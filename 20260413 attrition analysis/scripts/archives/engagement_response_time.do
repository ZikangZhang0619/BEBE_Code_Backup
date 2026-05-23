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
drop tid reminded firstname lastname completed validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m1_remindercount

duplicates drop hospital_id mother, force
drop if hospital_id == ""

gen m1_attrit = (m1_remindercount == 5 & m1_delay_days == .)
gen m1_complete = 1 - m1_attrit
drop m1_attrit

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
drop tid reminded firstname lastname completed validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m2_remindercount

duplicates drop hospital_id mother, force
drop if hospital_id == ""

gen m2_attrit = (m2_remindercount == 5 & m2_delay_days == .)
gen m2_complete = 1 - m2_attrit
drop m2_attrit
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
drop tid reminded firstname lastname completed validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m3_remindercount
duplicates drop hospital_id mother, force
drop if hospital_id == ""


gen m3_attrit = (m3_remindercount == 5 & m3_delay_days == .)
gen m3_complete = 1 - m3_attrit
drop m3_attrit
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
drop tid reminded firstname lastname completed validfrom

order hospital_id mother
destring remindercount, replace
rename remindercount m6_remindercount
duplicates drop hospital_id mother, force
drop if hospital_id == ""


gen m6_attrit = (m6_remindercount == 5 & m6_delay_days == .)
gen m6_complete = 1 - m6_attrit
drop m6_attrit
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


save "$proc/engagement_response_time.dta", replace


* ================================================================
* ===================   REGRESSION ANALYSIS    ===================
* ================================================================

use "$proc/engagement_response_time.dta", clear
order hospital_id mother lastname treatment date 


local m1_dependent_var m1_delay_days m2_delay_days m3_delay_days m6_delay_days
local independent_vars m1_father_involv_score m2_father_involv_score m6_father_involv_score

estimates clear

* 对母亲和父亲分别进行分析
foreach parent in 1 0 {
    preserve
    keep if mother == `parent'
    
    local col = 0
    foreach dv of local dependent_var {
        local col = `col' + 1
        local row = 0
        
        foreach iv of local independent_vars {
            local row = `row' + 1
            
            quietly reg `dv' `iv' i.treatment i.strata i.enumerator_id, cluster(cluster_var)
            
            * 存储系数和标准误（添加parent标识）
            local beta_`row'_`col'_`parent' = _b[`iv']
            local se_`row'_`col'_`parent' = _se[`iv']
            local t_`row'_`col'_`parent' = _b[`iv']/_se[`iv']
            local p_`row'_`col'_`parent' = 2*ttail(e(df_r), abs(`t_`row'_`col'_`parent''))
            
            * 生成显著性星号
            if `p_`row'_`col'_`parent'' <= 0.01 {
                local stars_`row'_`col'_`parent' "***"
            }
            else if `p_`row'_`col'_`parent'' <= 0.05 {
                local stars_`row'_`col'_`parent' "**"
            }
            else if `p_`row'_`col'_`parent'' <= 0.10 {
                local stars_`row'_`col'_`parent' "*"
            }
            else {
                local stars_`row'_`col'_`parent' ""
            }
            
            * 格式化系数和标准误
            local beta_fmt_`row'_`col'_`parent' : display %9.3f `beta_`row'_`col'_`parent''
            local se_fmt_`row'_`col'_`parent' : display %9.3f `se_`row'_`col'_`parent''
        }
    }
    restore
}

* 创建LaTeX表格
capture file close myfile
file open myfile using "$results/tables/engagement_regression_results.tex", write append

* 写入landscape环境和表格头
file write myfile "\begin{landscape}" _n
file write myfile "\begin{table}[htbp]" _n
file write myfile "\centering" _n
file write myfile "\caption{Regression Results by Parent Type (2m, 3m, 6m Surveys)}" _n
file write myfile "\small" _n  // 缩小字体以适应页面
file write myfile "\begin{tabular}{lcccccccccccccccccc}" _n
file write myfile "\hline\hline" _n

* 写入列标题 - 第一行
file write myfile " & \multicolumn{9}{c}{Mothers} & \multicolumn{9}{c}{Fathers} \\" _n
file write myfile "\cmidrule(lr){2-10} \cmidrule(lr){11-19}" _n

* 写入列标题 - 第二行（时期）
file write myfile " & \multicolumn{3}{c}{2 Months} & \multicolumn{3}{c}{3 Months} & \multicolumn{3}{c}{6 Months} & \multicolumn{3}{c}{2 Months} & \multicolumn{3}{c}{3 Months} & \multicolumn{3}{c}{6 Months} \\" _n
file write myfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7} \cmidrule(lr){8-10} \cmidrule(lr){11-13} \cmidrule(lr){14-16} \cmidrule(lr){17-19}" _n

