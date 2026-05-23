// All sample
//1m
//1m
use "$proc/2m_20251208.dta", clear
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
duplicates drop hospital_id mother, force
foreach var of varlist * {
    rename `var' m2_`var'
}
rename (m2_hospital_id m2_mother) (hospital_id mother)

tempfile 2m
save `2m'

//--3m---//
use "$proc/3m_20251208.dta", clear
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
duplicates drop hospital_id mother, force
foreach var of varlist * {
    rename `var' m3_`var'
}
rename (m3_hospital_id m3_mother) (hospital_id mother)

tempfile 3m
save `3m'

//--6m---//
use "$proc/6m_20251208.dta", clear
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
duplicates drop hospital_id mother, force
foreach var of varlist * {
    rename `var' m6_`var'
}
rename (m6_hospital_id m6_mother) (hospital_id mother)

tempfile 6m
save `6m'

//--1m---//
use "$proc/1m_20251208.dta", clear
duplicates drop hospital_id mother, force
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
foreach var of varlist * {
    rename `var' m1_`var'
}
rename (m1_hospital_id m1_mother) (hospital_id mother)
drop if hospital_id == "D00347882"
// merge data
merge 1:1 hospital_id mother using `2m', nogen
merge 1:1 hospital_id mother using `3m', nogen
merge 1:1 hospital_id mother using `6m', nogen

replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
tempfile all
save `all'

use "$proc/clustered_data.dta", clear

