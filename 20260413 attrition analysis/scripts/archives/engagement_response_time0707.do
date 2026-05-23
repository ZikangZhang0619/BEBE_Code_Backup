*# HOW RESPONSE TIME IS CORRELATED WITH PARENTS ANSWERS' DIFFERENCE (ENGAGEMENT)

* Author: Haoyue Wu
* June25, 2025

* ================================================================== *
* The time period between receiving the sms and answering the survey *
* ================================================================== *

// 1m
import delimited using "$data/tokens_659371.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_826686.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_137936.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 4
save `4'

import delimited using "$data/tokens_839976.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 5
save `5'

import delimited using "$data/tokens_757445.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 6
save `6'

import delimited using "$data/tokens_644261.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 7
save `7'

import delimited using "$data/tokens_972288.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 8
save `8'

import delimited using "$data/tokens_563862.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 9
save `9'

import delimited using "$data/tokens_716853.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 10
save `10'

import delimited using "$data/tokens_477485.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 11
save `11'

import delimited using "$data/tokens_492913.csv", stringcol(_all) encoding("utf-8") clear
tempfile 12
save `12'

/* import delimited using "$data/tokens_727311.csv", stringcol(_all) encoding("utf-8") clear
tempfile 13
save `13' */

import delimited using "$data/tokens_477485.csv", stringcol(_all) encoding("utf-8") clear

append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force
append using `6' , force
append using `7' , force
append using `8' , force
append using `9' , force
append using `10' , force
append using `11' , force
append using `12' , force
/* append using `13' , force */
rename attribute_11住院号 hospital_id
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
gen mother = attribute_7母亲 == "Y"

drop email emailstatus token language usesleft attribute_* 
drop validuntil
drop invited

local vars validfrom completed
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

gen m1_delay_days = completed - validfrom
drop tid reminded firstname lastname validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m1_remindercount

duplicates drop hospital_id mother, force
drop if hospital_id == ""

gen m1_attrit = (m1_remindercount == 5 & m1_delay_days == .)
gen m1_complete = 1 - m1_attrit
drop m1_attrit

rename completed m1_complete_time
save "$proc/1m_response_time.dta", replace


// 2m

import delimited using "$data/tokens_643199.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_714695.csv",stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_795738.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_448999.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 4
save `4'

import delimited using "$data/tokens_162992.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 5
save `5'

import delimited using "$data/tokens_753661.csv",stringcol(_all)  encoding("UTF-8") clear
tempfile 6
save `6'

import delimited using "$data/tokens_669218.csv",stringcol(_all)  encoding("UTF-8") clear

append using `1' , force
append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force
append using `6', force

rename attribute_11住院号 hospital_id
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
gen mother = attribute_7母亲 == "Y"

drop email emailstatus token language usesleft attribute_* 
drop validuntil
drop invited

local vars validfrom completed
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

gen m2_delay_days = completed - validfrom
drop tid reminded firstname lastname validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m2_remindercount

duplicates drop hospital_id mother, force
drop if hospital_id == ""

gen m2_attrit = (m2_remindercount == 5 & m2_delay_days == .)
gen m2_complete = 1 - m2_attrit
drop m2_attrit
rename completed m2_complete_time
save "$proc/2m_response_time.dta", replace


// 3m

import delimited using "$data/tokens_573762.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_917974.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_567772.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_291237.csv", stringcol(_all) encoding("UTF-8") clear
append using `2' , force
append using `1' , force
append using `3', force

rename attribute_11住院号 hospital_id
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
gen mother = attribute_7母亲 == "Y"

drop email emailstatus token language usesleft attribute_* 
drop validuntil
drop invited

local vars validfrom completed
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

gen m3_delay_days = completed - validfrom
drop tid reminded firstname lastname validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m3_remindercount
duplicates drop hospital_id mother, force
drop if hospital_id == ""


gen m3_attrit = (m3_remindercount == 5 & m3_delay_days == .)
gen m3_complete = 1 - m3_attrit
drop m3_attrit
rename completed m3_complete_time
save "$proc/3m_response_time.dta", replace



