** attrition patterns **

** Author : Haoyue Wu
** Updated on : Apr 10, 2025

/*
IMPORTS: 
	$proc/attritiontoken_1m.dta
	$proc/attritiontoken_2m.dta
	$proc/contact_list.dta

*/

*********
** LOG **
*********
// time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
// local project 01_randforest
// cap log close
// set linesize 200
// log using "$logs/`project'_`time'.log", text replace
// di "`c(current_date)' `c(current_time)'"
// pwd

*********************




////////////////////////////////////////////////////////////////////////////////
//////////////////////////// 1m - before tp change /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/* 
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

keep if date < date("2025-01-21", "YMD") & strpos(备注,"tp课程干预简化Ava测试") == 0 

gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment
tempfile complete
save `complete'

keep 母亲姓名 母亲电话 treatment date
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'

use `complete'
keep 父亲姓名 父亲电话 treatment date
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'

append using `mother'
order firstname lastname
destring firstname, replace
tempfile participants
save `participants'

use "$proc/attritiontoken_1m.dta", clear
rename attrition attrition_1m
// tempfile 1m
// save `1m'

// use "$proc/attritiontoken_2m.dta", clear
// rename attrition attrition_2m
// tempfile 2m
// save `2m'

// use `1m', clear
// merge 1:1 firstname using `2m'
// keep if _merge == 3
// drop _merge


merge 1:1 firstname lastname using `participants'
drop if _merge == 1
replace attrition_1m = 0 if _merge == 2
drop _merge
 
replace treatment = "T2" if firstname == 17638375569
replace parent = "F" if firstname == 17638375569
replace treatment = "T2" if firstname == 17621431230
replace parent = "F" if firstname == 17621431230
replace hospitalID = "D00334154" if firstname == 17638375569
replace hospitalID = "D00336813" if firstname == 17621431230

replace date_invited = td(09jan2025) if date == td(09dec2024)
replace date_invited = td(02jan2025) if date == td(07dec2024)
replace date_invited = td(02jan2025) if date == td(05dec2024)
replace date_invited = td(26dec2024) if date == td(29nov2024)
replace date_invited = td(19dec2024) if date == td(23nov2024)
replace date_invited = td(16jan2025) if date == td(20dec2024)
replace date_invited = td(16jan2025) if date == td(19dec2024)
replace date_invited = td(23jan2025) if date == td(23dec2024)
replace date_invited = td(23jan2025) if date == td(25dec2024)
replace date_invited = td(16jan2025) if date == td(18dec2024)
replace date_invited = td(16dec2024) if date == td(19nov2024)
replace date_invited = td(02feb2025) if date == td(21jan2025)
replace date_invited = td(02feb2025) if date == td(23jan2025)


************************************************
** visualization - attrition by treatment arm***
************************************************


gen unfinished_1m = (attrition_1m == 0)

// sort date_invited
// gen date_str = string(date_invited,  "%tdY-N-D")
replace date_invited = date("2025-1-2", "YMD") if date_invited == date("2024-12-31", "YMD")
replace date_invited = date("2024-12-5", "YMD")  if date_invited == date("2024-12-07", "YMD")

gen week = week(date_invited)
tab week
replace week = 53 if week == 1
replace week = 54 if week == 2
replace week = 55 if week == 3
replace week = 56 if week == 4
replace week = 57 if week == 5 | week == 6
replace week = 58 if week == 7
replace week = 59 if week == 8
replace week = 60 if week == 10

bysort week treatment: egen attrition_mean = mean(unfinished_1m)
/* drop if date_invited == td(06feb2025) */

// graph bar attrition_mean_treat, over(treatment) over(week, label(angle(45)) relabel(`rlab')) ///
//    asyvars  ///
//    bar(1, color(blue%10)) ///
//    bar(2, color(red%10)) ///
//    bar(3, color(orange%10)) ///
//    title("Attrition Over Time by Treatment Group - 1m") ///
//    b1title("Invited Date") ///
//    ytitle("Mean Attrition") ///
//    legend(label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
//    graphregion(color(white))
	
local varlist treatment parent
foreach var in `varlist'{
	encode `var', gen (`var'_temp)
	drop `var'
	rename `var'_temp `var'
}
	gen zero = 0
	// First generate offset weeks
gen week2 = week + 0.25
gen week3 = week + 0.5


