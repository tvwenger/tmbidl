pro clr,help=help
;+
; NAME:
;       CLR
;
;   clr.pro   Toggle all plots (Xwin and PS) to color CLR 
;   -------   display mode. 'bw' toggles to B/W for plots.
;
;             Syntax: clr,help=help
;             ---------------------
;
; V5.0 July 2007 
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'clr' & return & endif
;
!clr=1
;
return
end
