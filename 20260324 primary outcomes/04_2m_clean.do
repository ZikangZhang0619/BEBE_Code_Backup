********************************************************************************
* TITLE: Data Cleaning for 2M SURVEY, Since Formal Recruitment Sept24 2024
* Project: BEBE - Primary Outcomes
* Data: 2m Survey
* Author: Haoyue Wu
* Last updated: Nov19 2025
********************************************************************************

/*  (Survey id): 
2m:
    643199
    714695
    795738
    448999
    184411
    753661
    669218
    792737

2m onsite:
    815998
    184411
    265968
    924349
    446773

*/

        /*
        This file is to clean the data from the 2m survey 
        INPUT: csv files from the 1m survey
        OUTPUT: $proc/2m_`date'.dta
        */


*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 04_2m_clean
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd

*************************
** READ & EXPLORE DATA **
*************************


*---------------------*
* Survey 643199
*---------------------*
import delimited using "$data/2m/results-survey643199.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "643199"
tostring g09q01 g09q02,replace

tempfile 2m_1
save `2m_1'

*---------------------*
* Survey 714695
*---------------------*
import delimited using "$data/2m/results-survey714695.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "714695"

tempfile 2m_2
save `2m_2'

append using `2m_1'

/************************************
 *      RENAME VARIABLES (1/2)      *
 ************************************/
// Rename sibling and income variables:
rename g09q01 sibling_num
rename g09q02 sibling_num_partner
rename g09q03 total_couple_income
rename g09q04sq001 income_share_couple
rename g10q01sq001 prebirth_workdays
rename g10q02sq001 prebirth_workhours

tempfile 2m_11
save `2m_11'

*---------------------*
* Survey 795738
*---------------------*
// only use updated predetermined characteristic at 795738
import delimited using "$data/2m/results-survey795738.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "795738"


rename r496q0sq001 paternity_leave_taken
rename r272q0 maternity_leave_taken

rename r387q0 education_level
rename r32q0 self_brother_num
rename r17q0 self_sister_num
rename r97q0 partner_brother_num
rename r704q0 partner_sister_num
rename g01q06 parents_alive
rename g01q07 close_to_parents
rename g01q07other close_to_parents_other
rename r903q0 occupation_description
rename g12q02 total_couple_income
rename g12q03 income_share_couple
rename g12q04 building_area
rename g12q05 building_ownership
rename g12q05other building_ownership_other
rename g13q01 prebirth_workdays
rename g13q02 prebirth_workhours

append using `2m_11'


rename g01q01 father_involv_diaper
rename g01q02 father_involv_night
rename g01q03 father_involv_play
rename g01q04 father_involv_lull
rename g01q05 father_care_alone

// Rename household tasks:
rename g02q01 mental_load_household_task
rename g02q02 mental_load_balance

// Rename partner support variables:
rename g03q01 partner_support_help_me
rename g03q02 partner_support_emo_suppo
rename g03q03 partner_support_talk_problem
rename g03q04 partner_support_make_decision

// Rename childcare disagreement:
rename g04q01 disagreement_partner

// Rename maternal gatekeeping (F/M):
rename g05q0101 maternal_gatekeeping_F1
rename g05q0102 maternal_gatekeeping_F2
rename g05q0103 maternal_gatekeeping_F3
rename g05q0104 maternal_gatekeeping_F4
rename g05q0107 maternal_gatekeeping_F5
rename g05q0108 maternal_gatekeeping_F6
rename g05q0109 maternal_gatekeeping_F7
rename g05q0110 maternal_gatekeeping_F8

rename g05q0201 maternal_gatekeeping_M1
rename g05q0202 maternal_gatekeeping_M2
rename g05q0203 maternal_gatekeeping_M3
rename g05q0204 maternal_gatekeeping_M4
rename g05q0207 maternal_gatekeeping_M5
rename g05q0208 maternal_gatekeeping_M6
rename g05q0209 maternal_gatekeeping_M7
rename g05q0210 maternal_gatekeeping_M8

// Rename parent identity variables:
rename g06q01 parent_identity_security
rename g06q02 parent_identity_future_opt
rename g06q03 parent_identity_reflect_baby
rename g06q04 parent_identity_talk_baby
rename g06q05 parent_identity_no_children
rename g06q06 father_work_priority
rename g06q07 father_identity_importance

// Rename tp best practices:
rename g07q01 best_to_spend
rename g07q02 best_to_talk

// Rename baby blues indicators:
rename g07q03sq001 baby_blues_1
rename g07q03sq002 baby_blues_2
rename g07q03sq003 baby_blues_3
rename g07q03sq004 baby_blues_4
rename g07q03sq005 baby_blues_5

// Rename Triple P usage and video variables:
rename g08q01 self_triplep_usage
rename g08q02 partner_triplep_usage
rename g08q03 remember_video
rename g08q04 video_thought
rename g08q05 talked_video_with_partner


// Rename extra help plan and after birth assistance:
rename g11q01 change_extra_help_plan
rename g11q01other change_extra_help_plan_other
rename g11q02sq001 help_afterbirth_nanny
rename g11q02sq002 help_afterbirth_mother
rename g11q02sq003 help_ab_partner_mother
rename g11q02sq004 help_afterbirth_other_family
rename g11q02sq005 help_afterbirth_no
rename g11q02other help_afterbirth_other
rename g11q03sq001 plan_help_afterbirth_nanny
rename g11q03sq002 plan_help_afterbirth_mother
rename g11q03sq003 plan_help_ab_partner_mother
rename g11q03sq004 plan_help_ab_other_family
rename g11q03sq005 plan_help_afterbirth_no
rename g11q03other plan_help_afterbirth_other

// Rename willingness to pay variables:
rename g12q01sq001 WTP0
rename g12q01sq002 WTP100
rename g12q01sq003 WTP200
rename g12q01sq004 WTP300
rename g12q01sq005 WTP400
rename g12q01sq006 WTP500
rename g12q01sq007 WTP600
rename g12q01sq008 WTP700
rename g12q01sq009 WTP800
rename g12q01sq010 WTP900
rename g12q01sq011 WTP1000


replace prebirth_workhours = "4" if prebirth_workhours == "不超过4小时"
replace prebirth_workhours = "14" if prebirth_workhours == "不少于14小时"
replace prebirth_workhours = subinstr(prebirth_workhours,"小时","",.)
destring prebirth_workhours, replace force

drop if submitdate == ""

gen group = 0
replace group = 1 if attribute_5 == "Y"
replace group = 2 if attribute_6 == "Y"

gen mother = 1
replace mother = 0 if attribute_8 == "Y"

rename attribute_11 hospital_id

order hospital_id group mother
drop if hospital_id == ""
/* drop firstname-attribute_10 */

local fatherinvolv "father_involv_diaper father_involv_night father_involv_play father_involv_lull"
foreach var in `fatherinvolv' {
	replace `var' = subinstr(`var',"次及以上","",.)
	replace `var' = subinstr(`var',"次","",.)
	destring `var', replace force
}

gen father_involv_score = father_involv_diaper + father_involv_night + father_involv_play + father_involv_lull

local var father_involv_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0

gen temp = .
replace temp = 1 if father_care_alone == "不超过2分钟"
replace temp = 2 if father_care_alone == "3-15分钟"
replace temp = 3 if father_care_alone == "16-30分钟"
replace temp = 4 if father_care_alone == "31-60分钟"
replace temp = 5 if father_care_alone == "1-2小时"
replace temp = 6 if father_care_alone == "超过2小时"
drop father_care_alone
rename temp father_care_alone


// -- Recode Mental Load --
foreach var in mental_load_household_task mental_load_balance {
    gen temp = .
    if "`var'" == "mental_load_household_task" {
        replace temp = 1 if mental_load_household_task == "一点也不"
        replace temp = 2 if mental_load_household_task == "有一点"
        replace temp = 3 if mental_load_household_task == "有一些"
        replace temp = 4 if mental_load_household_task == "比较多"
        replace temp = 5 if mental_load_household_task == "非常多"
    }
    else {
        replace temp = 1 if mental_load_balance == "一点也不"
        replace temp = 2 if mental_load_balance == "有一点"
        replace temp = 3 if mental_load_balance == "有一些"
        replace temp = 4 if mental_load_balance == "比较多"
        replace temp = 5 if mental_load_balance == "非常多"
    }
    drop `var'
    rename temp `var'
}


