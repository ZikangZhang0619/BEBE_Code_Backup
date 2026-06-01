** Weekly Response Rate Update
** Author: Zikang Zhang
** Last rebuilt: 21 May, 2026

/*
Purpose:
    Produce weekly response-rate monitoring figures for 6m, 7m, and 10m surveys.

Design:
    - Use sent participant files as denominators.
    - Pool mothers/fathers and treatment groups.
    - For each invite date (sent_date), report cumulative response by:
        1 week  = sent_date + 8 days
        2 weeks = sent_date + 15 days
        3 weeks = sent_date + 22 days
        30 days = sent_date + 31 days
    - Only show a window once it has matured by the data cutoff date.

Outputs:
    $results/figures/weekly_response_6m.pdf
    $results/figures/weekly_response_7m.pdf
    $results/figures/weekly_response_10m.pdf
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

*** UPDATE THESE TWO DATES EACH WEEK **********************************************//
*** Keep invite dates on or after this date. This controls the leftmost date shown.
local sample_start_date "2025-03-01"   // <-- UPDATE MANUALLY EACH WEEK

*** Keep invite dates on or before this date. This controls the rightmost date shown.
*** It does not determine whether 1w/2w/3w/30d windows have matured.
local sample_end_date "2026-05-25"     // <-- UPDATE MANUALLY EACH WEEK
//********************************************************************************//

local waves 6m 7m 10m

local clean_data "$data"
if "`clean_data'" == "" {
    local clean_data "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/05_Cleaned anonymized data"
}

local sent_dir "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/06_Sent participants"

local figures_dir "$results/figures"
if "`figures_dir'" == "/figures" | "`figures_dir'" == "" {
    local figures_dir "/Users/zikangzhang/Library/CloudStorage/OneDrive-UniversitätZürichUZH/Anne Ardila Brenoe 的文件 - 08_BEBE/05_Code/2_Attrition Analysis/results/figures"
}

capture mkdir "`figures_dir'"

local data_6m  "`clean_data'/6m_20260525.dta"
local data_7m  "`clean_data'/7m_20260525.dta"
local data_10m "`clean_data'/10m_20260525.dta"

local sample_start = date("`sample_start_date'", "YMD")
local sample_end   = date("`sample_end_date'", "YMD")

if missing(`sample_start') {
    di as error "Please update local sample_start_date at the top of this do-file."
    exit 198
}

if missing(`sample_end') {
    di as error "Please update local sample_end_date at the top of this do-file."
    exit 198
}

set scheme s1color


//********************************************************************************//
// 1. POOLED RESPONSE-RATE MONITORING BY WAVE
//********************************************************************************//

