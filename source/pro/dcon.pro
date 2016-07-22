pro dcon,help=help
;+
; NAME:
;      DCON
;
;   dcon  Turn the DC subtraction ON when SHOWing TP spectra.
;   -----
;         Syntax: dcoff,help=help
;         =======================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'dcon' & return & endif
;
!dcsub=1
;
return
end
