** Comparison of attrition BEFORE and AFTER Triple P change

/*

Author: Haoyue Wu
Updated on: Mar 10, 2025

run following codes before running this program:
	1. attrition_1m.do / attrition_2m.do / attrition_3m.do
	2. contact_list_append.do 
	*/
	
	
** attrition table **
/* run <01_attrition_table.do> */


*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project Attrition_reminder_enumerator
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd



//--------------------------
// reminder times //
// after triple p change //
//--------------------------

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-03-11", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0
tab 组别
keep 住院号 日期
gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
drop 住院号

drop 日期
tempfile 1m
save `1m'

use "$proc/attritiontoken_1m.dta", clear
keep firstname hospitalID remindercount
rename hospitalID hospital_id
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
merge m:1 hospital_id using `1m'
keep if _merge == 3
drop _merge

tempfile participants
save `participants'


use "$proc/1m_results.dta", clear
duplicates drop firstname, force
merge 1:1 firstname using `participants'
tab remindercount

//------------------------//
// before triple p change //
//------------------------//
/* 
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
// keep if date <= date("2025-01-26", "YMD") 
keep if date < date("2025-01-21", "YMD") 
drop if strpos(备注,"tp课程干预简化Ava测试") > 0
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 

drop 日期
tempfile 1m
save `1m'

use "$proc/attritiontoken_1m.dta", clear
keep firstname hospitalID remindercount
rename hospitalID hospital_id
merge m:1 hospital_id using `1m'
keep if _merge == 3
drop _merge

tempfile participants
save `participants'


import delimited using "$data/results-survey659371.csv", encoding("utf-8") clear
drop if submitdate == ""

keep firstname attribute_1-attribute_10 submitdate


tempfile part1
save `part1'

import delimited using "$data/results-survey826686.csv", encoding("utf-8") clear
drop if submitdate == ""

keep firstname attribute_1-attribute_10 submitdate


tempfile part2
save `part2'

import delimited using "$data/results-survey137936.csv", encoding("utf-8") clear
drop if submitdate == ""

keep firstname attribute_1-attribute_10 submitdate

tempfile part3
save `part3'

import delimited using "$data/results-survey839976.csv", encoding("utf-8") clear
drop if submitdate == ""

keep firstname attribute_1-attribute_10 submitdate

tempfile part4
save `part4'

import delimited using "$data/results-survey757445.csv", encoding("utf-8") clear
drop if submitdate == ""

keep firstname attribute_1-attribute_10 submitdate

tempfile part5
save `part5'

import delimited using "$data/results-survey644261.csv", encoding("utf-8") clear
drop if submitdate == ""

keep firstname attribute_1-attribute_10 submitdate


tempfile part6
save `part6'

import delimited using "$data/results-survey972288.csv", encoding("utf-8") clear
drop if submitdate == ""

keep firstname attribute_1-attribute_10 submitdate


append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force
drop if firstname == .

replace hospital_id = "000" + hospital_id if length(hospital_id) == 6

merge 1:1 firstname using `participants'
tab remindercount

tempfile attrition_1m
save `attrition_1m'

 */




// ----------------------------------------------------------------------------

//-------------------------//
// attrition by enumerator //
//-------------------------//

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-03-11", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0

preserve
keep 母亲电话 母亲姓名 招募人员 组别 date 住院号
rename (母亲电话 母亲姓名)(firstname lastname)
tempfile mother
save `mother'
restore

preserve
keep 父亲电话 父亲姓名 招募人员 组别 date 住院号
rename (父亲电话 父亲姓名)(firstname lastname)
tempfile father
save `father'
restore

use `mother', clear
append using `father', force

format date %td
tab 组别
destring firstname, replace
tempfile 1m 
save `1m' 



use "$proc/1m_results.dta", clear
duplicates drop firstname, force
merge 1:1 firstname using `1m'

drop if _merge == 1
drop _merge

gen treatment = "T0" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

gen month = floor((date - date("2024-09-24", "YMD"))/30) + 1
drop if month == 0
replace month = 5 if month == 6

gen attrition_1m = (submitdate == "")
encode 招募人员, gen(enumerator_num)
encode treatment, gen(treatment_temp)
drop treatment
rename treatment_temp treatment
gen C = (treatment == 1)
gen T1 = (treatment == 2)
gen T2 = (treatment == 3)
gen Treat = (treatment ~= 1)
gen group = 0
replace group = 1 if T1 == 1
replace group = 2 if T2 == 1

capture drop hospital_id
gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
drop 住院号
tempfile temp
save `temp'

use "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/temp2.dta", clear

keep hospitalID bed_in_room cluster_var vip
rename hospitalID hospital_id

merge 1:m hospital_id using `temp'
drop if _merge == 1
drop _merge
save "$proc/tp_comparision_enumerator.dta", replace





