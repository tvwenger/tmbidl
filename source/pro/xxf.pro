pro xxf,help=help
;+
; NAME:
;       XXF
;
;            ====================
;            Syntax: xxf,help=help
;            ====================
;
;  xxf    Renaming of SHOW procedure plus displaying line flags
;  --
;               
;-
; V5.1 July 2008
; V6.0 June 2009
;      tmb/dsb fixed for elegance
; V7.0 03may2013 tvw - added /help, !debug
;-
;
if keyword_set(help) then begin & get_help,'xxf' & return & endif
erase
show
flags
;
return
end
