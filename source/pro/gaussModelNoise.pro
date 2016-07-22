function gaussModelNoise, x, peak, center, width, rms, help=help
;+
;  gaussModelNoise.pro    Model Gaussian function plus Gaussian noise
;  -------------------    All units are in current x-axis units 
;
; ===================================================================
; SYNTAX: spectrum=gaussModelNoise(x,peak,center,width,rms,help=help)
; ===================================================================
;          x      - dependent variable
;          peak   - Gaussian peak
;          center - Gaussian center
;          width  - FWHM Gaussian width
;          rms    - standard deviation of noise
;
;   Keywords:   help   - gives this help 
;
;-
; MODIFICATION HISTORY
; ??? dsb created 
;
; v7.0 04jul2013 tmb - updated documentation original code is 
;                      correct despite tmb's initial thought
;-                     
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then get_help,'gaussmodelnoise' 
;
; generate the Gaussian curve
g = peak*exp(-4.0*alog(2.0)*( ((x - center)/width)*((x - center)/width) ))
;
; generate the noise
npoints=n_elements(x)
seed=-1L
noise = randomn(seed, npoints)*rms

; add the Gaussian and the noise
f = g + noise
;
return, f
end

