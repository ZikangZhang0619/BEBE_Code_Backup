import delimited using "$data/tokens_659371.csv", encoding("UTF-8") clear
tempfile 2
save `2'

import delimited using "$data/tokens_826686.csv", encoding("UTF-8") clear
tempfile 3
save `3'

import delimited using "$data/tokens_137936.csv", encoding("UTF-8") clear
tempfile 4
save `4'

import delimited using "$data/tokens_839976.csv", encoding("UTF-8") clear
tempfile 5
save `5'

import delimited using "$data/tokens_757445.csv", encoding("UTF-8") clear
tempfile 6
save `6'

import delimited using "$data/tokens_644261.csv", encoding("UTF-8") clear
tempfile 7
save `7'

import delimited using "$data/tokens_972288.csv", encoding("UTF-8") clear


// append using `1' , force
append using `2' , force
append using `3' , force
append using `4' , force
append using `5' , force
append using `6' , force
append using `7' , force

gen treatment = "C" if attribute_4控制组 == "Y"
	replace treatment = "T1" if attribute_5t1 == "Y"
	replace treatment = "T2" if attribute_6t2 == "Y"
gen parent = "F" if attribute_8父亲 == "Y"
	replace parent = "M" if attribute_7母亲 == "Y"
gen baby_gender = "Boy" if attribute_10男宝宝 == "Y"
	replace baby_gender = "Girl" if attribute_9女宝宝 == "Y"
drop if attribute_11住院号 == ""

// ----- attrition analysis -----

gen date_invited = date(invited, "YMDhm")
format date_invited %td
// drop if date_invited < date("2024-11-01", "YMD") // keep only those with 50 reminder call incentive
// drop if date_invited == date("2024-11-21", "YMD")
duplicates report attribute_11住院号
duplicates tag attribute_11住院号, gen(tag)
br if tag == 2 
sort date_invited
drop if firstname == 13616298980 | firstname == 15822222920 | firstname == 18611768884 
drop tag
replace firstname = 15277315277 if lastname == "陶慧梅"


duplicates report firstname
duplicates tag firstname, gen(tag)
br if tag == 1

drop tag
duplicates tag attribute_11住院号, gen(tag)


rename attribute_11住院号 hospitalID
replace completed = "Y" if completed ~= "N"
keep firstname lastname completed remindercount treatment parent baby_gender date_invited hospitalID
drop if firstname == 18580838102

gen attrition = (completed == "Y")

drop if date_invited == date("2025-1-16", "YMD")
drop if date_invited == date("2025-1-23", "YMD")

gen hospitalid = substr(hospitalID, 4, 6)
gen mother = (parent == "M")
tostring mother, replace
gen merge_var = hospitalid + mother
save "$proc/attritiontoken_1m.dta", replace


