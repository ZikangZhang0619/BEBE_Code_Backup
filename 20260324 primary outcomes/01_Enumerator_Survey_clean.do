********************************************************************************
* TITLE: Data Cleaning for Enumerator Survey, Since Formal Recruitment Sept24 2024
* Project: BEBE - Primary Outcomes
* Data: Enumerator Survey
* Author: Haoyue Wu
* Last updated: Nov19 2025
********************************************************************************

/*  (Survey id): 
        * 593646
        * 175343
        * 464493
        * 241113
        * 241204
        * 877826
        * 250120
        * 250125
        * 250314
        * 250427
        * 250703

*/

        /*
        This file is to clean the data from the enumerator survey 
        INPUT: csv files from the enumerator survey
        OUTPUT: $proc/enumerator_cleaned_`date'.dta
				$proc/room_bed_match.dta
				$proc/clusters_`date'.dta
        */


*********
** LOG **
*********
// time  
// local project 01_Enumerator_clean
// cap log close
// set linesize 200
// log using "$logs/`project'_`time'.log", text replace
// di "`c(current_date)' `c(current_time)'"
// pwd





* ///////////////////////////////////////////////////////////////////////////////////////////////// *
* ////                        1. Aggregate All Survey Data                                     //// *
* ///////////////////////////////////////////////////////////////////////////////////////////////// * 

* ------------------- *
* Survey 593646
* ------------------- *
import delimited using "$data/Enumerator/results-survey593646.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 593646
tempfile 1
save `1'

* ------------------- *
* Survey 175343
* ------------------- *

import delimited using "$data/Enumerator/results-survey175343.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 175343
tempfile 2
save `2'

* ------------------- *
* Survey 464493 
* (added control group discussion)
* ------------------- *

import delimited using "$data/Enumerator/results-survey464493.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 464493
tempfile 3
save `3'

* ------------------- *
* Survey 241113 
* (added video survey)
* ------------------- *
import delimited using "$data/Enumerator/results-survey241113.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 241113

rename hidedg07q04 video_helpful_f
rename hidedg07q05 video_helpful_m
rename vfs01 video_like_f
rename vfs02 video_learn_f
rename vfs03 video_change_f
rename vfs04 video_recommend_f
rename vfs05 video_like_m
rename vfs06 video_learn_m
rename vfs07 video_change_m
rename vfs08 video_recommend_m

tempfile 4
save `4'

* ------------------- *
* Survey 241204
* (simplified survey)
* ------------------- *
import delimited using "$data/Enumerator/results-survey241204.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 241204

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 5
save `5'

* ------------------- *
* Survey 877826
* (begin recruitment at westside hospital)
* ------------------- *
import delimited using "$data/Enumerator/results-survey877826.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 877826
rename g01q07wsq001 hospital_id_westside

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m
tempfile 6
save `6'

