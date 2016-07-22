pro prtfit,help=help
;+
; NAME:
;       PRTFIT
;
;            =======================================
;            Syntax: prtfit,help=help
;            =======================================
;
;   prtfit  Creates ps plot of spectrum + fit
;   ------   
;-
;  V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'prtfit' & return & endif
;
fname=' '
print,'enter file name for plot'
read,fname
printon,fname
xx
lmarker
flagon
g
zline
printoff
;
return
end

