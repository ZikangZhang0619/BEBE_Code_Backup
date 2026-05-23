////////////////////////////////--------------------------

/* Attrition Analysis of 6w face-to-face survey


The goal of the analysis is to check balanceness across treatment arms.



    6w survey id:
    191613
    815998
    184411
    265968


AUTHOR: Haoyue Wu
Updated on: 23Apr 2025

*/

*************** LOG *****************
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 6w_attrition
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd



///////////////////////////////////////////////////////
//// 1. Data Aggregation and Cleaning /////////////////
///////////////////////////////////////////////////////


// (1) completed 6w survey data
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


append using `1', force
append using `2', force
append using `3', force
drop if submitdate == ""
replace g00q02 = "爸爸" in 104

keep submitdate mname fname mphone fphone g00q01sq001 g00q02

rename g00q01sq001 hospital_id
tostring hospital_id, replace
rename g00q02 parent

tempfile 42d_participants
save `42d_participants'


// (2) appointment list
import excel using "$data/6w_appointment_list.xlsx", firstrow clear

keep 住院号 姓名 父母是否同行 父母是否完成 未做问卷原因

rename 住院号 hospital_id
rename 姓名 name
rename 父母是否同行 complete1
rename 父母是否完成 complete2
rename 未做问卷原因 reason

drop if reason == "取消"
drop if reason == "错失"

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

tempfile appointment_list
save `appointment_list'


///////////////////////////////////////////////////////////////
///////////////////// 2. merge dataset ////////////////////////
///////////////////////////////////////////////////////////////


// (1) merge treatment arm of participants who completed 6w in hospital
use "$proc/contact_list.dta", clear

gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
rename 组别 treatment

keep hospital_id treatment


merge 1:m hospital_id using `42d_participants'
keep if _merge == 3
drop _merge

replace treatment = "Control" if treatment == "1"
replace treatment = "T1" if treatment == "2"
replace treatment = "T2" if treatment == "3"

preserve
keep if parent == "妈妈"
keep treatment hospital_id mname mphone parent submitdate
rename (mname mphone) (lastname firstname)
tempfile 42d_mother
save `42d_mother'
restore

keep if parent == "爸爸"
keep treatment hospital_id fname fphone parent submitdate
rename (fname fphone) (lastname firstname)
append using `42d_mother', force

gen completed = 1

drop if submitdate == ""
save "$proc/6w_completed.dta", replace


// (2) merge treatment arm of participants in the appointment list

use "$proc/contact_list.dta", clear
gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
rename 组别 treatment
keep hospital_id treatment 母亲姓名 母亲电话 父亲姓名 父亲电话 日期
rename (母亲姓名 母亲电话 父亲姓名 父亲电话) (mname mphone fname fphone)
rename 日期 recruitmentdate

merge 1:m hospital_id using `appointment_list'
keep if _merge == 3
drop _merge
replace treatment = "Control" if treatment == "1"
replace treatment = "T1" if treatment == "2"
replace treatment = "T2" if treatment == "3"

drop name 

preserve 
keep treatment hospital_id mname mphone complete1 complete2 reason recruitmentdate
rename (mname mphone) (lastname firstname)
gen parent = "妈妈"
tempfile appointment_mother
save `appointment_mother'
restore

keep treatment hospital_id fname fphone complete1 complete2 reason recruitmentdate
rename (fname fphone) (lastname firstname)
gen parent = "爸爸"
append using `appointment_mother', force


// (3) merge completed 6w and appointment list
merge 1:1 hospital_id parent using "$proc/6w_completed.dta"
drop _merge 
save "$proc/6w_complete_onsite.dta", replace



// (4) merge online completed

import delimited using "$data/results-survey162992.csv", stringcols(_all) encoding("utf-8") clear
tempfile 1
save `1'

