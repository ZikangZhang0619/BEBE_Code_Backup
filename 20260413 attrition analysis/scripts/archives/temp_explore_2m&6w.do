

import excel using "$data/6w_appointment_list.xlsx", firstrow clear

keep 住院号 姓名 父母是否同行 父母是否完成 未做问卷原因
rename 住院号 hospital_id
rename 姓名 name
rename 父母是否同行 complete1
rename 父母是否完成 complete2
rename 未做问卷原因 reason


replace hospital_id = substr(hospital_id, 4, 6) if strlen(hospital_id) > 6

tempfile appointment_list
save `appointment_list'

// merge treatment group to appointment list
use "$proc/contact_list.dta", clear

gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6
rename 组别 treatment

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 treatment hospital_id


merge 1:m hospital_id using `appointment_list'
keep if _merge == 3
drop _merge
drop name 

gen C = (treatment == "1")
gen T1 = (treatment == "2")
gen T2 = (treatment == "3")
drop treatment

tempfile complete
save `complete'

drop 父亲姓名 父亲电话
rename (母亲姓名 母亲电话)(lastname firstname)
gen mother = 1
tempfile mother
save `mother'

use `complete'
drop 母亲姓名 母亲电话
rename (父亲姓名 父亲电话)(lastname firstname)
gen mother = 0
tempfile father
save `father'

append using `mother'
order firstname lastname

keep firstname 

tempfile 6w_appointment_list
save `6w_appointment_list'




** --------------- 2m ------------------ **
use "$proc/contact_list.dta", clear

gen date = date(日期, "YMD") if strpos(日期, "年") > 0
replace date = date(日期, "MDY") if strpos(日期, "/") > 0
replace date = date(日期, "DMY") if date == .
format date %td

gen participants_2m = 1 if date <= date("2025-04-06", "YMD") & (date >= date("2025-01-21", "YMD") | strpos(备注, "tp课程干预简化Ava测试") > 0)


gen treatment = "C" if 组别 == "1"
replace treatment = "T1" if 组别 == "2"
replace treatment = "T2" if 组别 == "3"

gen hospital_id = substr(住院号, 4, 6) if strlen(住院号) > 6

keep 母亲姓名 母亲电话 父亲姓名 父亲电话 date treatment hospital_id participants_2m
tempfile complete
save `complete'

keep 母亲姓名 母亲电话 treatment hospital_id participants_2m date
rename (母亲姓名 母亲电话)(lastname firstname)
gen parent = "M"
tempfile mother
save `mother'

use `complete'
keep 父亲姓名 父亲电话 treatment hospital_id participants_2m date
rename (父亲姓名 父亲电话)(lastname firstname)
gen parent = "F"
tempfile father
save `father'

append using `mother'
order firstname lastname

keep date firstname participants_2m 


merge 1:1 firstname using `6w_appointment_list'

gen participants_6w = 1 if _merge == 3
drop _merge

drop if participants_2m == . & participants_6w == .
replace participants_2m = 0 if participants_2m == .
replace participants_6w = 0 if participants_6w == .




// Create a numeric version of the date variable to apply value labels
gen date_num = date
format date_num %td  // Keep it formatted nicely

gen date1 = date + 0.5

gen cutoff_date = date("2025-01-14", "YMD")
gen week_num = int((date - cutoff_date) / 7) + 1


collapse (sum) participants_2m participants_6w, by(week_num)

gen week_num1 = week_num + 0.5
gen zero = 0

local rlab `" 1 "14jan2025" 2 "21jan2025" 3 "28jan2025" 4 "04feb2025" 5 "11feb2025" 6 "18feb2025" 7 "25feb2025" 8 "03mar2025" 9 "10mar2025" 10 "17mar2025" 11 "24mar2025" 12 "01apr2025" 13 "08apr2025" 14 "15apr2025" 15 "22apr2025" 16"29apr2025" 17 "06may2025" "'
	twoway (rbar zero participants_2m week_num , color(cranberry%30) barw(0.5)) ///
		   (rbar zero participants_6w week_num1 , color(mint%30) barw(0.5)), ///
		   ylabel(0(20)120, format(%9.0gc) labsize(small)) ///
		   xlabel(`rlab', angle(45)) ///
            title("Distinction of Participants") ///
            ytitle("Number of Participants") ////
            xtitle("Recruitment Date") ///
		   legend(order(1 "2m Online Participants" 2 "2m Onsite Participants")) ///
		   graphregion(color(white))
	  
graph export "$results/figures/distinction_bewteen_2m_6w.pdf", replace