// 6m

import delimited using "$data/tokens_975966.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 1
save `1'

import delimited using "$data/tokens_721796.csv", stringcol(_all) encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_948966.csv", stringcol(_all) encoding("UTF-8") clear
/* tempfile 3
save `3' */
append using `2' , force
append using `1' , force


rename attribute_11住院号 hospital_id
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
gen mother = attribute_7母亲 == "Y"

drop email emailstatus token language usesleft attribute_* 
drop validuntil
drop invited

local vars validfrom completed
foreach var in `vars'{
    gen `var'_temp = date(`var', "YMDhm")
    format `var'_temp %td
    drop `var'
    rename `var'_temp `var'
}

gen m6_delay_days = completed - validfrom
drop tid reminded firstname lastname validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m6_remindercount
duplicates drop hospital_id mother, force
drop if hospital_id == ""


gen m6_attrit = (m6_remindercount == 5 & m6_delay_days == .)
gen m6_complete = 1 - m6_attrit
drop m6_attrit
rename completed m6_complete_time
save "$proc/6m_response_time.dta", replace



* ==================================================
* MEASUREMENT OF PARTICIPANTS' ENGAGEMENT
* ==================================================

/* 
Measurement of parents' engagement
- baseline
    - expectation of father involvement 
    - belief
- 1m
    - father involvement
    - belief
    - baby-parent bonding (self and partner)
    - belief and simplified version 
- 2m
    - father involvement
    - disagreement with partner
    - maternal gatekeeping 
- 3m 
    - relationship satisfaction 
    - infant temperament
- 6m 
    - father involvement
    - relationship satisfaction

*/

use "$proc/baseline.dta", clear
drop submitdate_bl cutoff_date baby_female communication_quality employment_security social_desirability_score ability_mother belief_mother ability_father
drop father_identity_importance belief_father exp_father_involv attitude_full attitude_part1 attitude_part2 extra_time_belief
drop g05q03sq001

tempfile baseline
save `baseline'

use "$proc/1m.dta", clear
drop if hospital_id == ""

merge 1:1 hospital_id mother using `baseline'
drop if _merge == 1
/* gen response_1m = (_merge == 3) */
drop _merge 
tempfile 1m_bl
save `1m_bl'

use "$proc/2m.dta", clear
drop if hospital_id == ""
drop if m2_father_involv_score == .
duplicates drop hospital_id mother, force
merge 1:1 hospital_id mother using `1m_bl'
drop if _merge == 1
drop _merge 
tempfile 2m_1m_bl
save `2m_1m_bl'

use "$proc/6m.dta", clear
drop if hospital_id == ""
drop if m6_father_involv_score == .
duplicates drop hospital_id mother, force
merge 1:1 hospital_id mother using `2m_1m_bl'
drop if _merge == 1


order hospital_id mother date


drop _merge
merge 1:1 hospital_id mother using "$proc/1m_response_time.dta"
drop if _merge == 2
drop _merge

merge 1:1 hospital_id mother using "$proc/2m_response_time.dta"
drop if _merge == 2
drop _merge

merge 1:1 hospital_id mother using "$proc/3m_response_time.dta"
drop if _merge == 2
drop _merge

merge 1:1 hospital_id mother using "$proc/6m_response_time.dta"
drop if _merge == 2
drop _merge


local varlist m6_father_involv_score m2_father_involv_score m1_father_involv_score
    foreach var in `varlist'{
    sum `var' if treatment == 1  // Replace 'treatment' with your control treatment indicator
    scalar control_mean = r(mean)
    scalar control_sd = r(sd)

    // Standardize using control treatment parameters
    gen `var'_z = (`var' - control_mean) / control_sd
}

local varlist m6_father_involv_score_z m2_father_involv_score_z m1_father_involv_score_z
foreach var in `varlist'{
    gen mother_`var' = `var' if mother == 1
    bys hospital_id: replace mother_`var' = mother_`var'[_N]
}

