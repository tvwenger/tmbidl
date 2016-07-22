pro flagoff,help=help
;+
; NAME:
;      FLAGOFF
;
;   flagoff   Turn the !flag OFF for various control functions.
;   -------   =========================
;             Syntax: flagoff,help=help
;             =========================
;
; V5.0 JULY 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'flagoff' & return & endif
;
!flag=0
;
return
end
