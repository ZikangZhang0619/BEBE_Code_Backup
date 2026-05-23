

// ----- See: if the father is not responding, whether the mother's response is balanced across arms --------- // 

local waves 1m 2m 3m 6m

foreach wave in `waves' {
        use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update each week
        if "`wave'" == "1m" {
            keep if date <= date("2025-05-20", "YMD")
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("2025-04-13", "YMD")
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("2025-03-08", "YMD") 
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "6m" {
            keep if date <= date("2024-12-08", "YMD") 
        }

    gen treatment = "C" if 组别 == "1"
    replace treatment = "T1" if 组别 == "2"
    replace treatment = "T2" if 组别 == "3"

    gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6

    keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment hospital_id
    tempfile complete
    save `complete'

    keep 母亲姓名 母亲电话 treatment hospital_id
    rename (母亲姓名 母亲电话)(lastname firstname)
    gen parent = "M"
    tempfile mother
    save `mother'

    use `complete'
    keep 父亲姓名 父亲电话 treatment hospital_id
    rename (父亲姓名 父亲电话)(lastname firstname)
    gen parent = "F"
    tempfile father
    save `father'

    append using `mother'
    order firstname lastname

    tempfile participants
    save `participants'

    if "`wave'" == "2m" {
        merge 1:m firstname using "$proc/2m&6w_results.dta"
    }
    else {
        merge 1:m firstname using "$proc/`wave'_results.dta"
    }
    drop if _merge == 2
    gen response_`wave' = (_merge == 3)
    drop _merge
    drop if missing(firstname)

    merge m:1 hospital_id using ///
    "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
    keep if _merge == 3
    drop _merge

    duplicates drop firstname, force

    gen mother = (parent == "M")
    bys hospital_id (mother): gen only_mother = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 0)
    bys hospital_id (mother): gen only_father = (response_`wave'[_N] == 0 & response_`wave'[_N-1] == 1)
    bysort hospital_id (response_`wave'): gen response_either_`wave' = response_`wave'[_N]
    bys hospital_id : gen response_both_`wave' = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 1)

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")
    gen group = 1 if C == 1
    replace group = 2 if T1 == 1
    replace group = 3 if T2 == 1
    
    capture gen mother = (parent == "M")
    drop attribute_*

    save "$proc/attrition_`wave'.dta", replace


    use "$proc/attrition_`wave'.dta", clear
    gen response_m = response_`wave'  if mother == 1
    gen response_f = response_`wave' if mother == 0

    bys hospital_id: egen temp_mother_response = max(response_m)
    replace response_m = temp_mother_response if missing(response_m)

    bys hospital_id: egen temp_father_response = max(response_f)
    replace response_f = temp_father_response if missing(response_f)

    drop temp_*


    /* br if response_f != response_1m & mother == 0
    br if response_m != response_1m & mother == 1 */
    duplicates drop hospital_id, force  
        
    preserve 
        // Model father response probability
        // Add more baseline covariates here as available (age, education, income, etc.)
        logit response_f T1 i.strata i.enumerator_id, cluster(cluster_var)
        
        // Predict probabilities
        predict p_respond_f, pr
        
        // Create inverse probability weights
        // Weight = 1/P(respond) for responders, 1/P(not respond) for non-responders
        gen ipw_f = 1/p_respond_f if response_f == 1
        replace ipw_f = 1/(1-p_respond_f) if response_f == 0
        
        // Stabilize weights to prevent extreme values
        summarize ipw_f, detail
        // Trim weights at 99th percentile to avoid extreme influence
        egen ipw_f_p99 = pctile(ipw_f), p(99)
        replace ipw_f = ipw_f_p99 if ipw_f > ipw_f_p99 & !missing(ipw_f)
        
        // Alternative: Normalize weights to have mean 1
        summarize ipw_f
        replace ipw_f = ipw_f / r(mean)
        
        // Main regression with IPW
        gen T1_response_f = T1 * response_f
        reg response_m T1 response_f T1_response_f i.strata i.enumerator_id [pweight=ipw_f], cluster(cluster_var)
        
        // Store coefficients
        local coef_t1_`wave' = string(_b[T1], "%9.3f")
        local coef_response_f_`wave' = string(_b[response_f], "%9.3f")
        local coef_t1_response_f_`wave' = string(_b[T1_response_f], "%9.3f")
        
        // Store standard errors
        local se_t1_`wave' = string(_se[T1], "%9.3f")
        local se_response_f_`wave' = string(_se[response_f], "%9.3f")
        local se_t1_response_f_`wave' = string(_se[T1_response_f], "%9.3f")
        
        // Calculate p-values and significance stars
        local pval_t1_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local pval_response_f_`wave' = 2*ttail(e(df_r), abs(_b[response_f]/_se[response_f]))
        local pval_t1_response_f_`wave' = 2*ttail(e(df_r), abs(_b[T1_response_f]/_se[T1_response_f]))

        // T1 significance stars
        local star_t1_`wave' ""
        if (`pval_t1_`wave''<0.1) local star_t1_`wave' "*"
        if (`pval_t1_`wave''<0.05) local star_t1_`wave' "**"
        if (`pval_t1_`wave''<0.01) local star_t1_`wave' "***"
        
        // response_f significance stars
        local star_response_f_`wave' ""
        if (`pval_response_f_`wave''<0.1) local star_response_f_`wave' "*"
        if (`pval_response_f_`wave''<0.05) local star_response_f_`wave' "**"
        if (`pval_response_f_`wave''<0.01) local star_response_f_`wave' "***"

        // T1 x response_f significance stars
        local star_t1_response_f_`wave' ""
        if (`pval_t1_response_f_`wave''<0.1) local star_t1_response_f_`wave' "*"
        if (`pval_t1_response_f_`wave''<0.05) local star_t1_response_f_`wave' "**"
        if (`pval_t1_response_f_`wave''<0.01) local star_t1_response_f_`wave' "***"
        
        // Store other regression statistics
        local n_obs_`wave' = e(N)
        local r2_`wave' = string(e(r2), "%9.3f")
        local r2_adj_`wave' = string(e(r2_a), "%9.3f")
        
        // Store formatted coefficient strings for LaTeX
        local t1_latex_`wave' "`coef_t1_`wave''`star_t1_`wave''"
        local response_f_latex_`wave' "`coef_response_f_`wave''`star_response_f_`wave''"
        local t1_response_f_latex_`wave' "`coef_t1_response_f_`wave''`star_t1_response_f_`wave''"
        local se_t1_latex_`wave' "(`se_t1_`wave'')"
        local se_response_f_latex_`wave' "(`se_response_f_`wave'')"
        local se_t1_response_f_latex_`wave' "(`se_t1_response_f_`wave'')"
        
        // Store IPW diagnostics
        summarize ipw_f, detail
        local ipw_mean_`wave' = string(r(mean), "%9.3f")
        local ipw_min_`wave' = string(r(min), "%9.3f")
        local ipw_max_`wave' = string(r(max), "%9.3f")
        
        display "Wave `wave' T1 vs C - IPW diagnostics:"
        display "Mean weight: `ipw_mean_`wave'', Min: `ipw_min_`wave'', Max: `ipw_max_`wave''"
        
    restore

    preserve 
        drop if T1 == 1  // For T2 vs Control analysis
        
        // Model father response probability for T2 vs Control
        logit response_f T2 i.strata i.enumerator_id, cluster(cluster_var)
        
        // Predict probabilities
        predict p_respond_f_t2, pr
        
        // Create inverse probability weights
        gen ipw_f_t2 = 1/p_respond_f_t2 if response_f == 1
        replace ipw_f_t2 = 1/(1-p_respond_f_t2) if response_f == 0
        
        // Stabilize weights
        summarize ipw_f_t2, detail
        egen ipw_f_t2_p99 = pctile(ipw_f_t2), p(99)
        replace ipw_f_t2 = ipw_f_t2_p99 if ipw_f_t2 > ipw_f_t2_p99 & !missing(ipw_f_t2)
        
        // Normalize weights
        summarize ipw_f_t2
        replace ipw_f_t2 = ipw_f_t2 / r(mean)
        
        gen T2_response_f = T2 * response_f
        reg response_m T2 response_f T2_response_f i.strata i.enumerator_id [pweight=ipw_f_t2], cluster(cluster_var)
        
        // Store coefficients
        local coef_t2_`wave' = string(_b[T2], "%9.3f")
        local coef_response_f_t2_`wave' = string(_b[response_f], "%9.3f")
        local coef_t2_response_f_`wave' = string(_b[T2_response_f], "%9.3f")
        
        // Store standard errors
        local se_t2_`wave' = string(_se[T2], "%9.3f")
        local se_response_f_t2_`wave' = string(_se[response_f], "%9.3f")
        local se_t2_response_f_`wave' = string(_se[T2_response_f], "%9.3f")

        // Calculate p-values and significance stars
        local pval_t2_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local pval_response_f_t2_`wave' = 2*ttail(e(df_r), abs(_b[response_f]/_se[response_f]))
        local pval_t2_response_f_`wave' = 2*ttail(e(df_r), abs(_b[T2_response_f]/_se[T2_response_f]))

        // T2 significance stars
        local star_t2_`wave' ""
        if (`pval_t2_`wave''<0.1) local star_t2_`wave' "*"
        if (`pval_t2_`wave''<0.05) local star_t2_`wave' "**"
        if (`pval_t2_`wave''<0.01) local star_t2_`wave' "***"
        
        // response_f significance stars for T2 regression
        local star_response_f_t2_`wave' ""
        if (`pval_response_f_t2_`wave''<0.1) local star_response_f_t2_`wave' "*"
        if (`pval_response_f_t2_`wave''<0.05) local star_response_f_t2_`wave' "**"
        if (`pval_response_f_t2_`wave''<0.01) local star_response_f_t2_`wave' "***"

        // T2 x response_f significance stars
        local star_t2_response_f_`wave' ""
        if (`pval_t2_response_f_`wave''<0.1) local star_t2_response_f_`wave' "*"
        if (`pval_t2_response_f_`wave''<0.05) local star_t2_response_f_`wave' "**"
        if (`pval_t2_response_f_`wave''<0.01) local star_t2_response_f_`wave' "***"
        
        // Store other regression statistics
        local n_obs_t2_`wave' = e(N)
        local r2_t2_`wave' = string(e(r2), "%9.3f")
        local r2_adj_t2_`wave' = string(e(r2_a), "%9.3f")
        
        // Store formatted coefficient strings for LaTeX
        local t2_latex_`wave' "`coef_t2_`wave''`star_t2_`wave''"
        local response_f_t2_latex_`wave' "`coef_response_f_t2_`wave''`star_response_f_t2_`wave''"
        local t2_response_f_latex_`wave' "`coef_t2_response_f_`wave''`star_t2_response_f_`wave''"
        local se_t2_latex_`wave' "(`se_t2_`wave'')"
        local se_response_f_t2_latex_`wave' "(`se_response_f_t2_`wave'')"
        local se_t2_response_f_latex_`wave' "(`se_t2_response_f_`wave'')"
        
        // Store IPW diagnostics for T2
        summarize ipw_f_t2, detail
        local ipw_mean_t2_`wave' = string(r(mean), "%9.3f")
        local ipw_min_t2_`wave' = string(r(min), "%9.3f")
        local ipw_max_t2_`wave' = string(r(max), "%9.3f")
        
        display "Wave `wave' T2 vs C - IPW diagnostics:"
        display "Mean weight: `ipw_mean_t2_`wave'', Min: `ipw_min_t2_`wave'', Max: `ipw_max_t2_`wave''"
        
    restore
}

