pro pl,help=help
;+
; NAME:
;       PL
;       pl,help=help
;
;   pl.pro   Study of 3He Pseudo Line 
;   ------ 
;-
; V5.0 June 2007 
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'pl' & return & endif
;
; first do N6826
getns,625
accum
f1=!b[0].sky_freq
getns,425
wrap,-19
accum
f2=!b[0].sky_freq
print,'N6826 sky freq diff is ',f1-f2
;
ave
smooth      ; 5 channel gaussian smooth
mk
dcsub,1750,2250
;
return
end
