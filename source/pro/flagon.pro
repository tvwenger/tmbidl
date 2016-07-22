pro flagon,help=help
;+
; NAME:
;      FLAGON
;
;   flagon   Turn the !flag ON for various control functions.
;   ------   ========================
;            Syntax: flagon,help=help
;            ========================
;
; V5.0 JULY 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'flagon' & return & endif
;
!flag=1
;
return
end
