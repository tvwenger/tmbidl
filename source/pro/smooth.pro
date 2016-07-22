pro smooth,help=help
;+
; NAME:
;       SMOOTH
;
;            ========================
;            Syntax: smooth,help=help
;            ========================
;
;   smooth   5-channel smooth with gaussian weighting.
;   ------
;            Wses !smgwt array  !smgwt[0] = number of channels in smgwt.
;            Channels within this range at either end of spectrum are left intact
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'smooth' & return & endif
;
!smgwt[0:!max_no_smooth_chans-1]=0.0
!smgwt[0:11]=[11.,0.187822,0.168118,0.120565,0.0692732,0.0318894,0.0117616, $
                 0.347553e-02,0.822839e-03,0.156080e-03,2.37200e-05,2.88816e-06]

;
if !flag then begin
              fwhm=(!b[0].bw/!b[0].sky_freq)*(!light_c/!nchan)*5  ; fwhm velocity width
              print,'Smoothing with '+fstring(fwhm,'(f5.2)')+' km/sec FWHM gaussian'
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