// After running all your regressions and storing locals, generate LaTeX table
capture file close latex
file open latex using "$results/tables/spillover_table_ipw.tex", write replace

// Table header
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\caption{Spillover Effects with Inverse Probability Weighting: Mother Response by Treatment Arm and Follow-up Period}" _n
file write latex "\label{tab:spillover_effects_ipw}" _n
file write latex "\footnotesize" _n
file write latex "\begin{tabular}{l*{8}{c}}" _n
file write latex "\hline\hline" _n

// Column headers
file write latex "& \multicolumn{4}{c}{T1 vs Control} & \multicolumn{4}{c}{T2 vs Control} \\" _n
file write latex "\cmidrule(lr){2-5} \cmidrule(lr){6-9}" _n
file write latex "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\" _n
file write latex "& 1 Month & 2 Month & 3 Month & 6 Month & 1 Month & 2 Month & 3 Month & 6 Month \\" _n
file write latex "\hline" _n

// Treatment coefficients row (effect when father doesn't respond)
file write latex "Treatment & `t1_latex_1m' & `t1_latex_2m' & `t1_latex_3m' & `t1_latex_6m' & `t2_latex_1m' & `t2_latex_2m' & `t2_latex_3m' & `t2_latex_6m' \\" _n

// Treatment standard errors row
file write latex "& `se_t1_latex_1m' & `se_t1_latex_2m' & `se_t1_latex_3m' & `se_t1_latex_6m' & `se_t2_latex_1m' & `se_t2_latex_2m' & `se_t2_latex_3m' & `se_t2_latex_6m' \\" _n

