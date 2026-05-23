********************************************************************************
* TITLE: Data Cleaning for 6M SURVEY, Since Formal Recruitment Sept24 2024
* Project: BEBE - Primary Outcomes
* Data: 6m Survey
* Author: Haoyue Wu
* Last updated: Dec4 2025
********************************************************************************

/*  (Survey id): 
        975966
        721796
        455394
        948966
        575937
        660828

*/

        /*
        This file is to clean the data from the 6m survey 
        INPUT: csv files from the 6m survey
        OUTPUT: $proc/3m_`date'.dta
        */



*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 06_6m_clean
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd

*************************
** READ & EXPLORE DATA **
*************************

*---------------------*
* Survey 975966
*---------------------*
import delimited using "$data/6m/results-survey975966.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "975996"
tostring g08q01, replace force
drop if submitdate == ""
tempfile 6m_part0
save `6m_part0'

*---------------------*
* Survey 72179
*---------------------*
import delimited using "$data/6m/results-survey721796.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "721796"
drop if submitdate == ""
tempfile 6m_part1
save `6m_part1'

// revise 6m father involvment var using 455394
// only replace everyone who has filled in the 455394. did not delete the records for mothers in the previous survey.
import delimited using "$data/6m/results-survey455394.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
drop if attribute_11 == ""
drop if submitdate == ""
keep firstname lastname g01q01 g01q02 g01q03 g01q04 g01q05 grouptime2089
local varlist g01q01 g01q02 g01q03 g01q04 g01q05
foreach var in `varlist'{
    rename `var' `var'_temp
}
tempfile 455394
save `455394'

use `6m_part0', clear
merge 1:1 firstname lastname using `455394'
local varlist g01q01 g01q02 g01q03 g01q04 g01q05
foreach var in `varlist'{
    replace `var' = `var'_temp if _merge == 3
    drop `var'_temp
}
drop _merge
tempfile 6m_part0_replaced
save `6m_part0_replaced'

use `6m_part1', clear
merge 1:1 firstname lastname using `455394'
/* replace grouptime1973 = grouptime2089 if grouptime2089 != . */
local varlist g01q01 g01q02 g01q03 g01q04 g01q05
foreach var in `varlist'{
    replace `var' = `var'_temp if _merge == 3
    drop `var'_temp
}
drop _merge
tempfile 6m_part1_replaced
save `6m_part1_replaced'




import delimited using "$data/6m/results-survey948966.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "948966"

append using `6m_part0_replaced'
append using `6m_part1_replaced'

tempfile 6m
save `6m'

import delimited using "$data/6m/results-survey575937.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "575937"
replace g08q01 = subinstr(g08q01,"天","",.)
tempfile 575937
save `575937'

import delimited using "$data/6m/results-survey660828.csv", stringcol(_all) bindquote(strict) encoding("utf-8") clear
gen survey_id = "660828"


rename g12q02sq001 help_current_nanny
rename g12q02sq002 help_current_my_mother
rename g12q02sq003 help_current_partner_mother
rename g12q02sq004 help_current_other_family
rename g12q02sq005 help_current_daycare
rename g12q02sq006 help_current_no
rename g12q02other help_current_other 


local care "help_current_nanny help_current_my_mother help_current_partner_mother help_current_no help_current_other_family help_current_daycare"
foreach var in `care'{
gen temp = .
replace temp = 1 if `var' == "是"
replace temp = 0 if `var' == "否"
drop `var'
rename temp `var'
}

rename g12q03 help_time_nanny
rename g12q04 help_time_my_mother
rename g12q05 help_time_partner_mother
rename g12q06 help_time_other_family
rename g12q07 help_time_daycare

local help_time "help_time_nanny help_time_my_mother help_time_partner_mother help_time_other_family"
foreach var in `help_time'{
    gen temp = .
    replace temp = 1 if `var' == "少于10小时"
    replace temp = 2 if `var' == "10-19小时"
    replace temp = 3 if `var' == "不少于20小时"
    drop `var'
    rename temp `var'
} 

gen temp = .
replace temp = 1 if help_time_daycare == "少于20小时"
replace temp = 2 if help_time_daycare == "20-39小时"
replace temp = 3 if help_time_daycare == "40-59小时"
replace temp = 4 if help_time_daycare == "不少于60小时"
drop help_time_daycare
rename temp help_time_daycare



tempfile 660828
save `660828'

