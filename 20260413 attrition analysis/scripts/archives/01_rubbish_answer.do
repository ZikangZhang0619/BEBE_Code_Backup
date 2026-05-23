
*****************************
/* Attrition Analysis - Rubbish Answer
   
   ** 

   ** Author: Haoyue Wu
   ** Date Updated: 2025-06-09
   */


************* log *************


////////////////////////////////////////////////////////
************************** 1m **************************
////////////////////////////////////////////////////////

// ------------------- //
// 1m complete results //
// ------------------- //


import delimited using "$data/results-survey659371.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "659371"

tempfile part1
save `part1'

import delimited using "$data/results-survey826686.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "826686"


tempfile part2
save `part2'

import delimited using "$data/results-survey137936.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "137936"


tempfile part3
save `part3'

import delimited using "$data/results-survey839976.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "839976"

tempfile part4
save `part4'

import delimited using "$data/results-survey757445.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "757445"

tempfile part5
save `part5'

import delimited using "$data/results-survey644261.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "644261"


tempfile part6
save `part6'

import delimited using "$data/results-survey972288.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "972288"


tempfile part7
save `part7'

import delimited using "$data/results-survey716853.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "716853"


tempfile part8
save `part8'

import delimited using "$data/results-survey563862.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "563862"

tempfile part9
save `part9'

import delimited using "$data/results-survey477485.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "477485"
tempfile part10
save `part10'

import delimited using "$data/results-survey727311.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "727311"

tempfile part11
save `part11'

import delimited using "$data/results-survey492913.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "492913"


append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force
append using `part7', force
append using `part8', force
append using `part9', force
append using `part10', force
append using `part11', force


drop if submitdate == ""
rename attribute_11 hospital_id
keep firstname lastname hospital_id submitdate startdate interviewtime grouptime* attribute_* survey_id
destring interviewtime grouptime*, replace

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if firstname == ""

duplicates report firstname
duplicates drop firstname, force

gen short_survey = (survey_id == "727311" | survey_id == "492913")

su interviewtime if short_survey == 0, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
gen valid_answer = interviewtime >= r(p5) if short_survey == 0
gen duration_min = interviewtime / 60

su interviewtime if short_survey == 1, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
replace valid_answer = interviewtime >= r(p5) if short_survey == 1

tab valid_answer if short_survey == 1


winsor duration_min, gen(duration_min_winsor) p(0.01)

su duration_min_winsor, detail
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min_winsor, fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 1m Survey Valid Answers (winsorized at 1%)") ///
    xlabel(0(5)50) ///
    ylabel(0(3)15) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    name(graph1, replace)

graph export "$proc/rubbish_1m_duration.pdf", replace
gen rubbish_answer = (valid_answer == 0)
save "$proc/rubbish_1m_results.dta", replace    





/////////////////////////////////////////////////////////////////////////
************************************* 2m ********************************
/////////////////////////////////////////////////////////////////////////


// ------------------- //
// 2m complete results //
// ------------------- //

import delimited using "$data/results-survey643199.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "643199"


rename attribute_11 hospital_id

tempfile part1
save `part1'


import delimited using "$data/results-survey714695.csv",stringcol(_all) encoding("utf-8") clear
gen survey_id = "714695"


rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey795738.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "795738"


rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey448999.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "448999"


rename attribute_11 hospital_id

tempfile part4
save `part4'

import delimited using "$data/results-survey162992.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "162992"


rename attribute_11 hospital_id

tempfile part5
save `part5'

import delimited using "$data/results-survey753661.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "753661"


tempfile part6 
save `part6'

import delimited using "$data/results-survey669218.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "669218"


rename attribute_11 hospital_id

append using `part1', force
append using `part2', force
append using `part3', force
append using `part4', force
append using `part5', force
append using `part6', force
gen online_results = 1

drop if submitdate == ""
replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
duplicates drop firstname, force
tempfile online_results
save `online_results'




//------------------ 6w ------------------//

import delimited using "$data/results-survey184411.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "184411"

rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_1
save `6w_1'

import delimited using "$data/results-survey191613.csv",stringcol(_all) encoding("utf-8") clear
gen survey_id = "191613"

