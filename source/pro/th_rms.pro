pro th_rms,tsys,df,npol,k1,k2,xmin,xmax,no_pts,time_x,rms_y,help=help
;+
; NAME:
;       TH_RMS
;
;            =========================================================================
;            Syntax: th_rms,tsys,df,npol,k1,k2,xmin,xmax,no_pts,time_x,rms_y,help=help
;            =========================================================================
;
; th_rms   Calculate theoretical rms expected from current configuration
; ------   of the GBT ACS spectrometer.  Pass arrays to RADIOM for
;        comparison with empirical radiometer equation.
;
; Theoretical radiometer equation: ;
;
; rms := k1*tsys/sqrt(k2*teff*npol*df);
;
; where
;
;  tsys  - system temperature                in milliKelvins
;  k1    - backend sampling efficiency
;           k1 = 1.032 for 9-level
;           k1 = 1.235 for 3-level
;  k2    - autocorrelator channel weighting function         
;           k2 = 1.21 for Uniform
;           k2 = 2.00 for Hanning
;  teff  - ton*toff/(ton + toff)  in seconds
;  npol  - number of polarizations (or independent signals)
;  df    - frequency resolution in Hz 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'th_rms' & return & endif
;
case k1 of 
          9: k1=1.032d   ; 9-level
          3: ki=1.235d   ; 3-level
       else: begin
             print,'Error: Correlator sampling not specified'
             return
             end
endcase
;
case k2 of
           1: k2=1.21d   ; uniform weighting
           2: k2=2.00    ; Hanning weighting
        else: begin
              print,'Error: Correlator weighting not specified'
              return
              end
endcase
;
; teff = 0.5*t_scan for equal times ON/OFF
; tintg= 2.0*t_scan
; 
; ==>   teff = 0.25*tintg
;
xmin=xmin*60.                     ; time in seconds
xmax=xmax*60. 
dt=(xmax-xmin)/no_pts
for i=0,no_pts-1 do begin
      time_x[i]=xmin+float(i)*dt
      teff=0.25*time_x[i]
      rms_y[i] = k1*tsys/sqrt(k2*teff*npol*df)
endfor
;
time_x=time_x/60.                 ; return time in minutes
;
return
end