local varlist m6_father_involv_score_z m2_father_involv_score_z m1_father_involv_score_z
foreach var in `varlist'{
    gen father_`var' = `var' if mother == 0
    bys hospital_id: replace father_`var' = father_`var'[1]
}

gen m1_weekday = dow(m1_complete_time)
gen m2_weekday = dow(m2_complete_time)
gen m3_weekday = dow(m3_complete_time)
gen m6_weekday = dow(m6_complete_time)

save "$proc/engagement_response_time.dta", replace


* ================================================================
* ===================   REGRESSION ANALYSIS    ===================
* ================================================================

use "$proc/engagement_response_time.dta", clear
// Clear previous estimates
estimates clear

// Function to determine significance stars
program define get_stars, rclass
    args pval
    if `pval' < 0.01 {
        return local stars "***"
    }
    else if `pval' < 0.05 {
        return local stars "**"
    }
    else if `pval' < 0.1 {
        return local stars "*"
    }
    else {
        return local stars ""
    }
end

// Full sample regressions - Mother reported father involvement
quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.treatment i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local full_mother_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local full_mother_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local full_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `full_mother_m_pval'
local full_mother_m_stars = r(stars)
local full_mother_m_n = e(N)

quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.treatment i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local full_father_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local full_father_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local full_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `full_father_m_pval'
local full_father_m_stars = r(stars)
local full_father_m_n = e(N)

// Full sample regressions - Father reported father involvement
quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.treatment i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local full_mother_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local full_mother_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local full_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `full_mother_f_pval'
local full_mother_f_stars = r(stars)
local full_mother_f_n = e(N)

quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.treatment i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local full_father_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local full_father_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local full_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `full_father_f_pval'
local full_father_f_stars = r(stars)
local full_father_f_n = e(N)

// Treatment 1 regressions
preserve 
keep if treatment == 1

quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local c_mother_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local c_mother_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local c_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `c_mother_m_pval'
local c_mother_m_stars = r(stars)
local c_mother_m_n = e(N)

quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local c_father_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local c_father_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local c_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `c_father_m_pval'
local c_father_m_stars = r(stars)
local c_father_m_n = e(N)

quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local c_mother_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local c_mother_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local c_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `c_mother_f_pval'
local c_mother_f_stars = r(stars)
local c_mother_f_n = e(N)

quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local c_father_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local c_father_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local c_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `c_father_f_pval'
local c_father_f_stars = r(stars)
local c_father_f_n = e(N)

restore

// Treatment 2 regressions
preserve 
keep if treatment == 2

quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t1_mother_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local t1_mother_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local t1_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `t1_mother_m_pval'
local t1_mother_m_stars = r(stars)
local t1_mother_m_n = e(N)

quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t1_father_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local t1_father_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local t1_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `t1_father_m_pval'
local t1_father_m_stars = r(stars)
local t1_father_m_n = e(N)

quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t1_mother_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local t1_mother_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local t1_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `t1_mother_f_pval'
local t1_mother_f_stars = r(stars)
local t1_mother_f_n = e(N)

quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t1_father_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local t1_father_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local t1_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `t1_father_f_pval'
local t1_father_f_stars = r(stars)
local t1_father_f_n = e(N)

restore

// Treatment 3 regressions
preserve 
keep if treatment == 3

quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t2_mother_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local t2_mother_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local t2_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `t2_mother_m_pval'
local t2_mother_m_stars = r(stars)
local t2_mother_m_n = e(N)

quietly reg m1_delay_days mother_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t2_father_m_coef = string(_b[mother_m1_father_involv_score_z], "%9.3f")
local t2_father_m_se = string(_se[mother_m1_father_involv_score_z], "%9.3f")
local t2_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m1_father_involv_score_z]/_se[mother_m1_father_involv_score_z]))
get_stars `t2_father_m_pval'
local t2_father_m_stars = r(stars)
local t2_father_m_n = e(N)

quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t2_mother_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local t2_mother_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local t2_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `t2_mother_f_pval'
local t2_mother_f_stars = r(stars)
local t2_mother_f_n = e(N)

