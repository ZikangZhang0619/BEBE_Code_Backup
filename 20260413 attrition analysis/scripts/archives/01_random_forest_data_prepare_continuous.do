** Attrition Analysis - Prepare Baseline Characteristics **

** random forest **

** Author: Haoyue Wu
** Updated on: Jan 7, 2025

** IMPORT: 
/*
1M: 644261 137936 839976 659371 767445 826686
Baseline: 872571 968746 793221 414279
enumerator: 593646 175343 464493 241113 241204
*/

** NOTES:
* variables are non-binary

*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 01_dataprep
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd



*************************
** READ & EXPLORE DATA **
*************************
// extract desired variable
**# enumerator survey
** Enumerator’s reports at recruitment (willingness to participate, engagement, relationship quality)
** enumerator 593646 175343 464493 241113 241204

import delimited "$data/results-survey593646.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 checkenumerator g11q01 g11q02 g12q03 g12q06 g12q04sq001
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 g11q01 g11q02 g12q03 g12q06 g12q04sq001)(enumerator randdate ward bed momname hospitalID eligible willingness  group engagement_father engagement_mother environment_recruitment num_other_family relationship_quality)
tostring relationship_quality, replace
gen survey_id = 1
tempfile 1
save `1'

import delimited "$data/results-survey464493.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 checkenumerator g11q01 g11q02 g12q03 g12q06 g12q04sq001
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 g11q01 g11q02 g12q03 g12q06 g12q04sq001)(enumerator randdate ward bed momname hospitalID eligible willingness  group engagement_father engagement_mother environment_recruitment num_other_family relationship_quality)
tostring relationship_quality, replace
tostring num_other_family, replace
gen survey_id = 3
tempfile 2
save `2'

import delimited "$data/results-survey175343_new.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 checkenumerator g11q01 g11q02 g12q03 g12q06 g12q04sq001
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 g11q01 g11q02 g12q03 g12q06 g12q04sq001)(enumerator randdate ward bed momname hospitalID eligible willingness  group engagement_father engagement_mother environment_recruitment num_other_family relationship_quality)
gen survey_id = 2
tostring relationship_quality, replace
tostring num_other_family, replace
tempfile 3
save `3'

import delimited "$data/results-survey241113.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 checkenumerator g11q01 g11q02 g12q03 g12q06 g12q04sq001
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 g11q01 g11q02 g12q03 g12q06 g12q04sq001)(enumerator randdate ward bed momname hospitalID eligible willingness  group engagement_father engagement_mother environment_recruitment num_other_family relationship_quality)
tostring relationship_quality, replace
tostring num_other_family, replace
gen survey_id = 4
tempfile 4
save `4'

import delimited "$data/results-survey241204.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 checkenumerator g11q01 g11q02 g12q03 g12q06 g12q04 g012q97 g13q98 g01q99
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g04q02 g01q08 g11q01 g11q02 g12q03 g12q06 g12q04 g012q97 g13q98 g01q99)(enumerator randdate ward bed momname hospitalID eligible willingness group engagement_father engagement_mother environment_recruitment num_other_family relationship_quality dominance childcare_will_f childcare_will_m)
replace hospitalID = 340632 if hospitalID == 340362
tostring num_other_family, replace
gen survey_id = 5


append using `1'
append using `2'
append using `3'
append using `4'

//---------- clean ----------- 
drop if submitdate == ""

gen submitdatetime = clock(submitdate, "YMDhms") if survey_id ~= 2
gen date_temp = startdate if survey_id == 2 

gen double date_part = date(substr(date_temp, 1, 8), "MD20Y")
gen double hour_part = real(substr(date_temp, 9, strpos(date_temp, ":") - 9))
gen double minute_part = real(substr(date_temp, strpos(date_temp, ":") + 1, 2))

gen double datetime_combined = dhms(date_part, hour_part, minute_part, 0)
replace submitdatetime = datetime_combined if survey_id == 2
format submitdatetime %tc
drop date_temp date_part hour_part minute_part datetime_combined submitdate startdate

*randdate

gen randdate_temp = date(randdate, "YMDhms") if survey_id ~= 2
replace randdate_temp = date(substr(randdate, 1, 8), "MD20Y") if survey_id == 2
format randdate_temp %td
drop randdate
rename randdate_temp randdate
// replace date_temp = "10/11/24 15:43" in 1979

