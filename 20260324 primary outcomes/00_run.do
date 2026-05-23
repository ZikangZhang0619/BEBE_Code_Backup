// BOILERPLATE ---------------------------------------------------------- 
// For nearly-fresh Stata session and reproducibility
set more off
set varabbrev off
clear all
macro drop _all

// DIRECTORIES ---------------------------------------------------------------
// Define CODE path (where your scripts are stored)
if "$code_path"=="" {
    if "`c(username)'" == "isabellawu" { 
        global code_path "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/08_BEBE/05_Code/Primary Outcome Analysis"
    }
	else if "`c(username)'" == "zikangzhang" { 
        global code_path "/Users/zikangzhang/Library/CloudStorage/OneDrive-UniversitätZürichUZH/Anne Ardila Brenoe 的文件 - 08_BEBE/05_Code/1_Primary Outcome Analysis"
    }
    else { 
        display as error "User not recognized."
        display as error "Specify global code_path in 00_run.do."
        exit 198
    }
}

// Define MAIN path (where your data and results are stored)
if "$main"=="" {
    if "`c(username)'" == "isabellawu" { 
        global main "/Users/isabellawu/Library/CloudStorage/OneDrive-UniversitätZürichUZH/collaboration desk - BEBE/data analysis/BEBE/Combine Survey Data"
    }
	else if "`c(username)'" == "zikangzhang" { 
        global main "/Users/zikangzhang/Library/CloudStorage/OneDrive-UniversitätZürichUZH/Haoyue Wu 的文件 - collaboration desk - BEBE/data analysis/Combine Survey Data"
    }
    else { 
        display as error "User not recognized."
        display as error "Specify global main in 00_run.do."
        exit 198
    }
}

// Create subfolders under DATA/RESULTS path
local main_subdirectories ///
    data             ///
    documentation    ///
    logs             ///
    proc             ///
    results

foreach folder of local main_subdirectories {
    cap mkdir "$main/`folder'" 
    global `folder' "$main/`folder'"
}

// Create scripts folder under CODE path
cap mkdir "$code_path/scripts"
global scripts "$code_path/scripts"

// Create results subfolders
cap mkdir "$results/figures"
cap mkdir "$results/tables"
cap mkdir "$scripts/programs"

// Display paths for verification
display as result _newline "Code path: $code_path"
display as result "Data/Results path: $main"
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
		return local tim`x' = "`time`x''"
	}
	c_local time "`time'"
	c_local date "`time_d'"
end

// PRELIMINARIES -------------------------------------------------------------
// Control which scripts run
// local 01_data_clean = 1
// local 02_format_result  = 1
// local 03_analysis    = 1

// RUN SCRIPTS ---------------------------------------------------------------
// 
// if (`01_dataprep' == 1) do "$scripts/01_data_clean.do"
// if (`02_desc' == 1) do "$scripts/02_format_result.do"


**主要修改点：**

// 1. **新增 `$code_path`**：指向你的代码文件夹
// 2. **`$main`**：指向你的数据和结果文件夹
// 3. **`$scripts`**：在代码路径下创建
// 4. **其他文件夹**（data, documentation, logs, proc, results）：在数据路径下创建
// 5. **移除了路径中的引号问题**：Mac路径不需要单引号包裹
// 6. **添加了路径显示**：运行时会显示所有路径，方便你验证

// **文件夹结构：**
// ```
// 代码路径 ($code_path):
// └── scripts/
//     └── programs/

// 数据路径 ($main):
// ├── data/
// ├── documentation/
// ├── logs/
// ├── proc/
// └── results/
//     ├── figures/
//     └── tables/
