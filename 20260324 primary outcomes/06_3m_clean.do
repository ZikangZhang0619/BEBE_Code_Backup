********************************************************************************
* TITLE: Data Cleaning for 3M SURVEY, Since Formal Recruitment Sept24 2024
* Project: BEBE - Primary Outcomes
* Data: 3m Survey
* Author: Haoyue Wu
* Last updated: Dec3 2025
********************************************************************************

/*  (Survey id): 
        573762	
        917974	
        567772	
        291237	
        415357	
        331106
        331112

*/

        /*
        This file is to clean the data from the 3m survey 
        INPUT: csv files from the 3m survey
        OUTPUT: $proc/3m_`date'.dta
        */



*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 05_3m_clean
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd

*************************
** READ & EXPLORE DATA **
*************************
// import delimited using "$data/results-survey229356.csv", bindquote(strict) encoding("utf-8") clear

// tempfile 3m_1
// save `3m_1'

// import delimited using "$data/results-survey332795.csv", bindquote(strict) encoding("utf-8") clear

// append using `3m_1', force
*---------------------*
* Survey 917974
*---------------------*


import delimited using "$data/3m/results-survey291237.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "291237"
tempfile 2
save `2'

import delimited using "$data/3m/results-survey567772.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "567772"
tempfile 3
save `3'


import delimited using "$data/3m/results-survey415357.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "415357"
tempfile 4
save `4'

import delimited using "$data/3m/results-survey331106.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "331106"
tempfile 5
save `5'


import delimited using "$data/3m/results-survey331112.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "331112"
/* tempfile 4
save `4' */

append using `2'
append using `3'
append using `4'
append using `5'


*------------- bonding ------------*
rename g02q01 bonding_close
rename g02q02 bonding_trapped
rename g02q03 bonding_bored
rename g02q04 bonding_thinking
rename g02q05 bonding_leave
rename g02q06 bonding_enjoyplay
rename g02q07 interaction_with_baby
rename g02q08 partner_close_baby

rename g03q01 mental_load_household_task
rename g03q02 mental_load_balance

rename g04q01 relationship_satisfaction

rename g05q01sq001 time_use_morning_sleep
rename g05q01sq002 time_use_morning_work
rename g05q01sq003 time_use_morning_care_baby
rename g05q01sq004 time_use_morning_hh_duty
rename g05q01sq005 time_use_morning_other
rename g05q02sq001 time_use_noon_sleep
rename g05q02sq002 time_use_noon_work
rename g05q02sq003 time_use_noon_care_baby
rename g05q02sq004 time_use_noon_hh_duty
rename g05q02sq005 time_use_noon_other
rename g05q03sq001 time_use_evening_sleep
rename g05q03sq002 time_use_evening_work
rename g05q03sq003 time_use_evening_care_baby
rename g05q03sq004 time_use_evening_hh_duty
rename g05q03sq005 time_use_evening_other
rename g05q04sq001 time_use_night_sleep
rename g05q04sq002 time_use_night_work
rename g05q04sq003 time_use_night_care_baby
rename g05q04sq004 time_use_night_hh_duty
rename g05q04sq005 time_use_night_other

rename g05q06 care_baby_morning
rename g05q07 care_baby_noon
rename g05q08 care_baby_evening
rename g05q09 care_baby_night

rename g06q01 self_efficacy_baby_cries
rename g06q02 self_efficacy_play
rename g06q03 self_efficacy_decision
rename g06q04 self_efficacy_stressful
rename g06q05 self_efficacy_good_job
rename g06q06 self_efficacy_ptn_good_job
rename g06q07 ability_father


rename g07q01 workdays_last_week
rename g07q02 workdays_before_holiday
rename g07q03 workhours_last_week
rename g07q04 workhours_before_holiday
rename g07q05 work_commute
rename g07q06 workhours_baby_6m
rename g07q07 workhours_baby_12m
rename g07q08 workhours_baby_24m
rename g07q09 work_challenge
rename g07q10 maternity_leave_end
rename g07q11 current_baby_care
rename g07q11other current_baby_care_other
rename g07q12 future_baby_care
rename g07q12other future_baby_care_other
rename g07q13 childcare_discussion
rename g07q14 childcare_plan
rename g07q15 partner_childcare_likelihood

