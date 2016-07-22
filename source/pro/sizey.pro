PRO sizey,yfact,help=help
;+
; NAME:
;       SIZEY
;
;            =============================
;            Syntax: sizey,yfact,help=help
;            =============================
;
;   sizey  Resize the Y-axis using range of data intensities. 
;   -----  Default sets Y-axis from ymin-0.05*yrange to ymax+0.05*yrange
;
;          'yfact' is the factor by which the Y-axis is scaled:
;           yfact = 0.05 makes the axis 5% LARGER (default)
;                  -0.05 makes the axis 5% SMALLER 
;
;   USES THE !Y.CRANGE ARRAY WHICH IS ONLY SET *AFTER* A CALL TO 'SHOW'
;-
; MODIFICATION HISTORY:
; V5.1 TMB 21jul08 
;      tmb 23jul08 fixed CURON bug
;          24jul08 made much more general 
;
; V6.1 tmb 22oct09 
;      tmb 16aug10  fixed back to !y.crange and eliminated
;                   curon/curoff as sety.pro has been generalized
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'sizey' & return & endif
;
; set y-axis range
;
if n_params() eq 0 then yfact=0.05
;
ymin = min(!y.crange,max=ymax) 
yrange=abs(ymax-ymin) & yincr=yfact*yrange
ymin=ymin-yincr & ymax=ymax+yincr
sety,ymin,ymax 
;
xx 
;
return
end
 
