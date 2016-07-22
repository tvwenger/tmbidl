;+
; NAME:
;       SMOV
;
;            ======================================
;            Syntax: smov, velocity=fwhm_of_smooth
;            ======================================
;
;   smov  Smooth with gaussian weighting with fwhm= in velocity.
;   ----  If argument is omitted, defaults to system variable !sm_vel
;         Works with any x-axis definition.
;
;        FLAGON/FLAGOFF toggle RESHOW and information on smoothing
;
; From V5.0 July 2007
; RTR  8/08
;-
pro smov,vsm
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 then vsm=!sm_vel
;
!line_sm_vel=vsm
nsm=round(vsm*!nchan*(!b[0].sky_freq/!b[0].bw)/!light_c)
smo,nsm
;
return
end