local partnerVars "partner_support_help_me partner_support_emo_suppo partner_support_talk_problem partner_support_make_decision"
foreach var in `partnerVars' {
    gen temp = .
    replace temp = 1 if `var' == "极度不同意"
    replace temp = 2 if `var' == "非常不同意"
    replace temp = 3 if `var' == "有点不同意"
    replace temp = 4 if `var' == "中立"
    replace temp = 5 if `var' == "有点同意"
    replace temp = 6 if `var' == "非常同意"
    replace temp = 7 if `var' == "极度同意"
    drop `var'
    rename temp `var'
}

gen partner_support_score = partner_support_help_me + partner_support_emo_suppo + partner_support_talk_problem + partner_support_make_decision

local var partner_support_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0

gen temp = .
replace temp = 1 if disagreement_partner == "几乎每天"
replace temp = 2 if disagreement_partner == "大约一半的天数"
replace temp = 3 if disagreement_partner == "有过一到两天"
replace temp = 4 if disagreement_partner == "更少出现"
drop disagreement_partner
rename temp disagreement_partner

local maternalVars "maternal_gatekeeping_F1 maternal_gatekeeping_F2 maternal_gatekeeping_F3 maternal_gatekeeping_F4 maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 maternal_gatekeeping_M1 maternal_gatekeeping_M2 maternal_gatekeeping_M3 maternal_gatekeeping_M4 maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8"
foreach var in `maternalVars' {
    gen temp = .
    replace temp = 1 if `var' == "一天发生几次"
    replace temp = 2 if `var' == "一周发生几次"
    replace temp = 3 if `var' == "一个月发生几次"
    replace temp = 4 if `var' == "更少出现"
    replace temp = 5 if `var' == "从未有过"
    drop `var'
    rename temp `var'
}

foreach var in maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 ///
              maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8 {
    gen rev_`var' = 6 - `var'
}

gen maternal_gatekeeping_score_F = ///
    maternal_gatekeeping_F1 + maternal_gatekeeping_F2 + maternal_gatekeeping_F3 + maternal_gatekeeping_F4 + ///
    rev_maternal_gatekeeping_F5 + rev_maternal_gatekeeping_F6 + rev_maternal_gatekeeping_F7 + rev_maternal_gatekeeping_F8



gen maternal_gatekeeping_score_M = ///
    maternal_gatekeeping_M1 + maternal_gatekeeping_M2 + maternal_gatekeeping_M3 + maternal_gatekeeping_M4 + ///
    rev_maternal_gatekeeping_M5 + rev_maternal_gatekeeping_M6 + rev_maternal_gatekeeping_M7 + rev_maternal_gatekeeping_M8

local var maternal_gatekeeping_score_F
sum `var' if group == 0  // Replace 'treatment' with your control group indicator
scalar control_mean = r(mean)
scalar control_sd = r(sd)

// Standardize using control group parameters
gen gatekeeping_score_F_std = (`var' - control_mean) / control_sd

local var maternal_gatekeeping_score_M
sum `var' if group == 0  // Replace 'treatment' with your control group indicator
scalar control_mean = r(mean)
scalar control_sd = r(sd)

// Standardize using control group parameters
gen gatekeeping_score_M_std = (`var' - control_mean) / control_sd


local parentIdVars "parent_identity_security parent_identity_future_opt parent_identity_reflect_baby parent_identity_talk_baby parent_identity_no_children"
foreach var in `parentIdVars' {
    gen temp = .
    replace temp = 1 if `var' == "非常不同意"
    replace temp = 2 if `var' == "不同意"
    replace temp = 3 if `var' == "中立"
    replace temp = 4 if `var' == "同意"
    replace temp = 5 if `var' == "非常同意"
    drop `var'
    rename temp `var'
}

gen rev_parent_ident_no_children = 6 - parent_identity_no_children
gen parent_identity_score = parent_identity_security + parent_identity_future_opt + parent_identity_reflect_baby + parent_identity_talk_baby + rev_parent_ident_no_children

local var parent_identity_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0




local genderattitu "father_work_priority father_identity_importance"
foreach i in `genderattitu'{
    fre `i'
}
foreach var in `genderattitu'{
	gen temp = .
	replace temp = 1 if `var' == "非常不同意"
	replace temp = 2 if `var' == "不同意"
	replace temp = 3 if `var' == "中立"
	replace temp = 4 if `var' == "同意"
	replace temp = 5 if `var' == "非常同意"
	drop `var'
	rename temp `var'
}


gen temp = 0
replace temp = 1 if best_to_spend == "从早到晚都频繁地和宝宝玩，每次玩1-2分钟。"
drop best_to_spend
rename temp best_to_spend

gen temp = 0
replace temp = 1 if best_to_talk == "语速慢一点，声音要欢快，面部表情要清晰，用词要夸张。"
drop best_to_talk
rename temp best_to_talk