use "$proc/tp_comparision_enumerator.dta", clear
// analysis
/* keep if month == 5 */
drop if date > td(11mar2025)
local attrition_1m "attrition_1m"

local row = 0
foreach var of varlist `attrition_1m' {
    
	count
	local N = r(N)
	
	su `var'
	local mean: di %6.3f r(mean)
	local sd: di %6.3f r(sd)
	local sd = trim("`sd'")
	
	// Mean and SD for Control (C)
    su `var' if C == 1
    local mean_c: di %6.3f r(mean)
    local sd_c: di %6.3f r(sd)
	local sd_c = trim("`sd_c'")


    // Mean and SD for T1
    su `var' if T1 == 1
    local mean_t1: di %6.3f r(mean)
    local sd_t1: di %6.3f r(sd)
	local sd_t1 = trim("`sd_t1'")
	
    // Mean and SD for T2
    su `var' if T2 == 1
    local mean_t2: di %6.3f r(mean)
    local sd_t2: di %6.3f r(sd)
	local sd_t2 = trim("`sd_t2'")

	// Mean and SD for Treat
    su `var' if Treat == 1
    local mean_treat: di %6.3f r(mean)
    local sd_treat: di %6.3f r(sd)
	local sd_treat = trim("`sd_treat'")
	
	
    // Regression for T1 vs Control (C)
    preserve
    drop if T2 == 1
    reg `var' T1 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t1c: di %6.3f _b[T1]
    local se_t1c: di %6.3f _se[T1]
	local se_t1c = trim("`se_t1c'")
	
    local pval_t1c = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
    local pval_t1c: di %6.3f `pval_t1c'
	
	local star_t1c ""
    if (`pval_t1c' < 0.1) local star_t1c "*"
    if (`pval_t1c' < 0.05) local star_t1c "**"
    if (`pval_t1c' < 0.01) local star_t1c "***"
    restore

    // Regression for T2 vs Control (C)
    preserve
    drop if T1 == 1
    reg `var' T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t2c: di %6.3f _b[T2]
    local se_t2c: di %6.3f _se[T2]
	local se_t2c = trim("`se_t2c'")

    local pval_t2c = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
    local pval_t2c: di %6.3f `pval_t2c'
	
	local star_t2c ""
    if (`pval_t2c' < 0.1) local star_t2c "*"
    if (`pval_t2c' < 0.05) local star_t2c "**"
    if (`pval_t2c' < 0.01) local star_t2c "***"
	
    restore

    // Regression for T2 vs T1
    preserve
    drop if C == 1
    reg `var' T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t2t1: di %6.3f _b[T2]
    local se_t2t1: di %6.3f _se[T2]
	local se_t2t1 = trim("`se_t2t1'")

    local pval_t2t1 = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
    local pval_t2t1: di %6.3f `pval_t2t1'
	
	local star_t2t1 ""
    if (`pval_t2t1' < 0.1) local star_t2t1 "*"
    if (`pval_t2t1' < 0.05) local star_t2t1 "**"
    if (`pval_t2t1' < 0.01) local star_t2t1 "***"
    restore

	// Regression for Treat vs C
    preserve
    reg `var' Treat i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_treat: di %6.3f _b[Treat]
    local se_treat: di %6.3f _se[Treat]
	local se_treat = trim("`se_treat'")

    local pval_treat = 2 * ttail(e(df_r), abs(_b[Treat] / _se[Treat]))
    local pval_treat: di %6.3f `pval_treat'
	
	local star_treat ""
    if (`pval_treat' < 0.1) local star_treat "*"
    if (`pval_treat' < 0.05) local star_treat "**"
    if (`pval_treat' < 0.01) local star_treat "***"
    restore
	
	
    // Optional: Perform Chi-square test for categorical variables if needed
    // Here, I'll assume you know which variables are categorical
    preserve
    tab `var' group, chi2
    local pval_chi2: di %6.3f r(p)
    restore

    // Increment row counter
    local row = `row' + 1

    // Store the results for this variable
    local mu_row`row' "\textit{ N = `N'} &`mean' & `mean_c' & `mean_t1' & `mean_t2' & `mean_treat' & `diff_t1c'`star_t1c' & `diff_t2c'`star_t2c' & `diff_t2t1'`star_t2t1' & `diff_treat'`star_treat' &  `pval_chi2'"
	
	// Increment row counter
    local row = `row' + 1
	local mu_row`row' " &(`sd') & (`sd_c') & (`sd_t1') & (`sd_t2') & (`sd_treat') & (`se_t1c') & (`se_t2c')  & (`se_t2t1') & (`se_treat') &  "
	
	
}
 
 
// Output results to LaTeX
file open resultsfile using "$results/tables/attrition_5m_enumerator.tex", write replace
local row = 0
foreach var of varlist `attrition_1m' {
    local row = `row' + 1
    file write resultsfile "`mu_row`row'' \\" _n
	local row = `row' + 1
    file write resultsfile "`mu_row`row'' \\" _n
}
file close resultsfile




use "$proc/tp_comparision_enumerator.dta", clear
/* keep if month == 5 */
local varlist enumerator_num
display `varlist'

foreach var in `varlist' {
    
    // Get the levels of the current categorical variable
    levelsof `var', local(var_value)
    
    // Open the output file (append mode)
    file open resultsfile using "$results/tables/attrition_5m_enumerator.tex", write append
    
    // Loop through each level of the current variable
    foreach level of local var_value {
        di "Processing for `var' level: `level'"

        use "$proc/tp_comparision_enumerator.dta", clear
        drop if date > td(11mar2025)
        keep if `var' == `level'  // Keep data for the current level

        count
        local N_`var'`level' = r(N)  // Save the count

        // Output header to LaTeX file
        file write resultsfile "\midrule" _n
        file write resultsfile "\textbf{`var' level `level'}\\" _n
        
        local row = 0
        
        // Calculate and output means and standard deviations
        su attrition_1m
        local mean: di %6.3f r(mean)
        local sd: di %6.3f r(sd)
        
        // Mean and SD for Control (C)
        su attrition_1m if C == 1
        local mean_c: di %6.3f r(mean)
        local sd_c: di %6.3f r(sd)
        
        // Mean and SD for T1
        su attrition_1m if T1 == 1
        local mean_t1: di %6.3f r(mean)
        local sd_t1: di %6.3f r(sd)
        
        // Mean and SD for T2
        su attrition_1m if T2 == 1
        local mean_t2: di %6.3f r(mean)
        local sd_t2: di %6.3f r(sd)
        
        // Mean and SD for Treat
        su attrition_1m if Treat == 1
        local mean_treat: di %6.3f r(mean)
        local sd_treat: di %6.3f r(sd)
        
        // Perform regressions and calculate coefficients, standard errors, p-values, and stars
        preserve
        drop if T2 == 1
        reg attrition_1m T1 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t1c: di %6.3f _b[T1]
        local se_t1c: di %6.3f _se[T1]
        local pval_t1c = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
        local star_t1c ""
        if (`pval_t1c' < 0.1) local star_t1c "*"
        if (`pval_t1c' < 0.05) local star_t1c "**"
        if (`pval_t1c' < 0.01) local star_t1c "***"
        restore

        preserve
        drop if T1 == 1
        reg attrition_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t2c: di %6.3f _b[T2]
        local se_t2c: di %6.3f _se[T2]
        local pval_t2c = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
        local star_t2c ""
        if (`pval_t2c' < 0.1) local star_t2c "*"
        if (`pval_t2c' < 0.05) local star_t2c "**"
        if (`pval_t2c' < 0.01) local star_t2c "***"
        restore

        preserve
        drop if C == 1
        reg attrition_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t2t1: di %6.3f _b[T2]
        local se_t2t1: di %6.3f _se[T2]
        local pval_t2t1 = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
        local star_t2t1 ""
        if (`pval_t2t1' < 0.1) local star_t2t1 "*"
        if (`pval_t2t1' < 0.05) local star_t2t1 "**"
        if (`pval_t2t1' < 0.01) local star_t2t1 "***"
        restore

        preserve
        reg attrition_1m Treat i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_treat: di %6.3f _b[Treat]
        local se_treat: di %6.3f _se[Treat]
        local pval_treat = 2 * ttail(e(df_r), abs(_b[Treat] / _se[Treat]))
        local star_treat ""
        if (`pval_treat' < 0.1) local star_treat "*"
        if (`pval_treat' < 0.05) local star_treat "**"
        if (`pval_treat' < 0.01) local star_treat "***"
        restore

        // Optional Chi-square test
        preserve
        tab attrition_1m group, chi2
        local pval_chi2: di %6.3f r(p)
        restore

        // Prepare the output row
        local row = `row' + 1
        local mu_row`row' "\textit{ N = `N_`var'`level''} & `mean' & `mean_c' & `mean_t1' & `mean_t2' & `mean_treat' & `diff_t1c'`star_t1c' & `diff_t2c'`star_t2c' & `diff_t2t1'`star_t2t1' & `diff_treat'`star_treat' &  `pval_chi2'"

        local row = `row' + 1
        local mu_row`row' " & (`sd') & (`sd_c') & (`sd_t1') & (`sd_t2') & (`sd_treat') & (`se_t1c') & (`se_t2c')  & (`se_t2t1') & (`se_treat') &  "
        // Write the row to the LaTeX file
		
		    local row = 0

        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n
        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n
    
    }

    // Close the output file after finishing
    file close resultsfile
}



**** log ****
log close