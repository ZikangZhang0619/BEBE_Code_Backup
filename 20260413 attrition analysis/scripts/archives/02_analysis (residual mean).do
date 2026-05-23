** Attrition Analysis

** Haoyue Wu
** Updated on: 19 May, 2025


*********
** LOG **
*********
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project attrition_table
cap log close
set linesize 200
log using "$logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd



//********************************************************************************//
// 1. REPORT THE ATTRITION TABLE FOR EACH WAVES OF SURVEY WITH RESIDUALIZED MEANS //
//********************************************************************************//

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
            keep if date <= date("2025-04-15", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "2m" {
            keep if date <= date("2025-03-08", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "3m" {
            keep if date <= date("2025-01-26", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)
            /* keep if date < date("2025-01-21", "YMD") & strpos(备注, "tp课程干预简化Ava测试") == 0 */
        }
        else if "`wave'" == "6m" {
            keep if date <= date("2024-11-03", "YMD") 
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

    if "`wave'" == "2m" {
        merge 1:m firstname using "$proc/2m&6w_results.dta"
    }
    else {
        merge 1:m firstname using "$proc/`wave'_results.dta"
    }
    drop if _merge == 2
    gen response_`wave' = (_merge == 3)
    drop _merge
    drop if missing(firstname)

    merge m:1 hospital_id using ///
    "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
    keep if _merge == 3
    drop _merge

    duplicates drop firstname, force

    bysort hospital_id (response_`wave'): gen response_either_`wave' = response_`wave'[_N]

    gen C = (treatment == "C")
    gen T1 = (treatment == "T1")
    gen T2 = (treatment == "T2")

    gen mother = (parent == "M")
    drop attribute_*

    *------------------------------------------------------------*
    *             Regression: residualize attrition means        *
    *------------------------------------------------------------*
    reg response_`wave' i.strata i.enumerator_id, cluster(cluster_var)
    predict response_resid, residuals
    reg response_either_`wave' i.strata i.enumerator_id, cluster(cluster_var)
    predict response_either_resid, residuals

    sum response_`wave'
    scalar overall_mean = r(mean)

    sum response_either_`wave'
    scalar overall_mean_either = r(mean)

    gen response_resid_mean = response_resid + overall_mean
    gen response_either_mean = response_either_resid + overall_mean_either

    gen T1_mother = (T1==1 & mother==1)
    gen T2_mother = (T2==1 & mother==1)
    gen C_mother  = (T1==0 & T2==0 & mother==1)

    gen T1_father = (T1==1 & mother==0)
    gen T2_father = (T2==1 & mother==0)
    gen C_father  = (T1==0 & T2==0 & mother==0)

    foreach grp in T1_mother T2_mother C_mother T1_father T2_father C_father {
        su response_resid_mean if `grp'
        local mean_`grp'_`wave': di %6.3f r(mean)
        di "Residualized mean (`grp' `wave'): " `mean_`grp'_`wave''
    }

    foreach grpe in T1 T2 C {
        su response_either_mean if `grpe'
        local mean_`grpe'_either_`wave': di %6.3f r(mean)
        di "Observed mean (`mean_`grpe'_either_`wave'): " `mean_`grpe'_either_`wave''
    }

    *------------------------------------------------------------*
    * Significance testing: residualized attrition vs. control
    *------------------------------------------------------------*

    * ---------- Mothers ----------
    preserve
    keep if mother == 1
    reg response_`wave' T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
    matrix r_m1 = r(table)
    local p_T1_mother_`wave' = r_m1[4, 1]

    local star_T1_mother_`wave' ""
    if (`p_T1_mother_`wave'' < 0.1) local star_T1_mother_`wave' "*"
    if (`p_T1_mother_`wave'' < 0.05) local star_T1_mother_`wave' "**"
    if (`p_T1_mother_`wave'' < 0.01) local star_T1_mother_`wave' "***"

    count if C == 1 & mother == 1
    local N_C_mother_`wave' = r(N)

    count if T1 == 1 & mother == 1
    local N_T1_mother_`wave' = r(N)

    reg response_`wave' T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
    matrix r_m2 = r(table)
    local p_T2_mother_`wave' = r_m2[4, 1]

    local star_T2_mother_`wave' ""
    if (`p_T2_mother_`wave'' < 0.1) local star_T2_mother_`wave' "*"
    if (`p_T2_mother_`wave'' < 0.05) local star_T2_mother_`wave' "**"
    if (`p_T2_mother_`wave'' < 0.01) local star_T2_mother_`wave' "***"

    count if T2 == 1 & mother == 1
    local N_T2_mother_`wave' = r(N)

    restore

    * ---------- Fathers ----------
    preserve
    keep if mother == 0

    reg response_`wave' T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
    matrix r_m1 = r(table)
    local p_T1_father_`wave' = r_m1[4, 1]

    local star_T1_father_`wave' ""
    if (`p_T1_father_`wave'' < 0.1) local star_T1_father_`wave' "*"
    if (`p_T1_father_`wave'' < 0.05) local star_T1_father_`wave' "**"
    if (`p_T1_father_`wave'' < 0.01) local star_T1_father_`wave' "***"

    count if C == 1 & mother == 0
    local N_C_father_`wave' = r(N)

    count if T1 == 1 & mother == 0
    local N_T1_father_`wave' = r(N)

    reg response_`wave' T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
    matrix r_m2 = r(table)
    local p_T2_father_`wave' = r_m2[4, 1]

    local star_T2_father_`wave' ""
    if (`p_T2_father_`wave'' < 0.1) local star_T2_father_`wave' "*"
    if (`p_T2_father_`wave'' < 0.05) local star_T2_father_`wave' "**"
    if (`p_T2_father_`wave'' < 0.01) local star_T2_father_`wave' "***"

    count if T2 == 1 & mother == 0
    local N_T2_father_`wave' = r(N)

    restore

    * ---------- Either ----------
    reg response_either_`wave' T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
    matrix r_e1 = r(table)
    local p_T1_either_`wave' = r_e1[4, 1]

    local star_T1_either_`wave' ""
    if (`p_T1_either_`wave'' < 0.1) local star_T1_either_`wave' "*"
    if (`p_T1_either_`wave'' < 0.05) local star_T1_either_`wave' "**"
    if (`p_T1_either_`wave'' < 0.01) local star_T1_either_`wave' "***"

    count if C== 1
    local N_C_either_`wave' = r(N)

    count if T1 == 1
    local N_T1_either_`wave' = r(N)

    reg response_either_`wave' T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
    matrix r_e2 = r(table)
    local p_T2_either_`wave' = r_e2[4, 1]

    local star_T2_either_`wave' ""
    if (`p_T2_either_`wave'' < 0.1) local star_T2_either_`wave' "*"
    if (`p_T2_either_`wave'' < 0.05) local star_T2_either_`wave' "**"
    if (`p_T2_either_`wave'' < 0.01) local star_T2_either_`wave' "***"

    count if T2 == 1
    local N_T2_either_`wave' = r(N)
}

*------------------------------------------------------------*
* Export LaTeX Table with Residualized Means and Stars       *
*------------------------------------------------------------*
capture file close latex
file open latex using "$results/$tables/residualized_attrition.tex", write replace

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

file write latex "Mother & `mean_C_mother_1m' &`mean_T1_mother_1m'`star_T1_mother_1m' & `mean_T2_mother_1m'`star_T2_mother_1m' &  0.923 & 0.886** &  0.812***  \\" _n
file write latex "Father & `mean_C_father_1m' & `mean_T1_father_1m'`star_T1_father_1m' & `mean_T2_father_1m'`star_T2_father_1m' &  0.905 &  0.807*** &  0.764***  \\" _n
file write latex "Either & `mean_C_either_1m' & `mean_T1_either_1m'`star_T1_either_1m' & `mean_T2_either_1m'`star_T2_either_1m' &  0.976 &  0.945** &  0.924***  \\" _n
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

file write latex "Mother & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_T1_mother_2m' & `mean_T2_mother_2m'`star_T2_mother_2m' &  0.888 &  0.843** &  0.775*** \\" _n
file write latex "Father & `mean_C_father_2m' & `mean_T1_father_2m'`star_T1_father_2m' & `mean_T2_father_2m'`star_T2_father_2m' &  0.898 &  0.757*** &  0.699*** \\" _n
file write latex "Either & `mean_C_either_2m' & `mean_T1_either_2m'`star_T1_either_2m' & `mean_T2_either_2m'`star_T2_either_2m'&  0.958 &  0.925** &  0.869***  \\" _n
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

file write latex "Mother & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_T1_mother_3m' & `mean_T2_mother_3m'`star_T2_mother_3m' &  0.873 &  0.812*** &  0.787*** \\" _n
file write latex "Father & `mean_C_father_3m' & `mean_T1_father_3m'`star_T1_father_3m' & `mean_T2_father_3m'`star_T2_father_3m' &  0.898 &  0.738*** &  0.710*** \\" _n
file write latex "Either & `mean_C_either_3m' & `mean_T1_either_3m'`star_T1_either_3m' & `mean_T2_either_3m'`star_T2_either_3m' &  0.953 &  0.904*** &  0.877***  \\" _n
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

file write latex "Mother & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_T1_mother_6m' & `mean_T2_mother_6m'`star_T2_mother_6m' \\" _n
file write latex "Father & `mean_C_father_6m' & `mean_T1_father_6m'`star_T1_father_6m' & `mean_T2_father_6m'`star_T2_father_6m' \\" _n
file write latex "Either & `mean_C_either_6m' & `mean_T1_either_6m'`star_T1_either_6m' & `mean_T2_either_6m'`star_T2_either_6m' \\" _n
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

file close latex




//********************************************************************************//
//                   2. ATTRITION FOR CONSECUTIVE WAVES OF SURVEYS               //
//********************************************************************************//


*------------------------------------------------------------*
*                           1m & 2m                          *
*------------------------------------------------------------*

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-03-08", "YMD") 
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


merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen response_1m = (_merge == 3)
drop _merge
drop if missing(firstname)

tempfile 1m
save `1m'

use `participants', clear
merge 1:m firstname using "$proc/2m&6w_results.dta"
drop if _merge == 2
gen response_2m = (_merge == 3)
drop _merge
drop if missing(firstname)
duplicates drop firstname, force

tempfile 2m
save `2m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge


merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

// fix some errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"
replace hospital_id = "D00338830" if firstname == "17740880560"


gen any_response = (response_1m == 1 | response_2m == 1)

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
drop attribute_*

duplicates drop firstname, force

// Residualize response means
reg response_1m i.strata i.enumerator_id, cluster(cluster_var)
predict response_1m_resid, residuals
reg response_2m i.strata i.enumerator_id, cluster(cluster_var)
predict response_2m_resid, residuals
reg any_response i.strata i.enumerator_id, cluster(cluster_var)
predict any_response_resid, residuals

sum response_1m
scalar mean_response_1m = r(mean)

sum response_2m
scalar mean_response_2m = r(mean)

sum any_response
scalar mean_any_response = r(mean)

gen response_resid_mean_1m = response_1m_resid + mean_response_1m   
gen response_resid_mean_2m = response_2m_resid + mean_response_2m
gen any_response_resid_mean = any_response_resid + mean_any_response


gen T1_mother = (T1==1 & mother==1)
gen T2_mother = (T2==1 & mother==1)
gen C_mother  = (T1==0 & T2==0 & mother==1)

gen T1_father = (T1==1 & mother==0)
gen T2_father = (T2==1 & mother==0)
gen C_father  = (T1==0 & T2==0 & mother==0)


foreach grp in T1_mother T2_mother C_mother T1_father T2_father C_father {
    su response_resid_mean_1m if `grp'
    local mean_`grp'_1m: di %6.3f r(mean)
    su response_resid_mean_2m if `grp'
    local mean_`grp'_2m : di %6.3f r(mean)
    su any_response_resid_mean if `grp'
    local mean_`grp'_any: di %6.3f r(mean)
    di "Residualized mean (`grp' 1m): " `mean_`grp'_1m'
}


* ---------- Mothers ----------
preserve
keep if mother == 1

* 1m 
reg response_1m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_mother_1m = r_m1[4, 1]

local star_T1_mother_1m ""
if (`p_T1_mother_1m' < 0.1) local star_T1_mother_1m "*"
if (`p_T1_mother_1m' < 0.05) local star_T1_mother_1m "**"
if (`p_T1_mother_1m' < 0.01) local star_T1_mother_1m "***"

reg response_1m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_mother_1m = r_m2[4, 1]

local star_T2_mother_1m ""
if (`p_T2_mother_1m' < 0.1) local star_T2_mother_1m "*"
if (`p_T2_mother_1m' < 0.05) local star_T2_mother_1m "**"
if (`p_T2_mother_1m' < 0.01) local star_T2_mother_1m "***"

* 2m 
reg response_2m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_mother_2m = r_m1[4, 1]

local star_T1_mother_2m ""
if (`p_T1_mother_2m' < 0.1) local star_T1_mother_2m "*"
if (`p_T1_mother_2m' < 0.05) local star_T1_mother_2m "**"
if (`p_T1_mother_2m' < 0.01) local star_T1_mother_2m "***"

reg response_2m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_mother_2m = r_m2[4, 1]

local star_T2_mother_2m ""
if (`p_T2_mother_2m' < 0.1) local star_T2_mother_2m "*"
if (`p_T2_mother_2m' < 0.05) local star_T2_mother_2m "**"
if (`p_T2_mother_2m' < 0.01) local star_T2_mother_2m "***"

* any
reg any_response T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_e1 = r(table)
local p_T1_mother_any = r_e1[4, 1]

local star_T1_mother_any ""
if (`p_T1_mother_any' < 0.1) local star_T1_mother_any "*"
if (`p_T1_mother_any' < 0.05) local star_T1_mother_any "**"
if (`p_T1_mother_any' < 0.01) local star_T1_mother_any "***"

reg any_response T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_e2 = r(table)
local p_T2_mother_any = r_e2[4, 1]

local star_T2_mother_any ""
if (`p_T2_mother_any' < 0.1) local star_T2_mother_any "*"
if (`p_T2_mother_any' < 0.05) local star_T2_mother_any "**"
if (`p_T2_mother_any' < 0.01) local star_T2_mother_any "***"

count if C == 1 & mother == 1
local N_C_mother = r(N)

count if T1 == 1 & mother == 1
local N_T1_mother = r(N)

count if T2 == 1 & mother == 1
local N_T2_mother = r(N)

restore

* ---------- Fathers ----------
preserve
keep if mother == 0

* 1m
reg response_1m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_father_1m = r_m1[4, 1]

local star_T1_father_1m ""
if (`p_T1_father_1m' < 0.1) local star_T1_father_1m "*"
if (`p_T1_father_1m' < 0.05) local star_T1_father_1m "**"
if (`p_T1_father_1m' < 0.01) local star_T1_father_1m "***"

reg response_1m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_father_1m = r_m2[4, 1]

local star_T2_father_1m ""
if (`p_T2_father_1m' < 0.1) local star_T2_father_1m "*"
if (`p_T2_father_1m' < 0.05) local star_T2_father_1m "**"
if (`p_T2_father_1m' < 0.01) local star_T2_father_1m "***"

* 2m 
reg response_2m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_father_2m = r_m1[4, 1]

local star_T1_father_2m ""
if (`p_T1_father_2m' < 0.1) local star_T1_father_2m "*"
if (`p_T1_father_2m' < 0.05) local star_T1_father_2m "**"
if (`p_T1_father_2m' < 0.01) local star_T1_father_2m "***"

reg response_2m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_father_2m = r_m2[4, 1]

local star_T2_father_2m ""
if (`p_T2_father_2m' < 0.1) local star_T2_father_2m "*"
if (`p_T2_father_2m' < 0.05) local star_T2_father_2m "**"
if (`p_T2_father_2m' < 0.01) local star_T2_father_2m "***"

* any
reg any_response T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_e1 = r(table)
local p_T1_father_any = r_e1[4, 1]

local star_T1_father_any ""
if (`p_T1_father_any' < 0.1) local star_T1_father_any "*"
if (`p_T1_father_any' < 0.05) local star_T1_father_any "**"
if (`p_T1_father_any' < 0.01) local star_T1_father_any "***"

reg any_response T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_e2 = r(table)
local p_T2_father_any = r_e2[4, 1]

local star_T2_father_any ""
if (`p_T2_father_any' < 0.1) local star_T2_father_any "*"
if (`p_T2_father_any' < 0.05) local star_T2_father_any "**"
if (`p_T2_father_any' < 0.01) local star_T2_father_any "***"

count if C == 1 & mother == 0
local N_C_father = r(N)

count if T1 == 1 & mother == 0
local N_T1_father = r(N)

count if T2 == 1 & mother == 0
local N_T2_father = r(N)

restore


capture file close resultsfile
file open resultsfile using "$results/tables/response_across_wave.tex", write replace

file write resultsfile "\begin{table}[htbp]" _n
file write resultsfile "\centering" _n
file write resultsfile "\caption{Residualized Response Means}" _n
file write resultsfile "\begin{tabular}{lcccccc}" _n
file write resultsfile "\toprule" _n
file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write resultsfile "\textbf{Measure} & Control & T1 & T2 & Control & T1 & T2 \\" _n
file write resultsfile "\midrule" _n

file write resultsfile "1m Response & `mean_C_mother_1m' & `mean_T1_mother_1m'`star_T1_mother_1m' & `mean_T2_mother_1m'`star_T2_mother_1m' & `mean_C_father_1m' & `mean_T1_father_1m'`star_T1_father_1m' & `mean_T2_father_1m'`star_T2_father_1m' \\" _n

file write resultsfile "2m Response & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_T1_mother_2m' & `mean_T2_mother_2m'`star_T2_mother_2m' & `mean_C_father_2m' & `mean_T1_father_2m'`star_T1_father_2m' & `mean_T2_father_2m'`star_T2_father_2m' \\" _n

file write resultsfile "Any Response & `mean_C_mother_any' & `mean_T1_mother_any'`star_T1_mother_any' & `mean_T2_mother_any'`star_T2_mother_any' & `mean_C_father_any' & `mean_T1_father_any'`star_T1_father_any' & `mean_T2_father_any'`star_T2_father_any' \\" _n

file write resultsfile "N & `N_C_mother' & `N_T1_mother' & `N_T2_mother' & `N_C_father' & `N_T1_father' & `N_T2_father' \\" _n

file write resultsfile "\bottomrule" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\small" _n
file write resultsfile "Notes: Stars indicate significance relative to the control group. " _n
file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write resultsfile "Residualized means control for strata and enumerator fixed effects." _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{table}" _n

file close resultsfile



*------------------------------------------------------------*
*                       1m & 2m & 3m                         *
*------------------------------------------------------------*

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-01-26", "YMD")
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


merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen response_1m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 1m
save `1m'

use `participants', clear
merge 1:m firstname using "$proc/2m&6w_results.dta"
drop if _merge == 2
gen response_2m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 2m
save `2m'

use `participants', clear
merge 1:m firstname using "$proc/3m_results.dta"
drop if _merge == 2
gen response_3m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 3m
save `3m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `3m', force
drop if _merge == 1
drop _merge 

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

 
// fix errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"

gen any_response = (response_1m == 1 | response_2m == 1 | response_3m == 1)

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
drop attribute_*

duplicates drop firstname, force

// Residualize response means
reg response_1m i.strata i.enumerator_id, cluster(cluster_var)
predict response_1m_resid, residuals
reg response_2m i.strata i.enumerator_id, cluster(cluster_var)
predict response_2m_resid, residuals
reg response_3m i.strata i.enumerator_id, cluster(cluster_var)
predict response_3m_resid, residuals
reg any_response i.strata i.enumerator_id, cluster(cluster_var)
predict any_response_resid, residuals

sum response_1m
scalar mean_response_1m = r(mean)

sum response_2m
scalar mean_response_2m = r(mean)

sum response_3m
scalar mean_response_3m = r(mean)

sum any_response
scalar mean_any_response = r(mean)

gen response_resid_mean_1m = response_1m_resid + mean_response_1m   
gen response_resid_mean_2m = response_2m_resid + mean_response_2m
gen response_resid_mean_3m = response_3m_resid + mean_response_3m
gen any_response_resid_mean = any_response_resid + mean_any_response


gen T1_mother = (T1==1 & mother==1)
gen T2_mother = (T2==1 & mother==1)
gen C_mother  = (T1==0 & T2==0 & mother==1)

gen T1_father = (T1==1 & mother==0)
gen T2_father = (T2==1 & mother==0)
gen C_father  = (T1==0 & T2==0 & mother==0)


foreach grp in T1_mother T2_mother C_mother T1_father T2_father C_father {
    su response_resid_mean_1m if `grp'
    local mean_`grp'_1m: di %6.3f r(mean)
    su response_resid_mean_2m if `grp'
    local mean_`grp'_2m : di %6.3f r(mean)
    su response_resid_mean_3m if `grp'
    local mean_`grp'_3m : di %6.3f r(mean)
    su any_response_resid_mean if `grp'
    local mean_`grpe'_any: di %6.3f r(mean)
}


* ---------- Mothers ----------
preserve
keep if mother == 1

* 1m 
reg response_1m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_mother_1m = r_m1[4, 1]

local star_T1_mother_1m ""
if (`p_T1_mother_1m' < 0.1) local star_T1_mother_1m "*"
if (`p_T1_mother_1m' < 0.05) local star_T1_mother_1m "**"
if (`p_T1_mother_1m' < 0.01) local star_T1_mother_1m "***"

reg response_1m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_mother_1m = r_m2[4, 1]

local star_T2_mother_1m ""
if (`p_T2_mother_1m' < 0.1) local star_T2_mother_1m "*"
if (`p_T2_mother_1m' < 0.05) local star_T2_mother_1m "**"
if (`p_T2_mother_1m' < 0.01) local star_T2_mother_1m "***"

* 2m 
reg response_2m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_mother_2m = r_m1[4, 1]

local star_T1_mother_2m ""
if (`p_T1_mother_2m' < 0.1) local star_T1_mother_2m "*"
if (`p_T1_mother_2m' < 0.05) local star_T1_mother_2m "**"
if (`p_T1_mother_2m' < 0.01) local star_T1_mother_2m "***"

reg response_2m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_mother_2m = r_m2[4, 1]

local star_T2_mother_2m ""
if (`p_T2_mother_2m' < 0.1) local star_T2_mother_2m "*"
if (`p_T2_mother_2m' < 0.05) local star_T2_mother_2m "**"
if (`p_T2_mother_2m' < 0.01) local star_T2_mother_2m "***"

* 3m 
reg response_3m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_mother_3m = r_m1[4, 1]

local star_T1_mother_3m ""
if (`p_T1_mother_3m' < 0.1) local star_T1_mother_3m "*"
if (`p_T1_mother_3m' < 0.05) local star_T1_mother_3m "**"
if (`p_T1_mother_3m' < 0.01) local star_T1_mother_3m "***"

reg response_3m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_mother_3m = r_m2[4, 1]

local star_T2_mother_3m ""
if (`p_T2_mother_3m' < 0.1) local star_T2_mother_3m "*"
if (`p_T2_mother_3m' < 0.05) local star_T2_mother_3m "**"
if (`p_T2_mother_3m' < 0.01) local star_T2_mother_3m "***"

* any
reg any_response T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_e1 = r(table)
local p_T1_mother_any = r_e1[4, 1]

local star_T1_mother_any ""
if (`p_T1_mother_any' < 0.1) local star_T1_mother_any "*"
if (`p_T1_mother_any' < 0.05) local star_T1_mother_any "**"
if (`p_T1_mother_any' < 0.01) local star_T1_mother_any "***"

reg any_response T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_e2 = r(table)
local p_T2_mother_any = r_e2[4, 1]

local star_T2_mother_any ""
if (`p_T2_mother_any' < 0.1) local star_T2_mother_any "*"
if (`p_T2_mother_any' < 0.05) local star_T2_mother_any "**"
if (`p_T2_mother_any' < 0.01) local star_T2_mother_any "***"

count if C == 1 & mother == 1
local N_C_mother = r(N)

count if T1 == 1 & mother == 1
local N_T1_mother = r(N)

count if T2 == 1 & mother == 1
local N_T2_mother = r(N)

restore

* ---------- Fathers ----------
preserve
keep if mother == 0

* 1m
reg response_1m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_father_1m = r_m1[4, 1]

local star_T1_father_1m ""
if (`p_T1_father_1m' < 0.1) local star_T1_father_1m "*"
if (`p_T1_father_1m' < 0.05) local star_T1_father_1m "**"
if (`p_T1_father_1m' < 0.01) local star_T1_father_1m "***"

reg response_1m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_father_1m = r_m2[4, 1]

local star_T2_father_1m ""
if (`p_T2_father_1m' < 0.1) local star_T2_father_1m "*"
if (`p_T2_father_1m' < 0.05) local star_T2_father_1m "**"
if (`p_T2_father_1m' < 0.01) local star_T2_father_1m "***"

* 2m 
reg response_2m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_father_2m = r_m1[4, 1]

local star_T1_father_2m ""
if (`p_T1_father_2m' < 0.1) local star_T1_father_2m "*"
if (`p_T1_father_2m' < 0.05) local star_T1_father_2m "**"
if (`p_T1_father_2m' < 0.01) local star_T1_father_2m "***"

reg response_2m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_father_2m = r_m2[4, 1]

local star_T2_father_2m ""
if (`p_T2_father_2m' < 0.1) local star_T2_father_2m "*"
if (`p_T2_father_2m' < 0.05) local star_T2_father_2m "**"
if (`p_T2_father_2m' < 0.01) local star_T2_father_2m "***"

* 3m 
reg response_3m T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_m1 = r(table)
local p_T1_father_3m = r_m1[4, 1]

local star_T1_father_3m ""
if (`p_T1_father_3m' < 0.1) local star_T1_father_3m "*"
if (`p_T1_father_3m' < 0.05) local star_T1_father_3m "**"
if (`p_T1_father_3m' < 0.01) local star_T1_father_3m "***"

reg response_3m T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_m2 = r(table)
local p_T2_father_3m = r_m2[4, 1]

local star_T2_father_3m ""
if (`p_T2_father_3m' < 0.1) local star_T2_father_3m "*"
if (`p_T2_father_3m' < 0.05) local star_T2_father_3m "**"
if (`p_T2_father_3m' < 0.01) local star_T2_father_3m "***"

* any
reg any_response T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_e1 = r(table)
local p_T1_father_any = r_e1[4, 1]

local star_T1_father_any ""
if (`p_T1_father_any' < 0.1) local star_T1_father_any "*"
if (`p_T1_father_any' < 0.05) local star_T1_father_any "**"
if (`p_T1_father_any' < 0.01) local star_T1_father_any "***"

reg any_response T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_e2 = r(table)
local p_T2_father_any = r_e2[4, 1]

local star_T2_father_any ""
if (`p_T2_father_any' < 0.1) local star_T2_father_any "*"
if (`p_T2_father_any' < 0.05) local star_T2_father_any "**"
if (`p_T2_father_any' < 0.01) local star_T2_father_any "***"

count if C == 1 & mother == 0
local N_C_father = r(N)

count if T1 == 1 & mother == 0
local N_T1_father = r(N)

count if T2 == 1 & mother == 0
local N_T2_father = r(N)

restore


capture file close resultsfile
file open resultsfile using "$results/tables/response_across_wave.tex", write append

file write resultsfile "\begin{table}[htbp]" _n
file write resultsfile "\centering" _n
file write resultsfile "\caption{Residualized Response Means}" _n
file write resultsfile "\begin{tabular}{lcccccc}" _n
file write resultsfile "\toprule" _n
file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write resultsfile "\textbf{Measure} & Control & T1 & T2 & Control & T1 & T2 \\" _n
file write resultsfile "\midrule" _n

file write resultsfile "1m Response & `mean_C_mother_1m' & `mean_T1_mother_1m'`star_T1_mother_1m' & `mean_T2_mother_1m'`star_T2_mother_1m' & `mean_C_father_1m' & `mean_T1_father_1m'`star_T1_father_1m' & `mean_T2_father_1m'`star_T2_father_1m' \\" _n

file write resultsfile "2m Response & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_T1_mother_2m' & `mean_T2_mother_2m'`star_T2_mother_2m' & `mean_C_father_2m' & `mean_T1_father_2m'`star_T1_father_2m' & `mean_T2_father_2m'`star_T2_father_2m' \\" _n
file write resultsfile "3m Response & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_T1_mother_3m' & `mean_T2_mother_3m'`star_T2_mother_3m' & `mean_C_father_3m' & `mean_T1_father_3m'`star_T1_father_3m' & `mean_T2_father_3m'`star_T2_father_3m' \\" _n
file write resultsfile "Any Response & `mean_C_mother_any' & `mean_T1_mother_any'`star_T1_mother_any' & `mean_T2_mother_any'`star_T2_mother_any' & `mean_C_father_any' & `mean_T1_father_any'`star_T1_father_any' & `mean_T2_father_any'`star_T2_father_any' \\" _n

file write resultsfile "N & `N_C_mother' & `N_T1_mother' & `N_T2_mother' & `N_C_father' & `N_T1_father' & `N_T2_father' \\" _n

file write resultsfile "\bottomrule" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\small" _n
file write resultsfile "Notes: Stars indicate significance relative to the control group. " _n
file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write resultsfile "Residualized means control for strata and enumerator fixed effects." _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{table}" _n

file close resultsfile




*------------------------------------------------------------*
*                      1m & 2m & 3m & 6m                     *
*------------------------------------------------------------*

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2024-11-03", "YMD")
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


merge 1:m firstname using "$proc/1m_results.dta"
drop if _merge == 2
gen response_1m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 1m
save `1m'

use `participants', clear
merge 1:m firstname using "$proc/2m&6w_results.dta"
drop if _merge == 2
gen response_2m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 2m
save `2m'

use `participants', clear
merge 1:m firstname using "$proc/3m_results.dta"
drop if _merge == 2
gen response_3m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 3m
save `3m'

use `participants', clear
merge 1:m firstname using "$proc/6m_results.dta"
drop if _merge == 2
gen response_6m =(_merge == 3)
drop _merge
drop if firstname == ""

tempfile 6m
save `6m'

use `1m', clear
merge 1:1 firstname using `2m', force
drop if _merge == 1
drop _merge

merge 1:1 firstname using `3m', force
drop if _merge == 1
drop _merge 

merge 1:1 firstname using `6m', force
drop if _merge == 1
drop _merge 

merge m:1 hospital_id using ///
"/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/clustered_data.dta"
keep if _merge == 3
drop _merge

//fix some errors
replace hospital_id = "D00334154" if firstname == "17638375569"
replace hospital_id = "D00336813" if firstname == "17621431230"

gen any_response = (response_1m == 1 | response_2m == 1 | response_3m == 1 | response_6m == 1) 

gen C = (treatment == "C")
gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

gen mother = (parent == "M")
drop attribute_*

duplicates drop firstname, force

// Residualize response means
reg response_1m i.strata i.enumerator_id, cluster(cluster_var)
predict response_1m_resid, residuals
reg response_2m i.strata i.enumerator_id, cluster(cluster_var)
predict response_2m_resid, residuals
reg response_3m i.strata i.enumerator_id, cluster(cluster_var)
predict response_3m_resid, residuals
reg response_6m i.strata i.enumerator_id, cluster(cluster_var)
predict response_6m_resid, residuals
reg any_response i.strata i.enumerator_id, cluster(cluster_var)
predict any_response_resid, residuals

sum response_1m
scalar mean_response_1m = r(mean)

sum response_2m
scalar mean_response_2m = r(mean)

sum response_3m
scalar mean_response_3m = r(mean)

sum response_6m
scalar mean_response_6m = r(mean)

sum any_response
scalar mean_any_response = r(mean)

gen response_resid_mean_1m = response_1m_resid + mean_response_1m   
gen response_resid_mean_2m = response_2m_resid + mean_response_2m
gen response_resid_mean_3m = response_3m_resid + mean_response_3m
gen response_resid_mean_6m = response_6m_resid + mean_response_6m
gen any_response_resid_mean = any_response_resid + mean_any_response


gen T1_mother = (T1==1 & mother==1)
gen T2_mother = (T2==1 & mother==1)
gen C_mother  = (T1==0 & T2==0 & mother==1)

gen T1_father = (T1==1 & mother==0)
gen T2_father = (T2==1 & mother==0)
gen C_father  = (T1==0 & T2==0 & mother==0)


foreach grp in T1_mother T2_mother C_mother T1_father T2_father C_father {
    su response_resid_mean_1m if `grp'
    local mean_`grp'_1m: di %6.3f r(mean)
    su response_resid_mean_2m if `grp'
    local mean_`grp'_2m : di %6.3f r(mean)
    su response_resid_mean_3m if `grp'
    local mean_`grp'_3m : di %6.3f r(mean)
    su response_resid_mean_6m if `grp'
    local mean_`grp'_6m : di %6.3f r(mean)
    su any_response_resid_mean if `grp'
    local mean_`grpe'_any: di %6.3f r(mean)
}



* ---------- Mothers ----------
preserve
keep if mother == 1
local waves 1m 2m 3m 6m

foreach wave in `waves' {
    reg response_`wave' T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
    matrix r_m1 = r(table)
    local p_T1_mother_`wave' = r_m1[4, 1]

    local star_T1_mother_`wave' ""
    if (`p_T1_mother_`wave'' < 0.1) local star_T1_mother_`wave' "*"
    if (`p_T1_mother_`wave'' < 0.05) local star_T1_mother_`wave' "**"
    if (`p_T1_mother_`wave'' < 0.01) local star_T1_mother_`wave' "***"

    reg response_`wave' T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
    matrix r_m2 = r(table)
    local p_T2_mother_`wave' = r_m2[4, 1]

    local star_T2_mother_`wave' ""
    if (`p_T2_mother_`wave'' < 0.1) local star_T2_mother_`wave' "*"
    if (`p_T2_mother_`wave'' < 0.05) local star_T2_mother_`wave' "**"
    if (`p_T2_mother_`wave'' < 0.01) local star_T2_mother_`wave' "***"
}

* any
reg any_response T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_e1 = r(table)
local p_T1_mother_any = r_e1[4, 1]

local star_T1_mother_any ""
if (`p_T1_mother_any' < 0.1) local star_T1_mother_any "*"
if (`p_T1_mother_any' < 0.05) local star_T1_mother_any "**"
if (`p_T1_mother_any' < 0.01) local star_T1_mother_any "***"

reg any_response T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_e2 = r(table)
local p_T2_mother_any = r_e2[4, 1]

local star_T2_mother_any ""
if (`p_T2_mother_any' < 0.1) local star_T2_mother_any "*"
if (`p_T2_mother_any' < 0.05) local star_T2_mother_any "**"
if (`p_T2_mother_any' < 0.01) local star_T2_mother_any "***"

count if C == 1 & mother == 1
local N_C_mother = r(N)

count if T1 == 1 & mother == 1
local N_T1_mother = r(N)

count if T2 == 1 & mother == 1
local N_T2_mother = r(N)

restore

* ---------- Fathers ----------
preserve
keep if mother == 0
local waves 1m 2m 3m 6m

foreach wave in `waves' {
    reg response_`wave' T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
    matrix r_m1 = r(table)
    local p_T1_father_`wave' = r_m1[4, 1]

    local star_T1_father_`wave' ""
    if (`p_T1_father_`wave'' < 0.1) local star_T1_father_`wave' "*"
    if (`p_T1_father_`wave'' < 0.05) local star_T1_father_`wave' "**"
    if (`p_T1_father_`wave'' < 0.01) local star_T1_father_`wave' "***"

    reg response_`wave' T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
    matrix r_m2 = r(table)
    local p_T2_father_`wave' = r_m2[4, 1]

    local star_T2_father_`wave' ""
    if (`p_T2_father_`wave'' < 0.1) local star_T2_father_`wave' "*"
    if (`p_T2_father_`wave'' < 0.05) local star_T2_father_`wave' "**"
    if (`p_T2_father_`wave'' < 0.01) local star_T2_father_`wave' "***"
}

* any
reg any_response T1 i.strata i.enumerator_id if T2 == 0, cluster(cluster_var)
matrix r_e1 = r(table)
local p_T1_father_any = r_e1[4, 1]

local star_T1_father_any ""
if (`p_T1_father_any' < 0.1) local star_T1_father_any "*"
if (`p_T1_father_any' < 0.05) local star_T1_father_any "**"
if (`p_T1_father_any' < 0.01) local star_T1_father_any "***"

reg any_response T2 i.strata i.enumerator_id if T1 == 0, cluster(cluster_var)
matrix r_e2 = r(table)
local p_T2_father_any = r_e2[4, 1]

local star_T2_father_any ""
if (`p_T2_father_any' < 0.1) local star_T2_father_any "*"
if (`p_T2_father_any' < 0.05) local star_T2_father_any "**"
if (`p_T2_father_any' < 0.01) local star_T2_father_any "***"

count if C == 1 & mother == 0
local N_C_father = r(N)

count if T1 == 1 & mother == 0
local N_T1_father = r(N)

count if T2 == 1 & mother == 0
local N_T2_father = r(N)

restore


capture file close resultsfile
file open resultsfile using "$results/tables/response_across_wave.tex", write append

file write resultsfile "\begin{table}[htbp]" _n
file write resultsfile "\centering" _n
file write resultsfile "\caption{Residualized Response Means}" _n
file write resultsfile "\begin{tabular}{lcccccc}" _n
file write resultsfile "\toprule" _n
file write resultsfile "& \multicolumn{3}{c}{\textbf{Mother}} & \multicolumn{3}{c}{\textbf{Father}} \\" _n
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write resultsfile "\textbf{Measure} & Control & T1 & T2 & Control & T1 & T2 \\" _n
file write resultsfile "\midrule" _n

file write resultsfile "1m Response & `mean_C_mother_1m' & `mean_T1_mother_1m'`star_T1_mother_1m' & `mean_T2_mother_1m'`star_T2_mother_1m' & `mean_C_father_1m' & `mean_T1_father_1m'`star_T1_father_1m' & `mean_T2_father_1m'`star_T2_father_1m' \\" _n

file write resultsfile "2m Response & `mean_C_mother_2m' & `mean_T1_mother_2m'`star_T1_mother_2m' & `mean_T2_mother_2m'`star_T2_mother_2m' & `mean_C_father_2m' & `mean_T1_father_2m'`star_T1_father_2m' & `mean_T2_father_2m'`star_T2_father_2m' \\" _n
file write resultsfile "3m Response & `mean_C_mother_3m' & `mean_T1_mother_3m'`star_T1_mother_3m' & `mean_T2_mother_3m'`star_T2_mother_3m' & `mean_C_father_3m' & `mean_T1_father_3m'`star_T1_father_3m' & `mean_T2_father_3m'`star_T2_father_3m' \\" _n
file write resultsfile "6m Response & `mean_C_mother_6m' & `mean_T1_mother_6m'`star_T1_mother_6m' & `mean_T2_mother_6m'`star_T2_mother_6m' & `mean_C_father_6m' & `mean_T1_father_6m'`star_T1_father_6m' & `mean_T2_father_6m'`star_T2_father_6m' \\" _n
file write resultsfile "Any Response & `mean_C_mother_any' & `mean_T1_mother_any'`star_T1_mother_any' & `mean_T2_mother_any'`star_T2_mother_any' & `mean_C_father_any' & `mean_T1_father_any'`star_T1_father_any' & `mean_T2_father_any'`star_T2_father_any' \\" _n

file write resultsfile "N & `N_C_mother' & `N_T1_mother' & `N_T2_mother' & `N_C_father' & `N_T1_father' & `N_T2_father' \\" _n

file write resultsfile "\bottomrule" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\small" _n
file write resultsfile "Notes: Stars indicate significance relative to the control group. " _n
file write resultsfile "\$^{*}\$ \$p<0.10\$, \$^{**}\$ \$p<0.05\$, \$^{***}\$ \$p<0.01\$." _n
file write resultsfile "Residualized means control for strata and enumerator fixed effects." _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{table}" _n

file close resultsfile



log close
