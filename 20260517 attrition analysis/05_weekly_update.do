** Weekly Response Rate Update
** Rebuilt on: 17 May, 2026

/*
This file monitors response rates for ongoing survey collection.

Unlike the main attrition analysis, denominators come from the wave-specific
sent participant files. This excludes participants who had already withdrawn
before the wave was sent and is therefore appropriate for operational response
rate monitoring.

Outputs:
    $results/tables/weekly_update.tex
*/


*********
** LOG **
*********
cap log close
set linesize 200
capture log using "$logs/weekly_update.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd


//********************************************************************************//
// 0. SETTINGS
//********************************************************************************//

local waves 6m 7m 10m

local clean_data "$data"
if "`clean_data'" == "" {
    local clean_data "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/05_Cleaned anonymized data"
}

local sent_dir "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/06_Sent participants"

local tables_dir "$results/tables"
if "`tables_dir'" == "/tables" | "`tables_dir'" == "" {
    local tables_dir "/Users/zikangzhang/Library/CloudStorage/OneDrive-UniversitätZürichUZH/Anne Ardila Brenoe 的文件 - 08_BEBE/05_Code/2_Attrition Analysis/results/tables"
}

*** Collection date of used data: 2026-05-18
*** Active survey: sent after 2026-04-23
*** Reminder window: sent after 2026-04-30

*** The active survey (within 30 days) ***
local active_cutoff_date "2026-04-23"

*** The reminder window (within 17 days) ***
local reminder_cutoff_date "2026-05-07"

local data_6m "`clean_data'/6m_20260518.dta"
local data_7m "`clean_data'/7m_20260518.dta"
local data_10m "`clean_data'/10m_20260518.dta"

local cluster_map "`clean_data'/anonymized_cluster_mapping.dta"

capture mkdir "`tables_dir'"
capture file close latex
file open latex using "`tables_dir'/weekly_update.tex", write replace


//********************************************************************************//
// 1. TREATMENT-GROUP RESPONSE MONITORING
//********************************************************************************//

local fam_rows mother father om of either both
local label_mother "Mother"
local label_father "Father"
local label_om "Only Mother"
local label_of "Only Father"
local label_either "Either"
local label_both "Both"

