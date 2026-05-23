** Attrition Analysis

** Haoyue Wu
** Updated on: 27 Dec, 2025


/*
This file outputs the very basic attrition table, with raw percentages of response rates, and significance across 
treatment (compared to control group) within parents.

Before running this file, you have to make sure:
    1. run "01_contact_list_append.do", to make sure your contact list is most updated
    2. run "01_data aggregation and clean.do" to prepare the survey data 
    3. go to folder "formal_study_recruitment" and run "01_generate_clusters.do", to make sure you have the most updated
        recruitment data, so that your strata and cluster are prepared.

How to use this file:
-> You need to keep the correct data by adjusting the *DATE* in the first section for each survey
*/


/* 
RESULTS: 
1. response_across_wave.tex
2. attrition_triple_p_cutoff.tex
3. attrition_2m_onsite_cutoff.tex
*/



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
// 1. REPORT THE ATTRITION TABLE FOR EACH WAVES OF SURVEY WITH Raw MEANS //
//********************************************************************************//
local m1_cutoff_date "2026-03-02"
local m2_cutoff_date "2026-03-02"
local m3_cutoff_date "2025-11-15"
local m6_cutoff_date "2025-08-15"
local m7_cutoff_date "2025-07-05"
local m10_cutoff_date "2025-04-12"

*###### TRIPLE P CUTOFF #######

local waves 1m 2m 3m 6m 7m 10m