rename g00q01sq001 hospital_id
rename g00q02 parent

tempfile 6w_2
save `6w_2'

import delimited using "$data/results-survey815998.csv",stringcol(_all) encoding("utf-8") clear
gen survey_id = "815998"

rename g00q01sq001 hospital_id

tempfile 6w_3
save `6w_3'

import delimited using "$data/results-survey265968.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "265968"

rename g00q01sq001 hospital_id
tempfile 6w_4
save `6w_4'

import delimited using "$data/results-survey924349.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "924349"

rename g00q01sq001 hospital_id

rename g00q02 parent
append using `6w_1'
append using `6w_2'
append using `6w_3'
append using `6w_4'
replace parent = g00q02 if parent == ""

drop if submitdate == ""
preserve
keep if parent == "爸爸"
rename (fphone fname)(firstname lastname)
tempfile father 
save `father'
restore

keep if parent == "妈妈"
rename (mphone mname)(firstname lastname)
append using `father'

tostring hospital_id, replace
gen onsite_results = 1
append using `online_results'


replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

drop if firstname == ""
duplicates drop firstname, force

keep firstname lastname hospital_id submitdate startdate interviewtime grouptime* attribute_* group parent online_results onsite_results survey_id
destring interviewtime grouptime*, replace

order interviewtime grouptime*
replace interviewtime = interviewtime - grouptime2131 if grouptime2131 != .
replace interviewtime = interviewtime - grouptime1773 if grouptime1773 != .
replace interviewtime = interviewtime - grouptime1740 if grouptime1740 != .
replace interviewtime = interviewtime - grouptime1992 if grouptime1992 != .
replace interviewtime = interviewtime - grouptime2145 if grouptime2145 != .


su interviewtime, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
gen valid_answer = interviewtime >= r(p5)
gen duration_min = interviewtime / 60
winsor duration_min, gen(duration_min_winsor) p(0.01)

/* . display "5th percentile: " r(p5)
5th percentile: 227.92

. display "95th percentile: " r(p95)
95th percentile: 1403.96 */


