** attrition **

** 

** author: Haoyue Wu
** updated on: Jan 20, 2025

** 1m **
// import delimited using "$data/tokens_812586.csv", encoding("UTF-8") clear
// tempfile 1
// save `1'

import delimited using "$data/tokens_659371.csv", encoding("UTF-8") clear
tempfile 4
save `4'

import delimited using "$data/tokens_826686.csv", encoding("UTF-8") clear
tempfile 5
save `5'

import delimited using "$data/tokens_137936.csv", encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_839976.csv", encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_757445.csv", encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_644261.csv", encoding("UTF-8") clear
append using `1' , force
append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force

gen invited_date = date(invited, "YMDhm")
format invited_date %td

gen treatment = "C" if attribute_4控制组 == "Y"
	replace treatment = "T1" if attribute_5t1 == "Y"
	replace treatment = "T2" if attribute_6t2 == "Y"
	
gen parent =  (attribute_7母亲 == "Y")
label define mother 0 "Father" 1 "Mother"
label values parent mother

gen baby_female = 0 if attribute_10男宝宝 == "Y"
	replace baby_female = 1 if attribute_9女宝宝 == "Y"
	
// 	encode baby_gender, gen(temp)
// 	drop baby_gender
// 	rename temp baby_gender
drop if attribute_11住院号 == ""

// ----- attrition analysis -----

gen date_invited = date(invited, "YMDhm")
format date_invited %td
// drop if date_invited < date("2024-11-01", "YMD")
// drop if date_invited == date("2024-11-21", "YMD")
duplicates report attribute_11住院号
drop if firstname == 13616298980 | firstname == 15822222920 | firstname == 18611768884 
drop if firstname == 18580838102

replace completed = "Y" if completed ~= "N"

keep firstname lastname remindercount completed treatment parent baby_female attribute_11住院号 invited_date
gen hospitalID = substr(attribute_11住院号, 4, 6)
drop attribute_11住院号

gen unfinished_1m = remindercount == 5 & completed == "N"

local varlist completed treatment
foreach i in `varlist'{
	encode `i', gen (`i'_temp)
	drop `i'
	rename `i'_temp `i'
}

gen incentive = (invited_date >= date("2024-11-14", "YMD"))
gen T1 = (treatment == 2)
gen T2 = (treatment == 3)
gen C = (treatment == 1)

gen Treat = 1 if T1 == 1 | T2 == 1
replace Treat = 0 if C == 1


gen group = 0
replace group = 1 if T1 == 1
replace group = 2 if T2 == 1

// drop if invited_date == date("2025-1-2", "YMD")

// gen mother_temp = (mother == "妈妈")
// drop mother
// rename mother_temp mother
// rename parent mother
// tostring mother, gen(mother_str)
// gen merge_var = hospitalID + mother_str
// keep merge_var unfinished_1m
save "$proc/attrition_1m.dta", replace
