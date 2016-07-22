pro lastx,help=help
;+
; NAME:
;       LASTX
;
;            =======================
;            Syntax: lastx,help=help
;            =======================
;
;   lastx   Restore x-axis range to value set at last SETX.
;   -----
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'lastx' & return & endif
;
!x.range=!last_x
;
return
end
