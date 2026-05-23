*==================================================================*
*                   WITHIN-IN SURVEY ATTRITION                     *
*==================================================================*




*# ================== 1M =================== #*

import delimited using "$data/results-survey659371.csv", stringcol(_all) encoding("utf-8") clear
tempfile part1
save `part1'

import delimited using "$data/results-survey826686.csv", stringcol(_all) encoding("utf-8") clear
tempfile part2
save `part2'

import delimited using "$data/results-survey137936.csv", stringcol(_all) encoding("utf-8") clear
tempfile part3
save `part3'

import delimited using "$data/results-survey839976.csv", stringcol(_all) encoding("utf-8") clear
tempfile part4
save `part4'

import delimited using "$data/results-survey757445.csv", stringcol(_all) encoding("utf-8") clear
tempfile part5
save `part5'

import delimited using "$data/results-survey644261.csv", stringcol(_all) encoding("utf-8") clear
tempfile part6
save `part6'

import delimited using "$data/results-survey972288.csv", stringcol(_all) encoding("utf-8") clear
tempfile part7
save `part7'

import delimited using "$data/results-survey716853.csv", stringcol(_all) encoding("utf-8") clear
tempfile part8
save `part8'

import delimited using "$data/results-survey563862.csv", stringcol(_all) encoding("utf-8") clear
tempfile part9
save `part9'

import delimited using "$data/results-survey477485.csv", stringcol(_all) encoding("utf-8") clear
tempfile part10
save `part10'

import delimited using "$data/results-survey727311.csv", stringcol(_all) encoding("utf-8") clear
tempfile part11
save `part11'

import delimited using "$data/results-survey492913.csv", stringcol(_all) encoding("utf-8") clear
tempfile part12
save `part12'

import delimited using "$data/results-survey941843.csv", stringcol(_all) encoding("utf-8") clear
tempfile part13
save `part13'

import delimited using "$data/results-survey110807.csv", stringcol(_all) encoding("utf-8") clear


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


drop if firstname == ""
drop if inlist(firstname, "13277039529", "13709475838", "18580838102", "15297915517")

duplicates report firstname
keep firstname lastname attribute_1-attribute_11 submitdate lastpage
rename attribute_11 hospital_id
// generate variables
gen complete_answer = (submitdate ~= "")
bys firstname: egen any_complete = max(complete_answer)

bys firstname (complete_answer):  drop if _n ~= _N
tab any_complete
destring lastpage, replace
tab lastpage




*# ================== 2M =================== #*

import delimited using "$data/results-survey643199.csv", stringcol(_all) encoding("utf-8") clear
tempfile part1
save `part1'


import delimited using "$data/results-survey714695.csv",stringcol(_all) encoding("utf-8") clear
tempfile part2
save `part2'

import delimited using "$data/results-survey795738.csv", stringcol(_all) encoding("utf-8") clear
tempfile part3
save `part3'

import delimited using "$data/results-survey448999.csv", stringcol(_all) encoding("utf-8") clear
tempfile part4
save `part4'

import delimited using "$data/results-survey162992.csv", stringcol(_all) encoding("utf-8") clear
tempfile part5
save `part5'

import delimited using "$data/results-survey753661.csv", stringcol(_all) encoding("utf-8") clear
tempfile part6 
save `part6'

import delimited using "$data/results-survey669218.csv", stringcol(_all) encoding("utf-8") clear
tempfile part7
save `part7'

import delimited using "$data/results-survey792737.csv", stringcol(_all) encoding("utf-8") clear

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force 
append using `part7', force


drop if firstname == ""
drop if inlist(firstname, "13277039529", "13709475838", "18580838102", "15297915517")

duplicates report firstname
keep firstname lastname attribute_1-attribute_11 submitdate lastpage
rename attribute_11 hospital_id
// generate variables
gen complete_answer = (submitdate ~= "")
bys firstname: egen any_complete = max(complete_answer)

bys firstname (complete_answer):  drop if _n ~= _N
tab any_complete
destring lastpage, replace
tab lastpage


//------------------ 6w ------------------//

import delimited using "$data/results-survey184411.csv", stringcol(_all) encoding("utf-8") clear


keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_1
save `6w_1'

import delimited using "$data/results-survey191613.csv",stringcol(_all) encoding("utf-8") clear


keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_2
save `6w_2'

import delimited using "$data/results-survey815998.csv",stringcol(_all) encoding("utf-8") clear


keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id

tempfile 6w_3
save `6w_3'

import delimited using "$data/results-survey265968.csv", stringcol(_all) encoding("utf-8") clear


keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id
tempfile 6w_4
save `6w_4'

import delimited using "$data/results-survey924349.csv", stringcol(_all) encoding("utf-8") clear


keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id

tempfile 6w_5
save `6w_5'

