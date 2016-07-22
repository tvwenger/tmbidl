pro cflag,help=help
;+
; NAME:
;       CFLAG
;
;            =============================
;            Syntax: cflag,help=help
;            =============================
;
;   cflag  flag center channel based on !b[0].c_pts
;   -----
; MODIFICATION HISTORY:
; V5.1 TMB 
;
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cflag' & return & endif
;
center=!b[0].c_pts-1
center=center/2
flag,center
;
return
end
