pro  plus,n,m,help=help
;+
; NAME:
;       PLUS
;
;            ============================
;            Syntax: plus, n, m,help=help
;            ============================
;
;   plus   !b[0].data = !b[n].data + !b[m].data
;   ----   Adds buffer n to buffer m.
;          Default:   !b[0].data = !b[0].data + !b[1].data
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'plus' & return & endif
;
if n_params() eq 0 then begin & n=0 & m=1 & endif &
;
!b[0].data = !b[n].data + !b[m].data
;
return
end