use `6m',clear
append using `575937'
append using `660828'



rename g01q01 father_involv_diaper
rename g01q02 father_involv_night
rename g01q03 father_involv_play
rename g01q04 father_involv_lull
rename g01q05 father_involv_feed
rename g01q06 father_care_alone
rename g01q07 partner_very_supportive

rename g02q01 bonding_close
rename g02q02 bonding_trapped
rename g02q03 bonding_bored
rename g02q04 bonding_thinking
rename g02q05 bonding_leave
rename g02q06 bonding_enjoyplay
rename g02q07 interaction_with_baby
rename g02q08 partner_close_baby


rename g03q01sq001 time_use_morning_sleep
rename g03q01sq002 time_use_morning_work
rename g03q01sq003 time_use_morning_care_baby
rename g03q01sq004 time_use_morning_hh_duty
rename g03q01sq005 time_use_morning_other
rename g03q02sq001 time_use_noon_sleep
rename g03q02sq002 time_use_noon_work
rename g03q02sq003 time_use_noon_care_baby
rename g03q02sq004 time_use_noon_hh_duty
rename g03q02sq005 time_use_noon_other
rename g03q03sq001 time_use_evening_sleep
rename g03q03sq002 time_use_evening_work
rename g03q03sq003 time_use_evening_care_baby
rename g03q03sq004 time_use_evening_hh_duty
rename g03q03sq005 time_use_evening_other
rename g03q04sq001 time_use_night_sleep
rename g03q04sq002 time_use_night_work
rename g03q04sq003 time_use_night_care_baby
rename g03q04sq004 time_use_night_hh_duty
rename g03q04sq005 time_use_night_other
rename g03q05 care_baby_morning
rename g03q06 care_baby_noon
rename g03q07 care_baby_evening
rename g03q08 care_baby_night

rename g04q10 EPDS_1
rename g04q11 EPDS_2
rename g04q12 EPDS_3
rename g04q13 EPDS_4
rename g04q14 EPDS_5
rename g04q15 EPDS_6
rename g04q16 EPDS_7
rename g04q17 EPDS_8
rename g04q18 EPDS_9
rename g04q19 EPDS_10

rename g05q01 partner_MH
rename g05q02 relationship_satisfaction

rename g06q01 baby_health_condition
rename g06q02 baby_growth_development

rename g07q01 child_plan_respondent
rename g07q02 child_plan_partner
rename g07q03 child_plan_5yrs_likelihood

rename g08q01 workdays_last_week
rename g08q02 workdays_before_holiday
rename g08q03 workhours_last_week
rename g08q04 workhours_before_holiday
rename g08q05 nights_away_from_baby
rename g08q06 job_change_better
rename g08q06other job_change_better_other
rename g08q07 workhours_baby_12m
rename g08q08 workhours_baby_24m


rename g09q01 father_work_priority
rename g09q02 father_strong_reliant
rename g09q03 mothers_know_better
rename g09q04 women_work_hurt_family
rename g09q05 women_more_income_problem
rename g09q06 father_time_less_valuable
rename g09q07 father_identity_importance

rename g10q01 sleep_time
rename g10q02 wake_up_time
rename g10q03 times_wake_up_night_baby
rename g10q04 avg_night_wake_up_duration
rename g10q05 sleep_quality

rename g11q01 extra_time_motor_dev
rename g11q02 extra_time_linguistic_emo_dev
rename g11q03 extra_time_father_wellbeing
rename g11q04 extra_time_mother_wellbeing
rename g11q05 ability_father
rename g11q06 ability_mother

rename g12q01sq001 help_afterbirth_nanny
rename g12q01sq002 help_afterbirth_mother
rename g12q01sq003 help_ab_partner_mother
rename g12q01sq004 help_afterbirth_other_family
rename g12q01sq005 help_afterbirth_daycare
rename g12q01sq006 help_afterbirth_no
rename g12q01other help_afterbirth_other

rename g13q01 time_infant_formula
rename g13q02 breastfeed_situation
rename g13q03 age_stop_breastfeeding
rename g13q04 reason_stop_breastfeeding
rename g13q04other reason_stop_breastfeeding_oth

rename g14q01 treat_father_video_effect
rename g14q02 treat_father_video_actions
rename g14q03 treat_father_video_no_reason
rename g14q04 t2_mother_video_discuss
rename g14q05 t2_mother_partner_reaction

rename g15q01 WTP500
rename g15q02 WTP600
rename g15q03 WTP700
rename g15q04 WTP800
rename g15q05 WTP900
rename g15q06 WTP1000
rename g15q07 WTP400
rename g15q08 WTP300
rename g15q09 WTP200
rename g15q10 WTP100
rename g15q11 WTP0


* Clean Dataset *
* ------------------------------ *
drop g01q01time-g14q05time
drop g12q02time-g12q07time
drop grouptime*
drop textdisplay*
drop if submitdate == ""

foreach var of varlist _all {
    label variable `var' "`var'"
}

