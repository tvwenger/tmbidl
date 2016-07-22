pro curon,help=help
;+
; NAME:
;      CURON
;
;   curon,help=help   Turn the cursor ON for various input
;   -----
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'curon' & return & endif
;
!cursor=1
;
return
end
