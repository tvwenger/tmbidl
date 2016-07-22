;+
;  gaussModelNoise.pro    Model Gaussian function plus Gaussian noise
;  -------------------
;                         x      - dependent variable
;                         peak   - Gaussian peak
;                         center - Gaussian center
;                         width  - Gaussian width
;                         rms    - standard deviation of noise
;
;-
function gaussModelNoise, x, peak, center, width, rms
;

; generate the Gaussian curve
g = peak*exp(-4.0*alog(2.0)*( ((x - center)/width)*((x - center)/width) ))

; generate the noise
npoints=n_elements(x)
seed=-1L
noise = randomn(seed, npoints)*rms

; add the Gaussian and the noise
f = g + noise
;
return, f
end