// Empty row for spacing
file write latex "\\" _n

// Father Response coefficients row (spillover effect in control group)
file write latex "Father Response & `response_f_latex_1m' & `response_f_latex_2m' & `response_f_latex_3m' & `response_f_latex_6m' & `response_f_t2_latex_1m' & `response_f_t2_latex_2m' & `response_f_t2_latex_3m' & `response_f_t2_latex_6m' \\" _n

// Father Response standard errors row
file write latex "& `se_response_f_latex_1m' & `se_response_f_latex_2m' & `se_response_f_latex_3m' & `se_response_f_latex_6m' & `se_response_f_t2_latex_1m' & `se_response_f_t2_latex_2m' & `se_response_f_t2_latex_3m' & `se_response_f_t2_latex_6m' \\" _n

// Empty row for spacing
file write latex "\\" _n

// Interaction coefficients row (difference in spillover effect between treatment and control)
file write latex "Treatment \$\\times\$ Father Response & `t1_response_f_latex_1m' & `t1_response_f_latex_2m' & `t1_response_f_latex_3m' & `t1_response_f_latex_6m' & `t2_response_f_latex_1m' & `t2_response_f_latex_2m' & `t2_response_f_latex_3m' & `t2_response_f_latex_6m' \\" _n

// Interaction standard errors row
file write latex "& `se_t1_response_f_latex_1m' & `se_t1_response_f_latex_2m' & `se_t1_response_f_latex_3m' & `se_t1_response_f_latex_6m' & `se_t2_response_f_latex_1m' & `se_t2_response_f_latex_2m' & `se_t2_response_f_latex_3m' & `se_t2_response_f_latex_6m' \\" _n

file write latex "\hline" _n

// Summary statistics
file write latex "Observations & `n_obs_1m' & `n_obs_2m' & `n_obs_3m' & `n_obs_6m' & `n_obs_t2_1m' & `n_obs_t2_2m' & `n_obs_t2_3m' & `n_obs_t2_6m' \\" _n