quietly reg m1_delay_days father_m1_father_involv_score_z i.m1_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t2_father_f_coef = string(_b[father_m1_father_involv_score_z], "%9.3f")
local t2_father_f_se = string(_se[father_m1_father_involv_score_z], "%9.3f")
local t2_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m1_father_involv_score_z]/_se[father_m1_father_involv_score_z]))
get_stars `t2_father_f_pval'
local t2_father_f_stars = r(stars)
local t2_father_f_n = e(N)

restore

// Generate LaTeX table (transposed)
file open latextable using "$results/tables/father_involvement_table.tex", write replace

file write latextable "\begin{table}[htbp]" _n
file write latextable "\centering" _n
file write latextable "\caption{Effect of Father Involvement on M1 Delay Days}" _n
file write latextable "\label{tab:father_involvement}" _n
file write latextable "\begin{tabular}{lcccc|cccc}" _n
file write latextable "\hline\hline" _n
file write latextable " & \multicolumn{4}{c|}{Mothers (M1 Delay Days)} & \multicolumn{4}{c}{Fathers (M1 Delay Days)} \\" _n
file write latextable " & Full & C & T1 & T2 & Full & C & T1 & T2 \\" _n
file write latextable "\hline" _n

// Mother-reported father involvement
file write latextable "Mother-reported & `full_mother_m_coef'`full_mother_m_stars' & `c_mother_m_coef'`c_mother_m_stars' & `t1_mother_m_coef'`t1_mother_m_stars' & `t2_mother_m_coef'`t2_mother_m_stars' & `full_father_m_coef'`full_father_m_stars' & `c_father_m_coef'`c_father_m_stars' & `t1_father_m_coef'`t1_father_m_stars' & `t2_father_m_coef'`t2_father_m_stars' \\" _n
file write latextable "Father Involvement & (`full_mother_m_se') & (`c_mother_m_se') & (`t1_mother_m_se') & (`t2_mother_m_se') & (`full_father_m_se') & (`c_father_m_se') & (`t1_father_m_se') & (`t2_father_m_se') \\" _n
file write latextable " & [`full_mother_m_n'] & [`c_mother_m_n'] & [`t1_mother_m_n'] & [`t2_mother_m_n'] & [`full_father_m_n'] & [`c_father_m_n'] & [`t1_father_m_n'] & [`t2_father_m_n'] \\" _n

file write latextable "\hline" _n

// Father-reported father involvement
file write latextable "Father-reported & `full_mother_f_coef'`full_mother_f_stars' & `c_mother_f_coef'`c_mother_f_stars' & `t1_mother_f_coef'`t1_mother_f_stars' & `t2_mother_f_coef'`t2_mother_f_stars' & `full_father_f_coef'`full_father_f_stars' & `c_father_f_coef'`c_father_f_stars' & `t1_father_f_coef'`t1_father_f_stars' & `t2_father_f_coef'`t2_father_f_stars' \\" _n
file write latextable "Father Involvement & (`full_mother_f_se') & (`c_mother_f_se') & (`t1_mother_f_se') & (`t2_mother_f_se') & (`full_father_f_se') & (`c_father_f_se') & (`t1_father_f_se') & (`t2_father_f_se') \\" _n
file write latextable " & [`full_mother_f_n'] & [`c_mother_f_n'] & [`t1_mother_f_n'] & [`t2_mother_f_n'] & [`full_father_f_n'] & [`c_father_f_n'] & [`t1_father_f_n'] & [`t2_father_f_n'] \\" _n

