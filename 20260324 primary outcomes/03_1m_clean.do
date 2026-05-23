********************************************************************************
* TITLE: Data Cleaning for 1M SURVEY, Since Formal Recruitment Sept24 2024
* Project: BEBE - Primary Outcomes
* Data: 1m Survey
* Author: Haoyue Wu
* Last updated: Nov19 2025
********************************************************************************

/*  (Survey id): 
		659371 
		826686 
		137936 
		839976 
		757445 
		644261 
		972288 
		563862 
		716853 
		477485
		727311 - short survey
		492913
		941843
		110807

*/

        /*
        This file is to clean the data from the 1m survey 
        INPUT: csv files from the 1m survey
        OUTPUT: $proc/1m_`date'.dta
        */




*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 03_1m_clean
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
//pwd

*************************
** READ & EXPLORE DATA **
*************************
** 1m 659371 826686 137936 839976 757445 644261 972288 563862 716853 477485

*---------------------*
* Survey 659371
*---------------------*
import delimited using "$data/1m/results-survey659371.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04sq001, replace force

gen survey_id = "659371"
tempfile 1m_1
save `1m_1', replace

*---------------------*
* Survey 826686
*---------------------*
import delimited using "$data/1m/results-survey826686.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04sq001, replace force

gen survey_id = "826686"
tempfile 1m_2
save `1m_2', replace

*---------------------*
* Survey 137936
*---------------------*
import delimited using "$data/1m/results-survey137936.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04sq001, replace force

gen survey_id = "137936"
tempfile 1m_3
save `1m_3', replace

*---------------------*
* Survey 839976 (requires extra cleaning)
*---------------------*
import delimited using "$data/1m/results-survey839976.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g08q05 g08q06a g08q06b g12q04sq001, replace force

gen survey_id = "839976"

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables (remove strings "次及以上" and "次")
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .) // 3次及以上变成3 所以这里有一个under estimate
    replace `var' = subinstr(`var', "次", "", .) // 2次变成2
    destring `var', replace force
}

rename g02q06 g02q02
rename g02q07 g02q03

tempfile 1m_4
save `1m_4', replace

*---------------------*
* Survey 757445
*---------------------*
import delimited using "$data/1m/results-survey757445.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g08q02 g08q03a g08q03b g12q04sq001, replace force

gen survey_id = "757445"

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

rename g02q06 g02q02
rename g02q07 g02q03

tempfile 1m_5
save `1m_5', replace

*---------------------*
* Survey 644261
*---------------------*
import delimited using "$data/1m/results-survey644261.csv",  bindquote(strict) encoding("utf-8") clear

gen survey_id = "644261"
tostring g01q02 g01q03 g01q04 g01q05, replace force

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

* Rename additional variables for survey 644261
rename g02q06 g02q02
rename g02q07 g02q03
rename g11q02 g11q02sq001
rename g12q03 g12q03sq001
rename g12q04 g12q04sq001
rename g13q01 g13q01sq001
rename g13q02 g13q02sq001

* Clean prebirth_workhours (g13q02sq001)
replace g13q02sq001 = "4" if g13q02sq001 == "不超过4小时"
replace g13q02sq001 = "14" if g13q02sq001 == "不少于14小时"
replace g13q02sq001 = subinstr(g13q02sq001, "小时", "", .)
destring g13q02sq001, replace force

tempfile 1m_6
save `1m_6', replace


*---------------------*
* Survey 972288
*---------------------*
import delimited using "$data/1m/results-survey563862.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04, replace force

gen survey_id = "563862"

tempfile 1m_7
save `1m_7', replace

import delimited using "$data/1m/results-survey716853.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04, replace force

gen survey_id = "716853"

tempfile 1m_8
save `1m_8', replace


import delimited using "$data/1m/results-survey972288.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05, replace force

gen survey_id = "972288"

tempfile 1m_9
save `1m_9', replace

import delimited using "$data/1m/results-survey477485.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05, replace force

gen survey_id = "477485"


append using `1m_7', force
append using `1m_8', force 
append using `1m_9', force

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

rename g02q06 g02q02
rename g02q07 g02q03
rename g11q02 g11q02sq001
rename g12q03 g12q03sq001
rename g12q04 g12q04sq001
rename g13q01 g13q01sq001
rename g13q02 g13q02sq001

