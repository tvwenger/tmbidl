pro lasty,help=help
;+
; NAME:
;       LASTY
;
;            =======================
;            Syntax: lasty,help=help
;            =======================
;
;   lasty   Restore y-axis range to value set at last SETY.
;   -----
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'lasty' & return & endif
;
!y.range=!last_y
;
return
end
