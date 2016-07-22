;+
;NAME:
;
;   cshift.pro   calculate channel shift needed to align spectra 
;   ----------   taken at incorrect source velocity 
;                        
;                Syntax: cshift,vel,ichan
;                ------------------------
;
;                vel -> correct source velocity in km/sec
;                ichan -> number of channels to shift to correct 
;   
;  T.M. Bania June 2000
;-
pro cshift,vel,ichan
;
on_error,!debug ? 0 : 2
;
frest=!b[0].rest_freq      ; in Hz
fsky =!b[0].sky_freq       ; in Hz
vel_used=!b[0].vel/1.0e+3  ; in km/s
dv=vel_used-vel            ; delta velocity for correction
df=-fsky*(dv/!light_c)    ; in Hz
ichan=df/!b[0].delta_x     ; in channels 
;
;
out:          
return
end
