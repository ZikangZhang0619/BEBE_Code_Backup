** Father Identity Attrition
** Updated on: 17 May, 2026

/*
This file estimates attrition after the 7m father identity experiment.

Sample:
    1. parents who were sent the 10m survey;
    2. among them, parents who completed the 7m survey and therefore received
       the father identity experiment;
    3. attrition outcome is whether they completed the 10m survey.

Inputs:
    $data/7m_20260507.dta
    $data/10m_20260507.dta
    $data/anonymized_cluster_mapping.dta
    /Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/06_Sent participants/10m_sent.dta

Outputs:
    $proc/attrition_father_identity.dta
    $results/tables/attrition_father_identity.tex
*/


*********
** LOG **
*********
cap log close
set linesize 200
log using "$logs/father_identity_attrition.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd


//********************************************************************************//
// 1. DATA PREPARATION
//********************************************************************************//

local sent10m "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/06_Sent participants/10m_sent.dta"

use "`sent10m'", clear

capture destring mother, replace
capture destring group, replace

drop if missing(family_id) | missing(mother)
drop if family_id == "f2ddbf38"
duplicates drop family_id mother, force

tempfile sent10m
save `sent10m'


// 7m respondents define the valid father identity experiment sample.
use "$data/7m_20260507.dta", clear

capture destring mother, replace
capture destring randtreat, replace

drop if missing(family_id) | missing(mother)
drop if family_id == "f2ddbf38"

capture drop submit_dt
gen double submit_dt = clock(submitdate, "YMDhms")
format submit_dt %tc

capture drop has_submit
gen has_submit = !missing(submit_dt)

gsort family_id mother -has_submit -submit_dt
by family_id mother: keep if _n == 1

keep family_id mother randtreat submitdate submit_dt has_submit
rename submitdate submitdate_7m
rename submit_dt submit_dt_7m
rename has_submit has_submit_7m

tempfile resp7m
save `resp7m'


// 10m respondents define the attrition outcome.
use "$data/10m_20260507.dta", clear

capture destring mother, replace

drop if missing(family_id) | missing(mother)
drop if family_id == "f2ddbf38"

capture drop submit_dt
gen double submit_dt = clock(submitdate, "YMDhms")
format submit_dt %tc

capture drop has_submit
gen has_submit = !missing(submit_dt)

gsort family_id mother -has_submit -submit_dt
by family_id mother: keep if _n == 1

keep family_id mother submitdate submit_dt has_submit
rename submitdate submitdate_10m
rename submit_dt submit_dt_10m
rename has_submit has_submit_10m

tempfile resp10m
save `resp10m'


use `sent10m', clear

merge 1:1 family_id mother using `resp7m'
keep if _merge == 3
drop _merge

merge 1:1 family_id mother using `resp10m'
drop if _merge == 2
gen completed_10m = (_merge == 3)
drop _merge

merge m:1 family_id using "$data/anonymized_cluster_mapping.dta"
keep if _merge == 3
drop _merge

capture confirm numeric variable strata
if _rc {
    encode strata, gen(strata_num)
}
else {
    gen strata_num = strata
}

capture confirm numeric variable enumerator_id
if _rc {
    encode enumerator_id, gen(enumerator_num)
}
else {
    gen enumerator_num = enumerator_id
}

capture confirm numeric variable cluster_var
if _rc {
    encode cluster_var, gen(cluster_num)
}
else {
    gen cluster_num = cluster_var
}

gen infocon = (randtreat == 0)

bys family_id: egen family_n = count(mother)
bys family_id: egen father_treat = max(cond(mother == 0, randtreat, .))
bys family_id: egen mother_treat = max(cond(mother == 1, randtreat, .))
bys family_id: egen father_response = max(cond(mother == 0, completed_10m, .))
bys family_id: egen mother_response = max(cond(mother == 1, completed_10m, .))
bys family_id: egen any_response = max(completed_10m)
bys family_id: egen n_response = total(completed_10m)