import delimited using "$data/results-survey753661.csv", stringcols(_all) encoding("utf-8") clear
tempfile 2
save `2'

import delimited using "$data/results-survey448999.csv", stringcols(_all) encoding("utf-8") clear
append using `1', force
append using `2', force

drop if submitdate == ""
keep firstname lastname submitdate
rename submitdate submitdate1
gen completed1 = 1
gen online = 1

duplicates drop firstname, force

merge 1:1 firstname using "$proc/6w_complete_onsite.dta"
drop if _merge == 1
drop _merge

replace completed = 1 if completed1 == 1
replace submitdate = submitdate1 if submitdate == "" 
drop completed1 submitdate1

save "$proc/6w_complete_all.dta", replace



// (4) merge online completed
/* 
import delimited using "$data/tokens_162992.csv", stringcols(_all) encoding("utf-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_753661.csv", stringcols(_all) encoding("utf-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_448999.csv", stringcols(_all) encoding("utf-8") clear
append using `1', force
append using `2', force

rename completed completed_temp
gen completed_online = (completed_temp ~= "N")
drop completed_temp
duplicates drop firstname, force

keep firstname lastname completed_online attribute_4控制组 attribute_5t1 attribute_6t2 ///
attribute_7母亲 attribute_8父亲 attribute_9女宝宝 attribute_10男宝宝 attribute_11住院号

merge 1:1 firstname using "$proc/6w_complete_onsite.dta"
rename completed completed_onsite
gen completed = 1 if completed_onsite == 1 | completed_online == 1
drop if _merge == 1
drop _merge

save "$proc/6w_complete_all.dta", replace */

//////////////////////////////////////////////////////////////////////////////
///////////////// 3. Attrition Analysis of 6w face-to-face survey ////////////
//////////////////////////////////////////////////////////////////////////////

use "$proc/6w_complete_all.dta", clear

tab treatment

local Ni = 284
local Ci = 102
local T1i = 90
local T2i = 92

local N = `Ni'/2
local C = `Ci'/2
local T1 = `T1i'/2
local T2 = `T2i'/2

drop if completed == .

gen attribute_7 = "Y" if parent == "妈妈"
gen attribute_8 = "Y" if parent == "爸爸"
gen attribute_4 = "Y" if treatment == "Control"
gen attribute_5 = "Y" if treatment == "T1"
gen attribute_6 = "Y" if treatment == "T2"

tab hospital_id
local m1_individual = r(N)

tab attribute_7
local m1_mother = r(N)

tab attribute_8
local m1_father = r(N)

duplicates report hospital_id
local m1_both = r(N)-r(unique_value)
local m1_either = r(unique_value)

preserve
keep if attribute_4 == "Y"

tab hospital_id
local C_individual = r(N)

tab attribute_7
local C_mother = r(N)

tab attribute_8
local C_father = r(N)

duplicates report hospital_id
local C_both = r(N)-r(unique_value)
local C_either = r(unique_value)
restore

preserve
keep if attribute_5 == "Y"

tab hospital_id
local T1_individual = r(N)

tab attribute_7
local T1_mother = r(N)

tab attribute_8
local T1_father = r(N)

duplicates report hospital_id
local T1_both = r(N)-r(unique_value)
local T1_either = r(unique_value)
restore

preserve
keep if attribute_6 == "Y"

tab hospital_id
local T2_individual = r(N)

tab attribute_7
local T2_mother = r(N)

tab attribute_8
local T2_father = r(N)

duplicates report hospital_id
local T2_both = r(N)-r(unique_value)
local T2_either = r(unique_value)
restore

local m1_prec1 = `m1_individual'/`Ni'
	local m1_prec1: di %6.3f `m1_prec1'
local m1_prec2 = `m1_mother'/`N'
	local m1_prec2: di %6.3f `m1_prec2'
local m1_prec3 = `m1_father'/`N'
	local m1_prec3: di %6.3f `m1_prec3'
local m1_prec4 = `m1_both'/`N'
	local m1_prec4: di %6.3f `m1_prec4'
local m1_prec5 = `m1_either'/`N'
	local m1_prec5: di %6.3f `m1_prec5'

local C_prec1 = `C_individual'/`Ci'
	local C_prec1: di %6.3f `C_prec1'
local C_prec2 = `C_mother'/`C'
	local C_prec2: di %6.3f `C_prec2'
local C_prec3 = `C_father'/`C'
	local C_prec3: di %6.3f `C_prec3'
local C_prec4 = `C_both'/`C'
	local C_prec4: di %6.3f `C_prec4'
local C_prec5 = `C_either'/`C'
	local C_prec5: di %6.3f `C_prec5'

local T1_prec1 = `T1_individual'/`T1i'
	local T1_prec1: di %6.3f `T1_prec1'
local T1_prec2 = `T1_mother'/`T1'
	local T1_prec2: di %6.3f `T1_prec2'
local T1_prec3 = `T1_father'/`T1'
	local T1_prec3: di %6.3f `T1_prec3'
local T1_prec4 = `T1_both'/`T1'
	local T1_prec4: di %6.3f `T1_prec4'
local T1_prec5 = `T1_either'/`T1'
	local T1_prec5: di %6.3f `T1_prec5'

local T2_prec1 = `T2_individual'/`T2i'
	local T2_prec1: di %6.3f `T2_prec1'
local T2_prec2 = `T2_mother'/`T2'
	local T2_prec2: di %6.3f `T2_prec2'
local T2_prec3 = `T2_father'/`T2'
	local T2_prec3: di %6.3f `T2_prec3'
local T2_prec4 = `T2_both'/`T2'
	local T2_prec4: di %6.3f `T2_prec4'
local T2_prec5 = `T2_either'/`T2'
	local T2_prec5: di %6.3f `T2_prec5'
	
file open resultsfile using "$results/tables/attrition_table_6w.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{1m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{1m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{1m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{1m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile





use "$proc/6w_complete.dta", clear



/////////////////////////////////////////////////////////////////////
//////////////// 4. Interval Between Survey and recruitment /////////
/////////////////////////////////////////////////////////////////////


// (1) Export histogram data for 6w survey interval
use "$proc/6w_complete.dta", clear
gen recruitment_date = ///
	cond(strpos(recruitmentdate, "年") > 0, date(recruitmentdate, "YMD"), ///
	cond(strpos(recruitmentdate, "/") > 0, date(recruitmentdate, "MDY"), ///
	date(recruitmentdate, "DMY")))
drop recruitmentdate
format recruitment_date %td
rename submitdate survey_date
gen submitdate_str = substr(survey_date, 1, 10)
gen submitdate = date(submitdate_str, "YMD")
format submitdate %td
gen interval_6w = submitdate - recruitment_date
drop if interval_6w < 0
gen source = "6w"
keep interval_6w source
rename interval_6w interval
tempfile data_6w
save `data_6w'

