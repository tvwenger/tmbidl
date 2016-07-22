pro mgauss,x,a,f,pder,help=help
;+
; NAME:
;       MGAUSS
;
;            =======================================
;            Syntax: mgauss, x, a, f, pder,help=help
;            =======================================
;
;   mgauss   The Gaussian function required by curvefit.
;   ------   Used to fit the sum of a number of Gaussians.
;            Taken from ASTROLIB.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'mgauss' & return & endif
;
ngauss=n_elements(a)/3                          ;  'a' stores the Gaussian coeffs 
f=fltarr(n_elements(x))
pder=fltarr(n_elements(x),n_elements(a))
;
for i=0,ngauss-1 do begin
     h=a[i*3+0]          
     c=a[i*3+1]
     w=a[i*3+2]
     fx=h*exp(-4.0*alog(2)*(x-c)^2/w^2)
     f=f+fx
     pder[*,i*3+0]=fx/h
     pder[*,i*3+1]=fx*8.0*alog(2)*(x-c)/w^2
     pder[*,i*3+2]=fx*8.0*alog(2)*(x-c)^2/w^3
endfor
;
return
end