* 写入列标题 - 第三行（变量名）
file write myfile " "
forvalues i = 1/2 {  // 母亲和父亲
    file write myfile " & Reminder & Delay & Complete"
    file write myfile " & Reminder & Delay & Complete"
    file write myfile " & Reminder & Delay & Complete"
}
file write myfile " \\" _n

* 写入列标题 - 第四行（单位）
file write myfile " "
forvalues i = 1/2 {  // 母亲和父亲
    file write myfile " & Count & Days & "
    file write myfile " & Count & Days & "
    file write myfile " & Count & Days & "
}
file write myfile " \\" _n
file write myfile "\hline" _n

* 写入每一行（每个自变量）
local row = 0
foreach iv of local independent_vars {
    local row = `row' + 1
    
    * 使用完整变量名，但需要转义下划线
    local var_display = subinstr("`iv'", "_", "\_", .)
    
    * 变量名行
    file write myfile "`var_display'" 
    
    * 系数行 - 先母亲（9列），后父亲（9列）
    forvalues col = 1/9 {
        file write myfile " & `beta_fmt_`row'_`col'_1'`stars_`row'_`col'_1'"
    }
    forvalues col = 1/9 {
        file write myfile " & `beta_fmt_`row'_`col'_0'`stars_`row'_`col'_0'"
    }
    file write myfile " \\" _n
    
    * 标准误行
    file write myfile " "
    forvalues col = 1/9 {
        file write myfile " & (`se_fmt_`row'_`col'_1')"
    }
    forvalues col = 1/9 {
        file write myfile " & (`se_fmt_`row'_`col'_0')"
    }
    file write myfile " \\" _n
    
    * 添加一些空间
    if `row' < 10 {
        file write myfile "[0.15cm]" _n
    }
}

* 写入表格尾部
file write myfile "\hline\hline" _n
file write myfile "\end{tabular}" _n
file write myfile "\begin{tablenotes}" _n
file write myfile "\small" _n
file write myfile "\item Notes: Standard errors clustered at the cluster level in parentheses." _n
file write myfile "\item All regressions include treatment, strata and enumerator fixed effects." _n
file write myfile "\item *** p$<$0.01, ** p$<$0.05, * p$<$0.10" _n
file write myfile "\end{tablenotes}" _n
file write myfile "\end{table}" _n
file write myfile "\end{landscape}" _n

* 关闭文件
file close myfile

di "LaTeX表格已保存到 $results/tables/engagement_regression_results.tex"





* ==============================================================
* ======================== Difference ==========================
* ================================================================


use "$proc/engagement_response_time.dta", clear
order hospital_id mother lastname treatment date 
rename bl_father_identity_importance bl_f_iden_importance

preserve
keep if mother == 1
local varlist m1_father_involv_score_z m1_father_care_alone m1_own_close_baby ///
m1_partner_close_baby m1_partner_relationship m1_belief_score bl_f_iden_importance ///
bl_attitude bl_exp_father_involv_z bl_belief_score m1_remindercount m1_delay_days m1_complete ///
m2_remindercount m2_delay_days m2_complete m3_remindercount m3_delay_days m3_complete m6_remindercount m6_delay_days m6_complete
foreach var in `varlist'{
    rename `var' m_`var'
}
tempfile mother
save `mother'
restore

keep if mother == 0
local varlist m1_father_involv_score_z m1_father_care_alone m1_own_close_baby ///
m1_partner_close_baby m1_partner_relationship m1_belief_score bl_f_iden_importance ///
bl_attitude bl_exp_father_involv_z bl_belief_score m1_remindercount m1_delay_days m1_complete ///
m2_remindercount m2_delay_days m2_complete m3_remindercount m3_delay_days m3_complete m6_remindercount m6_delay_days m6_complete
foreach var in `varlist'{
    rename `var' f_`var'
}
merge 1:1 hospital_id using `mother'

local varlist m1_father_involv_score_z m1_father_care_alone m1_partner_relationship ///
m1_belief_score bl_f_iden_importance bl_attitude bl_exp_father_involv_z bl_belief_score
foreach var in `varlist'{
    gen  diff_`var' = m_`var' - f_`var'

}

