pro hdron,short=short,help=help
;+
; NAME:
;       HDRON
;
;       ===================================
;       SYNTAX: hdron,short=short,help=help
;       ===================================
;
;   hdron   Turn plotting the spectrum header ON 
;   -----   !plthdr=1
;
;   KEYWORDS:  help  - gives this help
;              short - give only short one line header
;-
; V6.1 March 2010 toggle for turning the spectrum header
;                 plot ON 
; V7.0 30may2013 tvw - added /help, !debug
;      26may2013 tmb - added debug and /short keyword
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'hdron' & return & endif
;
!plthdr=1
if keyword_set(short) then !plthdr=2
;
return
end
