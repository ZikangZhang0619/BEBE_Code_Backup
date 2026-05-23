

** Attrition by intervention reaction

** Haoyue Wu
** Feb 11. 2025

/* 
import delimited "$data/results-survey175343_new.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 checkenumerator g07q04 g07q05 g10q01 g10q02 g10q03 g10q04
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 )(enumerator randdate ward bed momname hospitalID eligible willingness willingness1 group )
rename (g07q04 g07q05 g10q01 g10q02 g10q03 g10q04)(video_helpful_f video_helpful_m video_feedback_f video_finish_f video_feedback_m video_finish_m )
gen survey_id = 2
tempfile 3
save `3' */



import delimited "$data/results-survey241113.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 checkenumerator hidedg07q04 hidedg07q05 vfs01 vfs02 vfs03 vfs04 vfs05 vfs06 vfs07 vfs08
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 )(enumerator randdate ward bed momname hospitalID eligible willingness willingness1 group )
rename (hidedg07q04 hidedg07q05 vfs01 vfs02 vfs03 vfs04 vfs05 vfs06 vfs07 vfs08)(video_helpful_f video_helpful_m video_like_f video_learn_f video_change_f video_recommend_f video_like_m video_learn_m video_change_m video_recommend_m)
tempfile 4
save `4'

import delimited "$data/results-survey241113.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 checkenumerator hidedg07q04 hidedg07q05 vfs01 vfs02 vfs03 vfs04 vfs05 vfs06 vfs07 vfs08 g09q04 g09q05 g10q01 g10q02 g10q03 g10q04
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 )(enumerator randdate ward bed momname hospitalID eligible willingness willingness1 group )
rename (hidedg07q04 hidedg07q05 vfs01 vfs02 vfs03 vfs04 vfs05 vfs06 vfs07 vfs08)(video_helpful_f video_helpful_m video_like_f video_learn_f video_change_f video_recommend_f video_like_m video_learn_m video_change_m video_recommend_m)
rename (g10q01 g10q02 g10q03 g10q04)(video_like_f_enu video_finish_f video_like_m_enu video_finish_m)
tempfile 4
save `4'

import delimited "$data/results-survey241204.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 checkenumerator vfs01 vfs03 vfs05 vfs07  g09q04 g09q05 g10q01 g10q02 g10q03 g10q04 
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g02q01 g02q02 g02q04 g01q08 )(enumerator randdate ward bed momname hospitalID eligible willingness willingness1 group )
rename (vfs01 vfs03 vfs05 vfs07 g10q01 g10q03)(video_rating_f video_change_f video_rating_m video_change_m video_like_f_enu video_like_m_enu)
rename (g10q02 g10q04)( video_finish_f video_finish_m)

replace hospitalID = 340632 if hospitalID == 340362
gen survey_id = 5
tempfile 5
save `5'

import delimited "$data/results-survey877826.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 hospitalbranch g01q03 g01q04sq001 g01q06 g01q07sq001  g01q07wsq001 g02q01 g02q02 g02q04 g01q08 checkenumerator vfs01 vfs03 vfs05 vfs07  g09q04 g09q05 g10q01 g10q02 g10q03 g10q04 
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g01q07wsq001 g02q01 g02q02 g02q04 g01q08 )(enumerator randdate ward bed momname hospitalID hospitalID_w eligible willingness willingness1 group )
rename (vfs01 vfs03 vfs05 vfs07 g10q01 g10q03)(video_rating_f video_change_f video_rating_m video_change_m video_like_f_enu video_like_m_enu)
rename (g10q02 g10q04)( video_finish_f video_finish_m)
gen survey_id = 6
tempfile 6
save `6'


