pro  div,n,m,help=help
;+
; NAME:
;      DIV
;
;   div   !b[0].data = !b[n].data / !b[m].data
;   ---   Divide buffer n by buffer m
;         Default:   !b[0].data = !b[1].data / !b[0].data
;
;         ===============================================================
;         Syntax: div, numerator_buffer_#, denominator_buffer_#,help=help
;         ===============================================================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'div' & return & endif
;
if n_params() eq 0 then begin & n=1 & m=0 & endif &
;
!b[0].data = !b[n].data / !b[m].data
;
return
end