gen group = 0
replace group = 1 if attribute_5 == "Y"
replace group = 2 if attribute_6 == "Y"

gen mother = 1
replace mother = 0 if attribute_8 == "Y"

rename attribute_11 hospital_id
order hospital_id group mother


* Build Numeric Variables *
* ------------------------------ *

local fatherinvolv "father_involv_diaper father_involv_night father_involv_play father_involv_lull father_involv_feed"
foreach var in `fatherinvolv' {
    fre `var'
	replace `var' = subinstr(`var',"次及以上","",.)
	replace `var' = subinstr(`var',"次","",.)
	destring `var', replace force
}

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

//replace workdays_last_week with workdays_before_holiday

local workdays_before_holiday "workdays_before_holiday"
foreach var in `workdays_before_holiday'{
    gen temp = .
    replace temp = 0 if inlist(`var', "0", "0天")
    replace temp = 1 if inlist(`var', "1", "1天")
    replace temp = 2 if inlist(`var', "2", "2天")
    replace temp = 3 if inlist(`var', "3", "3天")
    replace temp = 4 if inlist(`var', "4", "4天")
    replace temp = 5 if inlist(`var', "5", "5天")
    replace temp = 6 if inlist(`var', "6", "6天")
    drop `var'
    rename temp `var'
}

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

destring nights_away_from_baby, replace
* adjust how to build the variables here
local var "job_change_better"
gen temp = .

replace temp = 2 if `var' == "不，我的工作和待遇都没有变化"
replace temp = 3 if `var' == "我的工作没有变，但是条件待遇变好了"
replace temp = 1 if `var' == "我的工作没有变，但是条件待遇有所下降"
replace temp = 3 if `var' == "我有了一份新工作，而且条件待遇更好了"
replace temp = 1 if `var' == "我有了一份新工作，而且条件待遇有所下降"
replace temp = 2 if `var' == "我有了一份新工作，条件待遇与之前类似"
replace temp = 2 if `var' == "我之前没有工作，但是现在找到了一份工作"
replace temp = 1 if `var' == "我之前有工作，但是现在失业了"

drop `var'
rename temp `var'



local workhour "workhours_baby_12m workhours_baby_24m"
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


local helpVars "help_afterbirth_nanny help_afterbirth_mother help_ab_partner_mother help_afterbirth_other_family help_afterbirth_daycare help_afterbirth_no"
foreach var in `helpVars' {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
}


local timeuse "time_use_morning_sleep time_use_morning_work time_use_morning_care_baby time_use_morning_hh_duty time_use_morning_other time_use_noon_sleep time_use_noon_work time_use_noon_care_baby time_use_noon_hh_duty time_use_noon_other time_use_evening_sleep time_use_evening_work time_use_evening_care_baby time_use_evening_hh_duty time_use_evening_other time_use_night_sleep time_use_night_work time_use_night_care_baby time_use_night_hh_duty time_use_night_other"
foreach var in `timeuse' {
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
local var care_baby_total
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

local revBonding "bonding_trapped bonding_bored bonding_leave"
foreach var in `revBonding' {
    gen rev_`var' = 7 - `var'
}
gen bonding_score = bonding_close + rev_bonding_trapped + rev_bonding_bored + bonding_thinking + rev_bonding_leave + bonding_enjoyplay
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


local baby_cond "baby_health_condition baby_growth_development"
foreach var in `baby_cond' {
    gen temp = .
    replace temp = 1 if `var' == "非常差"
    replace temp = 2 if `var' == "比较差"
    replace temp = 3 if `var' == "还行"
    replace temp = 4 if `var' == "比较好"
    replace temp = 5 if `var' == "非常好"
    drop `var'
    rename temp `var'
}


// EPDS score
* Calculate scores based on responses for the Chinese questions
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
drop score_q1-score_q10
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

drop EPDS_1-EPDS_10

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



local fert_plan "child_plan_respondent child_plan_partner"
foreach var in `fert_plan' {
    gen temp = .
    replace temp = 2   if `var' == "是的"
    replace temp = 1 if `var' == "我不确定"
    replace temp = 0   if `var' == "不"
    drop `var'
    rename temp `var'
}

