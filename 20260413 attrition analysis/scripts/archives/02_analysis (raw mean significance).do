** Attrition Analysis

** Haoyue Wu
** Updated on: 18 June, 2025


*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project attrition_table
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd



//********************************************************************************//
// 1. REPORT THE ATTRITION TABLE FOR EACH WAVES OF SURVEY WITH RESIDUALIZED MEANS //
//********************************************************************************//

local waves 1m 2m 3m 6m

foreach wave in `waves' {
    //*************** Data Preparation ***************//
    use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update each week
        if "`wave'" == "1m" {
            keep if date <= date("2025-08-05", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("2025-07-05", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("2025-06-01", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "6m" {
            /* keep if date <= date("2025-03-02", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0) */
            keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0
           
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
        capture drop _merge
        merge 1:m firstname using "$proc/2m&6w_results.dta"
    }
    if "`wave'" == "6m" {
        capture drop _merge
        drop if lastname == "姬灵"
        merge 1:m firstname using "$proc/6m_results.dta"
    }
    else {
        capture drop _merge
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

    bysort hospital_id (response_`wave'): gen response_either_`wave' = response_`wave'[_N]

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")
    gen group = 1 if C == 1
    replace group = 2 if T1 == 1
    replace group = 3 if T2 == 1
    
    gen mother = (parent == "M")
    drop attribute_*

    save "$proc/attrition_`wave'.dta", replace

    *------------------------------------------------------------*
    *             Regression: residualize attrition means        *
    *------------------------------------------------------------*
        // ---------- Mothers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su response_`wave' if `g'==1
            local mean_`g'_mother_`wave' : di %6.3f r(mean)
            local N_`g'_mother_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_`wave' T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_mother_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mother_`wave' ""
        if (`pval_t1c_mother_`wave''<0.1) local star_t1c_mother_`wave' "*"
        if (`pval_t1c_mother_`wave''<0.05) local star_t1c_mother_`wave' "**"
        if (`pval_t1c_mother_`wave''<0.01) local star_t1c_mother_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_`wave' T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_mother_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mother_`wave' ""
        if (`pval_t2c_mother_`wave''<0.1) local star_t2c_mother_`wave' "*"
        if (`pval_t2c_mother_`wave''<0.05) local star_t2c_mother_`wave' "**"
        if (`pval_t2c_mother_`wave''<0.01) local star_t2c_mother_`wave' "***"
        restore

        // Chi2 test
        tab response_`wave' group, chi2
        local pval_chi2_mother_`wave' : di %6.3f r(p)
        

        // ---------- Fathers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su response_`wave' if `g'==1
            local mean_`g'_father_`wave' : di %6.3f r(mean)
            local N_`g'_father_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_`wave' T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_father_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_father_`wave' ""
        if (`pval_t1c_father_`wave''<0.1) local star_t1c_father_`wave' "*"
        if (`pval_t1c_father_`wave''<0.05) local star_t1c_father_`wave' "**"
        if (`pval_t1c_father_`wave''<0.01) local star_t1c_father_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_`wave' T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_father_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_father_`wave' ""
        if (`pval_t2c_father_`wave''<0.1) local star_t2c_father_`wave' "*"
        if (`pval_t2c_father_`wave''<0.05) local star_t2c_father_`wave' "**"
        if (`pval_t2c_father_`wave''<0.01) local star_t2c_father_`wave' "***"
        restore

        // Chi2 test
        tab response_`wave' group, chi2
        local pval_chi2_father_`wave' : di %6.3f r(p)
        

        // ---------- Either parent ----------
        use "$proc/attrition_`wave'.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_either_`wave' if `g'==1
            local mean_`g'_either_`wave' : di %6.3f r(mean)
            local N_`g'_either_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_either_`wave' T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_either_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_either_`wave' ""
        if (`pval_t1c_either_`wave''<0.1) local star_t1c_either_`wave' "*"
        if (`pval_t1c_either_`wave''<0.05) local star_t1c_either_`wave' "**"
        if (`pval_t1c_either_`wave''<0.01) local star_t1c_either_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_either_`wave' T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_either_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_either_`wave' ""
        if (`pval_t2c_either_`wave''<0.1) local star_t2c_either_`wave' "*"
        if (`pval_t2c_either_`wave''<0.05) local star_t2c_either_`wave' "**"
        if (`pval_t2c_either_`wave''<0.01) local star_t2c_either_`wave' "***"
        restore

        // Chi2 test
        tab response_either_`wave' group, chi2
        local pval_chi2_either_`wave' : di %6.3f r(p)
        
}
di `N_C_mother_6m' `N_T1_mother_6m' `N_T2_mother_6m'
// Output LaTeX tables for each wave and respondent type (mother, father, either)

capture file close latex
file open latex using "$results/tables/attrition_raw_significance.tex", write replace

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 1m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_1m' &`mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m' &  0.926 &  0.883** &  0.811*** \\" _n
file write latex "Father & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' &  0.908 &  0.804*** &  0.764***" _n
file write latex "Either & `mean_C_either_1m' & `mean_T1_either_1m'`star_t1c_either_1m' & `mean_T2_either_1m'`star_t2c_either_1m' &  0.977 &  0.944** &  0.924***  \\" _n
file write latex "N(Family) & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' & 393 & 403 & 381 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 2m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m'  &  0.893 &  0.839** &  0.774*** \\" _n
file write latex "Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' &  0.903 &  0.752*** &  0.698*** \\" _n
file write latex "Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_t1c_either_2m' & `mean_T2_either_2m'`star_t2c_either_2m' &  0.959 &  0.924** &  0.869***  \\" _n
file write latex "N(Family) & `N_C_mother_2m' & `N_T1_mother_2m' & `N_T2_mother_2m' & 393 & 403 & 381 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n



file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 3m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_t1c_mother_3m' & `mean_T2_mother_3m'`star_t2c_mother_3m' &  0.878 &  0.809*** &  0.785***  \\" _n
file write latex "Father & `mean_C_father_3m' & `mean_T1_father_3m'`star_t1c_father_3m' & `mean_T2_father_3m'`star_t2c_father_3m' &  0.903 &  0.735*** &  0.709*** \\" _n
file write latex "Either & `mean_C_either_3m' & `mean_T1_either_3m'`star_t1c_either_3m' & `mean_T2_either_3m'`star_t2c_either_3m' &  0.954 &  0.902*** &  0.877***  \\" _n
file write latex "N(Family) & `N_C_mother_3m' & `N_T1_mother_3m' & `N_T2_mother_3m'  & 393 & 403 & 381 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 6m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_t1c_mother_6m' & `mean_T2_mother_6m'`star_t2c_mother_6m' &  0.878 &  0.809*** &  0.785***  \\" _n
file write latex "Father & `mean_C_father_6m' & `mean_T1_father_6m'`star_t1c_father_6m' & `mean_T2_father_6m'`star_t2c_father_6m' &  0.903 &  0.735*** &  0.709*** \\" _n
file write latex "Either & `mean_C_either_6m' & `mean_T1_either_6m'`star_t1c_either_6m' & `mean_T2_either_6m'`star_t2c_either_6m' &  0.954 &  0.902*** &  0.877***  \\" _n
file write latex "N(Family) & `N_C_mother_6m' & `N_T1_mother_6m' & `N_T2_mother_6m'  & 393 & 403 & 381 \\" _n


file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


//********************************************************************************//
//                   2. ATTRITION FOR CONSECUTIVE WAVES OF SURVEYS               //
//********************************************************************************//

*------------------------------------------------------------*
*                           1m & 2m                          *
*------------------------------------------------------------*

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-07-05", "YMD") 
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

duplicates drop firstname, force
merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen response_1m = (_merge == 3)
drop _merge
drop if missing(firstname)

tempfile 1m
save `1m'

use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/2m&6w_results.dta"
drop if _merge == 2
gen response_2m = (_merge == 3)
drop _merge
drop if missing(firstname)
duplicates drop firstname, force

tempfile 2m
save `2m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

// fix some errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"
replace hospital_id = "D00338830" if firstname == "17740880560"

gen any_response = (response_1m == 1 | response_2m == 1)

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
drop attribute_*

duplicates drop firstname, force

save "$proc/attrition_1m_2m.dta", replace

*-------------------------------------------------*
*             Regression: treatment effect        *
*-------------------------------------------------*

// ---------- Mothers ----------
use "$proc/attrition_1m_2m.dta", clear
keep if mother == 1
foreach g in C T1 T2 {
    su response_1m if `g'==1
    local mean_`g'_mother_1m : di %6.3f r(mean)
    local N_`g'_mother_1m = r(N)
    su response_2m if `g'==1
    local mean_`g'_mother_2m : di %6.3f r(mean)
    local N_`g'_mother_2m = r(N)
    su any_response if `g'==1
    local mean_`g'_mother_any : di %6.3f r(mean)
    local N_`g'_mother_any = r(N)
}

// T1 vs C
preserve
drop if T2==1
reg response_1m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_1m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_1m ""
if (`pval_t1c_mother_1m'<0.1) local star_t1c_mother_1m "*"
if (`pval_t1c_mother_1m'<0.05) local star_t1c_mother_1m "**"
if (`pval_t1c_mother_1m'<0.01) local star_t1c_mother_1m "***"
restore

preserve
drop if T2==1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_2m ""
if (`pval_t1c_mother_2m'<0.1) local star_t1c_mother_2m "*"
if (`pval_t1c_mother_2m'<0.05) local star_t1c_mother_2m "**"
if (`pval_t1c_mother_2m'<0.01) local star_t1c_mother_2m "***"
restore

preserve
drop if T2==1
reg any_response T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_any = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_any ""
if (`pval_t1c_mother_any'<0.1) local star_t1c_mother_any "*"
if (`pval_t1c_mother_any'<0.05) local star_t1c_mother_any "**"
if (`pval_t1c_mother_any'<0.01) local star_t1c_mother_any "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_1m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_1m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_1m ""
if (`pval_t2c_mother_1m'<0.1) local star_t2c_mother_1m "*"
if (`pval_t2c_mother_1m'<0.05) local star_t2c_mother_1m "**"
if (`pval_t2c_mother_1m'<0.01) local star_t2c_mother_1m "***"
restore

preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_2m ""
if (`pval_t2c_mother_2m'<0.1) local star_t2c_mother_2m "*"
if (`pval_t2c_mother_2m'<0.05) local star_t2c_mother_2m "**"
if (`pval_t2c_mother_2m'<0.01) local star_t2c_mother_2m "***"
restore

preserve
drop if T1==1
reg any_response T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_any = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_any ""
if (`pval_t2c_mother_any'<0.1) local star_t2c_mother_any "*"
if (`pval_t2c_mother_any'<0.05) local star_t2c_mother_any "**"
if (`pval_t2c_mother_any'<0.01) local star_t2c_mother_any "***"
restore

// ---------- Fathers ----------
use "$proc/attrition_1m_2m.dta", clear
keep if mother == 0
foreach g in C T1 T2 {
    su response_1m if `g'==1
    local mean_`g'_father_1m : di %6.3f r(mean)
    local N_`g'_father_1m = r(N)
    su response_2m if `g'==1
    local mean_`g'_father_2m : di %6.3f r(mean)
    local N_`g'_father_2m = r(N)
    su any_response if `g'==1
    local mean_`g'_father_any : di %6.3f r(mean)
    local N_`g'_father_any = r(N)
}

// T1 vs C
preserve
drop if T2==1
reg response_1m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_1m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_1m ""
if (`pval_t1c_father_1m'<0.1) local star_t1c_father_1m "*"
if (`pval_t1c_father_1m'<0.05) local star_t1c_father_1m "**"
if (`pval_t1c_father_1m'<0.01) local star_t1c_father_1m "***"
restore

preserve
drop if T2==1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_2m ""
if (`pval_t1c_father_2m'<0.1) local star_t1c_father_2m "*"
if (`pval_t1c_father_2m'<0.05) local star_t1c_father_2m "**"
if (`pval_t1c_father_2m'<0.01) local star_t1c_father_2m "***"
restore

preserve
drop if T2==1
reg any_response T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_any = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_any ""
if (`pval_t1c_father_any'<0.1) local star_t1c_father_any "*"
if (`pval_t1c_father_any'<0.05) local star_t1c_father_any "**"
if (`pval_t1c_father_any'<0.01) local star_t1c_father_any "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_1m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_1m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_1m ""
if (`pval_t2c_father_1m'<0.1) local star_t2c_father_1m "*"
if (`pval_t2c_father_1m'<0.05) local star_t2c_father_1m "**"
if (`pval_t2c_father_1m'<0.01) local star_t2c_father_1m "***"
restore

preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_2m ""
if (`pval_t2c_father_2m'<0.1) local star_t2c_father_2m "*"
if (`pval_t2c_father_2m'<0.05) local star_t2c_father_2m "**"
if (`pval_t2c_father_2m'<0.01) local star_t2c_father_2m "***"
restore

preserve
drop if T1==1
reg any_response T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_any = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_any ""
if (`pval_t2c_father_any'<0.1) local star_t2c_father_any "*"
if (`pval_t2c_father_any'<0.05) local star_t2c_father_any "**"
if (`pval_t2c_father_any'<0.01) local star_t2c_father_any "***"
restore

// Output LaTeX table for 1m & 2m
capture file close resultsfile
file open resultsfile using "$results/tables/response_across_wave.tex", write replace

file write resultsfile "\begin{table}[htbp]" _n
file write resultsfile "\centering" _n
file write resultsfile "\caption{Raw Means with Significance}" _n
file write resultsfile "\begin{tabular}{lcccccc}" _n
file write resultsfile "\toprule" _n
file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write resultsfile "\textbf{Measure} & Control & T1 & T2 & Control & T1 & T2 \\" _n
file write resultsfile "\midrule" _n

file write resultsfile "1m Response & `mean_C_mother_1m' & `mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m' & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' \\" _n

file write resultsfile "2m Response & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m' & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' \\" _n

file write resultsfile "Any Response & `mean_C_mother_any' & `mean_T1_mother_any'`star_t1c_mother_any' & `mean_T2_mother_any'`star_t2c_mother_any' & `mean_C_father_any' & `mean_T1_father_any'`star_t1c_father_any' & `mean_T2_father_any'`star_t2c_father_any' \\" _n

file write resultsfile "N & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' & `N_C_father_1m' & `N_T1_father_1m' & `N_T2_father_1m' \\" _n

file write resultsfile "\bottomrule" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\small" _n
file write resultsfile "Notes: Stars indicate significance relative to the control group. " _n
file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write resultsfile "Residualized means control for strata and enumerator fixed effects." _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{table}" _n

file close resultsfile

// Repeat the above structure for 1m & 2m & 3m and 1m & 2m & 3m & 6m
// (You can adapt the regression and output code as above for each case)


*-----------------------------------------------------------------*
*                           1m & 2m & 3m                          *
*-----------------------------------------------------------------*
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-06-01", "YMD")
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

duplicates drop firstname, force
merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen response_1m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 1m
save `1m'

use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/2m&6w_results.dta"
drop if _merge == 2
gen response_2m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 2m
save `2m'

use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/3m_results.dta"
drop if _merge == 2
gen response_3m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 3m
save `3m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `3m', force
drop if _merge == 1
drop _merge 

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

 
// fix errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"

gen any_response = (response_1m == 1 | response_2m == 1 | response_3m == 1)

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
drop attribute_*

duplicates drop firstname, force

save "$proc/attrition_1m_2m_3m.dta", replace

*------------------------------------------------------------*
*             Regression: residualize attrition means        *
*------------------------------------------------------------*
// ---------- Mothers ----------
use "$proc/attrition_1m_2m_3m.dta", clear
keep if mother == 1
foreach g in C T1 T2 {
    su response_1m if `g'==1
    local mean_`g'_mother_1m : di %6.3f r(mean)
    local N_`g'_mother_1m = r(N)
    su response_2m if `g'==1
    local mean_`g'_mother_2m : di %6.3f r(mean)
    local N_`g'_mother_2m = r(N)
    su response_3m if `g'==1
    local mean_`g'_mother_3m : di %6.3f r(mean)
    local N_`g'_mother_3m = r(N)
    su any_response if `g'==1
    local mean_`g'_mother_any : di %6.3f r(mean)
    local N_`g'_mother_any = r(N)
}

// T1 vs C
preserve
drop if T2==1
reg response_1m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_1m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_1m ""
if (`pval_t1c_mother_1m'<0.1) local star_t1c_mother_1m "*"
if (`pval_t1c_mother_1m'<0.05) local star_t1c_mother_1m "**"
if (`pval_t1c_mother_1m'<0.01) local star_t1c_mother_1m "***"
restore

preserve
drop if T2==1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_2m ""
if (`pval_t1c_mother_2m'<0.1) local star_t1c_mother_2m "*"
if (`pval_t1c_mother_2m'<0.05) local star_t1c_mother_2m "**"
if (`pval_t1c_mother_2m'<0.01) local star_t1c_mother_2m "***"
restore

preserve
drop if T2==1
reg response_3m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_3m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_3m ""
if (`pval_t1c_mother_3m'<0.1) local star_t1c_mother_3m "*"
if (`pval_t1c_mother_3m'<0.05) local star_t1c_mother_3m "**"
if (`pval_t1c_mother_3m'<0.01) local star_t1c_mother_3m "***"
restore

preserve
drop if T2==1
reg any_response T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_any = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_any ""
if (`pval_t1c_mother_any'<0.1) local star_t1c_mother_any "*"
if (`pval_t1c_mother_any'<0.05) local star_t1c_mother_any "**"
if (`pval_t1c_mother_any'<0.01) local star_t1c_mother_any "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_1m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_1m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_1m ""
if (`pval_t2c_mother_1m'<0.1) local star_t2c_mother_1m "*"
if (`pval_t2c_mother_1m'<0.05) local star_t2c_mother_1m "**"
if (`pval_t2c_mother_1m'<0.01) local star_t2c_mother_1m "***"
restore

preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_2m ""
if (`pval_t2c_mother_2m'<0.1) local star_t2c_mother_2m "*"
if (`pval_t2c_mother_2m'<0.05) local star_t2c_mother_2m "**"
if (`pval_t2c_mother_2m'<0.01) local star_t2c_mother_2m "***"
restore

preserve
drop if T1==1
reg response_3m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_3m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_3m ""
if (`pval_t2c_mother_3m'<0.1) local star_t2c_mother_3m "*"
if (`pval_t2c_mother_3m'<0.05) local star_t2c_mother_3m "**"
if (`pval_t2c_mother_3m'<0.01) local star_t2c_mother_3m "***"
restore

preserve
drop if T1==1
reg any_response T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_any = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_any ""
if (`pval_t2c_mother_any'<0.1) local star_t2c_mother_any "*"
if (`pval_t2c_mother_any'<0.05) local star_t2c_mother_any "**"
if (`pval_t2c_mother_any'<0.01) local star_t2c_mother_any "***"
restore

// ---------- Fathers ----------
use "$proc/attrition_1m_2m_3m.dta", clear
keep if mother == 0
foreach g in C T1 T2 {
    su response_1m if `g'==1
    local mean_`g'_father_1m : di %6.3f r(mean)
    local N_`g'_father_1m = r(N)
    su response_2m if `g'==1
    local mean_`g'_father_2m : di %6.3f r(mean)
    local N_`g'_father_2m = r(N)
    su response_3m if `g'==1
    local mean_`g'_father_3m : di %6.3f r(mean)
    local N_`g'_father_3m = r(N)
    su any_response if `g'==1
    local mean_`g'_father_any : di %6.3f r(mean)
    local N_`g'_father_any = r(N)
}

// T1 vs C
preserve
drop if T2==1
reg response_1m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_1m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_1m ""
if (`pval_t1c_father_1m'<0.1) local star_t1c_father_1m "*"
if (`pval_t1c_father_1m'<0.05) local star_t1c_father_1m "**"
if (`pval_t1c_father_1m'<0.01) local star_t1c_father_1m "***"
restore

preserve
drop if T2==1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_2m ""
if (`pval_t1c_father_2m'<0.1) local star_t1c_father_2m "*"
if (`pval_t1c_father_2m'<0.05) local star_t1c_father_2m "**"
if (`pval_t1c_father_2m'<0.01) local star_t1c_father_2m "***"
restore

preserve
drop if T2==1
reg response_3m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_3m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_3m ""
if (`pval_t1c_father_3m'<0.1) local star_t1c_father_3m "*"
if (`pval_t1c_father_3m'<0.05) local star_t1c_father_3m "**"
if (`pval_t1c_father_3m'<0.01) local star_t1c_father_3m "***"
restore

preserve
drop if T2==1
reg any_response T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_any = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_any ""
if (`pval_t1c_father_any'<0.1) local star_t1c_father_any "*"
if (`pval_t1c_father_any'<0.05) local star_t1c_father_any "**"
if (`pval_t1c_father_any'<0.01) local star_t1c_father_any "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_1m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_1m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_1m ""
if (`pval_t2c_father_1m'<0.1) local star_t2c_father_1m "*"
if (`pval_t2c_father_1m'<0.05) local star_t2c_father_1m "**"
if (`pval_t2c_father_1m'<0.01) local star_t2c_father_1m "***"
restore

preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_2m ""
if (`pval_t2c_father_2m'<0.1) local star_t2c_father_2m "*"
if (`pval_t2c_father_2m'<0.05) local star_t2c_father_2m "**"
if (`pval_t2c_father_2m'<0.01) local star_t2c_father_2m "***"
restore

preserve
drop if T1==1
reg response_3m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_3m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_3m ""
if (`pval_t2c_father_3m'<0.1) local star_t2c_father_3m "*"
if (`pval_t2c_father_3m'<0.05) local star_t2c_father_3m "**"
if (`pval_t2c_father_3m'<0.01) local star_t2c_father_3m "***"
restore

preserve
drop if T1==1
reg any_response T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_any = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_any ""
if (`pval_t2c_father_any'<0.1) local star_t2c_father_any "*"
if (`pval_t2c_father_any'<0.05) local star_t2c_father_any "**"
if (`pval_t2c_father_any'<0.01) local star_t2c_father_any "***"
restore

// Output LaTeX table for 1m, 2m, 3m
capture file close resultsfile
file open resultsfile using "$results/tables/response_across_wave.tex", write append

file write resultsfile "\begin{table}[htbp]" _n
file write resultsfile "\centering" _n
file write resultsfile "\caption{Raw Means with Significance (1m, 2m, 3m)}" _n
file write resultsfile "\begin{tabular}{lcccccc}" _n
file write resultsfile "\toprule" _n
file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write resultsfile "\textbf{Measure} & Control & T1 & T2 & Control & T1 & T2 \\" _n
file write resultsfile "\midrule" _n

file write resultsfile "1m Response & `mean_C_mother_1m' & `mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m' & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' \\" _n

file write resultsfile "2m Response & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m' & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' \\" _n

file write resultsfile "3m Response & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_t1c_mother_3m' & `mean_T2_mother_3m'`star_t2c_mother_3m' & `mean_C_father_3m' & `mean_T1_father_3m'`star_t1c_father_3m' & `mean_T2_father_3m'`star_t2c_father_3m' \\" _n

file write resultsfile "Any Response & `mean_C_mother_any' & `mean_T1_mother_any'`star_t1c_mother_any' & `mean_T2_mother_any'`star_t2c_mother_any' & `mean_C_father_any' & `mean_T1_father_any'`star_t1c_father_any' & `mean_T2_father_any'`star_t2c_father_any' \\" _n
file write resultsfile "N & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' & `N_C_father_1m' & `N_T1_father_1m' & `N_T2_father_1m' \\" _n
file write resultsfile "\bottomrule" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\small" _n
file write resultsfile "Notes: Stars indicate significance relative to the control group. " _n
file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write resultsfile "Residualized means control for strata and enumerator fixed effects." _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{table}" _n

file close resultsfile

*-----------------------------------------------------------------*
*                        1m & 2m & 3m & 6m                        *
*-----------------------------------------------------------------*
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-03-02", "YMD")
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

duplicates drop firstname, force
merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen response_1m = (_merge == 3)
drop _merge
drop if firstname == ""

tempfile 1m
save `1m'

use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/2m&6w_results.dta"
drop if _merge == 2
gen response_2m = (_merge == 3)
drop _merge
drop if firstname == ""

tempfile 2m
save `2m'

use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/3m_results.dta"
drop if _merge == 2
gen response_3m = (_merge == 3)
drop _merge
drop if firstname == ""

tempfile 3m
save `3m'

use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/6m_results.dta"
drop if _merge == 2
gen response_6m = (_merge == 3)
drop _merge
drop if firstname == ""

tempfile 6m
save `6m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `3m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `6m', force
drop if _merge == 1
drop _merge

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

// fix errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"

gen any_response = (response_1m == 1 | response_2m == 1 | response_3m == 1 | response_6m == 1)

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
drop attribute_*

duplicates drop firstname, force

save "$proc/attrition_1m_2m_3m_6m.dta", replace

*------------------------------------------------------------*
*             Regression: residualize attrition means        *
*------------------------------------------------------------*
// ---------- Mothers ----------
use "$proc/attrition_1m_2m_3m_6m.dta", clear
keep if mother == 1
foreach g in C T1 T2 {
    su response_1m if `g'==1
    local mean_`g'_mother_1m : di %6.3f r(mean)
    local N_`g'_mother_1m = r(N)
    su response_2m if `g'==1
    local mean_`g'_mother_2m : di %6.3f r(mean)
    local N_`g'_mother_2m = r(N)
    su response_3m if `g'==1
    local mean_`g'_mother_3m : di %6.3f r(mean)
    local N_`g'_mother_3m = r(N)
    su response_6m if `g'==1
    local mean_`g'_mother_6m : di %6.3f r(mean)
    local N_`g'_mother_6m = r(N)
    su any_response if `g'==1
    local mean_`g'_mother_any : di %6.3f r(mean)
    local N_`g'_mother_any = r(N)
}

// T1 vs C
preserve
drop if T2==1
reg response_1m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_1m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_1m ""
if (`pval_t1c_mother_1m'<0.1) local star_t1c_mother_1m "*"
if (`pval_t1c_mother_1m'<0.05) local star_t1c_mother_1m "**"
if (`pval_t1c_mother_1m'<0.01) local star_t1c_mother_1m "***"
restore

preserve
drop if T2==1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_2m ""
if (`pval_t1c_mother_2m'<0.1) local star_t1c_mother_2m "*"
if (`pval_t1c_mother_2m'<0.05) local star_t1c_mother_2m "**"
if (`pval_t1c_mother_2m'<0.01) local star_t1c_mother_2m "***"
restore

preserve
drop if T2==1
reg response_3m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_3m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_3m ""
if (`pval_t1c_mother_3m'<0.1) local star_t1c_mother_3m "*"
if (`pval_t1c_mother_3m'<0.05) local star_t1c_mother_3m "**"
if (`pval_t1c_mother_3m'<0.01) local star_t1c_mother_3m "***"
restore

preserve
drop if T2==1
reg response_6m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_6m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_6m ""
if (`pval_t1c_mother_6m'<0.1) local star_t1c_mother_6m "*"
if (`pval_t1c_mother_6m'<0.05) local star_t1c_mother_6m "**"
if (`pval_t1c_mother_6m'<0.01) local star_t1c_mother_6m "***"
restore

preserve
drop if T2==1
reg any_response T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_any = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_any ""
if (`pval_t1c_mother_any'<0.1) local star_t1c_mother_any "*"
if (`pval_t1c_mother_any'<0.05) local star_t1c_mother_any "**"
if (`pval_t1c_mother_any'<0.01) local star_t1c_mother_any "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_1m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_1m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_1m ""
if (`pval_t2c_mother_1m'<0.1) local star_t2c_mother_1m "*"
if (`pval_t2c_mother_1m'<0.05) local star_t2c_mother_1m "**"
if (`pval_t2c_mother_1m'<0.01) local star_t2c_mother_1m "***"
restore

preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_2m ""
if (`pval_t2c_mother_2m'<0.1) local star_t2c_mother_2m "*"
if (`pval_t2c_mother_2m'<0.05) local star_t2c_mother_2m "**"
if (`pval_t2c_mother_2m'<0.01) local star_t2c_mother_2m "***"
restore

preserve
drop if T1==1
reg response_3m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_3m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_3m ""
if (`pval_t2c_mother_3m'<0.1) local star_t2c_mother_3m "*"
if (`pval_t2c_mother_3m'<0.05) local star_t2c_mother_3m "**"
if (`pval_t2c_mother_3m'<0.01) local star_t2c_mother_3m "***"
restore

preserve
drop if T1==1
reg response_6m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_6m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_6m ""
if (`pval_t2c_mother_6m'<0.1) local star_t2c_mother_6m "*"
if (`pval_t2c_mother_6m'<0.05) local star_t2c_mother_6m "**"
if (`pval_t2c_mother_6m'<0.01) local star_t2c_mother_6m "***"
restore

preserve
drop if T1==1
reg any_response T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_any = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_any ""
if (`pval_t2c_mother_any'<0.1) local star_t2c_mother_any "*"
if (`pval_t2c_mother_any'<0.05) local star_t2c_mother_any "**"
if (`pval_t2c_mother_any'<0.01) local star_t2c_mother_any "***"
restore

// ---------- Fathers ----------
use "$proc/attrition_1m_2m_3m_6m.dta", clear
keep if mother == 0
foreach g in C T1 T2 {
    su response_1m if `g'==1
    local mean_`g'_father_1m : di %6.3f r(mean)
    local N_`g'_father_1m = r(N)
    su response_2m if `g'==1
    local mean_`g'_father_2m : di %6.3f r(mean)
    local N_`g'_father_2m = r(N)
    su response_3m if `g'==1
    local mean_`g'_father_3m : di %6.3f r(mean)
    local N_`g'_father_3m = r(N)
    su response_6m if `g'==1
    local mean_`g'_father_6m : di %6.3f r(mean)
    local N_`g'_father_6m = r(N)
    su any_response if `g'==1
    local mean_`g'_father_any : di %6.3f r(mean)
    local N_`g'_father_any = r(N)
}

// T1 vs C
preserve
drop if T2==1
reg response_1m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_1m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_1m ""
if (`pval_t1c_father_1m'<0.1) local star_t1c_father_1m "*"
if (`pval_t1c_father_1m'<0.05) local star_t1c_father_1m "**"
if (`pval_t1c_father_1m'<0.01) local star_t1c_father_1m "***"
restore

preserve
drop if T2==1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_2m ""
if (`pval_t1c_father_2m'<0.1) local star_t1c_father_2m "*"
if (`pval_t1c_father_2m'<0.05) local star_t1c_father_2m "**"
if (`pval_t1c_father_2m'<0.01) local star_t1c_father_2m "***"
restore

preserve
drop if T2==1
reg response_3m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_3m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_3m ""
if (`pval_t1c_father_3m'<0.1) local star_t1c_father_3m "*"
if (`pval_t1c_father_3m'<0.05) local star_t1c_father_3m "**"
if (`pval_t1c_father_3m'<0.01) local star_t1c_father_3m "***"
restore

preserve
drop if T2==1
reg response_6m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_6m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_6m ""
if (`pval_t1c_father_6m'<0.1) local star_t1c_father_6m "*"
if (`pval_t1c_father_6m'<0.05) local star_t1c_father_6m "**"
if (`pval_t1c_father_6m'<0.01) local star_t1c_father_6m "***"
restore

preserve
drop if T2==1
reg any_response T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_any = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_any ""
if (`pval_t1c_father_any'<0.1) local star_t1c_father_any "*"
if (`pval_t1c_father_any'<0.05) local star_t1c_father_any "**"
if (`pval_t1c_father_any'<0.01) local star_t1c_father_any "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_1m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_1m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_1m ""
if (`pval_t2c_father_1m'<0.1) local star_t2c_father_1m "*"
if (`pval_t2c_father_1m'<0.05) local star_t2c_father_1m "**"
if (`pval_t2c_father_1m'<0.01) local star_t2c_father_1m "***"
restore

preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_2m ""
if (`pval_t2c_father_2m'<0.1) local star_t2c_father_2m "*"
if (`pval_t2c_father_2m'<0.05) local star_t2c_father_2m "**"
if (`pval_t2c_father_2m'<0.01) local star_t2c_father_2m "***"
restore

preserve
drop if T1==1
reg response_3m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_3m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_3m ""
if (`pval_t2c_father_3m'<0.1) local star_t2c_father_3m "*"
if (`pval_t2c_father_3m'<0.05) local star_t2c_father_3m "**"
if (`pval_t2c_father_3m'<0.01) local star_t2c_father_3m "***"
restore

preserve
drop if T1==1
reg response_6m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_6m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_6m ""
if (`pval_t2c_father_6m'<0.1) local star_t2c_father_6m "*"
if (`pval_t2c_father_6m'<0.05) local star_t2c_father_6m "**"
if (`pval_t2c_father_6m'<0.01) local star_t2c_father_6m "***"
restore

preserve
drop if T1==1
reg any_response T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_any = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_any ""
if (`pval_t2c_father_any'<0.1) local star_t2c_father_any "*"
if (`pval_t2c_father_any'<0.05) local star_t2c_father_any "**"
if (`pval_t2c_father_any'<0.01) local star_t2c_father_any "***"
restore

// Output LaTeX table for 1m, 2m, 3m, 6m
capture file close resultsfile
file open resultsfile using "$results/tables/response_across_wave.tex", write append

file write resultsfile "\begin{table}[htbp]" _n
file write resultsfile "\centering" _n
file write resultsfile "\caption{Raw Means with Significance (1m, 2m, 3m, 6m)}" _n
file write resultsfile "\begin{tabular}{lcccccc}" _n
file write resultsfile "\toprule" _n
file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write resultsfile "\textbf{Measure} & Control & T1 & T2 & Control & T1 & T2 \\" _n
file write resultsfile "\midrule" _n

file write resultsfile "1m Response & `mean_C_mother_1m' & `mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m' & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' \\" _n

file write resultsfile "2m Response & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m' & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' \\" _n

file write resultsfile "3m Response & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_t1c_mother_3m' & `mean_T2_mother_3m'`star_t2c_mother_3m' & `mean_C_father_3m' & `mean_T1_father_3m'`star_t1c_father_3m' & `mean_T2_father_3m'`star_t2c_father_3m' \\" _n

file write resultsfile "6m Response & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_t1c_mother_6m' & `mean_T2_mother_6m'`star_t2c_mother_6m' & `mean_C_father_6m' & `mean_T1_father_6m'`star_t1c_father_6m' & `mean_T2_father_6m'`star_t2c_father_6m' \\" _n

file write resultsfile "Any Response & `mean_C_mother_any' & `mean_T1_mother_any'`star_t1c_mother_any' & `mean_T2_mother_any'`star_t2c_mother_any' & `mean_C_father_any' & `mean_T1_father_any'`star_t1c_father_any' & `mean_T2_father_any'`star_t2c_father_any' \\" _n

file write resultsfile "N & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' & `N_C_father_1m' & `N_T1_father_1m' & `N_T2_father_1m' \\" _n

file write resultsfile "\bottomrule" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\small" _n
file write resultsfile "Notes: Stars indicate significance relative to the control group. " _n
file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write resultsfile "Residualized means control for strata and enumerator fixed effects." _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{table}" _n

file close resultsfile


log close
