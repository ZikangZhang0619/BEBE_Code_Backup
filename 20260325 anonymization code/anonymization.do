
*'/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/0_Data Anonymization/id_mapping_confidential.xlsx'
*'/Users/zikangzhang/Desktop/Predoc/BEBE/06_Raw Data'


*******************************************************
* Anonymization pipeline for BEBE survey data
*
* 功能说明：
* 1. 读取院内保存的 id_mapping_confidential.xlsx
*    - hospital_id -> family_id
*    - phone       -> family_id
*
* 2. 处理 Enumerator survey：
*    - 读取结果文件 results-survey######.csv
*    - 根据院区（HospitalBranch / G01Q03）给住院号补前缀：
*         东院 -> D000 + 原住院号
*         西院 -> 000  + 原住院号
*    - 用补齐后的住院号匹配 family_id
*    - 预留 cluster / strata 生成位置（本代码不实现）
*    - 删除文档中列出的敏感变量
*
* 3. 处理其他问卷（baseline, 1m, 2m, 2m onsite, 3m, 6m, 7m, 10m）：
*    - 按每类问卷对应的手机号变量匹配 family_id
*    - 删除文档中列出的敏感变量
*
* 4. 输出匿名化后的 csv：
*    - 文件名保持不变
*    - 输出到另一个文件夹
*
* 注意：
* - 本代码不做重复值检查、匹配率检查等数据质量筛查
* - 本代码不生成 cluster / strata，只留空白接口
* - 2m onsite 只使用 Mphone 匹配 family_id
* - 7m / 10m 除微信号变量外，也删除 firstname / lastname /
*   attribute_3 / attribute_11
*******************************************************

clear all
set more off

*******************************************************
* 0. 路径设置（这里改成你们医院服务器上的实际路径）
*******************************************************

local raw_dir  "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/01_Raw data backup/20260320"
local out_dir  "/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/0_Data Anonymization/Output"
local map_file "/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/0_Data Anonymization/data/id_mapping_confidential.xlsx"

cap mkdir "`out_dir'"

*******************************************************
* 1. 小工具
*******************************************************

* 把可能不同名字的变量，统一重命名为指定名称
* 用法：
* canonvar 新变量名 候选变量名1 候选变量名2 ...
capture program drop canonvar
program define canonvar
    gettoken target 0 : 0
    local found 0

    foreach v of local 0 {
        capture confirm variable `v'
        if !_rc {
            if "`v'" != "`target'" {
                rename `v' `target'
            }
            local found 1
            continue, break
        }
    }

    if !`found' {
        di as error "Variable for `target' not found. Tried: `0'"
        exit 111
    }
end