// foreach var in `fert_plan'{
// gen temp = ""
// replace temp = "Yes" if `var' == "是的"
// replace temp = "No" if `var' == "不"
// replace temp = "Not sure" if `var' == "我不确定"
// drop `var'
// rename temp `var'
// }

gen temp = .
replace temp = 1 if child_plan_5yrs_likelihood == "非常不可能"
replace temp = 2 if child_plan_5yrs_likelihood == "比较不可能"
replace temp = 3 if child_plan_5yrs_likelihood == "有些不可能" | child_plan_5yrs_likelihood == "有点不可能"
replace temp = 4 if child_plan_5yrs_likelihood == "有些可能" | child_plan_5yrs_likelihood == "有点可能"
replace temp = 5 if child_plan_5yrs_likelihood == "比较可能"
replace temp = 6 if child_plan_5yrs_likelihood == "非常可能"
drop child_plan_5yrs_likelihood
rename temp child_plan_5yrs_likelihood


local genderattitu "father_work_priority father_strong_reliant mothers_know_better women_work_hurt_family women_more_income_problem father_time_less_valuable father_identity_importance"
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

gen rev_father_ident_importance = 6 - father_identity_importance

gen father_norm_index = father_work_priority + father_strong_reliant + father_time_less_valuable + rev_father_ident_importance

gen gender_attitude_score = father_work_priority + father_strong_reliant + mothers_know_better + women_work_hurt_family + ///
                            women_more_income_problem + father_time_less_valuable + rev_father_ident_importance

                            
local var gender_attitude_score
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

* sleep time
gen sleep_hour = substr(sleep_time, 12, 5)
gen sleep_time_num = clock(sleep_hour, "hm")
gen wake_hour = substr(wake_up_time, 12, 5)
gen wake_time_num = clock(wake_hour, "hm")
gen sleep_duration = wake_time_num - sleep_time_num
format sleep_time_num wake_time_num sleep_duration %tc

gen sleep_minutes = hh(sleep_duration) * 60 + mm(sleep_duration)
drop sleep_time wake_up_time 


replace times_wake_up_night_baby = substr(times_wake_up_night_baby,1,1)
destring times_wake_up_night_baby,replace force

gen temp = .
replace temp = 1 if avg_night_wake_up_duration == "0-5分钟"
replace temp = 2 if avg_night_wake_up_duration == "6-15分钟"
replace temp = 3 if avg_night_wake_up_duration == "16-30分钟"
replace temp = 4 if avg_night_wake_up_duration == "31-45分钟"
replace temp = 5 if avg_night_wake_up_duration == "46-60分钟"
replace temp = 6 if avg_night_wake_up_duration == "61-90分钟"
replace temp = 7 if avg_night_wake_up_duration == "91-120分钟"
replace temp = 8 if avg_night_wake_up_duration == "120分钟以上"
drop avg_night_wake_up_duration
rename temp avg_night_wake_up_duration

gen temp = .
	replace temp = 1 if sleep_quality == "很糟糕"
	replace temp = 2 if sleep_quality == "不太好"
	replace temp = 3 if sleep_quality == "一般"
	replace temp = 4 if sleep_quality == "比较好"
	replace temp = 5 if sleep_quality == "非常好"
drop sleep_quality
rename temp sleep_quality


