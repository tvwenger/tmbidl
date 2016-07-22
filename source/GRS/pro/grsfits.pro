;+
; NAME:
;       GRSFITS 
;
;            ================================================================
;            Syntax: GRSfits,vrrl,fitvals,help=help,noinfo=noinfo,nohdr=nohdr
;            ================================================================
;
;   grsfits   Returns an easy to use structure 'fitvals' 
;   -------   packed with the current Gaussian fit information 
;             For GRS Beamap spectra to be compared with HRDS Vrrl
;         
;           FITVALS  structure array containing current Gaussian fit 
;                    parameter values from !a_gauss and !g_sigma
;
;      fitvals = {ngauss:ngauss, $
;                 height:fltarr(ngauss), $
;                 errheight:fltarr(ngauss), $
;                 width:fltarr(ngauss), $
;                 errwidth:fltarr(ngauss), $
;                 center:fltarr(ngauss), $
;                 errcenter:fltarr(ngauss)}
;
;   KEYWORDS
;
;           HELP    /help   Provide Syntax and other help
;           NOINFO  /noinfo Suppress Gfit parameter output
;           NOHDR   /nohdr   Suppress Header 
;
; V6.1 Feb 2011 tmb based on LDA code for rehash.pro
;
;-
pro grsfits,vrrl,fitvals,help=help,noinfo=noinfo,nohdr=nohdr
;
on_error, 2           ; return to main level after error
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
; 
if KeyWord_Set(help) then begin
    print
    print,'=============================================================='
    print,'Syntax: gfits,vrrl,fitvals,help=help,noinfo=noinfo,nohdr=nohdr'
    print,'=============================================================='
    print
    print,'Returns FITVALS structure packed with the current Gaussian fit'
    print,'parameter values from !a_gauss and !g_sigma'
    print
    print,'    fitvals = {ngauss:ngauss, $'
    print,'               height:fltarr(ngauss), $'
    print,'               errheight:fltarr(ngauss), $'
    print,'               width:fltarr(ngauss), $'
    print,'               errwidth:fltarr(ngauss), $'
    print,'               center:fltarr(ngauss), $'
    print,'               errcenter:fltarr(ngauss)}'
    print
    print,'KEYWORDS: HELP    /help   Provide Syntax and other help'
    print,'          NOINFO  /noinfo Suppress Gfit parameter output'
    print,'          NOHDR   /nohdr   Suppress Header' 
    print
return
endif
;
; format for Gaussian fit parameters 
fmt='(f6.3,1x,f7.2,1x,f5.2,1x,f6.2,1x,f5.2,1x,f5.2,1x,f5.2)'
;
ngauss=!ngauss        ; number of Gaussian components currently fit
dv=fltarr(!ngauss)    ; Vhii - Vco array for the components
;
fitvals = {ngauss:ngauss, $
           height:fltarr(ngauss), $
           errheight:fltarr(ngauss), $
           width:fltarr(ngauss), $
           errwidth:fltarr(ngauss), $
           center:fltarr(ngauss), $
           errcenter:fltarr(ngauss)}
;
dv=fitvals.center
for i=0,ngauss-1 do begin
    fitvals.height[i] = !a_gauss[0+i*3]
    fitvals.errheight[i] = !g_sigma[0+i*3]
    fitvals.center[i] = !a_gauss[1+i*3]
    dv[i]=vrrl-fitvals.center[i]
    fitvals.errcenter[i] = !g_sigma[1+i*3]
    fitvals.width[i] = !a_gauss[2+i*3]
    fitvals.errwidth[i] = !g_sigma[2+i*3]
endfor
;
if ~Keyword_Set(noinfo) then for i=0,ngauss-1 do begin
    if ~Keyword_Set(nohdr) and i eq 0 then $
        print,'  D_V     Vco   SigV   Tco   SigT  FWHM  SigFWHM'
;
    print,dv[i],fitvals.center[i],fitvals.errcenter[i], $
          fitvals.height[i],fitvals.errheight[i], $
          fitvals.width[i], fitvals.errwidth[i],  $
    format=fmt
endfor
;
flush:
return
end