local rlab `"43 "25oct2024" 44"01nov2024" 45 "08nov2024" 46 "14nov2024" 47 "21nov2024" 48 "28nov2024" 49 "05dec2024" 50 "12dec2024" 51 "19dec2024" 52 "26dec2024" 53 "02jan2025" 54 "09jan2025" 55 "16jan2025" 56 "23jan2025" 57 "06feb2025" 58 "13feb2025" 59 "20feb2025" "'
	twoway (rbar zero attrition_mean week if treatment==1, color(blue) barw(0.25)) ///
		   (rbar zero attrition_mean week2 if treatment==2, color(red) barw(0.25)) ///
		   (rbar zero attrition_mean week3 if treatment==3, color(orange) barw(0.25)) ///
		   (pci 0 45.75 0.5 45.75, lcolor(red%50) lpattern(dash)) ///
		   (pci 0 52.75 0.5 52.75, lcolor(red%50) lpattern(dash)) ///
		   (pci 0 56.75 0.5 56.75, lcolor(red%50) lpattern(dash)) ///
		   (scatteri 0.47 45.75 "1", mlabsize(small)) ///
		   (scatteri 0.47 56.75 "3", mlabsize(small)) ///
		   (scatteri 0.47 52.75 "2", mlabsize(small)), ///
		   yscale(range(0 0.5)) ///
		   ylab(0(0.1)0.5) ///
		   xlabel(`rlab', angle(45)) ///
		   title("Attrition Over Time by Treatment Group - 1m") ///
		   xtitle("Invited Date") ///
		   ytitle("Mean Attrition") ///
		   legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
		   graphregion(color(white))
	  
  
	graph export "$results/figures/attrition_1m_beforetp.pdf" , replace
	
preserve 
	keep if parent == 1
	bysort week treatment: egen attrition_mean_treat = mean(unfinished_1m)
				
	local rlab `"43 "25oct2024" 44"01nov2024" 45 "08nov2024" 46 "14nov2024" 47 "21nov2024" 48 "28nov2024" 49 "05dec2024" 50 "12dec2024" 51 "19dec2024" 52 "26dec2024" 53 "02jan2025" 54 "09jan2025" 55 "16jan2025" 56 "23jan2025" 57 "06feb2025" 58 "13feb2025"  59 "20feb2025" "'
	twoway (rbar zero attrition_mean_treat week if treatment==1, color(blue) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week2 if treatment==2, color(red) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week3 if treatment==3, color(orange) barw(0.25)) ///
		   (pci 0 45.75 0.5 45.75, lcolor(red%50) lpattern(dash)) ///
		   (pci 0 52.75 0.5 52.75, lcolor(red%50) lpattern(dash)) ///
		   (pci 0 56.75 0.5 56.75, lcolor(red%50) lpattern(dash)) ///
		   (scatteri 0.47 45.75 "1", mlabsize(small)) ///
		   (scatteri 0.47 56.75 "3", mlabsize(small)) ///
		   (scatteri 0.47 52.75 "2", mlabsize(small)), ///
		   yscale(range(0 0.5)) ///
		   ylab(0(0.1)0.5) ///
		   xlabel(`rlab', angle(45)) ///
		   title("Attrition Over Time - Father") ///
		   xtitle("Invited Date") ///
		   ytitle("Mean Attrition") ///
		   legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
		   graphregion(color(white))
		
	graph export "$results/figures/attrition_1m_beforetp_father.pdf", replace
		
restore

preserve 
	keep if parent == 2
	bysort date_invited treatment: egen attrition_mean_treat = mean(unfinished_1m)
				
	local rlab `"43 "25oct2024" 44"01nov2024" 45 "08nov2024" 46 "14nov2024" 47 "21nov2024" 48 "28nov2024" 49 "05dec2024" 50 "12dec2024" 51 "19dec2024" 52 "26dec2024" 53 "02jan2025" 54 "09jan2025" 55 "16jan2025" 56 "23jan2025" 57 "06feb2025" 58 "13feb2025" 59 "20feb2025"  "'
	twoway (rbar zero attrition_mean_treat week if treatment==1, color(blue) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week2 if treatment==2, color(red) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week3 if treatment==3, color(orange) barw(0.25)) ///
		   (pci 0 45.75 0.5 45.75, lcolor(red%50) lpattern(dash)) ///
		   (pci 0 52.75 0.5 52.75, lcolor(red%50) lpattern(dash)) ///
		   (pci 0 56.75 0.5 56.75, lcolor(red%50) lpattern(dash)) ///
		   (scatteri 0.47 45.75 "1", mlabsize(small)) ///
		   (scatteri 0.47 56.75 "3", mlabsize(small)) ///
		   (scatteri 0.47 52.75 "2", mlabsize(small)), ///
		   yscale(range(0 0.5)) ///
		   ylab(0(0.1)0.5) ///
		   xlabel(`rlab', angle(45)) ///
		   title("Attrition Over Time - Mother") ///
		   xtitle("Invited Date") ///
		   ytitle("Mean Attrition") ///
		   legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
		   graphregion(color(white))
		
	graph export "$results/figures/attrition_1m_beforetp_mother.pdf", replace
		
