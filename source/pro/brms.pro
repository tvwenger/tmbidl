pro brms,dsig,help=help
;+
; NAME:
;       BRMS
;
;       ===========================
;       SYNTAX: brms,dsig,help=help
;       ===========================
;
;   brms  Calculate the rms in the NREGIONs stored 
;   ----  in history of !astack[0] record
;
;   ===> HRDS 7-alpha data assumed  
;
;   OUTPUTS: dsig - rms in NREGIONs (current y-axis units)
;
;   KEYWORDS: help  -  gets this help 
;
;-
; MODIFICATION HISTORY:
; V6.1 TMB 22july2010
;
; v7.0 tmb 27may2013 !debug help 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'brms' & return & endif
;
clrstk
select
get,!astack[0]
hdr
rehash,/reset
sx
;
history=!b[0].history & deja_vu=string(history[0:2])
if deja_vu eq '' then begin
   comment="NO HISTORY for this spectrum: "
   scanid=fstring(!b[0].scan_num,'(i9)')
   print & print,comment+scanid & print
   return
endif
;
mask,dsig
label='RMS = '
print
print,label,dsig,format='(a,1x,f5.3)'
;
return
end
