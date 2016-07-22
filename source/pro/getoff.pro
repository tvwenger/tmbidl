pro getoff,rec,help=help
;+
; NAME:
;       GETOFF
;
;            =======================================
;            Syntax: getoff, rec_#,help=help
;            =======================================
;
;   getoff   Copy rec_# into buffer !b[0] and !b[6]
;   ------   This is assumed to be an OFF scan in TP mode.
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'getoff' & return & endif
;
get,rec
copy,0,6             ; copy OFFinto buffer 6
!tsys = !b[0].tsys 
!time = !b[0].tintg
;
return
end
