pro copy,bin,bout,help=help
;+
; NAME:
;       COPY
;
;            =============================================
;            Syntax: copy, buffer_in, buffer_out,help=help
;            =============================================
;
;   copy   Copy buffer !b[bin] into buffer !b[bout]
;   ----
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'copy' & return & endif
;
!b[bout] = !b[bin]
;
return
end
