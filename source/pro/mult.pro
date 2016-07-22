pro  mult,n,m,help=help
;+
; NAME:
;       MULT
;
;            ============================
;            Syntax: mult, n, m,help=help
;            ============================
;
;   mult   !b[0].data = !b[n].data * !b[m].data
;   ----   Multiply buffer n by buffer m
;
;          Default:   !b[0].data = !b[1].data * !b[0].data
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'mult' & return & endif
;
if n_params() eq 0 then begin & n=1 & m=0 & endif &
;
!b[0].data = !b[n].data * !b[m].data
;
return
end