local babyBlues "baby_blues_1 baby_blues_2 baby_blues_3 baby_blues_4 baby_blues_5"
foreach var in `babyBlues' {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}
gen baby_blues = .
replace baby_blues = 0 if baby_blues != .
replace baby_blues = baby_blues_1 + baby_blues_3

gen triple_p_correct = baby_blues + best_to_spend + best_to_talk
drop baby_blues baby_blues_1-baby_blues_5 best_to_talk best_to_spend

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

gen temp = .
replace temp = 1 if self_triplep_usage == "从未用过"
replace temp = 2 if self_triplep_usage == "用过1次"
replace temp = 3 if self_triplep_usage == "用过2-3次"
replace temp = 4 if self_triplep_usage == "用过4-6次"
replace temp = 5 if self_triplep_usage == "用过7-10次"
replace temp = 6 if self_triplep_usage == "用过10次以上"
drop self_triplep_usage
rename temp self_triplep_usage

gen temp = .
replace temp = 1 if partner_triplep_usage == "从未用过"
replace temp = 2 if partner_triplep_usage == "用过1次"
replace temp = 3 if partner_triplep_usage == "用过2-3次"
replace temp = 4 if partner_triplep_usage == "用过4-6次"
replace temp = 5 if partner_triplep_usage == "用过7-10次"
replace temp = 6 if partner_triplep_usage == "用过10次以上"
drop partner_triplep_usage
rename temp partner_triplep_usage

gen temp = .
replace temp = 1 if remember_video == "不记得"
replace temp = 2 if remember_video == "依稀记得"
replace temp = 3 if remember_video == "记得"
drop remember_video
rename temp remember_video


gen temp = .
replace temp = 1 if talked_video_with_partner == "没有"
replace temp = 2 if talked_video_with_partner == "是的，谈了一点"
replace temp = 3 if talked_video_with_partner == "是的，谈了很多"
drop talked_video_with_partner
rename temp talked_video_with_partner
/* 
gen temp = .
replace temp = 1 if sibling_num == "0"
replace temp = 2 if sibling_num == "1"
replace temp = 3 if sibling_num == "2"
replace temp = 4 if sibling_num == "3个或更多"
drop sibling_num
rename temp sibling_num

gen temp = .
replace temp = 1 if sibling_num_partner == "0"
replace temp = 2 if sibling_num_partner == "1"
replace temp = 3 if sibling_num_partner == "2"
replace temp = 4 if sibling_num_partner == "3个或更多"
drop sibling_num_partner
rename temp sibling_num_partner

gen temp = .
	replace temp = 1 if education_level == "高中毕业或以下"
	replace temp = 2 if education_level == "专科毕业"
	replace temp = 3 if education_level == "本科毕业"
	replace temp = 4 if education_level == "硕士毕业或博士毕业"
drop education_level
rename temp education_level

local siblingList "self_brother_num self_sister_num partner_brother_num partner_sister_num"
foreach var in `siblingList' {
    gen temp = .
    replace temp = 1 if `var' == "0"
    replace temp = 2 if `var' == "1"
    replace temp = 3 if `var' == "2"
    replace temp = 4 if `var' == "3个或更多"
    drop `var'
    rename temp `var'
}
gen self_sibling_num = self_brother_num + self_sister_num
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
rename temp close_to_parents


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

tostring building_area,replace force
replace building_area = "200" if building_area == "200及以上"
destring building_area, replace force */

local helpVars "help_afterbirth_nanny help_afterbirth_mother help_ab_partner_mother help_afterbirth_other_family"
foreach var in `helpVars' {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}

local planHelpVars "plan_help_afterbirth_nanny plan_help_afterbirth_mother plan_help_ab_partner_mother plan_help_ab_other_family"
foreach var in `planHelpVars' {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}

local WTPVars "WTP0 WTP100 WTP1000 WTP200 WTP300 WTP400 WTP500 WTP600 WTP700 WTP800 WTP900"
foreach var of local WTPVars {
    replace `var' = "1" if `var' == "是"
    replace `var' = "0" if `var' == "否"
    destring `var', replace
}


gen WTP_value = .
replace WTP_value = 0 if WTP100 == 0
replace WTP_value = 100 if WTP100 == 1 & WTP200 == 0
replace WTP_value = 200 if WTP200 == 1 & WTP300 == 0
replace WTP_value = 300 if WTP300 == 1 & WTP400 == 0
replace WTP_value = 400 if WTP400 == 1 & WTP500 == 0
replace WTP_value = 500 if WTP500 == 1 & WTP600 == 0
replace WTP_value = 600 if WTP600 == 1 & WTP700 == 0
replace WTP_value = 700 if WTP700 == 1 & WTP800 == 0
replace WTP_value = 800 if WTP800 == 1 & WTP900 == 0
replace WTP_value = 900 if WTP900 == 1 & WTP1000 == 0
replace WTP_value = 1000 if WTP1000 == 1
drop WTP0 WTP100 WTP1000 WTP200 WTP300 WTP400 WTP500 WTP600 WTP700 WTP800 WTP900

drop id lastpage startlanguage seed token ipaddr refurl priming1positive textdisplay01 ///
    priming1negative textdisplay02 priming2positive priming2negative textdisplay03 textdisplay04 ///
    hidedg05q0105 hidedg05q0106 textdisplay05 hidedg05q0205 hidedg05q0206 textdisplay06 textdisplay07 ///
    textdisplay08 tpreport1 tpreport2 tpreport3 textdisplay09 ending ///
    grouptime1519-endingtime grouptime1428-grouptime1238

// label variables
foreach var of varlist * {
    label var `var' "`var'"
}

// drop if hospital_id == ""
drop if hospital_id == "D00341883"
capture drop  rev_maternal_* maternal_gatekeeping_F1-maternal_gatekeeping_F8 maternal_gatekeeping_M1-maternal_gatekeeping_M8


save "$proc/2m_20250814.dta", replace




//************************************
 *         SURVEY 448999            *
 ************************************/
 // new 2m survey design
import delimited using "$data/2m/results-survey448999.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "448999"

rename g11q01sq001 WTP0
rename g11q01sq002 WTP100
rename g11q01sq003 WTP200
rename g11q01sq004 WTP300
rename g11q01sq005 WTP400
rename g11q01sq006 WTP500
rename g11q01sq007 WTP600
rename g11q01sq008 WTP700
rename g11q01sq009 WTP800
rename g11q01sq010 WTP900
rename g11q01sq011 WTP1000

tempfile 2m_1
save `2m_1'

import delimited using "$data/2m/results-survey162992.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "162992"

rename g11q01 WTP500
rename g11q02 WTP600
rename g11q03 WTP700
rename g11q04 WTP800
rename g11q05 WTP900
rename g11q06 WTP1000
rename g11q07 WTP400
rename g11q08 WTP300
rename g11q09 WTP200
rename g11q10 WTP100
rename g11q11 WTP0

tempfile 2m_2
save `2m_2'

import delimited using "$data/2m/results-survey753661.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "753661"

rename g11q01 WTP500
rename g11q02 WTP600
rename g11q03 WTP700
rename g11q04 WTP800
rename g11q05 WTP900
rename g11q06 WTP1000
rename g11q07 WTP400
rename g11q08 WTP300
rename g11q09 WTP200
rename g11q10 WTP100
rename g11q11 WTP0

append using `2m_1', force
append using `2m_2', force

