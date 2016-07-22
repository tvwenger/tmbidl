pro geton,rec,help=help
;+
; NAME:
;       GETON
;
;            ==============================
;            Syntax: geton, rec_#,help=help
;            ==============================
;
;   geton   Copy rec# into buffer !b[0] and !b[5]
;   -----   This is an ON record in TP mode.
;-
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'geton' & return & endif
;
get,rec
copy,0,5              ; copy ON into buffer 5
!tsys = !b[0].tsys 
!time = !b[0].tintg
;
return
end