// (2) Export histogram data for 1m survey interval
use "$proc/contact_list.dta", clear
gen recruitment_date = date(日期, "YMD") if strpos(日期, "年") > 0
replace recruitment_date = date(日期, "MDY") if strpos(日期, "/") > 0
replace recruitment_date = date(日期, "DMY") if recruitment_date == .
format recruitment_date %td
keep if recruitment_date <= date("2025-03-18", "YMD") 
keep if recruitment_date >= date("2025-02-19", "YMD") 
rename 住院号 hospital_id 
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop 日期
keep 母亲姓名 母亲电话 父亲姓名 父亲电话 recruitment_date hospital_id
tempfile complete
save `complete'
keep 母亲姓名 母亲电话 hospital_id recruitment_date
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'
use `complete'
keep 父亲姓名 父亲电话 hospital_id recruitment_date
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'
append using `mother'
order firstname lastname
destring firstname, replace
tempfile participants
save `participants'
use "$proc/1m_results.dta", clear
duplicates drop firstname, force
keep firstname lastname submitdate
merge 1:1 firstname using `participants'
drop if _merge == 1
gen completed = "Y" if _merge == 3
drop _merge
rename submitdate survey_date
gen submitdate_str = substr(survey_date, 1, 10)
gen submitdate = date(submitdate_str, "YMD")
format submitdate %td
gen interval_1m = submitdate - recruitment_date
drop if interval_1m < 0
gen source = "1m"
keep interval_1m source
rename interval_1m interval
tempfile data_1m
save `data_1m'