tempfile 2m_3
save `2m_3'

// 2m survey add belief qs
import delimited using "$data/2m/results-survey669218.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "669218"

rename g11q01 WTP500
rename g11q02 WTP600
rename g11q03 WTP700
rename g11q04 WTP800
rename g11q05 WTP900
rename g11q06 WTP1000
rename g11q07 WTP400
rename g11q08 WTP300
rename g11q09 WTP200
rename g11q10 WTP100
rename g11q11 WTP0

tempfile 2m_4
save `2m_4'

import delimited using "$data/2m/results-survey792737.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "792737"

rename g11q01 WTP500
rename g11q02 WTP600
rename g11q03 WTP700
rename g11q04 WTP800
rename g11q05 WTP900
rename g11q06 WTP1000
rename g11q07 WTP400
rename g11q08 WTP300
rename g11q09 WTP200
rename g11q10 WTP100
rename g11q11 WTP0

tempfile 2m_5
save `2m_5'

use `2m_3', clear
append using `2m_4', force
append using `2m_5', force

drop if submitdate == ""

gen group = 0
replace group = 1 if attribute_5 == "Y"
replace group = 2 if attribute_6 == "Y"

gen mother = 1
replace mother = 0 if attribute_8 == "Y"

rename attribute_11 hospital_id

//  accompany to hospital
rename g00q03sq001 accompany_nobody
rename g00q03sq003 accompany_parents
rename g00q03sq004 accompany_parents_in_law
rename g00q03sq005 accompany_relatives
rename g00q03sq006 accompany_nanny
rename g00q03sq007 accompany_not_checked
rename g00q03other accompany_other

local accompany "accompany_nobody accompany_parents accompany_parents_in_law accompany_relatives accompany_nanny accompany_not_checked"
foreach var in `accompany'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}


gen father_time_off_diff_actual = ""
replace father_time_off_diff_actual = g00q04
replace father_time_off_diff_actual = g00q06 if father_time_off_diff_actual == ""

gen father_time_off_diff_hypo = ""
replace father_time_off_diff_hypo = g00q05
replace father_time_off_diff_hypo = g00q08 if father_time_off_diff_hypo == ""

drop g00q04 g00q05 g00q06 g00q08

local difficulty "father_time_off_diff_actual father_time_off_diff_hypo"
foreach var in `difficulty'{
gen temp = .
replace temp = 1 if `var' == "几乎不可能"
replace temp = 2 if `var' == "非常困难"
replace temp = 3 if `var' == "比较困难"
replace temp = 4 if `var' == "比较容易"
replace temp = 5 if `var' == "非常容易"
drop `var'
rename temp `var'
}

gen if_join_checkup_f = (g00q07 == "是， 我去了")
gen if_join_checkup_m = 1 if g00q03sq002 == "是"
replace if_join_checkup_m = 0 if g00q03sq002 == "否"
drop g00q07 g00q03sq002


// father involvement
rename g01q01 father_involv_diaper
rename g01q02 father_involv_night
rename g01q03 father_involv_play
rename g01q04 father_involv_lull


local fatherinvolv "father_involv_diaper father_involv_night father_involv_play father_involv_lull"
foreach var in `fatherinvolv' {
    fre `var'
	replace `var' = subinstr(`var',"次及以上","",.)
	replace `var' = subinstr(`var',"次","",.)
	destring `var', replace force
}

gen father_involv_score = father_involv_diaper + father_involv_night + father_involv_play + father_involv_lull
local var father_involv_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0



// father care alone
rename g01q05 father_care_alone
gen temp = .
replace temp = 1 if father_care_alone == "不超过2分钟"
replace temp = 2 if father_care_alone == "3-15分钟"
replace temp = 3 if father_care_alone == "16-30分钟"
replace temp = 4 if father_care_alone == "31-60分钟"
replace temp = 5 if father_care_alone == "1-2小时"
replace temp = 6 if father_care_alone == "超过2小时"
drop father_care_alone
rename temp father_care_alone

// EPDS
rename g02q10 EPDS_1
rename g02q11 EPDS_2
rename g02q12 EPDS_3
rename g02q13 EPDS_4
rename g02q14 EPDS_5
rename g02q15 EPDS_6
rename g02q16 EPDS_7
rename g02q17 EPDS_8
rename g02q18 EPDS_9
rename g02q19 EPDS_10


// EPDS score
forvalues i = 1/10 {
    gen score_q`i' = .
}

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
sum `var' if group == 0  // Replace 'treatment' with your control group indicator
scalar control_mean = r(mean)
scalar control_sd = r(sd)


gen `var'_z = (`var' - control_mean) / control_sd

drop score_* EPDS_1-EPDS_10



// partner mental health
rename g03q01 partner_MH
gen temp = .
replace temp = 1 if partner_MH == "非常不好"
replace temp = 2 if partner_MH == "比较不好"
replace temp = 3 if partner_MH == "一般"
replace temp = 4 if partner_MH == "比较好"
replace temp = 5 if partner_MH == "非常好"
drop partner_MH
rename temp partner_MH


// partner support
rename g04q01 partner_support_help_me
rename g04q02 partner_support_emo_suppo
rename g04q03 partner_support_talk_problem
rename g04q04 partner_support_make_decision

local partnerVars "partner_support_help_me partner_support_emo_suppo partner_support_talk_problem partner_support_make_decision"
foreach var in `partnerVars' {
    gen temp = .
    replace temp = 1 if `var' == "极度不同意"
    replace temp = 2 if `var' == "非常不同意"
    replace temp = 3 if `var' == "有点不同意"
    replace temp = 4 if `var' == "中立"
    replace temp = 5 if `var' == "有点同意"
    replace temp = 6 if `var' == "非常同意"
    replace temp = 7 if `var' == "极度同意"
    drop `var'
    rename temp `var'
}

gen partner_support_score = partner_support_help_me + partner_support_emo_suppo + partner_support_talk_problem + partner_support_make_decision

local var partner_support_score
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0


// 	Disagreement with partner 
rename g05q01 disagreement_partner

gen temp = .
replace temp = 1 if disagreement_partner == "几乎每天"
replace temp = 2 if disagreement_partner == "大约一半的天数"
replace temp = 3 if disagreement_partner == "有过一到两天"
replace temp = 4 if disagreement_partner == "更少出现"
drop disagreement_partner
rename temp disagreement_partner

// Maternal Gatekeeping

rename g05q0101 maternal_gatekeeping_F1
rename g05q0102 maternal_gatekeeping_F2
rename g05q0103 maternal_gatekeeping_F3
rename g05q0104 maternal_gatekeeping_F4
rename g05q0107 maternal_gatekeeping_F5
rename g05q0108 maternal_gatekeeping_F6
rename g05q0109 maternal_gatekeeping_F7
rename g05q0110 maternal_gatekeeping_F8

