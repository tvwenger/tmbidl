pro initgrs,help=help
;+
; NAME: INITGRS
;       
;
;            =========================
;            Syntax: initgrs,help=help
;            =========================
;
;   initgrs Initialize GRS analysis of HRDS nebulae
;   -------      
;                 
;
;   KEYWORDS: /help gives this help
;
;-
; MODIFICATION HISTORY:
;
;  Fri Mar 11 16:27:32 2011, Thomas Bania <bania@ninkasi.bu.edu>
;  V6.1  tmb date
;
;  V7.0 02jul2013 tmb - tweaked for full generalization 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  
;
if Keyword_Set(help) then begin & get_help,'initgrs' & return & endif 
;
fname='../../tables/HRDS_GRS_CO_FITS'
hrds=' '
read_table,fname,data=hrds,/global
;
src=strtrim(strmid(!data[0].source,0,13),2)
lgal=!data[0].lgal
bgal=!data[0].bgal
vrrl=!data[0].vrrl
;
print,src,lgal,bgal,vrrl
;
return
end