// replace enumerator = "Maggie" if enumerator == "Vivi" & randdate < date("2024-12-30", "YMD")
// replace checkenumerator = "Maggie" if checkenumerator == "Vivi" & randdate < date("2024-12-30", "YMD")

** hospitalID
tostring hospitalID, replace
drop if hospitalID == "." | hospitalID == "123456" | hospitalID == "777777" | hospitalID == "888888" | hospitalID == "111111" | momname == "测试" | hospitalID == "0"
replace hospitalID = "0" + hospitalID if strlen(hospitalID) == 5
replace hospitalID = "00" + hospitalID if strlen(hospitalID) == 4
count if strlen(hospitalID) < 6

** enumerator
replace checkenumerator = "" if checkenumerator == "0"
// replace checkenumerator = enumerator if checkenumerator == ""

** group
gen treatment = "T0" if strpos(group, "T0")>0
replace treatment = "T1" if strpos(group, "T1")>0
replace treatment = "T2" if strpos(group, "T2")>0
drop group

** duplicates
sort hospitalID submitdatetime
by hospitalID : gen id = _n
duplicates tag hospitalID, gen (dup_id)
forvalues i = 1/9 {
    forvalues j = 1/`i' {
        drop if dup_id == `i' & id == `j'
    }
}
drop id dup_id
drop if hospitalID == "."
duplicates report hospitalID

keep if treatment ~= ""

replace enumerator = "Maggie" if enumerator == "Vivi" & randdate <= date("2024-12-31", "YMD")
replace checkenumerator = "Maggie" if checkenumerator == "Vivi" & randdate <= date("2024-12-31", "YMD")


// ------------------ cluster error ----------------------
// week_num
gen cutoff_date = date("24/09/2024", "DMY")
gen week_num = floor((randdate - cutoff_date) / 7) 

// vip
gen vip = 0
replace vip = 1 if strlen(ward) == 3

// triple room
rename bed room_num
gen bed_in_room = 2
replace bed_in_room = 1 if strlen(ward) == 3
replace bed_in_room = 3 if (ward == "4A" & room_num < 39)
replace bed_in_room = 3 if (ward == "5A" & room_num < 38)
replace bed_in_room = 3 if (ward == "5B" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "5B" & room_num < 50 & room_num > 46)
replace bed_in_room = 3 if (ward == "6A" & room_num < 38)
replace bed_in_room = 3 if (ward == "6B" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "6B" & room_num < 50 & room_num > 46)
replace bed_in_room = 3 if (ward == "7A" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "7B" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "7B" & room_num > 46)

//cluster var
gen ward_num = substr(ward,1,1) if vip == 0
destring ward_num, replace force
gen cluster_var = ward_num*1000+ room_num * 100 + week_num if vip == 0
destring hospitalID, gen(hospital_id)
replace cluster_var = hospital_id if vip == 1

replace enumerator = checkenumerator if enumerator != checkenumerator & checkenumerator != ""  & checkenumerator != "." 

// fixed effect
encode enumerator, gen(enumerator_num)
drop hospital_id

save "$proc/enumerator_characteristics.dta", replace


**# Baseline: 872571 793221 414279
/*
1. Baby gender
2.	Beliefs about father/mother quality time investments (and certainty about beliefs)
3.	Own and partner’s ability to improve child’s development compared to other parents
4.	Expectations about father involvement (diaper, night, play, lull)
5.	Father reported time spent on household chores per week when back to work
6.	Father norms 
7.	Father identity
8.	Couple communication quality
9.	Father’s employment security 

*/
import delimited using "$data/results-survey414279.csv", bindquote(strict) encoding("utf-8") clear
drop if submitdate == ""
gen date = date(submitdate, "YMDhms")
format date %td

gen cutoff_date = date("24/09/2024", "DMY")
format cutoff_date %td
drop if date < cutoff_date
drop cutoff_date

rename g01q01sq001 hospitalID

keep submitdate hospitalID g01q03 g01q04 randgrouporder randinvestmentorder g02q01asq001 g02q01asq002 g02q01bsq001 g02q01bsq002 g02q02 g02q03a g02q03b g02q04asq001 g02q04asq002 g02q04bsq001 g02q04bsq002 g02q05 g02q06a g02q06b g03q01 g03q02 g03q03 g03q04 g03q05sq001 g04q01 g04q02 g04q03 g04q04 g04q05 g01q42 g01q43 g09q44 g01q45 g01q46 g01q42-g01q46

