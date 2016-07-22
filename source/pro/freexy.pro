pro freexy,help=help
;+
; NAME:
;      FREEXY
;
;  freex   Reset x + y-axis to autoscaling.
;  -----
;          ========================
;          Syntax: FREEXY,help=help
;          ========================
;
; 5.0 July 2007   N.B. GRS mode may require (TMB forgets)
;                      !x.range=[0.,!data_points-1] ????
;
; v6.1 Sept 2009 tmb dealing with widows and graphics management
; V7.0 3may2013 tvw - added /help, !debug
;
;-
if keyword_set(help) then begin & get_help,'freexy' & return & endif
;
@CT_IN
;
!x.range=[0.,0.]
!y.range=[0.,0.]
;
@CT_OUT
;
return
end