* Clean prebirth_workhours (g13q02sq001)
replace g13q02sq001 = "4" if g13q02sq001 == "不超过4小时"
replace g13q02sq001 = "14" if g13q02sq001 == "不少于14小时"
replace g13q02sq001 = subinstr(g13q02sq001, "小时", "", .)
destring g13q02sq001, replace force

tempfile 1m_7
save `1m_7', replace

*******************************************
** APPEND SURVEY FILES TO CREATE MASTER  **
*******************************************
append using `1m_1', force
append using `1m_2', force
append using `1m_3', force
append using `1m_4', force
append using `1m_5', force
append using `1m_6', force

tempfile 1m_11
save `1m_11', replace

//------------- 1m short survey -------------
import delimited using "$data/1m/results-survey727311.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force

gen survey_id = "727311"

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

rename g02q06 g02q02
rename g12q03 g12q03sq001
rename g13q01 g13q01sq001
rename g13q02 g13q02sq001

tempfile 1m_10
save `1m_10', replace

import delimited using "$data/1m/results-survey492913.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force

gen survey_id = "492913"

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

rename g02q06 g02q02
rename g12q03 g12q03sq001
rename g13q01 g13q01sq001
rename g13q02 g13q02sq001

tempfile 1m_13
save `1m_13', replace

import delimited using "$data/1m/results-survey941843.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force

gen survey_id = "941843"

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

rename g02q06 g02q02
rename g12q03 g12q03sq001
rename g13q01 g13q01sq001
rename g13q02 g13q02sq001

