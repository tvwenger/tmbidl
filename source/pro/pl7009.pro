pro pl7009,help=help
;+
; NAME:
;       PL7009
;       pl7009,help=help
;
;   pl.pro   Study of 3He Pseudo Line in NGC 7009
;   ------ 
;-
; V5.0 June 2007 
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be []
 if keyword_set(help) then begin & get_help,'pl7009' & return & endif
;
; N7009
getns,649
accum
f1=!b[0].sky_freq
getns,449
wrap,-18
accum
f2=!b[0].sky_freq
diff=f1-f2
bw=!b[0].bw
nchan=!data_points
cshift=(diff/bw)*nchan
print,'N7009 sky freq diff is ',diff
print,'      channel shift is ',cshift
;
ave
smooth      ; 5 channel gaussian smooth
mk
dcsub,1750,2250
;
return
end