rename g05q0201 maternal_gatekeeping_M1
rename g05q0202 maternal_gatekeeping_M2
rename g05q0203 maternal_gatekeeping_M3
rename g05q0204 maternal_gatekeeping_M4
rename g05q0207 maternal_gatekeeping_M5
rename g05q0208 maternal_gatekeeping_M6
rename g05q0209 maternal_gatekeeping_M7
rename g05q0210 maternal_gatekeeping_M8


local maternalVars "maternal_gatekeeping_F1 maternal_gatekeeping_F2 maternal_gatekeeping_F3 maternal_gatekeeping_F4 maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 maternal_gatekeeping_M1 maternal_gatekeeping_M2 maternal_gatekeeping_M3 maternal_gatekeeping_M4 maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8"
foreach var in `maternalVars' {
    gen temp = .
    replace temp = 1 if `var' == "一天发生几次"
    replace temp = 2 if `var' == "一周发生几次"
    replace temp = 3 if `var' == "一个月发生几次"
    replace temp = 4 if `var' == "更少出现"
    replace temp = 5 if `var' == "从未有过"
    drop `var'
    rename temp `var'
}

foreach var in maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 ///
              maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8 {
    gen rev_`var' = 6 - `var'
}

gen maternal_gatekeeping_score_F = ///
    maternal_gatekeeping_F1 + maternal_gatekeeping_F2 + maternal_gatekeeping_F3 + maternal_gatekeeping_F4 + ///
    rev_maternal_gatekeeping_F5 + rev_maternal_gatekeeping_F6 + rev_maternal_gatekeeping_F7 + rev_maternal_gatekeeping_F8
gen maternal_gatekeeping_score_M = ///
    maternal_gatekeeping_M1 + maternal_gatekeeping_M2 + maternal_gatekeeping_M3 + maternal_gatekeeping_M4 + ///
    rev_maternal_gatekeeping_M5 + rev_maternal_gatekeeping_M6 + rev_maternal_gatekeeping_M7 + rev_maternal_gatekeeping_M8

local var maternal_gatekeeping_score_F
sum `var' if group == 0  
scalar control_mean = r(mean)
scalar control_sd = r(sd)

gen gatekeeping_score_F_std = (`var' - control_mean) / control_sd

local var maternal_gatekeeping_score_M
sum `var' if group == 0  
scalar control_mean = r(mean)
scalar control_sd = r(sd)

gen gatekeeping_score_M_std = (`var' - control_mean) / control_sd
drop maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 ///
              maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8 ///
              maternal_gatekeeping_F1 maternal_gatekeeping_F2 maternal_gatekeeping_F3 maternal_gatekeeping_F4 ///
              maternal_gatekeeping_M1 maternal_gatekeeping_M2 maternal_gatekeeping_M3 maternal_gatekeeping_M4 ///
              maternal_gatekeeping_score_F maternal_gatekeeping_score_M
              

// belief : 669218 792737
rename g12q01 extra_time_motor_dev
rename g12q03 extra_time_father_wellbeing
rename g12q04 extra_time_mother_wellbeing


local belief "extra_time_motor_dev extra_time_father_wellbeing extra_time_mother_wellbeing "
foreach var in `belief'{
gen temp = .
replace temp = 1 if `var' == "完全没有帮助" 
replace temp = 2 if `var' == "帮助有限" 
replace temp = 3 if `var' == "有一些帮助" 
replace temp = 4 if `var' == "帮助很大" 
replace temp = 5 if `var' == "帮助非常大" 
drop `var'
rename temp `var'
}

gen belief_score = extra_time_motor_dev + extra_time_father_wellbeing + extra_time_mother_wellbeing
local var belief_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0


// ability: 669218 792737
rename g08q03a ability_father
rename g08q03b ability_mother

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


// parent identity
rename g06q01 parent_identity_security
rename g06q02 parent_identity_future_opt
rename g06q03 parent_identity_reflect_baby
rename g06q04 parent_identity_talk_baby
rename g06q05 parent_identity_no_children

local parentIdVars "parent_identity_security parent_identity_future_opt parent_identity_reflect_baby parent_identity_talk_baby parent_identity_no_children"
foreach var in `parentIdVars' {
    gen temp = .
    replace temp = 1 if `var' == "非常不同意"
    replace temp = 2 if `var' == "不同意"
    replace temp = 3 if `var' == "中立"
    replace temp = 4 if `var' == "同意"
    replace temp = 5 if `var' == "非常同意"
    drop `var'
    rename temp `var'
}

gen rev_parent_ident_no_children = 6 - parent_identity_no_children
gen parent_identity_score = parent_identity_security + parent_identity_future_opt + parent_identity_reflect_baby + parent_identity_talk_baby + rev_parent_ident_no_children

local var parent_identity_score
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0



// gender identity
rename g06q06 father_work_priority
rename g06q07 father_identity_importance

local genderattitu "father_work_priority father_identity_importance"
foreach i in `genderattitu'{
    fre `i'
}
foreach var in `genderattitu'{
	gen temp = .
	replace temp = 1 if `var' == "非常不同意"
	replace temp = 2 if `var' == "不同意"
	replace temp = 3 if `var' == "中立"
	replace temp = 4 if `var' == "同意"
	replace temp = 5 if `var' == "非常同意"
	drop `var'
	rename temp `var'
}

// predetermined characteristics： build the variable when merging
rename g09q01 education_level
rename g09q02 self_brother_num
rename g09q03 self_sister_num
rename g09q04 partner_brother_num
rename g09q05 partner_sister_num
rename g09q06 parents_alive
rename g09q07 close_to_parents
rename g09q07other close_to_parents_other
rename g09q08 occupation_description
rename g09q09 total_couple_income
rename g09q10 income_share_couple
rename g09q11 building_area
rename g09q12 building_ownership
rename g09q12other building_ownership_other
rename g10q01 prebirth_workdays
rename g10q02 prebirth_workhours


// nanny
rename g07q02sq001 help_current_nanny
rename g07q02sq002 help_current_my_mother
rename g07q02sq003 help_current_partner_mother
rename g07q02sq004 help_current_other_family
rename g07q02sq005 help_current_no
rename g07q02other help_current_other


rename g07q03sq001 help_nextmonth_nanny
rename g07q03sq002 help_nextmonth_my_mother
rename g07q03sq003 help_nextmonth_partner_mother
rename g07q03sq004 help_nextmonth_other_family
rename g07q03sq005 help_nextmonth_no
rename g07q03other help_nextmonth_other

local care "help_current_nanny help_current_my_mother help_current_partner_mother help_current_no help_current_other_family help_nextmonth_nanny help_nextmonth_my_mother help_nextmonth_partner_mother help_nextmonth_other_family help_nextmonth_no"
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}

// paternity and maternity leave
rename g08q01sq001 paternity_leave_taken
rename g08q02 maternity_leave_taken


