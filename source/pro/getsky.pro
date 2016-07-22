PRO getsky,ha,za,az,el,help=help
;+
; NAME:
;       GETSKY
;
;            ====================================
;            Syntax: getsky,HA,ZA,AZ,EL,help=help
;            ====================================
;
;   getsky  Returns the HA (hr), ZA (deg), AZ (deg), and EL (deg)
;   ------  of currently plotted data record from !b[0] 
;-
; MODIFICATION HISTORY:
; V5.1 TMB 24jul08 
; V7.0 3may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'getsky' & return & endif
;
ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ; yes, they send lst in seconds and ra in degrees
ha = (ha gt +12.) ? (ha-24.) : ha      ; note use of the Ternary operator...!
ha = (ha lt -12.) ? (ha+24.) : ha      ; note use of the Ternary operator...!
za=90.0-!b[0].el
az=!b[0].az
el=!b[0].el
;
return
end
 
