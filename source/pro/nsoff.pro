pro nsoff,help=help
;+
; NAME:
;       NSOFF
;
;            =======================
;            Syntax: nsoff,help=help
;            =======================
;
;   nsoff   Set NSAVE write protection flag OFF.
;   ----
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'nsoff' & return & endif
;
!protectns=0
;
if not !batch then begin
   print
   print,'NSAVE file overwrite protection is OFF'
   print
endif
;
return
end
