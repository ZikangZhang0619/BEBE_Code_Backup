********************************************************************************
* TITLE: Data Cleaning for BASELINE SURVEY, Since Formal Recruitment Sept24 2024
* Project: BEBE - Primary Outcomes
* Data: Baseline Survey
* Author: Haoyue Wu
* Last updated: Nov19 2025
********************************************************************************

/*  (Survey id): 
		414279
		423721
		659129
		793221
		872571
		968746

*/

        /*
        This file is to clean the data from the baseline survey 
        INPUT: csv files from the baseline survey
        OUTPUT: $proc/BL_`date'
        */




*********
** LOG **
// *********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 02_BL_clean
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd

*************************
** READ & EXPLORE DATA **
*************************


import delimited using "$data/BL/results-survey414279.csv", bindquote(strict) encoding("utf-8") clear
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
	
	rename g05q03sq001 citzen_id

tempfile bl_2
save `bl_2'


import delimited using "$data/BL/results-survey872571.csv", bindquote(strict) encoding("utf-8") clear
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

	
	rename g05q03sq001 citzen_id
tempfile bl_3
save `bl_3'

import delimited using "$data/BL/results-survey793221.csv", bindquote(strict) encoding("utf-8") clear
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
	
	rename g05q03sq001 citzen_id

tempfile bl_4
save `bl_4'

import delimited using "$data/BL/results-survey968746.csv", bindquote(strict) encoding("utf-8") clear
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
	rename g05q03sq001 citzen_id


tempfile bl_5
save `bl_5'

import delimited using "$data/BL/results-survey423721.csv", bindquote(strict) encoding("utf-8") clear
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


	import delimited using "$data/BL/results-survey659129.csv", bindquote(strict) encoding("utf-8") clear
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
rename g03q01 father_involv_diaper
rename g03q02 father_involv_night
rename g03q03 father_involv_play
rename g03q04 father_involv_lull
rename g03q05sq001 father_time_chores



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


local var father_involv_diaper father_involv_night father_involv_play father_involv_lull
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

/* 
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

 */



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



replace father_time_chores = "10" if father_time_chores == "10+"
destring father_time_chores, replace force

gen social_desirability_score = social_desirability_scale1 + social_desirability_scale2 + social_desirability_scale3 + social_desirability_scale4 + social_desirability_scale5
drop social_desirability_scale1 social_desirability_scale2 social_desirability_scale3 social_desirability_scale4 social_desirability_scale5

drop g04q08other
drop father_name phone_num alipay_account alipay_account_other feedback interviewtime 
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


drop belief_father_15_walk belief_father_15_word belief_father_45_walk ///
belief_father_45_word belief_mother_15_walk belief_mother_15_word belief_mother_45_walk belief_mother_45_word
/* drop certainty_* */
drop father_time_chores
/* drop if extra_time_father_wellbeing == . */
drop tag



save "$proc/BL_`date'.dta",replace