file write latextable "\hline\hline" _n
file write latextable "\end{tabular}" _n
file write latextable "\begin{flushleft}" _n
file write latextable "{\footnotesize Notes: This table shows the effect of father involvement (z-score) on M1 delay days." _n
file write latextable "Standard errors clustered at the cluster level are shown in parentheses, observations in brackets." _n
file write latextable "Left panel shows results for mothers, right panel shows results for fathers." _n
file write latextable "*** p$<$0.01, ** p$<$0.05, * p$<$0.1." _n
file write latextable "All regressions include weekday, treatment, strata, and enumerator fixed effects." _n
file write latextable "T1, T2, and T3 refer to treatment groups 1, 2, and 3 respectively.}" _n
file write latextable "\end{flushleft}" _n
file write latextable "\end{table}" _n

file close latextable

display "LaTeX table saved as father_involvement_table.tex"




// Full sample regressions - Mother reported father involvement
quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.treatment i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local full_mother_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local full_mother_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local full_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `full_mother_m_pval'
local full_mother_m_stars = r(stars)
local full_mother_m_n = e(N)

quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.treatment i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local full_father_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local full_father_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local full_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `full_father_m_pval'
local full_father_m_stars = r(stars)
local full_father_m_n = e(N)

// Full sample regressions - Father reported father involvement
quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.treatment i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local full_mother_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local full_mother_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local full_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `full_mother_f_pval'
local full_mother_f_stars = r(stars)
local full_mother_f_n = e(N)

quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.treatment i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local full_father_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local full_father_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local full_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `full_father_f_pval'
local full_father_f_stars = r(stars)
local full_father_f_n = e(N)

// Treatment 1 regressions
preserve 
keep if treatment == 1

quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local c_mother_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local c_mother_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local c_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `c_mother_m_pval'
local c_mother_m_stars = r(stars)
local c_mother_m_n = e(N)

quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local c_father_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local c_father_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local c_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `c_father_m_pval'
local c_father_m_stars = r(stars)
local c_father_m_n = e(N)

quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local c_mother_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local c_mother_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local c_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `c_mother_f_pval'
local c_mother_f_stars = r(stars)
local c_mother_f_n = e(N)

quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local c_father_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local c_father_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local c_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `c_father_f_pval'
local c_father_f_stars = r(stars)
local c_father_f_n = e(N)

restore

// Treatment 2 regressions
preserve 
keep if treatment == 2

quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t1_mother_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local t1_mother_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local t1_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `t1_mother_m_pval'
local t1_mother_m_stars = r(stars)
local t1_mother_m_n = e(N)

quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t1_father_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local t1_father_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local t1_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `t1_father_m_pval'
local t1_father_m_stars = r(stars)
local t1_father_m_n = e(N)

quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t1_mother_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local t1_mother_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local t1_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `t1_mother_f_pval'
local t1_mother_f_stars = r(stars)
local t1_mother_f_n = e(N)

quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t1_father_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local t1_father_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local t1_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `t1_father_f_pval'
local t1_father_f_stars = r(stars)
local t1_father_f_n = e(N)

restore

// Treatment 3 regressions
preserve 
keep if treatment == 3

quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t2_mother_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local t2_mother_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local t2_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `t2_mother_m_pval'
local t2_mother_m_stars = r(stars)
local t2_mother_m_n = e(N)

quietly reg m2_delay_days mother_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t2_father_m_coef = string(_b[mother_m2_father_involv_score_z], "%9.3f")
local t2_father_m_se = string(_se[mother_m2_father_involv_score_z], "%9.3f")
local t2_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m2_father_involv_score_z]/_se[mother_m2_father_involv_score_z]))
get_stars `t2_father_m_pval'
local t2_father_m_stars = r(stars)
local t2_father_m_n = e(N)

quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t2_mother_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local t2_mother_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local t2_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `t2_mother_f_pval'
local t2_mother_f_stars = r(stars)
local t2_mother_f_n = e(N)

quietly reg m2_delay_days father_m2_father_involv_score_z i.m2_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t2_father_f_coef = string(_b[father_m2_father_involv_score_z], "%9.3f")
local t2_father_f_se = string(_se[father_m2_father_involv_score_z], "%9.3f")
local t2_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m2_father_involv_score_z]/_se[father_m2_father_involv_score_z]))
get_stars `t2_father_f_pval'
local t2_father_f_stars = r(stars)
local t2_father_f_n = e(N)