// WTP
if survey_id == "448999" {
local WTPVars "WTP0 WTP100 WTP1000 WTP200 WTP300 WTP400 WTP500 WTP600 WTP700 WTP800 WTP900"
foreach var of local WTPVars {
    replace `var' = "1" if `var' == "是"
    replace `var' = "0" if `var' == "否"
    destring `var', replace
}
}

if survey_id == "162992" | survey_id == "753661" | survey_id == "669218" | survey_id == "792737" {
local WTPVars "WTP0 WTP100 WTP1000 WTP200 WTP300 WTP400 WTP500 WTP600 WTP700 WTP800 WTP900"
foreach var of local WTPVars {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}
}


gen WTP_value = .
replace WTP_value = 0 if WTP100 == 0
replace WTP_value = 100 if WTP100 == 1 & WTP200 == 0
replace WTP_value = 200 if WTP200 == 1 & WTP300 == 0
replace WTP_value = 300 if WTP300 == 1 & WTP400 == 0
replace WTP_value = 400 if WTP400 == 1 & WTP500 == 0
replace WTP_value = 500 if WTP500 == 1 & WTP600 == 0
replace WTP_value = 600 if WTP600 == 1 & WTP700 == 0
replace WTP_value = 700 if WTP700 == 1 & WTP800 == 0
replace WTP_value = 800 if WTP800 == 1 & WTP900 == 0
replace WTP_value = 900 if WTP900 == 1 & WTP1000 == 0
replace WTP_value = 1000 if WTP1000 == 1
drop WTP0 WTP100 WTP1000 WTP200 WTP300 WTP400 WTP500 WTP600 WTP700 WTP800 WTP900

drop id lastpage datestamp startlanguage seed token startdate ipaddr refurl textdisplay* r674q0 g07q01 g07q01other ending grouptime2017-endingtime grouptime1667-grouptime1810
drop hided* grouptime*
drop rev_maternal_*
// label variables
foreach var of varlist * {
    label var `var' "`var'"
}

drop if hospital_id == ""



/************************************
 *         FINAL DATA SET           *
 ************************************/

save "$proc/2m_new_version_`date'.dta", replace

append using "$proc/2m_20250814.dta", force
capture drop id lastpage datestamp startlanguage seed token startdate ipaddr refurl textdisplay* r674q0 g07q01 g07q01other ending grouptime2017-endingtime grouptime1667-grouptime1810
capture drop hided* grouptime*
capture drop  rev_maternal_* maternal_gatekeeping_F1-maternal_gatekeeping_F8 maternal_gatekeeping_M1-maternal_gatekeeping_M8


order firstname lastname group mother hospital_id 
drop g12q01time g12q03time g12q04time g08q03atime g08q03btime startdate datestamp hided 
save "$proc/2m_online_`date'.dta", replace






//************************************
 *         SURVEY Onsite            *
 ************************************/
 // new 2m survey design

import delimited using "$data/2m/results-survey815998.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "815998"
tempfile onsite_1
save `onsite_1'

import delimited using "$data/2m/results-survey184411.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "184411"
tempfile onsite_2
save `onsite_2'

import delimited using "$data/2m/results-survey265968.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "265968"
tempfile onsite_3
save `onsite_3'

import delimited using "$data/2m/results-survey924349.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "924349"
tempfile onsite_4
save `onsite_4'

import delimited using "$data/2m/results-survey446773.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "446773"

append using `onsite_1'
append using `onsite_2'
append using `onsite_3'
append using `onsite_4'


* rename variables *
* ---------------- *


drop if submitdate == ""

rename g00q01sq001 hospital_id
gen mother = 0
replace mother = 1 if g00q02 == "妈妈"
drop g00q02

destring group, replace

rename g00q03sq001 accompany_nobody
rename g00q03sq003 accompany_parents
rename g00q03sq004 accompany_parents_in_law
rename g00q03sq005 accompany_relatives
rename g00q03sq006 accompany_nanny
rename g00q03other accompany_other

local accompany "accompany_nobody accompany_parents accompany_parents_in_law accompany_relatives accompany_nanny"
foreach var in `accompany'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}


gen father_time_off_diff_actual = ""
replace father_time_off_diff_actual = g00q04
replace father_time_off_diff_actual = g00q06 if father_time_off_diff_actual == ""

gen father_time_off_diff_hypo = ""
replace father_time_off_diff_hypo = g00q05

drop g00q04 g00q05 g00q06 

local difficulty "father_time_off_diff_actual father_time_off_diff_hypo"
foreach var in `difficulty'{
gen temp = .
replace temp = 1 if `var' == "几乎不可能"
replace temp = 2 if `var' == "非常困难"
replace temp = 3 if `var' == "比较困难"
replace temp = 4 if `var' == "比较容易"
replace temp = 5 if `var' == "非常容易"
drop `var'
rename temp `var'
}

gen if_join_checkup_f = (mother == 0)
gen if_join_checkup_m = 1 if g00q03sq002 == "是"
replace if_join_checkup_m = 0 if g00q03sq002 == "否"
drop g00q03sq002




rename g01q01 father_involv_diaper
rename g01q02 father_involv_night
rename g01q03 father_involv_play
rename g01q04 father_involv_lull
rename g01q05 father_care_alone

rename g02q10 EPDS_1
rename g02q11 EPDS_2
rename g02q12 EPDS_3
rename g02q13 EPDS_4
rename g02q14 EPDS_5
rename g02q15 EPDS_6
rename g02q16 EPDS_7
rename g02q17 EPDS_8
rename g02q18 EPDS_9
rename g02q19 EPDS_10

rename g03q01 partner_MH

rename g04q01 partner_support_help_me
rename g04q02 partner_support_emo_suppo
rename g04q03 partner_support_talk_problem
rename g04q04 partner_support_make_decision

rename g05q01 disagreement_partner

rename g05q0101 maternal_gatekeeping_F1
rename g05q0102 maternal_gatekeeping_F2
rename g05q0103 maternal_gatekeeping_F3
rename g05q0104 maternal_gatekeeping_F4
rename g05q0107 maternal_gatekeeping_F5
rename g05q0108 maternal_gatekeeping_F6
rename g05q0109 maternal_gatekeeping_F7
rename g05q0110 maternal_gatekeeping_F8

rename g05q0201 maternal_gatekeeping_M1
rename g05q0202 maternal_gatekeeping_M2
rename g05q0203 maternal_gatekeeping_M3
rename g05q0204 maternal_gatekeeping_M4
rename g05q0207 maternal_gatekeeping_M5
rename g05q0208 maternal_gatekeeping_M6
rename g05q0209 maternal_gatekeeping_M7
rename g05q0210 maternal_gatekeeping_M8

rename g12q01 extra_time_motor_dev
rename g12q03 extra_time_father_wellbeing
rename g12q04 extra_time_mother_wellbeing

rename g06q01 parent_identity_security
rename g06q02 parent_identity_future_opt
rename g06q03 parent_identity_reflect_baby
rename g06q04 parent_identity_talk_baby
rename g06q05 parent_identity_no_children
rename g06q06 father_work_priority
rename g06q07 father_identity_importance


// Rename Triple P usage and video variables:
rename g08q01sq001 paternity_leave_taken
rename g08q02 maternity_leave_taken



rename g08q03a ability_father
rename g08q03b ability_mother

rename g09q01 education_level
rename g09q02 self_brother_num
rename g09q03 self_sister_num
rename g09q04 partner_brother_num
rename g09q05 partner_sister_num
rename g09q06 parents_alive
rename g09q07 close_to_parents
rename g09q07other close_to_parents_other
rename g09q08 occupation_description
rename g09q09 total_couple_income
rename g09q10 income_share_couple
rename g09q11 building_area
rename g09q12 building_ownership
rename g09q12other building_ownership_other
rename g10q01 prebirth_workdays
rename g10q02 prebirth_workhours

rename g11q01 WTP500
rename g11q02 WTP600
rename g11q03 WTP700
rename g11q04 WTP800
rename g11q05 WTP900
rename g11q06 WTP1000
rename g11q07 WTP400
rename g11q08 WTP300
rename g11q09 WTP200
rename g11q10 WTP100
rename g11q11 WTP0

replace WTP0 = g11q01sq001 if g11q01sq001 != ""
replace WTP100 = g11q01sq002 if g11q01sq002 != ""
replace WTP200 = g11q01sq003 if g11q01sq003 != ""
replace WTP300 = g11q01sq004 if g11q01sq004 != ""
replace WTP400 = g11q01sq005 if g11q01sq005 != ""
replace WTP500 = g11q01sq006 if g11q01sq006 != ""
replace WTP600 = g11q01sq007 if g11q01sq007 != ""
replace WTP700 = g11q01sq008 if g11q01sq008 != ""
replace WTP800 = g11q01sq009 if g11q01sq009 != ""
replace WTP900 = g11q01sq010 if g11q01sq010 != ""
replace WTP1000 = g11q01sq011 if g11q01sq011 != ""

drop g11q01sq001-g11q01sq011


local fatherinvolv "father_involv_diaper father_involv_night father_involv_play father_involv_lull"
foreach var in `fatherinvolv' {
    fre `var'
	replace `var' = subinstr(`var',"次及以上","",.)
	replace `var' = subinstr(`var',"次","",.)
	destring `var', replace force
}

gen father_involv_score = father_involv_diaper + father_involv_night + father_involv_play + father_involv_lull
local var father_involv_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0


gen temp = .
replace temp = 1 if father_care_alone == "不超过2分钟"
replace temp = 2 if father_care_alone == "3-15分钟"
replace temp = 3 if father_care_alone == "16-30分钟"
replace temp = 4 if father_care_alone == "31-60分钟"
replace temp = 5 if father_care_alone == "1-2小时"
replace temp = 6 if father_care_alone == "超过2小时"
drop father_care_alone
rename temp father_care_alone




// EPDS score
forvalues i = 1/10 {
    gen score_q`i' = .
}

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
sum `var' if group == 0  // Replace 'treatment' with your control group indicator
scalar control_mean = r(mean)
scalar control_sd = r(sd)


gen `var'_z = (`var' - control_mean) / control_sd

