
*****************************
/* Attrition Analysis 
   
   ** This script is for aggregating and cleaning the data for 1m, 2m, 3m, and 6m survey

   ** Author: Haoyue Wu
   ** Date: 2025-04-17
   ** Updated: 2025-09-01
   */


************* log *************
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project attrition_data_prepare
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
/* pwd */


////////////////////////////////////////////////////////
************************** 1m **************************
////////////////////////////////////////////////////////

// --------- //
// 1m tokens //
// --------- //

/* 
import delimited using "$data/tokens_659371.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_826686.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_137936.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 4
save `4'

import delimited using "$data/tokens_839976.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 5
save `5'

import delimited using "$data/tokens_757445.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 6
save `6'

import delimited using "$data/tokens_644261.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 7
save `7'

import delimited using "$data/tokens_972288.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 8
save `8'

import delimited using "$data/tokens_563862.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 9
save `9'

import delimited using "$data/tokens_716853.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 10
save `10'

import delimited using "$data/tokens_477485.csv", stringcol(_all) encoding("UTF-8") clear

append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force
append using `6' , force
append using `7' , force
append using `8' , force
append using `9' , force
append using `10' , force

// clean
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


// deal with errouneous data
duplicates report attribute_11住院号
duplicates tag attribute_11住院号, gen(tag)
br if tag == 2 
sort date_invited
drop if inlist(firstname, "13616298980", "15822222920", "18611768884") 
drop if firstname == "18580838102"
drop tag
replace firstname = "15277315277" if lastname == "陶慧梅"

duplicates report firstname
duplicates tag firstname, gen(tag)
br if tag == 1

drop tag
duplicates tag attribute_11住院号, gen(tag)

rename attribute_11住院号 hospitalID
replace completed = "Y" if completed ~= "N"
keep firstname lastname completed remindercount treatment parent baby_gender date_invited hospitalID

gen attrition = (completed == "Y")

replace firstname = "13916089297" if firstname == "13016089297"
replace firstname = "13917910114" if firstname == "13917910144"
replace firstname = "18281001022" if firstname == "18285111022"
replace firstname = "19916793841" if firstname == "19916763841"
replace firstname = "18801735876" if firstname == "18801775876"

replace hospitalID = "D00393844" if hospitalID == "D00293844"
sort date_invited
duplicates drop firstname lastname, force
save "$proc/attritiontoken_1m.dta", replace */


// ------------------- //
// 1m complete results //
// ------------------- //


import delimited using "$data/results-survey659371.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part1
save `part1'

import delimited using "$data/results-survey826686.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey137936.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey839976.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part4
save `part4'

import delimited using "$data/results-survey757445.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part5
save `part5'

import delimited using "$data/results-survey644261.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part6
save `part6'

import delimited using "$data/results-survey972288.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part7
save `part7'

import delimited using "$data/results-survey716853.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part8
save `part8'

import delimited using "$data/results-survey563862.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part9
save `part9'

import delimited using "$data/results-survey477485.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part10
save `part10'

import delimited using "$data/results-survey727311.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part11
save `part11'

import delimited using "$data/results-survey492913.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part12
save `part12'

import delimited using "$data/results-survey941843.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part13
save `part13'

import delimited using "$data/results-survey110807.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

/* tempfile part14
save `part14' */

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
append using `part12', force
append using `part13', force
/* append using `part14', force */

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if firstname == ""
drop if hospital_id == ""

duplicates report firstname
duplicates drop firstname, force

save "$proc/1m_results.dta", replace





/////////////////////////////////////////////////////////////////////////
************************************* 2m ********************************
/////////////////////////////////////////////////////////////////////////


// --------- //
// 2m tokens //
// --------- //

/* 

import delimited using "$data/tokens_643199.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_714695.csv",stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_795738.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_448999.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 4
save `4'

import delimited using "$data/tokens_162992.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 5
save `5'

import delimited using "$data/tokens_753661.csv",stringcol(_all)  encoding("UTF-8") clear


append using `1' , force
append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force


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

drop if firstname == "13616298980" | firstname == "15822222920" | firstname == "18611768884"
replace firstname = "15277315277" if lastname == "陶慧梅" 

rename attribute_11住院号 hospital_id
replace completed = "Y" if completed ~= "N"
keep firstname lastname completed remindercount treatment parent baby_gender date_invited hospital_id

gen attrition = (completed == "Y")

drop if lastname == "尤佳敏"
replace firstname = "13051395368" if lastname == "王猛"
replace lastname = "徐鑫" if firstname == "17602196772"
replace parent = "F" if firstname == "17602196772"

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
save "$proc/attritiontoken_2m.dta", replace
 */



// ------------------- //
// 2m complete results //
// ------------------- //

import delimited using "$data/results-survey643199.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part1
save `part1'


import delimited using "$data/results-survey714695.csv",stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey795738.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey448999.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part4
save `part4'

import delimited using "$data/results-survey162992.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part5
save `part5'

import delimited using "$data/results-survey753661.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part6 
save `part6'

