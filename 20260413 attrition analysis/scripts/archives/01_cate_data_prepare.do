********************************************************************************
********************************************************************************
* TITLE: Data Cleaning and Preparing for Analysing Baseline Characteristics' Prediction Power on Attrition
* Project: BEBE
* Data: Enumerator Survey, Baseline Surveys, and 1m Survey
* Author: Haoyue Wu
* Last updated: Sept14 2025




************* log *************
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project cate_data_prepare
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd


* ///////////////////////////////////////////////////////////////////////////////////////// *
* ////                        1. Enumerator Survey                                     //// *
* ///////////////////////////////////////////////////////////////////////////////////////// * 

* ------------------- *
* Survey 593646
* ------------------- *
import delimited using "$data/results-survey593646.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 593646
tempfile 1
save `1'

* ------------------- *
* Survey 175343
* ------------------- *
import delimited using "$data/results-survey175343_new.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 175343
tempfile 2
save `2'

* ------------------- *
* Survey 464493 
* (added control group discussion)
* ------------------- *
import delimited using "$data/results-survey464493.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 464493
tempfile 3
save `3'

* ------------------- *
* Survey 241113 
* (added video survey)
* ------------------- *
import delimited using "$data/results-survey241113.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
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
import delimited using "$data/results-survey241204.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 241204

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 mother_dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 5
save `5'

* ------------------- *
* Survey 877826
* (begin recruitment at westside hospital)
* ------------------- *
import delimited using "$data/results-survey877826.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 877826
rename g01q07wsq001 hospital_id_westside

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 mother_dominance
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
import delimited using "$data/results-survey250120.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250120
rename g01q07wsq001 hospital_id_westside

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 mother_dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 7
save `7'

* ------------------- *
* Survey 250125
* --------------------- *
import delimited using "$data/results-survey250125.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250125
rename g01q07wsq001 hospital_id_westside

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 mother_dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 8
save `8'

* ------------------- *
* Survey 250314
* 1. added control video
* 2. deleted westside design
* ------------------- *
import delimited using "$data/results-survey250314.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250314

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 mother_dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 9
save `9'

* ------------------- *
* Survey 250427
* updated ward layout
* ------------------- *
import delimited using "$data/results-survey250427.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250427

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 mother_dominance
rename g13q98 parenting_willingness_f
rename g01q99 parenting_willingness_m

tempfile 10
save `10'

* ------------------- *
* Survey 250703
* ------------------- *
import delimited using "$data/results-survey250703.csv", bindquote(strict) stringcols(_all) encoding("utf-8") clear
gen survey_id = 250427

rename vfs01 video_rating_f
rename vfs03 video_change_f
rename vfs05 video_rating_m
rename vfs07 video_change_m
rename g10q01 video_like_f_enu
rename g10q03 video_like_m_enu

* new observation questions
rename g012q97 mother_dominance
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

drop parent_unwilling eligibility willingness_either timestamp_begin_bl ///
treatment discussion_fail_reason discussion_begin father_company_time_weekday_* finish_bl ///
mother_company_time_weekend_* father_company_time_workday_* mother_company_time_workday_* /// 
father_expectation_* mother_expectation_* paternal_leave mostly_discussed_topic discussion_success ///
randvideocontrol randvideoshowsq001 randvideoshowsq002 randvideoshowsq003 randvideoshowsq004 ///
randvideoshowsq006 randvideoshowsq007 video_success video_fail_reason randvideosurvey ///
fatherpreamble motherpreamblecopy couplevideo vfsdisplay triple_p_id timestamp_end_intervention ///
triple_p_success triple_p_fail_reason discussion_other_notices not_eligible_reason_* unwilling_reason_f ///
sidenotes hospital_id_2 timestamp_* randtable hospitalbranch 
drop who_in_ward_other

drop discussion_consistency discussion_interaction parenting_willingness_f parenting_willingness_m father_volunteer_role
drop video_*
*----------------------- Assign Values to String Variables -------------------------------- *

// environment
fre environment_recruitment 
gen temp = .
replace temp = 1 if environment_recruitment == "不断地被其他人或事打扰"
replace temp = 2 if environment_recruitment == "整体是安静的，但偶尔被其他人或事打扰"
replace temp = 3 if environment_recruitment == "安静的，不被打扰的"
drop environment_recruitment
rename temp environment_recruitment

// engagement
fre engagement_father
gen engagement_father_temp = .
replace engagement_father_temp = 1 if engagement_father == "参与较低"
replace engagement_father_temp = 1 if engagement_father == "参与程度一般"
replace engagement_father_temp = 3 if engagement_father == "参与度较高"
replace engagement_father_temp = 4 if engagement_father == "参与度非常高"
replace engagement_father_temp = 1 if engagement_father == "很低"
replace engagement_father_temp = 1 if engagement_father == "有点低"
replace engagement_father_temp = 1 if engagement_father == "比较低"
replace engagement_father_temp = 2 if engagement_father == "有点高"
replace engagement_father_temp = 3 if engagement_father == "比较高"
replace engagement_father_temp = 4 if engagement_father == "很高"

fre engagement_mother
gen engagement_mother_temp = .
replace engagement_mother_temp = 1 if engagement_mother == "参与度非常低"
replace engagement_mother_temp = 1 if engagement_mother == "参与度较低"
replace engagement_mother_temp = 1 if engagement_mother == "参与度一般"
replace engagement_mother_temp = 3 if engagement_mother == "参与度较高"
replace engagement_mother_temp = 4 if engagement_mother == "参与度非常高"
replace engagement_mother_temp = 1 if engagement_mother == "很低"
replace engagement_mother_temp = 1 if engagement_mother == "有点低"
replace engagement_mother_temp = 1 if engagement_mother == "比较低"
replace engagement_mother_temp = 2 if engagement_mother == "有点高"
replace engagement_mother_temp = 3 if engagement_mother == "比较高"
replace engagement_mother_temp = 4 if engagement_mother == "很高"
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

