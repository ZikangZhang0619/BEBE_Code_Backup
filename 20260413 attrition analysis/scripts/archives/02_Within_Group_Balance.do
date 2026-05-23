** Attrition Analysis - Baseline Characteristics and Accross Group Balance**

** Author: Haoyue Wu
** Updated on: Jan 25, 2025

** IMPORT: 
/*
"$proc/random_forest_before_analysis.dta"
*/


*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project 02_attrition_baseline
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd





use "$proc/random_forest_before_analysis.dta", clear
gen unfinished_1m = (attrition==0)
// keep if time_divider == 3
// 获取所有的 enumerator 编号
local unfinished_1m "unfinished_1m"

local row = 0
foreach var of varlist `unfinished_1m' {
    
	count
	local N = r(N)
	
	su `var'
	local mean: di %6.3f r(mean)
	local sd: di %6.3f r(sd)
	local sd = trim("`sd'")
	
	// Mean and SD for Control (C)
    su `var' if C == 1
    local mean_c: di %6.3f r(mean)
    local sd_c: di %6.3f r(sd)
	local sd_c = trim("`sd_c'")


    // Mean and SD for T1
    su `var' if T1 == 1
    local mean_t1: di %6.3f r(mean)
    local sd_t1: di %6.3f r(sd)
	local sd_t1 = trim("`sd_t1'")
	
    // Mean and SD for T2
    su `var' if T2 == 1
    local mean_t2: di %6.3f r(mean)
    local sd_t2: di %6.3f r(sd)
	local sd_t2 = trim("`sd_t2'")

	// Mean and SD for Treat
    su `var' if Treat == 1
    local mean_treat: di %6.3f r(mean)
    local sd_treat: di %6.3f r(sd)
	local sd_treat = trim("`sd_treat'")
	
	
    // Regression for T1 vs Control (C)
    preserve
    drop if T2 == 1
    reg `var' T1 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t1c: di %6.3f _b[T1]
    local se_t1c: di %6.3f _se[T1]
	local se_t1c = trim("`se_t1c'")
	
    local pval_t1c = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
    local pval_t1c: di %6.3f `pval_t1c'
	
	local star_t1c ""
    if (`pval_t1c' < 0.1) local star_t1c "*"
    if (`pval_t1c' < 0.05) local star_t1c "**"
    if (`pval_t1c' < 0.01) local star_t1c "***"
    restore

    // Regression for T2 vs Control (C)
    preserve
    drop if T1 == 1
    reg `var' T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t2c: di %6.3f _b[T2]
    local se_t2c: di %6.3f _se[T2]
	local se_t2c = trim("`se_t2c'")

    local pval_t2c = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
    local pval_t2c: di %6.3f `pval_t2c'
	
	local star_t2c ""
    if (`pval_t2c' < 0.1) local star_t2c "*"
    if (`pval_t2c' < 0.05) local star_t2c "**"
    if (`pval_t2c' < 0.01) local star_t2c "***"
	
    restore

    // Regression for T2 vs T1
    preserve
    drop if C == 1
    reg `var' T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_t2t1: di %6.3f _b[T2]
    local se_t2t1: di %6.3f _se[T2]
	local se_t2t1 = trim("`se_t2t1'")

    local pval_t2t1 = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
    local pval_t2t1: di %6.3f `pval_t2t1'
	
	local star_t2t1 ""
    if (`pval_t2t1' < 0.1) local star_t2t1 "*"
    if (`pval_t2t1' < 0.05) local star_t2t1 "**"
    if (`pval_t2t1' < 0.01) local star_t2t1 "***"
    restore

	// Regression for Treat vs C
    preserve
    reg `var' Treat i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
    local diff_treat: di %6.3f _b[Treat]
    local se_treat: di %6.3f _se[Treat]
	local se_treat = trim("`se_treat'")

    local pval_treat = 2 * ttail(e(df_r), abs(_b[Treat] / _se[Treat]))
    local pval_treat: di %6.3f `pval_treat'
	
	local star_treat ""
    if (`pval_treat' < 0.1) local star_treat "*"
    if (`pval_treat' < 0.05) local star_treat "**"
    if (`pval_treat' < 0.01) local star_treat "***"
    restore
	
	
    // Optional: Perform Chi-square test for categorical variables if needed
    // Here, I'll assume you know which variables are categorical
    preserve
    tab `var' group, chi2
    local pval_chi2: di %6.3f r(p)
    restore

    // Increment row counter
    local row = `row' + 1

    // Store the results for this variable
    local mu_row`row' "\textit{ N = `N'} &`mean' & `mean_c' & `mean_t1' & `mean_t2' & `mean_treat' & `diff_t1c'`star_t1c' & `diff_t2c'`star_t2c' & `diff_t2t1'`star_t2t1' & `diff_treat'`star_treat' &  `pval_chi2'"
	
	// Increment row counter
    local row = `row' + 1
	local mu_row`row' " &(`sd') & (`sd_c') & (`sd_t1') & (`sd_t2') & (`sd_treat') & (`se_t1c') & (`se_t2c')  & (`se_t2t1') & (`se_treat') &  "
	
	
}
 
// Output results to LaTeX
file open resultsfile using "$results/tables/across_group_balance_by_time.tex", write replace
local row = 0
foreach var of varlist `unfinished_1m' {
    local row = `row' + 1
    file write resultsfile "`mu_row`row'' \\" _n
	local row = `row' + 1
    file write resultsfile "`mu_row`row'' \\" _n
}
file close resultsfile

///--------------------------------

use "$proc/random_forest_before_analysis.dta", clear


local varlist enumerator_num mother baby_female certainty_father certainty_mother ability_father ability_mother vip father_involvement attitude communication_quality employment_security environment_recruitment engagement_father engagement_mother willingness relationship_quality social_desirability_s belief_father belief_mother father_time_household_chores

foreach var in `varlist' {
    
    // Get the levels of the current categorical variable
    levelsof `var', local(var_value)
    
    // Open the output file (append mode)
    file open resultsfile using "$results/tables/across_group_balance.tex", write append
    
    // Loop through each level of the current variable
    foreach level of local var_value {
        di "Processing for `var' level: `level'"

        use "$proc/random_forest_before_analysis.dta", clear
        keep if `var' == `level'  // Keep data for the current level

        count
        local N_`var'`level' = r(N)  // Save the count

        // Output header to LaTeX file
        file write resultsfile "\midrule" _n
        file write resultsfile "\textbf{`var' level `level'}\\" _n
        
        local row = 0
        
        // Calculate and output means and standard deviations
        su unfinished_1m
        local mean: di %6.3f r(mean)
        local sd: di %6.3f r(sd)
        
        // Mean and SD for Control (C)
        su unfinished_1m if C == 1
        local mean_c: di %6.3f r(mean)
        local sd_c: di %6.3f r(sd)
        
        // Mean and SD for T1
        su unfinished_1m if T1 == 1
        local mean_t1: di %6.3f r(mean)
        local sd_t1: di %6.3f r(sd)
        
        // Mean and SD for T2
        su unfinished_1m if T2 == 1
        local mean_t2: di %6.3f r(mean)
        local sd_t2: di %6.3f r(sd)
        
        // Mean and SD for Treat
        su unfinished_1m if Treat == 1
        local mean_treat: di %6.3f r(mean)
        local sd_treat: di %6.3f r(sd)
        
        // Perform regressions and calculate coefficients, standard errors, p-values, and stars
        preserve
        drop if T2 == 1
        reg unfinished_1m T1 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t1c: di %6.3f _b[T1]
        local se_t1c: di %6.3f _se[T1]
        local pval_t1c = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
        local star_t1c ""
        if (`pval_t1c' < 0.1) local star_t1c "*"
        if (`pval_t1c' < 0.05) local star_t1c "**"
        if (`pval_t1c' < 0.01) local star_t1c "***"
        restore

        preserve
        drop if T1 == 1
        reg unfinished_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t2c: di %6.3f _b[T2]
        local se_t2c: di %6.3f _se[T2]
        local pval_t2c = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
        local star_t2c ""
        if (`pval_t2c' < 0.1) local star_t2c "*"
        if (`pval_t2c' < 0.05) local star_t2c "**"
        if (`pval_t2c' < 0.01) local star_t2c "***"
        restore

        preserve
        drop if C == 1
        reg unfinished_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_t2t1: di %6.3f _b[T2]
        local se_t2t1: di %6.3f _se[T2]
        local pval_t2t1 = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
        local star_t2t1 ""
        if (`pval_t2t1' < 0.1) local star_t2t1 "*"
        if (`pval_t2t1' < 0.05) local star_t2t1 "**"
        if (`pval_t2t1' < 0.01) local star_t2t1 "***"
        restore

        preserve
        reg unfinished_1m Treat i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_treat: di %6.3f _b[Treat]
        local se_treat: di %6.3f _se[Treat]
        local pval_treat = 2 * ttail(e(df_r), abs(_b[Treat] / _se[Treat]))
        local star_treat ""
        if (`pval_treat' < 0.1) local star_treat "*"
        if (`pval_treat' < 0.05) local star_treat "**"
        if (`pval_treat' < 0.01) local star_treat "***"
        restore

        // Optional Chi-square test
        preserve
        tab unfinished_1m group, chi2
        local pval_chi2: di %6.3f r(p)
        restore

        // Prepare the output row
        local row = `row' + 1
        local mu_row`row' "\textit{ N = `N_`var'`level''} & `mean' & `mean_c' & `mean_t1' & `mean_t2' & `mean_treat' & `diff_t1c'`star_t1c' & `diff_t2c'`star_t2c' & `diff_t2t1'`star_t2t1' & `diff_treat'`star_treat' &  `pval_chi2'"

        local row = `row' + 1
        local mu_row`row' " & (`sd') & (`sd_c') & (`sd_t1') & (`sd_t2') & (`sd_treat') & (`se_t1c') & (`se_t2c')  & (`se_t2t1') & (`se_treat') &  "
        // Write the row to the LaTeX file
		
		    local row = 0

        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n
        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n
    
    }

    // Close the output file after finishing
    file close resultsfile
}


// use "$proc/random_forest_before_analysis.dta", clear

// levelsof time_divider, local(time_levels)
// di `time_levels'
// local varlist  mother enumerator_num baby_female certainty_father certainty_mother ability_father ability_mother vip father_involvement attitude communication_quality employment_security environment_recruitment engagement_father engagement_mother willingness relationship_quality social_desirability_s belief_father belief_mother father_time_household_chores
// foreach var in `varlist' {
//     di "===== `var' by time_divider ====="
//     tab `var' time_divider, missing
// }

// foreach var in `varlist' {
//     // Get the levels of the current categorical variable
//     levelsof `var', local(var_value)
//     levelsof time_divider, local(time_levels)
    
//     // Open the output file (append mode)
//     file open resultsfile using "$results/tables/across_group_balance_by_time_3.tex", write append
    
//     // Loop through each level of the current variable
//     foreach level of local var_value {
//         di "Processing for `var' level: `level'"
//         use "$proc/random_forest_before_analysis.dta", clear
//         // Loop through each biweek
// //         foreach tim of local time_levels {
//             use "$proc/random_forest_before_analysis.dta", clear
//             keep if `var' == `level' & time_divider == 3  // Keep data for current level and biweek
            
//             count
//             local N_`var'`level' = r(N)  // Save the count
            
// //             // Only proceed if there are observations
// //             if `N_`var'`level'' > 0 {
//                 // Output header to LaTeX file
//                 file write resultsfile "\midrule" _n
//                 file write resultsfile "\textbf{`var' level `level', time 3}\\" _n
                
//                 // Calculate and output means and standard deviations
//                 qui su unfinished_1m
//                 local mean: di %6.3f r(mean)
//                 local sd: di %6.3f r(sd)
                
//                 // Mean and SD for Control (C)
//                 qui su unfinished_1m if C == 1
//                 local mean_c: di %6.3f r(mean)
//                 local sd_c: di %6.3f r(sd)
                
//                 // Mean and SD for T1
//                 qui su unfinished_1m if T1 == 1
//                 local mean_t1: di %6.3f r(mean)
//                 local sd_t1: di %6.3f r(sd)
                
//                 // Mean and SD for T2
//                 qui su unfinished_1m if T2 == 1
//                 local mean_t2: di %6.3f r(mean)
//                 local sd_t2: di %6.3f r(sd)
                
//                 // Mean and SD for Treat
//                 qui su unfinished_1m if Treat == 1
//                 local mean_treat: di %6.3f r(mean)
//                 local sd_treat: di %6.3f r(sd)
                
//                 // Regression analyses with error handling
//                 capture {
//                     // T1 vs Control
//                     preserve
//                     drop if T2 == 1
//                     reg unfinished_1m T1 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
//                     local diff_t1c: di %6.3f _b[T1]
//                     local se_t1c: di %6.3f _se[T1]
//                     local pval_t1c = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
//                     local star_t1c = cond(`pval_t1c' < 0.01, "***", cond(`pval_t1c' < 0.05, "**", cond(`pval_t1c' < 0.1, "*", "")))
//                     restore
                    
//                     // [Similar blocks for T2 vs Control and T2 vs T1]
//                     preserve
//                     drop if T1 == 1
//                     reg unfinished_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
//                     local diff_t2c: di %6.3f _b[T2]
//                     local se_t2c: di %6.3f _se[T2]
//                     local pval_t2c = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
//                     local star_t2c = cond(`pval_t2c' < 0.01, "***", cond(`pval_t2c' < 0.05, "**", cond(`pval_t2c' < 0.1, "*", "")))
//                     restore
					
// 					preserve
//                     drop if C == 1
//                     reg unfinished_1m T2 i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
//                     local diff_t2t1: di %6.3f _b[T2]
// 					local se_t2t1: di %6.3f _se[T2]
//                     local pval_t2t1 = 2 * ttail(e(df_r), abs(_b[T2] / _se[T2]))
//                     local star_t2t1 = cond(`pval_t2t1' < 0.01, "***", cond(`pval_t2t1' < 0.05, "**", cond(`pval_t2t1' < 0.1, "*", "")))
//                     restore
					
// 					preserve
//                     reg unfinished_1m Treat i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
//                     local diff_treat: di %6.3f _b[Treat]
// 					local se_treat: di %6.3f _se[Treat]
// 					local pval_treat = 2 * ttail(e(df_r), abs(_b[Treat] / _se[Treat]))
//                     local star_treat = cond(`pval_treat' < 0.01, "***", cond(`pval_treat' < 0.05, "**", cond(`pval_treat' < 0.1, "*", "")))
//                     restore				
					
//                     // Chi-square test
//                     qui tab unfinished_1m group, chi2
//                     local pval_chi2: di %6.3f r(p)
                    
//                     // Write results to file
//                     local mu_row1 "\textit{N = `N_`var'`level'', time = 3} & `mean' & `mean_c' & `mean_t1' & `mean_t2' & `mean_treat' & `diff_t1c'`star_t1c' & `diff_t2c'`star_t2c' & `diff_t2t1'`star_t2t1' & `diff_treat'`star_treat' & `pval_chi2'"
//                     local mu_row2 "& (`sd') & (`sd_c') & (`sd_t1') & (`sd_t2') & (`sd_treat') & (`se_t1c') & (`se_t2c') & (`se_t2t1') & (`se_treat') & "
                    
//                     file write resultsfile "`mu_row1' \\" _n
//                     file write resultsfile "`mu_row2' \\" _n
//                 }
// //             }
// //         }
//     }
//     file close resultsfile
// }



// ------------- see if attrition is related to something during recruitment
use "$proc/random_forest_before_analysis.dta", clear
reg attrition duration_intervention treatment 