import delimited "$data/results-survey250120.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 hospitalbranch g01q03 g01q04sq001 g01q06 g01q07sq001  g01q07wsq001 g02q01 g02q02 g02q04 g01q08 checkenumerator  vfs01 vfs03 vfs05 vfs07 g09q04 g09q05 g10q01 g10q02 g10q03 g10q04 
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g01q07wsq001 g02q01 g02q02 g02q04 g01q08 )(enumerator randdate ward bed momname hospitalID hospitalID_w eligible willingness willingness1 group )
rename (g10q02 g10q04)( video_finish_f video_finish_m)
rename (vfs01 vfs03 vfs05 vfs07 g10q01 g10q03)(video_rating_f video_change_f video_rating_m video_change_m video_like_f_enu video_like_m_enu)
gen survey_id = 7
tempfile 7
save `7'

import delimited "$data/results-survey250125.csv", encoding("utf-8") clear
keep submitdate startdate lastpage g01q01 g01q02 hospitalbranch g01q03 g01q04sq001 g01q06 g01q07sq001  g01q07wsq001 g02q01 g02q02 g02q04 g01q08 checkenumerator vfs01 vfs03 vfs05 vfs07 g09q04 g09q05 g10q01 g10q02 g10q03 g10q04 
rename (g10q02 g10q04)( video_finish_f video_finish_m)
rename (g01q01 g01q02 g01q03 g01q04sq001 g01q06 g01q07sq001 g01q07wsq001 g02q01 g02q02 g02q04 g01q08 )(enumerator randdate ward bed momname hospitalID hospitalID_w eligible willingness willingness1 group )
rename (vfs01 vfs03 vfs05 vfs07 g10q01 g10q03)(video_rating_f video_change_f video_rating_m video_change_m video_like_f_enu video_like_m_enu)

/* append using `1'
append using `2'
append using `3' */
append using `4'
append using `5'
append using `6'
append using `7'



drop if submitdate == ""
drop if hospitalID == .
keep if group ~= ""

rename(g09q04 g09q05)(coherence interactivity)


//----- clean ------

** date
*submitdate
drop if submitdate == ""

gen submitdatetime = clock(submitdate, "YMDhms") if survey_id ~= 2
gen date_temp = startdate if survey_id == 2 

gen double date_part = date(substr(date_temp, 1, 8), "MD20Y")
gen double hour_part = real(substr(date_temp, 9, strpos(date_temp, ":") - 9))
gen double minute_part = real(substr(date_temp, strpos(date_temp, ":") + 1, 2))

gen double datetime_combined = dhms(date_part, hour_part, minute_part, 0)
replace submitdatetime = datetime_combined if survey_id == 2
format submitdatetime %tc
drop date_temp date_part hour_part minute_part datetime_combined submitdate startdate

*randdate

gen randdate_temp = date(randdate, "YMDhms") if survey_id ~= 2
replace randdate_temp = date(substr(randdate, 1, 8), "MD20Y") if survey_id == 2
format randdate_temp %td
drop randdate
rename randdate_temp randdate
// replace date_temp = "10/11/24 15:43" in 1979

replace enumerator = "Maggie" if enumerator == "Vivi" & randdate < date("2024-12-30", "YMD")
replace checkenumerator = "Maggie" if checkenumerator == "Vivi" & randdate < date("2024-12-30", "YMD")

** hospitalID
replace hospitalID = hospitalID_w if hospitalID == .
drop hospitalID_w

tostring hospitalID, replace
drop if hospitalID == "." | hospitalID == "123456" | hospitalID == "777777" | hospitalID == "888888" | hospitalID == "111111" | momname == "测试" | hospitalID == "0"
replace hospitalID = "0" + hospitalID if strlen(hospitalID) == 5
replace hospitalID = "00" + hospitalID if strlen(hospitalID) == 4
count if strlen(hospitalID) < 6

** enumerator
replace checkenumerator = "" if checkenumerator == "0"
// replace checkenumerator = enumerator if checkenumerator == ""

** group
gen treatment = "T0" if strpos(group, "T0")>0
replace treatment = "T1" if strpos(group, "T1")>0
replace treatment = "T2" if strpos(group, "T2")>0
drop group

** duplicates
sort hospitalID submitdatetime
by hospitalID : gen id = _n
duplicates tag hospitalID, gen (dup_id)
forvalues i = 1/9 {
    forvalues j = 1/`i' {
        drop if dup_id == `i' & id == `j'
    }
}
drop id dup_id
drop if hospitalID == "."
duplicates report hospitalID

// week_num
gen cutoff_date = date("24/09/2024", "DMY")
gen week_num = floor((randdate - cutoff_date) / 7) 

// vip
gen vip = 0
replace vip = 1 if strlen(ward) == 3

