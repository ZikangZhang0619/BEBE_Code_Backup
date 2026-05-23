

/*
run 
	01_assemble
	02_baseline_characteristics_data_prepare_binary
	
before this file

*/
use "$proc/random_forest_before_analysis.dta", clear
local varlist parent

foreach var in `varlist' {
    
    // Get the levels of the current categorical variable
    levelsof `var', local(var_value)
    
    // Open the output file (append mode)
    file open resultsfile using "$results/tables/attrition_baseline.tex", write replace
    
    // Loop through each level of the current variable
    foreach level of local var_value {
        di "Processing for `var' level: `level'"

        use "$proc/random_forest_before_analysis.dta", clear
		drop if duration_intervention >= 900 & C ~= 1
		drop if duration_intervention >= 360 & C == 1
		drop if duration_intervention < 900 & C ~= 1
		drop if duration_intervention < 360 & C == 1
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
