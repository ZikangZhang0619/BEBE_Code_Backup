
import excel using "$data/10m_sent.xlsx", firstrow clear
rename 电话 firstname
duplicates drop firstname, force
merge 1:1 firstname using "$proc/7m_results.dta"
keep if _merge == 3
drop _merge
// the ones sent 10m and responded to the 7m 

merge 1:1 firstname using "$proc/10m_results.dta"
drop if _merge == 2
gen completed_10m = (_merge == 3)
drop _merge

drop if hospital_id == ""

gen mother = (attribute_7 == "Y")

gen treatment = "C" if attribute_4 == "Y"
replace treatment = "T1" if attribute_5 == "Y"
replace treatment = "T2" if attribute_6 == "Y"
drop C D T1 T2 母亲 父亲
gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")
gen group = 1 if C == 1
replace group = 2 if T1 == 1
replace group = 3 if T2 == 1

destring randtreat, replace
tab randtreat mother
gen infocon = (randtreat == 0)
bys hospital_id (mother): gen f_treat = (randtreat[_N-1] == 1 & randtreat[_N] == 0)
bys hospital_id (mother): gen m_treat = (randtreat[_N-1] == 0 & randtreat[_N] == 1)
bys hospital_id (mother): gen both_treat = (randtreat[_N-1] == 1 & randtreat[_N] == 1)
bys hospital_id (mother): gen both_control = (randtreat[_N-1] == 0 & randtreat[_N] == 0)




    bys hospital_id (mother): gen only_mother = (completed_10m[_N] == 1 & completed_10m[_N-1] == 0)
    bys hospital_id (mother): gen only_father = (completed_10m[_N] == 0 & completed_10m[_N-1] == 1)
    bysort hospital_id (completed_10m): gen response_either = completed_10m[_N]
    bys hospital_id : gen response_both = (completed_10m[_N] == 1 & completed_10m[_N-1] == 1)

rename hospital_id hospital_id_temp
gen hospital_id = substr(hospital_id_temp, 4, 6) if strlen(hospital_id_temp) > 6

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

duplicates tag hospital_id, gen(tag)

    save "$proc/attrition_father_identity.dta", replace






    *------------------------------------------------------------*
    *             Regression: Attrition means        *
    *------------------------------------------------------------*
            // ---------- Mothers ----------
        use "$proc/attrition_father_identity.dta", clear
        keep if mother == 1
        foreach g in infocon randtreat f_treat m_treat both_treat both_control {
            su completed_10m if `g'==1
            local mean_`g'_mother : di %6.3f r(mean)
            local N_`g'_mother = r(N)
        }

        // randtreat vs C
        foreach g in randtreat   {
            preserve
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_mother = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_mother ""
            if (`pval_`g'_mother'<0.1) local star_`g'_mother "*"
            if (`pval_`g'_mother'<0.05) local star_`g'_mother "**"
            if (`pval_`g'_mother'<0.01) local star_`g'_mother "***"
            restore
        }

        foreach g in f_treat m_treat both_treat both_control {
            preserve
            keep if tag == 1
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_mother = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_mother ""
            if (`pval_`g'_mother'<0.1) local star_`g'_mother "*"
            if (`pval_`g'_mother'<0.05) local star_`g'_mother "**"
            if (`pval_`g'_mother'<0.01) local star_`g'_mother "***"
            restore
        }

        // ---------- Fathers ----------
        use "$proc/attrition_father_identity.dta", clear
        keep if mother == 0
        foreach g in  infocon randtreat f_treat m_treat both_treat both_control {
            su completed_10m if `g'==1
            local mean_`g'_father : di %6.3f r(mean)
            local N_`g'_father = r(N)
            di `mean_`g'_father'
        }

        // randtreat vs C
        foreach g in randtreat  {
            preserve
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_father = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_father ""
            if (`pval_`g'_father'<0.1) local star_`g'_father "*"
            if (`pval_`g'_father'<0.05) local star_`g'_father "**"
            if (`pval_`g'_father'<0.01) local star_`g'_father "***"
            restore
        }

        foreach g in f_treat m_treat both_treat both_control {
            preserve
            keep if tag == 1
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_father = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_father ""
            if (`pval_`g'_father'<0.1) local star_`g'_father "*"
            if (`pval_`g'_father'<0.05) local star_`g'_father "**"
            if (`pval_`g'_father'<0.01) local star_`g'_father "***"
            restore
        }


        // ---------- Only Mothers ----------
        use "$proc/attrition_father_identity.dta", clear
        keep if mother == 1
        foreach g in  infocon randtreat f_treat m_treat both_treat both_control {
            su only_mother if `g'==1
            local mean_`g'_mo : di %6.3f r(mean)
            local N_`g'_mo = r(N)
        }

        foreach g in randtreat {
            preserve
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_mo = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_mo ""
            if (`pval_`g'_mo'<0.1) local star_`g'_mo "*"
            if (`pval_`g'_mo'<0.05) local star_`g'_mo "**"
            if (`pval_`g'_mo'<0.01) local star_`g'_mo "***"
            restore
        }

        foreach g in f_treat m_treat both_treat both_control {
            preserve
            keep if tag == 1
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_mo = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_mo ""
            if (`pval_`g'_mo'<0.1) local star_`g'_mo "*"
            if (`pval_`g'_mo'<0.05) local star_`g'_mo "**"
            if (`pval_`g'_mo'<0.01) local star_`g'_mo "***"
            restore
        }

        

        // ---------- Only Fathers ----------
        use "$proc/attrition_father_identity.dta", clear
        keep if mother == 0
        foreach g in  infocon randtreat f_treat m_treat both_treat both_control {
            su only_father if `g'==1
            local mean_`g'_fa : di %6.3f r(mean)
            local N_`g'_fa = r(N)
        }

        foreach g in randtreat {
            preserve
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_fa = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_fa ""
            if (`pval_`g'_fa'<0.1) local star_`g'_fa "*"
            if (`pval_`g'_fa'<0.05) local star_`g'_fa "**"
            if (`pval_`g'_fa'<0.01) local star_`g'_fa "***"
            restore
        }

        foreach g in f_treat m_treat both_treat both_control {
            preserve
            keep if tag == 1
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_fa = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_fa ""
            if (`pval_`g'_fa'<0.1) local star_`g'_fa "*"
            if (`pval_`g'_fa'<0.05) local star_`g'_fa "**"
            if (`pval_`g'_fa'<0.01) local star_`g'_fa "***"
            restore
        }


        // ---------- Either parent ----------
        use "$proc/attrition_father_identity.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in infocon randtreat f_treat m_treat both_treat both_control {
            su response_either if `g'==1
            local mean_`g'_either : di %6.3f r(mean)
            local N_`g'_either = r(N)
        }

        // T1 vs C
        foreach g in randtreat {
            preserve
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_either = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_either ""
            if (`pval_`g'_either'<0.1) local star_`g'_either "*"
            if (`pval_`g'_either'<0.05) local star_`g'_either "**"
            if (`pval_`g'_either'<0.01) local star_`g'_either "***"
            restore
        }

        foreach g in  f_treat m_treat both_treat both_control {
            preserve
            keep if tag == 1
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_either = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_either ""
            if (`pval_`g'_either'<0.1) local star_`g'_either "*"
            if (`pval_`g'_either'<0.05) local star_`g'_either "**"
            if (`pval_`g'_either'<0.01) local star_`g'_either "***"
            restore
        }
        // ---------- Both parent ----------
        use "$proc/attrition_father_identity.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in infocon randtreat f_treat m_treat both_treat both_control  {
            su response_both if `g'==1
            local mean_`g'_both : di %6.3f r(mean)
            local N_`g'_both = r(N)
        }

        foreach g in randtreat {
            preserve
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_both = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_both ""
            if (`pval_`g'_both'<0.1) local star_`g'_both "*"
            if (`pval_`g'_both'<0.05) local star_`g'_both "**"
            if (`pval_`g'_both'<0.01) local star_`g'_both "***"
            restore
        }
        
        foreach g in f_treat m_treat both_treat both_control {
            preserve
            keep if tag == 1
            reg completed_10m `g' i.strata i.enumerator_id, cluster(cluster_var)
            local pval_`g'_both = 2*ttail(e(df_r), abs(_b[`g']/_se[`g']))
            local star_`g'_both ""
            if (`pval_`g'_both'<0.1) local star_`g'_both "*"
            if (`pval_`g'_both'<0.05) local star_`g'_both "**"
            if (`pval_`g'_both'<0.01) local star_`g'_both "***"
            restore
        }


