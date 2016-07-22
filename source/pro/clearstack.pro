pro clearstack,help=help
;+
; NAME
;     CLEARSTACK
;     clearstack,help=help
;
;  clearstack.pro   synonym for 'clrstk'
;  --------------
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'clearstack' & return & endif
;
clrstk
;
return
end