foreach wave of local waves {
    foreach window in reminder active {

        local lower_date "`active_cutoff_date'"
        local window_title "Active Survey Window"
        if "`window'" == "reminder" {
            local lower_date "`reminder_cutoff_date'"
            local window_title "Reminder Window"
        }

        use "`sent_dir'/`wave'_sent.dta", clear

        capture destring mother, replace
        capture destring group, replace

        drop if missing(family_id) | missing(mother)
        drop if family_id == "f2ddbf38"

        capture confirm variable sent_date
        if _rc {
            capture confirm numeric variable date
            if _rc {
                gen sent_date = daily(date, "YMD")
            }
            else {
                gen sent_date = date
            }
        }
        else {
            capture confirm numeric variable sent_date
            if _rc {
                gen double sent_date_num = daily(sent_date, "YMD")
                drop sent_date
                rename sent_date_num sent_date
            }
        }
        format sent_date %td

        keep if sent_date >= date("`lower_date'", "YMD")
        duplicates drop family_id mother, force

        tempfile sent_`wave'_`window'
        save `sent_`wave'_`window''

        use "`data_`wave''", clear

        capture destring mother, replace
        capture destring group, replace

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

        tempfile resp_`wave'
        save `resp_`wave''

        use `sent_`wave'_`window'', clear

        merge 1:1 family_id mother using `resp_`wave''
        drop if _merge == 2
        gen response_`wave' = (_merge == 3)
        drop _merge

        merge m:1 family_id using "`cluster_map'"
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

        gen C = (group == 1)
        gen T1 = (group == 2)

        bys family_id: egen family_n = count(mother)
        bys family_id: egen family_group = max(group)
        bys family_id: egen mother_response = max(cond(mother == 1, response_`wave', .))
        bys family_id: egen father_response = max(cond(mother == 0, response_`wave', .))
        bys family_id: egen any_response = max(response_`wave')
        bys family_id: egen n_response = total(response_`wave')

        gen pair_sample = (family_n == 2)
        gen C_fam = (family_group == 1)
        gen T1_fam = (family_group == 2)
        gen only_mother = pair_sample & mother_response == 1 & father_response == 0
        gen only_father = pair_sample & mother_response == 0 & father_response == 1
        gen response_either = pair_sample & any_response == 1
        gen response_both = pair_sample & n_response == 2

        bys family_id (mother): gen family_row = (_n == 1)

        save "$proc/weekly_update_`wave'_`window'.dta", replace

        // Individual assignment: parent-level response rates, Control vs T1 only.
        foreach parent in mother father {
            use "$proc/weekly_update_`wave'_`window'.dta", clear
            if "`parent'" == "mother" keep if mother == 1
            if "`parent'" == "father" keep if mother == 0

            foreach g in C T1 {
                quietly summarize response_`wave' if `g' == 1
                local mu_i_`g'_`parent'_`wave'_`window' : display %6.3f r(mean)
                local N_i_`g'_`parent'_`wave'_`window' = r(N)
            }
            local s_i_T1_`parent'_`wave'_`window' ""

            preserve
            keep if C == 1 | T1 == 1
            capture noisily reg response_`wave' T1 i.strata_num i.enumerator_num, cluster(cluster_num)
            if !_rc & !missing(_se[T1]) {
                local p_i_T1_`parent'_`wave'_`window' = 2 * ttail(e(df_r), abs(_b[T1] / _se[T1]))
                if (`p_i_T1_`parent'_`wave'_`window'' < 0.1) local s_i_T1_`parent'_`wave'_`window' "*"
                if (`p_i_T1_`parent'_`wave'_`window'' < 0.05) local s_i_T1_`parent'_`wave'_`window' "**"
                if (`p_i_T1_`parent'_`wave'_`window'' < 0.01) local s_i_T1_`parent'_`wave'_`window' "***"
            }
            restore
        }

        // Family assignment: complete parent-pair families only, Control vs T1 only.
        foreach row in `fam_rows' {
            use "$proc/weekly_update_`wave'_`window'.dta", clear
            keep if family_row == 1 & pair_sample == 1

            if "`row'" == "mother" local y mother_response
            if "`row'" == "father" local y father_response
            if "`row'" == "om" local y only_mother
            if "`row'" == "of" local y only_father
            if "`row'" == "either" local y response_either
            if "`row'" == "both" local y response_both

            foreach g in C_fam T1_fam {
                quietly summarize `y' if `g' == 1
                local mu_`g'_`row'_`wave'_`window' : display %6.3f r(mean)
                local N_`g'_`row'_`wave'_`window' = r(N)
            }
            local s_T1_fam_`row'_`wave'_`window' ""

            preserve
            keep if C_fam == 1 | T1_fam == 1
            capture noisily reg `y' T1_fam i.strata_num i.enumerator_num, cluster(cluster_num)
            if !_rc & !missing(_se[T1_fam]) {
                local p_T1_fam_`row'_`wave'_`window' = 2 * ttail(e(df_r), abs(_b[T1_fam] / _se[T1_fam]))
                if (`p_T1_fam_`row'_`wave'_`window'' < 0.1) local s_T1_fam_`row'_`wave'_`window' "*"
                if (`p_T1_fam_`row'_`wave'_`window'' < 0.05) local s_T1_fam_`row'_`wave'_`window' "**"
                if (`p_T1_fam_`row'_`wave'_`window'' < 0.01) local s_T1_fam_`row'_`wave'_`window' "***"
            }
            restore
        }
    }

    // Individual assignment table: reminder and active windows side by side.
    file write latex "\begin{table}[htbp]" _n
    file write latex "\centering" _n
    file write latex "\begin{threeparttable}" _n
    file write latex "\caption{Weekly Response Monitoring: `wave' Survey, Individual Assignment}" _n
    file write latex "\begin{tabular}{lcccc}" _n
    file write latex "\toprule" _n
    file write latex "& \multicolumn{2}{c}{\textbf{Reminder Window}} & \multicolumn{2}{c}{\textbf{Active Survey Window}} \\" _n
    file write latex "\cmidrule(lr){2-3} \cmidrule(lr){4-5}" _n
    file write latex "\textbf{Parent} & \textbf{Control} & \textbf{T1} & \textbf{Control} & \textbf{T1} \\" _n
    file write latex "\midrule" _n
    file write latex "Mother & `mu_i_C_mother_`wave'_reminder' (`N_i_C_mother_`wave'_reminder') & `mu_i_T1_mother_`wave'_reminder'`s_i_T1_mother_`wave'_reminder' (`N_i_T1_mother_`wave'_reminder') & `mu_i_C_mother_`wave'_active' (`N_i_C_mother_`wave'_active') & `mu_i_T1_mother_`wave'_active'`s_i_T1_mother_`wave'_active' (`N_i_T1_mother_`wave'_active') \\" _n
    file write latex "Father & `mu_i_C_father_`wave'_reminder' (`N_i_C_father_`wave'_reminder') & `mu_i_T1_father_`wave'_reminder'`s_i_T1_father_`wave'_reminder' (`N_i_T1_father_`wave'_reminder') & `mu_i_C_father_`wave'_active' (`N_i_C_father_`wave'_active') & `mu_i_T1_father_`wave'_active'`s_i_T1_father_`wave'_active' (`N_i_T1_father_`wave'_active') \\" _n
    file write latex "\bottomrule" _n
    file write latex "\end{tabular}" _n
    file write latex "\begin{minipage}{0.8\textwidth}" _n
    file write latex "\begin{attritionnotes}" _n
    file write latex "Notes: The denominator is restricted to parents sent the `wave' survey on or after the corresponding sent-date cutoff. Cells report parent-level response rates, with parent N in parentheses. Stars test T1 against control. Regressions include strata and enumerator fixed effects and cluster standard errors by the project cluster variable. \$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
    file write latex "\end{attritionnotes}" _n
    file write latex "\end{minipage}" _n
    file write latex "\end{threeparttable}" _n
    file write latex "\end{table}" _n _n

    // Family assignment table: complete families only, reminder and active windows side by side.
    file write latex "\begin{table}[htbp]" _n
    file write latex "\centering" _n
    file write latex "\begin{threeparttable}" _n
    file write latex "\caption{Weekly Response Monitoring: `wave' Survey, Family Assignment}" _n
    file write latex "\begin{tabular}{lcccc}" _n
    file write latex "\toprule" _n
    file write latex "& \multicolumn{2}{c}{\textbf{Reminder Window}} & \multicolumn{2}{c}{\textbf{Active Survey Window}} \\" _n
    file write latex "\cmidrule(lr){2-3} \cmidrule(lr){4-5}" _n
    file write latex "\textbf{Outcome} & \textbf{Control} & \textbf{T1} & \textbf{Control} & \textbf{T1} \\" _n
    file write latex "\midrule" _n

    foreach row in `fam_rows' {
        file write latex "`label_`row'' & `mu_C_fam_`row'_`wave'_reminder' & `mu_T1_fam_`row'_`wave'_reminder'`s_T1_fam_`row'_`wave'_reminder' & `mu_C_fam_`row'_`wave'_active' & `mu_T1_fam_`row'_`wave'_active'`s_T1_fam_`row'_`wave'_active' \\" _n
    }

    file write latex "\midrule" _n
    file write latex "N (Family) & `N_C_fam_mother_`wave'_reminder' & `N_T1_fam_mother_`wave'_reminder' & `N_C_fam_mother_`wave'_active' & `N_T1_fam_mother_`wave'_active' \\" _n
    file write latex "\bottomrule" _n
    file write latex "\end{tabular}" _n
    file write latex "\begin{minipage}{0.8\textwidth}" _n
    file write latex "\begin{attritionnotes}" _n
    file write latex "Notes: The denominator is restricted to complete parent-pair families in which both parents were sent the `wave' survey on or after the corresponding sent-date cutoff. Mother and Father report parent-specific response rates within complete families; Only Mother, Only Father, Either, and Both report family-level response patterns. Stars test T1 against control. Regressions include strata and enumerator fixed effects and cluster standard errors by the project cluster variable. \$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
    file write latex "\end{attritionnotes}" _n
    file write latex "\end{minipage}" _n
    file write latex "\end{threeparttable}" _n
    file write latex "\end{table}" _n _n
}


//********************************************************************************//
// 2. FATHER IDENTITY RESPONSE MONITORING, 10M ONLY
//********************************************************************************//

local fam_rows mother father om of either both
local y_mother mother_response
local y_father father_response
local y_om only_mother
local y_of only_father
local y_either response_either
local y_both response_both

foreach window in active reminder {

    local lower_date "`active_cutoff_date'"
    if "`window'" == "reminder" local lower_date "`reminder_cutoff_date'"
    local window_title "Active Survey Window"
    if "`window'" == "reminder" local window_title "Reminder Window"

    use "`sent_dir'/10m_sent.dta", clear

    capture destring mother, replace
    capture destring group, replace

    drop if missing(family_id) | missing(mother)
    drop if family_id == "f2ddbf38"

    capture confirm variable sent_date
    if _rc {
        capture confirm numeric variable date
        if _rc {
            gen sent_date = daily(date, "YMD")
        }
        else {
            gen sent_date = date
        }
    }
    else {
        capture confirm numeric variable sent_date
        if _rc {
            gen double sent_date_num = daily(sent_date, "YMD")
            drop sent_date
            rename sent_date_num sent_date
        }
    }
    format sent_date %td

    keep if sent_date >= date("`lower_date'", "YMD")
    duplicates drop family_id mother, force

    tempfile sent10_`window'
    save `sent10_`window''

    use "`data_7m'", clear

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

    tempfile resp7_`window'
    save `resp7_`window''

    use "`data_10m'", clear

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

    tempfile resp10_`window'
    save `resp10_`window''

    use `sent10_`window'', clear

    merge 1:1 family_id mother using `resp7_`window''
    keep if _merge == 3
    drop _merge

    merge 1:1 family_id mother using `resp10_`window''
    drop if _merge == 2
    gen completed_10m = (_merge == 3)
    drop _merge

    merge m:1 family_id using "`cluster_map'"
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

    save "$proc/weekly_update_father_identity_`window'.dta", replace

    use "$proc/weekly_update_father_identity_`window'.dta", clear
    foreach parent in mother father {
        if "`parent'" == "mother" local pcond "mother == 1"
        if "`parent'" == "father" local pcond "mother == 0"

        quietly summarize completed_10m if `pcond' & infocon == 1
        local mu_i_c_`parent'_`window' : display %6.3f r(mean)
        local N_i_c_`parent'_`window' = r(N)

        quietly summarize completed_10m if `pcond' & randtreat == 1
        local mu_i_t_`parent'_`window' : display %6.3f r(mean)
        local N_i_t_`parent'_`window' = r(N)
        local s_i_t_`parent'_`window' ""

        preserve
        keep if `pcond'
        capture noisily reg completed_10m randtreat i.strata_num i.enumerator_num, cluster(cluster_num)
        if !_rc & !missing(_se[randtreat]) {
            local p_i_`parent'_`window' = 2 * ttail(e(df_r), abs(_b[randtreat] / _se[randtreat]))
            if (`p_i_`parent'_`window'' < 0.1) local s_i_t_`parent'_`window' "*"
            if (`p_i_`parent'_`window'' < 0.05) local s_i_t_`parent'_`window' "**"
            if (`p_i_`parent'_`window'' < 0.01) local s_i_t_`parent'_`window' "***"
        }
        restore
    }

    foreach row in `fam_rows' {
        use "$proc/weekly_update_father_identity_`window'.dta", clear
        keep if family_row == 1 & pair_sample == 1

        local y `y_`row''

        foreach g in mom_control dad_control mom_treat dad_treat f_treat m_treat both_treat both_control {
            quietly summarize `y' if `g' == 1
            local mu_`g'_`row'_`window' : display %6.3f r(mean)
            local N_`g'_`row'_`window' = r(N)
            local s_`g'_`row'_`window' ""
        }

        preserve
        keep if mom_control == 1 | mom_treat == 1
        capture noisily reg `y' mother_treat i.strata_num i.enumerator_num, cluster(cluster_num)
        if !_rc & !missing(_se[mother_treat]) {
            local p_mt_`row'_`window' = 2 * ttail(e(df_r), abs(_b[mother_treat] / _se[mother_treat]))
            if (`p_mt_`row'_`window'' < 0.1) local s_mom_treat_`row'_`window' "*"
            if (`p_mt_`row'_`window'' < 0.05) local s_mom_treat_`row'_`window' "**"
            if (`p_mt_`row'_`window'' < 0.01) local s_mom_treat_`row'_`window' "***"
        }
        restore

        preserve
        keep if dad_control == 1 | dad_treat == 1
        capture noisily reg `y' father_treat i.strata_num i.enumerator_num, cluster(cluster_num)
        if !_rc & !missing(_se[father_treat]) {
            local p_ft_`row'_`window' = 2 * ttail(e(df_r), abs(_b[father_treat] / _se[father_treat]))
            if (`p_ft_`row'_`window'' < 0.1) local s_dad_treat_`row'_`window' "*"
            if (`p_ft_`row'_`window'' < 0.05) local s_dad_treat_`row'_`window' "**"
            if (`p_ft_`row'_`window'' < 0.01) local s_dad_treat_`row'_`window' "***"
        }
        restore

        foreach g in f_treat m_treat both_treat {
            preserve
            keep if both_control == 1 | `g' == 1
            capture noisily reg `y' `g' i.strata_num i.enumerator_num, cluster(cluster_num)
            if !_rc & !missing(_se[`g']) {
                local p_`g'_`row'_`window' = 2 * ttail(e(df_r), abs(_b[`g'] / _se[`g']))
                if (`p_`g'_`row'_`window'' < 0.1) local s_`g'_`row'_`window' "*"
                if (`p_`g'_`row'_`window'' < 0.05) local s_`g'_`row'_`window' "**"
                if (`p_`g'_`row'_`window'' < 0.01) local s_`g'_`row'_`window' "***"
            }
            restore
        }
    }

    file write latex "\begin{table}[htbp]" _n
    file write latex "\centering" _n
    file write latex "\begin{threeparttable}" _n
    file write latex "\caption{Weekly Response Monitoring: Father Identity Individual Assignment, `window_title'}" _n
    file write latex "" _n
    file write latex "\begin{tabular*}{0.65\textwidth}{@{\extracolsep{\fill}}lcc@{}}" _n
    file write latex "\toprule" _n
    file write latex "\textbf{Parent} & \textbf{Control} & \textbf{Treat} \\" _n
    file write latex "\midrule" _n
    file write latex "Mother & `mu_i_c_mother_`window'' (`N_i_c_mother_`window'') & `mu_i_t_mother_`window''`s_i_t_mother_`window'' (`N_i_t_mother_`window'') \\" _n
    file write latex "Father & `mu_i_c_father_`window'' (`N_i_c_father_`window'') & `mu_i_t_father_`window''`s_i_t_father_`window'' (`N_i_t_father_`window'') \\" _n
    file write latex "\bottomrule" _n
    file write latex "\end{tabular*}" _n
    file write latex "\begin{minipage}{0.65\textwidth}" _n
    file write latex "\begin{attritionnotes}" _n
    file write latex " Notes: The sample is restricted to parents sent the 10m survey on or after `lower_date' who completed the 7m survey. Cells report the 10m completion rate, with parent N in parentheses. Stars test individual treatment against individual control within parent type. Regressions include strata and enumerator fixed effects and cluster standard errors by the project cluster variable. \$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
    file write latex "\end{attritionnotes}" _n
    file write latex "\end{minipage}" _n
    file write latex "\end{threeparttable}" _n
    file write latex "\end{table}" _n _n

    file write latex "\begin{table}[htbp]" _n
    file write latex "\centering" _n
    file write latex "\begin{threeparttable}" _n
    file write latex "\caption{Weekly Response Monitoring: Father Identity Family Assignment, `window_title'}" _n
    file write latex "\begin{tabular}{lcccccccc}" _n
    file write latex "\toprule" _n
    file write latex "& \multicolumn{2}{c}{\textbf{Control}} & \multicolumn{2}{c}{\textbf{Treat}} & \multicolumn{2}{c}{\textbf{Only Treat}} & \multicolumn{2}{c}{\textbf{Both}} \\" _n
    file write latex "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9}" _n
    file write latex "\textbf{Outcome} & \textbf{Mother} & \textbf{Father} & \textbf{Mother} & \textbf{Father} & \textbf{Mother} & \textbf{Father} & \textbf{Treat} & \textbf{Control} \\" _n
    file write latex "\midrule" _n

    foreach row in `fam_rows' {
        file write latex "`label_`row'' & `mu_mom_control_`row'_`window'' & `mu_dad_control_`row'_`window'' & `mu_mom_treat_`row'_`window''`s_mom_treat_`row'_`window'' & `mu_dad_treat_`row'_`window''`s_dad_treat_`row'_`window'' & `mu_m_treat_`row'_`window''`s_m_treat_`row'_`window'' & `mu_f_treat_`row'_`window''`s_f_treat_`row'_`window'' & `mu_both_treat_`row'_`window''`s_both_treat_`row'_`window'' & `mu_both_control_`row'_`window'' \\" _n
    }

    file write latex "\midrule" _n
    file write latex "N (Family) & `N_mom_control_mother_`window'' & `N_dad_control_mother_`window'' & `N_mom_treat_mother_`window'' & `N_dad_treat_mother_`window'' & `N_m_treat_mother_`window'' & `N_f_treat_mother_`window'' & `N_both_treat_mother_`window'' & `N_both_control_mother_`window'' \\" _n
    file write latex "\bottomrule" _n
    file write latex "\end{tabular}" _n
    file write latex "\begin{minipage}{\textwidth}" _n
    file write latex "\begin{attritionnotes}" _n
    file write latex "Notes: The sample is restricted to complete parent-pair families in which both parents were sent the 10m survey on or after `lower_date' and completed the 7m survey. The Control and Treat columns classify families by whether the mother or father was assigned to control or treatment; the Only Treat columns classify families in which only the mother or only the father was assigned to treatment. Stars in Mother Treat test against Mother Control; stars in Father Treat test against Father Control; stars in Mother Only Treat, Father Only Treat, and Both Treat test against Both Control. Regressions include strata and enumerator fixed effects and cluster standard errors by the project cluster variable. \$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
    file write latex "\end{attritionnotes}" _n
    file write latex "\end{minipage}" _n
    file write latex "\end{threeparttable}" _n
    file write latex "\end{table}" _n _n
}

file close latex
capture log close
