*# HOW RESPONSE TIME IS CORRELATED WITH PARENTS ANSWERS' DIFFERENCE (ENGAGEMENT)

* Author: Haoyue Wu
* June25, 2025

* ================================================================== *
* The time period between receiving the sms and answering the survey *
* ================================================================== *

// 1m
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
tempfile 11
save `11'

import delimited using "$data/tokens_492913.csv", stringcol(_all) encoding("utf-8") clear
tempfile 12
save `12'

/* import delimited using "$data/tokens_727311.csv", stringcol(_all) encoding("utf-8") clear
tempfile 13
save `13' */

import delimited using "$data/tokens_477485.csv", stringcol(_all) encoding("utf-8") clear

append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force
append using `6' , force
append using `7' , force
append using `8' , force
append using `9' , force
append using `10' , force
append using `11' , force
append using `12' , force
/* append using `13' , force */

keep validfrom attribute_1放弃填写问卷 attribute_4控制组 attribute_5t1 attribute_6t2 attribute_11住院号

local vars validfrom 
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

keep if attribute_1放弃填写问卷 == "Y"
gen group = "Control" if attribute_4控制组 == "Y"
replace group = "T1" if attribute_5t1 == "Y"
replace group = "T2" if attribute_6t2 == "Y"
drop attribute_4控制组 attribute_5t1 attribute_6t2

gen survey_wave = "1m"

tempfile 1m 
save `1m'


// 2m

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
tempfile 6
save `6'

import delimited using "$data/tokens_669218.csv",stringcol(_all)  encoding("UTF-8") clear

append using `1' , force
append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force
append using `6', force

keep validfrom attribute_1放弃问卷填写 attribute_4控制组 attribute_5t1 attribute_6t2 attribute_11住院号

local vars validfrom 
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

keep if attribute_1放弃问卷填写== "Y"
gen group = "Control" if attribute_4控制组 == "Y"
replace group = "T1" if attribute_5t1 == "Y"
replace group = "T2" if attribute_6t2 == "Y"
drop attribute_4控制组 attribute_5t1 attribute_6t2

gen survey_wave = "2m"

tempfile 2m 
save `2m'


// 3m

import delimited using "$data/tokens_573762.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_917974.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_567772.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_291237.csv", stringcol(_all) encoding("UTF-8") clear
append using `2' , force
append using `1' , force
append using `3', force


keep validfrom attribute_1放弃问卷填写 attribute_4控制组 attribute_5t1 attribute_6t2 attribute_11住院号

local vars validfrom 
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

keep if attribute_1放弃问卷填写 == "Y"
gen group = "Control" if attribute_4控制组 == "Y"
replace group = "T1" if attribute_5t1 == "Y"
replace group = "T2" if attribute_6t2 == "Y"
drop attribute_4控制组 attribute_5t1 attribute_6t2

gen survey_wave = "3m"

tempfile 3m 
save `3m'


// 6m

import delimited using "$data/tokens_975966.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_721796.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_948966.csv", stringcol(_all) encoding("UTF-8") clear
/* tempfile 3
save `3' */
append using `2' , force
append using `1' , force


keep validfrom attribute_1放弃填写问卷 attribute_4控制组 attribute_5t1 attribute_6t2 attribute_11住院号

local vars validfrom 
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

keep if attribute_1放弃填写问卷 == "Y"
gen group = "Control" if attribute_4控制组 == "Y"
replace group = "T1" if attribute_5t1 == "Y"
replace group = "T2" if attribute_6t2 == "Y"
drop attribute_4控制组 attribute_5t1 attribute_6t2

gen survey_wave = "6m"

append using `1m'
append using `2m'
append using `3m'

replace attribute_1放弃填写问卷 = attribute_1放弃问卷填写 if attribute_1放弃填写问卷 == ""
drop attribute_1放弃问卷填写

sort survey_wave validfrom attribute_11住院号