tempfile 1m_14
save `1m_14', replace

import delimited using "$data/1m/results-survey110807.csv",  bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force

gen survey_id = "110807"

* Rename father involvement variables
rename g02q02 g02q01sq001
rename g02q03 g02q01sq002
rename g02q04 g02q01sq003
rename g02q05 g02q01sq004

* Clean father involvement variables
local fatherinvolv "g02q01sq001 g02q01sq002 g02q01sq003 g02q01sq004"
foreach var of local fatherinvolv {
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

rename g02q06 g02q02
rename g12q03 g12q03sq001
rename g13q01 g13q01sq001
rename g13q02 g13q02sq001
tempfile 1m_15
save `1m_15', replace
//------------- APPEND 1m short survey -------------
use `1m_11', clear
append using `1m_10', force
append using `1m_13', force
append using `1m_14', force
append using `1m_15', force



tostring(firstname), replace  format("%17.0f")

***********************
** VARIABLE RENAMING **
***********************

* -- Demographic variables -- 
rename g01q01      education_level
rename g01q02      self_brother_num
rename g01q03      self_sister_num
rename g01q04      partner_brother_num
rename g01q05      partner_sister_num
rename g01q06      parents_alive
rename g01q07      close_to_parents
rename g01q07other close_to_parents_other

* -- Father involvement and support --
rename g02q01sq001 father_involv_diaper
rename g02q01sq002 father_involv_night
rename g02q01sq003 father_involv_play
rename g02q01sq004 father_involv_lull
rename g02q02      father_care_alone
rename g02q03      partner_very_supportive

* -- EPDS (Emotional) variables --
rename g03q01 EPDS_1
rename g03q02 EPDS_2
rename g03q03 EPDS_3
rename g03q04 EPDS_4
rename g03q05 EPDS_5
rename g03q06 EPDS_6
rename g03q07 EPDS_7
rename g03q08 EPDS_8
rename g03q09 EPDS_9
rename g03q10 EPDS_10

* -- Partner and sleep indicators --
rename g04q01 partner_MH
rename g05q01 relationship_satisfaction
rename g05q02 sleep_quality

* -- Care obstacles --
rename g06q01sq001 care_obstacles_1
rename g06q01sq002 care_obstacles_2
rename g06q01sq003 care_obstacles_3
rename g06q01sq004 care_obstacles_4
rename g06q01sq005 care_obstacles_5
rename g06q01sq006 care_obstacles_6
rename g06q01sq007 care_obstacles_7
rename g06q01sq008 care_obstacles_8
rename g06q01other care_obstacles_other

* -- Baby closeness and parenting --
rename g07q01      own_close_baby
rename g07q02      partner_close_baby
rename g09q01sq001 positive_parenting_1
rename g09q01sq002 positive_parenting_2
rename g09q01sq003 positive_parenting_3
rename g09q01sq004 positive_parenting_4
rename g09q01sq005 positive_parenting_5
rename g09q01sq006 positive_parenting_6
rename g09q01sq007 positive_parenting_7
rename g09q02      escalation_trap

* -- Booklet and video usage --
rename g09q03 self_booklet_usage
rename g09q04 partner_booklet_usage
rename g09q05 booklet_useful
rename g09q06 sms_video_watch

* -- Help after birth and planning --
rename g10q01sq001 help_afterbirth_nanny
rename g10q01sq002 help_afterbirth_mother
rename g10q01sq003 help_ab_partner_mother
rename g10q01sq004 help_afterbirth_other_family
rename g10q01sq005 help_afterbirth_center
rename g10q01sq006 help_afterbirth_no
rename g10q01other help_after_birth_other

rename g10q02sq001 plan_help_afterbirth_nanny
rename g10q02sq002 plan_help_afterbirth_mother
rename g10q02sq003 plan_help_ab_partner_mother
rename g10q02sq004 plan_help_ab_other_family
rename g10q02sq005 plan_help_afterbirth_center
rename g10q02other plan_help_after_birth_other

* -- Leave taken --
rename g11q01sq001 paternity_leave_taken
rename g11q02sq001 maternity_leave_taken

* -- Occupation, income, & building characteristics --
rename g12q01      occupation_description
rename g12q02      total_couple_income
rename g12q03sq001 income_share_couple
rename g12q04sq001 building_area
rename g12q05      building_ownership
rename g12q05other building_ownership_other
rename g13q01sq001 prebirth_workdays
rename g13q02sq001 prebirth_workhours

* -- Extra time variables and father time valuation --
rename r723q0 extra_time_motor_dev
rename r835q0 extra_time_linguistic_emo_dev
rename r79q0  extra_time_father_wellbeing
rename r311q0 extra_time_mother_wellbeing
rename g04q09 father_time_less_valuable


drop if submitdate == ""

/* -- Create Group and Mother Variables -- */
gen group = 0
replace group = 1 if attribute_5 == "Y"
replace group = 2 if attribute_6 == "Y"

gen mother = 1
replace mother = 0 if attribute_8 == "Y"



gen father_involv_score = father_involv_diaper + father_involv_night + father_involv_play + father_involv_lull


local var father_involv_score
* Standardize for mothers (mother == 1) using control group (group == 0)
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)

* Standardize for fathers (mother == 0) using control group (group == 0)
sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0


* -- Initialize belief variables --
gen belief_father_15_walk = 0
gen belief_father_15_word = 0
gen belief_father_45_walk = 0
gen belief_father_45_word = 0
gen belief_mother_15_walk = 0
gen belief_mother_15_word = 0
gen belief_mother_45_walk = 0
gen belief_mother_45_word = 0

local varlist "g08q01asq001 g08q04asq001 g08q01bsq001 g08q04bsq001 g08q01asq002 g08q01bsq002 g08q04asq002 g08q04bsq002"
foreach var in `varlist' {
    replace `var' = 0 if `var' == .
}

* -- Compute belief variables based on randomization orders --
replace belief_father_15_walk = g08q01asq001 if (randgrouporder == 1 & randinvestmentorder == 1) 
replace belief_father_15_walk = g08q01bsq001 if (randgrouporder == 1 & randinvestmentorder == 2)
replace belief_father_15_walk = g08q04asq001 if (randgrouporder == 2 & randinvestmentorder == 1)
replace belief_father_15_walk = g08q04bsq001 if (randgrouporder == 2 & randinvestmentorder == 2)

replace belief_father_15_word = g08q01asq002 if (randgrouporder == 1 & randinvestmentorder == 1)
replace belief_father_15_word = g08q01bsq002 if (randgrouporder == 1 & randinvestmentorder == 2)
replace belief_father_15_word = g08q04asq002 if (randgrouporder == 2 & randinvestmentorder == 1)
replace belief_father_15_word = g08q04bsq002 if (randgrouporder == 2 & randinvestmentorder == 2)

replace belief_father_45_walk = g08q01asq001 if (randgrouporder == 1 & randinvestmentorder == 2)
replace belief_father_45_walk = g08q01bsq001 if (randgrouporder == 1 & randinvestmentorder == 1)
replace belief_father_45_walk = g08q04asq001 if (randgrouporder == 2 & randinvestmentorder == 2)
replace belief_father_45_walk = g08q04bsq001 if (randgrouporder == 2 & randinvestmentorder == 1)