gen relationship_quality_temp = .
replace relationship_quality_temp = 1 if relationship_quality == "很疏远"
replace relationship_quality_temp = 2 if relationship_quality == "比较疏远"
replace relationship_quality_temp = 3 if relationship_quality == "一般，不近不远"
replace relationship_quality_temp = 4 if relationship_quality == "比较亲近"
replace relationship_quality_temp = 5 if relationship_quality == "很亲近"
drop relationship_quality
rename relationship_quality_temp relationship_quality

gen mother_dominance_temp = .
replace mother_dominance_temp = 1 if mother_dominance == "父亲明显主导"
replace mother_dominance_temp = 2 if mother_dominance == "父亲稍微主导"
replace mother_dominance_temp = 3 if mother_dominance == "看不出来"
replace mother_dominance_temp = 4 if mother_dominance == "母亲稍微主导"
replace mother_dominance_temp = 5 if mother_dominance == "母亲明显主导"
drop mother_dominance
rename mother_dominance_temp mother_dominance


* ---  observation questions ---- *
destring bed_in_room_site, replace force
drop who_in_ward*

drop discussion_responsive_f discussion_responsive_m

*------------------------------------------------------------------------------------------- *
* ------------------------------------- CLEAN THE DATA ------------------------------------- *

* date
gen submitdatetime = clock(submitdate, "YMDhms") if survey_id != 175343
gen date_temp = startdate if survey_id == 175343 

gen double date_part = date(substr(date_temp, 1, 8), "MD20Y")
gen double hour_part = real(substr(date_temp, 9, strpos(date_temp, ":") - 9))
gen double minute_part = real(substr(date_temp, strpos(date_temp, ":") + 1, 2))

gen double datetime_combined = dhms(date_part, hour_part, minute_part, 0)
replace submitdatetime = datetime_combined if survey_id == 175343
format submitdatetime %tc
drop date_temp date_part hour_part minute_part datetime_combined submitdate startdate

* date stamp that is used to match the randomization code
gen datestamp_temp = date(datestamp, "YMDhms") if survey_id != 175343
replace datestamp_temp = date(substr(datestamp, 1, 8), "MD20Y") if survey_id == 175343
format datestamp_temp %td
drop datestamp
rename datestamp_temp datestamp

* manually fix some erroneous records in the survey
replace enumerator = "Maggie" if enumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")
replace checkenumerator = "Maggie" if checkenumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")

* hospital_id
replace hospital_id = hospital_id_westside if hospital_id == ""
drop hospital_id_westside
drop if hospital_id == "." | hospital_id == "123456" | hospital_id == "777777" | hospital_id == "888888" | hospital_id == "111111" | momname == "测试" | hospital_id == "0"

* enumerator
replace checkenumerator = "" if checkenumerator == "0"

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

save "$proc/cleaned_data.dta", replace

* //////////////////////////// Creating Cluster Variables ////////////////////////////////////// *
// room number
import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match.xlsx", firstrow sheet("Sheet1") clear
/* import excel using "/Users/haolianghu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match.xlsx", firstrow sheet("Sheet1") clear */
keep room_yfy room_num
gen ward = substr(room_num,1,2)
drop if ward == "5A"
gen bed = substr(room_num,3,2)
replace bed = "0" + bed if strlen(bed) == 1
drop room_num
gen room_num = ward + bed 
drop ward 
tempfile east_ordinary1
save  `east_ordinary1'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match_ordinary.xlsx", firstrow sheet("Sheet1") clear
/* import excel using "/Users/haolianghu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match_ordinary.xlsx", firstrow sheet("Sheet1") clear  */
keep room_yfy roomID 
rename roomID room_num
append using `east_ordinary1'
tempfile east_ordinary
save `east_ordinary'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_ordinary.xlsx", firstrow allstring sheet("Sheet1") clear
/* import excel using "/Users/haolianghu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_ordinary.xlsx", firstrow allstring sheet("Sheet1") clear  */
keep room_yfy roomID
rename roomID room_num
drop if room_yfy == ""
append using `east_ordinary'
tempfile ordinary 
save `ordinary'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear
/* import excel using "/Users/haolianghu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear  */
keep room_yfy roomID
tempfile west_vip
save `west_vip'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear
/* import excel using "/Users/haolianghu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear  */
keep room_yfy roomID
append using `west_vip'
rename roomID room_num

append using `ordinary'

duplicates drop room_yfy, force

tempfile temp
save `temp'

use "$proc/cleaned_data.dta", clear

replace bed = "0" + bed if strlen(bed) == 1
gen room_yfy = ward + bed

merge m:1 room_yfy using `temp'
replace room_num = "328" if room_num == ""
drop if _merge == 2
drop _merge 

// month num
gen cutoff_date = date("24/09/2024", "DMY")
gen week_num = floor((datestamp - cutoff_date) / 7) 
gen month_num = floor((datestamp - cutoff_date) / 28)

// vip
destring bed, replace force
* eastside
gen vip = 0 
replace vip = 1 if strlen(ward) == 3
replace vip = 1 if inlist(bed,211,213,215,216,217,218,219,220,221,323,325,326,327,328,501,502,503,505,506,507,508,509,510,511,512,513,515)

// triple room
gen bed_in_room = 2 
replace bed_in_room = 1 if strlen(ward) == 3
replace bed_in_room = 3 if (ward == "4A" & bed < 39)
replace bed_in_room = 3 if (ward == "5A" & bed < 38)
replace bed_in_room = 3 if (ward == "5B" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "5B" & bed < 50 & bed > 46)
replace bed_in_room = 3 if (ward == "6A" & bed < 38)
replace bed_in_room = 3 if (ward == "6B" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "6B" & bed < 50 & bed > 46)
replace bed_in_room = 3 if (ward == "7A" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "7B" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "7B" & bed > 46)