//second-order belief
rename g08q01 father_1hr_care_alone
rename g08q02 father_15mins_care_alone

rename g08q03 extra_time_motor_dev
rename g08q04 extra_time_linguistic_emo_dev
rename g08q05 extra_time_father_wellbeing
rename g08q06 extra_time_mother_wellbeing
rename g08q07 father_time_less_valuable

rename g09q01 baby_squirm_dressed
rename g09q02 baby_laugh_play
rename g09q03 baby_toy_focus
rename g09q04 baby_distress_tired
rename g09q05 baby_squirm_back
rename g09q06 baby_enjoy_rock_hug


rename g10q01 feeding_infant_formula
rename g10q02 feeding_breastmilk_breast
rename g10q03 feeding_breastmilk_pumped
rename g10q04 feeding_water
rename g10q05 feeding_other
rename g10q06 time_breastmilk_breast
rename g10q07 time_breastmilk_pump
rename g10q08sq001 who_feed_milkformula_me
rename g10q08sq002 who_feed_milkformula_me_ptn
rename g10q08sq003 who_feed_milkformula_mothers
rename g10q08sq004 who_feed_milkformula_nanny
rename g10q08other who_feed_milkformula_others
rename g10q09 time_infant_formula
rename g10q10 breastfeed_situation
rename g10q11 age_stop_breastfeeding

rename g11q01 best_to_spend
rename g11q02 best_to_talk
rename g11q03sq001 baby_blues_1
rename g11q03sq002 baby_blues_2
rename g11q03sq003 baby_blues_3
rename g11q03sq004 baby_blues_4
rename g11q03sq005 baby_blues_5
drop g11q04 g11q05 g11q06

rename g12q01 self_triplep_usage
rename g12q02 partner_triplep_usage
rename g12q03 remember_video
rename g12q04 video_thought
rename g12q05 talked_video_with_partner

// predetermined characteristics： build the variable when merging
rename g14q01 education_level
rename g14q02 self_brother_num
rename g14q03 self_sister_num
rename g14q09 total_couple_income
rename g14q10 income_share_couple
rename g14q12 building_ownership
rename g14q12other building_ownership_other

rename g15q01 prebirth_workdays
rename g15q02 prebirth_workhours

rename g16q01sq001 help_current_nanny
rename g16q01sq002 help_current_my_mother
rename g16q01sq003 help_current_partner_mother
rename g16q01sq004 help_current_other_family
rename g16q01sq005 help_current_no
rename g16q01other help_current_other
rename g16q02sq001 help_nextmonth_nanny
rename g16q02sq002 help_nextmonth_my_mother
rename g16q02sq003 help_nextmonth_partner_mother
rename g16q02sq004 help_nextmonth_other_family
rename g16q02sq005 help_nextmonth_no
rename g16q02other help_nextmonth_other
//need revise//

tempfile 3
save `3'

*---------------------*
* First 2 surveys
*---------------------*


import delimited using "$data/3m/results-survey917974.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "917974"
tempfile 1
save `1'


import delimited using "$data/3m/results-survey573762.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "573762"