import delimited using "$data/results-survey669218.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part7
save `part7'

import delimited using "$data/results-survey792737.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force 
append using `part7', force


tempfile online_results
save `online_results'

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if hospital_id == ""
duplicates drop firstname, force
save "$proc/2m_results.dta", replace


//------------------ 6w ------------------//

import delimited using "$data/results-survey184411.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_1
save `6w_1'

import delimited using "$data/results-survey191613.csv",stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_2
save `6w_2'

import delimited using "$data/results-survey815998.csv",stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id

tempfile 6w_3
save `6w_3'

import delimited using "$data/results-survey265968.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id
tempfile 6w_4
save `6w_4'

import delimited using "$data/results-survey924349.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id

tempfile 6w_5
save `6w_5'

import delimited using "$data/results-survey446773.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id


rename g00q02 parent
append using `6w_1'
append using `6w_2'
append using `6w_3'
append using `6w_4'
append using `6w_5'
replace parent = g00q02 if parent == ""

preserve
keep if parent == "爸爸"
keep fname fphone parent hospital_id
rename (fphone fname)(firstname lastname)
tempfile father 
save `father'
restore

keep if parent == "妈妈"
keep mname mphone parent hospital_id
rename (mphone mname)(firstname lastname)
append using `father'

tostring hospital_id, replace

append using `online_results'


replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

drop if firstname == ""
drop if hospital_id == ""
duplicates drop firstname, force
save "$proc/2m&6w_results.dta", replace






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

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part1
save `part1'

import delimited using "$data/results-survey917974.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey567772.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey291237.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part4
save `part4'

import delimited using "$data/results-survey415357.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""
keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part5
save `part5'


import delimited using "$data/results-survey331106.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""
keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

tempfile part6
save `part6'


import delimited using "$data/results-survey331112.csv", stringcol(_all) encoding("utf-8") clear
drop if submitdate == ""
keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id



append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force

duplicates drop firstname, force
drop if hospital_id == ""

save "$proc/3m_results.dta", replace







/////////////////////////////////////////////////////////////////////////
************************************* 6m ********************************
/////////////////////////////////////////////////////////////////////////


// --------- //
// 6m tokens //
// --------- //

* data list:
/* 
885914, 491311, 946233, 435596, 975966
721796, 455394, 948966, 575937, 660828
*/

/* import delimited using "$data/tokens_885914.csv", stringcol(_all) encoding("UTF-8") clear
save temp_data, replace

import delimited using "$data/tokens_491311.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_946233.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_435596.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_975966.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_721796.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_455394.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_948966.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_575937.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data
save temp_data, replace

import delimited using "$data/tokens_660828.csv", stringcol(_all) encoding("UTF-8") clear
append using temp_data


duplicates drop firstname, force

tab remindercount

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
save "$proc/attritiontoken_6m.dta", replace  */


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
tempfile part3
save `part3'

import delimited using "$data/results-survey575937.csv", stringcol(_all) encoding("UTF-8") clear
tempfile part4
save `part4'


import delimited using "$data/results-survey660828.csv", stringcol(_all) encoding("UTF-8") clear
// tempfile part5
// save `part5'

// import delimited using "$data/results-survey857172.csv", stringcol(_all) encoding("UTF-8") clear
append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force



drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

rename submitdate submitdate_6m

duplicates drop firstname, force




drop if hospital_id == ""
save "$proc/6m_results.dta", replace






// ------------------- //
// 7m complete results //
// ------------------- //


import delimited using "$data/results-survey771105.csv",  bindquote(strict) stringcol(_all) encoding("UTF-8") clear

tempfile part1
save `part1'



import delimited using "$data/results-survey771120.csv", bindquote(strict) stringcol(_all) encoding("UTF-8") clear

tempfile part2
save `part2'

import delimited using "$data/results-survey771204.csv",  bindquote(strict) stringcol(_all) encoding("UTF-8") clear
tempfile part3
save `part3'

import delimited using "$data/results-survey771205.csv",  bindquote(strict) stringcol(_all) encoding("UTF-8") clear



append using `part1', force
append using `part2', force
append using `part3', force
/* append using `part4', force */


drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate randtreat
rename attribute_11 hospital_id

rename submitdate submitdate_7m

duplicates drop firstname, force




drop if hospital_id == ""
save "$proc/7m_results.dta", replace





// ------------------- //
// 10m complete results //
// ------------------- //


*import delimited using "$data/results-survey289734.csv",  bindquote(strict) stringcol(_all) encoding("UTF-8") clear

import delimited using "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/02_Raw data/results-survey289734.csv",  bindquote(strict) stringcol(_all) encoding("UTF-8") clear

drop if submitdate == ""

keep firstname lastname attribute_1-attribute_11 submitdate
rename attribute_11 hospital_id

rename submitdate submitdate_7m

duplicates drop firstname, force




drop if hospital_id == ""
save "$proc/10m_results.dta", replace




************************ log close ************************
log close
