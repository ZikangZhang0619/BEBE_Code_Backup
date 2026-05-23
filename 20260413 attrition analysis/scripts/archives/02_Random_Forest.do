** Attrition Analysis - Random Forest **


** Author: Haoyue Wu
** Updated on: Jan 9, 2025

/* 
IMPORTS:
$proc/random_forest_before_analysis.dta

OUTPUT:
$results/figures
*/



*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 01_randforest
cap log close
set linesize 200
log using "/Users/isabellawu/Downloads/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd

*******
use "$proc/random_forest_before_analysis.dta", clear
set seed 201807
gen u=uniform()
sort u
gen out_of_bag_error1 = .
gen validation_error = .
gen iter1 = .
local j = 0

// forvalues i = 1(1)50{
// 	local j = `j' + 1
// 	rforest unfinished_1m baby_female certainty_father certainty_mother ability_father ability_mother father_involvement attitude communication_quality employment_security environment_recruitment childcare_will_f childcare_will_m willingness dominance relationship_quality social_desirability_scale_score belief_father belief_mother father_time_household_chores engagement in 1/700, ///
// 	type(class) iter(`i') numvars(1)
// 	replace iter1 = `i' in `j'
// 	replace out_of_bag_error1 = `e(OOB_Error)' in `j'
// 	predict p in 701/1354
// 	replace validation_error = `e(error_rate)' in `j'
// 	drop p
// }


forvalues i = 1(1)50{
	local j = `j' + 1
	rforest unfinished_1m baby_female treatment bed_in_room certainty_father certainty_mother ability_father ability_mother vip father_involv_diaper father_involvs_night father_involv_play father_involv_lull attitude_work attitude_emotion attitude_importance communication_quality employment_security environment_recruitment willingness relationship_quality social_desirability_scale_score belief_father_walk belief_father_word belief_mother_walk belief_mother_word father_time_household_chores engagement_mother engagement_father in 1/900, ///
	type(class) iter(`i') numvars(1) ///
	depth(0) lsize(1) seed(12345) numdecimalplaces(5) 
	
	replace iter1 = `i' in `j'
	replace out_of_bag_error1 = `e(OOB_Error)' in `j'
	predict p in 901/1516
	replace validation_error = `e(error_rate)' in `j'
	drop p
}

twoway (scatter out_of_bag_error1 iter1, msymbol(o) mcolor(blue) msize(vsmall)) ///
       (scatter validation_error iter1, msymbol(o) mcolor(red) msize(vsmall)), ///
       legend(label(1 "Out of Bag Error") label(2 "Validation Error") pos(6)) ///
       xlabel(0(5)50) ylabel(0.08(.01).18) ///
       xtitle("Iterations") ytitle("Error") ///
       title("Out of Bag Error and Validation Error vs Iterations") ///
       graphregion(color(white)) 
	   
	   graph export "$results/figures/OOB_validation_iteration.pdf", as(pdf) replace
	   
	   
// Find the iteration corresponding to the minimum validation error
egen min_val_error = min(validation_error)
gen best_iter = iter1 if validation_error == min_val_error
list best_iter validation_error if validation_error == min_val_error

	   
gen oob_error = .
gen nvars = .
gen val_error = .
local j = 0
forvalues i = 1(1)28{
	local j = `j' + 1
	rforest unfinished_1m baby_female treatment bed_in_room certainty_father certainty_mother ability_father ability_mother vip father_involv_diaper father_involvs_night father_involv_play father_involv_lull attitude_work attitude_emotion attitude_importance communication_quality employment_security environment_recruitment willingness relationship_quality social_desirability_scale_score belief_father_walk belief_father_word belief_mother_walk belief_mother_word father_time_household_chores engagement_mother engagement_father in 1/900, ///
	type(class) iter(7) numvars(`i')
	replace nvars = `i' in `j'
	replace oob_error = `e(OOB_Error)' in `j'
	predict p in 901/1516
	replace val_error = `e(error_rate)' in `j'
	drop p
}
twoway (scatter oob_error nvars, msymbol(o) mcolor(blue) msize(vsmall)) ///
       (scatter val_error nvars, msymbol(o) mcolor(red) msize(vsmall)), ///
       legend(label(1 "Out of Bag Error") label(2 "Validation Error") pos(6)) ///
       xlabel(0(4)20) ylabel(0.08(.02).18) ///
       xtitle("Number of Variables Selected at Each Split") ytitle("Error") ///
       graphregion(color(white)) 
	   
	   graph export "$results/figures/OOB_validation_numvar.pdf", as(pdf) replace
	   
	   
egen min_val_error2 = min(val_error)
gen best_num_var = nvars if val_error == min_val_error2
list best_num_var val_error if val_error == min_val_error2
	   
use "$proc/random_forest_before_analysis.dta", clear
rforest unfinished_1m baby_female treatment bed_in_room certainty_father certainty_mother ability_father ability_mother vip father_involv_diaper father_involvs_night father_involv_play father_involv_lull attitude_work attitude_emotion attitude_importance communication_quality employment_security environment_recruitment willingness relationship_quality social_desirability_scale_score belief_father_walk belief_father_word belief_mother_walk belief_mother_word father_time_household_chores engagement_mother engagement_father in 1/800, type(class) iter(7) numvars(2)

ereturn list
matrix list e(importance)
matrix importance = e(importance)

local feature_names baby_female treatment bed_in_room certainty_father certainty_mother ability_father ability_mother vip father_involv_diaper father_involvs_night father_involv_play father_involv_lull attitude_work attitude_emotion attitude_importance communication_quality employment_security environment_recruitment willingness relationship_quality social_desirability_scale_score belief_father_walk belief_father_word belief_mother_walk belief_mother_word father_time_household_chores engagement_mother engagement_father


gen varname = ""

local i = 1
foreach feature of local feature_names {
    
    replace varname = "`feature'" in `i'
    local i = `i' + 1
}

svmat importance, name(col)
keep varname Variable
rename (Variable varname) (importance feature)

graph hbar importance, over(feature, sort(1) gap(30)) scale(*.6) ///
    blabel(bar, size(small) format(%9.2f)) /// 
    title("Feature Importance") ///
    ytitle("importance", size(small)) /// 
    ylabel(,labsize(small)) /// 
    graphregion(color(white)) ///
    aspect(1) 


graph export "$results/figures/feature_importance.pdf", replace


*************
** WRAP UP **
*************
log close
exit