append using `1'





rename g01q01 bonding_close
rename g01q02 bonding_trapped
rename g01q03 bonding_bored
rename g01q04 bonding_thinking
rename g01q05 bonding_leave
rename g01q06 bonding_enjoyplay

rename g01q07 interaction_with_baby
rename g01q08 partner_close_baby

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
rename g04q01 relationship_satisfaction

rename g05q01sq001 time_use_morning_sleep
rename g05q01sq002 time_use_morning_work
rename g05q01sq003 time_use_morning_care_baby
rename g05q01sq004 time_use_morning_hh_duty
rename g05q01sq005 time_use_morning_other
rename g05q02sq001 time_use_noon_sleep
rename g05q02sq002 time_use_noon_work
rename g05q02sq003 time_use_noon_care_baby
rename g05q02sq004 time_use_noon_hh_duty
rename g05q02sq005 time_use_noon_other
rename g05q03sq001 time_use_evening_sleep
rename g05q03sq002 time_use_evening_work
rename g05q03sq003 time_use_evening_care_baby
rename g05q03sq004 time_use_evening_hh_duty
rename g05q03sq005 time_use_evening_other
rename g05q04sq001 time_use_night_sleep
rename g05q04sq002 time_use_night_work
rename g05q04sq003 time_use_night_care_baby
rename g05q04sq004 time_use_night_hh_duty
rename g05q04sq005 time_use_night_other

rename g05q05 care_baby_morning
rename g05q06 care_baby_noon
rename g05q07 care_baby_evening
rename g05q08 care_baby_night

rename g06q01 self_efficacy_baby_cries
rename g06q02 self_efficacy_play
rename g06q03 self_efficacy_decision
rename g06q04 self_efficacy_stressful
rename g06q05 self_efficacy_good_job
rename g06q06 self_efficacy_ptn_good_job
rename g06q07 ability_father


rename g07q01 workdays_last_week
rename g07q02 workdays_before_holiday
rename g07q03 workhours_last_week
rename g07q04 workhours_before_holiday
rename g07q05 work_commute
rename g07q06 workhours_baby_6m
rename g07q07 workhours_baby_12m
rename g07q08 workhours_baby_24m
rename g07q09 work_challenge
rename g07q10 maternity_leave_end
rename g07q11 current_baby_care
rename g07q11other current_baby_care_other
rename g07q12 future_baby_care
rename g07q12other future_baby_care_other
rename g07q13 childcare_discussion
rename g07q14 childcare_plan
rename g07q15 partner_childcare_likelihood

rename g08q01 father_1hr_care_alone
rename g08q02 father_15mins_care_alone

rename g08q03 extra_time_motor_dev
rename g08q04 extra_time_linguistic_emo_dev
rename g08q05 extra_time_father_wellbeing
rename g08q06 extra_time_mother_wellbeing

rename g08q09 father_time_less_valuable

rename g09q01 baby_squirm_dressed
rename g09q02 baby_laugh_play
rename g09q03 baby_toy_focus
rename g09q04 baby_distress_tired
rename g09q05 baby_squirm_back
rename g09q06 baby_enjoy_rock_hug

rename g10q01 feeding_infant_formula
rename g10q02 feeding_breastmilk_breast
rename g10q03 feeding_breastmilk_pumped
rename g10q04 feeding_water
rename g10q05 feeding_other
rename g10q06 time_breastmilk_breast
rename g10q07 time_breastmilk_pump
rename g10q08sq001 who_feed_milkformula_me
rename g10q08sq002 who_feed_milkformula_me_ptn
rename g10q08sq003 who_feed_milkformula_mothers
rename g10q08sq004 who_feed_milkformula_nanny
rename g10q08other who_feed_milkformula_others
rename g10q09 time_infant_formula
rename g10q10 breastfeed_situation
rename g08q11 age_stop_breastfeeding

rename g11q01 education_level
rename g11q02 self_brother_num
rename g11q03 self_sister_num
rename g11q04 partner_brother_num
rename g11q05 partner_sister_num
rename g11q06 parents_alive
rename g11q07 close_to_parents
rename g11q07other close_to_parents_other
rename g11q08 occupation_description
rename g11q09 total_couple_income
rename g11q10 income_share_couple
rename g11q11 building_area
rename g11q12 building_ownership
rename g11q12other building_ownership_other

rename g12q01 prebirth_workdays
rename g12q02 prebirth_workhours

rename g13q01sq001 help_current_nanny
rename g13q01sq002 help_current_my_mother
rename g13q01sq003 help_current_partner_mother
rename g13q01sq004 help_current_other_family
rename g13q01sq005 help_current_no
rename g13q01other help_current_other
rename g13q02sq001 help_nextmonth_nanny
rename g13q02sq002 help_nextmonth_my_mother
rename g13q02sq003 help_nextmonth_partner_mother
rename g13q02sq004 help_nextmonth_other_family
rename g13q02sq005 help_nextmonth_no
rename g13q02other help_nextmonth_other
	

append using `3'

drop if submitdate == ""
// label variables
foreach var of varlist * {
    label var `var' "`var'"
}

gen group = 0
replace group = 1 if attribute_5 == "Y"
replace group = 2 if attribute_6 == "Y"