file write latex "R-squared & `r2_1m' & `r2_2m' & `r2_3m' & `r2_6m' & `r2_t2_1m' & `r2_t2_2m' & `r2_t2_3m' & `r2_t2_6m' \\" _n

// Fixed effects rows
file write latex "Strata FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write latex "Enumerator FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write latex "Inverse Probability Weights & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\" _n

// Table footer
file write latex "\hline\hline" _n
file write latex "\end{tabular}" _n

// Table notes
file write latex "\begin{tablenotes}" _n
file write latex "\footnotesize" _n
file write latex "\item \textit{Notes:} This table shows spillover effects on mother response rates using inverse probability weighting to account for non-random father response. The dependent variable is mother response (0/1). Father response probabilities are modeled using treatment assignment, strata, and enumerator fixed effects. Inverse probability weights are trimmed at the 99th percentile and normalized to have mean 1. Treatment is the direct effect when father doesn't respond. Father Response shows the spillover effect in the control group. Treatment \$\\times\$ Father Response shows the difference in spillover effects between treatment and control groups. T1 vs Control columns compare Treatment 1 to Control group (excluding T2). T2 vs Control columns compare Treatment 2 to Control group (excluding T1). Standard errors (in parentheses) are clustered at the cluster level. *** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.1." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{table}" _n

file close latex

// Display confirmation
display "LaTeX table written to spillover_table.tex"


//================== from mother to father ===================== //

local waves 1m 2m 3m 6m