restore
		 */



////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// 1m - after tp change //////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

keep if date <= date("2025-04-01", "YMD") // where needing updates each week
keep if date >= date("2025-01-21", "YMD") | strpos(备注,"tp课程干预简化Ava测试") > 0

gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment
tempfile complete
save `complete'

keep 母亲姓名 母亲电话 treatment date
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'

use `complete'
keep 父亲姓名 父亲电话 treatment date
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'

append using `mother'
order firstname lastname
destring firstname, replace
tempfile participants
save `participants'

use "$proc/attritiontoken_1m.dta", clear
rename attrition attrition_1m

merge 1:1 firstname lastname using `participants'
drop if _merge == 1
replace attrition_1m = 0 if _merge == 2
drop _merge
 
replace treatment = "T2" if firstname == 17638375569
replace parent = "F" if firstname == 17638375569
replace treatment = "T2" if firstname == 17621431230
replace parent = "F" if firstname == 17621431230
replace hospitalID = "D00334154" if firstname == 17638375569
replace hospitalID = "D00336813" if firstname == 17621431230

replace date_invited = td(09jan2025) if date == td(09dec2024)
replace date_invited = td(02jan2025) if date == td(07dec2024)
replace date_invited = td(02jan2025) if date == td(05dec2024)
replace date_invited = td(26dec2024) if date == td(29nov2024)
replace date_invited = td(19dec2024) if date == td(23nov2024)
replace date_invited = td(16jan2025) if date == td(20dec2024)
replace date_invited = td(16jan2025) if date == td(19dec2024)
replace date_invited = td(23jan2025) if date == td(23dec2024)
replace date_invited = td(23jan2025) if date == td(25dec2024)
replace date_invited = td(16jan2025) if date == td(18dec2024)
replace date_invited = td(16dec2024) if date == td(19nov2024)
replace date_invited = td(02feb2025) if date == td(21jan2025)
replace date_invited = td(02feb2025) if date == td(23jan2025)
replace date_invited = td(13mar2025) if date == td(11feb2025)
replace	 date_invited = td(3apr2025) if date_invited == .


************************************************
** visualization - attrition by treatment arm***
************************************************


gen unfinished_1m = (attrition_1m == 0)

replace date_invited = date("2025-1-2", "YMD") if date_invited == date("2024-12-31", "YMD")
replace date_invited = date("2024-12-5", "YMD")  if date_invited == date("2024-12-07", "YMD")

gen week = week(date_invited)
tab week
replace week = 57 if week == 5 | week == 6
replace week = 58 if week == 7
replace week = 59 if week == 8
replace week = 60 if week == 10
replace week = 61 if week == 11
replace week = 62 if week == 12
replace week = 63 if week == 13
replace week = 64 if week == 14
replace week = 65 if week == 15
replace week = 66 if week == 16
replace week = 67 if week == 17

bysort week treatment: egen attrition_mean = mean(unfinished_1m)

	
local varlist treatment parent
foreach var in `varlist'{
	encode `var', gen (`var'_temp)
	drop `var'
	rename `var'_temp `var'
}
	gen zero = 0
	// First generate offset weeks
gen week2 = week + 0.25
gen week3 = week + 0.5