gen mother = 1
replace mother = 0 if attribute_8 == "Y"

rename attribute_11 hospital_id

local bonding "bonding_close bonding_trapped bonding_bored bonding_thinking bonding_leave bonding_enjoyplay"
foreach var in `bonding'{
gen temp = .
replace temp = 1 if `var' == "从不"
replace temp = 2 if `var' == "很少"
replace temp = 3 if `var' == "有时"
replace temp = 4 if `var' == "比较频繁"
replace temp = 5 if `var' == "非常频繁"
replace temp = 6 if `var' == "总是"
drop `var'
rename temp `var'
}

local bonding "bonding_trapped bonding_bored bonding_leave"
foreach var in `bonding' {
    gen rev_`var' = 7-`var'
}

gen bonding_score =bonding_close+rev_bonding_trapped+rev_bonding_bored+bonding_thinking+rev_bonding_leave+bonding_enjoyplay
local var bonding_score
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
replace temp = 1 if interaction_with_baby == "低很多"
replace temp = 2 if interaction_with_baby == "低一些"
replace temp = 3 if interaction_with_baby == "与其他父亲差不多"
replace temp = 4 if interaction_with_baby == "高一些"
replace temp = 5 if interaction_with_baby == "高很多"
drop interaction_with_baby
rename temp interaction_with_baby


gen temp = .
replace temp = 1 if partner_close_baby == "非常疏远"
replace temp = 2 if partner_close_baby == "有点疏远"
replace temp = 3 if partner_close_baby == "有些亲近"
replace temp = 4 if partner_close_baby == "亲近"
replace temp = 5 if partner_close_baby == "非常亲近"
drop partner_close_baby
rename temp partner_close_baby


// EPDS score
* Calculate scores based on responses for the Chinese questions
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

drop score_* EPDS_1-EPDS_10


// partner well-being
gen temp = .
replace temp = 1 if partner_MH == "非常不好"
replace temp = 2 if partner_MH == "比较不好"
replace temp = 3 if partner_MH == "一般"
replace temp = 4 if partner_MH == "比较好"
replace temp = 5 if partner_MH == "非常好"
drop partner_MH
rename temp partner_MH

// partner relationship
gen temp = .
replace temp = 1 if relationship_satisfaction == "非常不满意"
replace temp = 2 if relationship_satisfaction == "比较不满意"
replace temp = 3 if relationship_satisfaction == "一般"
replace temp = 4 if relationship_satisfaction == "比较满意"
replace temp = 5 if relationship_satisfaction == "非常满意"
drop relationship_satisfaction
rename temp relationship_satisfaction

// time use
foreach var of varlist time_use_morning_sleep-time_use_night_other {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}


local caretime "care_baby_morning care_baby_noon care_baby_evening care_baby_night"
foreach var in `caretime' {
	replace `var' = subinstr(`var',"分钟及以上","",.)
	replace `var' = subinstr(`var',"分钟","",.)
	destring `var', replace force
    // replace var to 0 if missing
    replace `var' = 0 if `var' == .
}

gen care_baby_total = care_baby_morning + care_baby_noon + care_baby_evening + care_baby_night

// self-efficacy
local efficacy "self_efficacy_baby_cries self_efficacy_play self_efficacy_decision self_efficacy_stressful self_efficacy_good_job self_efficacy_ptn_good_job"
	foreach var in `efficacy'{
	gen temp = .
	replace temp = 1 if `var' == "完全不符合"
	replace temp = 2 if `var' == "不符合"
	replace temp = 3 if `var' == "一般"
	replace temp = 4 if `var' == "符合"
	replace temp = 5 if `var' == "完全符合"
	drop `var'
	rename temp `var'
}

gen rev_self_efficacy_stressful = 6-self_efficacy_stressful
gen self_efficacy_score = self_efficacy_baby_cries+self_efficacy_play+self_efficacy_decision+rev_self_efficacy_stressful+self_efficacy_good_job+self_efficacy_ptn_good_job

local var self_efficacy_score
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
replace temp = 1 if ability_father == "能力远低于其他父亲"
replace temp = 2 if ability_father == "能力略低于其他父亲"
replace temp = 3 if ability_father == "能力与其他父亲不相上下"
replace temp = 4 if ability_father == "能力略高于其他父亲"
replace temp = 5 if ability_father == "能力远高于其他父亲"
drop ability_father
rename temp ability_father


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