* westside
replace bed_in_room = 1 if bed > 99
replace bed_in_room = 2 if inlist(bed,202,203,205,206,207,208,209,210)
replace bed_in_room = 3 if inlist(bed,332,333,335,336,337,338)
replace bed_in_room = 4 if inlist(bed,330,331,332,355,317,318,319,353,313,315,316,352,310,311,312,351,307,308,309,350)
replace bed_in_room = 5 if inlist(bed,301,302,303,305,306)

gen triple = (bed_in_room != 2 & bed_in_room != 1) 
egen bed_num = group(vip triple)
drop if bed_num == 4

// randomization strata
egen strata = group(bed_num month_num) 

/* replace strata = group(datestamp) if vip == 1 */

//cluster var
gen ward_num = substr(ward,1,1) if vip == 0
destring ward_num, replace force
gen cluster_var = ward_num*1000+ bed * 100 + week_num if vip == 0
replace cluster_var = bed * 100 + week_num if cluster_var == .
destring hospital_id, gen(hospital_id_temp)
replace cluster_var = hospital_id_temp if vip == 1
drop hospital_id_temp

// enumerator
replace checkenumerator = "Cong" if hospital_id == "332803"
replace enumerator = checkenumerator if enumerator != checkenumerator & checkenumerator != ""  & checkenumerator != "." 
replace checkenumerator = "Lucy" if checkenumerator == "Finn" & datestamp == date("2024-11-02","YMD")
encode enumerator, gen(enumerator_id)


// save a file used for balance check
drop checkenumerator ward bed momname submitdatetime datestamp room_yfy room_num cutoff_date ward_num
drop bed_in_room week_num month_num triple bed_num
save "$proc/enumerator_survey.dta", replace






* ///////////////////////////////////////////////////////////////////////////////////////// *
* ////                          2. Baseline Survey                                     //// *
* ///////////////////////////////////////////////////////////////////////////////////////// * 


import delimited using "$data/results-survey414279.csv", bindquote(strict) encoding("utf-8") clear
gen survey_id = "414279"

	rename g04q01 father_work_priority
	rename g04q02 father_strong_reliant
	rename g04q03 father_identity_importance
	rename g04q04 communication_quality
	rename g04q05 employment_security

        gen belief_father_15_walk = .
    gen belief_father_15_word = .
    gen belief_father_45_walk = .
    gen belief_father_45_word = .
    gen belief_mother_15_walk = .
    gen belief_mother_15_word = .
    gen belief_mother_45_walk = .
    gen belief_mother_45_word = .


    replace belief_father_15_walk = g02q01asq001 if (randgrouporder == 1 & randinvestmentorder == 1)
    replace belief_father_15_walk = g02q01bsq001 if (randgrouporder == 1 & randinvestmentorder == 2)
    replace belief_father_15_walk = g02q04asq001 if (randgrouporder == 2 & randinvestmentorder == 1)
    replace belief_father_15_walk = g02q04bsq001 if (randgrouporder == 2 & randinvestmentorder == 2)

    replace belief_father_15_word = g02q01asq002 if (randgrouporder == 1 & randinvestmentorder == 1)
    replace belief_father_15_word = g02q01bsq002 if (randgrouporder == 1 & randinvestmentorder == 2)
    replace belief_father_15_word = g02q04asq002 if (randgrouporder == 2 & randinvestmentorder == 1)
    replace belief_father_15_word = g02q04bsq002 if (randgrouporder == 2 & randinvestmentorder == 2)

    replace belief_father_45_walk = g02q01asq001 if (randgrouporder == 1 & randinvestmentorder == 2)
    replace belief_father_45_walk = g02q01bsq001 if (randgrouporder == 1 & randinvestmentorder == 1)
    replace belief_father_45_walk = g02q04asq001 if (randgrouporder == 2 & randinvestmentorder == 2)
    replace belief_father_45_walk = g02q04bsq001 if (randgrouporder == 2 & randinvestmentorder == 1)

    replace belief_father_45_word = g02q01asq002 if (randgrouporder == 1 & randinvestmentorder == 2)
    replace belief_father_45_word = g02q01bsq002 if (randgrouporder == 1 & randinvestmentorder == 1)
    replace belief_father_45_word = g02q04asq002 if (randgrouporder == 2 & randinvestmentorder == 2)
    replace belief_father_45_word = g02q04bsq002 if (randgrouporder == 2 & randinvestmentorder == 1)

    replace belief_mother_15_walk = g02q01asq001 if (randgrouporder == 2 & randinvestmentorder == 1)
    replace belief_mother_15_walk = g02q01bsq001 if (randgrouporder == 2 & randinvestmentorder == 2)
    replace belief_mother_15_walk = g02q04asq001 if (randgrouporder == 1 & randinvestmentorder == 1)
    replace belief_mother_15_walk = g02q04bsq001 if (randgrouporder == 1 & randinvestmentorder == 2)

    replace belief_mother_15_word = g02q01asq002 if (randgrouporder == 2 & randinvestmentorder == 1)
    replace belief_mother_15_word = g02q01bsq002 if (randgrouporder == 2 & randinvestmentorder == 2)
    replace belief_mother_15_word = g02q04asq002 if (randgrouporder == 1 & randinvestmentorder == 1)
    replace belief_mother_15_word = g02q04bsq002 if (randgrouporder == 1 & randinvestmentorder == 2)

    replace belief_mother_45_walk = g02q01asq001 if (randgrouporder == 2 & randinvestmentorder == 2)
    replace belief_mother_45_walk = g02q01bsq001 if (randgrouporder == 2 & randinvestmentorder == 1)
    replace belief_mother_45_walk = g02q04asq001 if (randgrouporder == 1 & randinvestmentorder == 2)
    replace belief_mother_45_walk = g02q04bsq001 if (randgrouporder == 1 & randinvestmentorder == 1)

    replace belief_mother_45_word = g02q01asq002 if (randgrouporder == 2 & randinvestmentorder == 2)
    replace belief_mother_45_word = g02q01bsq002 if (randgrouporder == 2 & randinvestmentorder == 1)
    replace belief_mother_45_word = g02q04asq002 if (randgrouporder == 1 & randinvestmentorder == 2)
    replace belief_mother_45_word = g02q04bsq002 if (randgrouporder == 1 & randinvestmentorder == 1)


    gen certainty_father = .
    gen certainty_mother = .


    replace certainty_father = 1 if (g02q02 == "非常不确定" & randgrouporder == 1)
    replace certainty_father = 2 if (g02q02 == "比较不确定" & randgrouporder == 1)
    replace certainty_father = 3 if (g02q02 == "比较确定" & randgrouporder == 1)
    replace certainty_father = 4 if (g02q02 == "非常确定" & randgrouporder == 1)
    replace certainty_father = 1 if (g02q05 == "非常不确定" & randgrouporder == 2)
    replace certainty_father = 2 if (g02q05 == "比较不确定" & randgrouporder == 2)
    replace certainty_father = 3 if (g02q05 == "比较确定" & randgrouporder == 2)
    replace certainty_father = 4 if (g02q05 == "非常确定" & randgrouporder == 2)
    
    replace certainty_mother = 1 if (g02q02 == "非常不确定" & randgrouporder == 2)
    replace certainty_mother = 2 if (g02q02 == "比较不确定" & randgrouporder == 2)
    replace certainty_mother = 3 if (g02q02 == "比较确定" & randgrouporder == 2)
    replace certainty_mother = 4 if (g02q02 == "非常确定" & randgrouporder == 2)
    replace certainty_mother = 1 if (g02q05 == "非常不确定" & randgrouporder == 1)
    replace certainty_mother = 2 if (g02q05 == "比较不确定" & randgrouporder == 1)
    replace certainty_mother = 3 if (g02q05 == "比较确定" & randgrouporder == 1)
    replace certainty_mother = 4 if (g02q05 == "非常确定" & randgrouporder == 1)

    gen ability_father = g02q03a
    gen ability_mother = g02q03b

    replace ability_father = g02q06b if ability_father == ""
    replace ability_mother = g02q06a if ability_mother == ""

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
    rename (ability_father_temp ability_mother_temp)(ability_father ability_mother)

