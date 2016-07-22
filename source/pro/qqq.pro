pro qqq,scan_number,help=help
;+
; NAME:
;       QQQ
;
;            ==================================
;            Syntax: qqq, scan_number,help=help
;            ==================================
;
;  qqq    Uses QLOOK4 to give a quick look at a single TP on/off pair
;  ---    for data taken in the 3He configuration:  8 x 2 correlators
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'qqq' & return & endif
;
clearset
settype,'ON'
setscan,scan_number
;
qlook4
;
return
end
