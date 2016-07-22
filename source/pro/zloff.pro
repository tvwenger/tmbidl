pro zloff,help=help
;+
; NAME:
;       ZLOFF
;
;            =======================
;            Syntax: zloff,help=help
;            =======================
;
;   zloff   Turn the zero line OFF:  !zline=0
;   -----
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'zloff' & return & endif
;
!zline=0
;
return
end