foreach wave in `waves' {
        use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update each week
        if "`wave'" == "1m" {
            keep if date <= date("2025-05-20", "YMD")
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("2025-04-13", "YMD")
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("2025-03-08", "YMD") 
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "6m" {
            keep if date <= date("2024-12-08", "YMD") 
        }

    gen treatment = "C" if 组别 == "1"
    replace treatment = "T1" if 组别 == "2"
    replace treatment = "T2" if 组别 == "3"

    gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6

    keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment hospital_id
    tempfile complete
    save `complete'

    keep 母亲姓名 母亲电话 treatment hospital_id
    rename (母亲姓名 母亲电话)(lastname firstname)
    gen parent = "M"
    tempfile mother
    save `mother'

    use `complete'
    keep 父亲姓名 父亲电话 treatment hospital_id
    rename (父亲姓名 父亲电话)(lastname firstname)
    gen parent = "F"
    tempfile father
    save `father'

    append using `mother'
    order firstname lastname

    tempfile participants
    save `participants'

    if "`wave'" == "2m" {
        merge 1:m firstname using "$proc/2m&6w_results.dta"
    }
    else {
        merge 1:m firstname using "$proc/`wave'_results.dta"
    }
    drop if _merge == 2
    gen response_`wave' = (_merge == 3)
    drop _merge
    drop if missing(firstname)

    merge m:1 hospital_id using ///
    "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
    keep if _merge == 3
    drop _merge

    duplicates drop firstname, force

    gen mother = (parent == "M")
    bys hospital_id (mother): gen only_mother = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 0)
    bys hospital_id (mother): gen only_father = (response_`wave'[_N] == 0 & response_`wave'[_N-1] == 1)
    bysort hospital_id (response_`wave'): gen response_either_`wave' = response_`wave'[_N]
    bys hospital_id : gen response_both_`wave' = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 1)

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")
    gen group = 1 if C == 1
    replace group = 2 if T1 == 1
    replace group = 3 if T2 == 1
    
    capture gen mother = (parent == "M")
    drop attribute_*

    save "$proc/attrition_`wave'.dta", replace


    use "$proc/attrition_`wave'.dta", clear
    gen response_m = response_`wave'  if mother == 1
    gen response_f = response_`wave' if mother == 0

    bys hospital_id: egen temp_mother_response = max(response_m)
    replace response_m = temp_mother_response if missing(response_m)

    bys hospital_id: egen temp_father_response = max(response_f)
    replace response_f = temp_father_response if missing(response_f)

    drop temp_*


    /* br if response_f != response_1m & mother == 0
    br if response_m != response_1m & mother == 1 */
    duplicates drop hospital_id, force  
        
    preserve 
        // Model father response probability
        // Add more baseline covariates here as available (age, education, income, etc.)
        logit response_m T1 i.strata i.enumerator_id, cluster(cluster_var)
        
        // Predict probabilities
        predict p_respond_m, pr
        
        // Create inverse probability weights
        // Weight = 1/P(respond) for responders, 1/P(not respond) for non-responders
        gen ipw_m = 1/p_respond_m if response_m == 1
        replace ipw_m = 1/(1-p_respond_m) if response_m == 0
        
        // Stabilize weights to prevent extreme values
        summarize ipw_m, detail
        // Trim weights at 99th percentile to avoid extreme influence
        egen ipw_m_p99 = pctile(ipw_m), p(99)
        replace ipw_m = ipw_m_p99 if ipw_m > ipw_m_p99 & !missing(ipw_m)
        
        // Alternative: Normalize weights to have mean 1
        summarize ipw_m
        replace ipw_m = ipw_m / r(mean)
        
        // Main regression with IPW
        gen T1_response_m = T1 * response_m
        reg response_f T1 response_m T1_response_m i.strata i.enumerator_id [pweight=ipw_m], cluster(cluster_var)
        
        // Store coefficients
        local coef_t1_`wave' = string(_b[T1], "%9.3f")
        local coef_response_f_`wave' = string(_b[response_m], "%9.3f")
        local coef_t1_response_f_`wave' = string(_b[T1_response_m], "%9.3f")
        
        // Store standard errors
        local se_t1_`wave' = string(_se[T1], "%9.3f")
        local se_response_f_`wave' = string(_se[response_m], "%9.3f")
        local se_t1_response_f_`wave' = string(_se[T1_response_m], "%9.3f")
        
        // Calculate p-values and significance stars
        local pval_t1_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local pval_response_f_`wave' = 2*ttail(e(df_r), abs(_b[response_m]/_se[response_m]))
        local pval_t1_response_f_`wave' = 2*ttail(e(df_r), abs(_b[T1_response_m]/_se[T1_response_m]))

        // T1 significance stars
        local star_t1_`wave' ""
        if (`pval_t1_`wave''<0.1) local star_t1_`wave' "*"
        if (`pval_t1_`wave''<0.05) local star_t1_`wave' "**"
        if (`pval_t1_`wave''<0.01) local star_t1_`wave' "***"
        
        // response_m significance stars
        local star_response_f_`wave' ""
        if (`pval_response_f_`wave''<0.1) local star_response_f_`wave' "*"
        if (`pval_response_f_`wave''<0.05) local star_response_f_`wave' "**"
        if (`pval_response_f_`wave''<0.01) local star_response_f_`wave' "***"

        // T1 x response_m significance stars
        local star_t1_response_f_`wave' ""
        if (`pval_t1_response_f_`wave''<0.1) local star_t1_response_f_`wave' "*"
        if (`pval_t1_response_f_`wave''<0.05) local star_t1_response_f_`wave' "**"
        if (`pval_t1_response_f_`wave''<0.01) local star_t1_response_f_`wave' "***"
        
        // Store other regression statistics
        local n_obs_`wave' = e(N)
        local r2_`wave' = string(e(r2), "%9.3f")
        local r2_adj_`wave' = string(e(r2_a), "%9.3f")
        
        // Store formatted coefficient strings for LaTeX
        local t1_latex_`wave' "`coef_t1_`wave''`star_t1_`wave''"
        local response_f_latex_`wave' "`coef_response_f_`wave''`star_response_f_`wave''"
        local t1_response_f_latex_`wave' "`coef_t1_response_f_`wave''`star_t1_response_f_`wave''"
        local se_t1_latex_`wave' "(`se_t1_`wave'')"
        local se_response_f_latex_`wave' "(`se_response_f_`wave'')"
        local se_t1_response_f_latex_`wave' "(`se_t1_response_f_`wave'')"
        
        // Store IPW diagnostics
        summarize ipw_m, detail
        local ipw_mean_`wave' = string(r(mean), "%9.3f")
        local ipw_min_`wave' = string(r(min), "%9.3f")
        local ipw_max_`wave' = string(r(max), "%9.3f")
        
        display "Wave `wave' T1 vs C - IPW diagnostics:"
        display "Mean weight: `ipw_mean_`wave'', Min: `ipw_min_`wave'', Max: `ipw_max_`wave''"
        
    restore

    preserve 
        drop if T1 == 1  // For T2 vs Control analysis
        
        // Model father response probability for T2 vs Control
        logit response_m T2 i.strata i.enumerator_id, cluster(cluster_var)
        
        // Predict probabilities
        predict p_respond_m_t2, pr
        
        // Create inverse probability weights
        gen ipw_m_t2 = 1/p_respond_m_t2 if response_m == 1
        replace ipw_m_t2 = 1/(1-p_respond_m_t2) if response_m == 0
        
        // Stabilize weights
        summarize ipw_m_t2, detail
        egen ipw_m_t2_p99 = pctile(ipw_m_t2), p(99)
        replace ipw_m_t2 = ipw_m_t2_p99 if ipw_m_t2 > ipw_m_t2_p99 & !missing(ipw_m_t2)
        
        // Normalize weights
        summarize ipw_m_t2
        replace ipw_m_t2 = ipw_m_t2 / r(mean)
        
        gen T2_response_m = T2 * response_m
        reg response_f T2 response_m T2_response_m i.strata i.enumerator_id [pweight=ipw_m_t2], cluster(cluster_var)
        
        // Store coefficients
        local coef_t2_`wave' = string(_b[T2], "%9.3f")
        local coef_response_f_t2_`wave' = string(_b[response_m], "%9.3f")
        local coef_t2_response_f_`wave' = string(_b[T2_response_m], "%9.3f")
        
        // Store standard errors
        local se_t2_`wave' = string(_se[T2], "%9.3f")
        local se_response_f_t2_`wave' = string(_se[response_m], "%9.3f")
        local se_t2_response_f_`wave' = string(_se[T2_response_m], "%9.3f")

        // Calculate p-values and significance stars
        local pval_t2_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local pval_response_f_t2_`wave' = 2*ttail(e(df_r), abs(_b[response_m]/_se[response_m]))
        local pval_t2_response_f_`wave' = 2*ttail(e(df_r), abs(_b[T2_response_m]/_se[T2_response_m]))

        // T2 significance stars
        local star_t2_`wave' ""
        if (`pval_t2_`wave''<0.1) local star_t2_`wave' "*"
        if (`pval_t2_`wave''<0.05) local star_t2_`wave' "**"
        if (`pval_t2_`wave''<0.01) local star_t2_`wave' "***"
        
        // response_m significance stars for T2 regression
        local star_response_f_t2_`wave' ""
        if (`pval_response_f_t2_`wave''<0.1) local star_response_f_t2_`wave' "*"
        if (`pval_response_f_t2_`wave''<0.05) local star_response_f_t2_`wave' "**"
        if (`pval_response_f_t2_`wave''<0.01) local star_response_f_t2_`wave' "***"

        // T2 x response_m significance stars
        local star_t2_response_f_`wave' ""
        if (`pval_t2_response_f_`wave''<0.1) local star_t2_response_f_`wave' "*"
        if (`pval_t2_response_f_`wave''<0.05) local star_t2_response_f_`wave' "**"
        if (`pval_t2_response_f_`wave''<0.01) local star_t2_response_f_`wave' "***"
        
        // Store other regression statistics
        local n_obs_t2_`wave' = e(N)
        local r2_t2_`wave' = string(e(r2), "%9.3f")
        local r2_adj_t2_`wave' = string(e(r2_a), "%9.3f")
        
        // Store formatted coefficient strings for LaTeX
        local t2_latex_`wave' "`coef_t2_`wave''`star_t2_`wave''"
        local response_f_t2_latex_`wave' "`coef_response_f_t2_`wave''`star_response_f_t2_`wave''"
        local t2_response_f_latex_`wave' "`coef_t2_response_f_`wave''`star_t2_response_f_`wave''"
        local se_t2_latex_`wave' "(`se_t2_`wave'')"
        local se_response_f_t2_latex_`wave' "(`se_response_f_t2_`wave'')"
        local se_t2_response_f_latex_`wave' "(`se_t2_response_f_`wave'')"
        
        // Store IPW diagnostics for T2
        summarize ipw_m_t2, detail
        local ipw_mean_t2_`wave' = string(r(mean), "%9.3f")
        local ipw_min_t2_`wave' = string(r(min), "%9.3f")
        local ipw_max_t2_`wave' = string(r(max), "%9.3f")
        
        display "Wave `wave' T2 vs C - IPW diagnostics:"
        display "Mean weight: `ipw_mean_t2_`wave'', Min: `ipw_min_t2_`wave'', Max: `ipw_max_t2_`wave''"
        
    restore
}

