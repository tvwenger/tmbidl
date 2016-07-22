pro GRS_plotspectrum, filename
;;
;;
;; GRS_plotspectrum.pro
;;
;; history - created September 7 2005 (JMR, ETC)
;;

if N_params() eq 0 then begin
    print,'GRS_plotspectrum.pro'
    print,'Plots a GRS spectrum '
    print,'Created by JMR and ETC on 7 September 2005'
    print,'*****************************************************'
    print,'SYNTAX:  GRS_plotspectrum,filename'
    print, '       '
    print,'*****************************************************'
    return
endif


print,'Plotting file= ',filename
; Read in the spectrum
spectrum=readfits(filename,hdr)

; Determine the min and max for display
ymin=min(spectrum)-0.05
ymax=max(spectrum)+0.05

; create the array of velocities
x=fltarr(sxpar(hdr,'NAXIS1'))
for i=0,sxpar(hdr,'NAXIS1')-1 do begin
    x(i)=((i-sxpar(hdr,'CRPIX3'))*sxpar(hdr,'CDELT3')+sxpar(hdr,'CRVAL3'))/1000
endfor
    
; plot.
plot,x,spectrum,xrange=[-5,135],xstyle=1,yrange=[ymin,ymax],ystyle=1, $
xtitle="Velocity (km/s)", ytitle="T!DA!N!U*!N (K)"

end