foreach wave of local waves {

    di as txt "Processing weekly response monitoring for `wave'..."

    // ------------------------------------------------------------------------- //
    // 1.1 Prepare denominator: parents who were sent this wave's survey SMS
    // ------------------------------------------------------------------------- //
    use "`sent_dir'/`wave'_sent.dta", clear

    capture destring mother, replace
    drop if missing(family_id) | missing(mother)
    drop if family_id == "f2ddbf38"

    capture drop sent_day
    capture confirm numeric variable sent_date
    if _rc {
        gen double sent_day = daily(sent_date, "YMD")
    }
    else {
        local sentdate_fmt : format sent_date
        if strpos("`sentdate_fmt'", "%tc") {
            gen double sent_day = dofc(sent_date)
        }
        else {
            gen double sent_day = sent_date
        }
    }
    format sent_day %td
    confirm numeric variable sent_day

    keep if sent_day >= `sample_start'

    keep family_id mother sent_day
    rename sent_day sent_date
    duplicates drop family_id mother sent_date, force

    tempfile sent_`wave'
    save `sent_`wave''

    // ------------------------------------------------------------------------- //
    // 1.2 Prepare numerator: latest valid response per parent
    // ------------------------------------------------------------------------- //
    use "`data_`wave''", clear

    capture destring mother, replace
    drop if missing(family_id) | missing(mother)
    drop if family_id == "f2ddbf38"

    capture drop submit_dt_weekly submit_day
    gen double submit_day = .

    capture confirm variable submitdate
    if !_rc {
        capture confirm string variable submitdate
        if !_rc {
            gen double submit_dt_weekly = clock(submitdate, "YMDhms")
            replace submit_dt_weekly = clock(submitdate, "YMDhm") if missing(submit_dt_weekly)
            replace submit_day = dofc(submit_dt_weekly) if !missing(submit_dt_weekly)
        }
        else {
            local submitdate_fmt : format submitdate
            if strpos("`submitdate_fmt'", "%tc") {
                replace submit_day = dofc(submitdate) if missing(submit_day)
            }
            else {
                replace submit_day = submitdate if missing(submit_day)
            }
        }
    }

    capture confirm numeric variable submit_dt
    if !_rc {
        local submitdt_fmt : format submit_dt
        if strpos("`submitdt_fmt'", "%tc") {
            replace submit_day = dofc(submit_dt) if missing(submit_day)
        }
        else {
            replace submit_day = submit_dt if missing(submit_day)
        }
    }
    format submit_day %td
    confirm numeric variable submit_day

    quietly summarize submit_day
    local response_data_cutoff = r(max)

    gen byte submitted = !missing(submit_day)
    gsort family_id mother -submitted -submit_day
    by family_id mother: keep if _n == 1

    keep family_id mother submit_day

    tempfile resp_`wave'
    save `resp_`wave''

    // ------------------------------------------------------------------------- //
    // 1.3 Merge once, create response windows, and collapse by invite date
    // ------------------------------------------------------------------------- //
    use `sent_`wave'', clear

    merge m:1 family_id mother using `resp_`wave''
    drop if _merge == 2
    drop _merge

    confirm numeric variable sent_date
    confirm numeric variable submit_day

    gen double cutoff_1w  = sent_date + 8
    gen double cutoff_2w  = sent_date + 15
    gen double cutoff_3w  = sent_date + 22
    gen double cutoff_30d = sent_date + 31

    format cutoff_* %td

    gen byte responded_1w  = 0
    gen byte responded_2w  = 0
    gen byte responded_3w  = 0
    gen byte responded_30d = 0

    replace responded_1w  = 1 if submit_day < . & submit_day <= cutoff_1w
    replace responded_2w  = 1 if submit_day < . & submit_day <= cutoff_2w
    replace responded_3w  = 1 if submit_day < . & submit_day <= cutoff_3w
    replace responded_30d = 1 if submit_day < . & submit_day <= cutoff_30d

    gen byte sent_parent = 1

    collapse ///
        (sum) denom = sent_parent ///
              n_1w = responded_1w ///
              n_2w = responded_2w ///
              n_3w = responded_3w ///
              n_30d = responded_30d, ///
        by(sent_date)

    format sent_date %td
    sort sent_date

    // Restrict displayed invite dates only after response windows have been computed.
    keep if sent_date <= `sample_end'

    // Automatically detect which response windows have matured for each invite date.
    // This works for both current weekly updates and historical plots:
    // old invite dates will usually have all four points, while recent invite dates
    // will only show the windows that can be observed by the response data.
    gen byte mature_1w  = sent_date + 8  <= `response_data_cutoff'
    gen byte mature_2w  = sent_date + 15 <= `response_data_cutoff'
    gen byte mature_3w  = sent_date + 22 <= `response_data_cutoff'
    gen byte mature_30d = sent_date + 31 <= `response_data_cutoff'

    // Keep only invite dates for which at least the 1-week response rate is observable.
    // This ensures every x-axis date has at least one plotted point.
    drop if mature_1w == 0
    quietly count
    if r(N) == 0 {
        di as error "No invite date has matured to the 1-week window for `wave'. Skipping this wave."
        continue
    }

    foreach win in 1w 2w 3w 30d {
        replace n_`win' = . if mature_`win' == 0
        gen rate_`win' = n_`win' / denom
        gen str8 lab_`win' = ""
        replace lab_`win' = string(100 * rate_`win', "%4.1f") + "%" if mature_`win' == 1
    }

    // Use an equally spaced cohort index for plotting. The true invite date is
    // still used for sorting and x-axis labels.
    sort sent_date
    gen int x_order = _n

    tempfile weekly_`wave'_wide
    save `weekly_`wave'_wide', replace

    // ------------------------------------------------------------------------- //
    // 1.4 Prepare graph labels and graph data
    // ------------------------------------------------------------------------- //
    local xlabels ""
    quietly count
    local n_dates = r(N)
    local xmin = 0.5
    local xmax = `n_dates' + 0.8
    forvalues i = 1/`n_dates' {
        local xpos = x_order[`i']
        local dnum = sent_date[`i']
        local dstr : display %tdMon_DD `dnum'
        local dstr = subinstr("`dstr'", "_", " ", .)
        local denom_i = denom[`i']
        local xlabels `xlabels' `xpos' `"`"`dstr'"' `"(n=`denom_i')"'"'
    }

    preserve
        keep x_order sent_date rate_* lab_*
        reshape long rate_ lab_, i(x_order sent_date) j(window) string

        gen byte win_order = .
        replace win_order = 1 if window == "1w"
        replace win_order = 2 if window == "2w"
        replace win_order = 3 if window == "3w"
        replace win_order = 4 if window == "30d"

        label define win_lab 1 "1 week" 2 "2 weeks" 3 "3 weeks" 4 "30 days", replace
        label values win_order win_lab

        drop if missing(rate_)

        gen double label_rate = rate_
        replace label_rate = rate_ - 0.040 if win_order == 1
        replace label_rate = rate_ - 0.015 if win_order == 2
        replace label_rate = rate_ + 0.020 if win_order == 3
        replace label_rate = rate_ + 0.050 if win_order == 4
        replace label_rate = max(label_rate, 0.02)
        replace label_rate = min(label_rate, 1.03)

        twoway ///
            (connected rate_ x_order if win_order == 1, sort lcolor(navy) mcolor(navy) msymbol(O) lwidth(medthin)) ///
            (scatter   label_rate x_order if win_order == 1, mcolor(navy) msymbol(i) mlabel(lab_) mlabcolor(navy) mlabsize(tiny) mlabposition(0)) ///
            (connected rate_ x_order if win_order == 2, sort lcolor(orange) mcolor(orange) msymbol(D) lwidth(medthin)) ///
            (scatter   label_rate x_order if win_order == 2, mcolor(orange) msymbol(i) mlabel(lab_) mlabcolor(orange) mlabsize(tiny) mlabposition(0)) ///
            (connected rate_ x_order if win_order == 3, sort lcolor(forest_green) mcolor(forest_green) msymbol(T) lwidth(medthin)) ///
            (scatter   label_rate x_order if win_order == 3, mcolor(forest_green) msymbol(i) mlabel(lab_) mlabcolor(forest_green) mlabsize(tiny) mlabposition(0)) ///
            (connected rate_ x_order if win_order == 4, sort lcolor(purple) mcolor(purple) msymbol(S) lwidth(medthin)) ///
            (scatter   label_rate x_order if win_order == 4, mcolor(purple) msymbol(i) mlabel(lab_) mlabcolor(purple) mlabsize(tiny) mlabposition(0)), ///
            title("`wave' Survey Response Monitoring", size(medsmall)) ///
            ytitle("Cumulative response rate", margin(medium)) ///
            xtitle("Invite date", margin(medium)) ///
            ylabel(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%", angle(horizontal) labsize(small)) ///
            yscale(range(0 1.08)) ///
            xscale(range(`xmin' `xmax')) ///
            xlabel(`xlabels', angle(0) labsize(vsmall)) ///
            legend(order(1 "1 week" 3 "2 weeks" 5 "3 weeks" 7 "30 days") ///
                   rows(2) position(5) ring(0) size(vsmall) region(lcolor(none))) ///
            graphregion(color(white) margin(medium)) plotregion(color(white) margin(medium)) ///
            xsize(11.5) ysize(5.8)

        graph export "`figures_dir'/weekly_response_`wave'.pdf", replace
        graph export "`figures_dir'/weekly_response_`wave'.png", width(2400) replace
    restore
}

capture log close