* ------------------- *
* Survey 250120
* 1. Removed the question about whether there should be a direct skip to the intervention.  
* 2. Added a text input question to record parents' reactions to the video.  
* 3. Added a final question to re-enter the hospitalization number (this will only appear when it's the last time the enumerator visits the family).  
* 4. Removed the question about whether the Triple P app is installed on the father's phone."
* ------------------- *
import delimited using "$data/Enumerator/results-survey250120.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250120
rename g01q07wsq001 hospital_id_westside

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 7
save `7'

* ------------------- *
* Survey 250125
* --------------------- *
import delimited using "$data/Enumerator/results-survey250125.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250125
rename g01q07wsq001 hospital_id_westside

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 8
save `8'

* ------------------- *
* Survey 250314
* 1. added control video
* 2. deleted westside design
* ------------------- *
import delimited using "$data/Enumerator/results-survey250314.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250314

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 9
save `9'

* ------------------- *
* Survey 250427
* updated ward layout
* ------------------- *
import delimited using "$data/Enumerator/results-survey250427.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250427

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m
tempfile 10
save `10'

* ------------------- *
* Survey 250703
* ------------------- *

import delimited using "$data/Enumerator/results-survey250703.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250703

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m
* ---------------------- aggregate all data ---------------------- *
append using `1'
append using `2'
append using `3'
append using `4'
append using `5'
append using `6'
append using `7'
append using `8'
append using `9'
append using `10'
 

* ///////////////////////////////////////////////////////////////////////////////////////////////// *
* ////                        2. Data Cleaning and Exploring                                   //// *
* ///////////////////////////////////////////////////////////////////////////////////////////////// * 

* -------------------- rename the data --------------------- *

rename g01q01 enumerator
rename g01q02 datetime
rename g01q03 ward
rename g01q04sq001 bed 
rename g01q06 momname
rename g01q07sq001 hospital_id

rename g02q01 eligibility
rename g02q02 willingness_either
rename g02q03 parent_unwilling

rename g04q01 timestamp_begin_bl
rename g04q02 willingness_both
rename g04q04 finish_bl

rename g06q02 timestamp_begin_intervention
replace timestamp_begin_intervention = timestamp1 if timestamp_begin_intervention == ""
drop timestamp1
rename g01q08 treatment
rename g06q01 discussion_begin
rename g06q16 discussion_fail_reason

* -- father company time in a weekday --
rename g06q04sq001 father_company_time_weekday_0
rename g06q04sq002 father_company_time_weekday_1
rename g06q04sq003 father_company_time_weekday_2
rename g06q04sq004 father_company_time_weekday_3
rename g06q04sq005 father_company_time_weekday_4
rename g06q04sq006 father_company_time_weekday_5
rename g06q04sq007 father_company_time_weekday_6
rename g06q04sq008 father_company_time_weekday_7
rename g06q04sq009 father_company_time_weekday_8

rename g06q05sq001 mother_company_time_weekend_0 // mother assumes the time of father's company
rename g06q05sq002 mother_company_time_weekend_1
rename g06q05sq003 mother_company_time_weekend_2
rename g06q05sq004 mother_company_time_weekend_3
rename g06q05sq005 mother_company_time_weekend_4
rename g06q05sq006 mother_company_time_weekend_5
rename g06q05sq007 mother_company_time_weekend_6
rename g06q05sq008 mother_company_time_weekend_7
rename g06q05sq009 mother_company_time_weekend_8

rename g06q06sq001 father_company_time_workday_0
rename g06q06sq002 father_company_time_workday_1
rename g06q06sq003 father_company_time_workday_2
rename g06q06sq004 father_company_time_workday_3
rename g06q06sq005 father_company_time_workday_4
rename g06q06sq006 father_company_time_workday_5
rename g06q06sq007 father_company_time_workday_6
rename g06q06sq008 father_company_time_workday_7
rename g06q06sq009 father_company_time_workday_8

rename g06q07sq001 mother_company_time_workday_0 // mother assumes the time of father's company
rename g06q07sq002 mother_company_time_workday_1
rename g06q07sq003 mother_company_time_workday_2
rename g06q07sq004 mother_company_time_workday_3
rename g06q07sq005 mother_company_time_workday_4
rename g06q07sq006 mother_company_time_workday_5
rename g06q07sq007 mother_company_time_workday_6
rename g06q07sq008 mother_company_time_workday_7
rename g06q07sq009 mother_company_time_workday_8

*-- father's expectation on how they divide the tasks of taking care of the baby
rename g06q09sq001 father_expectation_diaper
rename g06q09sq002 father_expectation_night
rename g06q09sq004 father_expectation_play
rename g06q09sq005 father_expectation_lull

replace father_expectation_diaper = g06q10sq0011 if father_expectation_diaper == ""
replace father_expectation_night = g06q10sq0021 if father_expectation_night == ""
replace father_expectation_play = g06q10sq0041 if father_expectation_play == ""
replace father_expectation_lull = g06q10sq0051 if father_expectation_lull == ""
drop g06q10sq0011 g06q10sq0021 g06q10sq0041 g06q10sq0051

rename g06q10sq0012 mother_expectation_diaper
rename g06q10sq0022 mother_expectation_night
rename g06q10sq0042 mother_expectation_play
rename g06q10sq0052 mother_expectation_lull

*-- paternal leave
rename g06q11 paternal_leave

*-- did father raise up the topic of father involvement by himself, control group
rename g06q98 father_volunteer_role

*-- mostly discussed topics, control group
rename g06q99 mostly_discussed_topic

rename g07q91 timestamp_end_discussion
replace timestamp_end_discussion = timestamp2 if timestamp_end_discussion == ""
drop timestamp2

rename g06q15 discussion_success


rename g07q03 video_success
replace video_success = g07q11 if video_success == ""
drop g07q11

replace video_helpful_f = g07q04 if video_helpful_f == ""
drop g07q04
replace video_helpful_m = g07q05 if video_helpful_m == ""
drop g07q05

rename g07q08 video_fail_reason

rename g08q02sq001 triple_p_id 
rename g08q05 triple_p_success
rename g08q06 triple_p_fail_reason

rename g08q07 timestamp_end_intervention
replace timestamp_end_intervention = timestamp3 if timestamp_end_intervention == ""
drop timestamp3

rename g09q04 discussion_consistency
rename g09q05 discussion_interaction
rename g09q06 discussion_other_notices
rename g09q02 discussion_responsive_f
rename g09q03 discussion_responsive_m

rename g10q01 video_feedback_f
rename g10q02 video_finish_f
rename g10q03 video_feedback_m
rename g10q04 video_finish_m
rename g10q06 video_comment

rename g11q01 engagement_mother
rename g11q02 engagement_father

*-- why not eligible
rename g12q01sq001 not_eligible_reason_age_f
rename g12q01sq002 not_eligible_reason_age_m
rename g12q01sq003 not_eligible_reason_living_f
rename g12q01sq004 not_eligible_reason_living_m
rename g12q01sq006 not_eligible_reason_gestation
rename g12q01sq007 not_eligible_reason_notfirstborn
rename g12q01sq008 not_eligible_reason_notin3days
rename g12q01sq009 not_eligible_reason_fnotaround

rename g12q02 unwilling_reason_f
rename g12q04 relationship_quality
rename g12q06 bed_in_room_site
rename g12q03 environment_recruitment

*-- who else in the ward
rename g12q05sq001 who_in_ward_nanny
rename g12q05sq002 who_in_ward_mm // mother's mother
rename g12q05sq003 who_in_ward_fm // father's mother
rename g12q05sq004 who_in_ward_noone
rename g12q05other who_in_ward_other

rename g12q07 sidenotes
rename g13q12sq001 hospital_id_2


* ------------------ drop the variables that are not needed ------------------ *
drop g0*
drop hided*
/* drop rand* */
drop g1*
drop grouptime*
drop *time

drop if submitdate == ""
drop id lastpage startlanguage seed ipaddr refurl

*------------------------------------------------------------------------------------------- *
* ------------------------------------- CLEAN THE DATA ------------------------------------- *

* date
gen submitdatetime = clock(submitdate, "YMDhms") if survey_id ~= 175343
gen date_temp = startdate if survey_id == 175343 

gen double date_part = date(substr(date_temp, 1, 8), "MD20Y")
gen double hour_part = real(substr(date_temp, 9, strpos(date_temp, ":") - 9))
gen double minute_part = real(substr(date_temp, strpos(date_temp, ":") + 1, 2))

gen double datetime_combined = dhms(date_part, hour_part, minute_part, 0)
replace submitdatetime = datetime_combined if survey_id == 175343
format submitdatetime %tc
drop date_temp date_part hour_part minute_part datetime_combined submitdate startdate

* date stamp that is used to match the randomization code
gen datestamp_temp = date(datestamp, "YMDhms") if survey_id ~= 175343
replace datestamp_temp = date(substr(datestamp, 1, 8), "MD20Y") if survey_id == 175343
format datestamp_temp %td
drop datestamp
rename datestamp_temp datestamp

* manually fix some errorous records in the survey
replace enumerator = "Maggie" if enumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")
replace checkenumerator = "Maggie" if checkenumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")
replace checkenumerator = "Cong" if hospital_id == "332803"
replace checkenumerator = "" if checkenumerator == "0"
replace enumerator = checkenumerator if enumerator != checkenumerator & checkenumerator != ""  & checkenumerator != "." 
replace checkenumerator = "Lucy" if checkenumerator == "Finn" & datestamp == date("2024-11-02","YMD")
encode enumerator, gen(enumerator_id)


* hospital_id
replace hospital_id = hospital_id_westside if hospital_id == ""
drop hospital_id_westside
drop if hospital_id == "." | hospital_id == "123456" | hospital_id == "777777" | hospital_id == "888888" | hospital_id == "111111" | momname == "测试" | hospital_id == "0"

* enumerator

* treatment
replace treatment = "T0" if strpos(treatment, "T0")>0
replace treatment = "T1" if strpos(treatment, "T1")>0
replace treatment = "T2" if strpos(treatment, "T2")>0

* ONLY KEEP THE FINAL RECORDS FOR ALL HOSPITAL_ID
**** NOTE: skip this step if you are not running the analysis, rather, you are conducting a check on enumerators' behavior
sort hospital_id submitdatetime
by hospital_id : gen id = _n
duplicates tag hospital_id, gen (dup_id)
forvalues i = 1/11 {
    forvalues j = 1/`i' {
        drop if dup_id == `i' & id == `j'
    }
}
drop id dup_id
drop if hospital_id == "."
duplicates report hospital_id