// triple room
rename bed room_num
gen bed_in_room = 2
replace bed_in_room = 1 if strlen(ward) == 3
replace bed_in_room = 3 if (ward == "4A" & room_num < 39)
replace bed_in_room = 3 if (ward == "5A" & room_num < 38)
replace bed_in_room = 3 if (ward == "5B" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "5B" & room_num < 50 & room_num > 46)
replace bed_in_room = 3 if (ward == "6A" & room_num < 38)
replace bed_in_room = 3 if (ward == "6B" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "6B" & room_num < 50 & room_num > 46)
replace bed_in_room = 3 if (ward == "7A" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "7B" & room_num < 40 & room_num > 2)
replace bed_in_room = 3 if (ward == "7B" & room_num > 46)

//cluster var
gen ward_num = substr(ward,1,1) if vip == 0
destring ward_num, replace force
gen cluster_var = ward_num*1000+ room_num * 100 + week_num if vip == 0
destring hospitalID, gen(hospital_id)
replace cluster_var = hospital_id if vip == 1

save "$proc/video_temp1.dta", replace


use "$proc/attrition_1m.dta", clear
keep hospital_id completed merge_var
gen hospitalID = substr(hospital_id,4,6)
drop hospital_id
gen completed_1m = (completed == "Y")
drop completed

tempfile attrition_1m
save `attrition_1m'

use "$proc/video_temp1.dta", clear
merge 1:m hospitalID using `attrition_1m'
keep if _merge == 3

drop if treatment == "T0"

gen temp = .
	replace temp = 1 if video_helpful_f == "没有帮助"
	replace temp = 1 if video_helpful_f == "不太有帮助"
	replace temp = 2 if video_helpful_f == "有一定帮助"
	replace temp = 2 if video_helpful_f == "很有帮助"
drop video_helpful_f
rename temp video_helpful_f
	

gen temp = .
	replace temp = 1 if video_helpful_m == "没有帮助"
	replace temp = 1 if video_helpful_m == "不太有帮助"
	replace temp = 2 if video_helpful_m == "有一定帮助"
	replace temp = 2 if video_helpful_m == "很有帮助"
drop video_helpful_m
rename temp video_helpful_m


local var video_change_f video_change_m video_learn_f video_learn_m video_recommend_f video_recommend_m

foreach i in `var'{
	encode `i', gen(temp_`i')
	drop `i'
	rename temp_`i' `i'
}

local var video_like_f video_like_m
foreach i in `var'{
	gen temp_`i' = .
	replace temp_`i' = 1 if `i' == "不太喜欢"
	replace temp_`i' = 1 if `i' == "有一点喜欢"
	replace temp_`i' = 2 if `i' == "比较喜欢"
	replace temp_`i' = 2 if `i' == "非常喜欢"
	drop `i'
	rename temp_`i' `i'
	}

local var video_like_f_enu video_like_m_enu
foreach i in `var'{
	gen temp_`i' = .
	replace temp_`i' = 1 if `i' == "没有明显态度"
	replace temp_`i' = 1 if `i' == "非常不喜欢"
	replace temp_`i' = 1 if `i' == "不喜欢"
	replace temp_`i' = 2 if `i' == "喜欢"
	replace temp_`i' = 2 if `i' == "非常喜欢"
	drop `i'
	rename temp_`i' `i'

}

local var coherence interactivity
foreach i in `var'{
	gen temp_`i' = .
	replace temp_`i' = 1 if `i' == "有点低"
	replace temp_`i' = 1 if `i' == "比较少"
	replace temp_`i' = 1 if `i' == "一般"
	replace temp_`i' = 1 if `i' == "有点高"
	replace temp_`i' = 1 if `i' == "比较多"
	replace temp_`i' = 2 if `i' == "很高"
	replace temp_`i' = 2 if `i' == "比较高"
	replace temp_`i' = 2 if `i' == "非常多"
	drop `i'
	rename temp_`i' `i'
}


local var video_rating_f video_rating_m
foreach i in `var'{
	replace `i' = 1 if `i' == 1
	replace `i' = 1 if `i' == 4
	replace `i' = 1 if `i' == 5
	replace `i' = 1 if `i' == 6
	replace `i' = 1 if `i' == 7
	replace `i' = 2 if `i' == 8
	replace `i' = 2 if `i' == 9
	replace `i' = 2 if `i' == 10
}

gen T1 = (treatment == "T1")
gen T2 = (treatment == "T2")

encode enumerator, gen(enumerator_num)
save "$proc/video_temp2.dta", replace





