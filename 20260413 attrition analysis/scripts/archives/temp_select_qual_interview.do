import delimited using "$data/results-survey435596.csv",stringcol(_all) encoding("UTF-8") clear
drop if missing(firstname)
duplicates drop firstname, force
keep firstname attribute_11
rename attribute_11 hospital_id  
tempfile 6m_results
save `6m_results', replace

import delimited using "$data/results-survey229356.csv",stringcol(_all) encoding("UTF-8") clear
drop if missing(firstname)
duplicates drop firstname, force
keep firstname attribute_11
rename attribute_11 hospital_id  
tempfile 3m_results
save `3m_results', replace

import delimited using "$data/results-survey579354.csv",stringcol(_all) encoding("UTF-8") clear
drop if missing(firstname)
duplicates drop firstname, force
keep firstname attribute_11
rename attribute_11 hospital_id  
tempfile 2m_results
save `2m_results', replace

import delimited using "$data/results-survey812586.csv",stringcol(_all) encoding("UTF-8") clear
drop if missing(firstname)
duplicates drop firstname, force
keep firstname attribute_11 submitdate
rename attribute_11 hospital_id  
rename submitdate submitdate_6m
tempfile 1m_results
save `1m_results', replace




use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2024-9-24", "YMD")
gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6

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

tempfile participants
save `participants'


merge 1:m firstname using `1m_results'
drop if _merge == 2
gen response_1m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 1m
save `1m'

use `participants', clear
merge 1:m firstname using `2m_results'
drop if _merge == 2
gen response_2m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 2m
save `2m'

use `participants', clear
merge 1:m firstname using `3m_results'
drop if _merge == 2
gen response_3m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 3m
save `3m'

use `participants', clear
merge 1:m firstname using `6m_results'
drop if _merge == 2
gen response_6m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 6m
save `6m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `3m', force
drop if _merge == 1
drop _merge 

merge 1:1 firstname using `6m', force
drop if _merge == 1
drop _merge 


sort hospital_id parent
gen complete_all_mother = 1 if response_1m + response_2m + response_3m + response_6m == 4 & parent == "M"
gen complete_none_father = 1 if response_1m + response_2m + response_3m + response_6m <= 1 & parent == "F" 

bys hospital_id: egen mother_complete = max(complete_all_mother)
bys hospital_id: egen father_none = max(complete_none_father)
list firstname treatment hospital_id parent if mother_complete == 1 & father_none == 1