replace belief_father_45_word = g08q01asq002 if (randgrouporder == 1 & randinvestmentorder == 2)
replace belief_father_45_word = g08q01bsq002 if (randgrouporder == 1 & randinvestmentorder == 1)
replace belief_father_45_word = g08q04asq002 if (randgrouporder == 2 & randinvestmentorder == 2)
replace belief_father_45_word = g08q04bsq002 if (randgrouporder == 2 & randinvestmentorder == 1)

replace belief_mother_15_walk = g08q01asq001 if (randgrouporder == 2 & randinvestmentorder == 1)
replace belief_mother_15_walk = g08q01bsq001 if (randgrouporder == 2 & randinvestmentorder == 2)
replace belief_mother_15_walk = g08q04asq001 if (randgrouporder == 1 & randinvestmentorder == 1)
replace belief_mother_15_walk = g08q04bsq001 if (randgrouporder == 1 & randinvestmentorder == 2)

replace belief_mother_15_word = g08q01asq002 if (randgrouporder == 2 & randinvestmentorder == 1)
replace belief_mother_15_word = g08q01bsq002 if (randgrouporder == 2 & randinvestmentorder == 2)
replace belief_mother_15_word = g08q04asq002 if (randgrouporder == 1 & randinvestmentorder == 1)
replace belief_mother_15_word = g08q04bsq002 if (randgrouporder == 1 & randinvestmentorder == 2)

replace belief_mother_45_walk = g08q01asq001 if (randgrouporder == 2 & randinvestmentorder == 2)
replace belief_mother_45_walk = g08q01bsq001 if (randgrouporder == 2 & randinvestmentorder == 1)
replace belief_mother_45_walk = g08q04asq001 if (randgrouporder == 1 & randinvestmentorder == 2)
replace belief_mother_45_walk = g08q04bsq001 if (randgrouporder == 1 & randinvestmentorder == 1)

replace belief_mother_45_word = g08q01asq002 if (randgrouporder == 2 & randinvestmentorder == 2)
replace belief_mother_45_word = g08q01bsq002 if (randgrouporder == 2 & randinvestmentorder == 1)
replace belief_mother_45_word = g08q04asq002 if (randgrouporder == 1 & randinvestmentorder == 2)
replace belief_mother_45_word = g08q04bsq002 if (randgrouporder == 1 & randinvestmentorder == 1)

gen belief_old = (belief_father_45_walk - belief_father_15_walk) + ///
                    (belief_mother_45_walk - belief_mother_15_walk) + ///
                    (belief_father_45_word - belief_father_15_word) + ///
                    (belief_mother_45_word - belief_mother_15_walk)
local var belief_old
* Standardize for mothers (mother == 1) using control group (group == 0)
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)

* Standardize for fathers (mother == 0) using control group (group == 0)
sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0
drop belief_father_15_walk belief_father_15_word belief_father_45_walk belief_father_45_word belief_mother_15_walk belief_mother_15_word belief_mother_45_walk belief_mother_45_word

