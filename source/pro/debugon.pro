pro debugon,help=help
;+
; NAME:
;      DEBUGON
;
;   debugon   Turn the !debug ON
;   -------  =========================
;            Syntax: DEBUGON,help=help
;            =========================
;
; V7.0 2may2013 tvw
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'debugon' & return & endif
;
!debug=1
;
return
end