tostring workdays_before_holiday, replace force
replace workdays_last_week = workdays_before_holiday if workdays_before_holiday != "."
replace workdays_last_week = substr(workdays_last_week,1,1)
replace workdays_last_week = "." if workdays_last_week == "{"
destring workdays_last_week, replace force
drop workdays_before_holiday

replace workhours_last_week = workhours_before_holiday if workhours_last_week == ""
replace workhours_last_week = "4" if workhours_last_week == "不超过4小时"
replace workhours_last_week = "14" if workhours_last_week == "不少于14小时"
replace workhours_last_week = subinstr(workhours_last_week,"小时","",.)
destring workhours_last_week, replace force
drop workhours_before_holiday

local workhour "workhours_baby_6m workhours_baby_12m workhours_baby_24m"
foreach var in `workhour'{
    gen temp = .
    replace temp = 0 if inlist(`var', "0", "0小时")
    replace temp = 5 if inlist(`var', "5", "5小时")
    replace temp = 10 if inlist(`var', "10", "10小时")
    replace temp = 15 if inlist(`var', "15", "15小时")
    replace temp = 20 if inlist(`var', "20", "20小时")
    replace temp = 25 if inlist(`var', "25", "25小时")
    replace temp = 30 if inlist(`var', "30", "30小时")
    replace temp = 35 if inlist(`var', "35", "35小时")
    replace temp = 40 if inlist(`var', "40", "40小时")
    replace temp = 45 if inlist(`var', "45", "45小时")
    replace temp = 50 if inlist(`var', "50", "50小时")
    replace temp = 55 if inlist(`var', "55", "55小时")
    replace temp = 60 if inlist(`var', "60+", "60小时及以上")
    drop `var'
    rename temp `var'
}


gen temp = .
replace temp = 1 if work_challenge == "是的，我想要换一个更轻松的工作"
replace temp = 2 if work_challenge == "是的，我想要换一个稍微轻松一些的工作"
replace temp = 3 if work_challenge == "是的，我想要换一个挑战性稍高一些的工作"
replace temp = 4 if work_challenge == "是的，我想要换一个更具挑战性的工作"
replace temp = 5 if work_challenge == "不，我想保持跟以前一样的工作"
replace temp = 6 if work_challenge == "我一年前没有工作"
replace temp = 7 if work_challenge == "我在未来一两年内不打算工作"
drop work_challenge
rename temp work_challenge


// work_commute
gen temp = .
replace temp = 1 if work_commute == "少于 0.5 小时"
replace temp = 2 if work_commute == "0.5-1 小时"
replace temp = 3 if work_commute == "1-1.5 小时"
replace temp = 4 if work_commute == "1.5-2 小时"
replace temp = 5 if work_commute == "2-2.5 小时"
replace temp = 6 if work_commute == "2.5-3 小时"
replace temp = 7 if work_commute == "大于3 小时"
drop work_commute
rename temp work_commute


local varname "maternity_leave_end"
foreach var in `varname'{
gen temp = .
replace temp = 1 if `var' == "一个月内"
replace temp = 2 if `var' == "一个月后，两个月内"
replace temp = 3 if `var' == "两个月后，三个月内"
replace temp = 4 if `var' == "三个月以后"
drop `var'
rename temp `var'
}

local varname "current_baby_care future_baby_care"
foreach var in `varname'{
gen temp = .
replace temp = 1 if `var' == "佣人、保姆等"
replace temp = 2 if `var' == "托儿所、日托说、或其他育儿机构"
replace temp = 3 if `var' == "我的母亲"
replace temp = 4 if `var' == "我伴侣的母亲"
replace temp = 5 if `var' == "我的伴侣"
replace temp = 6 if `var' == "其他亲戚"
drop `var'
rename temp `var'
}

local varname "childcare_discussion"
foreach var in `varname'{
gen temp = .
replace temp = 5 if `var' == "我们已经详细讨论过了"
replace temp = 4 if `var' == "我们讨论过了一些"
replace temp = 3 if `var' == "我们只是简要地谈过"
replace temp = 2 if `var' == "我们还没有讨论过，但会在之后进行讨论"
replace temp = 1 if `var' == "我们可能不会讨论这些"
drop `var'
rename temp `var'
}

local varname "childcare_plan"
foreach var in `varname'{
gen temp = .
replace temp = 3 if `var' == "是的，我们有一个详细的计划"
replace temp = 2 if `var' == "是的，我们有一个模糊的计划"
replace temp = 1 if `var' == "不，我们还没有一个具体的计划"
drop `var'
rename temp `var'
}

local varname "partner_childcare_likelihood"
foreach var in `varname'{
gen temp = .
replace temp = 1 if `var' == "非常不可能"
replace temp = 2 if `var' == "比较不可能"
replace temp = 3 if `var' == "比较可能"
replace temp = 4 if `var' == "非常可能"
drop `var'
rename temp `var'
}

// BF
foreach var of varlist feeding_infant_formula-feeding_other {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}


local varname "time_breastmilk_breast time_breastmilk_pump"
foreach var in `varname'{
replace `var' = subinstr(`var',"次","",.)
destring `var', replace force
}

local varname "age_stop_breastfeeding"
foreach var in `varname' {
	replace `var' = subinstr(`var',"周及以上","",.)
	replace `var' = subinstr(`var',"周","",.)
	destring `var', replace force
}

foreach var of varlist who_feed_milkformula_me-who_feed_milkformula_nanny {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}

gen temp = .
replace temp = 1 if time_infant_formula == "未饮用任何婴儿配方奶"
replace temp = 2 if time_infant_formula == "1-7次"
replace temp = 3 if time_infant_formula == "8-14次"
replace temp = 4 if time_infant_formula == "15-21次"
replace temp = 5 if time_infant_formula == "21次以上"
drop time_infant_formula
rename temp time_infant_formula


gen temp = .
replace temp = 1 if breastfeed_situation == "我从来没有母乳喂养过"
replace temp = 2 if breastfeed_situation == "我用母乳喂养了一段时间，但现在我已经停止了"
replace temp = 3 if breastfeed_situation == "我现在是直接母乳喂养或使用吸奶器进行母乳喂养"
drop breastfeed_situation
rename temp breastfeed_situation

// gen temp = .
// 	replace temp = 1 if reason_stop_breastfeeding == "母亲生病"
// 	replace temp = 2 if reason_stop_breastfeeding == "宝宝生病"
// 	replace temp = 3 if reason_stop_breastfeeding == "奶量不足/宝宝饥饿"
// 	replace temp = 4 if reason_stop_breastfeeding == "宝宝的年龄"
// 	replace temp = 5 if reason_stop_breastfeeding == "乳头疼痛或感染"
// 	replace temp = 6 if reason_stop_breastfeeding == "复工/复学"
// 	replace temp = 7 if reason_stop_breastfeeding == "医生让我停止"
// 	replace temp = 8 if reason_stop_breastfeeding == "我的伴侣或亲戚希望我停止"
// 	replace temp = 9 if reason_stop_breastfeeding == "更偏好配方奶喂养"
// drop reason_stop_breastfeeding
// rename temp reason_stop_breastfeeding


// predetermined characteristics
gen temp = .
	replace temp = 1 if education_level == "高中毕业或以下"
	replace temp = 2 if education_level == "专科毕业"
	replace temp = 3 if education_level == "本科毕业"
	replace temp = 4 if education_level == "硕士毕业或博士毕业"
drop education_level
rename temp education_level

local varlist "self_brother_num self_sister_num partner_brother_num partner_sister_num"
foreach var in `varlist'{
	gen temp = .
	replace temp = 1 if `var' == "0"
	replace temp = 2 if `var' == "1"
	replace temp = 3 if `var' == "2"
	replace temp = 4 if `var' == "3个或更多"
drop `var'
rename temp `var'
}

gen sibling_num = self_brother_num + self_sister_num
gen sibling_num_partner = partner_brother_num + partner_sister_num


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

tostring building_area, replace force
replace building_area = "200" if building_area == "200及以上"
destring building_area, replace force


local care "help_current_nanny help_current_my_mother help_current_partner_mother help_current_no help_current_other_family help_nextmonth_nanny help_nextmonth_my_mother help_nextmonth_partner_mother help_nextmonth_other_family help_nextmonth_no"
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}