local rlab `"57 "06feb2025" 58 "13feb2025" 59 "20feb2025" 60 "06mar2025" 61 "13mar2025" 62 "20mar2025" 63 "27mar2025" 64 "03apr2025" 65 "10apr2025" 66 "17apr2025" 67 "24apr2025" "'
	twoway (rbar zero attrition_mean week if treatment==1, color(blue) barw(0.25)) ///
		   (rbar zero attrition_mean week2 if treatment==2, color(red) barw(0.25)) ///
		   (rbar zero attrition_mean week3 if treatment==3, color(orange) barw(0.25)) , ///
		   yscale(range(0 0.5)) ///
		   ylab(0(0.1)0.5) ///
		   xlabel(`rlab', angle(45)) ///
		   title("Attrition Over Time by Treatment Group - 1m") ///
		   xtitle("Invited Date") ///
		   ytitle("Mean Attrition") ///
		   legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
		   graphregion(color(white))
	  
  
	graph export "$results/figures/attrition_1m_aftertp.pdf" , replace
	
preserve 
	keep if parent == 1
	bysort week treatment: egen attrition_mean_treat = mean(unfinished_1m)
	
local rlab `"57 "06feb2025" 58 "13feb2025" 59 "20feb2025" 60 "06mar2025" 61 "13mar2025" 62 "20mar2025" 63 "27mar2025" 64 "03apr2025" 65 "10apr2025" 66 "17apr2025" 67 "24apr2025" "'
	twoway (rbar zero attrition_mean_treat week if treatment==1, color(blue) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week2 if treatment==2, color(red) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week3 if treatment==3, color(orange) barw(0.25)) , ///
		   yscale(range(0 0.5)) ///
		   ylab(0(0.1)0.5) ///
		   xlabel(`rlab', angle(45)) ///
		   title("Attrition Over Time - Father") ///
		   xtitle("Invited Date") ///
		   ytitle("Mean Attrition") ///
		   legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
		   graphregion(color(white))
	  
		
	graph export "$results/figures/attrition_1m_aftertp_father.pdf", replace
		
restore

preserve 
	keep if parent == 2
	bysort date_invited treatment: egen attrition_mean_treat = mean(unfinished_1m)
				
local rlab `"57 "06feb2025" 58 "13feb2025" 59 "20feb2025" 60 "06mar2025" 61 "13mar2025" 62 "20mar2025" 63 "27mar2025" 64 "03apr2025" 65 "10apr2025" 66 "17apr2025" 67 "24apr2025" "'
	twoway (rbar zero attrition_mean_treat week if treatment==1, color(blue) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week2 if treatment==2, color(red) barw(0.25)) ///
		   (rbar zero attrition_mean_treat week3 if treatment==3, color(orange) barw(0.25)) , ///
		   yscale(range(0 0.5)) ///
		   ylab(0(0.1)0.5) ///
		   xlabel(`rlab', angle(45)) ///
		   title("Attrition Over Time - Mother") ///
		   xtitle("Invited Date") ///
		   ytitle("Mean Attrition") ///
		   legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
		   graphregion(color(white))
	  
	graph export "$results/figures/attrition_1m_aftertp_mother.pdf", replace
		
restore

// 2m

use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

drop if date > date("2025-01-05", "YMD") 
gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment
tempfile complete
save `complete'

keep 母亲姓名 母亲电话 treatment date
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'

use `complete'
keep 父亲姓名 父亲电话 treatment date
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'

append using `mother'
order firstname lastname
destring firstname, replace
tempfile participants
save `participants'

use "$proc/attritiontoken_2m.dta", clear
rename attrition attrition_2m
// tempfile 1m
// save `1m'

// use "$proc/attritiontoken_2m.dta", clear
// rename attrition attrition_2m
// tempfile 2m
// save `2m'

// use `1m', clear
// merge 1:1 firstname using `2m'
// keep if _merge == 3
// drop _merge