local varlist video_rating_f video_rating_m video_change_f video_change_m video_learn_f video_learn_m video_recommend_f video_recommend_m video_like_f video_like_m video_like_f_enu video_like_m_enu coherence interactivity
foreach var in `varlist'{
	use "$proc/video_temp2.dta", clear

    // Get the levels of the current categorical variable
    /* levelsof `var', local(var_value) */
    di "Processing variable: `var'"
	file open resultsfile using "$results/tables/intervention_reaction.tex", write append	
	        // Output header to LaTeX file
        file write resultsfile "\midrule" _n
        file write resultsfile "\textbf{`var' level `level'}\\" _n
    // Open the output file (append mode)
 

	/* foreach level of local var_value {
        di "Processing for `var' level: `level'"

		use "$proc/video_temp2.dta", clear
		drop if `var' == .
	    keep if `var' == `level'   */

        /* count
        local N_`var'_`level' = r(N)  // Save the count



        local row = 0

		su completed_1m, detail
		local mean: di %6.3f r(mean)
		local sd: di %6.3f r(sd)
		local sd = trim("`sd'")

		// Mean and SD for T1
		su completed_1m if T1 == 1
		local mean_t1: di %6.3f r(mean)
		local sd_t1: di %6.3f r(sd)
		local sd_t1 = trim("`sd_t1'")
		
		// Mean and SD for T2
		su completed_1m if T2 == 1
		local mean_t2: di %6.3f r(mean)
		local sd_t2: di %6.3f r(sd)
		local sd_t2 = trim("`sd_t2'")

	    local row = `row' + 1
        local mu_row`row' "\textit{ N = `N_`var'_`level''} & `mean' & `mean_t1' & `mean_t2' " 

        local row = `row' + 1
        local mu_row`row' " & (`sd') & (`sd_t1') & (`sd_t2') "

		local row = 0
		local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n */

	/* } */
		// Regression
		capture drop dummy_`var'
		gen dummy_`var' = 1 if `var' == 2
		replace dummy_`var' = 0 if `var' == 1
		
		reg completed_1m dummy_`var' i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
        local diff_: di %6.3f _b[dummy_`var']
        local se_: di %6.3f _se[dummy_`var']
        local pval_ = 2 * ttail(e(df_r), abs(_b[dummy_`var'] / _se[dummy_`var']))
        local star_ ""
        if (`pval_' < 0.1) local star_ "*"
        if (`pval_' < 0.05) local star_ "**"
        if (`pval_' < 0.01) local star_ "***"

		preserve
		keep if T1 == 1
		capture reg completed_1m dummy_`var' i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
		if _rc == 0 {
			local diff_t1: di %6.3f _b[dummy_`var']
			local se_t1: di %6.3f _se[dummy_`var']
			local pval_t1 = 2 * ttail(e(df_r), abs(_b[dummy_`var'] / _se[dummy_`var']))
			local star_t1 ""
			if (`pval_t1' < 0.1) local star_t1 "*"
			if (`pval_t1' < 0.05) local star_t1 "**"
			if (`pval_t1' < 0.01) local star_t1 "***"
		}
		else {
			local diff_t1 "."
			local se_t1 "."
			local star_t1 ""
		}
		restore

		preserve
		keep if T2 == 1
		capture reg completed_1m dummy_`var' i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
		if _rc == 0 {
			local diff_t2: di %6.3f _b[dummy_`var']
			local se_t2: di %6.3f _se[dummy_`var']
			local pval_t2 = 2 * ttail(e(df_r), abs(_b[dummy_`var'] / _se[dummy_`var']))
			local star_t2 ""
			if (`pval_t2' < 0.1) local star_t2 "*"
			if (`pval_t2' < 0.05) local star_t2 "**"
			if (`pval_t2' < 0.01) local star_t2 "***"
		}
		else {
			local diff_t2 "."
			local se_t2 "."
			local star_t2 ""
		}
		restore


        // Prepare the output row


        
		local row = `row' + 1
		local mu_row`row' " \textbf{`var'} & `diff_'`star_' & `diff_t1'`star_t1' & `diff_t2'`star_t2'  "
		
		local row = `row' + 1
		local mu_row`row' " & (`se_')  & (`se_t1') & (`se_t2') "
		
		// Write the row to the LaTeX file
		
		    local row = 0


        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n

        local row = `row' + 1
        file write resultsfile "`mu_row`row'' \\" _n
		file close resultsfile
		

}
