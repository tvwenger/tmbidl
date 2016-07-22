pro gcomp,ngauss=ngauss,center=center,height=height,width=width,$
          thick=thick,help=help
;+
; NAME:
;       GCOMP
;
;  =====================================================================
;  SYNTAX: gcomp,ngauss=ngauss,center=center,height=height,width=width,$
;                thick=thick,help=help,cpgcomp=cpgcomp
;  =====================================================================
;
;   gcomp  Calculate and plot model Gaussian components individually.
;   -----  Assumes !nsave and !a_gauss fits unless explicitly passed.
;          Stores first 5 gaussian model components in !b[10-14]
; 
;         Can pass Gaussian model parameters as keywords
;         NGAUSS is scalar all others are vectors of length(NGAUSS)
;
;    KEYWORDS:  help    - gives this help
;               thick   - thickness of model curve (default 2.0)
;               cpgcomp - copy gaussian component fit info in
;                         !a_gauss 
;
;-
; MODIFICATION HISTORY:
; V6.1 13Feb2010 TMB 
;      30jul2012 tvw - added thick keyword, default is 0.5
;
; V7.0 3may2013 tvw - added /help, !debug
;      23may2013 tvw - added cpgcomp keyword to call cpgcomp before
;                      doing anything else
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'gcomp' & return & endif
@CT_IN
;
if keyword_set(cpgcomp) then cpgcomp
if ~keyword_set(thick) then thick=2.0
;
def_xaxis                ;   determine x-axis units
clr=!orange
get_clr,clr
;
gauss_x=!xx
yfit=fltarr(n_elements(gauss_x))
;
; Get Gaussin fit parameters from !ngauss and !a_gauss unless
; passed explicitly
;
case Keyword_Set(ngauss) of
     0:begin & ngauss=!ngauss & a=!a_gauss & end
     1:begin
       a=fltarr(3*ngauss) & c=center & h=height & w=width
       for i=0,ngauss-1 do begin
           a[i*3+0]=h[i] & a[i*3+1]=c[i] & a[i*3+2]=w[i]
       endfor
       end
endcase
;
for i=0,ngauss-1 do begin
      h=a[i*3+0]
      c=a[i*3+1]
      w=abs(a[i*3+2])
      ycomp=h*exp(-4.0*alog(2)*(gauss_x-c)^2/w^2)
      oplot,gauss_x,ycomp,thick=thick,color=clr
;
      case i of
               0: copy,0,10 ; comp# 1
               1: copy,0,11 ; comp# 2
               2: copy,0,12 ; comp# 3
               3: copy,0,13 ; comp# 4
               4: copy,0,14 ; comp# 5
            else: print,'No more !b[] space to store model component'
      endcase
endfor
;
@CT_OUT
return
end
