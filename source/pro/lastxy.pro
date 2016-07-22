pro lastxy,help=help
;+
; NAME:
;       LASTXY
;
;            ========================
;            Syntax: lastxy,help=help
;            ========================
;
;   lastxy   Restore x and y-axis ranges to previous values.
;   ------
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'lastxy' & return & endif
;
!x.range=!last_x
!y.range=!last_y
;
return
end