/* 


// save a file used for balance check
keep willingness_both discussion_consistency discussion_interaction engagement_father engagement_mother relationship_quality dominance ///
parenting_willingness_f parenting_willingness_m environment_recruitment hospital_id vip cluster_var enumerator_id strata
  */

gen temp = .
replace temp = 1 if discussion_consistency == "非常少"
replace temp = 2 if discussion_consistency == "比较少"
replace temp = 3 if discussion_consistency == "一般"
replace temp = 4 if discussion_consistency == "比较多"
replace temp = 5 if discussion_consistency == "非常多"
drop discussion_consistency
rename temp discussion_consistency

gen temp = .
replace temp = 1 if discussion_interaction == "非常少"
replace temp = 2 if discussion_interaction == "比较少"
replace temp = 3 if discussion_interaction == "一般"
replace temp = 4 if discussion_interaction == "比较多"
replace temp = 5 if discussion_interaction == "非常多"
drop discussion_interaction
rename temp discussion_interaction


// environment
gen temp = .
replace temp = 1 if environment_recruitment == "不断地被其他人或事打扰"
replace temp = 2 if environment_recruitment == "整体是安静的，但偶尔被其他人或事打扰"
replace temp = 3 if environment_recruitment == "安静的，不被打扰的"
drop environment_recruitment
rename temp environment_recruitment

