* 手动列出所有sheet名称
local sheet_names 20251228 20251221 20251214 20251207 20251130 20251123 20251116 20251109 20251102 20251026 20251020 20251013 20251005 20250928 20250921 0915 0908 0901 0824 ///
0817 0810 0803 0728 0721 0714 0707 0629 0622 0615 0608 0601 0525 0518 0511 0504 0427 ///
0420 0413 0406 0330 0323 0316 0309 0302 0223 0216 0209 0126 0119 0112 0105 1229 1222 ///
1215 1208 1201 1124 1117 1110 1103 1027 1020 1013 1006 0928 0921 0914 0907 0831 0823 ///
0818 0811 0804 0727 0719 0713 0706




import excel "$data/Contact List.xlsx", sheet("`=word("`sheet_names'",1)'") firstrow allstring clear



forvalues i = 2/`: word count `sheet_names'' {
      preserve
     import excel "$data/Contact List.xlsx", sheet("`=word("`sheet_names'",`i')'") firstrow allstring clear
    tostring 日期, replace
    tempfile temp`i'
    save `temp`i''
    restore
    append using `temp`i'', force
 }
 drop if 住院号 == ""

 save "$proc/contact_list.dta", replace


 
 
// * 手动列出所有sheet名称
// local sheet_names 0316 0309 0302 0223 0216 0209 0126 0119 0112 0105 1229 1222 ///
// 1215


// import excel "$data/Contact List.xlsx", sheet("`=word("`sheet_names'",1)'") firstrow allstring clear



// forvalues i = 2/`: word count `sheet_names'' {
//       preserve
//      import excel "$data/Contact List.xlsx", sheet("`=word("`sheet_names'",`i')'") firstrow allstring clear
//     tostring 日期, replace
//     tempfile temp`i'
//     save `temp`i''
//     restore
//     append using `temp`i'', force
//  }
//  drop if 住院号 == ""

//  save "$proc/contact_list_10m_second.dta", replace

