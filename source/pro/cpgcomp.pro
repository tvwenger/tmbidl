pro cpgcomp,oplot=oplot,help=help
;+
; NAME:
;       CPGCOMP
;
;  =====================================
;  SYNTAX: cpgcomp,oplot=oplot,help=help
;  =====================================
;
;   gcomp Use !ngauss and !agauss to model
;   ----- gfits and then copy them to !b[1]
; 
;   KEYWORDS:  help  - gives this help
;              oplot - overplot gfits model
;-
; MODIFICATION HISTORY:
; V6.1 15jun2012 TMB 
;
; v7.0 27may2013 tmb merged !debug help 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'cpgcomp' & return & endif
;
@CT_IN
;
def_xaxis                ;   determine x-axis units
;
gauss_x=!xx
yfit=fltarr(n_elements(gauss_x))
;
; Get Gaussin fit parameters from !ngauss and !a_gauss
;
ngauss=!ngauss & a=!a_gauss
;
ycomp=fltarr(n_elements(gauss_x))
;
for i=0,ngauss-1 do begin
      h=a[i*3+0]
      c=a[i*3+1]
      w=abs(a[i*3+2])
      ycomp=ycomp+h*exp(-4.0*alog(2)*(gauss_x-c)^2/w^2)
      if keyword_set(oplot) then $
         oplot,gauss_x,ycomp,thick=0.5,color=clr
endfor
copy,0,1
!b[1].data=ycomp
!b[1].line_id=byte('GMODEL')
;
@CT_OUT
return
end