restore

// Generate LaTeX table (transposed)
file open latextable using "$results/tables/father_involvement_table.tex", write append

file write latextable "\begin{table}[htbp]" _n
file write latextable "\centering" _n
file write latextable "\caption{Effect of Father Involvement on M1 Delay Days}" _n
file write latextable "\label{tab:father_involvement}" _n
file write latextable "\begin{tabular}{lcccc|cccc}" _n
file write latextable "\hline\hline" _n
file write latextable " & \multicolumn{4}{c|}{Mothers (M1 Delay Days)} & \multicolumn{4}{c}{Fathers (M1 Delay Days)} \\" _n
file write latextable " & Full & C & T1 & T2 & Full & C & T1 & T2 \\" _n
file write latextable "\hline" _n

// Mother-reported father involvement
file write latextable "Mother-reported & `full_mother_m_coef'`full_mother_m_stars' & `c_mother_m_coef'`c_mother_m_stars' & `t1_mother_m_coef'`t1_mother_m_stars' & `t2_mother_m_coef'`t2_mother_m_stars' & `full_father_m_coef'`full_father_m_stars' & `c_father_m_coef'`c_father_m_stars' & `t1_father_m_coef'`t1_father_m_stars' & `t2_father_m_coef'`t2_father_m_stars' \\" _n
file write latextable "Father Involvement & (`full_mother_m_se') & (`c_mother_m_se') & (`t1_mother_m_se') & (`t2_mother_m_se') & (`full_father_m_se') & (`c_father_m_se') & (`t1_father_m_se') & (`t2_father_m_se') \\" _n
file write latextable " & [`full_mother_m_n'] & [`c_mother_m_n'] & [`t1_mother_m_n'] & [`t2_mother_m_n'] & [`full_father_m_n'] & [`c_father_m_n'] & [`t1_father_m_n'] & [`t2_father_m_n'] \\" _n

file write latextable "\hline" _n

// Father-reported father involvement
file write latextable "Father-reported & `full_mother_f_coef'`full_mother_f_stars' & `c_mother_f_coef'`c_mother_f_stars' & `t1_mother_f_coef'`t1_mother_f_stars' & `t2_mother_f_coef'`t2_mother_f_stars' & `full_father_f_coef'`full_father_f_stars' & `c_father_f_coef'`c_father_f_stars' & `t1_father_f_coef'`t1_father_f_stars' & `t2_father_f_coef'`t2_father_f_stars' \\" _n
file write latextable "Father Involvement & (`full_mother_f_se') & (`c_mother_f_se') & (`t1_mother_f_se') & (`t2_mother_f_se') & (`full_father_f_se') & (`c_father_f_se') & (`t1_father_f_se') & (`t2_father_f_se') \\" _n
file write latextable " & [`full_mother_f_n'] & [`c_mother_f_n'] & [`t1_mother_f_n'] & [`t2_mother_f_n'] & [`full_father_f_n'] & [`c_father_f_n'] & [`t1_father_f_n'] & [`t2_father_f_n'] \\" _n

file write latextable "\hline\hline" _n
file write latextable "\end{tabular}" _n
file write latextable "\begin{flushleft}" _n
file write latextable "{\footnotesize Notes: This table shows the effect of father involvement (z-score) on M1 delay days." _n
file write latextable "Standard errors clustered at the cluster level are shown in parentheses, observations in brackets." _n
file write latextable "Left panel shows results for mothers, right panel shows results for fathers." _n
file write latextable "*** p$<$0.01, ** p$<$0.05, * p$<$0.1." _n
file write latextable "All regressions include weekday, treatment, strata, and enumerator fixed effects." _n
file write latextable "T1, T2, and T3 refer to treatment groups 1, 2, and 3 respectively.}" _n
file write latextable "\end{flushleft}" _n
file write latextable "\end{table}" _n

