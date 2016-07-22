pro gfits,fitvals,help=help,noinfo=noinfo,nohdr=nohdr,fmt=fmt
;+
; NAME:
;       GFITS 
;
;    =================================================================
;    Syntax: gfits,fitvals,help=help,noinfo=noinfo,nohdr=nohdr,fmt=fmt
;    =================================================================
;
;   gfits   Returns an easy to use structure 'fitvals' 
;   -----   packed with the current Gaussian fit information 
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
;           NOHDR   /nohdr  Suppress Header 
;           FMT    fmt='()' Override default output format:
;                  fmt='(f7.2,1x,f5.2,1x,f6.2,1x,f5.2,1x,f6.2,1x,f5.2)'
;-
; V6.1 Feb 2011 tmb based on LDA code for rehash.pro
;      4feb2011 tmb added override for output format
; V7.0 3may2013 tvw - added /help, !debug
; v8.0 19jun2015 tmb - fixed FWHM format bug VEGAS channel range is
;                      very big!
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
; 
if keyword_set(help) then begin & get_help,'gfits' & return & endif
;
if ~KeyWord_Set(fmt) then $
;   default format for Gaussian fit parameters 
    fmt='(f7.2,1x,f5.2,1x,f6.2,1x,f5.2,1x,f6.2,1x,f5.2)'
;
ngauss=!ngauss        ; number of Gaussian components currently fit
;
fitvals = {ngauss:ngauss, $
           height:fltarr(ngauss), $
           errheight:fltarr(ngauss), $
           width:fltarr(ngauss), $
           errwidth:fltarr(ngauss), $
           center:fltarr(ngauss), $
           errcenter:fltarr(ngauss)}
;
for i=0,ngauss-1 do begin
    fitvals.height[i] = !a_gauss[0+i*3]
    fitvals.errheight[i] = !g_sigma[0+i*3]
    fitvals.center[i] = !a_gauss[1+i*3]
    fitvals.errcenter[i] = !g_sigma[1+i*3]
    fitvals.width[i] = !a_gauss[2+i*3]
    fitvals.errwidth[i] = !g_sigma[2+i*3]
endfor
;
if ~Keyword_Set(noinfo) then for i=0,ngauss-1 do begin
    if ~Keyword_Set(nohdr) and i eq 0 then $
        print,' Center  SigC  Height SigH  FWHM  SigFWHM'
;
    print,fitvals.center[i],fitvals.errcenter[i], $
          fitvals.height[i],fitvals.errheight[i], $
          fitvals.width[i], fitvals.errwidth[i],  $
    format=fmt
endfor
;
flush:
return
end