gen diff_m_close_to_baby = m_m1_own_close_baby - f_m1_partner_close_baby
gen diff_f_close_to_baby = f_m1_own_close_baby - m_m1_partner_close_baby

save "$proc/diff_engagement_response_time", replace






use "$proc/diff_engagement_response_time.dta", clear
order hospital_id mother lastname treatment date 

* ============ 1m survey response pattern ===================

local independent_vars diff_bl_f_iden_importance diff_bl_attitude diff_bl_exp_father_involv_z diff_bl_belief_score
local father_response_pattern f_m1_remindercount f_m1_delay_days f_m1_complete 
local mother_response_pattern m_m1_remindercount m_m1_delay_days m_m1_complete 

estimates clear

* 对母亲和父亲分别进行分析
    
    local col = 0
    foreach dv of local mother_response_pattern {
        local col = `col' + 1
        local row = 0
        
        foreach iv of local independent_vars {
            local row = `row' + 1
            
            quietly reg `dv' `iv' i.treatment i.strata i.enumerator_id, cluster(cluster_var)
            
            * 存储系数和标准误（添加parent标识）
            local beta_`row'_`col'_mother = _b[`iv']
            local se_`row'_`col'_mother = _se[`iv']
            local t_`row'_`col'_mother = _b[`iv']/_se[`iv']
            local p_`row'_`col'_mother = 2*ttail(e(df_r), abs(`t_`row'_`col'_mother'))
            
            * 生成显著性星号
            if `p_`row'_`col'_mother' <= 0.01 {
                local stars_`row'_`col'_mother "***"
            }
            else if `p_`row'_`col'_mother' <= 0.05 {
                local stars_`row'_`col'_mother "**"
            }
            else if `p_`row'_`col'_mother' <= 0.10 {
                local stars_`row'_`col'_mother "*"
            }
            else {
                local stars_`row'_`col'_mother ""
            }
            
            * 格式化系数和标准误
            local beta_fmt_`row'_`col'_mother : display %9.3f `beta_`row'_`col'_mother'
            local se_fmt_`row'_`col'_mother : display %9.3f `se_`row'_`col'_mother'
        }
    }



    local col = 0
    foreach dv of local father_response_pattern {
        local col = `col' + 1
        local row = 0
        
        foreach iv of local independent_vars {
            local row = `row' + 1
            
            quietly reg `dv' `iv' i.treatment i.strata i.enumerator_id, cluster(cluster_var)
            
            * 存储系数和标准误（添加parent标识）
            local beta_`row'_`col'_father = _b[`iv']
            local se_`row'_`col'_father = _se[`iv']
            local t_`row'_`col'_father = _b[`iv']/_se[`iv']
            local p_`row'_`col'_father = 2*ttail(e(df_r), abs(`t_`row'_`col'_father'))
            
            * 生成显著性星号
            if `p_`row'_`col'_father' <= 0.01 {
                local stars_`row'_`col'_father "***"
            }
            else if `p_`row'_`col'_father' <= 0.05 {
                local stars_`row'_`col'_father "**"
            }
            else if `p_`row'_`col'_father' <= 0.10 {
                local stars_`row'_`col'_father "*"
            }
            else {
                local stars_`row'_`col'_father ""
            }
            
            * 格式化系数和标准误
            local beta_fmt_`row'_`col'_father : display %9.3f `beta_`row'_`col'_father'
            local se_fmt_`row'_`col'_father : display %9.3f `se_`row'_`col'_father'
        }
    }