file close latextable

display "LaTeX table saved as father_involvement_table.tex"




// Full sample regressions - Mother reported father involvement
quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.treatment i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local full_mother_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local full_mother_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local full_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `full_mother_m_pval'
local full_mother_m_stars = r(stars)
local full_mother_m_n = e(N)

quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.treatment i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local full_father_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local full_father_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local full_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `full_father_m_pval'
local full_father_m_stars = r(stars)
local full_father_m_n = e(N)

// Full sample regressions - Father reported father involvement
quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.treatment i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local full_mother_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local full_mother_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local full_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `full_mother_f_pval'
local full_mother_f_stars = r(stars)
local full_mother_f_n = e(N)

quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.treatment i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local full_father_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local full_father_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local full_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `full_father_f_pval'
local full_father_f_stars = r(stars)
local full_father_f_n = e(N)

// Treatment 1 regressions
preserve 
keep if treatment == 1

quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local c_mother_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local c_mother_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local c_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `c_mother_m_pval'
local c_mother_m_stars = r(stars)
local c_mother_m_n = e(N)

quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local c_father_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local c_father_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local c_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `c_father_m_pval'
local c_father_m_stars = r(stars)
local c_father_m_n = e(N)

quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local c_mother_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local c_mother_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local c_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `c_mother_f_pval'
local c_mother_f_stars = r(stars)
local c_mother_f_n = e(N)

quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local c_father_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local c_father_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local c_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `c_father_f_pval'
local c_father_f_stars = r(stars)
local c_father_f_n = e(N)

restore

// Treatment 2 regressions
preserve 
keep if treatment == 2

quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t1_mother_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local t1_mother_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local t1_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `t1_mother_m_pval'
local t1_mother_m_stars = r(stars)
local t1_mother_m_n = e(N)

quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t1_father_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local t1_father_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local t1_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `t1_father_m_pval'
local t1_father_m_stars = r(stars)
local t1_father_m_n = e(N)

quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t1_mother_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local t1_mother_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local t1_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `t1_mother_f_pval'
local t1_mother_f_stars = r(stars)
local t1_mother_f_n = e(N)

quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t1_father_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local t1_father_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local t1_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `t1_father_f_pval'
local t1_father_f_stars = r(stars)
local t1_father_f_n = e(N)

restore

// Treatment 3 regressions
preserve 
keep if treatment == 3

quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t2_mother_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local t2_mother_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local t2_mother_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `t2_mother_m_pval'
local t2_mother_m_stars = r(stars)
local t2_mother_m_n = e(N)

quietly reg m6_delay_days mother_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t2_father_m_coef = string(_b[mother_m6_father_involv_score_z], "%9.3f")
local t2_father_m_se = string(_se[mother_m6_father_involv_score_z], "%9.3f")
local t2_father_m_pval = 2*ttail(e(df_r), abs(_b[mother_m6_father_involv_score_z]/_se[mother_m6_father_involv_score_z]))
get_stars `t2_father_m_pval'
local t2_father_m_stars = r(stars)
local t2_father_m_n = e(N)

quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 1, cluster(cluster_var)
local t2_mother_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local t2_mother_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local t2_mother_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `t2_mother_f_pval'
local t2_mother_f_stars = r(stars)
local t2_mother_f_n = e(N)

quietly reg m6_delay_days father_m6_father_involv_score_z i.m6_weekday i.strata i.enumerator_id if mother == 0, cluster(cluster_var)
local t2_father_f_coef = string(_b[father_m6_father_involv_score_z], "%9.3f")
local t2_father_f_se = string(_se[father_m6_father_involv_score_z], "%9.3f")
local t2_father_f_pval = 2*ttail(e(df_r), abs(_b[father_m6_father_involv_score_z]/_se[father_m6_father_involv_score_z]))
get_stars `t2_father_f_pval'
local t2_father_f_stars = r(stars)
local t2_father_f_n = e(N)

