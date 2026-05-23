// attrition_table

** you need to download ONLY COMPLETE answers from limesurvey

/* run below files first:
	1. attrition_1m.do / attrition_2m.do / attrition_3m.do
	2. contact_list_append.do 
	*/
	

** Haoyue Wu
** Updated on: Mar 24, 2025


//--------------------------------//
// 1m before triple p change ------//
//---------------------------------//

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date < date("2025-01-21", "YMD") & strpos(备注,"tp课程干预简化Ava测试") == 0 // where needing updates each week
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 

drop 日期
tempfile 1m_contact
save `1m_contact'


import delimited using "$data/results-survey659371.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part1
save `part1'

import delimited using "$data/results-survey826686.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey137936.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey839976.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part4
save `part4'

import delimited using "$data/results-survey757445.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part5
save `part5'

import delimited using "$data/results-survey644261.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part6
save `part6'

import delimited using "$data/results-survey972288.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id


append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force

tempfile 1m_survey_finish
save `1m_survey_finish'

merge m:1 hospital_id using `1m_contact'

drop if _merge == 1
drop if attribute_3 == ""
drop _merge
gen completed = "Y"
// gen date = date(substr(submitdate, 1, 10), "YMD")
// format date %td

// gen hour = real(substr(submitdate, 12, 2))
// gen minute = real(substr(submitdate, 15, 2)) 
// gen second = real(substr(submitdate, 18, 2))

gen merge_var = hospital_id + "F" if attribute_8 == "Y"
replace merge_var = hospital_id + "M" if attribute_7 == "Y"
tempfile 1m_attrition
save `1m_attrition'

use "$proc/attritiontoken_1m.dta", clear
gen merge_var = hospital_id + parent
keep hospital_id date_invited merge_var
rename hospital_id hospital_id

merge m:1 hospital_id using `1m_contact'
keep if _merge == 3
drop _merge 

merge 1:1 merge_var using `1m_attrition'


replace date_invited = date("2025-1-2", "YMD") if date_invited == date("2024-12-31", "YMD")
replace date_invited = date("2024-12-5", "YMD")  if date_invited == date("2024-12-07", "YMD")

save "$proc/attrition_1m.dta", replace

local N = 1196
local C = 399
local T1 = 411
local T2 = 386

local Ni = 2*`N'
local Ci = 2*`C'
local T1i = 2*`T1'
local T2i = 2*`T2'

preserve
keep if completed == "Y"
tab hospital_id

local m1_individual = r(N)
display `m1_individual'

tab attribute_7
local m1_mother = r(N)

tab attribute_8
local m1_father = r(N)

duplicates report hospital_id
local m1_both = r(N)-r(unique_value)
local m1_either = r(unique_value)
restore

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
	
file open resultsfile using "$results/tables/attrition_table_1m.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{1m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{1m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{1m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{1m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile



//--------------------------------//
// 1m after triple p change ------//
//--------------------------------//

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-03-11", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

drop 日期
tempfile 1m
save `1m'


//------- see if changing the reminder interval affects attrition

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-03-11", "YMD") // where needing updates each week
keep if date >= date("2025-02-19", "YMD") 
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

drop 日期
tempfile 1m
save `1m'


use "$proc/1m_results.dta", clear

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

merge m:1 hospital_id using `1m'

drop if _merge == 1
drop if attribute_3 == ""


//
local N = 133
local C = 43
local T1 = 44
local T2 = 46

local Ni = 2*`N'
local Ci = 2*`C'
local T1i = 2*`T1'
local T2i = 2*`T2'

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
	
file open resultsfile using "$results/tables/attrition_table_1m_2weeks.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{1m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{1m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{1m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{1m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile



// --------------------------------- //
// --------- 2m attrition ---------- //
// -------------------------------- //


use "$proc/contact_list.dta", clear

gen date = ///
	cond(strpos(日期, "年") > 0, date(日期, "YMD"), ///
	cond(strpos(日期, "/") > 0, date(日期, "MDY"), ///
	date(日期, "DMY")))
	
keep if date <= date("2025-01-26", "YMD") // where needing updates each week
tab 组别
rename 住院号 hospital_id 
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop 日期

gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

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
destring firstname, replace
tempfile participants
save `participants'

use "$proc/2m_results.dta", clear
duplicates drop firstname, force
keep firstname lastname 

merge 1:1 firstname using `participants'

drop if _merge == 1
gen completed = "Y" if _merge == 3
drop _merge

replace treatment = "T2" if firstname == 13012837789