tempfile bl_2
save `bl_2'

import delimited using "$data/results-survey872571.csv", bindquote(strict) encoding("utf-8") clear
rename g05q02sq001 g05q02
gen survey_id = "872571"

	rename g04q01 father_work_priority
	rename g04q02 father_strong_reliant
	rename g04q03 father_identity_importance
	rename g04q04 communication_quality
	rename g04q05 employment_security

    gen belief_father_15_walk = .
    gen belief_father_15_word = .
    gen belief_father_45_walk = .
    gen belief_father_45_word = .

    replace belief_father_15_walk = g02q01asq001 if randinvestmentorder == 1
    replace belief_father_15_walk = g02q01bsq001 if randinvestmentorder == 2

    replace belief_father_15_word = g02q01asq002 if randinvestmentorder == 1
    replace belief_father_15_word = g02q01bsq002 if randinvestmentorder == 2

    replace belief_father_45_walk = g02q01asq001 if randinvestmentorder == 2
    replace belief_father_45_walk = g02q01bsq001 if randinvestmentorder == 1

    replace belief_father_45_word = g02q01asq002 if randinvestmentorder == 2
    replace belief_father_45_word = g02q01bsq002 if randinvestmentorder == 1

    gen certainty_father = .
    gen certainty_mother = .


    replace certainty_father = 1 if g02q02 == "非常不确定"
    replace certainty_father = 2 if g02q02 == "比较不确定" 
    replace certainty_father = 3 if g02q02 == "比较确定" 
    replace certainty_father = 4 if g02q02 == "非常确定" 
    
    replace certainty_mother = 1 if g02q02 == "非常不确定"
    replace certainty_mother = 2 if g02q02 == "比较不确定"
    replace certainty_mother = 3 if g02q02 == "比较确定" 
    replace certainty_mother = 4 if g02q02 == "非常确定" 

    gen ability_father = g02q03a
    gen ability_mother = g02q03b

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
    rename (ability_father_temp ability_mother_temp)(ability_father ability_mother)

tempfile bl_3
save `bl_3'

import delimited using "$data/results-survey793221.csv", bindquote(strict) encoding("utf-8") clear
gen survey_id = "793221"
rename g05q02sq001 g05q02

	rename g04q01 father_work_priority
	rename g04q02 father_strong_reliant
	rename g04q03 mothers_know_better
	rename g04q04 women_work_hurt_family
	rename g04q05 women_more_income_problem
	/* rename g04q09 father_time_less_valuable */
	rename g04q06 father_identity_importance

	rename g04q07 communication_quality
	rename g04q08 employment_security

    gen belief_father_15_walk = .
    gen belief_father_15_word = .
    gen belief_father_45_walk = .
    gen belief_father_45_word = .

    replace belief_father_15_walk = g02q01asq001 if randinvestmentorder == 1
    replace belief_father_15_walk = g02q01bsq001 if randinvestmentorder == 2

    replace belief_father_15_word = g02q01asq002 if randinvestmentorder == 1
    replace belief_father_15_word = g02q01bsq002 if randinvestmentorder == 2

    replace belief_father_45_walk = g02q01asq001 if randinvestmentorder == 2
    replace belief_father_45_walk = g02q01bsq001 if randinvestmentorder == 1

    replace belief_father_45_word = g02q01asq002 if randinvestmentorder == 2
    replace belief_father_45_word = g02q01bsq002 if randinvestmentorder == 1

    gen certainty_father = .
    gen certainty_mother = .


    replace certainty_father = 1 if g02q02 == "非常不确定"
    replace certainty_father = 2 if g02q02 == "比较不确定" 
    replace certainty_father = 3 if g02q02 == "比较确定" 
    replace certainty_father = 4 if g02q02 == "非常确定" 
    
    replace certainty_mother = 1 if g02q02 == "非常不确定"
    replace certainty_mother = 2 if g02q02 == "比较不确定"
    replace certainty_mother = 3 if g02q02 == "比较确定" 
    replace certainty_mother = 4 if g02q02 == "非常确定" 

    gen ability_father = g02q03a
    gen ability_mother = g02q03b

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
    rename (ability_father_temp ability_mother_temp)(ability_father ability_mother)

