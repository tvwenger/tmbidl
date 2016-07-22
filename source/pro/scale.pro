pro  scale,fact,help=help
;+
; NAME:
;       SCALE
;
;            =====================================
;            Syntax: scale, scale_factor,help=help
;            =====================================
;
;   scale   Scale !b[0].data by 'scale_factor'.
;   -----   If no input, uses existing !fact to scale.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'scale' & return & endif
;
if n_params() eq 0 then fact=!fact      ;  default is current value of !fact
;
!fact=fact
;
!b[0].data=!fact*!b[0].data
;
return
end