// (3) Export histogram data for 2m survey interval
use "$proc/contact_list.dta", clear
gen recruitment_date = date(日期, "YMD") if strpos(日期, "年") > 0
replace recruitment_date = date(日期, "MDY") if strpos(日期, "/") > 0
replace recruitment_date = date(日期, "DMY") if recruitment_date == .
format recruitment_date %td
keep if recruitment_date <= date("2025-02-03", "YMD")
rename 住院号 hospital_id 
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop 日期
keep 母亲姓名 母亲电话 父亲姓名 父亲电话 recruitment_date hospital_id
tempfile complete
save `complete'
keep 母亲姓名 母亲电话 hospital_id recruitment_date
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'
use `complete'
keep 父亲姓名 父亲电话 hospital_id recruitment_date
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'
append using `mother'
order firstname lastname
destring firstname, replace
tempfile participants
save `participants'
use "$proc/2m_results.dta", clear
duplicates drop firstname, force
keep firstname lastname submitdate
merge 1:1 firstname using `participants'
drop if _merge == 1
gen completed = "Y" if _merge == 3
drop _merge
rename submitdate survey_date
gen submitdate_str = substr(survey_date, 1, 10)
gen submitdate = date(submitdate_str, "YMD")
format submitdate %td
gen interval_2m = submitdate - recruitment_date
drop if interval_2m < 0
gen source = "2m"
keep interval_2m source
rename interval_2m interval
tempfile data_2m
save `data_2m'

// Combine all datasets
use `data_6w', clear
append using `data_1m'
append using `data_2m'

// Generate overlaid histogram
twoway (histogram interval if source == "6w", percent lcolor(blue%50) fcolor(blue%30) lwidth(medium) width(0.999)) ///
	   (histogram interval if source == "1m", percent lcolor(red%50) fcolor(red%30) lwidth(medium)  width(0.999)) ///
	   (histogram interval if source == "2m", percent lcolor(green%50) fcolor(green%30) lwidth(medium) width(0.999)), ///
	   legend(order(1 "6w" 2 "1m" 3 "2m")) ///
	   title("Comparison of Interval Distributions", size(medium)) ///
	   xlabel(20(5)100, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) /// ///
	   ylabel(, grid) ///
	   xtitle("Interval", size(small)) ///
	   ytitle("Percent", size(small))

graph export "$results/figures/interval_comparison.pdf", replace
// Generate LaTeX table based on summary statistics
preserve
keep if source == "6w"
sum interval, detail
local mean_6w = r(mean)
local median_6w = r(p50)
local min_6w = r(min)
local max_6w = r(max)
local obs_6w = r(N)
restore

preserve
keep if source == "1m"
sum interval, detail
local mean_1m = r(mean)
local median_1m = r(p50)
local min_1m = r(min)
local max_1m = r(max)
local obs_1m = r(N)
restore

preserve
keep if source == "2m"
sum interval, detail
local mean_2m = r(mean)
local median_2m = r(p50)
local min_2m = r(min)
local max_2m = r(max)
local obs_2m = r(N)
restore

// Write LaTeX table
file open tablefile using "$results/tables/interval_summary.tex", write replace
file write tablefile "\begin{table}[h!]" _n
file write tablefile "\centering" _n
file write tablefile "\resizebox{\textwidth}{!}{" _n
file write tablefile "\begin{tabular}{lccccc}" _n
file write tablefile "\hline" _n
file write tablefile "Variable & Mean & Median & Minimum & Maximum & Observations \\\\" _n
file write tablefile "\hline" _n
file write tablefile "6w Survey Interval & `mean_6w' & `median_6w' & `min_6w' & `max_6w' & `obs_6w' \\\\" _n
file write tablefile "1m Survey Interval & `mean_1m' & `median_1m' & `min_1m' & `max_1m' & `obs_1m' \\\\" _n
file write tablefile "2m Survey Interval & `mean_2m' & `median_2m' & `min_2m' & `max_2m' & `obs_2m' \\\\" _n
file write tablefile "\hline" _n
file write tablefile "\end{tabular}}" _n
file write tablefile "\begin{tablenotes}" _n
file write tablefile "\small" _n
file write tablefile "\item[a] \textit{The analysis of the 1m survey data encompasses exclusively those participants who had their reminder frequency adjusted to a 2-day interval, whereas participants in the 2m survey maintained the standard 3-day reminder schedule.}" _n
file write tablefile "\end{tablenotes}" _n
file write tablefile "\end{table}" _n
file close tablefile


**************** END OF LOG *****************
log close