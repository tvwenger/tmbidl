;+
; NAME:
;       PLOTGRS
;
;            ==============================================
;            Syntax: pltgrs
;            ==============================================
;
;   pltgrs  procedure to plot NSAVEd GRS Beamap spectra toward
;   ------  HRDS HII regions using stored HISTORY information.
;
;
;
;   KEYWORDS:
;
; MODIFICATION HISTORY:
;
; V6.1  tmb 07mar2011
;
;-
pro plotgrs,vrrl
;
@CT_IN
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
rehash,/reset
vmin=!nregion[0] & vmax=!nregion[2.*!nrset-1] & setx,vmin,vmax & xx
zline & flagoff & g
;
fits=' '
grsfits,vrrl,fits
flag,vrrl
flag,vrrl-10.,color=!yellow
flag,vrrl+10.,color=!yellow
for i=0,fits.ngauss-1 do begin
    flag,fits.center[i],color=!cyan
endfor
;
@CT_OUT
return
end
