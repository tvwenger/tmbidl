pro sky_align,ns1,ns2,show=show,help=help
;+
; NAME:
;       SKY_ALIGN
;
;  =============================================
;  SYNTAX: sky_align,ns1,ns2,show=show,help=help
;  =============================================
;
;  sky_align  align two NSAVE spectra by matching 
;  ---------  sky frequency in header 
;             Default is Batch Mode
;
;  PARAMETERS: ns1 - first NSAVE 
;              ns2 - second NSAVE
;
;  KEYWORDS:  help -  gives this help
;             show -  show all the spectra
;                     before and after shifting
;
;-
; MODIFICATION HISTORY
; aug 2010 rtr
; V7.0 tmb integration
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if n_params() ne 2 or keyword_set(help) then begin 
   get_help,'sky_align' & return & endif
;
@CT_IN  ; color table handling
;
copy,0,10
; the first NSAVE
getns,ns1
f1=!b[0].sky_freq/1.0D6
copy,0,11
if keyword_set(show) then begin
   dcsub & xxf & pause & endif
; the second NSAVE
getns,ns2
f2=!b[0].sky_freq/1.0D6
copy,0,12
if keyword_set(show) then begin 
   dcsub & reshow & pause & endif
copy,12,0
; the frequency aligned spectrum 
df=f2-f1
shift_spec,df
if keyword_set(show) then begin 
    dcsub & reshow,color=!yellow & endif
;
@CT_OUT ; restore color table 
;
return
end