su duration_min, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min_winsor, fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 2m Survey Valid Answers (winsorized at 1%)") ///
    xlabel(0(5)50) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    ylabel(#6) ///
    name(graph1, replace)

graph export "$proc/rubbish_2m_duration.pdf", replace
gen rubbish_answer = (valid_answer == 0)
save "$proc/rubbish_2m_results.dta", replace


/////////////////////////////////////////////////////////////////////////
************************************* 3m ********************************
/////////////////////////////////////////////////////////////////////////



// ------------------- //
// 3m complete results //
// ------------------- //



import delimited using "$data/results-survey573762.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "573762"


rename attribute_11 hospital_id

tempfile part1
save `part1'

import delimited using "$data/results-survey917974.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "917974"


rename attribute_11 hospital_id

tempfile part2
save `part2'

import delimited using "$data/results-survey567772.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "567772"


rename attribute_11 hospital_id

tempfile part3
save `part3'

import delimited using "$data/results-survey291237.csv", stringcol(_all) encoding("utf-8") clear
gen survey_id = "291237"

rename attribute_11 hospital_id

tempfile part4
save `part4'

append using `part1', force
append using `part2', force
append using `part3', force


drop if submitdate == ""
keep firstname lastname hospital_id submitdate startdate interviewtime grouptime* attribute_* survey_id
destring interviewtime grouptime*, replace

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if firstname == ""

duplicates report firstname
duplicates drop firstname, force

su interviewtime, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
gen valid_answer = interviewtime >= r(p5)
gen duration_min = interviewtime / 60
winsor duration_min, gen(duration_min_winsor) p(0.01)

su duration_min, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min_winsor, fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 3m Survey Valid Answers (winsorized at 1%)") ///
    xlabel(0(5)45) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    ylabel(#6) ///
    name(graph1, replace)

graph export "$proc/rubbish_3m_duration.pdf", replace
gen rubbish_answer = (valid_answer == 0)
save "$proc/rubbish_3m_results.dta", replace







/////////////////////////////////////////////////////////////////////////
************************************* 6m ********************************
/////////////////////////////////////////////////////////////////////////


// ------------------- //
// 6m complete results //
// ------------------- //


import delimited using "$data/results-survey975966.csv", stringcol(_all) encoding("UTF-8") clear
rename attribute_11 hospital_id
gen survey_id = "975966"
tempfile part1
save `part1'

import delimited using "$data/results-survey721796.csv",stringcol(_all) encoding("UTF-8") clear
rename attribute_11 hospital_id
gen survey_id = "721796"    
tempfile part2
save `part2'

import delimited using "$data/results-survey948966.csv", stringcol(_all) encoding("UTF-8") clear
rename attribute_11 hospital_id
gen survey_id = "948966"

append using `part1', force
append using `part2', force


drop if submitdate == ""
keep firstname lastname hospital_id submitdate startdate interviewtime grouptime* attribute_* survey_id 
destring interviewtime grouptime*, replace

replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6
drop if firstname == ""


duplicates report firstname
duplicates drop firstname, force

su interviewtime, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
gen valid_answer = interviewtime >= r(p5)
gen duration_min = interviewtime / 60

winsor duration_min, gen(duration_min_winsor) p(0.01)

su duration_min, detail
display "5th percentile: " r(p5)
display "95th percentile: " r(p95)
local mean = round(r(mean), 0.01)
local median = round(r(p50), 0.01)
local n = r(N)

tw (hist duration_min_winsor, fcolor(cranberry%30) lcolor(cranberry%30) percent start(0) width(1)), ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    xtitle( "(N=`n', median=`median', mean=`mean')", size(*0.8)) ///
    ytitle("Percent", size(*.8)) ///
    title("Duration of 6m Survey Valid Answers (winsorized at 1%)") ///
    xlabel(0(5)50) ///
    ylabel(0(3)15) ///
    ylabel(, labsize(*1.1) angle(horizontal) grid glc(gs15) noticks) ///
    ysc(titlegap(3) noline) ///
    name(graph1, replace)

graph export "$proc/rubbish_6m_duration.pdf", replace
gen rubbish_answer = (valid_answer == 0)
save "$proc/rubbish_6m_results.dta", replace



************************************************************************
/* use "$proc/rubbish_1m_results.dta", clear
gen treatment = (attribute_4 != "Y")
local timevar grouptime*

foreach var of varlist `timevar' {
    gen tag = 1 if `var' == . & treatment == 0
    gen temp = .
    quietly levelsof survey_id if tag == 1, local(sids)
    foreach sid of local sids {
        quietly count if survey_id == "`sid'" & treatment == 1 & !missing(`var')
        if r(N) > 0 {
            replace `var' = 0 if survey_id == "`sid'" & tag == 1
        }
    }
    drop tag temp
}
 */

/////////////////////////////////////////////////////////////////////////
***************************** ANANALYSIS ********************************
/////////////////////////////////////////////////////////////////////////



local waves 1m 2m 3m 6m