local belief "extra_time_motor_dev extra_time_linguistic_emo_dev extra_time_father_wellbeing extra_time_mother_wellbeing "
foreach var in `belief'{
gen temp = .
// For survey 972288 responses
// replace temp = 1 if `var' == "完全没有帮助/可能有害" & survey_id == "644261"
// replace temp = 2 if `var' == "没有帮助但也没有坏处" & survey_id == "644261"
// replace temp = 3 if `var' == "帮助有限" & survey_id == "644261"
// replace temp = 4 if `var' == "有一些帮助" & survey_id == "644261"
// replace temp = 5 if `var' == "帮助很大" & survey_id == "644261"
replace temp = 1 if `var' == "完全没有帮助" & (survey_id == "972288" | survey_id == "563862" | survey_id == "477485")
replace temp = 2 if `var' == "帮助有限" & (survey_id == "972288" | survey_id == "563862" | survey_id == "477485")
replace temp = 3 if `var' == "有一些帮助" & (survey_id == "972288" | survey_id == "563862" | survey_id == "477485")
replace temp = 4 if `var' == "帮助很大" & (survey_id == "972288" | survey_id == "563862" | survey_id == "477485")
replace temp = 5 if `var' == "帮助非常大" & (survey_id == "972288" | survey_id == "563862" | survey_id == "477485")
drop `var'
rename temp `var'
}


gen belief_score = extra_time_motor_dev + extra_time_linguistic_emo_dev + ///
                   extra_time_father_wellbeing + extra_time_mother_wellbeing


local var belief_score
* Standardize for mothers (mother == 1) using control group (group == 0)
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)

* Standardize for fathers (mother == 0) using control group (group == 0)
sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0

replace belief_score_z = belief_old_z if belief_score_z == .


gen temp = .
replace temp = 1 if father_time_less_valuable == "非常不同意"
replace temp = 2 if father_time_less_valuable == "不同意"
replace temp = 3 if father_time_less_valuable == "中立"
replace temp = 4 if father_time_less_valuable == "同意"
replace temp = 5 if father_time_less_valuable == "非常同意"
drop father_time_less_valuable
rename temp father_time_less_valuable


gen certainty_father = .
replace certainty_father = 1 if (g08q02 == "非常不确定" & randgrouporder == 1)
replace certainty_father = 2 if (g08q02 == "比较不确定" & randgrouporder == 1)
replace certainty_father = 3 if (g08q02 == "比较确定"   & randgrouporder == 1)
replace certainty_father = 4 if (g08q02 == "非常确定"   & randgrouporder == 1)
replace certainty_father = 1 if (g08q05 == "非常不确定" & randgrouporder == 2)
replace certainty_father = 2 if (g08q05 == "比较不确定" & randgrouporder == 2)
replace certainty_father = 3 if (g08q05 == "比较确定"   & randgrouporder == 2)
replace certainty_father = 4 if (g08q05 == "非常确定"   & randgrouporder == 2)


gen certainty_mother = .
replace certainty_mother = 1 if (g08q02 == "非常不确定" & randgrouporder == 2)
replace certainty_mother = 2 if (g08q02 == "比较不确定" & randgrouporder == 2)
replace certainty_mother = 3 if (g08q02 == "比较确定"   & randgrouporder == 2)
replace certainty_mother = 4 if (g08q02 == "非常确定"   & randgrouporder == 2)
replace certainty_mother = 1 if (g08q05 == "非常不确定" & randgrouporder == 1)
replace certainty_mother = 2 if (g08q05 == "比较不确定" & randgrouporder == 1)
replace certainty_mother = 3 if (g08q05 == "比较确定"   & randgrouporder == 1)
replace certainty_mother = 4 if (g08q05 == "非常确定"   & randgrouporder == 1)

/* -- Generate Ability Variables from g08q03a and g08q03b, with cleanup -- */
gen ability_father = g08q03a
gen ability_mother = g08q03b
replace ability_father = g08q06b if ability_father == ""
replace ability_mother = g08q06a if ability_mother == ""

/* -- Recode Ability to Numeric Scale -- */
gen ability_father_temp = .
gen ability_mother_temp = .

replace ability_father_temp = 1 if ability_father == "能力远低于其他父亲"
replace ability_father_temp = 2 if ability_father == "能力略低于其他父亲"
replace ability_father_temp = 3 if ability_father == "能力与其他父亲不相上下"
replace ability_father_temp = 4 if ability_father == "能力略高于其他父亲"
replace ability_father_temp = 5 if ability_father == "能力远高于其他父亲"

replace ability_mother_temp = 1 if ability_mother == "能力远低于其他母亲"
replace ability_mother_temp = 2 if ability_mother == "能力略低于其他母亲"
replace ability_mother_temp = 3 if ability_mother == "能力与其他母亲不相上下"
replace ability_mother_temp = 4 if ability_mother == "能力略高于其他母亲"
replace ability_mother_temp = 5 if ability_mother == "能力远高于其他母亲"

drop ability_father ability_mother
rename (ability_father_temp ability_mother_temp) (ability_father ability_mother)


/* 

/* -- Recode Education Level -- */
gen temp = .
replace temp = 1 if education_level == "高中毕业或以下"
replace temp = 2 if education_level == "专科毕业"
replace temp = 3 if education_level == "本科毕业"
replace temp = 4 if education_level == "硕士毕业或博士毕业"
drop education_level
rename temp education_level

/* -- Recode Sibling Variables and Create Total Sibling Counts -- */
local varlist "self_brother_num self_sister_num partner_brother_num partner_sister_num"
foreach var of local varlist {
    gen temp = .
    replace temp = 1 if `var' == "0"
    replace temp = 2 if `var' == "1"
    replace temp = 3 if `var' == "2"
    replace temp = 4 if `var' == "3个或更多"
    drop `var'
    rename temp `var'
}
gen self_sibling_num    = self_brother_num + self_sister_num
gen partner_sibling_num = partner_brother_num + partner_sister_num	


gen temp = .
	replace temp = 1 if parents_alive == "是，他们都还健在"
	replace temp = 2 if parents_alive == "我母亲还健在（父亲已经离世）"
	replace temp = 3 if parents_alive == "我父亲还健在（母亲已经离世）"
	replace temp = 4 if parents_alive == "我父母都已经离世"
drop parents_alive
rename temp parents_alive

gen temp = .
	replace temp = 1 if close_to_parents == "我的父母与我生活在一起（不是临时的）"
	replace temp = 2 if close_to_parents == "我与父母的关系非常亲近，我们频繁地联系或探望彼此"
	replace temp = 3 if close_to_parents == "我与父母的关系比较亲近，我们偶尔会联系或探望彼此"
	replace temp = 4 if close_to_parents == "我与父母的关系并不亲近，我们几乎不联系或探望彼此"
drop close_to_parents
rename temp close_to_parents */


gen temp = .
replace temp = 1 if father_care_alone == "不超过2分钟"
replace temp = 2 if father_care_alone == "3-15分钟"
replace temp = 3 if father_care_alone == "16-30分钟"
replace temp = 4 if father_care_alone == "31-60分钟"
replace temp = 5 if father_care_alone == "1-2小时"
replace temp = 6 if father_care_alone == "超过2小时"
drop father_care_alone
rename temp father_care_alone
	
gen temp = .
replace temp = 1 if partner_very_supportive == "非常不同意"
replace temp = 2 if partner_very_supportive == "不同意"
replace temp = 3 if partner_very_supportive == "中立"
replace temp = 4 if partner_very_supportive == "同意"
replace temp = 5 if partner_very_supportive == "非常同意"
drop partner_very_supportive
rename temp partner_very_supportive


gen temp = .
replace temp = 1 if attentioncheck == "蓝色"
replace temp = 2 if attentioncheck == "棕色"
replace temp = 3 if attentioncheck == "绿色"
replace temp = 4 if attentioncheck == "红色"
drop attentioncheck
rename temp attentioncheck


gen temp = .
replace temp = 1 if partner_MH == "非常不好"
replace temp = 2 if partner_MH == "比较不好"
replace temp = 3 if partner_MH == "一般"
replace temp = 4 if partner_MH == "比较好"
replace temp = 5 if partner_MH == "非常好"
drop partner_MH
rename temp partner_MH


gen temp = .
replace temp = 1 if relationship_satisfaction == "非常不好"
replace temp = 2 if relationship_satisfaction == "比较不好"
replace temp = 3 if relationship_satisfaction == "一般"
replace temp = 4 if relationship_satisfaction == "比较好"
replace temp = 5 if relationship_satisfaction == "非常好"
drop relationship_satisfaction
rename temp relationship_satisfaction

gen temp = .
	replace temp = 1 if sleep_quality == "很糟糕"
	replace temp = 2 if sleep_quality == "不太好"
	replace temp = 3 if sleep_quality == "一般"
	replace temp = 4 if sleep_quality == "比较好"
	replace temp = 5 if sleep_quality == "非常好"
drop sleep_quality
rename temp sleep_quality


local care "care_obstacles_1 care_obstacles_2 care_obstacles_3 care_obstacles_4 care_obstacles_5 care_obstacles_6 care_obstacles_7 care_obstacles_8"
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}

gen temp = .
replace temp = 1 if own_close_baby == "非常疏远"
replace temp = 2 if own_close_baby == "比较疏远"
replace temp = 3 if own_close_baby == "比较亲近"
replace temp = 4 if own_close_baby == "亲近"
replace temp = 5 if own_close_baby == "非常亲近"
drop own_close_baby
rename temp own_close_baby

gen temp = .
replace temp = 1 if partner_close_baby == "非常疏远"
replace temp = 2 if partner_close_baby == "比较疏远"
replace temp = 3 if partner_close_baby == "比较亲近"
replace temp = 4 if partner_close_baby == "亲近"
replace temp = 5 if partner_close_baby == "非常亲近"
drop partner_close_baby
rename temp partner_close_baby




local care "positive_parenting_1 positive_parenting_2 positive_parenting_3 positive_parenting_4 positive_parenting_5 positive_parenting_6 positive_parenting_7 "
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}

gen positive_parenting_score = positive_parenting_1 + positive_parenting_2 + ///
                               positive_parenting_3 + positive_parenting_4 + ///
                               positive_parenting_5 + positive_parenting_6 + positive_parenting_7
gen positive_parenting = .
replace positive_parenting = 0 if positive_parenting_score != .
replace positive_parenting = 1 if positive_parenting_2 == 1 & positive_parenting_3 == 1 ///
                              & positive_parenting_5 == 1 & positive_parenting_score == 3

drop positive_parenting_1-positive_parenting_7 positive_parenting_score


gen temp = .
replace temp = 1 if escalation_trap == "如果照顾者对宝宝的哭声没有回应，宝宝会哭得更厉害，或者更大声，以让照顾者对他们做出回应"
replace temp = 2 if escalation_trap == "如果一个宝宝听到另一个宝宝的哭声，那么通常这个婴儿也会哭"
replace temp = 3 if escalation_trap == "如果父母中的一方心情不好，另一方也可能会心情不好，这会对婴儿产生负面影响"
drop escalation_trap
rename temp escalation_trap

gen escalation_trap_score = 0
replace escalation_trap_score = 1 if escalation_trap == 1

gen triple_p_correct = escalation_trap_score + positive_parenting

local var triple_p_correct
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)

sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0
drop `var'