foreach wave in `waves' {
    //*************** Data Preparation ***************//
    use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update, for triple p date cutoff
        if "`wave'" == "1m" {
            keep if date <= date("`m1_cutoff_date'", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0
             drop if date < date("2024-09-21", "YMD") */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("`m2_cutoff_date'", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0
             drop if date < date("2024-09-21", "YMD") */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("`m3_cutoff_date'", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0
            drop if date < date("2024-09-21", "YMD") */
        }
        else if "`wave'" == "6m" {
            keep if date <= date("`m6_cutoff_date'", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0
            drop if date < date("2024-09-21", "YMD") */
        }
         else if "`wave'" == "7m" {
            keep if date <= date("`m7_cutoff_date'", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 
            drop if date < date("2024-09-21", "YMD") */
        }
         else if "`wave'" == "10m" {
            keep if date <= date("`m10_cutoff_date'", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 
            drop if date < date("2024-09-21", "YMD") */
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
    drop if lastname == "姬灵"
    tempfile participants
    save `participants'

    if "`wave'" == "2m" {
        capture drop _merge
        merge 1:m firstname using "$proc/2m&6w_results.dta"
    }
    else if "`wave'" == "6m" {
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
    capture drop attribute_*

    save "$proc/attrition_`wave'.dta", replace

	
    *------------------------------------------------------------*
    *             Regression: Attrition means        *
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
            di `mean_`g'_father_`wave''
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
        

        // ---------- Only Mothers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su only_mother if `g'==1
            local mean_`g'_mo_`wave' : di %6.3f r(mean)
            local N_`g'_mo_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_mother T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_mo_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mo_`wave' ""
        if (`pval_t1c_mo_`wave''<0.1) local star_t1c_mo_`wave' "*"
        if (`pval_t1c_mo_`wave''<0.05) local star_t1c_mo_`wave' "**"
        if (`pval_t1c_mo_`wave''<0.01) local star_t1c_mo_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_mother T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_mo_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mo_`wave' ""
        if (`pval_t2c_mo_`wave''<0.1) local star_t2c_mo_`wave' "*"
        if (`pval_t2c_mo_`wave''<0.05) local star_t2c_mo_`wave' "**"
        if (`pval_t2c_mo_`wave''<0.01) local star_t2c_mo_`wave' "***"
        restore

        

        // ---------- Only Fathers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su only_father if `g'==1
            local mean_`g'_fa_`wave' : di %6.3f r(mean)
            local N_`g'_fa_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_father T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_fa_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_fa_`wave' ""
        if (`pval_t1c_fa_`wave''<0.1) local star_t1c_fa_`wave' "*"
        if (`pval_t1c_fa_`wave''<0.05) local star_t1c_fa_`wave' "**"
        if (`pval_t1c_fa_`wave''<0.01) local star_t1c_fa_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_father T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_fa_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_fa_`wave' ""
        if (`pval_t2c_fa_`wave''<0.1) local star_t2c_fa_`wave' "*"
        if (`pval_t2c_fa_`wave''<0.05) local star_t2c_fa_`wave' "**"
        if (`pval_t2c_fa_`wave''<0.01) local star_t2c_fa_`wave' "***"
        restore
        

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

        // ---------- Both parent ----------
        use "$proc/attrition_`wave'.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_both_`wave' if `g'==1
            local mean_`g'_both_`wave' : di %6.3f r(mean)
            local N_`g'_both_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_both_`wave' T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_both_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_both_`wave' ""
        if (`pval_t1c_both_`wave''<0.1) local star_t1c_both_`wave' "*"
        if (`pval_t1c_both_`wave''<0.05) local star_t1c_both_`wave' "**"
        if (`pval_t1c_both_`wave''<0.01) local star_t1c_both_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_both_`wave' T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_both_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_both_`wave' ""
        if (`pval_t2c_both_`wave''<0.1) local star_t2c_both_`wave' "*"
        if (`pval_t2c_both_`wave''<0.05) local star_t2c_both_`wave' "**"
        if (`pval_t2c_both_`wave''<0.01) local star_t2c_both_`wave' "***"
        restore


        
}
di `N_C_mother_6m' `N_T1_mother_6m' `N_T2_mother_6m'
// Output LaTeX tables for each wave and respondent type (mother, father, either)

capture file close latex
file open latex using "$results/tables/attrition_triple_p_cutoff.tex", write replace

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 1m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_1m' &`mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m' & 0.929 & 0.884** &  0.810***\\" _n
file write latex "Father & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' & 0.911 &  0.806*** &  0.765*** \\" _n
file write latex "Only Mother & `mean_C_mo_1m' &`mean_T1_mo_1m'`star_t1c_mo_1m' & `mean_T2_mo_1m'`star_t2c_mo_1m' &  0.066 & 0.139*** &  0.158***  \\" _n
file write latex "Only Father & `mean_C_fa_1m' & `mean_T1_fa_1m'`star_t1c_fa_1m' & `mean_T2_fa_1m'`star_t2c_fa_1m' &  0.047 &  0.063 &  0.112*** \\" _n
file write latex "Either & `mean_C_either_1m' & `mean_T1_either_1m'`star_t1c_either_1m' & `mean_T2_either_1m'`star_t2c_either_1m' &  0.976 &  0.946** &  0.922*** \\" _n
file write latex "Both & `mean_C_both_1m' & `mean_T1_both_1m'`star_t1c_both_1m' & `mean_T2_both_1m'`star_t2c_both_1m' & 0.863 &  0.744*** &  0.652*** \\" _n
file write latex "N(Family) & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' &  380 & 396 & 374 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 2m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m'  &  0.900 &  0.838** &  0.775*** \\" _n
file write latex "Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' &  0.905 &  0.756*** &  0.703*** \\" _n
file write latex "Only Mother & `mean_C_mo_2m' & `mean_T1_mo_2m'`star_t1c_mo_2m' & `mean_T2_mo_2m'`star_t2c_mo_2m'  & 0.058 &  0.169*** &  0.166***   \\" _n
file write latex "Only Father & `mean_C_fa_2m' & `mean_T1_fa_2m'`star_t1c_fa_2m' & `mean_T2_fa_2m'`star_t2c_fa_2m' & 0.063 &  0.088 &  0.094 \\" _n
file write latex "Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_t1c_either_2m' & `mean_T2_either_2m'`star_t2c_either_2m' &  0.963 &  0.926** &  0.869*** \\" _n
file write latex "Both & `mean_C_both_2m' & `mean_T1_both_2m'`star_t1c_both_2m' & `mean_T2_both_2m'`star_t2c_both_2m' &  0.842 &  0.668*** &  0.610*** \\" _n
file write latex "N(Family) & `N_C_mother_2m' & `N_T1_mother_2m' & `N_T2_mother_2m' & 380 & 396 & 374 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n



file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 3m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_t1c_mother_3m' & `mean_T2_mother_3m'`star_t2c_mother_3m' &  0.884 &  0.811*** &  0.786*** \\" _n
file write latex "Father & `mean_C_father_3m' & `mean_T1_father_3m'`star_t1c_father_3m' & `mean_T2_father_3m'`star_t2c_father_3m' &  0.908 &  0.738*** &  0.709*** \\" _n
file write latex "Only Mother & `mean_C_mo_3m' & `mean_T1_mo_3m'`star_t1c_mo_3m' & `mean_T2_mo_3m'`star_t2c_mo_3m' &   0.053 &  0.167*** &  0.166***  \\" _n
file write latex "Only Father & `mean_C_fa_3m' & `mean_T1_fa_3m'`star_t1c_fa_3m' & `mean_T2_fa_3m'`star_t2c_fa_3m' &   0.076 &  0.096 &  0.088  \\" _n
file write latex "Either & `mean_C_either_3m' & `mean_T1_either_3m'`star_t1c_either_3m' & `mean_T2_either_3m'`star_t2c_either_3m' &  0.961 &  0.905*** &  0.874*** \\" _n
file write latex "Both & `mean_C_both_3m' & `mean_T1_both_3m'`star_t1c_both_3m' & `mean_T2_both_3m'`star_t2c_both_3m' &  0.832 &  0.643*** &  0.620***  \\" _n
file write latex "N(Family) & `N_C_mother_3m' & `N_T1_mother_3m' & `N_T2_mother_3m'  & 380 & 396 & 374 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 6m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_t1c_mother_6m' & `mean_T2_mother_6m'`star_t2c_mother_6m' &   0.916 &  0.848*** &  0.869* \\" _n
file write latex "Father & `mean_C_father_6m' & `mean_T1_father_6m'`star_t1c_father_6m' & `mean_T2_father_6m'`star_t2c_father_6m' & 0.921 &  0.806*** &  0.810*** \\" _n
file write latex "Only Mother & `mean_C_mo_6m' & `mean_T1_mo_6m'`star_t1c_mo_6m' & `mean_T2_mo_6m'`star_t2c_mo_6m' & 0.050 &  0.124*** &  0.131***  \\" _n
file write latex "Only Father & `mean_C_fa_6m' & `mean_T1_fa_6m'`star_t1c_fa_6m' & `mean_T2_fa_6m'`star_t2c_fa_6m' & 0.055 &  0.083* &  0.072 \\" _n
file write latex "Either & `mean_C_either_6m' & `mean_T1_either_6m'`star_t1c_either_6m' & `mean_T2_either_6m'`star_t2c_either_6m' &  0.971 &  0.931** &  0.941*  \\" _n
file write latex "Both & `mean_C_both_6m' & `mean_T1_both_6m'`star_t1c_both_6m' & `mean_T2_both_6m'`star_t2c_both_6m' &  0.866 &  0.724*** &  0.738*** \\" _n
file write latex "N(Family) & `N_C_mother_6m' & `N_T1_mother_6m' & `N_T2_mother_6m'  & 380 & 396 & 374 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 7m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_7m' & `mean_T1_mother_7m'`star_t1c_mother_7m' & `mean_T2_mother_7m'`star_t2c_mother_7m' &   0.763 &  0.702* &  0.628*** \\" _n
file write latex "Father & `mean_C_father_7m' & `mean_T1_father_7m'`star_t1c_father_7m' & `mean_T2_father_7m'`star_t2c_father_7m' & 0.734 &  0.582*** &  0.594*** \\" _n
file write latex "Only Mother & `mean_C_mo_7m' & `mean_T1_mo_7m'`star_t1c_mo_7m' & `mean_T2_mo_7m'`star_t2c_mo_7m' & 0.155 &  0.227** &  0.206 \\" _n
file write latex "Only Father & `mean_C_fa_7m' & `mean_T1_fa_7m'`star_t1c_fa_7m' & `mean_T2_fa_7m'`star_t2c_fa_7m' &  0.126 &  0.108 &  0.171* \\" _n
file write latex "Either & `mean_C_either_7m' & `mean_T1_either_7m'`star_t1c_either_7m' & `mean_T2_either_7m'`star_t2c_either_7m' & 0.889 &  0.810*** &  0.799*** \\" _n
file write latex "Both & `mean_C_both_7m' & `mean_T1_both_7m'`star_t1c_both_7m' & `mean_T2_both_7m'`star_t2c_both_7m' & 0.608 &  0.474*** &  0.422** \\" _n
file write latex "N(Family) & `N_C_mother_7m' & `N_T1_mother_7m' & `N_T2_mother_7m'  & 380 & 396 & 374 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n

file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 10m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_10m' & `mean_T1_mother_10m'`star_t1c_mother_10m' & `mean_T2_mother_10m'`star_t2c_mother_10m' &  0.693 &  0.631** &  0.602**\\" _n
file write latex "Father & `mean_C_father_10m' & `mean_T1_father_10m'`star_t1c_father_10m' & `mean_T2_father_10m'`star_t2c_father_10m' &  0.635 &  0.534** &  0.529***\\" _n
file write latex "Only Mother & `mean_C_mo_10m' & `mean_T1_mo_10m'`star_t1c_mo_10m' & `mean_T2_mo_10m'`star_t2c_mo_10m' &  0.199 &  0.227 &  0.227  \\" _n
file write latex "Only Father & `mean_C_fa_10m' & `mean_T1_fa_10m'`star_t1c_fa_10m' & `mean_T2_fa_10m'`star_t2c_fa_10m' &  0.142 &  0.131 &  0.155 \\" _n
file write latex "Either & `mean_C_either_10m' & `mean_T1_either_10m'`star_t1c_either_10m' & `mean_T2_either_10m'`star_t2c_either_10m' & 0.835 &  0.762*** &  0.757** \\" _n
file write latex "Both & `mean_C_both_10m' & `mean_T1_both_10m'`star_t1c_both_10m' & `mean_T2_both_10m'`star_t2c_both_10m' &  0.493 &  0.404** &  0.374*** \\" _n
file write latex "N(Family) & `N_C_mother_10m' & `N_T1_mother_10m' & `N_T2_mother_10m'  & 380 & 396 & 374 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 10m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n




*###### 2M ONSITE CUTOFF #######

local waves 1m 2m 3m 6m 7m 10m

foreach wave in `waves' {
    //*************** Data Preparation ***************//
    use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update, for 2m onsite date cutoff
        if "`wave'" == "1m" {
            keep if date <= date("`m1_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
            /* keep if date < date("2025-02-07", "YMD")
            drop if date < date("2024-09-21", "YMD") */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("`m2_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
            /* keep if date < date("2025-02-07", "YMD") 
            drop if date < date("2024-09-21", "YMD") */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("`m3_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
            /* keep if date < date("2025-02-07", "YMD") 
            drop if date < date("2024-09-21", "YMD") */
        }
        else if "`wave'" == "6m" {
            keep if date <= date("`m6_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
            /* keep if date < date("2025-02-07", "YMD")
            drop if date < date("2024-09-21", "YMD") */
           
        }
        else if "`wave'" == "7m" {
            keep if date <= date("`m7_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
            /* keep if date < date("2025-02-07", "YMD")
            drop if date < date("2024-09-21", "YMD") */
           
        }
        else if "`wave'" == "10m" {
            keep if date <= date("`m10_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
            /* keep if date < date("2025-02-07", "YMD")
            drop if date < date("2024-09-21", "YMD") */
           
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
    drop if lastname == "姬灵"
    tempfile participants
    save `participants'

    if "`wave'" == "2m" {
        capture drop _merge
        merge 1:m firstname using "$proc/2m&6w_results.dta"
    }
    else if "`wave'" == "6m" {
        capture drop _merge
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
    capture drop attribute_*

    save "$proc/attrition_`wave'.dta", replace

    *------------------------------------------------------------*
    *             Regression: Attrition means        *
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
            di `mean_`g'_father_`wave''
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
        

        // ---------- Only Mothers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su only_mother if `g'==1
            local mean_`g'_mo_`wave' : di %6.3f r(mean)
            local N_`g'_mo_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_mother T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_mo_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mo_`wave' ""
        if (`pval_t1c_mo_`wave''<0.1) local star_t1c_mo_`wave' "*"
        if (`pval_t1c_mo_`wave''<0.05) local star_t1c_mo_`wave' "**"
        if (`pval_t1c_mo_`wave''<0.01) local star_t1c_mo_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_mother T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_mo_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mo_`wave' ""
        if (`pval_t2c_mo_`wave''<0.1) local star_t2c_mo_`wave' "*"
        if (`pval_t2c_mo_`wave''<0.05) local star_t2c_mo_`wave' "**"
        if (`pval_t2c_mo_`wave''<0.01) local star_t2c_mo_`wave' "***"
        restore

        

        // ---------- Only Fathers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su only_father if `g'==1
            local mean_`g'_fa_`wave' : di %6.3f r(mean)
            local N_`g'_fa_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_father T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_fa_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_fa_`wave' ""
        if (`pval_t1c_fa_`wave''<0.1) local star_t1c_fa_`wave' "*"
        if (`pval_t1c_fa_`wave''<0.05) local star_t1c_fa_`wave' "**"
        if (`pval_t1c_fa_`wave''<0.01) local star_t1c_fa_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_father T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_fa_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_fa_`wave' ""
        if (`pval_t2c_fa_`wave''<0.1) local star_t2c_fa_`wave' "*"
        if (`pval_t2c_fa_`wave''<0.05) local star_t2c_fa_`wave' "**"
        if (`pval_t2c_fa_`wave''<0.01) local star_t2c_fa_`wave' "***"
        restore
        

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

        // ---------- Both parent ----------
        use "$proc/attrition_`wave'.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_both_`wave' if `g'==1
            local mean_`g'_both_`wave' : di %6.3f r(mean)
            local N_`g'_both_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_both_`wave' T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_both_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_both_`wave' ""
        if (`pval_t1c_both_`wave''<0.1) local star_t1c_both_`wave' "*"
        if (`pval_t1c_both_`wave''<0.05) local star_t1c_both_`wave' "**"
        if (`pval_t1c_both_`wave''<0.01) local star_t1c_both_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_both_`wave' T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_both_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_both_`wave' ""
        if (`pval_t2c_both_`wave''<0.1) local star_t2c_both_`wave' "*"
        if (`pval_t2c_both_`wave''<0.05) local star_t2c_both_`wave' "**"
        if (`pval_t2c_both_`wave''<0.01) local star_t2c_both_`wave' "***"
        restore


        
}
di `N_C_mother_6m' `N_T1_mother_6m' `N_T2_mother_6m'
// Output LaTeX tables for each wave and respondent type (mother, father, either)

capture file close latex
file open latex using "$results/tables/attrition_2m_onsite_cutoff.tex", write replace

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 1m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_1m' &`mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m' & 0.928 & 0.885** &  0.819***  \\" _n
file write latex "Father & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' & 0.913 &  0.802*** &  0.770***  \\" _n
file write latex "Only Mother & `mean_C_mo_1m' &`mean_T1_mo_1m'`star_t1c_mo_1m' & `mean_T2_mo_1m'`star_t2c_mo_1m' &  0.065 & 0.141*** &  0.156*** \\" _n
file write latex "Only Father & `mean_C_fa_1m' & `mean_T1_fa_1m'`star_t1c_fa_1m' & `mean_T2_fa_1m'`star_t2c_fa_1m' &  0.050 &  0.060 &  0.107*** \\" _n
file write latex "Either & `mean_C_either_1m' & `mean_T1_either_1m'`star_t1c_either_1m' & `mean_T2_either_1m'`star_t2c_either_1m' &  0.978 &  0.944** &  0.926*** \\" _n
file write latex "Both & `mean_C_both_1m' & `mean_T1_both_1m'`star_t1c_both_1m' & `mean_T2_both_1m'`star_t2c_both_1m' & 0.863 &  0.743*** &  0.663*** \\" _n
file write latex "N(Family) & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' & 402 & 418 & 392 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 2m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m'  & 0.900 &  0.835*** &  0.783***   \\" _n
file write latex "Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' &   0.908 &  0.752*** &  0.712*** \\" _n
file write latex "Only Mother & `mean_C_mo_2m' & `mean_T1_mo_2m'`star_t1c_mo_2m' & `mean_T2_mo_2m'`star_t2c_mo_2m'  &  0.057 &  0.170*** &  0.163***   \\" _n
file write latex "Only Father & `mean_C_fa_2m' & `mean_T1_fa_2m'`star_t1c_fa_2m' & `mean_T2_fa_2m'`star_t2c_fa_2m' & 0.065 &  0.088 &  0.092 \\" _n
file write latex "Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_t1c_either_2m' & `mean_T2_either_2m'`star_t2c_either_2m' &  0.965 &  0.922*** &  0.875*** \\" _n
file write latex "Both & `mean_C_both_2m' & `mean_T1_both_2m'`star_t1c_both_2m' & `mean_T2_both_2m'`star_t2c_both_2m' & 0.843 &  0.664*** &  0.620*** \\" _n
file write latex "N(Family) & `N_C_mother_2m' & `N_T1_mother_2m' & `N_T2_mother_2m' & 402 & 418 & 392  \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n



file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 3m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_t1c_mother_3m' & `mean_T2_mother_3m'`star_t2c_mother_3m' &  0.888 &  0.809*** &  0.793*** \\" _n
file write latex "Father & `mean_C_father_3m' & `mean_T1_father_3m'`star_t1c_father_3m' & `mean_T2_father_3m'`star_t2c_father_3m' & 0.908 &  0.735*** &  0.717*** \\" _n
file write latex "Only Mother & `mean_C_mo_3m' & `mean_T1_mo_3m'`star_t1c_mo_3m' & `mean_T2_mo_3m'`star_t2c_mo_3m' & 0.055 &  0.165*** &  0.163*** \\" _n
file write latex "Only Father & `mean_C_fa_3m' & `mean_T1_fa_3m'`star_t1c_fa_3m' & `mean_T2_fa_3m'`star_t2c_fa_3m' &  0.075 &  0.093 &  0.087 \\" _n
file write latex "Either & `mean_C_either_3m' & `mean_T1_either_3m'`star_t1c_either_3m' & `mean_T2_either_3m'`star_t2c_either_3m' & 0.963 &  0.901*** &  0.880*** \\" _n
file write latex "Both & `mean_C_both_3m' & `mean_T1_both_3m'`star_t1c_both_3m' & `mean_T2_both_3m'`star_t2c_both_3m' &  0.833 &  0.643*** &  0.630***  \\" _n
file write latex "N(Family) & `N_C_mother_3m' & `N_T1_mother_3m' & `N_T2_mother_3m'  & 402 & 418 & 392 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 6m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_t1c_mother_6m' & `mean_T2_mother_6m'`star_t2c_mother_6m' &  0.918 &  0.847*** &  0.872* \\" _n
file write latex "Father & `mean_C_father_6m' & `mean_T1_father_6m'`star_t1c_father_6m' & `mean_T2_father_6m'`star_t2c_father_6m' & 0.920 &  0.795*** &  0.811*** \\" _n
file write latex "Only Mother & `mean_C_mo_6m' & `mean_T1_mo_6m'`star_t1c_mo_6m' & `mean_T2_mo_6m'`star_t2c_mo_6m' &  0.052 &  0.129*** &  0.130*** \\" _n
file write latex "Only Father & `mean_C_fa_6m' & `mean_T1_fa_6m'`star_t1c_fa_6m' & `mean_T2_fa_6m'`star_t2c_fa_6m' &  0.055 &  0.079* &  0.069 \\" _n
file write latex "Either & `mean_C_either_6m' & `mean_T1_either_6m'`star_t1c_either_6m' & `mean_T2_either_6m'`star_t2c_either_6m' & 0.973 &  0.925*** &  0.941** \\" _n
file write latex "Both & `mean_C_both_6m' & `mean_T1_both_6m'`star_t1c_both_6m' & `mean_T2_both_6m'`star_t2c_both_6m' &  0.866 &  0.717*** &  0.742***  \\" _n
file write latex "N(Family) & `N_C_mother_6m' & `N_T1_mother_6m' & `N_T2_mother_6m'  &  402 & 418 & 392   \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n




file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 7m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_7m' & `mean_T1_mother_7m'`star_t1c_mother_7m' & `mean_T2_mother_7m'`star_t2c_mother_7m' &   0.818 &  0.770* &  0.722*** \\" _n
file write latex "Father & `mean_C_father_7m' & `mean_T1_father_7m'`star_t1c_father_7m' & `mean_T2_father_7m'`star_t2c_father_7m' & 0.818 &  0.635*** &  0.648***  \\" _n
file write latex "Only Mother & `mean_C_mo_7m' & `mean_T1_mo_7m'`star_t1c_mo_7m' & `mean_T2_mo_7m'`star_t2c_mo_7m' &   0.107 &  0.218*** &  0.204***  \\" _n
file write latex "Only Father & `mean_C_fa_7m' & `mean_T1_fa_7m'`star_t1c_fa_7m' & `mean_T2_fa_7m'`star_t2c_fa_7m' &   0.107 &  0.084 &  0.130  \\" _n
file write latex "Either & `mean_C_either_7m' & `mean_T1_either_7m'`star_t1c_either_7m' & `mean_T2_either_7m'`star_t2c_either_7m' &  0.925 &  0.853*** &  0.852*** \\" _n
file write latex "Both & `mean_C_both_7m' & `mean_T1_both_7m'`star_t1c_both_7m' & `mean_T2_both_7m'`star_t2c_both_7m' & 0.711 &  0.552*** &  0.518*** \\" _n
file write latex "N(Family) & `N_C_mother_7m' & `N_T1_mother_7m' & `N_T2_mother_7m'  &  402 & 418 & 392   \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n



file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 10m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mean_C_mother_10m' & `mean_T1_mother_10m'`star_t1c_mother_10m' & `mean_T2_mother_10m'`star_t2c_mother_10m' &   0.700 &  0.627** &  0.607** \\" _n
file write latex "Father & `mean_C_father_10m' & `mean_T1_father_10m'`star_t1c_father_10m' & `mean_T2_father_10m'`star_t2c_father_10m' & 0.638 &  0.525*** &  0.536***  \\" _n
file write latex "Only Mother & `mean_C_mo_10m' & `mean_T1_mo_10m'`star_t1c_mo_10m' & `mean_T2_mo_10m'`star_t2c_mo_10m' &   0.201 &  0.225 &  0.222 \\" _n
file write latex "Only Father & `mean_C_fa_10m' & `mean_T1_fa_10m'`star_t1c_fa_10m' & `mean_T2_fa_10m'`star_t2c_fa_10m' &   0.139 &  0.124 &  0.151 \\" _n
file write latex "Either & `mean_C_either_10m' & `mean_T1_either_10m'`star_t1c_either_10m' & `mean_T2_either_10m'`star_t2c_either_10m' &  0.839 &  0.750*** &  0.758**\\" _n
file write latex "Both & `mean_C_both_10m' & `mean_T1_both_10m'`star_t1c_both_10m' & `mean_T2_both_10m'`star_t2c_both_10m' & 0.499 &  0.401** &  0.385*** \\" _n
file write latex "N(Family) & `N_C_mother_10m' & `N_T1_mother_10m' & `N_T2_mother_10m'  &  402 & 418 & 392   \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - 10m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

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

keep if date <= date("`m2_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
/* drop if date > date("`m2_cutoff_date'", "YMD")  */
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
capture drop attribute_*

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

keep if date <= date("`m3_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
/* drop if date > date("`m3_cutoff_date'", "YMD") */
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
capture drop attribute_*

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

keep if date <= date("`m6_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
/* drop if date > date("`m6_cutoff_date'", "YMD") */
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
capture drop attribute_*

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




*-----------------------------------------------------------------*
*                        1m & 2m & 3m & 6m & 7m                       *
*-----------------------------------------------------------------*
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

keep if date <= date("`m7_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
/* drop if date > date("`m7_cutoff_date'", "YMD") */
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


use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/7m_results.dta"
drop if _merge == 2
gen response_7m = (_merge == 3)
drop _merge
drop if firstname == ""

tempfile 7m
save `7m'

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

merge 1:1 firstname using `7m', force
drop if _merge == 1
drop _merge

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

// fix errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"

gen any_response = (response_1m == 1 | response_2m == 1 | response_3m == 1 | response_6m == 1 | response_7m == 1)

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
capture drop attribute_*

duplicates drop firstname, force

save "$proc/attrition_1m_2m_3m_6m_7m.dta", replace

*------------------------------------------------------------*
*             Regression: residualize attrition means        *
*------------------------------------------------------------*
// ---------- Mothers ----------
use "$proc/attrition_1m_2m_3m_6m_7m.dta", clear
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
    su response_7m if `g'==1
    local mean_`g'_mother_7m : di %6.3f r(mean)
    local N_`g'_mother_7m = r(N)
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
reg response_7m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_7m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_7m ""
if (`pval_t1c_mother_7m'<0.1) local star_t1c_mother_7m "*"
if (`pval_t1c_mother_7m'<0.05) local star_t1c_mother_7m "**"
if (`pval_t1c_mother_7m'<0.01) local star_t1c_mother_7m "***"
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
reg response_7m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_7m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_7m ""
if (`pval_t2c_mother_7m'<0.1) local star_t2c_mother_7m "*"
if (`pval_t2c_mother_7m'<0.05) local star_t2c_mother_7m "**"
if (`pval_t2c_mother_7m'<0.01) local star_t2c_mother_7m "***"
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
use "$proc/attrition_1m_2m_3m_6m_7m.dta", clear
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
    su response_7m if `g'==1
    local mean_`g'_father_7m : di %6.3f r(mean)
    local N_`g'_father_7m = r(N)
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
reg response_7m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_7m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_7m ""
if (`pval_t1c_father_7m'<0.1) local star_t1c_father_7m "*"
if (`pval_t1c_father_7m'<0.05) local star_t1c_father_7m "**"
if (`pval_t1c_father_7m'<0.01) local star_t1c_father_7m "***"
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
reg response_7m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_7m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_7m ""
if (`pval_t2c_father_7m'<0.1) local star_t2c_father_7m "*"
if (`pval_t2c_father_7m'<0.05) local star_t2c_father_7m "**"
if (`pval_t2c_father_7m'<0.01) local star_t2c_father_7m "***"
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
file write resultsfile "\caption{Raw Means with Significance (1m, 2m, 3m, 6m, 7m)}" _n
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
file write resultsfile "7m Response & `mean_C_mother_7m' & `mean_T1_mother_7m'`star_t1c_mother_7m' & `mean_T2_mother_7m'`star_t2c_mother_7m' & `mean_C_father_7m' & `mean_T1_father_7m'`star_t1c_father_7m' & `mean_T2_father_7m'`star_t2c_father_7m' \\" _n
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
*                        1m & 2m & 3m & 6m & 7m & 10m                       *
*-----------------------------------------------------------------*
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

keep if date <= date("`m10_cutoff_date'", "YMD") & (date >= date("2025-02-07", "YMD"))
/* drop if date > date("`m10_cutoff_date'", "YMD") */
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


use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/7m_results.dta"
drop if _merge == 2
gen response_7m = (_merge == 3)
drop _merge
drop if firstname == ""

tempfile 7m
save `7m'

use `participants', clear
duplicates drop firstname, force
merge 1:m firstname using "$proc/10m_results.dta"
drop if _merge == 2
gen response_10m = (_merge == 3)
drop _merge
drop if firstname == ""

tempfile 10m
save `10m'

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

merge 1:1 firstname using `7m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `10m', force
drop if _merge == 1
drop _merge

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

// fix errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"

gen any_response = (response_1m == 1 | response_2m == 1 | response_3m == 1 | response_6m == 1 | response_7m == 1 | response_10m == 1)

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
capture drop attribute_*

duplicates drop firstname, force

save "$proc/attrition_1m_2m_3m_6m_7m_10m.dta", replace

*------------------------------------------------------------*
*             Regression: residualize attrition means        *
*------------------------------------------------------------*
// ---------- Mothers ----------
use "$proc/attrition_1m_2m_3m_6m_7m_10m.dta", clear
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
    su response_7m if `g'==1
    local mean_`g'_mother_7m : di %6.3f r(mean)
    local N_`g'_mother_7m = r(N)
    su response_10m if `g'==1
    local mean_`g'_mother_10m : di %6.3f r(mean)
    local N_`g'_mother_10m = r(N)
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
reg response_7m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_7m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_7m ""
if (`pval_t1c_mother_7m'<0.1) local star_t1c_mother_7m "*"
if (`pval_t1c_mother_7m'<0.05) local star_t1c_mother_7m "**"
if (`pval_t1c_mother_7m'<0.01) local star_t1c_mother_7m "***"
restore

preserve
drop if T2==1
reg response_10m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_10m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_10m ""
if (`pval_t1c_mother_10m'<0.1) local star_t1c_mother_10m "*"
if (`pval_t1c_mother_10m'<0.05) local star_t1c_mother_10m "**"
if (`pval_t1c_mother_10m'<0.01) local star_t1c_mother_10m "***"
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
reg response_7m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_7m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_7m ""
if (`pval_t2c_mother_7m'<0.1) local star_t2c_mother_7m "*"
if (`pval_t2c_mother_7m'<0.05) local star_t2c_mother_7m "**"
if (`pval_t2c_mother_7m'<0.01) local star_t2c_mother_7m "***"
restore

preserve
drop if T1==1
reg response_10m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_10m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_10m ""
if (`pval_t2c_mother_10m'<0.1) local star_t2c_mother_10m "*"
if (`pval_t2c_mother_10m'<0.05) local star_t2c_mother_10m "**"
if (`pval_t2c_mother_10m'<0.01) local star_t2c_mother_10m "***"
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
use "$proc/attrition_1m_2m_3m_6m_7m_10m.dta", clear
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
    su response_7m if `g'==1
    local mean_`g'_father_7m : di %6.3f r(mean)
    local N_`g'_father_7m = r(N)
    su response_10m if `g'==1
    local mean_`g'_father_10m : di %6.3f r(mean)
    local N_`g'_father_10m = r(N)
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
reg response_7m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_7m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_7m ""
if (`pval_t1c_father_7m'<0.1) local star_t1c_father_7m "*"
if (`pval_t1c_father_7m'<0.05) local star_t1c_father_7m "**"
if (`pval_t1c_father_7m'<0.01) local star_t1c_father_7m "***"
restore

preserve
drop if T2==1
reg response_10m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_10m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_10m ""
if (`pval_t1c_father_10m'<0.1) local star_t1c_father_10m "*"
if (`pval_t1c_father_10m'<0.05) local star_t1c_father_10m "**"
if (`pval_t1c_father_10m'<0.01) local star_t1c_father_10m "***"
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
reg response_7m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_7m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_7m ""
if (`pval_t2c_father_7m'<0.1) local star_t2c_father_7m "*"
if (`pval_t2c_father_7m'<0.05) local star_t2c_father_7m "**"
if (`pval_t2c_father_7m'<0.01) local star_t2c_father_7m "***"
restore

preserve
drop if T1==1
reg response_10m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_10m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_10m ""
if (`pval_t2c_father_10m'<0.1) local star_t2c_father_10m "*"
if (`pval_t2c_father_10m'<0.05) local star_t2c_father_10m "**"
if (`pval_t2c_father_10m'<0.01) local star_t2c_father_10m "***"
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
file write resultsfile "\caption{Raw Means with Significance (1m, 2m, 3m, 6m, 7m, 10m)}" _n
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
file write resultsfile "7m Response & `mean_C_mother_7m' & `mean_T1_mother_7m'`star_t1c_mother_7m' & `mean_T2_mother_7m'`star_t2c_mother_7m' & `mean_C_father_7m' & `mean_T1_father_7m'`star_t1c_father_7m' & `mean_T2_father_7m'`star_t2c_father_7m' \\" _n

file write resultsfile "10m Response & `mean_C_mother_10m' & `mean_T1_mother_10m'`star_t1c_mother_10m' & `mean_T2_mother_10m'`star_t2c_mother_10m' & `mean_C_father_10m' & `mean_T1_father_10m'`star_t1c_father_10m' & `mean_T2_father_10m'`star_t2c_father_10m' \\" _n

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
