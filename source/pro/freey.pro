pro freey,help=help
;+
; NAME:
;      FREEY
;
;  freey   Reset y-axis to autoscaling.
;  -----
;          =======================
;          Syntax: FREEY,help=help
;          =======================
;
; 5.0 July 2007  
;
; V6.1 2 sept 09 tmb trying to deal with graphics and window
; management
; V7.0 3may2013 tvw - added /help, !debug
;
;-
if keyword_set(help) then begin & get_help,'freey' & return & endif
;
@CT_IN
;
!y.range=[0.,0.]
;
@CT_OUT
;
return
end