foreach wave in `waves' {
    //*************** Data Preparation ***************//
    use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update each week
        if "`wave'" == "1m" {
            keep if date <= date("2025-05-14", "YMD") 
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("2025-04-06", "YMD") 
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("2025-03-01", "YMD")
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "6m" {
            keep if date <= date("2024-12-01", "YMD") 
        }

    gen treatment = "C" if 组别 == "1"
    replace treatment = "T1" if 组别 == "2"
    replace treatment = "T2" if 组别 == "3"

    gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6

    keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment hospital_id
    tempfile complete
    save `complete'

    keep 母亲姓名 母亲电话 treatment hospital_id
    rename (母亲姓名 母亲电话)(lastname firstname)
    gen parent = "M"
    tempfile mother
    save `mother'

    use `complete'
    keep 父亲姓名 父亲电话 treatment hospital_id
    rename (父亲姓名 父亲电话)(lastname firstname)
    gen parent = "F"
    tempfile father
    save `father'

    append using `mother'
    order firstname lastname

    tempfile participants
    save `participants'


    merge 1:m firstname using "$proc/rubbish_`wave'_results.dta"

    drop if _merge == 2
    gen response_`wave' = _merge == 3
    drop _merge
    drop if missing(firstname)
    gen good_answer = response_`wave' == 1
    replace good_answer = 1 if rubbish_answer == 0
    replace good_answer = 0 if rubbish_answer == 1

    merge m:1 hospital_id using ///
    "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
    keep if _merge == 3
    drop _merge

    duplicates drop firstname, force

    bysort hospital_id (good_answer): gen good_answer_either = good_answer[_N]

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")
    capture drop group
    gen group = 1 if C == 1
    replace group = 2 if T1 == 1
    replace group = 3 if T2 == 1
    
    gen mother = (parent == "M")

    save "$proc/attrition_`wave'.dta", replace

    *------------------------------------------------------------*
    *             Regression: residualize attrition means        *
    *------------------------------------------------------------*
        // ---------- Mothers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su good_answer if `g'==1
            local mean_`g'_mother_`wave' : di %6.3f r(mean)
            local N_`g'_mother_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg good_answer T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_mother_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mother_`wave' ""
        if (`pval_t1c_mother_`wave''<0.1) local star_t1c_mother_`wave' "*"
        if (`pval_t1c_mother_`wave''<0.05) local star_t1c_mother_`wave' "**"
        if (`pval_t1c_mother_`wave''<0.01) local star_t1c_mother_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg good_answer T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_mother_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mother_`wave' ""
        if (`pval_t2c_mother_`wave''<0.1) local star_t2c_mother_`wave' "*"
        if (`pval_t2c_mother_`wave''<0.05) local star_t2c_mother_`wave' "**"
        if (`pval_t2c_mother_`wave''<0.01) local star_t2c_mother_`wave' "***"
        restore

        // Chi2 test
        tab good_answer group, chi2
        local pval_chi2_mother_`wave' : di %6.3f r(p)
        

        // ---------- Fathers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su good_answer if `g'==1
            local mean_`g'_father_`wave' : di %6.3f r(mean)
            local N_`g'_father_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg good_answer T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_father_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_father_`wave' ""
        if (`pval_t1c_father_`wave''<0.1) local star_t1c_father_`wave' "*"
        if (`pval_t1c_father_`wave''<0.05) local star_t1c_father_`wave' "**"
        if (`pval_t1c_father_`wave''<0.01) local star_t1c_father_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg good_answer T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_father_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_father_`wave' ""
        if (`pval_t2c_father_`wave''<0.1) local star_t2c_father_`wave' "*"
        if (`pval_t2c_father_`wave''<0.05) local star_t2c_father_`wave' "**"
        if (`pval_t2c_father_`wave''<0.01) local star_t2c_father_`wave' "***"
        restore

        

        // ---------- Either parent ----------
        use "$proc/attrition_`wave'.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su good_answer_either if `g'==1
            local mean_`g'_either_`wave' : di %6.3f r(mean)
            local N_`g'_either_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg good_answer_either T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_either_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_either_`wave' ""
        if (`pval_t1c_either_`wave''<0.1) local star_t1c_either_`wave' "*"
        if (`pval_t1c_either_`wave''<0.05) local star_t1c_either_`wave' "**"
        if (`pval_t1c_either_`wave''<0.01) local star_t1c_either_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg good_answer_either T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_either_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_either_`wave' ""
        if (`pval_t2c_either_`wave''<0.1) local star_t2c_either_`wave' "*"
        if (`pval_t2c_either_`wave''<0.05) local star_t2c_either_`wave' "**"
        if (`pval_t2c_either_`wave''<0.01) local star_t2c_either_`wave' "***"
        restore
        
}
di `N_C_mother_6m' `N_T1_mother_6m' `N_T2_mother_6m'
// Output LaTeX tables for each wave and respondent type (mother, father, either)

capture file close latex
file open latex using "$results/tables/attrition_good_answer.tex", write replace

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Rubbish Answers - 1m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "1m & Mother & `mean_C_mother_1m' &`mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m'" _n
file write latex "1m & Father & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' " _n
file write latex "1m & Either & `mean_C_either_1m' & `mean_T1_either_1m'`star_t1c_either_1m' & `mean_T2_either_1m'`star_t2c_either_1m'" _n
file write latex "& N(Family) & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' " _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Rubbish Answers - 2m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "2m & Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m' " _n
file write latex "2m & Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' " _n
file write latex "2m & Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_t1c_either_2m' & `mean_T2_either_2m'`star_t2c_either_2m' " _n
file write latex "& N(Family) & `N_C_mother_2m' & `N_T1_mother_2m' & `N_T2_mother_2m' " _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n