// engagement
fre engagement_father
gen engagement_father_temp = .
replace engagement_father_temp = 2 if engagement_father == "参与度较低"
replace engagement_father_temp = 3 if engagement_father == "参与度一般"
replace engagement_father_temp = 4 if engagement_father == "参与度较高"
replace engagement_father_temp = 5 if engagement_father == "参与度非常高"

fre engagement_mother
gen engagement_mother_temp = .
replace engagement_mother_temp = 1 if engagement_mother == "参与度低"
replace engagement_mother_temp = 1 if engagement_mother == "参与度非常低"
replace engagement_mother_temp = 2 if engagement_mother == "参与度较低"
replace engagement_mother_temp = 3 if engagement_mother == "参与度一般"
replace engagement_mother_temp = 4 if engagement_mother == "参与度较高"
replace engagement_mother_temp = 5 if engagement_mother == "参与度非常高"
drop engagement_father engagement_mother
rename (engagement_father_temp engagement_mother_temp)(engagement_father engagement_mother)

// willingness
gen willingness_both_temp = .
replace willingness_both_temp = 2 if willingness_both == "妈妈意愿较高，爸爸一般"
replace willingness_both_temp = 2 if willingness_both == "爸爸意愿较高，妈妈一般"
replace willingness_both_temp = 1 if willingness_both == "双方意愿一般"
replace willingness_both_temp = 3 if willingness_both == "双方都非常愿意" 
drop willingness_both
rename willingness_both_temp willingness_both

gen parenting_willingness_f_temp = .
replace parenting_willingness_f_temp = 1 if parenting_willingness_f == "很低"
replace parenting_willingness_f_temp = 2 if parenting_willingness_f == "比较低"
replace parenting_willingness_f_temp = 3 if parenting_willingness_f == "有点低"
replace parenting_willingness_f_temp = 4 if parenting_willingness_f == "看不出来"
replace parenting_willingness_f_temp = 5 if parenting_willingness_f == "有点高"
replace parenting_willingness_f_temp = 6 if parenting_willingness_f == "比较高" 
replace parenting_willingness_f_temp = 7 if parenting_willingness_f == "很高"
drop parenting_willingness_f
rename parenting_willingness_f_temp parenting_willingness_f

