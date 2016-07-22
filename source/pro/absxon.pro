pro absxon,help=help
;+
; NAME:
;       ABSXON
;
;            ========================
;            Syntax: absxon,help=help
;            ========================
;
;   absxon   Set x-axis continuum display to RELATIVE co-ordinates
;   ------   (i.e. subtract the center position from the positions)
;
; V5.0 October 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'abson' & return & endif
;
!relative=1
;
if not !batch then begin
   print
   print,'X-axis positions are now relative to center position'
   print
endif
;
return
end