tempfile bl_4
save `bl_4'

import delimited using "$data/results-survey968746.csv", bindquote(strict) encoding("utf-8") clear
gen survey_id = "968746"
rename g05q02sq001 g05q02

	rename g04q01 father_work_priority
	rename g04q02 father_strong_reliant
	rename g04q03 mothers_know_better
	rename g04q04 women_work_hurt_family
	rename g04q05 women_more_income_problem
	rename g04q06 father_identity_importance
	rename g04q09 father_time_less_valuable

    rename g02q01 extra_time_motor_dev
    rename g02q02 extra_time_linguistic_emo_dev
    rename g02q03 extra_time_father_wellbeing
    rename g02q04 extra_time_mother_wellbeing

    rename g02q05 ability_father
    rename g02q06 ability_mother 

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
    rename (ability_father_temp ability_mother_temp)(ability_father ability_mother)

	rename g04q07 communication_quality
	rename g04q08 employment_security


tempfile bl_5
save `bl_5'

import delimited using "$data/results-survey423721.csv", bindquote(strict) encoding("utf-8") clear
gen survey_id = "423721"

rename g05q02sq001 g05q02

rename g02q01 extra_time_motor_dev
rename g02q02 extra_time_linguistic_emo_dev
rename g02q03 extra_time_father_wellbeing
rename g02q04 extra_time_mother_wellbeing

	rename g04q01 father_work_priority
	rename g04q02 father_strong_reliant
	rename g04q03 mothers_know_better
	rename g04q04 women_work_hurt_family
	rename g04q05 women_more_income_problem
	rename g04q06 father_identity_importance
	rename g04q09 father_time_less_valuable


	rename g04q07 communication_quality
	rename g04q08 employment_security

    rename g03q05 g03q05sq001

    rename g05q03sq001 citzen_id
    gen ability_father = g02q05
    gen ability_mother = g02q06


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
    rename (ability_father_temp ability_mother_temp)(ability_father ability_mother)

tempfile bl_6
save `bl_6'


import delimited using "$data/results-survey659129.csv", bindquote(strict) encoding("utf-8") clear
gen survey_id = "659129"

rename g05q02sq001 g05q02

rename g02q01 extra_time_motor_dev
rename g02q02 extra_time_linguistic_emo_dev
rename g02q03 extra_time_father_wellbeing
rename g02q04 extra_time_mother_wellbeing

	rename g04q01 father_work_priority
	rename g04q02 father_strong_reliant
	rename g04q03 mothers_know_better
	rename g04q04 women_work_hurt_family
	rename g04q05 women_more_income_problem
	rename g04q06 father_identity_importance
	rename g04q09 father_time_less_valuable


	rename g04q07 communication_quality
	rename g04q08 employment_security

    rename g03q05 g03q05sq001

    rename g05q03sq001 citzen_id
    gen ability_father = g02q05
    gen ability_mother = g02q06


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
    rename (ability_father_temp ability_mother_temp)(ability_father ability_mother)


//append using `bl_1', force
append using `bl_2', force
append using `bl_3', force
append using `bl_4', force
append using `bl_5', force
append using `bl_6', force


drop if submitdate == ""
drop if g01q02 == "否"

// select date
gen date = date(submitdate, "YMDhms")
format date %td

gen cutoff_date = date("24/09/2024", "DMY")
format cutoff_date %td

drop if date < cutoff_date

rename g01q01sq001 hospital_id
rename g01q03 mother
rename g01q04 baby_female
rename g03q01 exp_father_involv_diaper
rename g03q02 exp_father_involv_night
rename g03q03 exp_father_involv_play
rename g03q04 exp_father_involv_lull
rename g03q05sq001 exp_father_time_chores



rename g01q42 social_desirability_scale1
rename g01q43 social_desirability_scale2
rename g09q44 social_desirability_scale3
rename g01q45 social_desirability_scale4
rename g01q46 social_desirability_scale5
rename g05q01 father_name
rename g05q02 phone_num
rename g09q40 alipay_account
rename g09q40other alipay_account_other




gen baby_female_temp = 0
replace baby_female_temp = 1 if baby_female == "女宝宝"

drop baby_female
rename baby_female_temp baby_female


local var exp_father_involv_diaper exp_father_involv_night exp_father_involv_play exp_father_involv_lull
foreach i in `var'{
    fre `i'
}
foreach i in `var'{
    gen `i'_temp = .
	replace `i' = subinstr(`i', `"""', "", .)
	replace `i'_temp = 1 if `i' == "主要{if(G01Q03==AO01, 我,我的伴侣)}负责"
	replace `i'_temp = 3 if `i' == "主要{if(G01Q03==AO01, 我的伴侣,我)}负责" // father responsible
	replace `i'_temp = 2 if `i' == "我们一起做，分担得差不多"
    replace `i'_temp = 2 if `i' == "我们一起做，分担的差不多"
	drop `i'
	rename `i'_temp `i'
}


local genderattitu "father_work_priority father_strong_reliant mothers_know_better women_work_hurt_family women_more_income_problem father_time_less_valuable father_identity_importance"
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

