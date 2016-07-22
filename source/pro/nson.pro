pro nson,help=help
;+
; NAME:
;       NSON
;
;            ======================
;            Syntax: nson,help=help
;            ======================
;
;   nson   Set NSAVE write protection flag ON.
;   ----
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'nson' & return & endif
;
!protectns=1
;
if not !batch then begin
   print
   print,'NSAVE write protection turned ON'
   print
endif
;
return
end