* 如果变量存在，就删除
capture program drop drop_if_exists
program define drop_if_exists
    foreach v of local 0 {
        capture drop `v'
    }
end

*******************************************************
* 2. 读取 mapping 文件
*******************************************************

tempfile hosp_map phone_map

import excel using "`map_file'", firstrow clear allstring

replace hospital_id = trim(itrim(hospital_id))
replace phone       = trim(itrim(phone))
replace phone       = subinstr(phone, " ", "", .)

preserve
    keep hospital_id family_id
    drop if missing(hospital_id) | missing(family_id)

    * 如果同一个家庭在 mapping 里有两行（如父母两行），这里去重
    bysort hospital_id family_id: keep if _n == 1
    bysort hospital_id: keep if _n == 1

    save `hosp_map', replace
restore

keep phone family_id
rename phone survey_phone
drop if missing(survey_phone) | missing(family_id)

* 去重，避免同一手机号重复导致 m:1 merge 报错
bysort survey_phone family_id: keep if _n == 1
bysort survey_phone: keep if _n == 1

save `phone_map', replace




*******************************************************
* 3. Enumerator survey
*
* 住院号匹配逻辑：
* - contact_list / id_mapping_confidential.xlsx 中的 hospital_id 带前缀
*   东院：D00 + 住院号
*   西院：000 + 住院号
*
* - 大多数 Enumerator 版本只有东院样本，
*   住院号变量为 G01Q07[SQ001]，原始值不带前缀，
*   因此这里统一补 D00
*
* - 在 877826 / 250120 / 250125 三个版本中：
*   东院住院号变量 = G01Q07[SQ001]
*   西院住院号变量 = G01Q07W[SQ001]
*   两列原始值都不带前缀，因此这里分别补 D00 / 000
*******************************************************

* 普通版本：只有东院
local enumerator_east ///
    593646 175343 464493 241113 241204 250314 250427 250703

foreach ver of local enumerator_east {

    di as txt "Processing Enumerator version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        bindquote(strict) stringcols(_all) encoding("utf-8") clear

    canonvar hospital_id_raw g01q07sq001 g01q07_sq001
    replace hospital_id_raw = trim(itrim(hospital_id_raw))

    * 普通版本只有东院，因此补 D00
    gen str40 hospital_id = "D00" + hospital_id_raw

    * 匹配 family_id
    merge m:1 hospital_id using `hosp_map', keep(master match) nogen

    ***************************************************
    * 在这里填写你们现有的 cluster / strata 生成代码
    ***************************************************

    * 删除敏感变量
    drop_if_exists ///
        g01q03 ///
        g01q04sq001 g01q04_sq001 ///
        g01q06 ///
        g01q07sq001 g01q07_sq001 ///
        hospital_id_raw hospital_id ///
		ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

* 特殊版本：东院和西院分成两列
local enumerator_both 877826 250120 250125

foreach ver of local enumerator_both {

    di as txt "Processing Enumerator version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        bindquote(strict) stringcols(_all) encoding("utf-8") clear

    capture rename g01q07sq001  hospital_id_east
    capture rename g01q07_sq001 hospital_id_east

    capture rename g01q07wsq001  hospital_id_west
    capture rename g01q07w_sq001 hospital_id_west

    replace hospital_id_east = trim(itrim(hospital_id_east))
    replace hospital_id_west = trim(itrim(hospital_id_west))

    gen str40 hospital_id = ""
    replace hospital_id = "D00" + hospital_id_east if hospital_id_east != ""
    replace hospital_id = "000" + hospital_id_west if hospital_id == "" & hospital_id_west != ""

    * 匹配 family_id
    merge m:1 hospital_id using `hosp_map', keep(master match) nogen

    ***************************************************
    * 在这里填写你们现有的 cluster / strata 生成代码
    ***************************************************

    * 删除敏感变量
    drop_if_exists ///
        g01q03 ///
        g01q04sq001 g01q04_sq001 ///
        g01q06 ///
        g01q07sq001 g01q07_sq001 ///
        g01q07wsq001 g01q07w_sq001 ///
        hospital_id_east hospital_id_west hospital_id ///
		ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}





*******************************************************
* 4. Baseline
*******************************************************

* 4.1 Baseline 784365：手机号变量 = G06Q03
local baseline_784365 784365

foreach ver of local baseline_784365 {

    di as txt "Processing Baseline version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone g06q03
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists ///
        g01q01sq001 g01q01_sq001 ///
        g06q02 ///
        g06q03 ///
        g06q04sq001 g06q04_sq001 ///
        g06q05other g06q05_other ///
        survey_phone ///
		ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

* 4.2 其他 Baseline：手机号变量 = G05Q02[SQ001]
local baseline_other 559392 414279 872571 793221 968746 423721 659129

foreach ver of local baseline_other {

    di as txt "Processing Baseline version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone g05q02sq001 g05q02_sq001 g05q02
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists ///
        g01q01sq001 g01q01_sq001 ///
        g05q01 ///
        g05q02sq001 g05q02_sq001 g05q02 ///
        g09q40other g09q40_other ///
        g05q03sq001 g05q03_sq001 ///
        survey_phone ///
		ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

*******************************************************
* 5. 1m
* 手机号变量 = firstname
*******************************************************

local m1_versions ///
    659371 826686 137936 839976 757445 644261 972288 ///
    563862 716853 477485 727311 492913 941843 110807

foreach ver of local m1_versions {

    di as txt "Processing 1m version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone firstname
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists firstname lastname attribute_3 attribute_11 survey_phone ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

*******************************************************
* 6. 2m / 6w
* 手机号变量 = firstname
*
*******************************************************

local m2_versions 643199 714695 795738 448999 753661 669218 792737

foreach ver of local m2_versions {

    di as txt "Processing 2m version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone firstname
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists firstname lastname attribute_3 attribute_11 survey_phone ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

*******************************************************
* 7. 2m onsite
* 只使用 Mphone 匹配 family_id
*******************************************************

local m2_onsite_versions 815998 184411 265968 924349 446773

foreach ver of local m2_onsite_versions {

    di as txt "Processing 2m onsite version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone mphone
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists ///
        mname fname ///
        mphone fphone ///
        g00q01sq001 g00q01_sq001 ///
        survey_phone ///
		ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

*******************************************************
* 8. 3m
* 手机号变量 = firstname
*******************************************************

local m3_versions 573762 917974 567772 291237 415357 331106 331112

foreach ver of local m3_versions {

    di as txt "Processing 3m version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone firstname
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists firstname lastname attribute_3 attribute_11 survey_phone ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

*******************************************************
* 9. 6m
* 手机号变量 = firstname
*******************************************************

local m6_versions 975966 721796 455394 948966 575937 660828

foreach ver of local m6_versions {

    di as txt "Processing 6m version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone firstname
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists firstname lastname attribute_3 attribute_11 survey_phone ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

*******************************************************
* 10. 7m
* 手机号变量 = firstname
* 还需要删除微信号变量 C005[SQ001], C009[SQ001]
*******************************************************

local m7_versions 101005 771105 771120 771204 771205

foreach ver of local m7_versions {

    di as txt "Processing 7m version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone firstname
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists ///
        firstname lastname attribute_3 attribute_11 ///
        c005sq001 c005_sq001 ///
        c009sq001 c009_sq001 ///
        survey_phone ///
	    ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

*******************************************************
* 11. 10m
* 手机号变量 = firstname
* 还需要删除微信号变量 C005[SQ001], C009[SQ001]
*******************************************************

local m10_versions 100814 887747 375839

foreach ver of local m10_versions {

    di as txt "Processing 10m version `ver'..."

    import delimited using "`raw_dir'/results-survey`ver'.csv", ///
        clear varnames(1) stringcols(_all) case(lower) encoding(utf-8) bindquote(strict)

    canonvar survey_phone firstname
    replace survey_phone = trim(itrim(survey_phone))
    replace survey_phone = subinstr(survey_phone, " ", "", .)

    merge m:1 survey_phone using `phone_map', keep(master match) nogen

    drop_if_exists ///
        firstname lastname attribute_3 attribute_11 ///
        c005sq001 c005_sq001 ///
        c009sq001 c009_sq001 ///
        survey_phone ///
		ipaddr

    save "`out_dir'/results-survey`ver'.dta", replace
}

di as result "Done. Anonymized files have been exported to: `out_dir'"
