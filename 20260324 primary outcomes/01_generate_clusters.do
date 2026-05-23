*******************************************************************************
* TITLE: GENERATE CLUSTER VARIABLES
* PROJECT: BEBE 
* AUTHOR: Haoyue Wu
* Last updated: Nov 4, 2025



// room number
import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match.xlsx", firstrow sheet("Sheet1") clear
keep room_yfy room_num
gen ward = substr(room_num,1,2)
drop if ward == "5A"
gen bed = substr(room_num,3,2)
replace bed = "0" + bed if strlen(bed) == 1
drop room_num
gen room_num = ward + bed 
drop ward bed
tempfile east_ordinary1
save  `east_ordinary1'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match_ordinary.xlsx", firstrow sheet("Sheet1") clear
keep room_yfy roomID 
rename roomID room_num
append using `east_ordinary1'
tempfile east_ordinary
save `east_ordinary'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_ordinary.xlsx", firstrow allstring sheet("Sheet1") clear
keep room_yfy roomID
rename roomID room_num
drop if room_yfy == ""
append using `east_ordinary'
tempfile ordinary 
save `ordinary'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization_west/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear
keep room_yfy roomID
tempfile west_vip
save `west_vip'

import excel using "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/1_randomization/data/room_bed_match_vip.xlsx", firstrow allstring sheet("Sheet1") clear
keep room_yfy roomID
append using `west_vip'
rename roomID room_num

append using `ordinary'

duplicates drop room_yfy, force

save "$proc/room_bed_match.dta", replace






clear
local files "593646 175343 464493 241113 241204 877826 250120 250125 250314 250427 250703"

foreach id of local files {
    import delimited using "$data/Enumerator/results-survey`id'.csv", ///
        bindquote(strict) stringcols(_all) encoding("utf-8") clear
    gen survey_id = `id'
    tempfile survey`id'
    save `survey`id''
}

use `survey593646', clear
foreach id in 175343 464493 241113 241204 877826 250120 250125 250314 250427 250703 {
    append using `survey`id'', force
}

*  ------ clean data ------ *
drop if submitdate == ""

rename g01q01 enumerator
rename g01q02 datetime
rename g01q03 ward
rename g01q04sq001 bed 
rename g01q07sq001 hospital_id

keep enumerator datestamp datetime ward bed hospital_id survey_id checkenumerator

* date time that is used to match the randomization code
gen datetime_temp = date(datetime, "YMDhms") if survey_id ~= 175343
replace datetime_temp = date(substr(datetime, 1, 8), "MD20Y") if survey_id == 175343
format datetime_temp %td
drop datetime
rename datetime_temp datetime


* date stamp 
gen datestamp_temp = date(datestamp, "YMDhms") if survey_id ~= 175343
replace datestamp_temp = date(substr(datestamp, 1, 8), "MD20Y") if survey_id == 175343
format datestamp_temp %td
drop datestamp
rename datestamp_temp datestamp

* manually fix some errorous records in the survey
replace enumerator = "Maggie" if enumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")
replace checkenumerator = "Maggie" if checkenumerator == "Vivi" & datestamp < date("2024-12-30", "YMD")
replace checkenumerator = "Cong" if hospital_id == "332803"
replace enumerator = checkenumerator if enumerator != checkenumerator & checkenumerator != ""  & checkenumerator != "." 
replace checkenumerator = "Lucy" if checkenumerator == "Finn" & datestamp == date("2024-11-02","YMD")
encode enumerator, gen(enumerator_id)

replace bed = "0" + bed if strlen(bed) == 1
gen room_yfy = ward + bed

merge m:1 room_yfy using "$proc/room_bed_match.dta"
replace room_num = "328" if room_num == ""
drop if _merge == 2
drop _merge 

// month num
gen cutoff_date = date("24/09/2024", "DMY")
gen week_num = floor((datetime - cutoff_date) / 7) 
gen month_num = floor((datetime - cutoff_date) / 28)
gen onsite_date = datestamp > date("07/02/2025", "DMY")

// vip
destring bed, replace force
* eastside
gen vip = 0 
replace vip = 1 if strlen(ward) == 3
replace vip = 1 if inlist(bed,211,213,215,216,217,218,219,220,221,323,325,326,327,328,501,502,503,505,506,507,508,509,510,511,512,513,515)


// triple room
gen bed_in_room = 2 
replace bed_in_room = 1 if strlen(ward) == 3
replace bed_in_room = 3 if (ward == "4A" & bed < 39)
replace bed_in_room = 3 if (ward == "5A" & bed < 38)
replace bed_in_room = 3 if (ward == "5B" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "5B" & bed < 50 & bed > 46)
replace bed_in_room = 3 if (ward == "6A" & bed < 38)
replace bed_in_room = 3 if (ward == "6B" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "6B" & bed < 50 & bed > 46)
replace bed_in_room = 3 if (ward == "7A" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "7B" & bed < 40 & bed > 2)
replace bed_in_room = 3 if (ward == "7B" & bed > 46)

* westside
replace bed_in_room = 1 if bed > 99
replace bed_in_room = 2 if inlist(bed,202,203,205,206,207,208,209,210)
replace bed_in_room = 3 if inlist(bed,332,333,335,336,337,338)
replace bed_in_room = 4 if inlist(bed,330,331,332,355,317,318,319,353,313,315,316,352,310,311,312,351,307,308,309,350)
replace bed_in_room = 5 if inlist(bed,301,302,303,305,306)


// randomization strata
gen triple = (bed_in_room != 2 & bed_in_room != 1) 
egen bed_num = group(vip triple)
drop if bed_num == 4

// randomization strata
egen strata = group(bed_num month_num) 


//cluster var
gen ward_num = substr(ward,1,1) if vip == 0
destring ward_num, replace force
gen cluster_var = ward_num*1000+ bed * 100 + week_num if vip == 0
replace cluster_var = bed * 100 + week_num if cluster_var == .
destring hospital_id, gen(hospital_id_temp)
replace cluster_var = hospital_id_temp if vip == 1
drop hospital_id_temp

drop if hospital_id == ""
duplicates drop hospital_id, force
// save a file that will be used to merge cluster variables with other datasets
keep hospital_id vip bed_num cluster_var enumerator_id strata onsite_date
save "$proc/clustered_data.dta", replace


