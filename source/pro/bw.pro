pro bw,help=help
;+
; NAME:
;       BW
;
;   bw.pro   Toggles all plots (Xwin and PS) to black and white BW
;   ------   display mode. 'clr' toggles to color CLR.
;
;            Syntax: bw,help=help
;            --------------------
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'bw' & return & endif
;
!clr=0
;
return
end
