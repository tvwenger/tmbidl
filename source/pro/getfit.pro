pro getfit,fit,help=help,debug=debug
;+
; NAME:
;       GETFIT
;
;    ========================================
;    SYNTAX: getfit,fit,help=help,debug=debug
;    ========================================
;
;   getfit   Puts current baseline and Gaussian fit 
;   ------   !vars into structure 'fit'
;         
;      FIT  structure containing current baseline and 
;           Gaussian fit parameters
;
;      fit = { nfit:nfit, $
;              nrset:nrset, $
;              nregion=fltarr(2*nrset), $
;              ngauss:ngauss, $
;              bgauss:bgauss, $
;              egauss:egauss, $
;              height:fltarr(ngauss), $
;              errheight:fltarr(ngauss), $
;              center:fltarr(ngauss), $
;              errcenter:fltarr(ngauss)
;              width:fltarr(ngauss), $
;              errwidth:fltarr(ngauss), $
;            }
;
;   KEYWORDS
;
;           HELP    /help   Provide Syntax and other help
;           DEBUG  /debug  prints out contents of input fit structure
;-
; V7.0 1 july 2012 tmb 
;        27may2013 tmb !debug 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'getfit' & return & endif
; 
if KeyWord_Set(help) then begin & get_help,'getfit' & return & endif
if n_params() eq 0 then begin & 
              print,'ERROR! Must supply structure containing fit info'
              return & endif 
;
;  define the structure
;
nfit=!nfit & nrset=!nrset & ngauss=!ngauss
;
fit = { nfit:nfit, $
        nrset:nrset, $
        nregion:fltarr(2*nrset), $
        ngauss:ngauss, $
        bgauss:0L, $
        egauss:0L, $
        height:fltarr(ngauss), $
        errheight:fltarr(ngauss), $
        center:fltarr(ngauss), $
        errcenter:fltarr(ngauss), $
        width:fltarr(ngauss), $
        errwidth:fltarr(ngauss) $
        }
;
; calculate dVEL per channel
;
freq=!b[0].rest_freq & bw=!b[0].bw & nchan=n_elements(!b[0].data)
dnu=bw/nchan & dnu=dnu*1000.d
dvel=(dnu/freq)*!light_c & dvperchan=dvel/1000.d
;
; push current baseline and Gaussian fit !var values into 'fit' structure 
; 
fit.nfit=!nfit & fit.nrset=!nrset & fit.nregion=!nregion[0:2*nrset-1]
;
fit.ngauss=!ngauss & fit.bgauss=!bgauss & fit.egauss=!egauss
;
; this is tricky.  start by assuming x-axis is in CHANnels 
;
for i=0,!ngauss-1 do begin
    fit.height[i]=    !a_gauss[0+i*3]
    fit.errheight[i]= !g_sigma[0+i*3]
    fit.center[i]=    !a_gauss[1+i*3]
    fit.errcenter[i]= !g_sigma[1+i*3]
    fit.width[i]=     !a_gauss[2+i*3]
    fit.errwidth[i]=  !g_sigma[2+i*3]
endfor
;
flush:
if KeyWord_Set(debug) then print,fit
;
return
end
