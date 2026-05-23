


////////////////////////////////////////////////////////
************************** 1m **************************
////////////////////////////////////////////////////////

// ------------------- //
// 1m complete results //
// ------------------- //


import delimited using "$data/results-survey659371.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part1
save `part1'

import delimited using "$data/results-survey826686.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part2
save `part2'

import delimited using "$data/results-survey137936.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""
tempfile part3
save `part3'

import delimited using "$data/results-survey839976.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part4
save `part4'

import delimited using "$data/results-survey757445.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part5
save `part5'

import delimited using "$data/results-survey644261.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part6
save `part6'

import delimited using "$data/results-survey972288.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part7
save `part7'

import delimited using "$data/results-survey716853.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part8
save `part8'

import delimited using "$data/results-survey563862.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part9
save `part9'

import delimited using "$data/results-survey477485.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part10
save `part10'

import delimited using "$data/results-survey727311.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part11
save `part11'

import delimited using "$data/results-survey492913.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""


append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force
append using `part7', force
append using `part8', force
append using `part9', force
append using `part10', force
append using `part11', force

keep firstname lastname attribute_1-attribute_11 submitdate suggestion
rename attribute_11 hospital_id

keep if suggestion ~= ""

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if firstname == ""

duplicates report firstname
duplicates drop firstname, force

gen mother = "母亲" if attribute_7 == "Y"
replace mother = "父亲" if attribute_8 == "Y"
gen group = "Control" if attribute_4 == "Y"
replace group = "T1" if attribute_5 == "Y"
replace group = "T2" if attribute_6 == "Y"
drop if suggestion == "无"
drop if suggestion == "没有"
drop if suggestion == "暂无"
drop if strpos(suggestion, "无")>0

keep submitdate suggestion mother group 
gen month = "1m"
sort submitdate

export excel using "$results/1m_suggestions.xlsx", firstrow(variables) replace





/////////////////////////////////////////////////////////////////////////
************************************* 2m ********************************
/////////////////////////////////////////////////////////////////////////


// ------------------- //
// 2m complete results //
// ------------------- //

import delimited using "$data/results-survey643199.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part1
save `part1'


import delimited using "$data/results-survey714695.csv",stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part2
save `part2'

import delimited using "$data/results-survey795738.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part3
save `part3'

import delimited using "$data/results-survey448999.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part4
save `part4'

import delimited using "$data/results-survey162992.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part5
save `part5'

import delimited using "$data/results-survey753661.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part6 
save `part6'

import delimited using "$data/results-survey669218.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force 

keep if suggestion ~= ""

keep firstname lastname attribute_1-attribute_11 submitdate suggestion
rename attribute_11 hospital_id

keep if suggestion ~= ""

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if firstname == ""

duplicates report firstname
duplicates drop firstname, force

gen mother = "母亲" if attribute_7 == "Y"
replace mother = "父亲" if attribute_8 == "Y"
gen group = "Control" if attribute_4 == "Y"
replace group = "T1" if attribute_5 == "Y"
replace group = "T2" if attribute_6 == "Y"
drop if suggestion == "无"
drop if suggestion == "没有"
drop if suggestion == "暂无"
drop if strpos(suggestion, "无")>0
keep suggestion mother group  submitdate

gen month = "2m"
sort submitdate
export excel using "$results/2m_suggestions.xlsx", firstrow(variables) replace

/* 
//------------------ 6w ------------------//

import delimited using "$data/results-survey184411.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 suggestion
rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_1
save `6w_1'

import delimited using "$data/results-survey191613.csv",stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 suggestion
rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_2
save `6w_2'

import delimited using "$data/results-survey815998.csv",stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 suggestion
rename g00q01sq001 hospital_id

tempfile 6w_3
save `6w_3'

import delimited using "$data/results-survey265968.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 suggestion
rename g00q01sq001 hospital_id
tempfile 6w_4
save `6w_4'

import delimited using "$data/results-survey924349.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 suggestion
rename g00q01sq001 hospital_id

rename g00q02 parent
append using `6w_1'
append using `6w_2'
append using `6w_3'
append using `6w_4'
replace parent = g00q02 if parent == ""
keep if suggestion != ""

preserve
keep if parent == "爸爸"
keep fname fphone parent hospital_id suggestion
rename (fphone fname)(firstname lastname)
tempfile father 
save `father'
restore

keep if parent == "妈妈"
keep mname mphone parent hospital_id suggestion
rename (mphone mname)(firstname lastname)
append using `father'

tostring hospital_id, replace



replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

drop if firstname == ""
duplicates drop firstname, force
keep if suggestion ~= ""


duplicates report firstname
duplicates drop firstname, force

rename parent mother
gen group = "Control" if attribute_4 == "Y"
replace group = "T1" if attribute_5 == "Y"
replace group = "T2" if attribute_6 == "Y"
drop if suggestion == "无"
drop if suggestion == "没有"
drop if suggestion == "暂无"
drop if strpos(suggestion, "无")>0
keep suggestion mother group 

export excel using "$results/2m_suggestions.xlsx", firstrow(variables) replace */






/////////////////////////////////////////////////////////////////////////
************************************* 3m ********************************
/////////////////////////////////////////////////////////////////////////


// --------- //
// 3m tokens //
// --------- //