local var communication_quality
fre communication_quality
foreach i in `var'{
    gen `i'_temp = .
	
	replace `i'_temp = 1 if `i' == "非常差"
	replace `i'_temp = 2 if `i' == "差"
	replace `i'_temp = 3 if `i' == "尚可"
	replace `i'_temp = 4 if `i' == "好"
	replace `i'_temp = 5 if `i' == "非常好"

	drop `i'
	rename `i'_temp `i'
}


local var employment_security
fre employment_security
foreach i in `var'{
    gen `i'_temp = .
	replace `i' = subinstr(`i', `"""', "", .)
	replace `i'_temp = 2 if `i' == "{if(G01Q03=='AO01',我,他)}会有一份稳定的全职工作，但收入或其他待遇可能会变差一些。"
	replace `i'_temp = 3 if `i' == "{if(G01Q03=='AO01',我,他)}会有一份稳定的全职工作，而且收入或其他待遇可能会与现在差不多。"
	replace `i'_temp = 4 if `i' == "{if(G01Q03=='AO01',我,他)}会有一份稳定的全职工作，而且收入或其他待遇可能会变得更好。"
	replace `i'_temp = 1 if `i' == "{if(G01Q03=='AO01',我,他)}有较大的可能会失去工作。"
	replace `i'_temp = 1 if `i' == "{if(G01Q03=='AO01',我,他)}有较小的可能会失去工作。"
	replace `i'_temp = 1 if `i' == "{if(G01Q03=='AO01',我,他)}未来一年不会工作，因为{if(G01Q03=='AO01',我,他)}还在学习或接受培训。"
	replace `i'_temp = 1 if `i' == "{if(G01Q03=='AO01',我,他)}目前没有工作，但正在寻找新工作。"
	replace `i'_temp = 1 if `i' == "其它"
	
	drop `i'
	rename `i'_temp `i'
}

// social_desirability_scale
foreach i in 1 3 4{
	gen temp = .
	replace temp = 0 if social_desirability_scale`i' == "是"
	replace temp = 1 if social_desirability_scale`i' == "否"
	drop social_desirability_scale`i'
	rename temp social_desirability_scale`i'
}

foreach i in 2 5{
	gen temp = .
	replace temp = 1 if social_desirability_scale`i' == "是"
	replace temp = 0 if social_desirability_scale`i' == "否"
	drop social_desirability_scale`i'
	rename temp social_desirability_scale`i'
}

	gen temp = .
	replace temp = 1 if mother == "妈妈"
	replace temp = 0 if mother == "爸爸"
	drop mother
	rename temp mother

local belief "extra_time_motor_dev extra_time_linguistic_emo_dev extra_time_father_wellbeing extra_time_mother_wellbeing"
foreach var in `belief' {
    fre `var'
}
foreach var in `belief' {
    // For survey 491311, clear value if needed
    replace `var' = "" if survey_id == "491311"
    gen temp = .
    replace temp = 1 if `var' == "完全没有帮助"
    replace temp = 1 if `var' == "完全没有帮助/可能有害" 
    replace temp = 2 if `var' == "没有帮助但也没有坏处"
    replace temp = 3 if `var' == "帮助有限"
    replace temp = 3 if `var' == "有一些帮助"
    replace temp = 3 if `var' == "有一定帮助"
    replace temp = 4 if `var' == "帮助很大"
    replace temp = 5 if `var' == "帮助非常大"
    drop `var'
    rename temp `var'
}



replace exp_father_time_chores = "10" if exp_father_time_chores == "10+"
destring exp_father_time_chores, replace force

gen social_desirability_score = social_desirability_scale1 + social_desirability_scale2 + social_desirability_scale3 + social_desirability_scale4 + social_desirability_scale5
drop social_desirability_scale1 social_desirability_scale2 social_desirability_scale3 social_desirability_scale4 social_desirability_scale5

drop g04q08other
drop father_name phone_num alipay_account alipay_account_other citzen_id feedback interviewtime g05q03sq001
drop id startlanguage seed ipaddr refurl g01q02 textdisplay* g02q05 g02q06 g09q41 g05q04 g05q04other textdisplay08 g10q47 *time textdisplay02 
drop g02q* g04q05other grouptime* g03q05 rand*
drop lastpage startdate datestamp 
rename submitdate submitdate_bl

gen belief_father_walk = belief_father_45_walk - belief_father_15_walk
gen belief_father_word = belief_father_45_word - belief_father_15_word
gen belief_mother_walk = belief_mother_45_walk - belief_mother_15_walk
gen belief_mother_word = belief_mother_45_word - belief_mother_15_word

tostring hospital_id, replace force
duplicates drop hospital_id mother, force
replace hospital_id = "0" + hospital_id if strlen(hospital_id) == 5
drop if hospital_id == "111111"
duplicates tag hospital_id, gen(tag)
drop if tag == 0
drop survey_id

drop belief_father_15_walk belief_father_15_word belief_father_45_walk ///
belief_father_45_word belief_mother_15_walk belief_mother_15_word belief_mother_45_walk belief_mother_45_word
/* drop certainty_* */
drop exp_father_time_chores
/* drop if extra_time_father_wellbeing == . */
drop tag

gen exp_father_involv = exp_father_involv_diaper + exp_father_involv_lull + exp_father_involv_night + exp_father_involv_play
drop exp_father_involv_diaper exp_father_involv_lull exp_father_involv_night exp_father_involv_play
gen attitude = father_work_priority + father_strong_reliant + mothers_know_better + women_work_hurt_family + women_more_income_problem + father_time_less_valuable 
drop father_work_priority father_strong_reliant mothers_know_better women_more_income_problem women_work_hurt_family father_time_less_valuable
gen extra_time_belief = extra_time_father_wellbeing + extra_time_mother_wellbeing + extra_time_motor_dev +extra_time_linguistic_emo_dev
drop extra_time_father_wellbeing extra_time_mother_wellbeing extra_time_motor_dev extra_time_linguistic_emo_dev


