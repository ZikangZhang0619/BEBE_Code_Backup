// If the reader wants to replicate the results, they just need to change this global path and put the data in /data file. 
// Run script for my project

// BOILERPLATE ---------------------------------------------------------- 
// For nearly-fresh Stata session and reproducibility
set more off
set varabbrev off
clear all
macro drop _all
//set scheme cleanplots, perm

// DIRECTORIES ---------------------------------------------------------------
if "$code_and_result_path"=="" {
    if "`c(username)'" == "zikangzhang" { 
        global code_and_result_path "/Users/zikangzhang/Library/CloudStorage/OneDrive-UniversitätZürichUZH/Anne Ardila Brenoe 的文件 - 08_BEBE/05_Code/2_Attrition Analysis"
    }
    else { 
        display as error "User not recognized."
        display as error "Specify global code_and_result_path in 00_run.do."
        exit 198
    }
}


if "$main"=="" { // Note this will only be untrue if line above uncommented
                 // due to the `macro drop _all` in the boilerplate
    if "`c(username)'" == "zikangzhang" { // John's Windows computer
        global main "/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/2_Attrition Analysis" // Ensure no spaces 
    }
    else if "`c(username)'" == "haolianghu" { // input other collaborators' PC username
        global main "/Users/haolianghu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/Attrition Analysis"
    } 
    else { // display an error 
        display as error "User not recognized."
        display as error "Specify global main in 00_run.do."
        exit 198 // stop the code so the user sees the error
    }
}

// Create subdirectories for main path (data, documentation, logs, proc)
local main_subdirectories ///
    documentation    ///
    logs             ///
    proc             ///
    
foreach folder of local main_subdirectories {
    cap mkdir "$main/`folder'" // Create folder if it doesn't exist already
    global `folder' "$main/`folder'"
}

// Create subdirectories for code_and_result_path (scripts and results)
cap mkdir "$code_and_result_path/scripts"
cap mkdir "$code_and_result_path/results"

// Create results subfolders if they don't exist already
cap mkdir "$code_and_result_path/results/figures"
cap mkdir "$code_and_result_path/results/tables"
cap mkdir "$code_and_result_path/scripts/programs"

// Set globals for scripts and results
global scripts "$code_and_result_path/scripts"
global results "$code_and_result_path/results"
global data "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/05_Cleaned anonymized data"

display as result _newline "Code and Results path: $code_and_result_path"
display as result "Main project path: $main"
display as result "Scripts folder: $scripts"
display as result "Data folder: $data"
display as result "Results folder: $results"

// programs that return date and time
program define time, rclass
	local time : di %tcCCYYNNDD!_HHMMSS clock("`c(current_date)'`c(current_time)'","DMYhms")
	local time_m = substr("`time'",1,13)
	local time_h = substr("`time'",1,11)
	local time_d = substr("`time'",1,8)
	foreach x in "_d" "_h" "_m" "" {
		return local time`x' = "`time`x''"
	}
	// undocumented way to create a local in ado file (found in levelsof.ado):
	c_local time "`time'"
	c_local date "`time_d'"
end