merge 1:1 firstname lastname using `participants'
drop if _merge == 1
replace attrition_2m = 0 if _merge == 2
drop _merge
 
replace treatment = "T2" if firstname == 17638375569
replace parent = "F" if firstname == 17638375569
replace treatment = "T2" if firstname == 17621431230
replace parent = "F" if firstname == 17621431230
replace hospitalID = "D00334154" if firstname == 17638375569
replace hospitalID = "D00336813" if firstname == 17621431230


replace date_invited = td(06feb2025) if date == td(23nov2024)
replace date_invited = td(09jan2025) if date == td(08nov2024)
// replace date_invited = td(16jan2025) if date == td(19dec2024)
replace date_invited = td(02jan2025) if date == td(02nov2024)
replace date_invited = td(12dec2024) if date == td(09oct2024)
replace date_invited = td(16jan2025) if date == td(12nov2024)
replace date_invited = td(06feb2025) if date == td(29nov2024)
replace date_invited = td(06feb2025) if date == td(30nov2024)
replace date_invited = td(06feb2025) if date == td(28nov2024)
replace date_invited = td(02jan2025) if date == td(07dec2024)
replace date_invited = td(02jan2025) if date == td(05dec2024)
replace date_invited = td(19dec2024) if date == td(19nov2024)
replace date_invited = td(16jan2025) if date == td(19dec2024)
replace date_invited = td(16jan2025) if date == td(18dec2024)
replace date_invited = td(16jan2025) if date == td(20dec2024)
replace date_invited = td(20feb2025) if date == td(03jan2025)
replace date_invited = td(27feb2025) if date == td(25dec2024)


gen unfinished_2m = (attrition_2m == 0)
replace date_invited = date("2025-1-2", "YMD") if date_invited == date("2024-12-31", "YMD")
replace date_invited = date("2024-12-5", "YMD")  if date_invited == date("2024-12-07", "YMD")

gen week = week(date_invited)
tab week

replace week = 53 if week == 1
replace week = 54 if week == 2
replace week = 55 if week == 3
replace week = 56 if week == 4
replace week = 57 if week == 6
replace week = 58 if week == 7
replace week = 59 if week == 8
replace week = 60 if week == 9
replace week = 61 if week == 10

bysort week treatment: egen attrition_mean = mean(unfinished_2m)
	
local varlist treatment parent
foreach var in `varlist'{
	encode `var', gen (`var'_temp)
	drop `var'
	rename `var'_temp `var'
}
	gen zero = 0
	// First generate offset weeks
gen week2 = week + 0.25
gen week3 = week + 0.5



local rlab `"48 "28nov2024" 49 "05dec2024" 50 "12dec2024" 51 "19dec2024" 52 "26dec2024" 53 "02jan2025" 54 "09jan2025" 55 "16jan2025" 56 "23jan2025" 57 "06feb2025" 58 "13feb2025" 59 "20feb2025" 60 "27feb2025" 61 "06mar2025""'
	twoway (rbar zero attrition_mean week if treatment==1, color(blue) barw(0.25)) ///
		   (rbar zero attrition_mean week2 if treatment==2, color(red) barw(0.25)) ///
		   (rbar zero attrition_mean week3 if treatment==3, color(orange) barw(0.25)) ///
		   (pci 0 52.75 0.5 52.75, lcolor(red%50) lpattern(dash)) ///
		   (pci 0 56.75 0.5 56.75, lcolor(red%50) lpattern(dash)) ///
		   (scatteri 0.47 56.75 "3", mlabsize(small)) ///
		   (scatteri 0.47 52.75 "2", mlabsize(small)), ///
		   yscale(range(0 0.5)) ///
		   ylab(0(0.1)0.5) ///
		   xlabel(`rlab', angle(45)) ///
		   title("Attrition Over Time by Treatment Group - 2m") ///
		   xtitle("Invited Date") ///
		   ytitle("Mean Attrition") ///
		   legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
		   graphregion(color(white))
	  
  
	graph export "$results/figures/attrition_by_time_treatment_2m.pdf" , replace
	
preserve 
	keep if parent == 1
	bysort week treatment: egen attrition_mean_treat = mean(unfinished_2m)
				
	local rlab `"48 "28nov2024" 49 "05dec2024" 50 "12dec2024" 51 "19dec2024" 52 "26dec2024" 53 "02jan2025" 54 "09jan2025" 55 "16jan2025" 56 "23jan2025" 57 "06feb2025" 58 "13feb2025" 59 "20feb2025" 60 "27feb2025" 61 "06mar2025""'
		twoway (rbar zero attrition_mean week if treatment==1, color(blue) barw(0.25)) ///
			(rbar zero attrition_mean week2 if treatment==2, color(red) barw(0.25)) ///
			(rbar zero attrition_mean week3 if treatment==3, color(orange) barw(0.25)) ///
			(pci 0 52.75 0.5 52.75, lcolor(red%50) lpattern(dash)) ///
			(pci 0 56.75 0.5 56.75, lcolor(red%50) lpattern(dash)) ///
			(scatteri 0.47 56.75 "3", mlabsize(small)) ///
			(scatteri 0.47 52.75 "2", mlabsize(small)), ///
			yscale(range(0 0.5)) ///
			ylab(0(0.1)0.5) ///
			xlabel(`rlab', angle(45)) ///
			title("Attrition Over Time - Father") ///
			xtitle("Invited Date") ///
			ytitle("Mean Attrition") ///
			legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
			graphregion(color(white))
	  
  
		
	graph export "$results/figures/attrition_by_time_treatment_father_2m.pdf", replace
		