rename g01q03 mother
rename g01q04 baby_female
rename g03q01 father_involv_diaper
rename g03q02 father_involvs_night
rename g03q03 father_involv_play
rename g03q04 father_involv_lull
rename g03q05sq001 father_time_household_chores
rename g04q01 attitude_work
rename g04q02 attitude_emotion
rename g04q03 attitude_importance
rename g04q04 communication_quality
rename g04q05 employment_security
rename g01q42 social_desirability_scale1
rename g01q43 social_desirability_scale2
rename g09q44 social_desirability_scale3
rename g01q45 social_desirability_scale4
rename g01q46 social_desirability_scale5

tempfile BL1
save `BL1'


import delimited using "$data/results-survey872571.csv", bindquote(strict) encoding("utf-8") clear
drop if submitdate == ""
gen date = date(submitdate, "YMDhms")
format date %td

gen cutoff_date = date("24/09/2024", "DMY")
format cutoff_date %td
drop if date < cutoff_date
drop cutoff_date
drop if g05q01 == "测试"

rename g01q01sq001 hospitalID

keep submitdate hospitalID g01q03 g01q04 randgrouporder randinvestmentorder g02q01asq001 g02q01asq002 g02q01bsq001 g02q01bsq002 g02q02 g02q03a g02q03b g03q01 g03q02 g03q03 g03q04 g03q05sq001 g04q01 g04q02 g04q03 g04q04 g04q05 g01q42 g01q43 g09q44 g01q45 g01q46 

rename g01q03 mother
rename g01q04 baby_female
rename g03q01 father_involv_diaper
rename g03q02 father_involvs_night
rename g03q03 father_involv_play
rename g03q04 father_involv_lull
rename g03q05sq001 father_time_household_chores
rename g04q01 attitude_work
rename g04q02 attitude_emotion
rename g04q03 attitude_importance
rename g04q04 communication_quality
rename g04q05 employment_security
rename g01q42 social_desirability_scale1
rename g01q43 social_desirability_scale2
rename g09q44 social_desirability_scale3
rename g01q45 social_desirability_scale4
rename g01q46 social_desirability_scale5

tempfile BL2
save `BL2'

import delimited using "$data/results-survey793221.csv", bindquote(strict) encoding("utf-8") clear
drop if submitdate == ""
gen date = date(submitdate, "YMDhms")
format date %td

gen cutoff_date = date("24/09/2024", "DMY")
format cutoff_date %td
drop if date < cutoff_date
drop cutoff_date
drop if g05q01 == "测试"

rename g01q01sq001 hospitalID

keep submitdate hospitalID g01q03 g01q04 randgrouporder randinvestmentorder g02q01asq001 g02q01asq002 g02q01bsq001 g02q01bsq002 g02q02 g02q03a g02q03b g03q01 g03q02 g03q03 g03q04 g03q05sq001 g04q01 g04q02 g04q03 g04q04 g04q05 g04q06 g04q07 g04q08 g01q42 g01q43 g09q44 g01q45 g01q46 

rename g01q03 mother
rename g01q04 baby_female
rename g03q01 father_involv_diaper
rename g03q02 father_involvs_night
rename g03q03 father_involv_play
rename g03q04 father_involv_lull
rename g03q05sq001 father_time_household_chores
rename g04q01 attitude_work
rename g04q02 attitude_emotion
rename g04q03 attitude_mom_knows
rename g04q04 attitude_women_fulltime
rename g04q05 attitude_income_share
rename g04q06 attitude_importance
rename g04q07 communication_quality
rename g04q08 employment_security
rename g01q42 social_desirability_scale1
rename g01q43 social_desirability_scale2
rename g09q44 social_desirability_scale3
rename g01q45 social_desirability_scale4
rename g01q46 social_desirability_scale5

append using `BL1'
append using `BL2'




gen baby_female_temp = 0
replace baby_female_temp = 1 if baby_female == "女宝宝"

drop baby_female
rename baby_female_temp baby_female

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
	
drop g02q01asq001 g02q01asq002 g02q01bsq001 g02q01bsq002 g02q02 g02q03a g02q03b g02q04asq001 g02q04asq002 g02q04bsq001 g02q04bsq002 g02q05 g02q06a g02q06b

