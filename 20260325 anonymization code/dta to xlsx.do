clear all
set more off

*============================*
* 1. 设置文件夹路径
*============================*
* 把下面路径改成你的实际文件夹路径
local folder "/Users/zikangzhang/Desktop/Predoc/BEBE/06_Data/04_Anonymized data"

*============================*
* 2. 六位数字编码列表
*============================*
local codes ///
    593646 175343 464493 241113 241204 250703 250427 250314 ///
    877826 250120 250125 ///
    784365 559392 414279 872571 793221 968746 423721 659129 ///
    659371 826686 137936 839976 757445 644261 972288 563862 ///
    716853 477485 727311 492913 941843 110807 ///
    643199 714695 795738 448999 753661 669218 792737 ///
    815998 184411 265968 924349 446773 ///
    573762 917974 567772 291237 415357 331106 331112 ///
    975966 721796 455394 948966 575937 660828 ///
    101005 771105 771120 771204 771205 ///
    100814 887747 375839

*============================*
* 3. 批量转换 dta -> xlsx
*============================*
foreach code in `codes' {

    local infile  "`folder'/results-survey`code'.dta"
    local outfile "`folder'/results-survey`code'.xlsx"

    capture confirm file "`infile'"
    if _rc == 0 {
        di as txt "Processing: `infile'"
        use "`infile'", clear
        export excel using "`outfile'", firstrow(variables) replace
    }
    else {
        di as err "File not found: `infile'"
    }
}

di as result "Done."
