////////////////////////////////--------------------------

/* Attrition Analysis of 42d face-to-face survey


The goal of the analysis is to check balanceness across treatment arms.



    42d survey id:
    191613
    815998
    184411
    265968
    924349
    446773


AUTHOR: Haoyue Wu
Updated on: 24Oct 2025

*/

*************** LOG *****************
/* time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 42d_attrition
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd */



///////////////////////////////////////////////////////
//// 1. Data Aggregation and Cleaning /////////////////
///////////////////////////////////////////////////////


* ---------------- (1) answers recorded by mother and father themselves -------------------- *

import delimited using "$data/results-survey191613.csv", stringcols(_all) encoding("utf-8") clear
tempfile 1
save `1'

import delimited using "$data/results-survey815998.csv", stringcols(_all) encoding("utf-8") clear
tempfile 2
save `2'

import delimited using "$data/results-survey184411.csv", stringcols(_all) encoding("utf-8") clear
tempfile 3
save `3'

import delimited using "$data/results-survey265968.csv", stringcols(_all) encoding("utf-8") clear
tempfile 4
save `4'

import delimited using "$data/results-survey924349.csv", stringcols(_all) encoding("utf-8") clear
tempfile 5
save `5'

import delimited using "$data/results-survey446773.csv", stringcols(_all) encoding("utf-8") clear

append using `1', force
append using `2', force
append using `3', force
append using `4', force 
append using `5', force
drop if submitdate == ""
replace g00q02 = "爸爸" in 104

gen both_present = (g00q03sq002 == "是")
replace both_present = 1 if g00q02 == "爸爸"

keep submitdate mname fname mphone fphone g00q01sq001 g00q02 both_present

rename g00q01sq001 hospital_id
tostring hospital_id, replace
rename g00q02 parent

preserve
keep if parent == "爸爸"
keep fname fphone parent hospital_id both_present
rename (fphone fname)(firstname lastname)
tempfile father 
save `father'
restore

keep if parent == "妈妈"
keep mname mphone parent hospital_id both_present
rename (mphone mname)(firstname lastname)
append using `father'

replace both_present = 1 if parent == "爸爸"
gen complete_onsite = 1
drop parent

tempfile 1
save `1' 



import delimited using "$data/results-survey448999.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""


rename attribute_11 hospital_id

tempfile part4
save `part4'

import delimited using "$data/results-survey162992.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

rename attribute_11 hospital_id

tempfile part5
save `part5'

import delimited using "$data/results-survey753661.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

rename attribute_11 hospital_id

tempfile part6
save `part6'

import delimited using "$data/results-survey669218.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

rename attribute_11 hospital_id

tempfile part7
save `part7'

import delimited using "$data/results-survey792737.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

rename attribute_11 hospital_id

append using `part4', force
append using `part5', force
append using `part6', force
append using `part7', force

keep firstname lastname hospital_id g00q03sq002 g00q07
gen both_present = (g00q03sq002 == "是")
replace both_present = 1 if g00q07 == "是， 我去了"
sort hospital_id
/* bysort hospital_id: replace both_present = 1 if both_present[_N] == 1 */
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop g00q03sq002
gen complete_online = 1

append using `1'

duplicates tag firstname complete_online, gen(tag)
sort firstname
br if tag == 1
duplicates drop firstname complete_online, force
drop tag
duplicates tag firstname, gen(tag)
sort firstname
br if tag == 1
replace complete_onsite = 1 if tag == 1
replace complete_online = 0 if tag == 1
duplicates drop firstname, force
drop tag
replace complete_online = 0 if complete_online == .
replace complete_onsite = 0 if complete_onsite == .


rename both_present both_present_self

save "$proc/2m&6w_complete_results.dta", replace

* ---------------- (2) answers recorded by the enumerators  -------------------- *

import excel using "$data/6w_appointment_list.xlsx", firstrow clear

keep 住院号 姓名 父母是否同行 父母是否完成 未做问卷原因

rename 住院号 hospital_id
rename 姓名 name
rename 父母是否同行 complete1
rename 父母是否完成 complete2
rename 未做问卷原因 reason

gen both_present = 1 if complete1 == "父母都在"
replace both_present = 0 if complete1 == "仅母亲" | complete1 == "仅父亲"

gen completed_mother = (complete2 == "仅母亲")
gen completed_father = (complete2 == "仅父亲")
gen completed_both = (complete2 == "父母均做")

