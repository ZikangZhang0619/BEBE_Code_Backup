** Attrition by Randomized SMS **

** Updated on: Mar 17, 2025
** Author: Haoyue Wu

use "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/TP_analysis/proc/sms_diff.dta", clear
tempfile sms_diff
save `sms_diff'

import delimited using "$data/tokens_659371.csv", encoding("utf-8") clear stringcols(_all)

tempfile part1
save `part1'

import delimited using "$data/tokens_826686.csv", encoding("utf-8") clear stringcols(_all)

tempfile part2
save `part2'

import delimited using "$data/tokens_137936.csv", encoding("utf-8") clear stringcols(_all)

tempfile part3
save `part3'

import delimited using "$data/tokens_839976.csv", encoding("utf-8") clear stringcols(_all)

tempfile part4
save `part4'

import delimited using "$data/tokens_757445.csv", encoding("utf-8") clear stringcols(_all)

tempfile part5
save `part5'

import delimited using "$data/tokens_644261.csv", encoding("utf-8") clear stringcols(_all)


tempfile part6
save `part6'

import delimited using "$data/tokens_972288.csv", encoding("utf-8") clear stringcols(_all)


tempfile part7
save `part7'

import delimited using "$data/tokens_563862.csv", encoding("utf-8") clear stringcols(_all)


tempfile part8
save `part8'

import delimited using "$data/tokens_477485.csv", encoding("utf-8") clear stringcols(_all)

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force
append using `part7', force
append using `part8', force

keep firstname lastname completed attribute_7母亲 attribute_8父亲 attribute_4控制组 attribute_5t1 attribute_6t2 attribute_11住院号
rename attribute_11住院号 hospital_id

drop if inlist(firstname, "18202116679", "18580838102", "13709475838")

merge m:1 firstname using `sms_diff'
keep if _merge == 3
gen unfinished_1m = (completed == "N")

drop if attribute_4控制组 == "Y"
drop if attribute_5t1 == "Y" & attribute_7母亲 == "Y"

tab unfinished_1m group

save "$proc/attrition_random_sms.dta", replace
