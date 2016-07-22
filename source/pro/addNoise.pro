pro addNoise,data,rms,model,help=help
;+
;  ADDNOISE  Adds rms noise to input data array. 
;  --------  
;
;           =========================================
;           SYNTAX: addNoise,data,rms,model,help=help
;           =========================================
;                   INPUTS:
;                   data   - array of data values
;                   rms    - standard deviation of noise to add
;                            specified in current y-axis units 
;                   OUTPUT:
;                   model  - input data array plus rms noise 
;
;           Keywords:   /help - gives this help
;
;-
; MODIFICATION HISTORY
;
; v7.0 05jul2013 tmb - needed for multiple gaussian models created
;                      by invoking modelGauss.pro multiple times 
;-                     
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'addNoise' & return & endif 
if n_params() lt 2 then begin & print,'ERROR! Must input rms value to add' & return & endif
;  generate the noise 
npoints=n_elements(data)
seed=-1L
noise = randomn(seed, npoints)*rms
;
model=data+noise ; add the noise to the data 
;
return
end

