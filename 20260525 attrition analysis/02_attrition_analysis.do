** Attrition Analysis

** Zikang Zhang
** Updated on: 05 May, 2026


/*
This file outputs the very basic attrition table, with raw percentages of response rates, and significance across 
treatment (compared to control group) within parents.

Before running this file, you have to make sure:
        go to folder "formal_study_recruitment" and run "01_generate_clusters.do", to make sure you have the most updated
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
local m1_cutoff_date "2026-03-01"
local m2_cutoff_date "2026-03-01"
local m3_cutoff_date "2026-03-01"
local m6_cutoff_date "2025-10-01"
local m7_cutoff_date "2025-09-01"
local m10_cutoff_date "2025-06-01"


/*
*###### TRIPLE P CUTOFF #######

local waves 1m 2m 3m 6m 7m 10m

foreach period in after before {
foreach wave in `waves' {
    //*************** Data Preparation ***************//
    use "$data/id_mapping_confidential.dta", clear

    gen 日期_clean = strtrim(日期)
    gen date = .
    replace date = daily(日期_clean, "MDY") if strpos(日期_clean, "/") > 0
    replace date = daily(日期_clean, "DMY") if missing(date)

    gen 日期_cn = ""
    replace 日期_cn = ustrregexs(1) + "-" + ustrregexs(2) + "-" + ustrregexs(3) ///
        if ustrregexm(日期_clean, "([0-9]{4})年([0-9]{1,2})月([0-9]{1,2})日")
    replace date = daily(日期_cn, "YMD") if missing(date) & 日期_cn != ""
    format date %td

    destring group, replace
    recast float group

    local cutoff_date ""
    if "`wave'" == "1m" local cutoff_date "`m1_cutoff_date'"
    else if "`wave'" == "2m" local cutoff_date "`m2_cutoff_date'"
    else if "`wave'" == "3m" local cutoff_date "`m3_cutoff_date'"
    else if "`wave'" == "6m" local cutoff_date "`m6_cutoff_date'"
    else if "`wave'" == "7m" local cutoff_date "`m7_cutoff_date'"
    else if "`wave'" == "10m" local cutoff_date "`m10_cutoff_date'"

    if "`period'" == "after" {
        keep if date <= date("`cutoff_date'", "YMD") & ///
            (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
    }
    else if "`period'" == "before" {
        keep if date <= date("`cutoff_date'", "YMD") & ///
            date < date("2025-01-21", "YMD") & ///
            strpos(备注, "tp课程干预简化Ava测试") == 0
        drop if date < date("2024-09-21", "YMD")
    }

    gen treatment = "C" if group == 1
    replace treatment = "T1" if group == 2
    replace treatment = "T2" if group == 3

    tempfile complete
    save `complete'

	
    keep if mother == 1
    gen parent = "M"
    tempfile mother
    save `mother'

    use `complete'
    keep if mother == 0
    gen parent = "F"
    tempfile father
    save `father'
	

    append using `mother'
    drop if family_id == "f2ddbf38"
    tempfile participants
    save `participants'

    if "`wave'" == "2m" {
        capture drop _merge
        merge 1:m family_id mother using "$data/2m_20260507.dta"
    }
    else if "`wave'" == "6m" {
        capture drop _merge
        drop if family_id == "f2ddbf38"
        merge 1:m family_id mother using "$data/6m_20260507.dta"
    }
    else {
        capture drop _merge
        merge 1:m family_id mother using "$data/`wave'_20260507.dta"
    }

    drop if _merge == 2
    gen response_`wave' = (_merge == 3)
    drop _merge
    drop if missing(family_id)

    merge m:1 family_id using "$data/anonymized_cluster_mapping.dta"
    keep if _merge == 3
    drop _merge

    capture confirm numeric variable strata
    if _rc {
        encode strata, gen(strata_num)
    }
    else {
        gen strata_num = strata
    }

    capture confirm numeric variable enumerator_id
    if _rc {
        encode enumerator_id, gen(enumerator_num)
    }
    else {
        gen enumerator_num = enumerator_id
    }

    capture confirm numeric variable cluster_var
    if _rc {
        encode cluster_var, gen(cluster_num)
    }
    else {
        gen cluster_num = cluster_var
    }
	

    capture drop submit_dt
    gen double submit_dt = clock(submitdate, "YMDhms")
    format submit_dt %tc
	
	capture drop has_submit

    gen has_submit = !missing(submit_dt)

    gsort family_id mother -has_submit -submit_dt
    by family_id mother: keep if _n == 1

    bys family_id (mother): gen only_mother = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 0)
    bys family_id (mother): gen only_father = (response_`wave'[_N] == 0 & response_`wave'[_N-1] == 1)
    bysort family_id (response_`wave'): gen response_either_`wave' = response_`wave'[_N]
    bys family_id : gen response_both_`wave' = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 1)

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")


	capture drop attribute_*

    save "$proc/attrition_`wave'_`period'.dta", replace

	
    *------------------------------------------------------------*
    *             Regression: Attrition means        *
    *------------------------------------------------------------*
            // ---------- Mothers ----------
        use "$proc/attrition_`wave'_`period'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su response_`wave' if `g'==1
            local mean_`g'_mother_`wave'_`period' : di %6.3f r(mean)
            local N_`g'_mother_`wave'_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t1c_mother_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mother_`wave'_`period' ""
        if (`pval_t1c_mother_`wave'_`period''<0.1) local star_t1c_mother_`wave'_`period' "*"
        if (`pval_t1c_mother_`wave'_`period''<0.05) local star_t1c_mother_`wave'_`period' "**"
        if (`pval_t1c_mother_`wave'_`period''<0.01) local star_t1c_mother_`wave'_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t2c_mother_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mother_`wave'_`period' ""
        if (`pval_t2c_mother_`wave'_`period''<0.1) local star_t2c_mother_`wave'_`period' "*"
        if (`pval_t2c_mother_`wave'_`period''<0.05) local star_t2c_mother_`wave'_`period' "**"
        if (`pval_t2c_mother_`wave'_`period''<0.01) local star_t2c_mother_`wave'_`period' "***"
        restore

        // Chi2 test
        tab response_`wave' group, chi2
        local pval_chi2_mother_`wave'_`period' : di %6.3f r(p)
        

        // ---------- Fathers ----------
        use "$proc/attrition_`wave'_`period'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su response_`wave' if `g'==1
            local mean_`g'_father_`wave'_`period' : di %6.3f r(mean)
            local N_`g'_father_`wave'_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t1c_father_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_father_`wave'_`period' ""
        if (`pval_t1c_father_`wave'_`period''<0.1) local star_t1c_father_`wave'_`period' "*"
        if (`pval_t1c_father_`wave'_`period''<0.05) local star_t1c_father_`wave'_`period' "**"
        if (`pval_t1c_father_`wave'_`period''<0.01) local star_t1c_father_`wave'_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t2c_father_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_father_`wave'_`period' ""
        if (`pval_t2c_father_`wave'_`period''<0.1) local star_t2c_father_`wave'_`period' "*"
        if (`pval_t2c_father_`wave'_`period''<0.05) local star_t2c_father_`wave'_`period' "**"
        if (`pval_t2c_father_`wave'_`period''<0.01) local star_t2c_father_`wave'_`period' "***"
        restore

        // Chi2 test
        tab response_`wave' group, chi2
        local pval_chi2_father_`wave'_`period' : di %6.3f r(p)
        

        // ---------- Only Mothers ----------
        use "$proc/attrition_`wave'_`period'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su only_mother if `g'==1
            local mean_`g'_mo_`wave'_`period' : di %6.3f r(mean)
            local N_`g'_mo_`wave'_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_mother T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t1c_mo_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mo_`wave'_`period' ""
        if (`pval_t1c_mo_`wave'_`period''<0.1) local star_t1c_mo_`wave'_`period' "*"
        if (`pval_t1c_mo_`wave'_`period''<0.05) local star_t1c_mo_`wave'_`period' "**"
        if (`pval_t1c_mo_`wave'_`period''<0.01) local star_t1c_mo_`wave'_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_mother T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t2c_mo_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mo_`wave'_`period' ""
        if (`pval_t2c_mo_`wave'_`period''<0.1) local star_t2c_mo_`wave'_`period' "*"
        if (`pval_t2c_mo_`wave'_`period''<0.05) local star_t2c_mo_`wave'_`period' "**"
        if (`pval_t2c_mo_`wave'_`period''<0.01) local star_t2c_mo_`wave'_`period' "***"
        restore

        

        // ---------- Only Fathers ----------
        use "$proc/attrition_`wave'_`period'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su only_father if `g'==1
            local mean_`g'_fa_`wave'_`period' : di %6.3f r(mean)
            local N_`g'_fa_`wave'_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_father T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t1c_fa_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_fa_`wave'_`period' ""
        if (`pval_t1c_fa_`wave'_`period''<0.1) local star_t1c_fa_`wave'_`period' "*"
        if (`pval_t1c_fa_`wave'_`period''<0.05) local star_t1c_fa_`wave'_`period' "**"
        if (`pval_t1c_fa_`wave'_`period''<0.01) local star_t1c_fa_`wave'_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_father T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t2c_fa_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_fa_`wave'_`period' ""
        if (`pval_t2c_fa_`wave'_`period''<0.1) local star_t2c_fa_`wave'_`period' "*"
        if (`pval_t2c_fa_`wave'_`period''<0.05) local star_t2c_fa_`wave'_`period' "**"
        if (`pval_t2c_fa_`wave'_`period''<0.01) local star_t2c_fa_`wave'_`period' "***"
        restore
        

        // ---------- Either parent ----------
        use "$proc/attrition_`wave'_`period'.dta", clear
        bysort family_id: keep if _n == 1
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_either_`wave' if `g'==1
            local mean_`g'_either_`wave'_`period' : di %6.3f r(mean)
            local N_`g'_either_`wave'_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_either_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t1c_either_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_either_`wave'_`period' ""
        if (`pval_t1c_either_`wave'_`period''<0.1) local star_t1c_either_`wave'_`period' "*"
        if (`pval_t1c_either_`wave'_`period''<0.05) local star_t1c_either_`wave'_`period' "**"
        if (`pval_t1c_either_`wave'_`period''<0.01) local star_t1c_either_`wave'_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_either_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t2c_either_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_either_`wave'_`period' ""
        if (`pval_t2c_either_`wave'_`period''<0.1) local star_t2c_either_`wave'_`period' "*"
        if (`pval_t2c_either_`wave'_`period''<0.05) local star_t2c_either_`wave'_`period' "**"
        if (`pval_t2c_either_`wave'_`period''<0.01) local star_t2c_either_`wave'_`period' "***"
        restore

        // ---------- Both parent ----------
        use "$proc/attrition_`wave'_`period'.dta", clear
        bysort family_id: keep if _n == 1
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_both_`wave' if `g'==1
            local mean_`g'_both_`wave'_`period' : di %6.3f r(mean)
            local N_`g'_both_`wave'_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_both_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t1c_both_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_both_`wave'_`period' ""
        if (`pval_t1c_both_`wave'_`period''<0.1) local star_t1c_both_`wave'_`period' "*"
        if (`pval_t1c_both_`wave'_`period''<0.05) local star_t1c_both_`wave'_`period' "**"
        if (`pval_t1c_both_`wave'_`period''<0.01) local star_t1c_both_`wave'_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_both_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local pval_t2c_both_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_both_`wave'_`period' ""
        if (`pval_t2c_both_`wave'_`period''<0.1) local star_t2c_both_`wave'_`period' "*"
        if (`pval_t2c_both_`wave'_`period''<0.05) local star_t2c_both_`wave'_`period' "**"
        if (`pval_t2c_both_`wave'_`period''<0.01) local star_t2c_both_`wave'_`period' "***"
        restore


        
}
}

capture file close latex
file open latex using "$results/tables/attrition_triple_p_cutoff.tex", write replace

foreach wave in `waves' {
    file write latex "\begin{table}[H]" _n
    file write latex "\centering" _n
    file write latex "\caption{Raw Means with Significance  - `wave' Survey}" _n
    file write latex "\begin{fittable}" _n
    file write latex "\begin{tabular}{lcccccc}" _n
    file write latex "\toprule" _n
    file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
    file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
    file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
    file write latex "\midrule" _n

    file write latex "Mother & `mean_C_mother_`wave'_after' & `mean_T1_mother_`wave'_after'`star_t1c_mother_`wave'_after' & `mean_T2_mother_`wave'_after'`star_t2c_mother_`wave'_after' & `mean_C_mother_`wave'_before' & `mean_T1_mother_`wave'_before'`star_t1c_mother_`wave'_before' & `mean_T2_mother_`wave'_before'`star_t2c_mother_`wave'_before' \\" _n
    file write latex "Father & `mean_C_father_`wave'_after' & `mean_T1_father_`wave'_after'`star_t1c_father_`wave'_after' & `mean_T2_father_`wave'_after'`star_t2c_father_`wave'_after' & `mean_C_father_`wave'_before' & `mean_T1_father_`wave'_before'`star_t1c_father_`wave'_before' & `mean_T2_father_`wave'_before'`star_t2c_father_`wave'_before' \\" _n
    file write latex "Only Mother & `mean_C_mo_`wave'_after' & `mean_T1_mo_`wave'_after'`star_t1c_mo_`wave'_after' & `mean_T2_mo_`wave'_after'`star_t2c_mo_`wave'_after' & `mean_C_mo_`wave'_before' & `mean_T1_mo_`wave'_before'`star_t1c_mo_`wave'_before' & `mean_T2_mo_`wave'_before'`star_t2c_mo_`wave'_before' \\" _n
    file write latex "Only Father & `mean_C_fa_`wave'_after' & `mean_T1_fa_`wave'_after'`star_t1c_fa_`wave'_after' & `mean_T2_fa_`wave'_after'`star_t2c_fa_`wave'_after' & `mean_C_fa_`wave'_before' & `mean_T1_fa_`wave'_before'`star_t1c_fa_`wave'_before' & `mean_T2_fa_`wave'_before'`star_t2c_fa_`wave'_before' \\" _n
    file write latex "Either & `mean_C_either_`wave'_after' & `mean_T1_either_`wave'_after'`star_t1c_either_`wave'_after' & `mean_T2_either_`wave'_after'`star_t2c_either_`wave'_after' & `mean_C_either_`wave'_before' & `mean_T1_either_`wave'_before'`star_t1c_either_`wave'_before' & `mean_T2_either_`wave'_before'`star_t2c_either_`wave'_before' \\" _n
    file write latex "Both & `mean_C_both_`wave'_after' & `mean_T1_both_`wave'_after'`star_t1c_both_`wave'_after' & `mean_T2_both_`wave'_after'`star_t2c_both_`wave'_after' & `mean_C_both_`wave'_before' & `mean_T1_both_`wave'_before'`star_t1c_both_`wave'_before' & `mean_T2_both_`wave'_before'`star_t2c_both_`wave'_before' \\" _n
    file write latex "N(Family) & `N_C_mother_`wave'_after' & `N_T1_mother_`wave'_after' & `N_T2_mother_`wave'_after' & `N_C_mother_`wave'_before' & `N_T1_mother_`wave'_before' & `N_T2_mother_`wave'_before' \\" _n

    file write latex "\bottomrule" _n
    file write latex "\end{tabular}" _n
    file write latex "\begin{attritionnotes}" _n
    file write latex "Notes: Stars indicate significance relative to the control group. " _n
    file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
    file write latex "Raw means control for strata and enumerator fixed effects." _n
    file write latex "\end{attritionnotes}" _n
    file write latex "\end{fittable}" _n
    file write latex "\end{table}" _n _n
}
file close latex




*###### 2M ONSITE CUTOFF #######

local waves 1m 2m 3m 6m 7m 10m

foreach period in after before {
foreach wave in `waves' {
    //*************** Data Preparation ***************//
    use "$data/id_mapping_confidential.dta", clear

    gen 日期_clean = strtrim(日期)
    gen date = .
    replace date = daily(日期_clean, "MDY") if strpos(日期_clean, "/") > 0
    replace date = daily(日期_clean, "DMY") if missing(date)

    gen 日期_cn = ""
    replace 日期_cn = ustrregexs(1) + "-" + ustrregexs(2) + "-" + ustrregexs(3) ///
        if ustrregexm(日期_clean, "([0-9]{4})年([0-9]{1,2})月([0-9]{1,2})日")
    replace date = daily(日期_cn, "YMD") if missing(date) & 日期_cn != ""
    format date %td

    destring group, replace
    recast float group

    local cutoff_date ""
    if "`wave'" == "1m" local cutoff_date "`m1_cutoff_date'"
    else if "`wave'" == "2m" local cutoff_date "`m2_cutoff_date'"
    else if "`wave'" == "3m" local cutoff_date "`m3_cutoff_date'"
    else if "`wave'" == "6m" local cutoff_date "`m6_cutoff_date'"
    else if "`wave'" == "7m" local cutoff_date "`m7_cutoff_date'"
    else if "`wave'" == "10m" local cutoff_date "`m10_cutoff_date'"

    if "`period'" == "after" {
        keep if date <= date("`cutoff_date'", "YMD") & ///
            date >= date("2025-02-07", "YMD")
    }
    else if "`period'" == "before" {
        keep if date <= date("`cutoff_date'", "YMD") & ///
            date < date("2025-02-07", "YMD")
        drop if date < date("2024-09-21", "YMD")
    }

    gen treatment = "C" if group == 1
    replace treatment = "T1" if group == 2
    replace treatment = "T2" if group == 3

    tempfile complete
    save `complete'

    keep if mother == 1
    gen parent = "M"
    tempfile mother
    save `mother'

    use `complete'
    keep if mother == 0
    gen parent = "F"
    tempfile father
    save `father'

    append using `mother'
    drop if family_id == "f2ddbf38"
    tempfile participants
    save `participants'

    if "`wave'" == "2m" {
        capture drop _merge
        merge 1:m family_id mother using "$data/2m_20260507.dta"
    }
    else if "`wave'" == "6m" {
        capture drop _merge
        drop if family_id == "f2ddbf38"
        merge 1:m family_id mother using "$data/6m_20260507.dta"
    }
    else {
        capture drop _merge
        merge 1:m family_id mother using "$data/`wave'_20260507.dta"
    }

    drop if _merge == 2
    gen response_`wave' = (_merge == 3)
    drop _merge
    drop if missing(family_id)

    merge m:1 family_id using "$data/anonymized_cluster_mapping.dta"
    keep if _merge == 3
    drop _merge

    capture confirm numeric variable strata
    if _rc {
        encode strata, gen(strata_num)
    }
    else {
        gen strata_num = strata
    }

    capture confirm numeric variable enumerator_id
    if _rc {
        encode enumerator_id, gen(enumerator_num)
    }
    else {
        gen enumerator_num = enumerator_id
    }

    capture confirm numeric variable cluster_var
    if _rc {
        encode cluster_var, gen(cluster_num)
    }
    else {
        gen cluster_num = cluster_var
    }

    capture drop submit_dt
    gen double submit_dt = clock(submitdate, "YMDhms")
    format submit_dt %tc

    capture drop has_submit
    gen has_submit = !missing(submit_dt)

    gsort family_id mother -has_submit -submit_dt
    by family_id mother: keep if _n == 1

    bys family_id (mother): gen only_mother = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 0)
    bys family_id (mother): gen only_father = (response_`wave'[_N] == 0 & response_`wave'[_N-1] == 1)
    bysort family_id (response_`wave'): gen response_either_`wave' = response_`wave'[_N]
    bys family_id : gen response_both_`wave' = (response_`wave'[_N] == 1 & response_`wave'[_N-1] == 1)

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")
    
    capture drop attribute_*

    save "$proc/attrition_`wave'_onsite_`period'.dta", replace

    *------------------------------------------------------------*
    *             Regression: Attrition means        *
    *------------------------------------------------------------*
            // ---------- Mothers ----------
        use "$proc/attrition_`wave'_onsite_`period'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su response_`wave' if `g'==1
            local mu_`g'_m_`wave'_os_`period' : di %6.3f r(mean)
            local N_`g'_m_`wave'_os_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t1_m_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local s_t1_m_`wave'_os_`period' ""
        if (`p_t1_m_`wave'_os_`period''<0.1) local s_t1_m_`wave'_os_`period' "*"
        if (`p_t1_m_`wave'_os_`period''<0.05) local s_t1_m_`wave'_os_`period' "**"
        if (`p_t1_m_`wave'_os_`period''<0.01) local s_t1_m_`wave'_os_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t2_m_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local s_t2_m_`wave'_os_`period' ""
        if (`p_t2_m_`wave'_os_`period''<0.1) local s_t2_m_`wave'_os_`period' "*"
        if (`p_t2_m_`wave'_os_`period''<0.05) local s_t2_m_`wave'_os_`period' "**"
        if (`p_t2_m_`wave'_os_`period''<0.01) local s_t2_m_`wave'_os_`period' "***"
        restore

        // Chi2 test
        tab response_`wave' group, chi2
        local pchi2_m_`wave'_ons_`period' : di %6.3f r(p)
        

        // ---------- Fathers ----------
        use "$proc/attrition_`wave'_onsite_`period'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su response_`wave' if `g'==1
            local mu_`g'_f_`wave'_os_`period' : di %6.3f r(mean)
            local N_`g'_f_`wave'_os_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t1_f_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local s_t1_f_`wave'_os_`period' ""
        if (`p_t1_f_`wave'_os_`period''<0.1) local s_t1_f_`wave'_os_`period' "*"
        if (`p_t1_f_`wave'_os_`period''<0.05) local s_t1_f_`wave'_os_`period' "**"
        if (`p_t1_f_`wave'_os_`period''<0.01) local s_t1_f_`wave'_os_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t2_f_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local s_t2_f_`wave'_os_`period' ""
        if (`p_t2_f_`wave'_os_`period''<0.1) local s_t2_f_`wave'_os_`period' "*"
        if (`p_t2_f_`wave'_os_`period''<0.05) local s_t2_f_`wave'_os_`period' "**"
        if (`p_t2_f_`wave'_os_`period''<0.01) local s_t2_f_`wave'_os_`period' "***"
        restore

        // Chi2 test
        tab response_`wave' group, chi2
        local pchi2_f_`wave'_ons_`period' : di %6.3f r(p)
        

        // ---------- Only Mothers ----------
        use "$proc/attrition_`wave'_onsite_`period'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su only_mother if `g'==1
            local mu_`g'_om_`wave'_os_`period' : di %6.3f r(mean)
            local N_`g'_om_`wave'_os_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_mother T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t1_om_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local s_t1_om_`wave'_os_`period' ""
        if (`p_t1_om_`wave'_os_`period''<0.1) local s_t1_om_`wave'_os_`period' "*"
        if (`p_t1_om_`wave'_os_`period''<0.05) local s_t1_om_`wave'_os_`period' "**"
        if (`p_t1_om_`wave'_os_`period''<0.01) local s_t1_om_`wave'_os_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_mother T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t2_om_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local s_t2_om_`wave'_os_`period' ""
        if (`p_t2_om_`wave'_os_`period''<0.1) local s_t2_om_`wave'_os_`period' "*"
        if (`p_t2_om_`wave'_os_`period''<0.05) local s_t2_om_`wave'_os_`period' "**"
        if (`p_t2_om_`wave'_os_`period''<0.01) local s_t2_om_`wave'_os_`period' "***"
        restore

        

        // ---------- Only Fathers ----------
        use "$proc/attrition_`wave'_onsite_`period'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su only_father if `g'==1
            local mu_`g'_of_`wave'_os_`period' : di %6.3f r(mean)
            local N_`g'_of_`wave'_os_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg only_father T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t1_of_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local s_t1_of_`wave'_os_`period' ""
        if (`p_t1_of_`wave'_os_`period''<0.1) local s_t1_of_`wave'_os_`period' "*"
        if (`p_t1_of_`wave'_os_`period''<0.05) local s_t1_of_`wave'_os_`period' "**"
        if (`p_t1_of_`wave'_os_`period''<0.01) local s_t1_of_`wave'_os_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg only_father T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t2_of_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local s_t2_of_`wave'_os_`period' ""
        if (`p_t2_of_`wave'_os_`period''<0.1) local s_t2_of_`wave'_os_`period' "*"
        if (`p_t2_of_`wave'_os_`period''<0.05) local s_t2_of_`wave'_os_`period' "**"
        if (`p_t2_of_`wave'_os_`period''<0.01) local s_t2_of_`wave'_os_`period' "***"
        restore
        

        // ---------- Either parent ----------
        use "$proc/attrition_`wave'_onsite_`period'.dta", clear
        bysort family_id: keep if _n == 1
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_either_`wave' if `g'==1
            local mu_`g'_e_`wave'_os_`period' : di %6.3f r(mean)
            local N_`g'_e_`wave'_os_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_either_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t1_e_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local s_t1_e_`wave'_os_`period' ""
        if (`p_t1_e_`wave'_os_`period''<0.1) local s_t1_e_`wave'_os_`period' "*"
        if (`p_t1_e_`wave'_os_`period''<0.05) local s_t1_e_`wave'_os_`period' "**"
        if (`p_t1_e_`wave'_os_`period''<0.01) local s_t1_e_`wave'_os_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_either_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t2_e_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local s_t2_e_`wave'_os_`period' ""
        if (`p_t2_e_`wave'_os_`period''<0.1) local s_t2_e_`wave'_os_`period' "*"
        if (`p_t2_e_`wave'_os_`period''<0.05) local s_t2_e_`wave'_os_`period' "**"
        if (`p_t2_e_`wave'_os_`period''<0.01) local s_t2_e_`wave'_os_`period' "***"
        restore

        // ---------- Both parent ----------
        use "$proc/attrition_`wave'_onsite_`period'.dta", clear
        bysort family_id: keep if _n == 1
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_both_`wave' if `g'==1
            local mu_`g'_b_`wave'_os_`period' : di %6.3f r(mean)
            local N_`g'_b_`wave'_os_`period' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_both_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t1_b_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local s_t1_b_`wave'_os_`period' ""
        if (`p_t1_b_`wave'_os_`period''<0.1) local s_t1_b_`wave'_os_`period' "*"
        if (`p_t1_b_`wave'_os_`period''<0.05) local s_t1_b_`wave'_os_`period' "**"
        if (`p_t1_b_`wave'_os_`period''<0.01) local s_t1_b_`wave'_os_`period' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_both_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
        local p_t2_b_`wave'_os_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local s_t2_b_`wave'_os_`period' ""
        if (`p_t2_b_`wave'_os_`period''<0.1) local s_t2_b_`wave'_os_`period' "*"
        if (`p_t2_b_`wave'_os_`period''<0.05) local s_t2_b_`wave'_os_`period' "**"
        if (`p_t2_b_`wave'_os_`period''<0.01) local s_t2_b_`wave'_os_`period' "***"
        restore


        
}
}

capture file close latex
file open latex using "$results/tables/attrition_2m_onsite_cutoff.tex", write replace

foreach wave in `waves' {
    file write latex "\begin{table}[H]" _n
    file write latex "\centering" _n
    file write latex "\caption{Raw Means with Significance  - `wave' Survey}" _n
    file write latex "\begin{fittable}" _n
    file write latex "\begin{tabular}{lcccccc}" _n
    file write latex "\toprule" _n
    file write latex "& \multicolumn{3}{c}{After 2m Onsite Survey} & \multicolumn{3}{c}{Before 2m Onsite Survey} \\" _n
    file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
    file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
    file write latex "\midrule" _n

    file write latex "Mother & `mu_C_m_`wave'_os_after' & `mu_T1_m_`wave'_os_after'`s_t1_m_`wave'_os_after' & `mu_T2_m_`wave'_os_after'`s_t2_m_`wave'_os_after' & `mu_C_m_`wave'_os_before' & `mu_T1_m_`wave'_os_before'`s_t1_m_`wave'_os_before' & `mu_T2_m_`wave'_os_before'`s_t2_m_`wave'_os_before' \\" _n
    file write latex "Father & `mu_C_f_`wave'_os_after' & `mu_T1_f_`wave'_os_after'`s_t1_f_`wave'_os_after' & `mu_T2_f_`wave'_os_after'`s_t2_f_`wave'_os_after' & `mu_C_f_`wave'_os_before' & `mu_T1_f_`wave'_os_before'`s_t1_f_`wave'_os_before' & `mu_T2_f_`wave'_os_before'`s_t2_f_`wave'_os_before' \\" _n
    file write latex "Only Mother & `mu_C_om_`wave'_os_after' & `mu_T1_om_`wave'_os_after'`s_t1_om_`wave'_os_after' & `mu_T2_om_`wave'_os_after'`s_t2_om_`wave'_os_after' & `mu_C_om_`wave'_os_before' & `mu_T1_om_`wave'_os_before'`s_t1_om_`wave'_os_before' & `mu_T2_om_`wave'_os_before'`s_t2_om_`wave'_os_before' \\" _n
    file write latex "Only Father & `mu_C_of_`wave'_os_after' & `mu_T1_of_`wave'_os_after'`s_t1_of_`wave'_os_after' & `mu_T2_of_`wave'_os_after'`s_t2_of_`wave'_os_after' & `mu_C_of_`wave'_os_before' & `mu_T1_of_`wave'_os_before'`s_t1_of_`wave'_os_before' & `mu_T2_of_`wave'_os_before'`s_t2_of_`wave'_os_before' \\" _n
    file write latex "Either & `mu_C_e_`wave'_os_after' & `mu_T1_e_`wave'_os_after'`s_t1_e_`wave'_os_after' & `mu_T2_e_`wave'_os_after'`s_t2_e_`wave'_os_after' & `mu_C_e_`wave'_os_before' & `mu_T1_e_`wave'_os_before'`s_t1_e_`wave'_os_before' & `mu_T2_e_`wave'_os_before'`s_t2_e_`wave'_os_before' \\" _n
    file write latex "Both & `mu_C_b_`wave'_os_after' & `mu_T1_b_`wave'_os_after'`s_t1_b_`wave'_os_after' & `mu_T2_b_`wave'_os_after'`s_t2_b_`wave'_os_after' & `mu_C_b_`wave'_os_before' & `mu_T1_b_`wave'_os_before'`s_t1_b_`wave'_os_before' & `mu_T2_b_`wave'_os_before'`s_t2_b_`wave'_os_before' \\" _n
    file write latex "N(Family) & `N_C_m_`wave'_os_after' & `N_T1_m_`wave'_os_after' & `N_T2_m_`wave'_os_after' & `N_C_m_`wave'_os_before' & `N_T1_m_`wave'_os_before' & `N_T2_m_`wave'_os_before' \\" _n

    file write latex "\bottomrule" _n
    file write latex "\end{tabular}" _n
    file write latex "\begin{attritionnotes}" _n
    file write latex "Notes: Stars indicate significance relative to the control group. " _n
    file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
    file write latex "Raw means control for strata and enumerator fixed effects." _n
    file write latex "\end{attritionnotes}" _n
    file write latex "\end{fittable}" _n
    file write latex "\end{table}" _n _n
}
file close latex


*/

//********************************************************************************//
//                   2. ATTRITION FOR CONSECUTIVE WAVES OF SURVEYS               //
//********************************************************************************//


*------------------------------------------------------------*
*                           1m & 2m                          *
*------------------------------------------------------------*

foreach period in after full {

    //*************** Data Preparation ***************//
    use "$data/id_mapping_confidential.dta", clear

    gen 日期_clean = strtrim(日期)
    gen date = .
    replace date = daily(日期_clean, "MDY") if strpos(日期_clean, "/") > 0
    replace date = daily(日期_clean, "DMY") if missing(date)

    gen 日期_cn = ""
    replace 日期_cn = ustrregexs(1) + "-" + ustrregexs(2) + "-" + ustrregexs(3) ///
        if ustrregexm(日期_clean, "([0-9]{4})年([0-9]{1,2})月([0-9]{1,2})日")
    replace date = daily(日期_cn, "YMD") if missing(date) & 日期_cn != ""
    format date %td

    destring group, replace
    recast float group

    if "`period'" == "after" {
        keep if date <= date("`m2_cutoff_date'", "YMD") & ///
            date >= date("2025-02-07", "YMD")
    }
    else if "`period'" == "full" {
        keep if date <= date("`m2_cutoff_date'", "YMD")
    }

    gen treatment = "C" if group == 1
    replace treatment = "T1" if group == 2
    replace treatment = "T2" if group == 3

    tempfile complete
    save `complete'

    keep if mother == 1
    gen parent = "M"
    tempfile mother
    save `mother'

    use `complete'
    keep if mother == 0
    gen parent = "F"
    tempfile father
    save `father'

    append using `mother'
    drop if family_id == "f2ddbf38"
    tempfile participants
    save `participants'

    foreach wave in 1m 2m {
        use `participants', clear
        capture drop _merge
        merge 1:m family_id mother using "$data/`wave'_20260507.dta"
        drop if _merge == 2
        gen response_`wave' = (_merge == 3)
        drop _merge
        drop if missing(family_id)

        capture drop submit_dt
        gen double submit_dt = clock(submitdate, "YMDhms")
        format submit_dt %tc

        capture drop has_submit
        gen has_submit = !missing(submit_dt)

        gsort family_id mother -has_submit -submit_dt
        by family_id mother: keep if _n == 1
        keep family_id mother response_`wave'

        tempfile resp_`wave'
        save `resp_`wave''
    }

    use `participants', clear
    merge 1:1 family_id mother using `resp_1m'
    drop if _merge == 2
    drop _merge

    merge 1:1 family_id mother using `resp_2m'
    drop if _merge == 2
    drop _merge

    replace response_1m = 0 if missing(response_1m)
    replace response_2m = 0 if missing(response_2m)

    merge m:1 family_id using "$data/anonymized_cluster_mapping.dta"
    keep if _merge == 3
    drop _merge

    capture confirm numeric variable strata
    if _rc {
        encode strata, gen(strata_num)
    }
    else {
        gen strata_num = strata
    }

    capture confirm numeric variable enumerator_id
    if _rc {
        encode enumerator_id, gen(enumerator_num)
    }
    else {
        gen enumerator_num = enumerator_id
    }

    capture confirm numeric variable cluster_var
    if _rc {
        encode cluster_var, gen(cluster_num)
    }
    else {
        gen cluster_num = cluster_var
    }

    gen any_response = (response_1m == 1 | response_2m == 1)

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")

    save "$proc/attrition_1m_2m_`period'.dta", replace

    *-------------------------------------------------*
    *             Regression: treatment effect        *
    *-------------------------------------------------*

    foreach par in m f {
        use "$proc/attrition_1m_2m_`period'.dta", clear
        if "`par'" == "m" keep if mother == 1
        if "`par'" == "f" keep if mother == 0

        foreach g in C T1 T2 {
            su response_1m if `g'==1
            local mu_`g'_`par'_1m_`period' : di %6.3f r(mean)
            local N_`g'_`par'_1m_`period' = r(N)

            su response_2m if `g'==1
            local mu_`g'_`par'_2m_`period' : di %6.3f r(mean)
            local N_`g'_`par'_2m_`period' = r(N)

            su any_response if `g'==1
            local mu_`g'_`par'_any_`period' : di %6.3f r(mean)
            local N_`g'_`par'_any_`period' = r(N)
        }

        foreach y in response_1m response_2m any_response {
            local v ""
            if "`y'" == "response_1m" local v "1m"
            else if "`y'" == "response_2m" local v "2m"
            else if "`y'" == "any_response" local v "any"

            // T1 vs C
            preserve
            drop if T2==1
            reg `y' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
            local p_t1_`par'_`v'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
            local s_t1_`par'_`v'_`period' ""
            if (`p_t1_`par'_`v'_`period''<0.1) local s_t1_`par'_`v'_`period' "*"
            if (`p_t1_`par'_`v'_`period''<0.05) local s_t1_`par'_`v'_`period' "**"
            if (`p_t1_`par'_`v'_`period''<0.01) local s_t1_`par'_`v'_`period' "***"
            restore

            // T2 vs C
            preserve
            drop if T1==1
            reg `y' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
            local p_t2_`par'_`v'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
            local s_t2_`par'_`v'_`period' ""
            if (`p_t2_`par'_`v'_`period''<0.1) local s_t2_`par'_`v'_`period' "*"
            if (`p_t2_`par'_`v'_`period''<0.05) local s_t2_`par'_`v'_`period' "**"
            if (`p_t2_`par'_`v'_`period''<0.01) local s_t2_`par'_`v'_`period' "***"
            restore
        }
    }
}

// Output LaTeX table for 1m & 2m
capture file close resultsfile
file open resultsfile using "$results/tables/response_across_wave.tex", write replace

foreach period in after full {
    local ptitle "After Cutoff"
    if "`period'" == "full" local ptitle "Full Sample"

    file write resultsfile "\begin{table}[H]" _n
    file write resultsfile "\centering" _n
    file write resultsfile "\caption{Raw Means with Significance (1m, 2m)}" _n
    file write resultsfile "\begin{fittable}" _n
    file write resultsfile "\begin{tabular}{lcccccc}" _n
    file write resultsfile "\toprule" _n
    file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
    file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
    file write resultsfile "\textbf{Measure} & \textbf{Control} & \textbf{T1} & \textbf{T2} & \textbf{Control} & \textbf{T1} & \textbf{T2} \\" _n
    file write resultsfile "\midrule" _n
    file write resultsfile "1m Response & `mu_C_m_1m_`period'' & `mu_T1_m_1m_`period''`s_t1_m_1m_`period'' & `mu_T2_m_1m_`period''`s_t2_m_1m_`period'' & `mu_C_f_1m_`period'' & `mu_T1_f_1m_`period''`s_t1_f_1m_`period'' & `mu_T2_f_1m_`period''`s_t2_f_1m_`period'' \\" _n
    file write resultsfile "2m Response & `mu_C_m_2m_`period'' & `mu_T1_m_2m_`period''`s_t1_m_2m_`period'' & `mu_T2_m_2m_`period''`s_t2_m_2m_`period'' & `mu_C_f_2m_`period'' & `mu_T1_f_2m_`period''`s_t1_f_2m_`period'' & `mu_T2_f_2m_`period''`s_t2_f_2m_`period'' \\" _n
    file write resultsfile "Any Response & `mu_C_m_any_`period'' & `mu_T1_m_any_`period''`s_t1_m_any_`period'' & `mu_T2_m_any_`period''`s_t2_m_any_`period'' & `mu_C_f_any_`period'' & `mu_T1_f_any_`period''`s_t1_f_any_`period'' & `mu_T2_f_any_`period''`s_t2_f_any_`period'' \\" _n
    file write resultsfile "N & `N_C_m_1m_`period'' & `N_T1_m_1m_`period'' & `N_T2_m_1m_`period'' & `N_C_f_1m_`period'' & `N_T1_f_1m_`period'' & `N_T2_f_1m_`period'' \\" _n
    file write resultsfile "\bottomrule" _n
    file write resultsfile "\end{tabular}" _n
    file write resultsfile "\begin{attritionnotes}" _n
    file write resultsfile "Notes: This table reports the `ptitle' sample. Stars indicate significance relative to the control group. " _n
    file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
    file write resultsfile "Raw means control for strata and enumerator fixed effects." _n
    file write resultsfile "\end{attritionnotes}" _n
    file write resultsfile "\end{fittable}" _n
    file write resultsfile "\end{table}" _n
}

file close resultsfile








*------------------------------------------------------------*
*             Remaining consecutive-wave tables              *
*------------------------------------------------------------*

local ctags 1m_2m_3m 1m_2m_3m_6m 1m_2m_3m_6m_7m 1m_2m_3m_6m_7m_10m

foreach ctag of local ctags {

    if "`ctag'" == "1m_2m_3m" {
        local cwaves 1m 2m 3m
        local ccut "`m3_cutoff_date'"
        local ctitle "1m, 2m, 3m"
    }
    else if "`ctag'" == "1m_2m_3m_6m" {
        local cwaves 1m 2m 3m 6m
        local ccut "`m6_cutoff_date'"
        local ctitle "1m, 2m, 3m, 6m"
    }
    else if "`ctag'" == "1m_2m_3m_6m_7m" {
        local cwaves 1m 2m 3m 6m 7m
        local ccut "`m7_cutoff_date'"
        local ctitle "1m, 2m, 3m, 6m, 7m"
    }
    else if "`ctag'" == "1m_2m_3m_6m_7m_10m" {
        local cwaves 1m 2m 3m 6m 7m 10m
        local ccut "`m10_cutoff_date'"
        local ctitle "1m, 2m, 3m, 6m, 7m, 10m"
    }

    foreach period in after full {

        //*************** Data Preparation ***************//
        use "$data/id_mapping_confidential.dta", clear

        gen 日期_clean = strtrim(日期)
        gen date = .
        replace date = daily(日期_clean, "MDY") if strpos(日期_clean, "/") > 0
        replace date = daily(日期_clean, "DMY") if missing(date)

        gen 日期_cn = ""
        replace 日期_cn = ustrregexs(1) + "-" + ustrregexs(2) + "-" + ustrregexs(3) ///
            if ustrregexm(日期_clean, "([0-9]{4})年([0-9]{1,2})月([0-9]{1,2})日")
        replace date = daily(日期_cn, "YMD") if missing(date) & 日期_cn != ""
        format date %td

        destring group, replace
        recast float group

        if "`period'" == "after" {
            keep if date <= date("`ccut'", "YMD") & ///
                date >= date("2025-02-07", "YMD")
        }
        else if "`period'" == "full" {
            keep if date <= date("`ccut'", "YMD")
        }

        gen treatment = "C" if group == 1
        replace treatment = "T1" if group == 2
        replace treatment = "T2" if group == 3

        tempfile complete
        save `complete'

        keep if mother == 1
        gen parent = "M"
        tempfile mother
        save `mother'

        use `complete'
        keep if mother == 0
        gen parent = "F"
        tempfile father
        save `father'

        append using `mother'
        drop if family_id == "f2ddbf38"
        tempfile participants
        save `participants'

        foreach wave of local cwaves {
            use `participants', clear
            capture drop _merge
            merge 1:m family_id mother using "$data/`wave'_20260507.dta"
            drop if _merge == 2
            gen response_`wave' = (_merge == 3)
            drop _merge
            drop if missing(family_id)

            capture drop submit_dt
            gen double submit_dt = clock(submitdate, "YMDhms")
            format submit_dt %tc

            capture drop has_submit
            gen has_submit = !missing(submit_dt)

            gsort family_id mother -has_submit -submit_dt
            by family_id mother: keep if _n == 1
            keep family_id mother response_`wave'

            tempfile resp_`wave'
            save `resp_`wave''
        }

        use `participants', clear
        foreach wave of local cwaves {
            merge 1:1 family_id mother using `resp_`wave''
            drop if _merge == 2
            drop _merge
            replace response_`wave' = 0 if missing(response_`wave')
        }

        merge m:1 family_id using "$data/anonymized_cluster_mapping.dta"
        keep if _merge == 3
        drop _merge

        capture confirm numeric variable strata
        if _rc {
            encode strata, gen(strata_num)
        }
        else {
            gen strata_num = strata
        }

        capture confirm numeric variable enumerator_id
        if _rc {
            encode enumerator_id, gen(enumerator_num)
        }
        else {
            gen enumerator_num = enumerator_id
        }

        capture confirm numeric variable cluster_var
        if _rc {
            encode cluster_var, gen(cluster_num)
        }
        else {
            gen cluster_num = cluster_var
        }

        gen any_response = 0
        foreach wave of local cwaves {
            replace any_response = 1 if response_`wave' == 1
        }

        gen C = (treatment == "C")
        gen T1 = (treatment == "T1")
        gen T2 = (treatment == "T2")

        save "$proc/attrition_`ctag'_`period'.dta", replace

        *-------------------------------------------------*
        *             Regression: treatment effect        *
        *-------------------------------------------------*

        foreach par in m f {
            use "$proc/attrition_`ctag'_`period'.dta", clear
            if "`par'" == "m" keep if mother == 1
            if "`par'" == "f" keep if mother == 0

            foreach g in C T1 T2 {
                foreach wave of local cwaves {
                    su response_`wave' if `g'==1
                    local mu_`g'_`par'_`wave'_`period' : di %6.3f r(mean)
                    local N_`g'_`par'_`wave'_`period' = r(N)
                }

                su any_response if `g'==1
                local mu_`g'_`par'_any_`period' : di %6.3f r(mean)
                local N_`g'_`par'_any_`period' = r(N)
            }

            foreach wave of local cwaves {
                // T1 vs C
                preserve
                drop if T2==1
                reg response_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
                local p_t1_`par'_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
                local s_t1_`par'_`wave'_`period' ""
                if (`p_t1_`par'_`wave'_`period''<0.1) local s_t1_`par'_`wave'_`period' "*"
                if (`p_t1_`par'_`wave'_`period''<0.05) local s_t1_`par'_`wave'_`period' "**"
                if (`p_t1_`par'_`wave'_`period''<0.01) local s_t1_`par'_`wave'_`period' "***"
                restore

                // T2 vs C
                preserve
                drop if T1==1
                reg response_`wave' T2 i.strata_num i.enumerator_num, cluster(cluster_num)
                local p_t2_`par'_`wave'_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
                local s_t2_`par'_`wave'_`period' ""
                if (`p_t2_`par'_`wave'_`period''<0.1) local s_t2_`par'_`wave'_`period' "*"
                if (`p_t2_`par'_`wave'_`period''<0.05) local s_t2_`par'_`wave'_`period' "**"
                if (`p_t2_`par'_`wave'_`period''<0.01) local s_t2_`par'_`wave'_`period' "***"
                restore
            }

            // T1 vs C, any response
            preserve
            drop if T2==1
            reg any_response T1 i.strata_num i.enumerator_num, cluster(cluster_num)
            local p_t1_`par'_any_`period' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
            local s_t1_`par'_any_`period' ""
            if (`p_t1_`par'_any_`period''<0.1) local s_t1_`par'_any_`period' "*"
            if (`p_t1_`par'_any_`period''<0.05) local s_t1_`par'_any_`period' "**"
            if (`p_t1_`par'_any_`period''<0.01) local s_t1_`par'_any_`period' "***"
            restore

            // T2 vs C, any response
            preserve
            drop if T1==1
            reg any_response T2 i.strata_num i.enumerator_num, cluster(cluster_num)
            local p_t2_`par'_any_`period' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
            local s_t2_`par'_any_`period' ""
            if (`p_t2_`par'_any_`period''<0.1) local s_t2_`par'_any_`period' "*"
            if (`p_t2_`par'_any_`period''<0.05) local s_t2_`par'_any_`period' "**"
            if (`p_t2_`par'_any_`period''<0.01) local s_t2_`par'_any_`period' "***"
            restore
        }
    }

    // Output LaTeX table
    capture file close resultsfile
    file open resultsfile using "$results/tables/response_across_wave.tex", write append

    foreach period in after full {
        local ptitle "After Cutoff"
        if "`period'" == "full" local ptitle "Full Sample"

        file write resultsfile "\begin{table}[H]" _n
        file write resultsfile "\centering" _n
        file write resultsfile "\caption{Raw Means with Significance (`ctitle')}" _n
    file write resultsfile "\begin{fittable}" _n
    file write resultsfile "\begin{tabular}{lcccccc}" _n
        file write resultsfile "\toprule" _n
        file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
        file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
        file write resultsfile "\textbf{Measure} & \textbf{Control} & \textbf{T1} & \textbf{T2} & \textbf{Control} & \textbf{T1} & \textbf{T2} \\" _n
        file write resultsfile "\midrule" _n

        foreach wave of local cwaves {
            file write resultsfile "`wave' Response & `mu_C_m_`wave'_`period'' & `mu_T1_m_`wave'_`period''`s_t1_m_`wave'_`period'' & `mu_T2_m_`wave'_`period''`s_t2_m_`wave'_`period'' & `mu_C_f_`wave'_`period'' & `mu_T1_f_`wave'_`period''`s_t1_f_`wave'_`period'' & `mu_T2_f_`wave'_`period''`s_t2_f_`wave'_`period'' \\" _n
        }

        file write resultsfile "Any Response & `mu_C_m_any_`period'' & `mu_T1_m_any_`period''`s_t1_m_any_`period'' & `mu_T2_m_any_`period''`s_t2_m_any_`period'' & `mu_C_f_any_`period'' & `mu_T1_f_any_`period''`s_t1_f_any_`period'' & `mu_T2_f_any_`period''`s_t2_f_any_`period'' \\" _n
        file write resultsfile "N & `N_C_m_1m_`period'' & `N_T1_m_1m_`period'' & `N_T2_m_1m_`period'' & `N_C_f_1m_`period'' & `N_T1_f_1m_`period'' & `N_T2_f_1m_`period'' \\" _n
        file write resultsfile "\bottomrule" _n
        file write resultsfile "\end{tabular}" _n
    file write resultsfile "\begin{attritionnotes}" _n
        file write resultsfile "Notes: This table reports the `ptitle' sample. Stars indicate significance relative to the control group. " _n
        file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
        file write resultsfile "Raw means control for strata and enumerator fixed effects." _n
        file write resultsfile "\end{attritionnotes}" _n
    file write resultsfile "\end{fittable}" _n
        file write resultsfile "\end{table}" _n
    }

    file close resultsfile
}


log close