// After running all your regressions and storing locals, generate LaTeX table
capture file close latex
file open latex using "$results/tables/spillover_table_ipw.tex", write append

// Table header
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\caption{Spillover Effects with Inverse Probability Weighting: Mother Response by Treatment Arm and Follow-up Period}" _n
file write latex "\label{tab:spillover_effects_ipw}" _n
file write latex "\footnotesize" _n
file write latex "\begin{tabular}{l*{8}{c}}" _n
file write latex "\hline\hline" _n

// Column headers
file write latex "& \multicolumn{4}{c}{T1 vs Control} & \multicolumn{4}{c}{T2 vs Control} \\" _n
file write latex "\cmidrule(lr){2-5} \cmidrule(lr){6-9}" _n
file write latex "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\" _n
file write latex "& 1 Month & 2 Month & 3 Month & 6 Month & 1 Month & 2 Month & 3 Month & 6 Month \\" _n
file write latex "\hline" _n

// Treatment coefficients row (effect when father doesn't respond)
file write latex "Treatment & `t1_latex_1m' & `t1_latex_2m' & `t1_latex_3m' & `t1_latex_6m' & `t2_latex_1m' & `t2_latex_2m' & `t2_latex_3m' & `t2_latex_6m' \\" _n

// Treatment standard errors row
file write latex "& `se_t1_latex_1m' & `se_t1_latex_2m' & `se_t1_latex_3m' & `se_t1_latex_6m' & `se_t2_latex_1m' & `se_t2_latex_2m' & `se_t2_latex_3m' & `se_t2_latex_6m' \\" _n

// Empty row for spacing
file write latex "\\" _n

// Father Response coefficients row (spillover effect in control group)
file write latex "Father Response & `response_f_latex_1m' & `response_f_latex_2m' & `response_f_latex_3m' & `response_f_latex_6m' & `response_f_t2_latex_1m' & `response_f_t2_latex_2m' & `response_f_t2_latex_3m' & `response_f_t2_latex_6m' \\" _n

// Father Response standard errors row
file write latex "& `se_response_f_latex_1m' & `se_response_f_latex_2m' & `se_response_f_latex_3m' & `se_response_f_latex_6m' & `se_response_f_t2_latex_1m' & `se_response_f_t2_latex_2m' & `se_response_f_t2_latex_3m' & `se_response_f_t2_latex_6m' \\" _n