restore

preserve 
	keep if parent == 2
	bysort date_invited treatment: egen attrition_mean_treat = mean(unfinished_2m)
				
	local rlab `"48 "28nov2024" 49 "05dec2024" 50 "12dec2024" 51 "19dec2024" 52 "26dec2024" 53 "02jan2025" 54 "09jan2025" 55 "16jan2025" 56 "23jan2025" 57 "06feb2025" 58 "13feb2025" 59 "20feb2025" 60 "27feb2025" 61 "06mar2025""'
		twoway (rbar zero attrition_mean week if treatment==1, color(blue) barw(0.25)) ///
			(rbar zero attrition_mean week2 if treatment==2, color(red) barw(0.25)) ///
			(rbar zero attrition_mean week3 if treatment==3, color(orange) barw(0.25)) ///
			(pci 0 52.75 0.5 52.75, lcolor(red%50) lpattern(dash)) ///
			(pci 0 56.75 0.5 56.75, lcolor(red%50) lpattern(dash)) ///
			(scatteri 0.47 56.75 "3", mlabsize(small)) ///
			(scatteri 0.47 52.75 "2", mlabsize(small)), ///
			yscale(range(0 0.5)) ///
			ylab(0(0.1)0.5) ///
			xlabel(`rlab', angle(45)) ///
			title("Attrition Over Time - Mother") ///
			xtitle("Invited Date") ///
			ytitle("Mean Attrition") ///
			legend(order(1 2 3) label(1 "Control Group") label(2 "T1") label(3 "T2")) ///
			graphregion(color(white))
		
	graph export "$results/figures/attrition_by_time_treatment_mother_2m.pdf", replace
		
restore











