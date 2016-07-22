pro cgetns,n_save_num,tcj=tcj,pk=pk,foc=foc,dc=dc,kelvin=kelvin,help=help
;+
; NAME:
;       CGETNS
;
;            ===============================================
;            Syntax: cgetns,n_save_#,tcj=tcj,pk=pk,foc=foc,$
;            dc=dc,kelvin=kelvin,help=help
;            ===============================================
;
;   cgetns  Fetch a TCJ (or anything) stored the NSAVE location n_save_#
;   ------  Convert intensities to mK if necessary.  
;           Copy raw data to buffers 13, 14 & 15
;           Restore HISTORY information if any. 
;
;           If keyword /tcj then set x-axis for normal TCJ2s
; 
; MODIFICATION HISTORY:
; V5.1 TMB 25jun08
;      tmb 18jul08 enhanced viewability 
;      tmb 19aug08 added /dc keyword to force DC offset subtraction
;                  added /kelvin keyword to override conversion to mK
;                  /kelvin => kelvin=1 convert to Kelvin if necessary
;                             else convert to mK if necessary
; V7.0 3may2013 tvw - added /help, !debug
;-
;
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params(0) eq 0 or keyword_set(help) then begin & get_help,'cgetns' & return & endif
;
ns=n_save_num
getns,ns
;
; get intensity units that you want
;
yunits=strtrim(string(!b[0].yunits),2)
if not Keyword_Set(kelvin) then begin     ; convert to mK if necessary
           if yunits ne 'mK' then mk
endif else begin                          ; convert to K if necessary
           if yunits ne 'K' then unmk
endelse
; copy data
copy,0,15 & copy,0,14 & copy,0,13
; restore HISTORY
rehash,/params
; figure out the x-axis :  WOW!!!! StrPos is a *terrific$ .pro 
;                          TYVM Loren, I had not known of it.
;
IF StrPos(StrUpCase(String(!b[0].scan_type)), 'DEC') NE -1 THEN decx
IF StrPos(StrUpCase(String(!b[0].scan_type)), 'RA')  NE -1 THEN raxx
;
freexy
;
; x-axis to +/- 1000 arcsec
if Keyword_Set(tcj) then begin & curoff & setx,-1000,1000 & curon & endif
; DC subtract mean of data 
if Keyword_Set(dc) then begin & batchon & dcsub & batchoff & endif
;
return
end