keep enumerator_id hospital_id strata cluster_var
merge 1:m hospital_id using `all'
keep if _merge == 3
drop _merge

rename m1_group group
replace group = m2_group if missing(group) & !missing(m2_group)
replace group = m3_group if missing(group) & !missing(m3_group)
replace group = m6_group if missing(group) & !missing(m6_group)

gen C = (group == 0)
gen T1 = (group == 1)
gen T2 = (group == 2)
gen Treat = (T1 == 1 | T2 == 1)

save "$proc/primary_outcome.dta", replace

** ------------ Combined Mother and Father Analysis -------------- **
use "$proc/primary_outcome.dta", clear

// Define variable lists

local mother_vars ///
"m1_belief_score_z m2_belief_score_z m3_belief_score_z m6_belief_score_z m6_gender_attitude_score_z m2_father_work_priority m6_father_work_priority m1_father_time_less_valuable m3_father_time_less_valuable m6_father_time_less_valuable m2_father_identity_importance m6_father_identity_importance m1_father_involv_score_z m2_father_involv_score_z m6_father_involv_score_z m1_father_care_alone m2_father_care_alone m6_father_care_alone m1_EPDS_score_z m2_EPDS_score_z m3_EPDS_score_z m6_EPDS_score_z m1_partner_MH m2_partner_MH m3_partner_MH m6_partner_MH m2_gatekeeping_score_F_std m2_gatekeeping_score_M_std m1_relationship_satisfaction m3_relationship_satisfaction m6_relationship_satisfaction m1_own_close_baby m1_partner_close_baby m3_partner_close_baby m6_partner_close_baby m3_interaction_with_baby m6_interaction_with_baby m1_triple_p_correct_z m2_triple_p_correct_z m3_triple_p_correct_z m1_maternity_leave_taken m2_mental_load_household_task m2_partner_support_score_z m1_partner_very_supportive m6_partner_very_supportive m2_disagreement_partner m2_parent_identity_score_z m3_bonding_score_z m6_bonding_score_z m6_care_baby_total m3_self_efficacy_score_z m1_ability_father m2_ability_father m3_ability_father m6_ability_father m1_ability_mother m2_ability_mother m6_ability_mother m3_workdays_last_week m6_workdays_last_week m3_workhours_last_week m6_workhours_last_week m3_workhours_baby_6m m3_workhours_baby_12m m6_workhours_baby_12m m3_workhours_baby_24m m6_workhours_baby_24m m3_work_commute m3_maternity_leave_end m6_job_change_better m3_childcare_discussion m3_childcare_plan m3_partner_childcare_likelihood m3_father_1hr_care_alone m3_father_15mins_care_alone m3_temperament_score_z m1_sleep_quality m6_sleep_quality m6_avg_night_wake_up_duration m6_times_wake_up_night_baby m6_sleep_minutes m6_nights_away_from_baby m2_WTP_value m6_WTP_value m6_child_plan_respondent m6_child_plan_partner m6_child_plan_5yrs_likelihood m6_baby_health_condition m6_baby_growth_development"

local father_vars ///
"m1_belief_score_z m2_belief_score_z m3_belief_score_z m6_belief_score_z m6_gender_attitude_score_z m2_father_work_priority m6_father_work_priority m1_father_time_less_valuable m3_father_time_less_valuable m6_father_time_less_valuable m2_father_identity_importance m6_father_identity_importance m1_father_involv_score_z m2_father_involv_score_z m6_father_involv_score_z m1_father_care_alone m2_father_care_alone m6_father_care_alone m1_EPDS_score_z m2_EPDS_score_z m3_EPDS_score_z m6_EPDS_score_z m1_partner_MH m2_partner_MH m3_partner_MH m6_partner_MH m2_gatekeeping_score_F_std m2_gatekeeping_score_M_std m1_relationship_satisfaction m3_relationship_satisfaction m6_relationship_satisfaction m1_own_close_baby m1_partner_close_baby m3_partner_close_baby m6_partner_close_baby m3_interaction_with_baby m6_interaction_with_baby m1_triple_p_correct_z m2_triple_p_correct_z m3_triple_p_correct_z m2_mental_load_balance m1_partner_very_supportive m6_partner_very_supportive m2_disagreement_partner m2_parent_identity_score_z m3_bonding_score_z m6_bonding_score_z m3_care_baby_total m6_care_baby_total m3_self_efficacy_score_z m1_ability_father m2_ability_father m3_ability_father m6_ability_father m1_ability_mother m2_ability_mother m6_ability_mother m3_workdays_last_week m6_workdays_last_week m3_workhours_last_week m6_workhours_last_week m3_workhours_baby_6m m3_workhours_baby_12m m6_workhours_baby_12m m3_workhours_baby_24m m6_workhours_baby_24m m3_work_commute  m6_job_change_better m3_childcare_discussion m3_childcare_plan m3_partner_childcare_likelihood m3_father_1hr_care_alone m3_father_15mins_care_alone m3_temperament_score_z m1_sleep_quality m6_sleep_quality m6_avg_night_wake_up_duration m6_times_wake_up_night_baby m6_sleep_minutes m6_nights_away_from_baby m1_father_time_less_valuable m3_father_time_less_valuable m6_father_time_less_valuable m2_WTP_value m6_WTP_value m6_child_plan_respondent m6_child_plan_partner m6_child_plan_5yrs_likelihood m6_baby_health_condition m6_baby_growth_development"


// Get unique variable list
local all_vars: list mother_vars | father_vars
local all_vars: list uniq all_vars

// Open output file
capture file close resultsfile
file open resultsfile using "$results/tables/primary_table_20251206.tex", write replace

// Loop through each unique variable
local row = 0
foreach var of local all_vars {
    
    // Check if variable exists for mother
    local mother_exists: list posof "`var'" in mother_vars
    
    // Check if variable exists for father
    local father_exists: list posof "`var'" in father_vars
    
    // Initialize strings for mother
    if `mother_exists' > 0 {
        // Mother analysis
        preserve
        keep if mother == 1
        
        // Mean and SD for Control (C)
        qui su `var' if C == 1
        if r(N) > 0 {
            local m_mean_c: di %6.3f r(mean)
            local m_sd_c: di %6.3f r(sd)
            local m_sd_c = trim("`m_sd_c'")
        }
        else {
            local m_mean_c "-"
            local m_sd_c "-"
        }
        
        // Regression for T1 vs Control (C)
        drop if T2 == 1
        capture reg `var' T1 i.strata i.enumerator_id, robust cluster(cluster_var)
        if _rc == 0 {
            local m_diff_t1c: di %6.3f _b[T1]
            local m_se_t1c: di %6.3f _se[T1]
            local m_se_t1c = trim("`m_se_t1c'")
            
            local pval = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
            local m_star_t1c ""
            if (`pval' < 0.1) local m_star_t1c "*"
            if (`pval' < 0.05) local m_star_t1c "**"
            if (`pval' < 0.01) local m_star_t1c "***"
        }
        else {
            local m_diff_t1c "-"
            local m_se_t1c "-"
            local m_star_t1c ""
        }
        restore
        
        // Regression for T2 vs Control (C)
        preserve
        keep if mother == 1
        drop if T1 == 1
        capture reg `var' T2 i.strata i.enumerator_id, robust cluster(cluster_var)
        if _rc == 0 {
            local m_diff_t2c: di %6.3f _b[T2]
            local m_se_t2c: di %6.3f _se[T2]
            local m_se_t2c = trim("`m_se_t2c'")
            
            local pval = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
            local m_star_t2c ""
            if (`pval' < 0.1) local m_star_t2c "*"
            if (`pval' < 0.05) local m_star_t2c "**"
            if (`pval' < 0.01) local m_star_t2c "***"
        }
        else {
            local m_diff_t2c "-"
            local m_se_t2c "-"
            local m_star_t2c ""
        }
        restore
    }
    else {
        local m_mean_c "-"
        local m_sd_c "-"
        local m_diff_t1c "-"
        local m_se_t1c "-"
        local m_star_t1c ""
        local m_diff_t2c "-"
        local m_se_t2c "-"
        local m_star_t2c ""
    }
    
    // Initialize strings for father
    if `father_exists' > 0 {
        // Father analysis
        preserve
        keep if mother == 0
        
        // Mean and SD for Control (C)
        qui su `var' if C == 1
        if r(N) > 0 {
            local f_mean_c: di %6.3f r(mean)
            local f_sd_c: di %6.3f r(sd)
            local f_sd_c = trim("`f_sd_c'")
        }
        else {
            local f_mean_c "-"
            local f_sd_c "-"
        }
        
        // Regression for T1 vs Control (C)
        drop if T2 == 1
        capture reg `var' T1 i.strata i.enumerator_id, robust cluster(cluster_var)
        if _rc == 0 {
            local f_diff_t1c: di %6.3f _b[T1]
            local f_se_t1c: di %6.3f _se[T1]
            local f_se_t1c = trim("`f_se_t1c'")
            
            local pval = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
            local f_star_t1c ""
            if (`pval' < 0.1) local f_star_t1c "*"
            if (`pval' < 0.05) local f_star_t1c "**"
            if (`pval' < 0.01) local f_star_t1c "***"
        }
        else {
            local f_diff_t1c "-"
            local f_se_t1c "-"
            local f_star_t1c ""
        }
        restore
        
        // Regression for T2 vs Control (C)
        preserve
        keep if mother == 0
        drop if T1 == 1
        capture reg `var' T2 i.strata i.enumerator_id, robust cluster(cluster_var)
        if _rc == 0 {
            local f_diff_t2c: di %6.3f _b[T2]
            local f_se_t2c: di %6.3f _se[T2]
            local f_se_t2c = trim("`f_se_t2c'")
            
            local pval = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
            local f_star_t2c ""
            if (`pval' < 0.1) local f_star_t2c "*"
            if (`pval' < 0.05) local f_star_t2c "**"
            if (`pval' < 0.01) local f_star_t2c "***"
        }
        else {
            local f_diff_t2c "-"
            local f_se_t2c "-"
            local f_star_t2c ""
        }
        restore
    }
    else {
        local f_mean_c "-"
        local f_sd_c "-"
        local f_diff_t1c "-"
        local f_se_t1c "-"
        local f_star_t1c ""
        local f_diff_t2c "-"
        local f_se_t2c "-"
        local f_star_t2c ""
    }
    
    // Write results to file - Line 1: Variable name and means
    file write resultsfile "\textbf{`var'} & `m_mean_c' & `m_diff_t1c'`m_star_t1c' & `m_diff_t2c'`m_star_t2c' & `f_mean_c' & `f_diff_t1c'`f_star_t1c' & `f_diff_t2c'`f_star_t2c' \\" _n
    
    // Write results to file - Line 2: SDs and SEs
    file write resultsfile " & (`m_sd_c') & (`m_se_t1c') & (`m_se_t2c') & (`f_sd_c') & (`f_se_t1c') & (`f_se_t2c') \\" _n
}

file close resultsfile



// SAMPLE after 2m onsite change
//1m
//1m
use "$proc/2m_20251208.dta", clear
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
duplicates drop hospital_id mother, force
foreach var of varlist * {
    rename `var' m2_`var'
}
rename (m2_hospital_id m2_mother) (hospital_id mother)

tempfile 2m
save `2m'

//--3m---//
use "$proc/3m_20251208.dta", clear
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
duplicates drop hospital_id mother, force
foreach var of varlist * {
    rename `var' m3_`var'
}
rename (m3_hospital_id m3_mother) (hospital_id mother)

tempfile 3m
save `3m'

//--6m---//
use "$proc/6m_20251208.dta", clear
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
duplicates drop hospital_id mother, force
foreach var of varlist * {
    rename `var' m6_`var'
}
rename (m6_hospital_id m6_mother) (hospital_id mother)

tempfile 6m
save `6m'

//--1m---//
use "$proc/1m_20251208.dta", clear
duplicates drop hospital_id mother, force
replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
foreach var of varlist * {
    rename `var' m1_`var'
}
rename (m1_hospital_id m1_mother) (hospital_id mother)
drop if hospital_id == "D00347882"
// merge data
merge 1:1 hospital_id mother using `2m', nogen
merge 1:1 hospital_id mother using `3m', nogen
merge 1:1 hospital_id mother using `6m', nogen

replace hospital_id = substr(hospital_id, 4, .) if strlen(hospital_id) > 6
tempfile all
save `all'

use "$proc/clustered_data.dta", clear
keep if onsite_date == 1
keep enumerator_id hospital_id strata cluster_var
merge 1:m hospital_id using `all'
keep if _merge == 3
drop _merge

rename m1_group group
replace group = m2_group if missing(group) & !missing(m2_group)
replace group = m3_group if missing(group) & !missing(m3_group)
replace group = m6_group if missing(group) & !missing(m6_group)

gen C = (group == 0)
gen T1 = (group == 1)
drop if group == 2

save "$proc/primary_outcome_2monsite.dta", replace

** ------------ Combined Mother and Father Analysis -------------- **
use "$proc/primary_outcome_2monsite.dta", clear

// Define variable lists


local mother_vars ///
"m1_belief_score_z m2_belief_score_z m3_belief_score_z m6_belief_score_z m6_gender_attitude_score_z m2_father_work_priority m6_father_work_priority m1_father_time_less_valuable m3_father_time_less_valuable m6_father_time_less_valuable m2_father_identity_importance m6_father_identity_importance m1_father_involv_score_z m2_father_involv_score_z m6_father_involv_score_z m1_father_care_alone m2_father_care_alone m6_father_care_alone m1_EPDS_score_z m2_EPDS_score_z m3_EPDS_score_z m6_EPDS_score_z m1_partner_MH m2_partner_MH m3_partner_MH m6_partner_MH m2_gatekeeping_score_F_std m2_gatekeeping_score_M_std m1_relationship_satisfaction m3_relationship_satisfaction m6_relationship_satisfaction m1_own_close_baby m1_partner_close_baby m3_partner_close_baby m6_partner_close_baby m3_interaction_with_baby m6_interaction_with_baby m1_triple_p_correct_z m2_triple_p_correct_z m3_triple_p_correct_z m1_maternity_leave_taken m2_mental_load_household_task m2_partner_support_score_z m1_partner_very_supportive m6_partner_very_supportive m2_disagreement_partner m2_parent_identity_score_z m3_bonding_score_z m6_bonding_score_z m6_care_baby_total m3_self_efficacy_score_z m1_ability_father m2_ability_father m3_ability_father m6_ability_father m1_ability_mother m2_ability_mother m6_ability_mother m3_workdays_last_week m6_workdays_last_week m3_workhours_last_week m6_workhours_last_week m3_workhours_baby_6m m3_workhours_baby_12m m6_workhours_baby_12m m3_workhours_baby_24m m6_workhours_baby_24m m3_work_commute m3_maternity_leave_end m6_job_change_better m3_childcare_discussion m3_childcare_plan m3_partner_childcare_likelihood m3_father_1hr_care_alone m3_father_15mins_care_alone m3_temperament_score_z m1_sleep_quality m6_sleep_quality m6_avg_night_wake_up_duration m6_times_wake_up_night_baby m6_sleep_minutes m6_nights_away_from_baby m2_WTP_value m6_WTP_value m6_child_plan_respondent m6_child_plan_partner m6_child_plan_5yrs_likelihood m6_baby_health_condition m6_baby_growth_development"

local father_vars ///
"m1_belief_score_z m2_belief_score_z m3_belief_score_z m6_belief_score_z m6_gender_attitude_score_z m2_father_work_priority m6_father_work_priority m1_father_time_less_valuable m3_father_time_less_valuable m6_father_time_less_valuable m2_father_identity_importance m6_father_identity_importance m1_father_involv_score_z m2_father_involv_score_z m6_father_involv_score_z m1_father_care_alone m2_father_care_alone m6_father_care_alone m1_EPDS_score_z m2_EPDS_score_z m3_EPDS_score_z m6_EPDS_score_z m1_partner_MH m2_partner_MH m3_partner_MH m6_partner_MH m2_gatekeeping_score_F_std m2_gatekeeping_score_M_std m1_relationship_satisfaction m3_relationship_satisfaction m6_relationship_satisfaction m1_own_close_baby m1_partner_close_baby m3_partner_close_baby m6_partner_close_baby m3_interaction_with_baby m6_interaction_with_baby m1_triple_p_correct_z m2_triple_p_correct_z m3_triple_p_correct_z m2_mental_load_balance m1_partner_very_supportive m6_partner_very_supportive m2_disagreement_partner m2_parent_identity_score_z m3_bonding_score_z m6_bonding_score_z m3_care_baby_total m6_care_baby_total m3_self_efficacy_score_z m1_ability_father m2_ability_father m3_ability_father m6_ability_father m1_ability_mother m2_ability_mother m6_ability_mother m3_workdays_last_week m6_workdays_last_week m3_workhours_last_week m6_workhours_last_week m3_workhours_baby_6m m3_workhours_baby_12m m6_workhours_baby_12m m3_workhours_baby_24m m6_workhours_baby_24m m3_work_commute  m6_job_change_better m3_childcare_discussion m3_childcare_plan m3_partner_childcare_likelihood m3_father_1hr_care_alone m3_father_15mins_care_alone m3_temperament_score_z m1_sleep_quality m6_sleep_quality m6_avg_night_wake_up_duration m6_times_wake_up_night_baby m6_sleep_minutes m6_nights_away_from_baby m1_father_time_less_valuable m3_father_time_less_valuable m6_father_time_less_valuable m2_WTP_value m6_WTP_value m6_child_plan_respondent m6_child_plan_partner m6_child_plan_5yrs_likelihood m6_baby_health_condition m6_baby_growth_development"



// Get unique variable list
local all_vars: list mother_vars | father_vars
local all_vars: list uniq all_vars

// Open output file
capture file close resultsfile
file open resultsfile using "$results/tables/primary_table_2mononsite_20251206.tex", write replace

// Loop through each unique variable
local row = 0
foreach var of local all_vars {
    
    // Check if variable exists for mother
    local mother_exists: list posof "`var'" in mother_vars
    
    // Check if variable exists for father
    local father_exists: list posof "`var'" in father_vars
    
    // Initialize strings for mother
    if `mother_exists' > 0 {
        // Mother analysis
        preserve
        keep if mother == 1
        
        // Mean and SD for Control (C)
        qui su `var' if C == 1
        if r(N) > 0 {
            local m_mean_c: di %6.3f r(mean)
            local m_sd_c: di %6.3f r(sd)
            local m_sd_c = trim("`m_sd_c'")
        }
        else {
            local m_mean_c "-"
            local m_sd_c "-"
        }
        
        // Regression for T1 vs Control (C)
        capture reg `var' T1 i.strata i.enumerator_id, robust cluster(cluster_var)
        if _rc == 0 {
            local m_diff_t1c: di %6.3f _b[T1]
            local m_se_t1c: di %6.3f _se[T1]
            local m_se_t1c = trim("`m_se_t1c'")
            
            local pval = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
            local m_star_t1c ""
            if (`pval' < 0.1) local m_star_t1c "*"
            if (`pval' < 0.05) local m_star_t1c "**"
            if (`pval' < 0.01) local m_star_t1c "***"
        }
        else {
            local m_diff_t1c "-"
            local m_se_t1c "-"
            local m_star_t1c ""
        }
        restore
        
    }
    else {
        local m_mean_c "-"
        local m_sd_c "-"
        local m_diff_t1c "-"
        local m_se_t1c "-"
        local m_star_t1c ""
    }
    
    // Initialize strings for father
    if `father_exists' > 0 {
        // Father analysis
        preserve
        keep if mother == 0
        
        // Mean and SD for Control (C)
        qui su `var' if C == 1
        if r(N) > 0 {
            local f_mean_c: di %6.3f r(mean)
            local f_sd_c: di %6.3f r(sd)
            local f_sd_c = trim("`f_sd_c'")
        }
        else {
            local f_mean_c "-"
            local f_sd_c "-"
        }
        
        // Regression for T1 vs Control (C)
        capture reg `var' T1 i.strata i.enumerator_id, robust cluster(cluster_var)
        if _rc == 0 {
            local f_diff_t1c: di %6.3f _b[T1]
            local f_se_t1c: di %6.3f _se[T1]
            local f_se_t1c = trim("`f_se_t1c'")
            
            local pval = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
            local f_star_t1c ""
            if (`pval' < 0.1) local f_star_t1c "*"
            if (`pval' < 0.05) local f_star_t1c "**"
            if (`pval' < 0.01) local f_star_t1c "***"
        }
        else {
            local f_diff_t1c "-"
            local f_se_t1c "-"
            local f_star_t1c ""
        }
        restore
        
    }
    else {
        local f_mean_c "-"
        local f_sd_c "-"
        local f_diff_t1c "-"
        local f_se_t1c "-"
        local f_star_t1c ""
    }
    
    // Write results to file - Line 1: Variable name and means
    file write resultsfile "\textbf{`var'} & `m_mean_c' & `m_diff_t1c'`m_star_t1c' & `f_mean_c' & `f_diff_t1c'`f_star_t1c'  \\" _n
    
    // Write results to file - Line 2: SDs and SEs
    file write resultsfile " & (`m_sd_c') & (`m_se_t1c') & (`f_sd_c') & (`f_se_t1c')  \\" _n
}

file close resultsfile