gen attribute_7 = "Y" if parent == "M" & completed == "Y"
gen attribute_8 = "Y" if parent == "F" & completed == "Y"
gen attribute_4 = "Y" if treatment == "C" & completed == "Y"
gen attribute_5 = "Y" if treatment == "T1" & completed == "Y"
gen attribute_6 = "Y" if treatment == "T2" & completed == "Y"
save "$proc/attrition_2m.dta", replace

//
local N = 1261
local C = 420
local T1 = 436
local T2 = 405

local Ni = 2*`N'
local Ci = 2*`C'
local T1i = 2*`T1'
local T2i = 2*`T2'


preserve
keep if completed == "Y"
tab hospital_id

local m1_individual = r(N)
display `m1_individual'

tab attribute_7
local m1_mother = r(N)

tab attribute_8
local m1_father = r(N)

duplicates report hospital_id
local m1_both = r(N)-r(unique_value)
local m1_either = r(unique_value)
restore

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
	
file open resultsfile using "$results/tables/attrition_table_2m.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{2m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{2m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{2m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{2m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile




// 2m attrition
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-01-12", "YMD") // where needing updates each week
keep if date >= date("2024-12-29", "YMD")
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 
drop 日期


tempfile 2m
save `2m'

import delimited using "$data/results-survey643199.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11
rename attribute_11 hospital_id

tempfile part1
save `part1'


import delimited using "$data/results-survey714695.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11
rename attribute_11 hospital_id

tempfile part2
save `part2'


import delimited using "$data/results-survey795738.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11
rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey448999.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11
rename attribute_11 hospital_id

append using `part1'
append using `part2'
append using `part3'

merge m:1 hospital_id using `2m'

drop if _merge == 1
drop if attribute_3 == ""

//
local N = 130
local C = 47
local T1 = 39
local T2 = 44

local Ni = 2*`N'
local Ci = 2*`C'
local T1i = 2*`T1'
local T2i = 2*`T2'

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
	
file open resultsfile using "$results/tables/attrition_table_2m_2weeks.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{2m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{2m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{2m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{2m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile



// 3m
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2024-12-29", "YMD") // where needing updates each week
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 
drop 日期
tempfile 3m_contact
save `3m_contact'

use "$proc/3m_results.dta", clear

merge m:1 hospital_id using `3m_contact'

drop if _merge == 1
drop if attribute_3 == ""
drop _merge

gen completed = "Y"

gen merge_var = hospital_id + "F" if attribute_8 == "Y"
replace merge_var = hospital_id + "M" if attribute_7 == "Y"
tempfile 3m_attrition
save `3m_attrition'

use "$proc/attritiontoken_3m.dta", clear
gen merge_var = hospital_id + parent
keep hospital_id date_invited merge_var
rename hospital_id hospital_id

merge m:1 hospital_id using `3m_contact'
keep if _merge == 3
drop _merge 

merge 1:1 merge_var using `3m_attrition'


replace date_invited = date("2025-1-2", "YMD") if date_invited == date("2024-12-31", "YMD")
replace date_invited = date("2024-12-5", "YMD")  if date_invited == date("2024-12-07", "YMD")


local N = 1004
local C = 328
local T1 = 351
local T2 = 325

local Ni = 2*`N'
local Ci = 2*`C'
local T1i = 2*`T1'
local T2i = 2*`T2'


preserve
keep if completed == "Y"
tab hospital_id

local m1_individual = r(N)
display `m1_individual'

tab attribute_7
local m1_mother = r(N)

tab attribute_8
local m1_father = r(N)

duplicates report hospital_id
local m1_both = r(N)-r(unique_value)
local m1_either = r(unique_value)
restore

preserve
keep if attribute_4 == "Y"

tab hospital_id
local C_individual = r(N)

tab attribute_7
local C_mother = r(N)

tab attribute_8
local C_father = r(N)

keep if completed == "Y"
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
	
file open resultsfile using "$results/tables/attrition_table_3m.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{3m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{3m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{3m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{3m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile


// 3m attrition
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2024-12-08", "YMD") // where needing updates each week
keep if date >= date("2024-11-26", "YMD")
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 
drop 日期


tempfile 3m
save `3m'



import delimited using "$data/results-survey573762.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part1
save `part1'

import delimited using "$data/results-survey917974.csv", encoding("utf-8") clear
drop if submitdate == ""

keep attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id


append using `part1', force



merge m:1 hospital_id using `3m'

drop if _merge == 1
drop if attribute_3 == ""

//
local N = 144
local C = 52
local T1 = 43
local T2 = 49

local Ni = 2*`N'
local Ci = 2*`C'
local T1i = 2*`T1'
local T2i = 2*`T2'

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
	
file open resultsfile using "$results/tables/attrition_table_3m_2weeks.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{3m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{3m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{3m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{3m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile


log close