** hospitalID
tostring hospitalID, replace
drop if hospitalID == "." | hospitalID == "123456" | hospitalID == "777777" | hospitalID == "888888" | hospitalID == "111111" 
replace hospitalID = "0" + hospitalID if strlen(hospitalID) == 5
replace hospitalID = "00" + hospitalID if strlen(hospitalID) == 4
count if strlen(hospitalID) < 6

save "$proc/BL_characteristics.dta", replace

merge m:1 hospitalID using "$proc/enumerator_characteristics.dta"
keep if _merge == 3
drop _merge
drop lastpage checkenumerator room_num momname eligible submitdatetime randdate survey_id cutoff_date 


// ---------------- assign value ------------------
gen mother_temp = (mother == "妈妈")
drop mother
rename mother_temp mother


local var father_involv_diaper father_involvs_night father_involv_play father_involv_lull
// 1 if father do more
foreach i in `var'{
    gen `i'_temp = .
	replace `i' = subinstr(`i', `"""', "", .)
	replace `i'_temp = 1 if `i' == "主要{if(G01Q03==AO01, 我,我的伴侣)}负责"
	replace `i'_temp = 3 if `i' == "主要{if(G01Q03==AO01, 我的伴侣,我)}负责"
	replace `i'_temp = 2 if `i' == "我们一起做，分担的差不多"
	drop `i'
	rename `i'_temp `i'
}
// gen father_involvement = (father_involv_diaper + father_involv_lull + father_involv_play + father_involvs_night) > 2
// drop father_involv_diaper father_involvs_night father_involv_play father_involv_lull

// 1 means attitude towards non-equality
local var attitude_work attitude_emotion attitude_mom_knows attitude_women_fulltime  attitude_income_share 
foreach i in `var'{
    gen `i'_temp = .
	replace `i'_temp = 5 if `i' == "非常不同意"
	replace `i'_temp = 4 if `i' == "不同意"
	replace `i'_temp = 3 if `i' == "中立"
	replace `i'_temp = 2 if `i' == "同意"
	replace `i'_temp = 1 if `i' == "非常同意"

	drop `i'
	rename `i'_temp `i'
}

local var attitude_importance
foreach i in `var'{
    gen `i'_temp = .
	replace `i'_temp = 1 if `i' == "非常不同意"
	replace `i'_temp = 2 if `i' == "不同意"
	replace `i'_temp = 3 if `i' == "中立"
	replace `i'_temp = 4 if `i' == "同意"
	replace `i'_temp = 5 if `i' == "非常同意"

	drop `i'
	rename `i'_temp `i'
}

// gen attitude = attitude_work + attitude_emotion + attitude_mom_knows + attitude_women_fulltime + attitude_income_share + attitude_importance >= 3 if attitude_income_share ~= .
// replace attitude = 1 if attitude_work + attitude_emotion + attitude_importance > 1 &attitude_income_share == .
// replace attitude = 0 if attitude == .
// drop attitude_work attitude_emotion attitude_mom_knows attitude_women_fulltime  attitude_income_share attitude_importance

local var communication_quality

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

foreach i in `var'{
    gen `i'_temp = .
	replace `i' = subinstr(`i', `"""', "", .)
	replace `i'_temp = 4 if `i' == "{if(G01Q03=='AO01',我,他)}会有一份稳定的全职工作，但收入或其他待遇可能会变差一些。"
	replace `i'_temp = 5 if `i' == "{if(G01Q03=='AO01',我,他)}会有一份稳定的全职工作，而且收入或其他待遇可能会与现在差不多。"
	replace `i'_temp = 6 if `i' == "{if(G01Q03=='AO01',我,他)}会有一份稳定的全职工作，而且收入或其他待遇可能会变得更好。"
	replace `i'_temp = 2 if `i' == "{if(G01Q03=='AO01',我,他)}有较大的可能会失去工作。"
	replace `i'_temp = 3 if `i' == "{if(G01Q03=='AO01',我,他)}有较小的可能会失去工作。"
	replace `i'_temp = 1 if `i' == "{if(G01Q03=='AO01',我,他)}未来一年不会工作，因为{if(G01Q03=='AO01',我,他)}还在学习或接受培训。"
	replace `i'_temp = 1 if `i' == "{if(G01Q03=='AO01',我,他)}目前没有工作，但正在寻找新工作。"
	replace `i'_temp = 0 if `i' == "其它"
	
	drop `i'
	rename `i'_temp `i'
}

