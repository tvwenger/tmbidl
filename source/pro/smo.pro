pro smo,n,help=help
;+
; NAME:
;       SMO
;
;            ================================================
;            Syntax: smo, #_channels=fwhm_of_smooth,help=help
;            ================================================
;
;   smo  Smooth with gaussian weighting with fwhm=n in channels.
;   ---  Works with any x-axis definition.
;
;        FLAGON/FLAGOFF toggle RESHOW and information on smoothing
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'smo' & return & endif
;
if n_params() eq 0 then n=!smgwt[0]
;
if !flag then begin
              fwhm=(!b[0].bw/!b[0].sky_freq)*(!light_c/!nchan)*n ; fwhm velocity width
              print,'Smoothing with '+fstring(fwhm,'(f5.2)')+' km/sec FWHM gaussian'
              endif
;
if n_params() eq 1 then begin
                    nch=n                                
                    sig=n/2.354 
                    smgwt=fltarr(!max_no_smooth_chans)
;
                    c1=1./(sqrt(2.*!dpi)*sig)
                    c2=-1./(2.*sig*sig)
;
                    !smgwt[0:!max_no_smooth_chans-1]=0.0
                    for i=0,2*nch do begin
                                  smgwt[i]=c1*exp(c2*(i)^2)
;                                 print,'wgt ',i,smgwt(i)
                    endfor
;                   print,(2*total(smgwt[1:(3*nch-1)]))+smgwt[0]
                    !smgwt[0]=2*nch+1
                    kount=1
                    for i=0,2*nch do begin
                                  !smgwt[kount]=smgwt[i]
                                  kount=kount+1
                    endfor
;
endif
;

smch=fix(!smgwt[0])
wt=fltarr(2*smch-1)
for i=0,smch-1 do begin
               wt[i]=!smgwt[smch-i]
               wt[2*smch-2-i]=!smgwt[smch-i]
               endfor
idx=fix(smch/2)
xx=fltarr(!nchan)
;
for i=smch,!nchan-smch do begin
    sum=0.0d0
    for j=0,2*smch-2 do begin
        sum=!b[0].data[i-smch+j]*wt[j]+sum
    endfor
    xx[i]=sum
endfor
;
!b[0].data=xx
;
if !flag then reshow
;
return
end