replace prebirth_workdays = substr(prebirth_workdays,1,1)
destring prebirth_workdays, replace force

replace prebirth_workhours = "4" if prebirth_workhours == "不超过4小时"
replace prebirth_workhours = "14" if prebirth_workhours == "不少于14小时"
replace prebirth_workhours = subinstr(prebirth_workhours,"小时","",.)
destring prebirth_workhours, replace force


local belief "extra_time_motor_dev extra_time_linguistic_emo_dev extra_time_father_wellbeing extra_time_mother_wellbeing"
foreach var in `belief'{
gen temp = .
replace temp = 1 if `var' == "完全没有帮助/可能有害"
replace temp = 2 if `var' == "没有帮助但也没有坏处"
replace temp = 3 if `var' == "帮助有限"
replace temp = 4 if `var' == "有一些帮助"
replace temp = 5 if `var' == "帮助很大"
replace temp = 1 if `var' == "完全没有帮助"
replace temp = 2 if `var' == "帮助有限"
replace temp = 3 if `var' == "有一些帮助"
replace temp = 4 if `var' == "帮助很大"
replace temp = 5 if `var' == "帮助非常大"
drop `var'
rename temp `var'
}

gen belief_score = extra_time_motor_dev+extra_time_linguistic_emo_dev+extra_time_father_wellbeing+extra_time_mother_wellbeing
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

gen temp = .
replace temp = 1 if father_time_less_valuable == "非常不同意"
replace temp = 2 if father_time_less_valuable == "不同意"
replace temp = 3 if father_time_less_valuable == "中立"
replace temp = 4 if father_time_less_valuable == "同意"
replace temp = 5 if father_time_less_valuable == "非常同意"
drop father_time_less_valuable
rename temp father_time_less_valuable

local temperament "baby_squirm_dressed baby_laugh_play baby_toy_focus baby_distress_tired baby_squirm_back baby_enjoy_rock_hug"
foreach var in `temperament'{
gen temp = .
replace temp = 1 if `var' == "从不"
replace temp = 2 if `var' == "很少"
replace temp = 3 if `var' == "不到一半时间"
replace temp = 4 if `var' == "大约一半时间"
replace temp = 5 if `var' == "超过一半时间"
replace temp = 6 if `var' == "总是"
drop `var'
rename temp `var'
}