/* 

import delimited using "$data/tokens_573762.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_917974.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_567772.csv", stringcol(_all) encoding("UTF-8") clear
append using `2' , force
append using `1' , force

gen treatment = "C" if attribute_4控制组 == "Y"
	replace treatment = "T1" if attribute_5t1 == "Y"
	replace treatment = "T2" if attribute_6t2 == "Y"
gen parent = "F" if attribute_8父亲 == "Y"
	replace parent = "M" if attribute_7母亲 == "Y"
gen baby_gender = "Boy" if attribute_10男宝宝 == "Y"
	replace baby_gender = "Girl" if attribute_9女宝宝 == "Y"
drop if attribute_11住院号 == ""

// ----- attrition analysis -----

gen date_invited = date(invited, "YMDhm")
format date_invited %td
duplicates report attribute_11住院号
duplicates tag attribute_11住院号, gen(tag)
br if tag == 2 
sort date_invited
drop if firstname == "13616298980" | firstname == "15822222920" | firstname == "18611768884" 
drop tag
replace firstname = "15277315277" if lastname == "陶慧梅"


duplicates report firstname
duplicates tag firstname, gen(tag)
br if tag == 1

drop tag
duplicates tag attribute_11住院号, gen(tag)


rename attribute_11住院号 hospital_id
replace completed = "Y" if completed ~= "N"
keep firstname lastname completed remindercount treatment parent baby_gender date_invited hospital_id
drop if firstname == "18580838102"

gen attrition = (completed == "Y")


replace hospital_id = "D00393844" if hospital_id == "D00293844"
save "$proc/attritiontoken_3m.dta", replace


 */


// ------------------- //
// 3m complete results //
// ------------------- //



import delimited using "$data/results-survey573762.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part1
save `part1'

import delimited using "$data/results-survey917974.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

tempfile part2
save `part2'

import delimited using "$data/results-survey567772.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""
rename g19q00001 suggestion
tempfile part3
save `part3'

import delimited using "$data/results-survey291237.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""
rename g19q00001 suggestion

append using `part1', force
append using `part2', force
append using `part3', force

duplicates drop firstname, force


keep if suggestion ~= ""

keep firstname lastname attribute_1-attribute_11 submitdate suggestion
rename attribute_11 hospital_id

keep if suggestion ~= ""

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if firstname == ""

duplicates report firstname
duplicates drop firstname, force

gen mother = "母亲" if attribute_7 == "Y"
replace mother = "父亲" if attribute_8 == "Y"
gen group = "Control" if attribute_4 == "Y"
replace group = "T1" if attribute_5 == "Y"
replace group = "T2" if attribute_6 == "Y"
drop if suggestion == "无"
drop if suggestion == "没有"
drop if suggestion == "暂无"
drop if strpos(suggestion, "无")>0
keep suggestion mother group submitdate
sort submitdate

gen month = "3m"
order submitdate suggestion firt
export excel using "$results/3m_suggestions.xlsx", firstrow(variables) replace







/////////////////////////////////////////////////////////////////////////
************************************* 6m ********************************
/////////////////////////////////////////////////////////////////////////


// --------- //
// 6m tokens //
// --------- //
/* 

import delimited using "$data/tokens_975966.csv", stringcol(_all) encoding("UTF-8") clear



gen treatment = "C" if attribute_4控制组 == "Y"
	replace treatment = "T1" if attribute_5t1 == "Y"
	replace treatment = "T2" if attribute_6t2 == "Y"
gen parent = "F" if attribute_8父亲 == "Y"
	replace parent = "M" if attribute_7母亲 == "Y"
gen baby_gender = "Boy" if attribute_10男宝宝 == "Y"
	replace baby_gender = "Girl" if attribute_9女宝宝 == "Y"
drop if attribute_11住院号 == ""

gen date_invited = date(invited, "YMDhm")
format date_invited %td

duplicates report attribute_11住院号
duplicates tag attribute_11住院号, gen(tag)
br if tag == 2 
sort date_invited
drop tag


duplicates report firstname
duplicates tag firstname, gen(tag)
br if tag == 1

drop tag
duplicates tag attribute_11住院号, gen(tag)


rename attribute_11住院号 hospital_id
replace completed = "Y" if completed ~= "N"
keep firstname lastname completed remindercount treatment parent baby_gender date_invited hospital_id

gen attrition = (completed == "Y")
save "$proc/attritiontoken_6m.dta", replace */



// ------------------- //
// 6m complete results //
// ------------------- //


import delimited using "$data/results-survey975966.csv", stringcol(_all) encoding("UTF-8") clear

tempfile part1
save `part1'



import delimited using "$data/results-survey721796.csv",stringcol(_all) encoding("UTF-8") clear

tempfile part2
save `part2'

import delimited using "$data/results-survey948966.csv", stringcol(_all) encoding("UTF-8") clear



append using `part1', force
append using `part2', force


drop if submitdate == ""
rename attribute_11 hospital_id


duplicates drop firstname, force



keep if suggestion ~= ""

keep firstname lastname attribute_1-attribute_10 suggestion submitdate

drop if firstname == ""

duplicates report firstname
duplicates drop firstname, force

gen mother = "母亲" if attribute_7 == "Y"
replace mother = "父亲" if attribute_8 == "Y"
gen group = "Control" if attribute_4 == "Y"
replace group = "T1" if attribute_5 == "Y"
replace group = "T2" if attribute_6 == "Y"
drop if suggestion == "无"
drop if suggestion == "没有"
drop if suggestion == "暂无"
drop if strpos(suggestion, "无")>0
drop if strpos(suggestion, "没有")>0
keep suggestion mother group submitdate
sort submitdate

gen month = "6m"

export excel using "$results/6m_suggestions.xlsx", firstrow(variables) replace



"





************************ log close ************************
log close
