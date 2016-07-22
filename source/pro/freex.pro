pro freex,pad,help=help
;+
; NAME:
;      FREEX
;
;  freex   Reset x-axis to autoscaling.
;  -----
;          ===========================
;          Syntax: FREEX,pad,help=help
;          ===========================
;
;          pad is number of channels to ignore for x-axis range
;          continuum issue only. pad=3 by default
;
; 5.0 July 2007   N.B. GRS mode may require (TMB forgets)
;                      !x.range=[0.,!data_points-1] ????
; v5.0 March 2008 tmb hacks to deal with differing number
;                 of continuum data points.
; 
; v6.1 3sept09 tmb trying to deal with graphics and window management
; V7.0 3may2013 tvw - added /help, !debug
;
;-
if keyword_set(help) then begin & get_help,'freex' & return & endif
;
@CT_IN
;
!x.range=[0.,0.]
;!x.range=[0.,!data_points-1]
;
if !line ne 1 then begin
   if n_params() eq 0 then pad=3  ; pad to mask potentially bad positions
   min=!xx[0+pad] & max=!xx[!c_pts-1-pad]
   !x.range=[min,max]
endif
;
@CT_OUT
;
return
end