gen refused = (reason == "拒绝")
gen missed = (reason == "错失")
drop if reason == "取消"

gen refused_father = (both_present == 1 & completed_mother == 1)
gen refused_mother = (both_present == 1 & completed_father == 1)

drop complete1 complete2 reason

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

tempfile appointment_list
save `appointment_list'



// merge treatment group to appointment list
use "$proc/contact_list.dta", clear

gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
rename 组别 treatment

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 treatment hospital_id


merge 1:m hospital_id using `appointment_list'
keep if _merge == 3
drop _merge
drop name 

gen C = (treatment == "1")
gen T1 = (treatment == "2")
gen T2 = (treatment == "3")
drop treatment

tempfile complete
save `complete'

drop 父亲姓名 父亲电话
rename (母亲姓名 母亲电话)(lastname firstname)
gen mother = 1
tempfile mother
save `mother'

use `complete'
drop 母亲姓名 母亲电话
rename (父亲姓名 父亲电话)(lastname firstname)
gen mother = 0
tempfile father
save `father'

append using `mother'
order firstname lastname
gen group = C == 1
replace group = 2 if T1 == 1
replace group = 3 if T2 == 1






/* gen complete = 1 if (completed_mother == 1 & mother == 1) | completed_both == 1
replace complete = 1 if completed_father == 1 & mother == 0
rename complete complete_onsite

replace complete_onsite = 0 if complete_onsite == . */

replace refused = 1 if refused_father == 1 & mother == 0
replace refused = 1 if refused_mother == 1 & mother == 1
drop refused_father refused_mother

rename both_present enu_rep_both_present
drop completed_mother completed_father completed_both 

duplicates drop firstname, force
merge 1:1 firstname using "$proc/2m&6w_complete_results.dta"
drop if _merge == 2
drop _merge
gen complete_either = (complete_onsite == 1 | complete_online == 1)

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
rename enu_rep_both_present both_present_enu 
keep if _merge == 3
drop _merge
local varlist complete_onsite complete_online complete_either 
foreach var of local varlist {
    replace `var' = 0 if `var' == .
}

save "$proc/2m_onsite_attrition_analysis.dta", replace

//*********************************************//
//                   Regressions               //
//*********************************************//
capture file close resultsfile
file open resultsfile using "$results/tables/response_42d.tex", write replace
file write resultsfile _n
file write resultsfile "\begin{table}[htbp]" _n
file write resultsfile "\centering" _n
file write resultsfile "\begin{threeparttable}" _n
file write resultsfile "\caption{Residualized Response Means - 42d Survey}" _n  
file write resultsfile "\begin{tabular}{lcccccc}" _n
file write resultsfile "\toprule" _n
file write resultsfile "& \multicolumn{3}{c}{Mother} & \multicolumn{3}{c}{Father} \\" _n
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write resultsfile "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write resultsfile "\midrule" _n

