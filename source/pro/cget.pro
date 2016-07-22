pro cget,recno,tcj=tcj,pk=pk,foc=foc,dc=dc,help=help
;+
; NAME:
;       CGET
;
;            ===========================================================
;            Syntax: cget,record_#,tcj=tcj,pk=pk,foc=foc,dc=dc,help=help
;            ===========================================================
;
;   cget  Fetch a continuum record from the OFFLINE (or ONLINE) data file.
;   ----  Copy raw data to buffers 13, 14, & 15
;         Set keyword /tcj to fix x-axis for normal TCJ2s;         
; 
; MODIFICATION HISTORY:
; V5.1 tmb 18jul08 
;      tmb 19aug08 added /dc keyword to force DC subtraction
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params(0) eq 0 or keyword_set(help) then begin & get_help,'cget' & return & endif
;
get,recno 
;
; copy data
copy,0,15 & copy,0,14 & copy,0,13
; figure out the x-axis :  WOW!!!! StrPos is a *terrific$ .pro 
;                          TYVM Loren, I had not known of it.
;
IF StrPos(StrUpCase(String(!b[0].scan_type)), 'DEC') NE -1 THEN decx
IF StrPos(StrUpCase(String(!b[0].scan_type)), 'RA')  NE -1 THEN raxx
;
freexy
;
; x-axis to +/- 1000 arcsec
if Keyword_Set(tcj) then begin &curoff & setx,-1000,1000 & curon & endif
; DC subtract mean of data 
if Keyword_Set(dc) then begin & batchon & dcsub & batchoff & endif
;
return
end