gen parenting_willingness_m_temp = .
replace parenting_willingness_m_temp = 1 if parenting_willingness_m == "很低"
replace parenting_willingness_m_temp = 2 if parenting_willingness_m == "比较低"
replace parenting_willingness_m_temp = 3 if parenting_willingness_m == "有点低"
replace parenting_willingness_m_temp = 4 if parenting_willingness_m == "看不出来"
replace parenting_willingness_m_temp = 5 if parenting_willingness_m == "有点高"
replace parenting_willingness_m_temp = 6 if parenting_willingness_m == "比较高"
replace parenting_willingness_m_temp = 7 if parenting_willingness_m == "很高"
drop parenting_willingness_m
rename parenting_willingness_m_temp parenting_willingness_m

gen relationship_quality_temp = .
replace relationship_quality_temp = 1 if relationship_quality == "很疏远"
replace relationship_quality_temp = 2 if relationship_quality == "比较疏远"
replace relationship_quality_temp = 3 if relationship_quality == "一般，不近不远"
replace relationship_quality_temp = 4 if relationship_quality == "比较亲近"
replace relationship_quality_temp = 5 if relationship_quality == "很亲近"
drop relationship_quality
rename relationship_quality_temp relationship_quality

gen dominance_temp = .
replace dominance_temp = 1 if dominance == "父亲明显主导"
replace dominance_temp = 2 if dominance == "父亲稍微主导"
replace dominance_temp = 3 if dominance == "看不出来"
replace dominance_temp = 4 if dominance == "母亲稍微主导"
replace dominance_temp = 5 if dominance == "母亲明显主导"
drop dominance
rename dominance_temp dominance



save "$proc/enumerator_cleaned_`date'.dta", replace






* ///////////////////////////////////////////////////////////////////////////////////////// *
* ////                        3. GENERATE CLUSTERS                                     //// *
* ///////////////////////////////////////////////////////////////////////////////////////// * 

// room number
// import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match.xlsx", firstrow sheet("Sheet1") clear
// keep room_yfy room_num
// gen ward = substr(room_num,1,2)
// drop if ward == "5A"
// gen bed = substr(room_num,3,2)
// replace bed = "0" + bed if strlen(bed) == 1
// drop room_num
// gen room_num = ward + bed 
// drop ward bed
// tempfile east_ordinary1
// save  `east_ordinary1'

// import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match_ordinary.xlsx", firstrow sheet("Sheet1") clear
// keep room_yfy roomID 
// rename roomID room_num
// append using `east_ordinary1'
// tempfile east_ordinary
// save `east_ordinary'

// import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_ordinary.xlsx", firstrow allstring sheet("Sheet1") clear
// keep room_yfy roomID
// rename roomID room_num
// drop if room_yfy == ""
// append using `east_ordinary'
// tempfile ordinary 
// save `ordinary'

// import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear
// keep room_yfy roomID
// tempfile west_vip
// save `west_vip'

// import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear
// keep room_yfy roomID
// append using `west_vip'
// rename roomID room_num

// append using `ordinary'

// duplicates drop room_yfy, force

// save "$proc/room_bed_match.dta", replace






// clear
// local files "593646 175343 464493 241113 241204 877826 250120 250125 250314 250427 250703"

// foreach id of local files {
//     import delimited using "$data/Enumerator/results-survey`id'.csv", ///
//         bindquote(strict) stringcols(_all) encoding("utf-8") clear
//     gen survey_id = `id'
//     tempfile survey`id'
//     save `survey`id''
// }

// use `survey593646', clear
// foreach id in 175343 464493 241113 241204 877826 250120 250125 250314 250427 250703 {
//     append using `survey`id'', force
// }

// *  ------ clean data ------ *
// drop if submitdate == ""

// rename g01q01 enumerator
// rename g01q02 datetime
// rename g01q03 ward
// rename g01q04sq001 bed 
// rename g01q07sq001 hospital_id

// keep enumerator datestamp datetime ward bed hospital_id survey_id checkenumerator