drop score_* EPDS_1-EPDS_10


gen temp = .
replace temp = 1 if partner_MH == "非常不好"
replace temp = 2 if partner_MH == "比较不好"
replace temp = 3 if partner_MH == "一般"
replace temp = 4 if partner_MH == "比较好"
replace temp = 5 if partner_MH == "非常好"
drop partner_MH
rename temp partner_MH



local partnerVars "partner_support_help_me partner_support_emo_suppo partner_support_talk_problem partner_support_make_decision"
foreach var in `partnerVars' {
    gen temp = .
    replace temp = 1 if `var' == "极度不同意"
    replace temp = 2 if `var' == "非常不同意"
    replace temp = 3 if `var' == "有点不同意"
    replace temp = 4 if `var' == "中立"
    replace temp = 5 if `var' == "有点同意"
    replace temp = 6 if `var' == "非常同意"
    replace temp = 7 if `var' == "极度同意"
    drop `var'
    rename temp `var'
}

gen partner_support_score = partner_support_help_me + partner_support_emo_suppo + partner_support_talk_problem + partner_support_make_decision

local var partner_support_score
sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0



gen temp = .
replace temp = 1 if disagreement_partner == "几乎每天"
replace temp = 2 if disagreement_partner == "大约一半的天数"
replace temp = 3 if disagreement_partner == "有过一到两天"
replace temp = 4 if disagreement_partner == "更少出现"
drop disagreement_partner
rename temp disagreement_partner


local maternalVars "maternal_gatekeeping_F1 maternal_gatekeeping_F2 maternal_gatekeeping_F3 maternal_gatekeeping_F4 maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 maternal_gatekeeping_M1 maternal_gatekeeping_M2 maternal_gatekeeping_M3 maternal_gatekeeping_M4 maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8"
foreach var in `maternalVars' {
    gen temp = .
    replace temp = 1 if `var' == "一天发生几次"
    replace temp = 2 if `var' == "一周发生几次"
    replace temp = 3 if `var' == "一个月发生几次"
    replace temp = 4 if `var' == "更少出现"
    replace temp = 5 if `var' == "从未有过"
    drop `var'
    rename temp `var'
}

foreach var in maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 ///
              maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8 {
    gen rev_`var' = 6 - `var'
}

gen maternal_gatekeeping_score_F = ///
    maternal_gatekeeping_F1 + maternal_gatekeeping_F2 + maternal_gatekeeping_F3 + maternal_gatekeeping_F4 + ///
    rev_maternal_gatekeeping_F5 + rev_maternal_gatekeeping_F6 + rev_maternal_gatekeeping_F7 + rev_maternal_gatekeeping_F8



gen maternal_gatekeeping_score_M = ///
    maternal_gatekeeping_M1 + maternal_gatekeeping_M2 + maternal_gatekeeping_M3 + maternal_gatekeeping_M4 + ///
    rev_maternal_gatekeeping_M5 + rev_maternal_gatekeeping_M6 + rev_maternal_gatekeeping_M7 + rev_maternal_gatekeeping_M8

local var maternal_gatekeeping_score_F
sum `var' if group == 0  // Replace 'treatment' with your control group indicator
scalar control_mean = r(mean)
scalar control_sd = r(sd)

// Standardize using control group parameters
gen gatekeeping_score_F_std = (`var' - control_mean) / control_sd

