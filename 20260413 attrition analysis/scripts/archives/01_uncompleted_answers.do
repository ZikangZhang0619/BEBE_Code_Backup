

import delimited using "$data/results-survey659371.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "659371"

tempfile part1
save `part1'

import delimited using "$data/results-survey826686.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "826686"


tempfile part2
save `part2'

import delimited using "$data/results-survey137936.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "137936"


tempfile part3
save `part3'

import delimited using "$data/results-survey839976.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "839976"

tempfile part4
save `part4'

import delimited using "$data/results-survey757445.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "757445"

tempfile part5
save `part5'

import delimited using "$data/results-survey644261.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "644261"


tempfile part6
save `part6'

import delimited using "$data/results-survey972288.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "972288"


tempfile part7
save `part7'

import delimited using "$data/results-survey716853.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "716853"


tempfile part8
save `part8'

import delimited using "$data/results-survey563862.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "563862"

tempfile part9
save `part9'

import delimited using "$data/results-survey477485.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "477485"
tempfile part10
save `part10'

import delimited using "$data/results-survey727311.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "727311"

tempfile part11
save `part11'

import delimited using "$data/results-survey492913.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "492913"


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

sort firstname submitdate
drop if firstname == ""

bysort firstname: gen tag = _N
drop if submitdate == "" & tag ~= 1

replace submitdate = "0" if submitdate == ""

keep if submitdate == "0"

destring interviewtime, replace
su interviewtime, detail
gen duration_min = interviewtime / 60

su duration_min, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min , fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 1m Survey Uncompleted Answers (minutes)") ///
    xlabel(0(1)15) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    ylabel(#6) ///
    legend(pos(6) rows(1) size(small)) ///
    name(graph1, replace)

graph export "$proc/uncompleted_1m_duration.pdf", replace






// ------------------- //
// 2m complete results //
// ------------------- //

import delimited using "$data/results-survey643199.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "643199"


rename attribute_11 hospital_id

tempfile part1
save `part1'


import delimited using "$data/results-survey714695.csv",stringcol(_all) encoding("utf-8") clear
gen survey_id = "714695"


rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey795738.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "795738"


rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey448999.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "448999"


rename attribute_11 hospital_id

tempfile part4
save `part4'

import delimited using "$data/results-survey162992.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "162992"


rename attribute_11 hospital_id

tempfile part5
save `part5'

import delimited using "$data/results-survey753661.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "753661"


tempfile part6 
save `part6'

import delimited using "$data/results-survey669218.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "669218"


rename attribute_11 hospital_id

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force
gen online_results = 1

tempfile online_results
save `online_results'




//------------------ 6w ------------------//

import delimited using "$data/results-survey184411.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "184411"

rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_1
save `6w_1'

import delimited using "$data/results-survey191613.csv",stringcol(_all) encoding("utf-8") clear
gen survey_id = "191613"

rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_2
save `6w_2'

import delimited using "$data/results-survey815998.csv",stringcol(_all) encoding("utf-8") clear
gen survey_id = "815998"

rename g00q01sq001 hospital_id

tempfile 6w_3
save `6w_3'

import delimited using "$data/results-survey265968.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "265968"

rename g00q01sq001 hospital_id
tempfile 6w_4
save `6w_4'

import delimited using "$data/results-survey924349.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "924349"

rename g00q01sq001 hospital_id

rename g00q02 parent
append using `6w_1'
append using `6w_2'
append using `6w_3'
append using `6w_4'
replace parent = g00q02 if parent == ""

preserve
keep if parent == "爸爸"
rename (fphone fname)(firstname lastname)
tempfile father 
save `father'
restore

keep if parent == "妈妈"
rename (mphone mname)(firstname lastname)
append using `father'

tostring hospital_id, replace
gen onsite_results = 1
append using `online_results'


sort firstname submitdate
drop if firstname == ""

bysort firstname: gen tag = _N
drop if submitdate == "" & tag ~= 1

replace submitdate = "0" if submitdate == ""

keep if submitdate == "0"

destring interviewtime, replace
su interviewtime, detail
gen duration_min = interviewtime / 60


su duration_min, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min , fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 2m Survey Uncompleted Answers (minutes)") ///
    xlabel(0(1)10) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    ylabel(#6) ///
    legend(pos(6) rows(1) size(small)) ///
    name(graph1, replace)

graph export "$proc/uncompleted_2m_duration.pdf", replace






// ------------------- //
// 3m complete results //
// ------------------- //



import delimited using "$data/results-survey573762.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "573762"


rename attribute_11 hospital_id

tempfile part1
save `part1'

import delimited using "$data/results-survey917974.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "917974"


rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey567772.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "567772"


rename attribute_11 hospital_id


append using `part1', force
append using `part2', force

sort firstname submitdate
drop if firstname == ""

bysort firstname: gen tag = _N
drop if submitdate == "" & tag ~= 1

replace submitdate = "0" if submitdate == ""

keep if submitdate == "0"

destring interviewtime, replace
su interviewtime, detail
gen duration_min = interviewtime / 60

drop if duration_min > 15
su duration_min, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min , fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 3m Survey Uncompleted Answers (minutes)") ///
    xlabel(0(1)15) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    ylabel(#6) ///
    legend(pos(6) rows(1) size(small)) ///
    name(graph1, replace)

graph export "$proc/uncompleted_3m_duration.pdf", replace







import delimited using "$data/results-survey975966.csv", stringcol(_all) encoding("UTF-8") clear
rename attribute_11 hospital_id
gen survey_id = "975966"
tempfile part1
save `part1'



import delimited using "$data/results-survey721796.csv",stringcol(_all) encoding("UTF-8") clear
rename attribute_11 hospital_id
gen survey_id = "721796"
append using `part1', force


sort firstname submitdate
drop if firstname == ""

bysort firstname: gen tag = _N
drop if submitdate == "" & tag ~= 1

replace submitdate = "0" if submitdate == ""

keep if submitdate == "0"

destring interviewtime, replace
su interviewtime, detail
gen duration_min = interviewtime / 60

drop if duration_min > 15
su duration_min, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min , fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 6m Survey Uncompleted Answers (minutes)") ///
    xlabel(0(1)15) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    ylabel(#6) ///
    legend(pos(6) rows(1) size(small)) ///
    name(graph1, replace)

graph export "$proc/uncompleted_6m_duration.pdf", replace