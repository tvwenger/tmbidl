pro modelGauss,x,peak,center,width,model,rms=rms,help=help
;+
;  MODELGAUSS  Model Gaussian function for input parameters
;  ----------  specified in current x-axis units. 
;
;   ==============================================================
;   SYNTAX: modelGauss,x,peak,center,width,model,rms=rms,help=help
;   ==============================================================
;          INPUTS:
;          x      - dependent variable array
;          peak   - Gaussian peak
;          center - Gaussian center
;          width  - FWHM Gaussian width
;          rms    - standard deviation of noise
;
;          OUTPUT:
;          model  - Gaussian model array
;
;   Keywords:   /help - gives this help
;               rms   - adds noise to the model at input
;                       rms (1 sigma) level specified in
;                       current y-axis units
;
;-
; MODIFICATION HISTORY
;
; v7.0 05jul2013 tmb - based on dsb function 
;
;-                     
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'modelGauss' & return & endif 
;
; generate the Gaussian curve
g = peak*exp(-4.0*alog(2.0)*( ((x - center)/width)*((x - center)/width) ))
;
if Keyword_Set(rms) then begin ; generate the noise 
   npoints=n_elements(x)
   seed=-1L
   noise = randomn(seed, npoints)*rms
   g=g+noise ; add the Gaussian and the noise
endif
;
model=g
;
return
end

