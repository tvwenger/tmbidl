pro nroff,help=help
;+
; NAME:
;       NROFF
;
;            =======================
;            Syntax: nroff,help=help
;            =======================
;
;   nroff   Turn flag OFF for showing BMARK regions (NREGIONS).
;   ----
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'nroff' & return & endif
;
!bmark=0
;
return
end