local care "help_afterbirth_nanny help_afterbirth_mother help_ab_partner_mother help_afterbirth_other_family help_afterbirth_center help_afterbirth_no"
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}

local care "plan_help_afterbirth_nanny plan_help_afterbirth_mother plan_help_ab_partner_mother plan_help_ab_other_family plan_help_afterbirth_center"
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}

// EPDS
forvalues i = 1/10 {
    gen score_q`i' = .
}


* Calculate scores based on responses for the Chinese questions
replace score_q1 = (EPDS_1 == "同以前一样") * 0 + ///
                   (EPDS_1 == "没有以前那么多") * 1 + ///
                   (EPDS_1 == "肯定比以前少") * 2 + ///
                   (EPDS_1 == "完全不能") * 3

replace score_q2 = (EPDS_2 == "同以前一样") * 0 + ///
                   (EPDS_2 == "没有以前那么多") * 1 + ///
                   (EPDS_2 == "肯定比以前少") * 2 + ///
                   (EPDS_2 == "几乎完全不能") * 3

replace score_q3 = (EPDS_3 == "是的，大部分时候会这样") * 3 + ///
                   (EPDS_3 == "是的，有时候会这样") * 2 + ///
                   (EPDS_3 == "不，不经常这样") * 1 + ///
                   (EPDS_3 == "不，一点也没有") * 0

replace score_q4 = (EPDS_4 == "不，一点也没有") * 0 + ///
                   (EPDS_4 == "极少这样") * 1 + ///
                   (EPDS_4 == "是，有时候这样") * 2 + ///
                   (EPDS_4 == "是，经常这样") * 3

replace score_q5 = (EPDS_5 == "是的，相当多时候这样") * 3 + ///
                   (EPDS_5 == "是的，有时候这样") * 2 + ///
                   (EPDS_5 == "不经常这样") * 1 + ///
                   (EPDS_5 == "一点也没有") * 0

replace score_q6 = (EPDS_6 == "是的，大多数时候我根本无法应对") * 3 + ///
                   (EPDS_6 == "是的，有时我不能像往常一样应对") * 2 + ///
                   (EPDS_6 == "不，大部分时候我都能应对很好") * 1 + ///
                   (EPDS_6 == "不，我能像平时那样应对很好") * 0

replace score_q7 = (EPDS_7 == "是的，大部分时候这样") * 3 + ///
                   (EPDS_7 == "是的，有时候这样") * 2 + ///
                   (EPDS_7 == "不经常这样") * 1 + ///
                   (EPDS_7 == "不，一点也没有") * 0

replace score_q8 = (EPDS_8 == "是的，大部分时间这样") * 3 + ///
                   (EPDS_8 == "是的，相当多时候这样") * 2 + ///
                   (EPDS_8 == "不经常这样") * 1 + ///
                   (EPDS_8 == "一点也没有") * 0

replace score_q9 = (EPDS_9 == "是的，大部分时候这样") * 3 + ///
                   (EPDS_9 == "是的，经常这样") * 2 + ///
                   (EPDS_9 == "不经常这样") * 1 + ///
                   (EPDS_9 == "一点也没有") * 0

replace score_q10 = (EPDS_10 == "是的，经常这样") * 3 + ///
                    (EPDS_10 == "有时候这样") * 2 + ///
                    (EPDS_10 == "几乎不这样") * 1 + ///
                    (EPDS_10 == "一点也没有") * 0
	
gen EPDS_score = score_q1 + score_q2 + score_q3 + score_q4 + score_q5 + ///
                 score_q6 + score_q7 + score_q8 + score_q9 + score_q10

gen EPDS_high = (EPDS_score >= 13)

local var EPDS_score
* Standardize for mothers (mother == 1) using control group (group == 0)
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)

* Standardize for fathers (mother == 0) using control group (group == 0)
sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0


gen temp = .
	replace temp = 1 if self_booklet_usage == "是的，很频繁"
	replace temp = 2 if self_booklet_usage == "是的，有时使用"
	replace temp = 3 if self_booklet_usage == "是的，但很少"
	replace temp = 4 if self_booklet_usage == "没有，还没有用过"
drop self_booklet_usage
rename temp self_booklet_usage


gen temp = .
	replace temp = 1 if partner_booklet_usage == "是的，很频繁"
	replace temp = 2 if partner_booklet_usage == "是的，有时使用"
	replace temp = 3 if partner_booklet_usage == "是的，但很少"
	replace temp = 4 if partner_booklet_usage == "没有，还没有用过"
drop partner_booklet_usage
rename temp partner_booklet_usage

gen temp = .
	replace temp = 1 if booklet_useful == "非常不同意"
	replace temp = 2 if booklet_useful == "不同意"
	replace temp = 3 if booklet_useful == "同意"
	replace temp = 4 if booklet_useful == "非常同意"
drop booklet_useful
rename temp booklet_useful


gen temp = .
	replace temp = 1 if sms_video_watch == "没有，我并没有点击或注意到短信中的视频链接"
	replace temp = 2 if sms_video_watch == "没有，我点进了网页但没有观看视频"
	replace temp = 3 if sms_video_watch == "是的，但没有看完全部视频"
	replace temp = 4 if sms_video_watch == "是的，我看完了全部视频"
drop sms_video_watch
rename temp sms_video_watch


gen temp = .
	replace temp = 1 if total_couple_income == "低于19.9万元"
	replace temp = 2 if total_couple_income == "20-29.9万元"
	replace temp = 3 if total_couple_income == "30-39.9万元"
	replace temp = 4 if total_couple_income == "40-59.9万元"
	replace temp = 5 if total_couple_income == "60-79.9万元"
	replace temp = 6 if total_couple_income == "80-99.9万元"
	replace temp = 7 if total_couple_income == "100万元或以上"
drop total_couple_income
rename temp total_couple_income

gen temp = .
	replace temp = 1 if building_ownership == "家庭拥有的"
	replace temp = 2 if building_ownership == "我们租住的"
drop building_ownership
rename temp building_ownership


replace building_area = "200" if building_area == "200及以上"
destring building_area, replace force

/***************************************************
** FINAL CLEANUP & SAVE                         **
***************************************************/

/* -- Drop Unneeded Variables -- */

drop id lastpage startlanguage seed token ipaddr refurl attentionreport g06q70 ///
     g02q01 textdisplay* g08q03a g08q03b tpreport1 tpreport2 triplepreminder ending ///
     grouptime1960-endingtime grouptime1766-grouptime1466 EPDS_1-EPDS_10 g08q01asq001-g08q06b score_*



/* -- Rename and Order Hospital ID -- */
rename attribute_11 hospital_id
order hospital_id group mother

/* -- Drop Unneeded Attributes -- */
drop attribute_1-attribute_10
drop if hospital_id == ""
// drop grouptime1057-grouptime1117
drop hided*
drop grouptime*
/* -- Save Final Dataset -- */
save "$proc/1m_`date'.dta", replace




