pro hdroff,help=help
;+
; NAME:
;       HDROFF
;
;            ========================
;            Syntax: hdroff,help=help
;            ========================
;
;   hdroff   Turn plotting the spectrum header OFF
;   ------   by setting !plthdr=0
;-
; V6.1 March 2010 toggle for turning the spectrum header
;                 plot OFF 
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'hdroff' & return & endif
;
!plthdr=0
;
return
end