import delimited using "$data/results-survey446773.csv", stringcol(_all) encoding("utf-8") clear


keep g00q02 mname fname mphone fphone g00q01sq001 submitdate
rename g00q01sq001 hospital_id


rename g00q02 parent
append using `6w_1'
append using `6w_2'
append using `6w_3'
append using `6w_4'
append using `6w_5'
replace parent = g00q02 if parent == ""
drop if mname == "TEST   "
drop if parent == ""

preserve
keep if parent == "爸爸"
keep fname fphone parent hospital_id submitdate
rename (fphone fname)(firstname lastname)
tempfile father 
save `father'
restore

keep if parent == "妈妈"
keep mname mphone parent hospital_id submitdate
rename (mphone mname)(firstname lastname)
append using `father'

drop if firstname == ""
drop if inlist(firstname, "13277039529", "13709475838", "18580838102", "15297915517")

duplicates report firstname

// generate variables
gen complete_answer = (submitdate ~= "")
bys firstname: egen any_complete = max(complete_answer)

bys firstname (complete_answer):  drop if _n ~= _N
tab any_complete




*# ================== 3M =================== #*

import delimited using "$data/results-survey573762.csv", stringcol(_all) encoding("utf-8") clear
tempfile part1
save `part1'

import delimited using "$data/results-survey917974.csv", stringcol(_all) encoding("utf-8") clear
tempfile part2
save `part2'

import delimited using "$data/results-survey567772.csv", stringcol(_all) encoding("utf-8") clear
tempfile part3
save `part3'

import delimited using "$data/results-survey291237.csv", stringcol(_all) encoding("utf-8") clear
tempfile part4
save `part4'

import delimited using "$data/results-survey415357.csv", stringcol(_all) encoding("utf-8") clear

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force


drop if firstname == ""
drop if inlist(firstname, "13277039529", "13709475838", "18580838102", "15297915517")

duplicates report firstname
keep firstname lastname attribute_1-attribute_11 submitdate lastpage
rename attribute_11 hospital_id
// generate variables
gen complete_answer = (submitdate ~= "")
bys firstname: egen any_complete = max(complete_answer)

bys firstname (complete_answer):  drop if _n ~= _N
tab any_complete
destring lastpage, replace
tab lastpage



*# ================== 6M =================== #*
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

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force


drop if firstname == ""
drop if inlist(firstname, "13277039529", "13709475838", "18580838102", "15297915517")

duplicates report firstname
keep firstname lastname attribute_1-attribute_11 submitdate lastpage
rename attribute_11 hospital_id
// generate variables
gen complete_answer = (submitdate ~= "")
bys firstname: egen any_complete = max(complete_answer)

bys firstname (complete_answer):  drop if _n ~= _N
tab any_complete
destring lastpage, replace
tab lastpage



*# ================== 7M =================== #*
import delimited using "$data/results-survey101005.csv", stringcol(_all) encoding("UTF-8") clear


drop if firstname == ""
drop if inlist(firstname, "13277039529", "13709475838", "18580838102", "15297915517")

duplicates report firstname
keep firstname lastname attribute_1-attribute_11 submitdate lastpage
rename attribute_11 hospital_id
// generate variables
gen complete_answer = (submitdate ~= "")
bys firstname: egen any_complete = max(complete_answer)

bys firstname (complete_answer):  drop if _n ~= _N
tab any_complete
destring lastpage, replace
tab lastpage

gen treatment = 1 if attribute_4 == "Y"
replace treatment = 2 if attribute_5 == "Y"
replace treatment = 3 if attribute_6 == "Y"

gen mother = 1 if attribute_7 == "Y"
replace mother = 0 if attribute_8 == "Y"

tab treatment mother

preserve 
keep if any_complete == 0 
tab treatment mother
restore

*# ================== 10M =================== #*
import delimited using "$data/results-survey100814.csv", stringcol(_all) encoding("UTF-8") clear
tempfile part1
save `part1'

import delimited using "$data/results-survey887747.csv", stringcol(_all) encoding("UTF-8") clear
tempfile part2
save `part2'

import delimited using "$data/results-survey375839.csv", stringcol(_all) encoding("UTF-8") clear

append using `part1'
append using `part2'

drop if firstname == ""
drop if inlist(firstname, "13277039529", "13709475838", "18580838102", "15297915517")

duplicates report firstname
keep firstname lastname attribute_1-attribute_11 submitdate lastpage
rename attribute_11 hospital_id
// generate variables
gen complete_answer = (submitdate ~= "")
bys firstname: egen any_complete = max(complete_answer)

bys firstname (complete_answer):  drop if _n ~= _N
tab any_complete
destring lastpage, replace
tab lastpage