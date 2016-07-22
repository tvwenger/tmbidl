pro zlon,help=help
;+
; NAME:
;       ZLON
;
;            ======================
;            Syntax: zlon,help=help
;            ======================
;
;   zlon   Turn the zero line ON:    !zline=1
;   ----
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'zlon' & return & endif
;
!zline=1
;
return
end
