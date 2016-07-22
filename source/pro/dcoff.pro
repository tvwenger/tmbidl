pro dcoff,help=help
;+
; NAME:
;      DCOFF
;
;   dcoff  Turn the DC subtraction OFF when SHOWing TP spectra.
;   -----
;          Syntax: dcoff,help=help
;          =======================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'dcoff' & return & endif
;
!dcsub=0
;
return
end
