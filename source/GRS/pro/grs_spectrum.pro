pro GRS_spectrum,filename,l,b,lsize,bsize
;;
;;
;; GRS_spectrum.pro
;;
;; history - created September 7 2005 (JMR)
;;

if N_params() eq 0 then begin
    print,'GRS_spectrum.pro'
    print,'Creates either a single or an averaged spectrum from GRS 13CO (1-0) data cubes'
    print,'Created by JMR on 7 September 2005'
    print,'*******************************************************************'
    print,'SYNTAX:  GRS_spectrum,filename,longitude,latitude,'
    print,'optional     size in longitude, size in latitude'
    print,'             (if no sizes are given a single spectrum is produced)'
    print,'                             '
    print,' all inputs should be in degrees'
    print,' creates an output file called grs-spectrum.fits'
    print,'*******************************************************************'
    return
endif

; Flag to determine if we want a spectrum over a range, or just at
; the centre pixel (0 is range, 1 is centre pixel)
flag=0

; Read in the cube
    cube=readfits(filename,hdr)
    spectrum=fltarr(sxpar(hdr,'NAXIS3'))
    totalspectrum=fltarr(sxpar(hdr,'NAXIS3'))
    x=fltarr(sxpar(hdr,'NAXIS3'))

; change the input longitude and latitude into pixels
    lpix=round((l/(sxpar(hdr,'CDELT1'))+(sxpar(hdr,'CRPIX1'))))
    bpix=round((b/(sxpar(hdr,'CDELT2'))+(sxpar(hdr,'CRPIX2'))))

; For a single postion, set the variables to the longitude and latitude values
if N_params() eq 3 then begin
     lsizepix=1
     bsizepix=1
     lmin=lpix
     lmax=lpix
     bmin=bpix
     bmax=bpix
     flag=1
endif

; To create a spectrum over a range in longitude and latitude, determine the
; sizes, min and max of the area in pixels.
if flag eq 0 then begin
    lmin=round((l+(lsize/2))/(sxpar(hdr,'CDELT1'))+(sxpar(hdr,'CRPIX1')))
    lmax=round((l-(lsize/2))/(sxpar(hdr,'CDELT1'))+(sxpar(hdr,'CRPIX1')))
    bmin=round((b-(bsize/2))/(sxpar(hdr,'CDELT2'))+(sxpar(hdr,'CRPIX2')))
    bmax=round((b+(bsize/2))/(sxpar(hdr,'CDELT2'))+(sxpar(hdr,'CRPIX2')))
    lsizepix=lmax-lmin
    bsizepix=bmax-bmin
endif

tempcube=fltarr(lsizepix+1,bsizepix+1)

; Create the mean spectrum
for i=0,sxpar(hdr,'NAXIS3')-1 do begin

; Generate the x array of velocities
        x(i)=((i-sxpar(hdr,'CRPIX3'))*sxpar(hdr,'CDELT3')+sxpar(hdr,'CRVAL3'))/1000

; extract the (l,b) plane and check the values are finite
        newcube=cube(*,*,i)
        mask=finite(newcube)

; loop over the (l,b) pixels in the plane, write them to a temp cube
; if the pixel is finite
        for j=lmin,lmax,1 do begin 
            for k=bmin,bmax,1 do begin
                if mask(j,k) eq 1 then begin 
                    tempcube((j-lmin),(k-bmin))=newcube(j,k)
                endif
            endfor
       endfor
   spectrum(i)=mean(tempcube)   
endfor

!b[0].data=spectrum    

fileout=strcompress("grs-spectrum.fits",/remove_all)
writefits,fileout,spectrum,hdr,/CHECKSUM
;
return
end