gen temperament_score = baby_squirm_dressed+baby_laugh_play+baby_toy_focus+baby_distress_tired+baby_squirm_back+baby_enjoy_rock_hug
local var temperament_score

sum `var' if group == 0 & mother == 1
scalar control_mean_m = r(mean)
scalar control_sd_m = r(sd)


sum `var' if group == 0 & mother == 0
scalar control_mean_f = r(mean)
scalar control_sd_f = r(sd)

gen `var'_z = .
replace `var'_z = (`var' - control_mean_m) / control_sd_m if mother == 1
replace `var'_z = (`var' - control_mean_f) / control_sd_f if mother == 0


destring father_1hr_care_alone father_15mins_care_alone, replace
********************************************************************************
** FINAL CLEANUP & SAVE
********************************************************************************
** Group & Mother Assignment


order hospital_id group mother survey_id
drop firstname-attribute_10
drop if hospital_id == ""
drop lastpage startlanguage seed token ipaddr refurl ///
     textdisplay01 textdisplay03 textdisplay04 textdisplay05 textdisplay06 ///
     textdisplay07 textdisplay08 textdisplay09 hidedg01q06 hidedg01q07 ///
     hidedg01q10 textdisplay10 textdisplay13 hidedg08q07 hidedg08q08 ///
     textdisplay12 textdisplay11 hidedg08q12 hidedg08q12other ending ///
     grouptime* 
drop g01q01time-g16q02time
drop textdisplay01time randefficacyordertime randbeliefordertime g19q00001time g19q00002time g14q04time g14q05time g14q06time g14q07time g14q08time g14q11time
misstable sum *

save "$proc/3m_`date'.dta",replace
	
	
	



