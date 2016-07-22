pro fs,help=help
;+
; NAME:
;       FS
;
;   fs   Toggle !tp OFF to select frequency switched data.
;   --
;            ====================
;            Syntax: fs,help=help
;            ====================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'fs' & return & endif
;
!tp=0
;
return
end
