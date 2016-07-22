pro pl6543,help=help
;+
; NAME:
;       PL6543
;       pl6543,help=help
;
;   pl.pro   Study of 3He Pseudo Line in NGC6543
;   ------ 
;-
; V5.0 June 2007 
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'pl6534' & return & endif
;
; first do N6543
getns,601
accum
f1=!b[0].sky_freq
getns,401
;wrap,-19
accum
f2=!b[0].sky_freq
diff=f1-f2
bw=!b[0].bw
nchan=!data_points
cshift=(diff/bw)*nchan
print,'N6543 sky freq diff is ',diff
print,'      channel shift is ',cshift
;
ave
smooth      ; 5 channel gaussian smooth
mk
dcsub,1750,2250
;
return
end