// Empty row for spacing
file write latex "\\" _n

// Interaction coefficients row (difference in spillover effect between treatment and control)
file write latex "Treatment \$\\times\$ Father Response & `t1_response_f_latex_1m' & `t1_response_f_latex_2m' & `t1_response_f_latex_3m' & `t1_response_f_latex_6m' & `t2_response_f_latex_1m' & `t2_response_f_latex_2m' & `t2_response_f_latex_3m' & `t2_response_f_latex_6m' \\" _n

// Interaction standard errors row
file write latex "& `se_t1_response_f_latex_1m' & `se_t1_response_f_latex_2m' & `se_t1_response_f_latex_3m' & `se_t1_response_f_latex_6m' & `se_t2_response_f_latex_1m' & `se_t2_response_f_latex_2m' & `se_t2_response_f_latex_3m' & `se_t2_response_f_latex_6m' \\" _n

file write latex "\hline" _n

// Summary statistics
file write latex "Observations & `n_obs_1m' & `n_obs_2m' & `n_obs_3m' & `n_obs_6m' & `n_obs_t2_1m' & `n_obs_t2_2m' & `n_obs_t2_3m' & `n_obs_t2_6m' \\" _n

file write latex "R-squared & `r2_1m' & `r2_2m' & `r2_3m' & `r2_6m' & `r2_t2_1m' & `r2_t2_2m' & `r2_t2_3m' & `r2_t2_6m' \\" _n

// Fixed effects rows
file write latex "Strata FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write latex "Enumerator FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write latex "Inverse Probability Weights & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\" _n

// Table footer
file write latex "\hline\hline" _n
file write latex "\end{tabular}" _n

// Table notes
file write latex "\begin{tablenotes}" _n
file write latex "\footnotesize" _n
file write latex "\item \textit{Notes:} This table shows spillover effects on mother response rates using inverse probability weighting to account for non-random father response. The dependent variable is mother response (0/1). Father response probabilities are modeled using treatment assignment, strata, and enumerator fixed effects. Inverse probability weights are trimmed at the 99th percentile and normalized to have mean 1. Treatment is the direct effect when father doesn't respond. Father Response shows the spillover effect in the control group. Treatment \$\\times\$ Father Response shows the difference in spillover effects between treatment and control groups. T1 vs Control columns compare Treatment 1 to Control group (excluding T2). T2 vs Control columns compare Treatment 2 to Control group (excluding T1). Standard errors (in parentheses) are clustered at the cluster level. *** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.1." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{table}" _n

file close latex

// Display confirmation
display "LaTeX table written to spillover_table.tex"



//-----------------------------------------------------//
///    Father-Mother attrition correlation analysis ///
//----------------------------------------------------//

// Initialize matrices to store correlation results
matrix corr_results = J(12, 6, .)  // 4 waves x 3 groups, 6 columns for stats
matrix colnames corr_results = wave_num group correlation p_value n_pairs attrition_rate
local row = 1

// Define waves and create numeric mapping
local waves "1m 2m 3m 6m"
local wave_nums "1 2 3 6"  // Numeric equivalents for matrix storage