restore

// Generate LaTeX table (transposed)
file open latextable using "$results/tables/father_involvement_table.tex", write append

file write latextable "\begin{table}[htbp]" _n
file write latextable "\centering" _n
file write latextable "\caption{Effect of Father Involvement on M1 Delay Days}" _n
file write latextable "\label{tab:father_involvement}" _n
file write latextable "\begin{tabular}{lcccc|cccc}" _n
file write latextable "\hline\hline" _n
file write latextable " & \multicolumn{4}{c|}{Mothers (M1 Delay Days)} & \multicolumn{4}{c}{Fathers (M1 Delay Days)} \\" _n
file write latextable " & Full & C & T1 & T2 & Full & C & T1 & T2 \\" _n
file write latextable "\hline" _n

// Mother-reported father involvement
file write latextable "Mother-reported & `full_mother_m_coef'`full_mother_m_stars' & `c_mother_m_coef'`c_mother_m_stars' & `t1_mother_m_coef'`t1_mother_m_stars' & `t2_mother_m_coef'`t2_mother_m_stars' & `full_father_m_coef'`full_father_m_stars' & `c_father_m_coef'`c_father_m_stars' & `t1_father_m_coef'`t1_father_m_stars' & `t2_father_m_coef'`t2_father_m_stars' \\" _n
file write latextable "Father Involvement & (`full_mother_m_se') & (`c_mother_m_se') & (`t1_mother_m_se') & (`t2_mother_m_se') & (`full_father_m_se') & (`c_father_m_se') & (`t1_father_m_se') & (`t2_father_m_se') \\" _n
file write latextable " & [`full_mother_m_n'] & [`c_mother_m_n'] & [`t1_mother_m_n'] & [`t2_mother_m_n'] & [`full_father_m_n'] & [`c_father_m_n'] & [`t1_father_m_n'] & [`t2_father_m_n'] \\" _n

file write latextable "\hline" _n

// Father-reported father involvement
file write latextable "Father-reported & `full_mother_f_coef'`full_mother_f_stars' & `c_mother_f_coef'`c_mother_f_stars' & `t1_mother_f_coef'`t1_mother_f_stars' & `t2_mother_f_coef'`t2_mother_f_stars' & `full_father_f_coef'`full_father_f_stars' & `c_father_f_coef'`c_father_f_stars' & `t1_father_f_coef'`t1_father_f_stars' & `t2_father_f_coef'`t2_father_f_stars' \\" _n
file write latextable "Father Involvement & (`full_mother_f_se') & (`c_mother_f_se') & (`t1_mother_f_se') & (`t2_mother_f_se') & (`full_father_f_se') & (`c_father_f_se') & (`t1_father_f_se') & (`t2_father_f_se') \\" _n
file write latextable " & [`full_mother_f_n'] & [`c_mother_f_n'] & [`t1_mother_f_n'] & [`t2_mother_f_n'] & [`full_father_f_n'] & [`c_father_f_n'] & [`t1_father_f_n'] & [`t2_father_f_n'] \\" _n

file write latextable "\hline\hline" _n
file write latextable "\end{tabular}" _n
file write latextable "\begin{flushleft}" _n
file write latextable "{\footnotesize Notes: This table shows the effect of father involvement (z-score) on M1 delay days." _n
file write latextable "Standard errors clustered at the cluster level are shown in parentheses, observations in brackets." _n
file write latextable "Left panel shows results for mothers, right panel shows results for fathers." _n
file write latextable "*** p$<$0.01, ** p$<$0.05, * p$<$0.1." _n
file write latextable "All regressions include weekday, treatment, strata, and enumerator fixed effects." _n
file write latextable "T1, T2, and T3 refer to treatment groups 1, 2, and 3 respectively.}" _n
file write latextable "\end{flushleft}" _n
file write latextable "\end{table}" _n

file close latextable

display "LaTeX table saved as father_involvement_table.tex"