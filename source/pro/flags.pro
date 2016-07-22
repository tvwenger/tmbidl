pro flags,help=help
;+
; NAME:
;       FLAGS
;
;            =======================
;            Syntax: flags,help=help
;            =======================
;
;   flags  Uses !config state and !b[0].line_id string to determine ACS 
;   -----  spectral transition flag locations in channels and plots them
;
;-
; MODIFICATION HISTORY:
; V5.1 8 Jan 2008 by TMB
;      3 Apr 2008 by DSB: add C-band 7-alpha flags
;     17 Jul 2008 by TMB: add Arecibo 3He flags
;     23 Feb 2009 by DSB: change strmid to strtrim to accomodate
;                         the larger strings with C-band (e.g., H109).
; V6.0 June 2009 tmb/dsb stringtrim change 
;
; V6.1 05feb2011 tmb add new configuration for 3-He configuration tests
;
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'flags' & return & endif
;
if !line ne 1 and !chan ne 1 then begin
         print,"Cannot show flags !"
         print,"Must be spectral line data displayed in channels."
         return
endif
;
if !config eq -1 then begin
                 print
                 print,'Need to specify ACS configuration for correct flags!!!'
                 print
                 print,'!config = 0 for GBT 3-Helium flags'
                 print,'!config = 1 for GBT 7-alpha (X-band) flags'
                 print,'!config = 2 for GBT 7-alpha (C-band) flags'
                 print,'!config = 3 for ARECIBO 3-Helium flags'
                 print,'!config = 4 for GBT 3-Helium linehii4 (aka testm3)'
                 print
                 print,'===================================
                 print,'Use procedure:  setconfig, config_#'
                 print,'==================================='
                 return
                 endif
;
rxid=strtrim(string(!b[0].line_id),2)
acs_flags,rxid
;
return
end