* 创建LaTeX表格
capture file close myfile
file open myfile using "$results/tables/engagement_regression_results.tex", write replace

* 写入landscape环境和表格头
file write myfile "\begin{landscape}" _n
file write myfile "\begin{table}[htbp]" _n
file write myfile "\centering" _n
file write myfile "\caption{Regression Results by Parent Type}" _n
file write myfile "\begin{tabular}{lcccccc}" _n
file write myfile "\hline\hline" _n

* 写入列标题 - 第一行
file write myfile " & \multicolumn{3}{c}{Mothers} & \multicolumn{3}{c}{Fathers} \\" _n
file write myfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n

* 写入列标题 - 第二行
file write myfile " & (1) & (2) & (3) & (4) & (5) & (6) \\" _n
file write myfile " & m1\_reminder & m1\_delay & m1\_complete & m1\_reminder & m1\_delay & m1\_complete \\" _n
file write myfile " & count & days &  & count & days &  \\" _n
file write myfile "\hline" _n

* 写入每一行（每个自变量）
local row = 0
foreach iv of local independent_vars {
    local row = `row' + 1
    
    * 使用完整变量名，但需要转义下划线
    local var_display = subinstr("`iv'", "_", "\_", .)
    
    * 变量名行
    file write myfile "`var_display'" 
    
    * 系数行 - 先母亲，后父亲
    forvalues col = 1/3 {
        file write myfile " & `beta_fmt_`row'_`col'_mother'`stars_`row'_`col'_mother'"
    }
    forvalues col = 1/3 {
        file write myfile " & `beta_fmt_`row'_`col'_father'`stars_`row'_`col'_father'"
    }
    file write myfile " \\" _n
    
    * 标准误行
    file write myfile " "
    forvalues col = 1/3 {
        file write myfile " & (`se_fmt_`row'_`col'_mother')"
    }
    forvalues col = 1/3 {
        file write myfile " & (`se_fmt_`row'_`col'_father')"
    }
    file write myfile " \\" _n
    
    * 添加一些空间
    if `row' < 4 {
        file write myfile "[0.2cm]" _n
    }
}

* 写入表格尾部
file write myfile "\hline\hline" _n
file write myfile "\end{tabular}" _n
file write myfile "\begin{tablenotes}" _n
file write myfile "\small" _n
file write myfile "\item Notes: Standard errors clustered at the cluster level in parentheses." _n
file write myfile "\item All regressions include strata and enumerator fixed effects." _n
file write myfile "\item *** p$<$0.01, ** p$<$0.05, * p$<$0.10" _n
file write myfile "\end{tablenotes}" _n
file write myfile "\end{table}" _n
file write myfile "\end{landscape}" _n

* 关闭文件
file close myfile

di "LaTeX表格已保存到 $results/tables/engagement_regression_results.tex"





























* =====================================================
* ================== MAKE GRAPHS ======================
* =====================================================

//////////// CORRELATION TABLE /////////////

use "$proc/engagement_response_time.dta", clear
/* drop if m1_father_involv_score_z == . */


local dependent_var m1_delay_days m2_delay_days m3_delay_days m6_delay_days 

matrix correlations = J(9, 3, .)
matrix colnames correlations = "Correlation" "P_value" "N_obs"
matrix rownames correlations = "M2_Reminder_Count" "M2_Delay_Days" "M2_Complete" ///
                               "M3_Reminder_Count" "M3_Delay_Days" "M3_Complete" ///
                               "M6_Reminder_Count" "M6_Delay_Days" "M6_Complete"


file open latexfile using "$results/tables/correlation_table.tex", write replace


file write latexfile "\begin{table}[htbp]" _n
file write latexfile "\centering" _n
file write latexfile "\caption{Correlations with Father Involvement Score (M1)}" _n
file write latexfile "\label{tab:correlations}" _n
file write latexfile "\begin{tabular}{lccc}" _n
file write latexfile "\toprule" _n
file write latexfile "Variable & Correlation & P-value & N \\" _n
file write latexfile "\midrule" _n

local i = 1
foreach var in `dependent_var' {
    correlate `var' m1_father_involv_score_z
    local corr_`i' = r(rho)
    local n_`i' = r(N)
    
    matrix correlations[`i', 1] = `corr_`i''
    matrix correlations[`i', 3] = `n_`i''
    
    quietly pwcorr `var' m1_father_involv_score_z, sig
    local pval_`i' = r(sig)[1,2]
    matrix correlations[`i', 2] = `pval_`i''
    
    local corr_fmt = string(round(`corr_`i'', 0.001), "%6.3f")
    
    local pval_fmt = string(round(`pval_`i'', 0.001), "%6.3f")
    
    local stars = ""
    if `pval_`i'' < 0.01 {
        local stars = "***"
    }
    else if `pval_`i'' < 0.05 {
        local stars = "**"
    }
    else if `pval_`i'' < 0.10 {
        local stars = "*"
    }
    
    local varname = "`var'"
    local varname = subinstr("`varname'", "m2_", "M2 ", .)
    local varname = subinstr("`varname'", "m3_", "M3 ", .)
    local varname = subinstr("`varname'", "m6_", "M6 ", .)
    local varname = subinstr("`varname'", "remindercount", "Reminder Count", .)
    local varname = subinstr("`varname'", "delay_days", "Delay Days", .)
    local varname = subinstr("`varname'", "complete", "Complete", .)
    
    file write latexfile "`varname' & `corr_fmt'`stars' & `pval_fmt' & `n_`i'' \\" _n
    
    di "`varname': r = `corr_fmt'`stars', p = `pval_fmt', N = `n_`i''"
    
    local i = `i' + 1
}

file write latexfile "\bottomrule" _n
file write latexfile "\end{tabular}" _n
file write latexfile "\begin{tablenotes}" _n
file write latexfile "\footnotesize" _n
file write latexfile "\item \textit{Notes:} *** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.10. " _n
file write latexfile "Pearson correlation coefficients between engagement variables and " _n
file write latexfile "standardized father involvement score at Month 1." _n
file write latexfile "\end{tablenotes}" _n
file write latexfile "\end{table}" _n

file close latexfile





//////////////// BINSCATTER GRAPH /////////////////
use "$proc/engagement_response_time.dta", clear
tab mother, missing
set scheme s1color

* 定义8个回归的变量对应关系
local reg1_y "m1_delay_days"
local reg1_x "m1_father_involv_score_z"
local reg1_name "M1 Delay Days vs M1 Father Involvement"

local reg2_y "m2_delay_days"
local reg2_x "m1_father_involv_score_z"
local reg2_name "M2 Delay Days vs M1 Father Involvement"

local reg3_y "m3_delay_days"
local reg3_x "m1_father_involv_score_z"
local reg3_name "M3 Delay Days vs M1 Father Involvement"

local reg4_y "m3_delay_days"
local reg4_x "m2_father_involv_score_z"
local reg4_name "M3 Delay Days vs M2 Father Involvement"

local reg5_y "m6_delay_days"
local reg5_x "m1_father_involv_score_z"
local reg5_name "M6 Delay Days vs M1 Father Involvement"

local reg6_y "m6_delay_days"
local reg6_x "m2_father_involv_score_z"
local reg6_name "M6 Delay Days vs M2 Father Involvement"

local reg7_y "m6_delay_days"
local reg7_x "m6_father_involv_score_z"
local reg7_name "M6 Delay Days vs M6 Father Involvement"

local reg8_y "m2_delay_days"
local reg8_x "m2_father_involv_score_z"
local reg8_name "M2 Delay Days vs M2 Father Involvement (Alt)"

* ============================================================================
* MOTHERS' REPORTS (mother == 1)
* ============================================================================

preserve
keep if mother == 1
di "Sample size for mothers: " _N

* 为8个回归分别画图
forvalues i = 1/8 {
    local y_var "`reg`i'_y'"
    local x_var "`reg`i'_x'"
    local title "`reg`i'_name'"
    
    * 检查样本量
    quietly count if !missing(`y_var') & !missing(`x_var')
    local n_obs = r(N)
    
    if `n_obs' > 0 {
        * 清理变量名用于标题
        local x_clean = "`x_var'"
        local x_clean = subinstr("`x_clean'", "m1_father_involv_score_z", "M1 Father Involvement", .)
        local x_clean = subinstr("`x_clean'", "m2_father_involv_score_z", "M2 Father Involvement", .)
        local x_clean = subinstr("`x_clean'", "m6_father_involv_score_z", "M6 Father Involvement", .)
        
        local y_clean = "`y_var'"
        local y_clean = subinstr("`y_clean'", "m1_delay_days", "M1 Delay Days", .)
        local y_clean = subinstr("`y_clean'", "m2_delay_days", "M2 Delay Days", .)
        local y_clean = subinstr("`y_clean'", "m3_delay_days", "M3 Delay Days", .)
        local y_clean = subinstr("`y_clean'", "m6_delay_days", "M6 Delay Days", .)
        
        binscatter `y_var' `x_var', ///
            title("`y_clean' vs `x_clean' (Mothers' Reports)", size(medium)) ///
            xtitle("`x_clean'", size(small)) ///
            ytitle("`y_clean'", size(small)) ///
            note("Regression `i': N = `n_obs'. Binned scatter plot with linear fit.", size(vsmall)) ///
            msymbol(circle_hollow) ///
            mcolor(navy) ///
            lcolor(maroon) ///
            name(mothers_reg`i', replace)
        
        * 保存单独的图
        graph export "$results/figures/binscatter_mothers_`y_var'_on_`x_var'.png", replace width(800) height(600)
        
        di "Created graph for mothers - Regression `i': `y_clean' vs `x_clean' (N = `n_obs')"
    }
    else {
        di "Skipping Regression `i' for mothers: insufficient data (N = `n_obs')"
    }
}

