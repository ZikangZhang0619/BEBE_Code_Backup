** Attrition Across Survey Waves

** Haoyue Wu
** 16 Apr, 2025


*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project attrition_table
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd


///////////////////////////////////////////////////////////////////////////////////
///***************************** Attrition Table ******************************////
///////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------//
//---------- 1m after triple p change ---------//
//---------------------------------------------//

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-04-01", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0
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
local N = 446
local C = 155
local T1 = 161
local T2 = 130

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
display `m1_both'
local m1_either = r(unique_value)
display `m1_either'

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




//-------------------------------------------------------------//
//-------------------- 2m with tp change ---------------------//
//-------------------------------------------------------------//



use "$proc/contact_list.dta", clear

gen date = ///
	cond(strpos(日期, "年") > 0, date(日期, "YMD"), ///
	cond(strpos(日期, "/") > 0, date(日期, "MDY"), ///
	date(日期, "DMY")))
	

keep if date <= date("2025-02-16", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0

/* keep if date < date("2025-01-21", "YMD") & strpos(备注,"tp课程干预简化Ava测试") == 0 */


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

tempfile participants
save `participants'

use "$proc/2m&6w_results.dta", clear
duplicates drop firstname, force
keep firstname lastname 


merge 1:1 firstname using `participants'

drop if _merge == 1
gen completed = "Y" if _merge == 3
drop _merge

replace treatment = "T2" if firstname == "13012837789"

gen attribute_7 = "Y" if parent == "M" & completed == "Y"
gen attribute_8 = "Y" if parent == "F" & completed == "Y"
gen attribute_4 = "Y" if treatment == "C" & completed == "Y"
gen attribute_5 = "Y" if treatment == "T1" & completed == "Y"
gen attribute_6 = "Y" if treatment == "T2" & completed == "Y"
save "$proc/attrition_2m.dta", replace

//
local N = 128
local C = 42
local T1 = 43
local T2 = 43

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





//-----------------------------------------------------//
//-------------------------- 3m -----------------------//
//-----------------------------------------------------//



use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-01-12", "YMD") // where needing updates each week
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


local N = 1134
local C = 375
local T1 = 390
local T2 = 369

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




///////////////////////////////////////////////
////-------------- 6m -----------------////////
///////////////////////////////////////////////


use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2024-10-20", "YMD") // where needing updates each week
tab 组别
keep 住院号 日期
rename 住院号 hospital_id 
drop 日期
tempfile 6m_contact
save `6m_contact'


use "$proc/6m_results.dta", clear

merge m:1 hospital_id using `6m_contact'

drop if _merge == 1
drop if attribute_3 == ""
drop _merge

gen completed = "Y"
/* 
gen merge_var = hospital_id + "F" if attribute_8 == "Y"
replace merge_var = hospital_id + "M" if attribute_7 == "Y"
tempfile 6m_attrition
save `6m_attrition' */

/* 
use "$proc/attritiontoken_6m.dta", clear
gen merge_var = hospital_id + parent
keep hospital_id date_invited merge_var
rename hospital_id hospital_id

merge m:1 hospital_id using `6m_contact'
keep if _merge == 3
drop _merge 

merge 1:1 merge_var using `6m_attrition'


replace date_invited = date("2025-1-2", "YMD") if date_invited == date("2024-12-31", "YMD")
replace date_invited = date("2024-12-5", "YMD")  if date_invited == date("2024-12-07", "YMD")
 */

local N = 233
local C = 84
local T1 = 67
local T2 = 82

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
	
file open resultsfile using "$results/tables/attrition_table_6m.tex", write replace

    file write resultsfile "\textbf{Baseline} & 1.00(`Ni') & 1.00(`N') & 1.00(`N')  &1.00(`N') & 1.00(`N') & `N'\\" _n
    file write resultsfile "\textbf{6m(total)} & `m1_prec1'(`m1_individual') & `m1_prec2'(`m1_mother') & `m1_prec3'(`m1_father')  &`m1_prec4'(`m1_both') & `m1_prec5'(`m1_either') & `N' \\" _n
	file write resultsfile "\textbf{6m(C)} & `C_prec1'(`C_individual') & `C_prec2'(`C_mother') & `C_prec3'(`C_father')  &`C_prec4'(`C_both') & `C_prec5'(`C_either') & `C' \\" _n	
    file write resultsfile "\textbf{6m(T1)} & `T1_prec1'(`T1_individual') & `T1_prec2'(`T1_mother') & `T1_prec3'(`T1_father')  &`T1_prec4'(`T1_both') & `T1_prec5'(`T1_either') & `T1' \\" _n
	file write resultsfile "\textbf{6m(T2)} & `T2_prec1'(`T2_individual') & `T2_prec2'(`T2_mother') & `T2_prec3'(`T2_father')  &`T2_prec4'(`T2_both') & `T2_prec5'(`T2_either') & `T2' \\" _n

file close resultsfile





////////////////////////////////////////////////////////////////////////////////
************************* Reminder Times after TP ******************************
////////////////////////////////////////////////////////////////////////////////

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-04-01", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0
tab 组别
keep 住院号 日期
gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
drop 住院号

drop 日期
tempfile 1m
save `1m'

use "$proc/attritiontoken_1m.dta", clear
keep firstname hospitalID remindercount
rename hospitalID hospital_id
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
merge m:1 hospital_id using `1m'
keep if _merge == 3
drop _merge

tempfile participants
save `participants'


use "$proc/1m_results.dta", clear
duplicates drop firstname, force
merge 1:1 firstname using `participants'

   
   file open mytable using "$results/tables/reminder_table.tex", write replace
   
   quietly tabulate remindercount
   local total = r(N)
   
   forvalues i = 0/5 {
       quietly count if remindercount == `i'
       local freq`i' = r(N)
       local pct`i' = `freq`i''/`total'*100
       local pct`i' : display %5.2f `pct`i''
   }
   
   local cum0 = `pct0'
   local cum0 : display %5.2f `cum0'
   
   local cum1 = `cum0' + `pct1'
   local cum1 : display %5.2f `cum1'
   
   local cum2 = `cum1' + `pct2'
   local cum2 : display %5.2f `cum2'
   
   local cum3 = `cum2' + `pct3'
   local cum3 : display %5.2f `cum3'
   
   local cum4 = `cum3' + `pct4'
   local cum4 : display %5.2f `cum4'
   
   local cum5 = 100.00
   
   file write mytable "0 & `freq0' & `pct0' & `cum0' & 1046 & 44.36 & 44.36 \\" _n
   file write mytable "1 & `freq1' & `pct1' & `cum1' & 356 & 15.10 & 59.46 \\" _n
   file write mytable "2 & `freq2' & `pct2' & `cum2' & 148 & 6.28 & 65.73 \\" _n
   file write mytable "3 & `freq3' & `pct3' & `cum3' & 75 & 3.18 & 68.91 \\" _n
   file write mytable "4 & `freq4' & `pct4' & `cum4' & 32 & 1.36 & 70.27 \\" _n
   file write mytable "5 & `freq5' & `pct5' & `cum5' & 701 & 29.73 & 100.00 \\" _n
   
   file close mytable
   





////////////////////////////////////////////////////////////////////////////////
*#*********************** Attrition By Enumerator ******************************
////////////////////////////////////////////////////////////////////////////////


use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-03-25", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0

preserve
keep 母亲电话 母亲姓名 招募人员 组别 date 住院号
rename (母亲电话 母亲姓名)(firstname lastname)
tempfile mother
save `mother'
restore

preserve
keep 父亲电话 父亲姓名 招募人员 组别 date 住院号
rename (父亲电话 父亲姓名)(firstname lastname)
tempfile father
save `father'
restore

use `mother', clear
append using `father', force

format date %td
tab 组别
destring firstname, replace
tempfile 1m 
save `1m' 



use "$proc/1m_results.dta", clear
duplicates drop firstname, force
merge 1:1 firstname using `1m'

drop if _merge == 1
drop _merge

gen treatment = "T0" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

gen month = floor((date - date("2024-09-24", "YMD"))/30) + 1
drop if month == 0
replace month = 5 if month == 6

gen attrition_1m = (submitdate == "")
encode 招募人员, gen(enumerator_num)
encode treatment, gen(treatment_temp)
drop treatment
rename treatment_temp treatment
gen C = (treatment == 1)
gen T1 = (treatment == 2)
gen T2 = (treatment == 3)
gen Treat = (treatment ~= 1)
gen group = 0
replace group = 1 if T1 == 1
replace group = 2 if T2 == 1

capture drop hospital_id
gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
drop 住院号
tempfile temp
save `temp'

use "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/temp2.dta", clear

keep hospitalID bed_in_room cluster_var vip
rename hospitalID hospital_id

merge 1:m hospital_id using `temp'
drop if _merge == 1
drop _merge
save "$proc/tp_comparision_enumerator.dta", replace



use "$proc/tp_comparision_enumerator.dta", clear
drop if date > td(11mar2025)
local attrition_1m "attrition_1m"

local row = 0
foreach var of varlist `attrition_1m' {
    
	count
	local N = r(N)
	
	su `var'
	local mean: di %6.3f r(mean)
	local sd: di %6.3f r(sd)
	local sd = trim("`sd'")
	
	// Mean and SD for Control (C)
    su `var' if C == 1
    local mean_c: di %6.3f r(mean)
    local sd_c: di %6.3f r(sd)
	local sd_c = trim("`sd_c'")


    // Mean and SD for T1
    su `var' if T1 == 1
    local mean_t1: di %6.3f r(mean)
    local sd_t1: di %6.3f r(sd)
	local sd_t1 = trim("`sd_t1'")
	
    // Mean and SD for T2
    su `var' if T2 == 1
    local mean_t2: di %6.3f r(mean)
    local sd_t2: di %6.3f r(sd)
	local sd_t2 = trim("`sd_t2'")

	// Mean and SD for Treat
    su `var' if Treat == 1
    local mean_treat: di %6.3f r(mean)
    local sd_treat: di %6.3f r(sd)
	local sd_treat = trim("`sd_treat'")
	
	
    // Regression for T1 vs Control (C)
    preserve
    drop if T2 == 1
    reg `var' T1 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t1c: di %6.3f _b[T1]
    local se_t1c: di %6.3f _se[T1]
	local se_t1c = trim("`se_t1c'")
	
    local pval_t1c = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
    local pval_t1c: di %6.3f `pval_t1c'
	
	local star_t1c ""
    if (`pval_t1c' < 0.1) local star_t1c "*"
    if (`pval_t1c' < 0.05) local star_t1c "**"
    if (`pval_t1c' < 0.01) local star_t1c "***"
    restore

    // Regression for T2 vs Control (C)
    preserve
    drop if T1 == 1
    reg `var' T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t2c: di %6.3f _b[T2]
    local se_t2c: di %6.3f _se[T2]
	local se_t2c = trim("`se_t2c'")

    local pval_t2c = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
    local pval_t2c: di %6.3f `pval_t2c'
	
	local star_t2c ""
    if (`pval_t2c' < 0.1) local star_t2c "*"
    if (`pval_t2c' < 0.05) local star_t2c "**"
    if (`pval_t2c' < 0.01) local star_t2c "***"
	
    restore

    // Regression for T2 vs T1
    preserve
    drop if C == 1
    reg `var' T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t2t1: di %6.3f _b[T2]
    local se_t2t1: di %6.3f _se[T2]
	local se_t2t1 = trim("`se_t2t1'")

    local pval_t2t1 = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
    local pval_t2t1: di %6.3f `pval_t2t1'
	
	local star_t2t1 ""
    if (`pval_t2t1' < 0.1) local star_t2t1 "*"
    if (`pval_t2t1' < 0.05) local star_t2t1 "**"
    if (`pval_t2t1' < 0.01) local star_t2t1 "***"
    restore

	// Regression for Treat vs C
    preserve
    reg `var' Treat i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_treat: di %6.3f _b[Treat]
    local se_treat: di %6.3f _se[Treat]
	local se_treat = trim("`se_treat'")

    local pval_treat = 2 * ttail(e(df_r), abs(_b[Treat] / _se[Treat]))
    local pval_treat: di %6.3f `pval_treat'
	
	local star_treat ""
    if (`pval_treat' < 0.1) local star_treat "*"
    if (`pval_treat' < 0.05) local star_treat "**"
    if (`pval_treat' < 0.01) local star_treat "***"
    restore
	
	
    // Optional: Perform Chi-square test for categorical variables if needed
    // Here, I'll assume you know which variables are categorical
    preserve
    tab `var' group, chi2
    local pval_chi2: di %6.3f r(p)
    restore

    // Increment row counter
    local row = `row' + 1

    // Store the results for this variable
    local mu_row`row' "\textit{ N = `N'} &`mean' & `mean_c' & `mean_t1' & `mean_t2' & `mean_treat' & `diff_t1c'`star_t1c' & `diff_t2c'`star_t2c' & `diff_t2t1'`star_t2t1' & `diff_treat'`star_treat' &  `pval_chi2'"
	
	// Increment row counter
    local row = `row' + 1
	local mu_row`row' " &(`sd') & (`sd_c') & (`sd_t1') & (`sd_t2') & (`sd_treat') & (`se_t1c') & (`se_t2c')  & (`se_t2t1') & (`se_treat') &  "
	
	
}
 
 
// Output results to LaTeX
file open resultsfile using "$results/tables/attrition_5m_enumerator.tex", write replace
local row = 0
foreach var of varlist `attrition_1m' {
    local row = `row' + 1
    file write resultsfile "`mu_row`row'' \\" _n
	local row = `row' + 1
    file write resultsfile "`mu_row`row'' \\" _n
}
file close resultsfile


use "$proc/tp_comparision_enumerator.dta", clear
/* keep if month == 5 */
local varlist enumerator_num
display `varlist'

foreach var in `varlist' {
    
    // Get the levels of the current categorical variable
    levelsof `var', local(var_value)
    
    // Open the output file (append mode)
    file open resultsfile using "$results/tables/attrition_5m_enumerator.tex", write append
    
    // Loop through each level of the current variable
    foreach level of local var_value {
        di "Processing for `var' level: `level'"

        use "$proc/tp_comparision_enumerator.dta", clear
        drop if date > td(11mar2025)
        keep if `var' == `level'  // Keep data for the current level

        count
        local N_`var'`level' = r(N)  // Save the count

        // Output header to LaTeX file
        file write resultsfile "\midrule" _n
        file write resultsfile "\textbf{`var' level `level'}\\" _n
        
        local row = 0
        
        // Calculate and output means and standard deviations
        su attrition_1m
        local mean: di %6.3f r(mean)
        local sd: di %6.3f r(sd)
        
        // Mean and SD for Control (C)
        su attrition_1m if C == 1
        local mean_c: di %6.3f r(mean)
        local sd_c: di %6.3f r(sd)
        
        // Mean and SD for T1
        su attrition_1m if T1 == 1
        local mean_t1: di %6.3f r(mean)
        local sd_t1: di %6.3f r(sd)
        
        // Mean and SD for T2
        su attrition_1m if T2 == 1
        local mean_t2: di %6.3f r(mean)
        local sd_t2: di %6.3f r(sd)
        
        // Mean and SD for Treat
        su attrition_1m if Treat == 1
        local mean_treat: di %6.3f r(mean)
        local sd_treat: di %6.3f r(sd)
        
        // Perform regressions and calculate coefficients, standard errors, p-values, and stars
        preserve
        drop if T2 == 1
        reg attrition_1m T1 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t1c: di %6.3f _b[T1]
        local se_t1c: di %6.3f _se[T1]
        local pval_t1c = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
        local star_t1c ""
        if (`pval_t1c' < 0.1) local star_t1c "*"
        if (`pval_t1c' < 0.05) local star_t1c "**"
        if (`pval_t1c' < 0.01) local star_t1c "***"
        restore

        preserve
        drop if T1 == 1
        reg attrition_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t2c: di %6.3f _b[T2]
        local se_t2c: di %6.3f _se[T2]
        local pval_t2c = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
        local star_t2c ""
        if (`pval_t2c' < 0.1) local star_t2c "*"
        if (`pval_t2c' < 0.05) local star_t2c "**"
        if (`pval_t2c' < 0.01) local star_t2c "***"
        restore

        preserve
        drop if C == 1
        reg attrition_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t2t1: di %6.3f _b[T2]
        local se_t2t1: di %6.3f _se[T2]
        local pval_t2t1 = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
        local star_t2t1 ""
        if (`pval_t2t1' < 0.1) local star_t2t1 "*"
        if (`pval_t2t1' < 0.05) local star_t2t1 "**"
        if (`pval_t2t1' < 0.01) local star_t2t1 "***"
        restore

        preserve
        reg attrition_1m Treat i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_treat: di %6.3f _b[Treat]
        local se_treat: di %6.3f _se[Treat]
        local pval_treat = 2 * ttail(e(df_r), abs(_b[Treat] / _se[Treat]))
        local star_treat ""
        if (`pval_treat' < 0.1) local star_treat "*"
        if (`pval_treat' < 0.05) local star_treat "**"
        if (`pval_treat' < 0.01) local star_treat "***"
        restore

        // Optional Chi-square test
        preserve
        tab attrition_1m group, chi2
        local pval_chi2: di %6.3f r(p)
        restore

        // Prepare the output row
        local row = `row' + 1
        local mu_row`row' "\textit{ N = `N_`var'`level''} & `mean' & `mean_c' & `mean_t1' & `mean_t2' & `mean_treat' & `diff_t1c'`star_t1c' & `diff_t2c'`star_t2c' & `diff_t2t1'`star_t2t1' & `diff_treat'`star_treat' &  `pval_chi2'"

        local row = `row' + 1
        local mu_row`row' " & (`sd') & (`sd_c') & (`sd_t1') & (`sd_t2') & (`sd_treat') & (`se_t1c') & (`se_t2c')  & (`se_t2t1') & (`se_treat') &  "
        // Write the row to the LaTeX file
		
		    local row = 0

        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n
        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n
    
    }

    // Close the output file after finishing
    file close resultsfile
}




////////////////////////////////////////////////////////////////////////////////
************************* Attrition Acrosss Waves ******************************
////////////////////////////////////////////////////////////////////////////////

// --------------------------- //
// Attrition between 1m and 2m //
// ---------------------------- //
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-02-16", "YMD")
gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment
tempfile complete
save `complete'

keep 母亲姓名 母亲电话 treatment
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'

use `complete'
keep 父亲姓名 父亲电话 treatment
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'

append using `mother'
order firstname lastname

tempfile participants
save `participants'


merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen attrition_1m = (_merge == 3)
drop _merge
drop if missing(firstname)

tempfile 1m
save `1m'

use `participants', clear
merge 1:m firstname using "$proc/2m_results.dta"
drop if _merge == 2
gen attrition_2m = (_merge == 3)
drop _merge
drop if missing(firstname)

tempfile 2m
save `2m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

 
replace treatment = "T2" if firstname == "17638375569"
replace parent = "F" if firstname == "17638375569"
replace treatment = "T2" if firstname == "17621431230"
replace parent = "F" if firstname == "17621431230"
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"
replace hospital_id = "D00338830" if firstname == "17740880560"
replace treatment = "C" if firstname == "17740880560"
replace treatment = "T2" if firstname == "13012837789"


gen both_attrition = (attrition_1m == 1 & attrition_2m == 1)
gen any_attrition = (attrition_1m == 1 | attrition_2m == 1)
save "$proc/attrition_waves_2m.dta", replace




file open resultsfile using "$results/tables/attrition_across_wave.tex", write replace

** individual 
file write resultsfile "\multirow{4}{*}{Total} " _n
count
local N_total = r(N)

file write resultsfile "& Total &"
local var attrition_1m attrition_2m any_attrition both_attrition
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

** father
file write resultsfile "\midrule" _n
file write resultsfile "\multirow{4}{*}{Father} " _n

use "$proc/attrition_waves_2m.dta", clear
keep if parent == "F"
count
local N_total = r(N)

file write resultsfile "& Father &"
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

** mother
file write resultsfile "\midrule" _n
file write resultsfile "\multirow{4}{*}{Mother} " _n

use "$proc/attrition_waves_2m.dta", clear
keep if parent == "M"
count
local N_total = r(N)

file write resultsfile "& Mother &"
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

file close resultsfile






// ------------------------------------------------- //
//         Attrition between 1m, 2m and 3m           //
// ------------------------------------------------- //



use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-01-12", "YMD")
gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment
tempfile complete
save `complete'

keep 母亲姓名 母亲电话 treatment
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'

use `complete'
keep 父亲姓名 父亲电话 treatment
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'

append using `mother'
order firstname lastname

tempfile participants
save `participants'

merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen attrition_1m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 1m
save `1m'

use `participants', clear
merge 1:m firstname using "$proc/2m_results.dta"
drop if _merge == 2
gen attrition_2m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 2m
save `2m'

use `participants', clear
merge 1:m firstname using "$proc/3m_results.dta"
drop if _merge == 2
gen attrition_3m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 3m
save `3m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `3m', force
drop if _merge == 1
drop _merge 
replace treatment = "T2" if firstname == "17638375569"
replace parent = "F" if firstname == "17638375569"
replace treatment = "T2" if firstname == "17621431230"
replace parent = "F" if firstname == "17621431230"
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"


gen all_attrition = (attrition_1m == 1 & attrition_2m == 1 & attrition_3m == 1)
gen any_attrition = (attrition_1m == 1 | attrition_2m == 1 | attrition_3m == 1)
save "$proc/attrition_waves_3m.dta", replace




file open resultsfile using "$results/tables/attrition_across_wave_3m.tex", write replace

** individual 
file write resultsfile "\multirow{4}{*}{Total} " _n
count
local N_total = r(N)

file write resultsfile "& Total &"
local var attrition_1m attrition_2m attrition_3m any_attrition all_attrition
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

** father
file write resultsfile "\midrule" _n
file write resultsfile "\multirow{4}{*}{Father} " _n

use "$proc/attrition_waves_3m.dta", clear
keep if parent == "F"
count
local N_total = r(N)

file write resultsfile "& Father &"
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

** mother
file write resultsfile "\midrule" _n
file write resultsfile "\multirow{4}{*}{Mother} " _n

use "$proc/attrition_waves_3m.dta", clear
keep if parent == "M"
count
local N_total = r(N)

file write resultsfile "& Mother &"
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

file close resultsfile






// ------------------------------------------------- //
//         Attrition between 1m, 2m, 3m and 6m          //
// ------------------------------------------------- //



use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2024-10-20", "YMD")
gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment
tempfile complete
save `complete'

keep 母亲姓名 母亲电话 treatment
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'

use `complete'
keep 父亲姓名 父亲电话 treatment
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'

append using `mother'
order firstname lastname

tempfile participants
save `participants'

merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen attrition_1m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 1m
save `1m'

use `participants', clear
merge 1:m firstname using "$proc/2m_results.dta"
drop if _merge == 2
gen attrition_2m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 2m
save `2m'

use `participants', clear
merge 1:m firstname using "$proc/3m_results.dta"
drop if _merge == 2
gen attrition_3m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 3m
save `3m'

use `participants', clear
merge 1:m firstname using "$proc/6m_results.dta"
drop if _merge == 2
gen attrition_6m =(_merge == 3)
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
replace treatment = "T2" if firstname == "17638375569"
replace parent = "F" if firstname == "17638375569"
replace treatment = "T2" if firstname == "17621431230"
replace parent = "F" if firstname == "17621431230"
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"


gen all_attrition = (attrition_1m == 1 & attrition_2m == 1 & attrition_3m == 1 & attrition_6m == 1)
gen any_attrition = (attrition_1m == 1 | attrition_2m == 1 | attrition_3m == 1 | attrition_6m == 1)
save "$proc/attrition_waves_6m.dta", replace




file open resultsfile using "$results/tables/attrition_across_wave_6m.tex", write replace

** individual 
file write resultsfile "\multirow{5}{*}{Total} " _n
count
local N_total = r(N)

file write resultsfile "& Total &"
local var attrition_1m attrition_2m attrition_3m attrition_6m any_attrition all_attrition
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

** father
file write resultsfile "\midrule" _n
file write resultsfile "\multirow{6}{*}{Father} " _n

use "$proc/attrition_waves_6m.dta", clear
keep if parent == "F"
count
local N_total = r(N)

file write resultsfile "& Father &"
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

** mother
file write resultsfile "\midrule" _n
file write resultsfile "\multirow{5}{*}{Mother} " _n

use "$proc/attrition_waves_6m.dta", clear
keep if parent == "M"
count
local N_total = r(N)

file write resultsfile "& Mother &"
foreach i in `var' {
   sum `i'
   local mean_`i': di %6.3f r(mean)
   count if `i' == 1 
   local num_`i' = r(N)
   file write resultsfile " `mean_`i'' (`num_`i'') &"
}
file write resultsfile " `N_total' \\" _n

foreach t in C T1 T2 {
   preserve
   keep if treatment == "`t'"
   local label = cond("`t'" == "C", "Control", "`t'")
   
   count if treatment == "`t'"
   local N_`t' = r(N)
   
   file write resultsfile "& `label' &"
   foreach i in `var' {
       sum `i'
       local mean_`i': di %6.3f r(mean)
       count if `i' == 1 
       local num_`i' = r(N)
       file write resultsfile " `mean_`i'' (`num_`i'') &"
   }
   file write resultsfile " `N_`t'' \\" _n
   restore
}

file close resultsfile



//////////////////////////////////////////////////////////////////////////
// whether attrition differs by control video receive ////////////////////
//////////////////////////////////////////////////////////////////////////


use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td
keep if date <= date("2025-04-01", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0
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
drop _merge 

use "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta", clear

merge m:1 hospital_id using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3


log close