gen pair_sample = (family_n == 2 & !missing(father_treat) & !missing(mother_treat))
gen f_treat = pair_sample & father_treat == 1 & mother_treat == 0
gen m_treat = pair_sample & father_treat == 0 & mother_treat == 1
gen both_treat = pair_sample & father_treat == 1 & mother_treat == 1
gen both_control = pair_sample & father_treat == 0 & mother_treat == 0
gen mom_control = pair_sample & mother_treat == 0
gen dad_control = pair_sample & father_treat == 0
gen mom_treat = pair_sample & mother_treat == 1
gen dad_treat = pair_sample & father_treat == 1

gen only_mother = pair_sample & mother_response == 1 & father_response == 0
gen only_father = pair_sample & mother_response == 0 & father_response == 1
gen response_either = (any_response == 1)
gen response_both = pair_sample & n_response == 2

bys family_id (mother): gen family_row = (_n == 1)

save "$proc/attrition_father_identity.dta", replace


//********************************************************************************//
// 2. RAW MEANS AND REGRESSIONS
//********************************************************************************//

local fam_rows mother father om of either both
local y_mother mother_response
local y_father father_response
local y_om only_mother
local y_of only_father
local y_either response_either
local y_both response_both

local label_mother "Mother"
local label_father "Father"
local label_om "Only Mother"
local label_of "Only Father"
local label_either "Either"
local label_both "Both"

// Individual assignment: parent-level control/treat, no complete-pair restriction.
use "$proc/attrition_father_identity.dta", clear
foreach parent in mother father {
    if "`parent'" == "mother" local pcond "mother == 1"
    if "`parent'" == "father" local pcond "mother == 0"

    quietly summarize completed_10m if `pcond' & infocon == 1
    local mu_i_c_`parent' : display %6.3f r(mean)
    local N_i_c_`parent' = r(N)

    quietly summarize completed_10m if `pcond' & randtreat == 1
    local mu_i_t_`parent' : display %6.3f r(mean)
    local N_i_t_`parent' = r(N)
    local s_i_t_`parent' ""

    preserve
    keep if `pcond'
    capture noisily reg completed_10m randtreat i.strata_num i.enumerator_num, cluster(cluster_num)
    if !_rc {
        local p_i_`parent' = 2 * ttail(e(df_r), abs(_b[randtreat] / _se[randtreat]))
        if (`p_i_`parent'' < 0.1) local s_i_t_`parent' "*"
        if (`p_i_`parent'' < 0.05) local s_i_t_`parent' "**"
        if (`p_i_`parent'' < 0.01) local s_i_t_`parent' "***"
    }
    restore
}

// Family assignment: complete parent pairs only.
foreach row in `fam_rows' {
    use "$proc/attrition_father_identity.dta", clear
    keep if family_row == 1 & pair_sample == 1

    local y `y_`row''

    foreach g in mom_control dad_control mom_treat dad_treat f_treat m_treat both_treat both_control {
        quietly summarize `y' if `g' == 1
        local mu_`g'_`row' : display %6.3f r(mean)
        local N_`g'_`row' = r(N)
        local s_`g'_`row' ""
    }

    preserve
    keep if mom_control == 1 | mom_treat == 1
    capture noisily reg `y' mother_treat i.strata_num i.enumerator_num, cluster(cluster_num)
    if !_rc {
        local p_mt_`row' = 2 * ttail(e(df_r), abs(_b[mother_treat] / _se[mother_treat]))
        if (`p_mt_`row'' < 0.1) local s_mom_treat_`row' "*"
        if (`p_mt_`row'' < 0.05) local s_mom_treat_`row' "**"
        if (`p_mt_`row'' < 0.01) local s_mom_treat_`row' "***"
    }
    restore

    preserve
    keep if dad_control == 1 | dad_treat == 1
    capture noisily reg `y' father_treat i.strata_num i.enumerator_num, cluster(cluster_num)
    if !_rc {
        local p_ft_`row' = 2 * ttail(e(df_r), abs(_b[father_treat] / _se[father_treat]))
        if (`p_ft_`row'' < 0.1) local s_dad_treat_`row' "*"
        if (`p_ft_`row'' < 0.05) local s_dad_treat_`row' "**"
        if (`p_ft_`row'' < 0.01) local s_dad_treat_`row' "***"
    }
    restore

    foreach g in f_treat m_treat both_treat {
        preserve
        keep if both_control == 1 | `g' == 1
        capture noisily reg `y' `g' i.strata_num i.enumerator_num, cluster(cluster_num)
        if !_rc {
            local p_`g'_`row' = 2 * ttail(e(df_r), abs(_b[`g'] / _se[`g']))
            if (`p_`g'_`row'' < 0.1) local s_`g'_`row' "*"
            if (`p_`g'_`row'' < 0.05) local s_`g'_`row' "**"
            if (`p_`g'_`row'' < 0.01) local s_`g'_`row' "***"
        }
        restore
    }
}


