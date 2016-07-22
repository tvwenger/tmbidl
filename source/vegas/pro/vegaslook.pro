pro vegasLook,rec_no,help=help
;+
; NAME:
;       VEGASLOOK
;
;            ==========================================
;            Syntax: VEGASLOOK, Record_number,help=help 
;            ==========================================
;
;   vegaslook  looks at VEGAS TP PS data in record space
;   ---------  assumes all fitting inputs are set
;              e.g. for W3 H91alpha             
;              setx,2000,6000  !nfit=5 
;              nrset=3,[2000,2550,3140,3740,4445,6000]
;
; KEYWORDS     help  - if set gives this help
;-
; MODIFICATION HISTORY:
; V8.0 tmb 01jul2015 based on jul2014 code 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'vegaslook' & return & endif
;
fetch,rec_no 
mk
dcsub
flagoff & smo,3 & flagon
scaley 
nrset,3,[2000,2550,3140,3740,4445,6000]
bbb,5,/no
zline
!ngauss=1 & !bgauss=3675 & !egauss=4570 
g
;
return
end