local outcome_var both_present_enu both_present_self complete_onsite complete_online complete_either missed refused
foreach var of local outcome_var {
    use "$proc/2m_onsite_attrition_analysis.dta", clear
    drop if `var' == .
    keep if mother == 1
    foreach g in C T1 T2 {
        su `var' if `g'==1
        local mean_`var'_`g'_m : di %6.3f r(mean)
        local N_`g'_m = r(N)   
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg `var' T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_m ""
        if (`pval_t1c_m'<0.1) local star_t1c_m "*"
        if (`pval_t1c_m'<0.05) local star_t1c_m "**"
        if (`pval_t1c_m'<0.01) local star_t1c_m "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg `var' T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_m ""
        if (`pval_t2c_m'<0.1) local star_t2c_m "*"
        if (`pval_t2c_m'<0.05) local star_t2c_m "**"
        if (`pval_t2c_m'<0.01) local star_t2c_m "***"
        restore

    use "$proc/2m_onsite_attrition_analysis.dta", clear
    drop if `var' == .
    keep if mother == 0
    foreach g in C T1 T2 {
        su `var' if `g'==1
        local mean_`var'_`g'_f : di %6.3f r(mean)
        local N_`g'_f = r(N)   
    }

        // T1 vs C
        preserve
        drop if T2==1
        reg `var' T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_f = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_f ""
        if (`pval_t1c_f'<0.1) local star_t1c_f "*"
        if (`pval_t1c_f'<0.05) local star_t1c_f "**"
        if (`pval_t1c_f'<0.01) local star_t1c_f "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg `var' T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_f = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_f ""
        if (`pval_t2c_f'<0.1) local star_t2c_f "*"
        if (`pval_t2c_f'<0.05) local star_t2c_f "**"
        if (`pval_t2c_f'<0.01) local star_t2c_f "***"
        restore


    file write resultsfile "`var' & `mean_`var'_C_m'(`N_C_m') & `mean_`var'_T1_m'`star_t1c_m' (`N_T1_m') & `mean_`var'_T2_m'`star_t2c_m' (`N_T2_m') & `mean_`var'_C_f' (`N_C_f') & `mean_`var'_T1_f'`star_t1c_f' (`N_T1_f') & `mean_`var'_T2_f'`star_t2c_f' (`N_T2_f') \\" _n
}


file write resultsfile "N & `N_C_m' & `N_T1_m' & `N_T2_m' & `N_C_f' & `N_T1_f' & `N_T2_f' \\" _n
file write resultsfile "\bottomrule" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\small" _n
file write resultsfile "Notes: Stars indicate significance relative to the control group. " _n
file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write resultsfile "Residualized means control for strata and enumerator fixed effects." _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{threeparttable}" _n
file write resultsfile "\end{table}" _n
file close resultsfile








******************************* CONSTRUCTING TABLES FOR RAW MEANS *******************************


use "$proc/2m_onsite_attrition_analysis.dta", clear
keep firstname hospital_id C T1 T2 mother complete_either strata cluster_var enumerator_id
rename complete_either response_2m

/* merge 1:1 firstname using "$proc/rubbish_2m_results.dta" */

keep if mother == 1
// Loop through each treatment group (Control, T1, T2) to calculate summary statistics
foreach g in C T1 T2 {
    su response_2m if `g'==1
    local mean_`g'_mother_2m : di %6.3f r(mean)
    local N_`g'_mother_2m = r(N)
}

// T1 vs C
preserve
drop if T2 == 1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_mother_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_mother_2m ""
if (`pval_t1c_mother_2m'<0.1) local star_t1c_mother_2m "*"
if (`pval_t1c_mother_2m'<0.05) local star_t1c_mother_2m "**"
if (`pval_t1c_mother_2m'<0.01) local star_t1c_mother_2m "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_mother_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_mother_2m ""
if (`pval_t2c_mother_2m'<0.1) local star_t2c_mother_2m "*"
if (`pval_t2c_mother_2m'<0.05) local star_t2c_mother_2m "**"
if (`pval_t2c_mother_2m'<0.01) local star_t2c_mother_2m "***"
restore

// ---------- Fathers ----------
use "$proc/2m_onsite_attrition_analysis.dta", clear
keep firstname hospital_id C T1 T2 mother complete_either strata cluster_var enumerator_id
rename complete_either response_2m
keep if mother == 0

// Loop through each treatment group (Control, T1, T2) to calculate summary statistics
foreach g in C T1 T2 {
    su response_2m if `g'==1
    local mean_`g'_father_2m : di %6.3f r(mean)
    local N_`g'_father_2m = r(N)  // FIX: Added missing N calculation
}

// T1 vs C
preserve
drop if T2 == 1
reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_father_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_father_2m ""
if (`pval_t1c_father_2m'<0.1) local star_t1c_father_2m "*"
if (`pval_t1c_father_2m'<0.05) local star_t1c_father_2m "**"
if (`pval_t1c_father_2m'<0.01) local star_t1c_father_2m "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_father_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_father_2m ""
if (`pval_t2c_father_2m'<0.1) local star_t2c_father_2m "*"
if (`pval_t2c_father_2m'<0.05) local star_t2c_father_2m "**"
if (`pval_t2c_father_2m'<0.01) local star_t2c_father_2m "***"
restore

// ---------- Either parent ----------
use "$proc/2m_onsite_attrition_analysis.dta", clear
keep firstname hospital_id C T1 T2 mother complete_either strata cluster_var enumerator_id
rename complete_either response_2m
sort hospital_id response_2m
egen response_either_2m = max(response_2m), by(hospital_id)

// Use full sample, not just mothers or fathers
foreach g in C T1 T2 {
    su response_either_2m if `g'==1
    local mean_`g'_either_2m : di %6.3f r(mean)
    local N_`g'_either_2m = r(N)  // FIX: Added missing N calculation
}

// T1 vs C
preserve
drop if T2==1
reg response_either_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t1c_either_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
local star_t1c_either_2m ""
if (`pval_t1c_either_2m'<0.1) local star_t1c_either_2m "*"
if (`pval_t1c_either_2m'<0.05) local star_t1c_either_2m "**"
if (`pval_t1c_either_2m'<0.01) local star_t1c_either_2m "***"
restore

// T2 vs C
preserve
drop if T1==1
reg response_either_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
local pval_t2c_either_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
local star_t2c_either_2m ""
if (`pval_t2c_either_2m'<0.1) local star_t2c_either_2m "*"
if (`pval_t2c_either_2m'<0.05) local star_t2c_either_2m "**"
if (`pval_t2c_either_2m'<0.01) local star_t2c_either_2m "***"
restore

// Debug: Check all macros before writing
display "=== DEBUGGING MACROS ==="
display "Mother - C: `mean_C_mother_2m' (N=`N_C_mother_2m')"
display "Mother - T1: `mean_T1_mother_2m'`star_t1c_mother_2m' (N=`N_T1_mother_2m')"
display "Mother - T2: `mean_T2_mother_2m'`star_t2c_mother_2m' (N=`N_T2_mother_2m')"
display "Father - C: `mean_C_father_2m' (N=`N_C_father_2m')"
display "Father - T1: `mean_T1_father_2m'`star_t1c_father_2m' (N=`N_T1_father_2m')"
display "Father - T2: `mean_T2_father_2m'`star_t2c_father_2m' (N=`N_T2_father_2m')"
display "Either - C: `mean_C_either_2m' (N=`N_C_either_2m')"
display "Either - T1: `mean_T1_either_2m'`star_t1c_either_2m' (N=`N_T1_either_2m')"
display "Either - T2: `mean_T2_either_2m'`star_t2c_either_2m' (N=`N_T2_either_2m')"

// Check if file path exists
capture mkdir "$results"
capture mkdir "$results/tables"

capture file close latex
file open latex using "$results/tables/attrition_raw_significance.tex", write replace

// Check if file opened successfully
if _rc != 0 {
    display "ERROR: Could not open LaTeX file. Return code: " _rc
    exit _rc
}

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\caption{Rubbish Answers - 2m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

// FIX: Added missing \\ at end of each row
file write latex "Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m' \\" _n
file write latex "Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' \\" _n
file write latex "Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_t1c_either_2m' & `mean_T2_either_2m'`star_t2c_either_2m' \\" _n
file write latex "N(Family) & `N_C_mother_2m' & `N_T1_mother_2m' & `N_T2_mother_2m' \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\end{table}" _n

file close latex
display "LaTeX file written successfully!"








*-------- before in-person survey --------*

/* 
use "$proc/2m_onsite_attrition_analysis.dta", clear
keep firstname hospital_id
tempfile afterinperson
save `afterinperson'

use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

    keep if date <= date("2025-03-16", "YMD") 
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

    merge 1:m firstname using `afterinperson'
    keep if _merge == 1
    drop _merge

    merge 1:m firstname using "$proc/2m&6w_results.dta"
    drop if _merge == 2
    gen response_2m = (_merge == 3)
    drop _merge
    drop if missing(firstname)

    merge m:1 hospital_id using ///
    "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
    keep if _merge == 3
    drop _merge

    duplicates drop firstname, force

    bysort hospital_id (response_2m): gen response_either_2m = response_2m[_N]

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")
    gen group = 1 if C == 1
    replace group = 2 if T1 == 1
    replace group = 3 if T2 == 1
    
    gen mother = (parent == "M")
    capture drop attribute_*

    save "$proc/attrition_2m_before_in_person.dta", replace

            // ---------- Mothers ----------
        use "$proc/attrition_2m_before_in_person.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su response_2m if `g'==1
            local mean_`g'_mother_2m : di %6.3f r(mean)
            local N_`g'_mother_2m = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_mother_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mother_2m ""
        if (`pval_t1c_mother_2m'<0.1) local star_t1c_mother_2m "*"
        if (`pval_t1c_mother_2m'<0.05) local star_t1c_mother_2m "**"
        if (`pval_t1c_mother_2m'<0.01) local star_t1c_mother_2m "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_mother_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mother_2m ""
        if (`pval_t2c_mother_2m'<0.1) local star_t2c_mother_2m "*"
        if (`pval_t2c_mother_2m'<0.05) local star_t2c_mother_2m "**"
        if (`pval_t2c_mother_2m'<0.01) local star_t2c_mother_2m "***"
        restore

        // Chi2 test
        tab response_2m group, chi2
        local pval_chi2_mother_2m : di %6.3f r(p)
        

        // ---------- Fathers ----------
        use "$proc/attrition_2m_before_in_person.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su response_2m if `g'==1
            local mean_`g'_father_2m : di %6.3f r(mean)
            local N_`g'_father_2m = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_father_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_father_2m ""
        if (`pval_t1c_father_2m'<0.1) local star_t1c_father_2m "*"
        if (`pval_t1c_father_2m'<0.05) local star_t1c_father_2m "**"
        if (`pval_t1c_father_2m'<0.01) local star_t1c_father_2m "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_father_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_father_2m ""
        if (`pval_t2c_father_2m'<0.1) local star_t2c_father_2m "*"
        if (`pval_t2c_father_2m'<0.05) local star_t2c_father_2m "**"
        if (`pval_t2c_father_2m'<0.01) local star_t2c_father_2m "***"
        restore

        // Chi2 test
        tab response_2m group, chi2
        local pval_chi2_father_2m : di %6.3f r(p)
        

        // ---------- Either parent ----------
        use "$proc/attrition_2m_before_in_person.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su response_either_2m if `g'==1
            local mean_`g'_either_2m : di %6.3f r(mean)
            local N_`g'_either_2m = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg response_either_2m T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_either_2m = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_either_2m ""
        if (`pval_t1c_either_2m'<0.1) local star_t1c_either_2m "*"
        if (`pval_t1c_either_2m'<0.05) local star_t1c_either_2m "**"
        if (`pval_t1c_either_2m'<0.01) local star_t1c_either_2m "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg response_either_2m T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_either_2m = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_either_2m ""
        if (`pval_t2c_either_2m'<0.1) local star_t2c_either_2m "*"
        if (`pval_t2c_either_2m'<0.05) local star_t2c_either_2m "**"
        if (`pval_t2c_either_2m'<0.01) local star_t2c_either_2m "***"
        restore

        // Chi2 test
        tab response_either_2m group, chi2
        local pval_chi2_either_2m : di %6.3f r(p)
        


// Debug: Check all macros before writing
display "=== DEBUGGING MACROS ==="
display "Mother - C: `mean_C_mother_2m' (N=`N_C_mother_2m')"
display "Mother - T1: `mean_T1_mother_2m'`star_t1c_mother_2m' (N=`N_T1_mother_2m')"
display "Mother - T2: `mean_T2_mother_2m'`star_t2c_mother_2m' (N=`N_T2_mother_2m')"
display "Father - C: `mean_C_father_2m' (N=`N_C_father_2m')"
display "Father - T1: `mean_T1_father_2m'`star_t1c_father_2m' (N=`N_T1_father_2m')"
display "Father - T2: `mean_T2_father_2m'`star_t2c_father_2m' (N=`N_T2_father_2m')"
display "Either - C: `mean_C_either_2m' (N=`N_C_either_2m')"
display "Either - T1: `mean_T1_either_2m'`star_t1c_either_2m' (N=`N_T1_either_2m')"
display "Either - T2: `mean_T2_either_2m'`star_t2c_either_2m' (N=`N_T2_either_2m')"

// Check if file path exists
capture mkdir "$results"
capture mkdir "$results/tables"

capture file close latex
file open latex using "$results/tables/attrition_raw_significance1.tex", write replace

// Check if file opened successfully
if _rc != 0 {
    display "ERROR: Could not open LaTeX file. Return code: " _rc
    exit _rc
}

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\caption{Rubbish Answers - 2m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

// FIX: Added missing \\ at end of each row
file write latex "Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m' \\" _n
file write latex "Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' \\" _n
file write latex "Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_t1c_either_2m' & `mean_T2_either_2m'`star_t2c_either_2m' \\" _n
file write latex "N(Family) & `N_C_mother_2m' & `N_T1_mother_2m' & `N_T2_mother_2m' \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\end{table}" _n

file close latex
display "LaTeX file written successfully!" */