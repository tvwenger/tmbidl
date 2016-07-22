pro tp,help=help
;+
; NAME:
;       TP
;
;            ====================
;            Syntax: tp,help=help
;            ====================
;
;   tp   Toggle !tp on to select total power mode.
;   --
;-
;  V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'tp' & return & endif
;
!tp=1
;
return
end
