pro nron,help=help
;+
; NAME:
;       NRON
;
;            ======================
;            Syntax: nron,help=help
;            ======================
;
;   nron   Turn flag ON for showing BMARK regions (NREGIONS)
;   ----
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'nron' & return & endif
;
!bmark=1
;
return
end