gen belief_father = belief_father_walk + belief_father_word
gen belief_mother = belief_mother_walk + belief_mother_word
drop belief_father_walk belief_father_word belief_mother_walk belief_mother_word




save "$proc/baseline.dta",replace



* ///////////////////////////////////////////////////////////////////////////////// *
* ////                        3. 1m Survey                                     //// *
* ///////////////////////////////////////////////////////////////////////////////// * 

** 1m 659371 826686 137936 839976 757445 644261 972288 563862 477485

*---------------------*
* Survey 659371
*---------------------*
import delimited using "$data/results-survey659371.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04sq001, replace force
gen survey_id = "659371"
tempfile 1m_1
save `1m_1', replace

*---------------------*
* Survey 826686
*---------------------*
import delimited using "$data/results-survey826686.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04sq001, replace force
gen survey_id = "826686"
tempfile 1m_2
save `1m_2', replace

*---------------------*
* Survey 137936
*---------------------*
import delimited using "$data/results-survey137936.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05 g12q04sq001, replace force
gen survey_id = "137936"
tempfile 1m_3
save `1m_3', replace

*---------------------*
* Survey 839976 (requires extra cleaning)
*---------------------*
import delimited using "$data/results-survey839976.csv", bindquote(strict) encoding("utf-8") clear
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
    replace `var' = subinstr(`var', "次及以上", "", .)
    replace `var' = subinstr(`var', "次", "", .)
    destring `var', replace force
}

rename g02q06 g02q02
rename g02q07 g02q03

tempfile 1m_4
save `1m_4', replace

*---------------------*
* Survey 757445
*---------------------*
import delimited using "$data/results-survey757445.csv", bindquote(strict) encoding("utf-8") clear
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
import delimited using "$data/results-survey644261.csv", bindquote(strict) encoding("utf-8") clear
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
import delimited using "$data/results-survey972288.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05, replace force
gen survey_id = "972288"

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


*---------------------*
* Survey 563862
*---------------------*
import delimited using "$data/results-survey563862.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05, replace force
gen survey_id = "563862"
tempfile 1
save `1', replace

*---------------------*
* Survey 716853
*---------------------*
import delimited using "$data/results-survey716853.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05, replace force
gen survey_id = "716853"
tempfile 2
save `2', replace

*---------------------*
* Survey 477485
*---------------------*
import delimited using "$data/results-survey477485.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03 g01q04 g01q05, replace force
gen survey_id = "477485"
append using `1', force
append using `2', force


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

tempfile 1m_8
save `1m_8', replace



*---------------------
* SURVEY 727311 (short 1m)
*---------------------
import delimited using "$data/results-survey727311.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force
gen survey_id = "727311"

tempfile short1
save `short1'


import delimited using "$data/results-survey492913.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force
gen survey_id = "492913"

tempfile short2
save `short2'


import delimited using "$data/results-survey941843.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force
gen survey_id = "941843"

tempfile short3
save `short3'


import delimited using "$data/results-survey110807.csv", bindquote(strict) encoding("utf-8") clear
tostring g01q02 g01q03, replace force
gen survey_id = "110807"

append using `short1', force
append using `short2', force 
append using `short3', force
drop hided*

tempfile 1m_9
save `1m_9'





*******************************************
** APPEND SURVEY FILES TO CREATE MASTER  **
*******************************************
append using `1m_1', force
append using `1m_2', force
append using `1m_3', force
append using `1m_4', force
append using `1m_5', force
append using `1m_6', force
append using `1m_7', force
append using `1m_8', force


drop if submitdate == ""
duplicates drop firstname, force
drop if attribute_11 == ""
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

* -- Help after birth and planning --
rename g10q01sq001 help_after_birth_1
rename g10q01sq002 help_after_birth_2
rename g10q01sq003 help_after_birth_3
rename g10q01sq004 help_after_birth_4
rename g10q01sq005 help_after_birth_5
rename g10q01sq006 help_after_birth_6
rename g10q01other help_after_birth_other

rename g10q02sq001 plan_help_after_birth_1
rename g10q02sq002 plan_help_after_birth_2
rename g10q02sq003 plan_help_after_birth_3
rename g10q02sq004 plan_help_after_birth_4
rename g10q02sq005 plan_help_after_birth_5
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

/* -- Create Group and Mother Variables -- */
gen group = 0
replace group = 1 if attribute_5 == "Y"
replace group = 2 if attribute_6 == "Y"

gen mother = 1
replace mother = 0 if attribute_8 == "Y"

rename g04q09 father_time_less_valuable
fre father_time_less_valuable
gen temp = .
replace temp = 1 if father_time_less_valuable == "非常不同意"
replace temp = 2 if father_time_less_valuable == "不同意"
replace temp = 3 if father_time_less_valuable == "中立"
replace temp = 4 if father_time_less_valuable == "同意"
replace temp = 5 if father_time_less_valuable == "非常同意"
drop father_time_less_valuable
rename temp father_time_less_valuable