file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Rubbish Answers - 3m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "3m & Mother & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_t1c_mother_3m' & `mean_T2_mother_3m'`star_t2c_mother_3m'\\" _n
file write latex "3m & Father & `mean_C_father_3m' & `mean_T1_father_3m'`star_t1c_father_3m' & `mean_T2_father_3m'`star_t2c_father_3m'  \\" _n
file write latex "3m & Either & `mean_C_either_3m' & `mean_T1_either_3m'`star_t1c_either_3m' & `mean_T2_either_3m'`star_t2c_either_3m'\\" _n
file write latex "& N(Family) & `N_C_mother_3m' & `N_T1_mother_3m' & `N_T2_mother_3m' " _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Rubbish Answers - 6m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "6m & Mother & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_t1c_mother_6m' & `mean_T2_mother_6m'`star_t2c_mother_6m' \\" _n
file write latex "6m & Father & `mean_C_father_6m' & `mean_T1_father_6m'`star_t1c_father_6m' & `mean_T2_father_6m'`star_t2c_father_6m' \\" _n
file write latex "6m & Either & `mean_C_either_6m' & `mean_T1_either_6m'`star_t1c_either_6m' & `mean_T2_either_6m'`star_t2c_either_6m' \\" _n
file write latex "& N(Family) & `N_C_mother_6m' & `N_T1_mother_6m' & `N_T2_mother_6m' \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n




*---------------------------------------------------------------------------------*
*                            Analysis: Good Answers by Triple P Change            *
*---------------------------------------------------------------------------------*


local waves 1m 2m 3m 6m