local wave_count = 1
foreach wave in `waves' {
    use "$proc/attrition_`wave'.dta", clear
    
    // Get numeric equivalent for this wave
    local wave_num : word `wave_count' of `wave_nums'
    
    gen response_m = response_`wave' if mother == 1
    gen response_f = response_`wave' if mother == 0

    bys hospital_id: egen temp_mother_response = max(response_m)
    replace response_m = temp_mother_response if missing(response_m)

    bys hospital_id: egen temp_father_response = max(response_f)
    replace response_f = temp_father_response if missing(response_f)

    drop temp_*

    duplicates drop hospital_id, force  
    
    forvalues g = 1/3 {
        preserve
        keep if group == `g'
        
        // Calculate correlation if we have enough observations
        count if !missing(response_m) & !missing(response_f)
        local n_pairs = r(N)
        
        if `n_pairs' >= 5 {  // Need at least 5 pairs for meaningful correlation
            
            // Calculate Pearson correlation
            quietly corr response_m response_f
            local correlation = r(rho)
            
            // Test significance of correlation
            quietly pwcorr response_m response_f, sig
            matrix pvals = r(sig)
            local p_value = pvals[2,1]
            
            // Calculate overall attrition rate for this group
            egen total_responses = rowtotal(response_m response_f)
            gen total_possible = 2  // 2 parents per family
            gen family_attrition_rate = total_responses / total_possible
            summarize family_attrition_rate
            local attrition_rate = r(mean)
            
            // Store results in matrix
            matrix corr_results[`row', 1] = `wave_num'  // Now using numeric value
            matrix corr_results[`row', 2] = `g'
            matrix corr_results[`row', 3] = `correlation'
            matrix corr_results[`row', 4] = `p_value'
            matrix corr_results[`row', 5] = `n_pairs'
            matrix corr_results[`row', 6] = `attrition_rate'
            
            // Store in locals for display (using wave string for naming)
            local corr_`wave'_g`g' = string(`correlation', "%9.3f")
            local pval_`wave'_g`g' = `p_value'
            local n_`wave'_g`g' = `n_pairs'
            local rate_`wave'_g`g' = string(`attrition_rate', "%9.3f")
            
            // Add significance stars
            local star_`wave'_g`g' ""
            if (`pval_`wave'_g`g'' < 0.1) local star_`wave'_g`g' "*"
            if (`pval_`wave'_g`g'' < 0.05) local star_`wave'_g`g' "**"
            if (`pval_`wave'_g`g'' < 0.01) local star_`wave'_g`g' "***"
            
            local corr_latex_`wave'_g`g' "`corr_`wave'_g`g''`star_`wave'_g`g''"
            
            // Display results
            di ""
            di "Wave: `wave', Group: `g'"
            di "Correlation: `corr_`wave'_g`g'' (p=`pval_`wave'_g`g'')"
            di "N pairs: `n_`wave'_g`g'', Attrition rate: `rate_`wave'_g`g''"
            
        }
        else {
            di "Wave: `wave', Group: `g' - Insufficient observations (N=`n_pairs')"
            // Still store in matrix for completeness
            matrix corr_results[`row', 1] = `wave_num'
            matrix corr_results[`row', 2] = `g'
            matrix corr_results[`row', 3] = .
            matrix corr_results[`row', 4] = .
            matrix corr_results[`row', 5] = `n_pairs'
            matrix corr_results[`row', 6] = .
            
            local corr_`wave'_g`g' = "N/A"
            local corr_latex_`wave'_g`g' = "N/A"
            local n_`wave'_g`g' = `n_pairs'
            local rate_`wave'_g`g' = "N/A"
        }
        
        restore
        local row = `row' + 1
    }
    
    // Save processed data for this wave
    save "$proc/correlation_`wave'.dta", replace
    local wave_count = `wave_count' + 1
}

// Create summary table
di ""
di "=== FATHER-MOTHER ATTRITION CORRELATION SUMMARY ==="
di ""
di "Wave" _col(10) "Control" _col(20) "T1" _col(30) "T2"
di "     " _col(10) "r (p-val)" _col(20) "r (p-val)" _col(30) "r (p-val)"
di "{hline 50}"

foreach wave in `waves' {
    di "`wave'" _col(10) "`corr_latex_`wave'_g1'" _col(20) "`corr_latex_`wave'_g2'" _col(30) "`corr_latex_`wave'_g3'"
}

di ""
di "*** p<0.01, ** p<0.05, * p<0.1"

// Display the correlation matrix for verification
di ""
di "=== CORRELATION RESULTS MATRIX ==="
matrix list corr_results

// ====== Write correlation results to LaTeX table ======
capture file close latex
file open latex using "$results/tables/attrition_correlation_table.tex", write replace

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\caption{Correlation between Father and Mother Attrition by Group and Wave}" _n
file write latex "\label{tab:father_mother_corr}" _n
file write latex "\footnotesize" _n
file write latex "\begin{tabular}{lccc|ccc|ccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c|}{Control} & \multicolumn{3}{c|}{T1} & \multicolumn{3}{c}{T2} \\" _n
file write latex "Wave & Corr. & N & Attr. Rate & Corr. & N & Attr. Rate & Corr. & N & Attr. Rate \\" _n
file write latex "\midrule" _n

// Check if locals exist before writing to avoid errors
capture confirm local corr_latex_1m_g1

    file write latex "1m & `corr_latex_1m_g1' & `n_1m_g1' & `rate_1m_g1' & `corr_latex_1m_g2' & `n_1m_g2' & `rate_1m_g2' & `corr_latex_1m_g3' & `n_1m_g3' & `rate_1m_g3' \\" _n

capture confirm local corr_latex_2m_g1

    file write latex "2m & `corr_latex_2m_g1' & `n_2m_g1' & `rate_2m_g1' & `corr_latex_2m_g2' & `n_2m_g2' & `rate_2m_g2' & `corr_latex_2m_g3' & `n_2m_g3' & `rate_2m_g3' \\" _n

capture confirm local corr_latex_3m_g1

    file write latex "3m & `corr_latex_3m_g1' & `n_3m_g1' & `rate_3m_g1' & `corr_latex_3m_g2' & `n_3m_g2' & `rate_3m_g2' & `corr_latex_3m_g3' & `n_3m_g3' & `rate_3m_g3' \\" _n

capture confirm local corr_latex_6m_g1

    file write latex "6m & `corr_latex_6m_g1' & `n_6m_g1' & `rate_6m_g1' & `corr_latex_6m_g2' & `n_6m_g2' & `rate_6m_g2' & `corr_latex_6m_g3' & `n_6m_g3' & `rate_6m_g3' \\" _n


file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\footnotesize" _n
file write latex "\item \textit{Notes:} Each cell shows the Pearson correlation between mother and father response (attrition) within family, by group and wave. Stars indicate significance: *** " _n
file write latex "$p<0.01$, ** $p<0.05$, * $p<0.1$. N is the number of families with both responses observed. Attr. Rate is the mean response rate per family." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{table}" _n

file close latex