capture file close latex
file open latex using "$results/tables/attrition_father_identity.tex", write replace

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance  - Father Identity Attrition}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{5}{c}{After Triple P Change}  \\" _n
file write latex "\cmidrule(lr){2-6} " _n
file write latex "\textbf{Group} & \textbf{Individual Control} & \textbf{Individual Treat} & \textbf{Father Only Treat} & \textbf{Mother Only Treat} & \textbf{Both Treat} & \textbf{Both Control}\\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_infocon_mother' & `mean_randtreat_mother'`star_randtreat_mother' & `mean_f_treat_mother'`star_f_treat_mother' & `mean_m_treat_mother'`star_m_treat_mother' & `mean_both_treat_mother'`star_both_treat_mother' & `mean_both_control_mother'`star_both_control_mother' \\" _n
file write latex "Father & `mean_infocon_father' & `mean_randtreat_father'`star_randtreat_father' & `mean_f_treat_father'`star_f_treat_father' & `mean_m_treat_father'`star_m_treat_father' & `mean_both_treat_father'`star_both_treat_father' & `mean_both_control_father'`star_both_control_father' \\" _n
file write latex "Only Mother & `mean_infocon_mo' & `mean_randtreat_mo'`star_randtreat_mo' & `mean_f_treat_mo'`star_f_treat_mo' & `mean_m_treat_mo'`star_m_treat_mo' & `mean_both_treat_mo'`star_both_treat_mo' & `mean_both_control_mo'`star_both_control_mo' \\" _n
file write latex "Only Father & `mean_infocon_fa' & `mean_randtreat_fa'`star_randtreat_fa' & `mean_f_treat_fa'`star_f_treat_fa' & `mean_m_treat_fa'`star_m_treat_fa' & `mean_both_treat_fa'`star_both_treat_fa' & `mean_both_control_fa'`star_both_control_fa' \\" _n
file write latex "Either & `mean_infocon_either' & `mean_randtreat_either'`star_randtreat_either' & `mean_f_treat_either'`star_f_treat_either' & `mean_m_treat_either'`star_m_treat_either' & `mean_both_treat_either'`star_both_treat_either' & `mean_both_control_either'`star_both_control_either' \\" _n
file write latex "Both & `mean_infocon_both' & `mean_randtreat_both'`star_randtreat_both' & `mean_f_treat_both'`star_f_treat_both' & `mean_m_treat_both'`star_m_treat_both' & `mean_both_treat_both'`star_both_treat_both' & `mean_both_control_both'`star_both_control_both' \\" _n
file write latex "N(Family) & `N_infocon_mother' & `N_randtreat_mother' & `N_f_treat_mother' & `N_m_treat_mother' & `N_both_treat_mother' & `N_both_control_mother' \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Raw means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n
file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n