local var maternal_gatekeeping_score_M
sum `var' if group == 0  // Replace 'treatment' with your control group indicator
scalar control_mean = r(mean)
scalar control_sd = r(sd)

// Standardize using control group parameters
gen gatekeeping_score_M_std = (`var' - control_mean) / control_sd
drop maternal_gatekeeping_F1 maternal_gatekeeping_F2 maternal_gatekeeping_F3 maternal_gatekeeping_F4 ///
        maternal_gatekeeping_F5 maternal_gatekeeping_F6 maternal_gatekeeping_F7 maternal_gatekeeping_F8 ///
              maternal_gatekeeping_M5 maternal_gatekeeping_M6 maternal_gatekeeping_M7 maternal_gatekeeping_M8 ///
               maternal_gatekeeping_M1 maternal_gatekeeping_M2 maternal_gatekeeping_M3 maternal_gatekeeping_M4 ///
               rev_maternal_gatekeeping_M5 rev_maternal_gatekeeping_M6 rev_maternal_gatekeeping_M7 rev_maternal_gatekeeping_M8 ///
               rev_maternal_gatekeeping_F5 rev_maternal_gatekeeping_F6 rev_maternal_gatekeeping_F7 rev_maternal_gatekeeping_F8


local belief "extra_time_motor_dev extra_time_father_wellbeing extra_time_mother_wellbeing "
foreach var in `belief'{
gen temp = .
replace temp = 1 if `var' == "完全没有帮助" 
replace temp = 2 if `var' == "帮助有限" 
replace temp = 3 if `var' == "有一些帮助" 
replace temp = 4 if `var' == "帮助很大" 
replace temp = 5 if `var' == "帮助非常大" 
drop `var'
rename temp `var'
}

gen belief_score = extra_time_motor_dev  + extra_time_father_wellbeing + extra_time_mother_wellbeing
local var belief_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0




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




local parentIdVars "parent_identity_security parent_identity_future_opt parent_identity_reflect_baby parent_identity_talk_baby parent_identity_no_children"
foreach var in `parentIdVars' {
    gen temp = .
    replace temp = 1 if `var' == "非常不同意"
    replace temp = 2 if `var' == "不同意"
    replace temp = 3 if `var' == "中立"
    replace temp = 4 if `var' == "同意"
    replace temp = 5 if `var' == "非常同意"
    drop `var'
    rename temp `var'
}

gen rev_parent_ident_no_children = 6 - parent_identity_no_children
gen parent_identity_score = parent_identity_security + parent_identity_future_opt + parent_identity_reflect_baby + parent_identity_talk_baby + rev_parent_ident_no_children

local var parent_identity_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0




// nanny
rename g07q02sq001 help_current_nanny
rename g07q02sq002 help_current_my_mother
rename g07q02sq003 help_current_partner_mother
rename g07q02sq004 help_current_other_family
rename g07q02sq005 help_current_no
rename g07q02other help_current_other


rename g07q03sq001 help_nextmonth_nanny
rename g07q03sq002 help_nextmonth_my_mother
rename g07q03sq003 help_nextmonth_partner_mother
rename g07q03sq004 help_nextmonth_other_family
rename g07q03sq005 help_nextmonth_no
rename g07q03other help_nextmonth_other

local care "help_current_nanny help_current_my_mother help_current_partner_mother help_current_no help_current_other_family help_nextmonth_nanny help_nextmonth_my_mother help_nextmonth_partner_mother help_nextmonth_other_family help_nextmonth_no"
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}


local genderattitu "father_work_priority father_identity_importance"
foreach i in `genderattitu'{
    fre `i'
}
foreach var in `genderattitu'{
	gen temp = .
	replace temp = 1 if `var' == "非常不同意"
	replace temp = 2 if `var' == "不同意"
	replace temp = 3 if `var' == "中立"
	replace temp = 4 if `var' == "同意"
	replace temp = 5 if `var' == "非常同意"
	drop `var'
	rename temp `var'
}



local WTPVars "WTP0 WTP100 WTP1000 WTP200 WTP300 WTP400 WTP500 WTP600 WTP700 WTP800 WTP900"
foreach var of local WTPVars {
    replace `var' = "1" if `var' == "是"
    replace `var' = "0" if `var' == "否"
    destring `var', replace
}


gen WTP_value = .
replace WTP_value = 0 if WTP100 == 0
replace WTP_value = 100 if WTP100 == 1 & WTP200 == 0
replace WTP_value = 200 if WTP200 == 1 & WTP300 == 0
replace WTP_value = 300 if WTP300 == 1 & WTP400 == 0
replace WTP_value = 400 if WTP400 == 1 & WTP500 == 0
replace WTP_value = 500 if WTP500 == 1 & WTP600 == 0
replace WTP_value = 600 if WTP600 == 1 & WTP700 == 0
replace WTP_value = 700 if WTP700 == 1 & WTP800 == 0
replace WTP_value = 800 if WTP800 == 1 & WTP900 == 0
replace WTP_value = 900 if WTP900 == 1 & WTP1000 == 0
replace WTP_value = 1000 if WTP1000 == 1
drop WTP0 WTP100 WTP1000 WTP200 WTP300 WTP400 WTP500 WTP600 WTP700 WTP800 WTP900



* clean variables *
drop id submitdate lastpage startlanguage seed startdate datestamp ipaddr refurl attribute
drop hided*
drop grouptime*
drop mother1m father1m couple1m info openingtext self1m infocheckm infocheckf
drop textdisplay*
drop r674q0
drop attributetime mnametime fnametime mphonetime fphonetime mother1mtime father1mtime couple1mtime g00q01time infotime openingtexttime g00q02time self1mtime infocheckmtime infocheckftime g00q03time g00q04time g00q05time g00q06time randpriming1time randpriming2time priming1positivetime priming1negativetime g01q01time g01q02time g01q03time g01q04time g01q05time g02q10time g02q11time g02q12time g02q13time g02q14time g02q15time g02q16time g02q17time g02q18time g02q19time g03q01time priming2positivetime priming2negativetime g04q01time g04q02time g04q03time g04q04time g05q01time r674q0time g05q0101time g05q0102time g05q0103time g05q0104time g05q0107time g05q0108time g05q0109time g05q0110time g05q0201time g05q0202time g05q0203time g05q0204time g05q0207time g05q0208time g05q0209time g05q0210time g12q01time g12q03time g12q04time g08q03atime g08q03btime g06q01time g06q02time g06q03time g06q04time g06q05time g06q06time g06q07time g09q01time g09q02time g09q03time g09q09time g09q10time g09q12time g10q01time g10q02time g11q01time g11q02time g11q03time g11q04time g11q05time g11q06time g11q07time g11q08time g11q09time g11q10time g11q11time suggestiontime endingtime
drop g07q01time g07q02time g07q03time g08q01time g08q02time g09q04time g09q05time g09q06time g09q07time g09q08time g09q11time
drop priming1positive priming1negative

* reorganize dataset *
gen firstname = mphone if mother == 1
replace firstname = fphone if mother == 0
gen lastname = mname if mother == 1
replace lastname = fname if mother == 0

drop mphone fphone mname fname

order firstname lastname mother group



save "$proc/2m_onsite_`date'.dta", replace

append using "$proc/2m_online_`date'.dta"

foreach var of varlist * {
    label var `var' "`var'"
}

save "$proc/2m_`date'.dta", replace