restore

* ============================================================================
* FATHERS' REPORTS (mother == 0)
* ============================================================================

preserve
keep if mother == 0
di "Sample size for fathers: " _N

* 为8个回归分别画图
forvalues i = 1/8 {
    local y_var "`reg`i'_y'"
    local x_var "`reg`i'_x'"
    local title "`reg`i'_name'"
    
    * 检查样本量
    quietly count if !missing(`y_var') & !missing(`x_var')
    local n_obs = r(N)
    
    if `n_obs' > 0 {
        * 清理变量名用于标题
        local x_clean = "`x_var'"
        local x_clean = subinstr("`x_clean'", "m1_father_involv_score_z", "M1 Father Involvement", .)
        local x_clean = subinstr("`x_clean'", "m2_father_involv_score_z", "M2 Father Involvement", .)
        local x_clean = subinstr("`x_clean'", "m6_father_involv_score_z", "M6 Father Involvement", .)
        
        local y_clean = "`y_var'"
        local y_clean = subinstr("`y_clean'", "m1_delay_days", "M1 Delay Days", .)
        local y_clean = subinstr("`y_clean'", "m2_delay_days", "M2 Delay Days", .)
        local y_clean = subinstr("`y_clean'", "m3_delay_days", "M3 Delay Days", .)
        local y_clean = subinstr("`y_clean'", "m6_delay_days", "M6 Delay Days", .)
        
        binscatter `y_var' `x_var', ///
            title("`y_clean' vs `x_clean' (Fathers' Reports)", size(medium)) ///
            xtitle("`x_clean'", size(small)) ///
            ytitle("`y_clean'", size(small)) ///
            note("Regression `i': N = `n_obs'. Binned scatter plot with linear fit.", size(vsmall)) ///
            msymbol(triangle_hollow) ///
            mcolor(darkgreen) ///
            lcolor(orange) ///
            name(fathers_reg`i', replace)
        
        * 保存单独的图
        graph export "$results/figures/binscatter_fathers_`y_var'_on_`x_var'.png", replace width(800) height(600)
        
        di "Created graph for fathers - Regression `i': `y_clean' vs `x_clean' (N = `n_obs')"
    }
    else {
        di "Skipping Regression `i' for fathers: insufficient data (N = `n_obs')"
    }
}

restore

* ============================================================================
* 创建组合图 (可选)
* ============================================================================

* 为每个回归创建母亲和父亲的对比图
forvalues i = 1/8 {
    local y_var "`reg`i'_y'"
    local x_var "`reg`i'_x'"
    
    * 检查是否两个图都存在
    capture graph describe mothers_reg`i'
    local mothers_exists = _rc == 0
    capture graph describe fathers_reg`i'
    local fathers_exists = _rc == 0
    
    if `mothers_exists' & `fathers_exists' {
        graph combine mothers_reg`i' fathers_reg`i', ///
            title("Regression `i': `reg`i'_name'", size(medium)) ///
            note("Comparison between mothers' and fathers' reports", size(small)) ///
            name(combined_reg`i', replace) ///
            rows(1) cols(2)
        
        graph export "$results/figures/combined_reg`i'_`y_var'_on_`x_var'.png", replace width(1200) height(600)
        
        di "Created combined graph for Regression `i'"
    }
}

di "所有回归图表已生成完成！"
di "- 母亲报告图：binscatter_mothers_reg*"
di "- 父亲报告图：binscatter_fathers_reg*" 
di "- 组合对比图：combined_reg*"


* ============================================================================
* REGRESSION RESULTS
* ============================================================================
use "$proc/engagement_response_time.dta", clear
order hospital_id mother lastname treatment date 

* =========== mothers ===============
keep if mother == 0
local dependent_var m2_remindercount m2_delay_days m2_complete m3_remindercount m3_delay_days m3_complete m6_remindercount m6_delay_days m6_complete
local independent_vars m1_father_involv_score_z 

// 清除之前的估计结果
estimates clear

// 回归分析
// 1. m1_delay_days on m1_father_involv_score
regress m1_delay_days m1_father_involv_score_z
estimates store reg1
local r1_coef = string(_b[m1_father_involv_score_z], "%9.3f")
local r1_se = string(_se[m1_father_involv_score_z], "%9.3f") 
local r1_t = string(_b[m1_father_involv_score_z]/_se[m1_father_involv_score_z], "%9.3f")
local r1_r2 = string(e(r2), "%9.3f")
local r1_n = e(N)

// 2. m2_delay_days on m1_father_involv_score_z
regress m2_delay_days m1_father_involv_score_z
estimates store reg2
local r2_coef = string(_b[m1_father_involv_score_z], "%9.3f")
local r2_se = string(_se[m1_father_involv_score_z], "%9.3f")
local r2_t = string(_b[m1_father_involv_score_z]/_se[m1_father_involv_score_z], "%9.3f")
local r2_r2 = string(e(r2), "%9.3f")
local r2_n = e(N)

// 8. m2_delay_days on m1_father_involv_score_z
regress m2_delay_days m2_father_involv_score_z
estimates store reg8
local r8_coef = string(_b[m2_father_involv_score_z], "%9.3f")
local r8_se = string(_se[m2_father_involv_score_z], "%9.3f")
local r8_t = string(_b[m2_father_involv_score_z]/_se[m2_father_involv_score_z], "%9.3f")
local r8_r2 = string(e(r2), "%9.3f")
local r8_n = e(N)

// 3. m3_delay_days on m1_father_involv_score_z
regress m3_delay_days m1_father_involv_score_z
estimates store reg3
local r3_coef = string(_b[m1_father_involv_score_z], "%9.3f")
local r3_se = string(_se[m1_father_involv_score_z], "%9.3f")
local r3_t = string(_b[m1_father_involv_score_z]/_se[m1_father_involv_score_z], "%9.3f")
local r3_r2 = string(e(r2), "%9.3f")
local r3_n = e(N)

// 4. m3_delay_days on m2_father_involv_score_z
regress m3_delay_days m2_father_involv_score_z
estimates store reg4
local r4_coef = string(_b[m2_father_involv_score_z], "%9.3f")
local r4_se = string(_se[m2_father_involv_score_z], "%9.3f")
local r4_t = string(_b[m2_father_involv_score_z]/_se[m2_father_involv_score_z], "%9.3f")
local r4_r2 = string(e(r2), "%9.3f")
local r4_n = e(N)

// 5. m6_delay_days on m1_father_involv_score_z
regress m6_delay_days m1_father_involv_score_z
estimates store reg5
local r5_coef = string(_b[m1_father_involv_score_z], "%9.3f")
local r5_se = string(_se[m1_father_involv_score_z], "%9.3f")
local r5_t = string(_b[m1_father_involv_score_z]/_se[m1_father_involv_score_z], "%9.3f")
local r5_r2 = string(e(r2), "%9.3f")
local r5_n = e(N)

// 6. m6_delay_days on m2_father_involv_score_z
regress m6_delay_days m2_father_involv_score_z
estimates store reg6
local r6_coef = string(_b[m2_father_involv_score_z], "%9.3f")
local r6_se = string(_se[m2_father_involv_score_z], "%9.3f")
local r6_t = string(_b[m2_father_involv_score_z]/_se[m2_father_involv_score_z], "%9.3f")
local r6_r2 = string(e(r2), "%9.3f")
local r6_n = e(N)

// 7. m6_delay_days on m6_father_involv_score_z
regress m6_delay_days m6_father_involv_score_z
estimates store reg7
local r7_coef = string(_b[m6_father_involv_score_z], "%9.3f")
local r7_se = string(_se[m6_father_involv_score_z], "%9.3f")
local r7_t = string(_b[m6_father_involv_score_z]/_se[m6_father_involv_score_z], "%9.3f")
local r7_r2 = string(e(r2), "%9.3f")
local r7_n = e(N)

// 生成LaTeX表格

// 生成LaTeX表格
file open resultstab using "$results/tables/regression_results.tex", write replace

file write resultstab "\begin{table}[htbp]" _n
file write resultstab "\centering" _n
file write resultstab "\caption{Regression Results: Father Involvement Scores on Delay Days}" _n
file write resultstab "\label{tab:regression_results}" _n
file write resultstab "\resizebox{\textwidth}{!}{%" _n
file write resultstab "\begin{tabular}{lcccccccc}" _n
file write resultstab "\hline" _n
file write resultstab "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\" _n
file write resultstab "& M1 Delay & M2 Delay & M2 Delay & M3 Delay & M3 Delay & M6 Delay & M6 Delay & M6 Delay \\" _n
file write resultstab "& Days & Days & Days & Days & Days & Days & Days & Days \\" _n
file write resultstab "\hline" _n

// M1 Father Involvement 行
file write resultstab "M1 Father Involvement & `r1_coef' & `r2_coef' &  & `r3_coef' &  & `r5_coef' &  &  \\" _n
file write resultstab "& (`r1_se') & (`r2_se') && (`r3_se') &  & (`r5_se') &  &  \\" _n
file write resultstab "&  &  &  &  &  &  &  &  \\" _n

// M2 Father Involvement 行
file write resultstab "M2 Father Involvement &  &  &`r8_coef' &  & `r4_coef' &  & `r6_coef' &  \\" _n
file write resultstab "&  &  &  (`r8_se')  &  & (`r4_se') &  & (`r6_se') &  \\" _n
file write resultstab "&  &  &  &  &  &  &  &  \\" _n

// M6 Father Involvement 行
file write resultstab "M6 Father Involvement &  &  &  &  &  &  &  & `r7_coef' \\" _n
file write resultstab "&  &  &  &  &  &  &  & (`r7_se') \\" _n
file write resultstab "&  &  &  &  &  &  &  &  \\" _n

file write resultstab "\hline" _n
file write resultstab "Observations & `r1_n' & `r2_n' & `r8_n' & `r3_n' & `r4_n' & `r5_n' & `r6_n' & `r7_n' \\" _n
file write resultstab "R-squared & `r1_r2' & `r2_r2' & `r8_r2' & `r3_r2' & `r4_r2' & `r5_r2' & `r6_r2' & `r7_r2' \\" _n
file write resultstab "\hline" _n
file write resultstab "\end{tabular}}" _n
file write resultstab "\begin{flushleft}" _n
file write resultstab "Notes: Standard errors in parentheses. Each column represents a separate regression." _n
file write resultstab "M1, M2, M3, and M6 refer to measurements at 1, 2, 3, and 6 months respectively." _n
file write resultstab "\end{flushleft}" _n
file write resultstab "\end{table}" _n

file close resultstab


// 显示结果摘要
display "回归分析完成！"
display "LaTeX表格已保存为 regression_results.tex"


