pro srcvlon,help=help
;+
; NAME:
;       SRCVLON
;
;            =========================
;            Syntax: srcvlon,help=help
;            =========================
;
;;   srcvlon   Turn the source velocity flag line ON.
;   --------
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'srcvlon' & return & endif
;
!srcvl=1
;
return
end
