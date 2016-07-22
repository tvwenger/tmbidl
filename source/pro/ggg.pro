pro ggg,help=help
;+
; NAME:
;       GGG
;
;            =======================================
;            Syntax: ggg,help=help
;            =======================================
;  ggg    'G' procedure with explicit i/o i.e. forces !flag on
;  ---    MUST have baseline removed.  Needs initial guesses for the fit.
;         Returns the fits no matter what state !flag is in.
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'ggg' & return & endif
;
flag=!flag
flagon
;
g
;
!flag=flag
;
return
end
