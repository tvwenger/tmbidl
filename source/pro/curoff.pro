pro curoff,help=help
;+
; NAME:
;      CUROFF
;
;   curoff,help=help   Turn the cursor OFF for various input.
;   ------
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'curoff' & return & endif
;
!cursor=-1
;
return
end
