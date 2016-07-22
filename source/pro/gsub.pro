pro gsub,newsrc=newsrc,lastns=lastns,save=save,cpgcomp=cpgcomp,help=help
;+
; NAME:
;       GSUB
;
;       ====================================================
;       Syntax: gsub,newsrc=newsrc,lastns=lastns,save=save,$
;                    cpgcomp=cpgcomp,help=help
;       ====================================================
;
;   gsub  Subtract model gaussian(s) in !b[1] from spectrum 
;   ----  in !b[0].  Returns new source name in keyword newsrc.
;         
;  KEYWORDS: help    - if set gives this help
;            cpgcomp - if set copies gaussian model fits 
;                      into !b[1] for subtraction 
;            newsrc  - new source name 'OriginalName"+"_gsub"
;            lastns  - if passed replaces  existing !lastns
;            save    - if set saves the subtracted spectrum
;                      in !lastns+1 nsave 
;
;-
; MODIFICATION HISTORY:
; V6.1 13feb1010 TMB 
; V7.0 3may2013 tvw - added /help, !debug
;      23may2013 tvw - changed calling of cpgcomp to keyword
;      24may2013 tmb - updated to v7.0 style 
;                      revised the documentation
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'gsub' & return & endif
;
if keyword_set(cpgcomp) then cpgcomp
;
copy,0,9    ; save original spectrum in 9
minus,0,1   ; subtract moded Gaussian(s)
;
src=string(!b[0].source) & src=strtrim(src,2)
newsrc=src+'_gsub'
tagsrc,newsrc
sx
;
if Keyword_Set(lastns) then !lastns=lastns
if Keyword_Set(save) then begin 
   ns=!lastns+1 & putns,ns & !lastns=ns
endif
;
return
end
