pro debugoff,help=help
;+
; NAME:
;      DEBUGOFF
;
;   debugoff   Turn the !debug OFF
;   -------- ==========================
;            Syntax: DEBUGOFF,help=help
;            ==========================
;
; V7.0 2may2013 tvw
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'debugoff' & return & endif
;
!debug=0
;
return
end