// * date time that is used to match the randomization code
// gen datetime_temp = date(datetime, "YMDhms") if survey_id ~= 175343
// replace datetime_temp = date(substr(datetime, 1, 8), "MD20Y") if survey_id == 175343
// format datetime_temp %td
// drop datetime
// rename datetime_temp datetime


// * date stamp 
// gen datestamp_temp = date(datestamp, "YMDhms") if survey_id ~= 175343
// replace datestamp_temp = date(substr(datestamp, 1, 8), "MD20Y") if survey_id == 175343
// format datestamp_temp %td
// drop datestamp
// rename datestamp_temp datestamp

// * manually fix some errorous records in the survey
// replace enumerator = "Maggie" if enumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")
// replace checkenumerator = "Maggie" if checkenumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")
// replace checkenumerator = "Cong" if hospital_id == "332803"
// replace enumerator = checkenumerator if enumerator != checkenumerator & checkenumerator != ""  & checkenumerator != "." 
// replace checkenumerator = "Lucy" if checkenumerator == "Finn" & datestamp == date("2024-11-02","YMD")
// encode enumerator, gen(enumerator_id)

// replace bed = "0" + bed if strlen(bed) == 1
// gen room_yfy = ward + bed

// merge m:1 room_yfy using "$proc/room_bed_match.dta"
// replace room_num = "328" if room_num == ""
// drop if _merge == 2
// drop _merge 

// // month num
// gen cutoff_date = date("24/09/2024", "DMY")
// gen week_num = floor((datetime - cutoff_date) / 7) 
// gen month_num = floor((datetime - cutoff_date) / 28)


// // vip
// destring bed, replace force
// * eastside
// gen vip = 0 
// replace vip = 1 if strlen(ward) == 3
// replace vip = 1 if inlist(bed,211,213,215,216,217,218,219,220,221,323,325,326,327,328,501,502,503,505,506,507,508,509,510,511,512,513,515)


// // triple room
// gen bed_in_room = 2 
// replace bed_in_room = 1 if strlen(ward) == 3
// replace bed_in_room = 3 if (ward == "4A" & bed < 39)
// replace bed_in_room = 3 if (ward == "5A" & bed < 38)
// replace bed_in_room = 3 if (ward == "5B" & bed < 40 & bed > 2)
// replace bed_in_room = 3 if (ward == "5B" & bed < 50 & bed > 46)
// replace bed_in_room = 3 if (ward == "6A" & bed < 38)
// replace bed_in_room = 3 if (ward == "6B" & bed < 40 & bed > 2)
// replace bed_in_room = 3 if (ward == "6B" & bed < 50 & bed > 46)
// replace bed_in_room = 3 if (ward == "7A" & bed < 40 & bed > 2)
// replace bed_in_room = 3 if (ward == "7B" & bed < 40 & bed > 2)
// replace bed_in_room = 3 if (ward == "7B" & bed > 46)

// * westside
// replace bed_in_room = 1 if bed > 99
// replace bed_in_room = 2 if inlist(bed,202,203,205,206,207,208,209,210)
// replace bed_in_room = 3 if inlist(bed,332,333,335,336,337,338)
// replace bed_in_room = 4 if inlist(bed,330,331,332,355,317,318,319,353,313,315,316,352,310,311,312,351,307,308,309,350)
// replace bed_in_room = 5 if inlist(bed,301,302,303,305,306)


// // randomization strata
// gen triple = (bed_in_room != 2 & bed_in_room != 1) 
// egen bed_num = group(vip triple)
// drop if bed_num == 4

// // randomization strata
// egen strata = group(bed_num month_num) 


// //cluster var
// gen ward_num = substr(ward,1,1) if vip == 0
// destring ward_num, replace force
// gen cluster_var = ward_num*1000+ bed * 100 + week_num if vip == 0
// replace cluster_var = bed * 100 + week_num if cluster_var == .
// destring hospital_id, gen(hospital_id_temp)
// replace cluster_var = hospital_id_temp if vip == 1
// drop hospital_id_temp


// // save a file that will be used to merge cluster variables with other datasets
// keep hospital_id vip bed_num cluster_var enumerator_id strata
// save "$proc/clusters_`date'.dta", replace



log close
