pro absxoff,help=help
;+
; NAME:
;       ABSXOFF
;
;            =========================
;            Syntax: absxoff,help=help
;            =========================
;
;   absxoff   Set x-axis continuum display to ABSOLUTE co-ordinates
;   -------   (i.e. do NOT subtract the center position from the positions)
;
; V5.0 October 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'absxoff' & return & endif
;
!relative=0
;
if not !batch then begin
   print
   print,'X-axis positions are now the absolute positions'
   print
endif
;
return
end
