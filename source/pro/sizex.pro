PRO sizex,xfact,help=help
;+
; NAME:
;       SIZEX
;
;            =============================
;            Syntax: sizex,xfact,help=help
;            =============================
;
;   sizex  Resize the X-axis using range of data intensities. 
;   -----  Default sets X-axis from xmin-0.05*xrange to xmax+0.05*xrange
;
;          'xfact' is the factor by which the X-axis is scaled:
;           xfact = 0.05 makes the axis 5% LARGER (default)
;                  -0.05 makes the axis 5% SMALLER 
;
;   USES THE !X.CRANGE ARRAY WHICH IS ONLY SET *AFTER* A CALL TO 'SHOW'
;-
; MODIFICATION HISTORY:
; V5.1 TMB 24jul08 
; V6.1 tmb 16aug10  removed curon/curoff because of new setx
; V7.0 03may2013 tvw - added /help, !debug
;
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'sizex' & return & endif
;
; set x-axis range
;
if n_params() eq 0 then xfact=0.05
;
xmin = min(!x.crange,max=xmax) 
xrange=abs(xmax-xmin) & xincr=xfact*xrange
xmin=xmin-xincr & xmax=xmax+xincr
setx,xmin,xmax 
;
xx 
;
return
end
 