// environment
gen temp = .
replace temp = 1 if environment_recruitment == "不断地被其他人或事打扰"
replace temp = 2 if environment_recruitment == "整体是安静的，但偶尔被其他人或事打扰"
replace temp = 3 if environment_recruitment == "安静的，不被打扰的"
drop environment_recruitment
rename temp environment_recruitment

// engagement
local var engagement_father engagement_mother childcare_will_f childcare_will_m

foreach i in `var'{
	gen `i'_temp = .
	replace `i'_temp = 1 if `i' == "参与度非常低" | `i' == "很低"
	replace `i'_temp = 2 if `i' == "参与度较低" | `i' == "比较低"
	replace `i'_temp = 3 if `i' == "有点低"
	replace `i'_temp = 3.5 if `i' == "参与度一般"
	replace `i'_temp = 4 if `i' == "有点高"
	replace `i'_temp = 5 if `i' == "参与度较高" | `i' == "比较高"
	replace `i'_temp = 6 if `i' == "参与度非常高" | `i' == "很高"
	drop `i'
	rename `i'_temp `i'
}

// willingness
gen willingness_temp = .
replace willingness_temp = 1 if willingness == "双方意愿一般"
replace willingness_temp = 2 if willingness == "妈妈意愿较高，爸爸一般" | willingness == "爸爸意愿较高，妈妈一般"
replace willingness_temp = 3 if willingness == "双方都非常愿意"
drop willingness
rename willingness_temp willingness

// dominance
gen dominance_temp = .
replace dominance_temp = 1 if dominance == "父亲明显主导"
replace dominance_temp = 2 if dominance == "父亲稍微主导"
replace dominance_temp = 3 if dominance == "看不出来"
replace dominance_temp = 4 if dominance == "母亲稍微主导"
replace dominance_temp = 5 if dominance == "母亲明显主导"
replace dominance_temp = . if dominance == ""
drop dominance
rename dominance_temp dominance

// relationship quality
// gen relationship_quality_temp = ""
replace relationship_quality = "5" if relationship_quality == "比较疏远"
replace relationship_quality = "6" if relationship_quality == "一般，不近不远"
replace relationship_quality = "8" if relationship_quality == "比较亲近"
replace relationship_quality = "10" if relationship_quality == "很亲近"
destring relationship_quality, replace
// drop relationship_quality
// rename relationship_quality_temp relationship_quality

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

gen social_desirability_scale_score = social_desirability_scale1+ social_desirability_scale2+social_desirability_scale3+social_desirability_scale4+social_desirability_scale5
drop social_desirability_scale1 social_desirability_scale3 social_desirability_scale4 social_desirability_scale2 social_desirability_scale5

// belief 
gen belief_father_walk = belief_father_45_walk - belief_father_15_walk 
gen belief_father_word = belief_father_45_word - belief_father_15_word 
// gen belief_father = (belief_father_walk + belief_father_word > 1) 
gen belief_mother_walk = belief_mother_45_walk - belief_mother_15_walk 
gen belief_mother_word = belief_mother_45_word - belief_mother_15_word 
// gen belief_mother = (belief_mother_walk + belief_mother_walk > 1)
drop belief_father_45_walk belief_father_15_walk belief_mother_45_walk belief_mother_15_walk belief_father_45_word belief_father_15_word belief_mother_45_word belief_mother_15_word 


// treatment
rename treatment treatment_str
encode treatment_str, gen(treatment)
drop treatment_str

// father time on household

// gen temp = (father_time_household_chores >= 5)
// replace temp = . if mother == 1
// drop father_time_household_chores
// rename temp father_time_household_chores
bysort hospitalID (mother): replace father_time_household_chores = father_time_household_chores[_n-1] if mother == 1



// merge variable
tostring mother, gen(mother_str)
gen merge_var = hospitalID + mother_str

bysort merge_var (submitdate) : gen id = _n
drop if id == 2
save "$proc/baseline_characteristics.dta", replace

************************
* merge with attrition *
************************
use "$proc/tempfile1m.dta", clear

merge 1:1 merge_var using "$proc/baseline_characteristics.dta"
keep if _merge == 3

drop mother_str id _merge num_other_family randgrouporder randinvestmentorder merge_var

order mother hospitalID

// some cleaning
// gen engagement = (engagement_mother == 1 & mother == 1) | (engagement_father == 1 & mother == 0)
// drop engagement_mother engagement_father

save "$proc/random_forest_before_analysis.dta", replace


*************
** WRAP UP **
*************
log close
exit
