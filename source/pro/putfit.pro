pro putfit,fit,help=help,debug=debug
;+
; NAME:
;       PUTFIT
;
;    ======================================================
;    SYNTAX: putfit,fit,help=help,noinfo=noinfo,debug=debug
;    ======================================================
;
;   putfit   Takes structure 'fit' packed with NREGION 
;   ------   and Gaussian fit info and sets the relevant 
;            !system_variables 
;         
;   INPUTS:  FIT  structure containing baseline and 
;            Gaussian fit parameter initial values
;
;      fit = { nfit:nfit, $
;              nrset:nrset, $
;              nregion=fltarr(2*nrset), $
;              ngauss:ngauss, $
;              bgauss:0., $
;              egauss:0., $
;              height:fltarr(ngauss), $
;              errheight:fltarr(ngauss), $
;              center:fltarr(ngauss), $
;              errcenter:fltarr(ngauss)
;              width:fltarr(ngauss), $
;              errwidth:fltarr(ngauss) $
;            }
;
;   KEYWORDS
;
;           HELP    /help   Provide Syntax and other help
;           DEBUG  /debug  prints out contents of input fit structure
;
;-
; V7.0 1 july 2012 tmb 
;      27may2013 tmb !debug 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
; 
if KeyWord_Set(help) then begin & get_help,'putfit' & return & endif
;
if n_params() eq 0 then begin & 
              print,'ERROR! Must supply structure containing fit info'
              return & endif 
if KeyWord_Set(debug) then print,fit
;
; calculate dVEL per channel
;
freq=!b[0].rest_freq & bw=!b[0].bw & nchan=n_elements(!b[0].data)
dnu=bw/nchan & dnu=dnu*1000.d
dvel=(dnu/freq)*!light_c & dvperchan=dvel/1000.d
;
; push fit structure values into !vars keeping track of x-axis units  
;
!nfit=fit.nfit
!nrset=fit.nrset
nregion=fit.nregion & idval,nregion,nregvalue & !nregion[0:2*!nrset-1]=nregvalue
;
!ngauss=fit.ngauss 
bgauss=fit.bgauss & idval,bgauss,bgvalue & !bgauss=bgvalue
egauss=fit.egauss & idval,egauss,egvalue & !egauss=egvalue
;
; this is tricky.  start by assuming x-axis is in CHANnels 
;
for i=0,!ngauss-1 do begin
    !a_gauss[0+i*3]=fit.height[i]
    !g_sigma[0+i*3]=fit.errheight[i]
    c=fit.center[i] & idval,c,cval
    !a_gauss[1+i*3]=cval
    !g_sigma[1+i*3]=fit.errcenter[i]
    !a_gauss[2+i*3]=fit.width[i]
    !g_sigma[2+i*3]=fit.errwidth[i]
endfor
;
flush:
;
return
end