/* -- Recode Education Level -- */
fre education_level
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
    fre `var'
}   
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

fre parents_alive
gen temp = .
	replace temp = 1 if parents_alive == "是，他们都还健在"
	replace temp = 2 if parents_alive == "我母亲还健在（父亲已经离世）"
	replace temp = 3 if parents_alive == "我父亲还健在（母亲已经离世）"
	replace temp = 4 if parents_alive == "我父母都已经离世"
drop parents_alive
rename temp parents_alive

fre close_to_parents
gen temp = .
    replace temp = 0 if close_to_parents == "其他"
	replace temp = 1 if close_to_parents == "我的父母与我生活在一起（不是临时的）"
	replace temp = 2 if close_to_parents == "我与父母的关系非常亲近，我们频繁地联系或探望彼此"
	replace temp = 3 if close_to_parents == "我与父母的关系比较亲近，我们偶尔会联系或探望彼此"
	replace temp = 4 if close_to_parents == "我与父母的关系并不亲近，我们几乎不联系或探望彼此"
drop close_to_parents
rename temp close_to_parents

fre total_couple_income
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

fre building_ownership
gen temp = .
    replace temp = 0 if building_ownership == "其他"
	replace temp = 1 if building_ownership == "家庭拥有的"
	replace temp = 2 if building_ownership == "我们租住的"
drop building_ownership
rename temp building_ownership

fre building_area
replace building_area = "200" if building_area == "200及以上"
destring building_area, replace force

gen help_after_birth = 1 if help_after_birth_1 == "是" // nanny
replace help_after_birth = 2 if help_after_birth_2 == "是" // my mother
replace help_after_birth = 3 if help_after_birth_3 == "是" // my partner's mother
replace help_after_birth = 4 if help_after_birth_4 == "是" // other familiy members
replace help_after_birth = 5 if help_after_birth_5 == "是" // confinement center
replace help_after_birth = 6 if help_after_birth_6 == "是" // no
drop help_after_birth_1-help_after_birth_6

gen plan_help_after_birth = 1 if plan_help_after_birth_1 == "是" // nanny
replace plan_help_after_birth = 2 if plan_help_after_birth_2 == "是" // my mother
replace plan_help_after_birth = 3 if plan_help_after_birth_3 == "是" // my partner's mother
replace plan_help_after_birth = 4 if plan_help_after_birth_4 == "是" // other familiy members
replace plan_help_after_birth = 5 if plan_help_after_birth_5 == "是" // no
drop plan_help_after_birth_1-plan_help_after_birth_5



/*************************************************
** FINAL CLEANUP & SAVE                         **
**************************************************/

/* -- Drop Unneeded Variables -- */
drop g0*
drop text* r723q0 r835q0 r79q0 r311q0 tpreport* suggestion triplepreminder ///
ending interviewtime grouptime* rand* *time lastname email attribute_1 attribute_2 ///
attribute_3 survey_id
drop id submitdate lastpage startdate datestamp startlanguage seed token ipaddr refurl 
drop close_to_parents_other
drop attentioncheck attentionreport
drop *_other

gen hospital_id = substr(attribute_11, 4, 6) if strlen(attribute_11) > 6
replace hospital_id = attribute_11 if hospital_id == ""
drop attribute_*

/* -- Save Final Dataset -- */
save "$proc/1m.dta", replace








* ///////////////////////////////////////////////////////////////////////////////////////// *
* ////                                4. MERGE DATASET                                 //// *
* ///////////////////////////////////////////////////////////////////////////////////////// * 

use "$proc/contact_list.dta", clear


    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update each week
    keep if date <= date("2025-04-29", "YMD")
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */

    gen treatment = "C" if 组别 == "1"
    replace treatment = "T1" if 组别 == "2"
    replace treatment = "T2" if 组别 == "3"

    gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6

    keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment hospital_id
    tempfile complete
    save `complete'

    keep 母亲姓名 母亲电话 treatment hospital_id
    rename (母亲姓名 母亲电话)(lastname firstname)
    gen mother = 1
    tempfile mother
    save `mother'

    use `complete'
    keep 父亲姓名 父亲电话 treatment hospital_id
    rename (父亲姓名 父亲电话)(lastname firstname)
    gen mother = 0
    tempfile father
    save `father'

    append using `mother'
    order firstname lastname

    tempfile participants
    save `participants'


    merge 1:m firstname using "$proc/1m_results.dta"

    drop if _merge == 2
    gen response_1m = (_merge == 3)
    drop _merge
    drop if missing(firstname)


keep firstname treatment hospital_id mother response_1m

merge m:1 hospital_id using "$proc/enumerator_survey.dta"
keep if _merge == 3
drop _merge

merge m:1 hospital_id mother using "$proc/baseline.dta"
keep if _merge == 3
drop _merge

encode treatment, gen(treatment_temp)
drop treatment
rename treatment_temp treatment


** construct the index
local var exp_father_involv attitude extra_time_belief
foreach var in `var'{
    su `var' if treatment == 1
    scalar control_mean = r(mean)
    scalar control_sd = r(sd)
    gen `var'_z = (`var' - control_mean) / control_sd
    drop `var'
}

drop date cutoff_date

gen response_father_temp = (response_1m == 1 & mother == 0)
bys hospital_id (mother): egen response_father = max(response_father_temp)
drop response_father_temp
drop response_1m

keep hospital_id mother bed_in_room_site environment_recruitment engagement_father engagement_mother ///
willingness_both relationship_quality mother_dominance vip enumerator_id ability_father ability_mother ///
baby_female father_identity_importance communication_quality employment_security social_desirability_score ///
treatment exp_father_involv_z attitude_z extra_time_belief_z response_father
rename engagement_father f_engagement
rename engagement_mother m_engagement
local varlist  ///
ability_father ability_mother ///
father_identity_importance communication_quality employment_security social_desirability_score ///
exp_father_involv_z attitude_z extra_time_belief_z
foreach var in `varlist'{
    gen m_`var' =  `var' if mother == 1
    gen f_`var' = `var' if mother == 0
}
preserve
keep if mother == 1
keep hospital_id response_father treatment m_* bed_in_room_site environment_recruitment willingness_both relationship_quality  mother_dominance vip enumerator_id baby_female
tempfile mother
save `mother'
restore

keep if mother == 0
keep hospital_id response_father treatment f_* bed_in_room_site environment_recruitment willingness_both relationship_quality  mother_dominance vip enumerator_id baby_female
merge 1:1 hospital_id using `mother'
drop if _merge == 2
drop _merge



order hospital_id response_father bed_in_room_site environment_recruitment willingness_both relationship_quality  mother_dominance vip enumerator_id baby_female f_* m_*

export excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/Attrition Analysis/cate_analysis/cate.xlsx", firstrow(variables) replace





************************ log close ************************
log close