/* 
		
	
************************************************
** visualization - attrition balance         ***
************************************************
use "$proc/attrition_1m.dta", clear
sort invited_date

drop if invited_date == date("2024-12-31", "YMD")
drop if invited_date == date("2024-12-07", "YMD")



// 	keep if parent == 1
	// bysort invited_date treatment: egen attrition_mean_C = mean(unfinished_1m) if treatment == 1
	// bysort invited_date treatment: egen attrition_mean_T1 = mean(unfinished_1m) if treatment == 2
	// bysort invited_date treatment: egen attrition_mean_T2 = mean(unfinished_1m) if treatment == 3
	bysort invited_date treatment: egen attrition_mean_treat = mean(unfinished_1m)

	duplicates drop invited_date treatment, force
	keep invited_date treatment attrition_mean_treat 

	bysort invited_date (treatment): gen t1_c = attrition_mean_treat[2] - attrition_mean_treat[1]
	bysort invited_date (treatment): gen t2_c = attrition_mean_treat[3] - attrition_mean_treat[1]
	bysort invited_date (treatment): gen t2_t1 = attrition_mean_treat[3] - attrition_mean_treat[2]

	gen attrition_diff = .
	replace attrition_diff = t1_c if treatment == 1
	replace attrition_diff = t2_c if treatment == 2
	replace attrition_diff = t2_t1 if treatment == 3

	label define barlabel 1 "T1-C" 2 "T2-C" 3 "T2-T1" 
	bysort invited_date (treatment): gen cat = _n
	label values cat barlabel

// duplicates drop invited_date, force
	gen date_str = string(invited_date,  "%tdY-N-D")

		graph bar attrition_diff,over(cat) over(date_str, label(angle(45))) ///
			asyvars  ///
			bar(1, color(blue%10)) ///
			bar(2, color(red%10)) ///
			bar(3, color(orange%10)) ///
			title("Attrition Difference") ///
			b1title("Invited Date") ///
			ytitle("Mean Attrition") ///
			legend(label(1 "T1-C") label(2 "T2-C") label(3 "T2-T1")) ///
			graphregion(color(white)) ///
			ysc(r(-0.2 0.25)) ///
			ylabel(-0.2(0.1)0.25) 
			
		graph export "$results/figures/attrition_diff.pdf", replace
	



use "$proc/attrition_1m.dta", clear
sort invited_date

drop if invited_date == date("2024-12-31", "YMD")
drop if invited_date == date("2024-12-07", "YMD")

	keep if parent == 0
	// bysort invited_date treatment: egen attrition_mean_C = mean(unfinished_1m) if treatment == 1
	// bysort invited_date treatment: egen attrition_mean_T1 = mean(unfinished_1m) if treatment == 2
	// bysort invited_date treatment: egen attrition_mean_T2 = mean(unfinished_1m) if treatment == 3
	bysort invited_date treatment: egen attrition_mean_treat = mean(unfinished_1m)

	duplicates drop invited_date treatment, force
	keep invited_date treatment attrition_mean_treat 

	bysort invited_date (treatment): gen t1_c = attrition_mean_treat[2] - attrition_mean_treat[1]
	bysort invited_date (treatment): gen t2_c = attrition_mean_treat[3] - attrition_mean_treat[1]
	bysort invited_date (treatment): gen t2_t1 = attrition_mean_treat[3] - attrition_mean_treat[2]

	gen attrition_diff = .
	replace attrition_diff = t1_c if treatment == 1
	replace attrition_diff = t2_c if treatment == 2
	replace attrition_diff = t2_t1 if treatment == 3

	label define barlabel 1 "T1-C" 2 "T2-C" 3 "T2-T1" 
	bysort invited_date (treatment): gen cat = _n
	label values cat barlabel

// duplicates drop invited_date, force
	gen date_str = string(invited_date,  "%tdY-N-D")

		graph bar attrition_diff,over(cat) over(date_str, label(angle(45))) ///
			asyvars  ///
			bar(1, color(blue%10)) ///
			bar(2, color(red%10)) ///
			bar(3, color(orange%10)) ///
			title("Attrition Difference - Father") ///
			b1title("Invited Date") ///
			ytitle("Mean Attrition") ///
			legend(label(1 "T1-C") label(2 "T2-C") label(3 "T2-T1")) ///
			graphregion(color(white)) ///
			ysc(r(-0 0.25)) ///
			ylabel(-0.05(0.05)0.25) 
			
		graph export "$results/figures/attrition_diff_father.pdf", replace
	

**** DID ****

//------------ data prepare ----------


// local group C T1 T2
// foreach i in `group'{
// 	gen attrition_`i' = unfinished_1m if `i' == 1
	
// }

use "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH(2)/collaboration desk - BEBE/data analysis/formal_study_recruitment/proc/before_analysis.dta", clear

keep if recru_succ == 1
encode enumerator, gen(enumerator_num)
keep hospitalID enumerator_num bed_in_room cluster_var group_temp 
tempfile temp
save `temp'

use "$proc/attrition_1m.dta", clear
merge m:1 hospitalID using `temp'
keep if _merge == 3
drop _merge 

save "$proc/1m_attrition_patterns.dta", replace

//------------- regression ------------
use "$proc/1m_attrition_patterns.dta", clear
gen t1_incentive = T1*incentive
gen t2_incentive = T2*incentive
gen tre_incentive = treatment*incentive
// T1 vs C
preserve
drop if T2 == 1
reg unfinished_1m T1 incentive t1_incentive baby_female parent i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
eststo m1
restore

// T2 vs C
preserve
drop if T1 == 1 
reg unfinished_1m T2 incentive t2_incentive baby_female parent i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
eststo m2
restore

// treatment vs C
preserve
reg unfinished_1m treatment incentive tre_incentive baby_female parent i.bed_in_room i.enumerator_num, robust cluster(cluster_var)
eststo m3
restore

// Export results to Excel
esttab m1 m2 m3 using "$results/tables/attrition_patterns_did.csv", replace ///
keep(T1 T2 treatment incentive t1_incentive t2_incentive tre_incentive baby_female parent) ///
b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
label title("Regression Results") ///
mtitle("T1 vs C" "T2 vs C" "Treatment vs C")

// duplicates drop firstname, force
// xtset firstname invited_date


local varlist incentive

foreach var in `varlist' {
    
    // Get the levels of the current categorical variable
    levelsof `var', local(var_value)
    
    // Open the output file (append mode)
    file open resultsfile using "$results/tables/attrition_patterns.tex", write replace
    
    // Loop through each level of the current variable
    foreach level of local var_value {
        di "Processing for `var' level: `level'"

        use "$proc/1m_attrition_patterns.dta", clear
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




//------------- descriptive analysis --------------

bysort treatment parent: tab remindercount unfinished_1m



 */