//********************************************************************************//
// 3. LATEX OUTPUT
//********************************************************************************//

capture mkdir "$results/tables"
capture file close latex
file open latex using "$results/tables/attrition_father_identity.tex", write replace

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance: Individual Assignment}" _n
file write latex "" _n
file write latex "\begin{tabular*}{0.65\textwidth}{@{\extracolsep{\fill}}lcc@{}}" _n
file write latex "\toprule" _n
file write latex "\textbf{Parent} & \textbf{Control} & \textbf{Treat} \\" _n
file write latex "\midrule" _n
file write latex "Mother & `mu_i_c_mother' (`N_i_c_mother') & `mu_i_t_mother'`s_i_t_mother' (`N_i_t_mother') \\" _n
file write latex "Father & `mu_i_c_father' (`N_i_c_father') & `mu_i_t_father'`s_i_t_father' (`N_i_t_father') \\" _n
file write latex "\bottomrule" _n
file write latex "\end{tabular*}" _n
file write latex "\begin{minipage}{0.65\textwidth}" _n
file write latex "\begin{attritionnotes}" _n
file write latex " Notes: The sample is restricted to parents sent the 10m survey who completed the 7m survey. Cells report the 10m completion rate, with parent N in parentheses. Stars test individual treatment against individual control within parent type. Regressions include strata and enumerator fixed effects and cluster standard errors by the project cluster variable. \$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "\end{attritionnotes}" _n
file write latex "\end{minipage}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n _n


file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Raw Means with Significance: Family Assignment}" _n
file write latex "\begin{tabular}{lcccccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{2}{c}{\textbf{Control}} & \multicolumn{2}{c}{\textbf{Treat}} & \multicolumn{2}{c}{\textbf{Only Treat}} & \multicolumn{2}{c}{\textbf{Both}} \\" _n
file write latex "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9}" _n
file write latex "\textbf{Outcome} & \textbf{Mother} & \textbf{Father} & \textbf{Mother} & \textbf{Father} & \textbf{Mother} & \textbf{Father} & \textbf{Treat} & \textbf{Control} \\" _n
file write latex "\midrule" _n

foreach row in `fam_rows' {
    file write latex "`label_`row'' & `mu_mom_control_`row'' & `mu_dad_control_`row'' & `mu_mom_treat_`row''`s_mom_treat_`row'' & `mu_dad_treat_`row''`s_dad_treat_`row'' & `mu_m_treat_`row''`s_m_treat_`row'' & `mu_f_treat_`row''`s_f_treat_`row'' & `mu_both_treat_`row''`s_both_treat_`row'' & `mu_both_control_`row'' \\" _n
}

file write latex "\midrule" _n
file write latex "N (Family) & `N_mom_control_mother' & `N_dad_control_mother' & `N_mom_treat_mother' & `N_dad_treat_mother' & `N_m_treat_mother' & `N_f_treat_mother' & `N_both_treat_mother' & `N_both_control_mother' \\" _n
file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{minipage}{\textwidth}" _n
file write latex "\begin{attritionnotes}" _n
file write latex "Notes: The sample is restricted to complete parent-pair families in which both parents were sent the 10m survey and completed the 7m survey. The Control and Treat columns classify families by whether the mother or father was assigned to control or treatment; the Only Treat columns classify families in which only the mother or only the father was assigned to treatment. Stars in Mother Treat test against Mother Control; stars in Father Treat test against Father Control; stars in Mother Only Treat, Father Only Treat, and Both Treat test against Both Control. Regressions include strata and enumerator fixed effects and cluster standard errors by the project cluster variable. \$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "\end{attritionnotes}" _n
file write latex "\end{minipage}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n
file close latex

log close