foreach wave in `waves' {
    //*************** Data Preparation ***************//
    use "$proc/contact_list.dta", clear

    gen date = date(日期, "YMD") if strpos(日期, "年") > 0
    replace date = date(日期, "MDY") if strpos(日期, "/") > 0
    replace date = date(日期, "DMY") if date == .
    format date %td

        // Where need to update each week
        if "`wave'" == "1m" {
            keep if date <= date("2025-05-14", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("2025-04-06", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("2025-03-01", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "6m" {
            keep if date <= date("2024-12-01", "YMD") 
        }

    gen treatment = "C" if 组别 == "1"
    replace treatment = "T1" if 组别 == "2"
    replace treatment = "T2" if 组别 == "3"

    gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6

    keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment hospital_id
    tempfile complete
    save `complete'

    keep 母亲姓名 母亲电话 treatment hospital_id
    rename (母亲姓名 母亲电话)(lastname firstname)
    gen parent = "M"
    tempfile mother
    save `mother'

    use `complete'
    keep 父亲姓名 父亲电话 treatment hospital_id
    rename (父亲姓名 父亲电话)(lastname firstname)
    gen parent = "F"
    tempfile father
    save `father'

    append using `mother'
    order firstname lastname

    tempfile participants
    save `participants'

    merge 1:m firstname using "$proc/rubbish_`wave'_results.dta"

    drop if _merge == 2
    gen response_`wave' = _merge == 3
    drop _merge
    drop if missing(firstname)
    gen good_answer = response_`wave' == 1
    replace good_answer = 1 if rubbish_answer == 0
    replace good_answer = 0 if rubbish_answer == 1

    merge m:1 hospital_id using ///
    "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
    keep if _merge == 3
    drop _merge

    duplicates drop firstname, force

    bysort hospital_id (good_answer): gen good_answer_either = good_answer[_N]

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")
    capture drop group
    gen group = 1 if C == 1
    replace group = 2 if T1 == 1
    replace group = 3 if T2 == 1
    
    gen mother = (parent == "M")
    drop attribute_*

    save "$proc/attrition_`wave'.dta", replace

    *------------------------------------------------------------*
    *             Regression: residualize attrition means        *
    *------------------------------------------------------------*
        // ---------- Mothers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 1
        foreach g in C T1 T2 {
            su good_answer if `g'==1
            local mean_`g'_mother_`wave' : di %6.3f r(mean)
            local N_`g'_mother_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg good_answer T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_mother_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_mother_`wave' ""
        if (`pval_t1c_mother_`wave''<0.1) local star_t1c_mother_`wave' "*"
        if (`pval_t1c_mother_`wave''<0.05) local star_t1c_mother_`wave' "**"
        if (`pval_t1c_mother_`wave''<0.01) local star_t1c_mother_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg good_answer T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_mother_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_mother_`wave' ""
        if (`pval_t2c_mother_`wave''<0.1) local star_t2c_mother_`wave' "*"
        if (`pval_t2c_mother_`wave''<0.05) local star_t2c_mother_`wave' "**"
        if (`pval_t2c_mother_`wave''<0.01) local star_t2c_mother_`wave' "***"
        restore

        // Chi2 test
        tab good_answer group, chi2
        local pval_chi2_mother_`wave' : di %6.3f r(p)
        

        // ---------- Fathers ----------
        use "$proc/attrition_`wave'.dta", clear
        keep if mother == 0
        foreach g in C T1 T2 {
            su good_answer if `g'==1
            local mean_`g'_father_`wave' : di %6.3f r(mean)
            local N_`g'_father_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg good_answer T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_father_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_father_`wave' ""
        if (`pval_t1c_father_`wave''<0.1) local star_t1c_father_`wave' "*"
        if (`pval_t1c_father_`wave''<0.05) local star_t1c_father_`wave' "**"
        if (`pval_t1c_father_`wave''<0.01) local star_t1c_father_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg good_answer T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_father_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_father_`wave' ""
        if (`pval_t2c_father_`wave''<0.1) local star_t2c_father_`wave' "*"
        if (`pval_t2c_father_`wave''<0.05) local star_t2c_father_`wave' "**"
        if (`pval_t2c_father_`wave''<0.01) local star_t2c_father_`wave' "***"
        restore

        // Chi2 test
        tab good_answer group, chi2
        local pval_chi2_father_`wave' : di %6.3f r(p)
        

        // ---------- Either parent ----------
        use "$proc/attrition_`wave'.dta", clear
        // Use full sample, not just mothers or fathers
        foreach g in C T1 T2 {
            su good_answer_either if `g'==1
            local mean_`g'_either_`wave' : di %6.3f r(mean)
            local N_`g'_either_`wave' = r(N)
        }

        // T1 vs C
        preserve
        drop if T2==1
        reg good_answer_either T1 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t1c_either_`wave' = 2*ttail(e(df_r), abs(_b[T1]/_se[T1]))
        local star_t1c_either_`wave' ""
        if (`pval_t1c_either_`wave''<0.1) local star_t1c_either_`wave' "*"
        if (`pval_t1c_either_`wave''<0.05) local star_t1c_either_`wave' "**"
        if (`pval_t1c_either_`wave''<0.01) local star_t1c_either_`wave' "***"
        restore

        // T2 vs C
        preserve
        drop if T1==1
        reg good_answer_either T2 i.strata i.enumerator_id, cluster(cluster_var)
        local pval_t2c_either_`wave' = 2*ttail(e(df_r), abs(_b[T2]/_se[T2]))
        local star_t2c_either_`wave' ""
        if (`pval_t2c_either_`wave''<0.1) local star_t2c_either_`wave' "*"
        if (`pval_t2c_either_`wave''<0.05) local star_t2c_either_`wave' "**"
        if (`pval_t2c_either_`wave''<0.01) local star_t2c_either_`wave' "***"
        restore

        // Chi2 test
        tab good_answer_either group, chi2
        local pval_chi2_either_`wave' : di %6.3f r(p)
        
}
di `N_C_mother_6m' `N_T1_mother_6m' `N_T2_mother_6m'
// Output LaTeX tables for each wave and respondent type (mother, father, either)

capture file close latex
file open latex using "$results/tables/attrition_good_answer.tex", write append

file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 1m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_1m' &`mean_T1_mother_1m'`star_t1c_mother_1m' & `mean_T2_mother_1m'`star_t2c_mother_1m' &  0.875 & 0.839 &  0.795***  \\" _n
file write latex "Father & `mean_C_father_1m' & `mean_T1_father_1m'`star_t1c_father_1m' & `mean_T2_father_1m'`star_t2c_father_1m' &  0.837 &  0.760*** &  0.727*** \\" _n
file write latex "Either & `mean_C_either_1m' & `mean_T1_either_1m'`star_t1c_either_1m' & `mean_T2_either_1m'`star_t2c_either_1m' &  0.954 &  0.930 &  0.911** \\" _n
file write latex "N(Family) & `N_C_mother_1m' & `N_T1_mother_1m' & `N_T2_mother_1m' & 393 & 403 & 381 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 2m Survey}" _n
file write latex "\begin{tabular}{lcccccc}" _n
file write latex "\toprule" _n
file write latex "& \multicolumn{3}{c}{After Triple P Change} & \multicolumn{3}{c}{Before Triple P Change} \\" _n
file write latex "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_t1c_mother_2m' & `mean_T2_mother_2m'`star_t2c_mother_2m'  &  0.850 &  0.817 &  0.751***   \\" _n
file write latex "Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_t1c_father_2m' & `mean_T2_father_2m'`star_t2c_father_2m' & 0.824 &  0.711*** &  0.659*** \\" _n
file write latex "Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_t1c_either_2m' & `mean_T2_either_2m'`star_t2c_either_2m' &  0.936 &  0.912 &  0.850***  \\" _n
file write latex "N(Family) & `N_C_mother_2m' & `N_T1_mother_2m' & `N_T2_mother_2m' & 393 & 403 & 381 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n



file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 3m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_t1c_mother_3m' & `mean_T2_mother_3m'`star_t2c_mother_3m' & 0.852 &  0.782*** &  0.759*** \\" _n
file write latex "Father & `mean_C_father_3m' & `mean_T1_father_3m'`star_t1c_father_3m' & `mean_T2_father_3m'`star_t2c_father_3m' & 0.832 &  0.691*** &  0.656***  \\" _n
file write latex "Either & `mean_C_either_3m' & `mean_T1_either_3m'`star_t1c_either_3m' & `mean_T2_either_3m'`star_t2c_either_3m' &  0.939 &  0.888*** &  0.848*** \\" _n
file write latex "N(Family) & `N_C_mother_3m' & `N_T1_mother_3m' & `N_T2_mother_3m'  & 393 & 403 & 381 \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n


file write latex _n
file write latex "\begin{table}[htbp]" _n
file write latex "\centering" _n
file write latex "\begin{threeparttable}" _n
file write latex "\caption{Residualized Response Means - 6m Survey}" _n
file write latex "\begin{tabular}{lccc}" _n
file write latex "\toprule" _n
file write latex "\textbf{Group} & \textbf{Control Mean} & \textbf{T1 Mean} & \textbf{T2 Mean} \\" _n
file write latex "\midrule" _n

file write latex "Mother & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_t1c_mother_6m' & `mean_T2_mother_6m'`star_t2c_mother_6m' \\" _n
file write latex "Father & `mean_C_father_6m' & `mean_T1_father_6m'`star_t1c_father_6m' & `mean_T2_father_6m'`star_t2c_father_6m' \\" _n
file write latex "Either & `mean_C_either_6m' & `mean_T1_either_6m'`star_t1c_either_6m' & `mean_T2_either_6m'`star_t2c_either_6m' \\" _n
file write latex "N(Family) & `N_C_mother_6m' & `N_T1_mother_6m' & `N_T2_mother_6m' \\" _n

file write latex "\bottomrule" _n
file write latex "\end{tabular}" _n
file write latex "\begin{tablenotes}" _n
file write latex "\small" _n
file write latex "Notes: Stars indicate significance relative to the control group. " _n
file write latex "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write latex "Residualized means control for strata and enumerator fixed effects." _n
file write latex "\end{tablenotes}" _n
file write latex "\end{threeparttable}" _n
file write latex "\end{table}" _n