* Belief
*--------------*
local belief "extra_time_motor_dev extra_time_linguistic_emo_dev extra_time_father_wellbeing extra_time_mother_wellbeing"
foreach var in `belief' {
    gen temp = .
    replace temp = 1 if `var' == "完全没有帮助"
    replace temp = 2 if `var' == "帮助有限"
    replace temp = 3 if `var' == "有一些帮助"
    replace temp = 4 if `var' == "帮助很大"
    replace temp = 5 if `var' == "帮助非常大"
    drop `var'
    rename temp `var'
}
gen belief_score = extra_time_motor_dev + extra_time_linguistic_emo_dev + extra_time_father_wellbeing + extra_time_mother_wellbeing
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
replace temp = 1 if ability_father == "能力远低于其他父亲"
replace temp = 2 if ability_father == "能力略低于其他父亲"
replace temp = 3 if ability_father == "能力与其他父亲不相上下"
replace temp = 4 if ability_father == "能力略高于其他父亲"
replace temp = 5 if ability_father == "能力远高于其他父亲"
drop ability_father
rename temp ability_father

gen temp = .
replace temp = 1 if ability_mother == "能力远低于其他母亲"
replace temp = 2 if ability_mother == "能力略低于其他母亲"
replace temp = 3 if ability_mother == "能力与其他母亲不相上下"
replace temp = 4 if ability_mother == "能力略高于其他母亲"
replace temp = 5 if ability_mother == "能力远高于其他母亲"
drop ability_mother
rename temp ability_mother


* Breastfeeding *
*---------------*
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

gen temp = .
replace temp = 0 if age_stop_breastfeeding == "不足月"
replace temp = 1 if age_stop_breastfeeding == "一个月大"
replace temp = 2 if age_stop_breastfeeding == "两个月大"
replace temp = 3 if age_stop_breastfeeding == "三个月大"
replace temp = 4 if age_stop_breastfeeding == "四个月大"
replace temp = 5 if age_stop_breastfeeding == "五个月大"
replace temp = 6 if age_stop_breastfeeding == "六个月大"
drop age_stop_breastfeeding
rename temp age_stop_breastfeeding

gen temp = .
	replace temp = 1 if reason_stop_breastfeeding == "母亲生病"
	replace temp = 2 if reason_stop_breastfeeding == "宝宝生病"
	replace temp = 3 if reason_stop_breastfeeding == "奶量不足/宝宝饥饿"
	replace temp = 4 if reason_stop_breastfeeding == "宝宝的年龄"
	replace temp = 5 if reason_stop_breastfeeding == "乳头疼痛或感染"
	replace temp = 6 if reason_stop_breastfeeding == "复工/复学"
	replace temp = 7 if reason_stop_breastfeeding == "医生让我停止"
	replace temp = 8 if reason_stop_breastfeeding == "我的伴侣或亲戚希望我停止"
	replace temp = 9 if reason_stop_breastfeeding == "更偏好配方奶喂养"
drop reason_stop_breastfeeding
rename temp reason_stop_breastfeeding

local WTP "WTP500 WTP600 WTP700 WTP800 WTP900 WTP1000 WTP400 WTP300 WTP200 WTP100 WTP0"
foreach var in `WTP' {
    gen temp = .
    replace temp = 1 if `var' == "是"
    replace temp = 0 if `var' == "否"
    drop `var'
    rename temp `var'
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


* treatment video affect opinion on childcare
gen temp = .
replace temp = 1 if treat_father_video_effect == "是"
replace temp = 0 if treat_father_video_effect == "否"
drop treat_father_video_effect
rename temp treat_father_video_effect

gen temp = .
replace temp = 1 if t2_mother_video_discuss == "是"
replace temp = 0 if t2_mother_video_discuss == "否"
drop t2_mother_video_discuss
rename temp t2_mother_video_discuss

********************************************************************************
** GROUP ASSIGNMENT & FINALIZATION
********************************************************************************

// Drop unnecessary variable ranges and missing hospital_id cases
drop firstname-attribute_10
drop if hospital_id == ""
drop if hospital_id == "D00330460"

drop hided*
drop attribute_*
drop id submitdate lastpage startlanguage seed token startdate datestamp ipaddr refurl randbelieforder
********************************************************************************
** SAVE PROCESSED DATA
********************************************************************************
save "$proc/6m_`date'.dta", replace



