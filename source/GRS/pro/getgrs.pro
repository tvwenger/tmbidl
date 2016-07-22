;
pro getGRS,l_gal,b_gal,found,offset,lpix,bpix
;+
; NAME:
;       getGRS
;
; PURPOSE: Fetch an input (l,b) galactic position from the GRS
;          database and put it in GRSIDL format
;
; CALLING SEQUENCE:
;       getGRS,l_gal,b_gal,found,offset
;
; INPUTS:
;       l_gal and b_gal in degrees.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       found -- Boolean:  0 -> position NOT in GRS
;                          1 -> position in GRS
;       offset -- angular difference in degrees between input (l_gal,b_gal)
;                 and position in GRS
;
; COMMON BLOCKS:
; common datacube,cube,hdr,nlong,nlat,nchan,delta_l,delta_b,delta_v,lmap0,bmap0     
;                 current FITS datacube data and map parameters

;
; MODIFICATION HISTORY:
;   23 May 2006, written by T.M. Bania
;   31 May 2006, modified and enhanced by TMB
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
common datacube,cube,hdr,nlong,nlat,nchan,delta_l,delta_b,delta_v,lmap0,bmap0     
;               current FITS datacube data and map parameters
;
fmt0='("(l,b)=(",f7.4,",",f7.4,"): Position is not in GRS database!")'
fmt1='("(l,b)=(",f7.4,",",f7.4,") is in file",a)'
;
;
!b[0]={gbt_data}      ; initialize the TMB-IDL structure
;
if N_params() eq 0 then begin
    print,'getGRS.pro'
    print,'Finds a single (l,b) spectrum from GRS 13CO (1-0) data cubes.'
    print,'Translates this spectrum into TMBIDL !b[0] format'
    print,'*******************************************************************'
    print,'SYNTAX:  `getGRS,l_gal,b_gal,found,offset'
    print
    print,'          input l_gal,b_gal in degrees'
    print
    print,'          Returns: found -- Boolean:  0 -> position NOT in GRS
    print,'                                      1 -> position in GRS'
    print,'                   offset -- angular difference in degrees between '
    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'*******************************************************************'
    return
endif
;
; search for correct GRS FITS file 
; if you are convolving the GRS beam (!grsBeam=1) 
; do NOT change data cubes...
if (!grsBeam eq 1) then goto,deja_vu

findGRS,l_gal,b_gal,found,imap
;
if (found eq 0) then begin  ;  Error! position does not exist in GRS 
                     print,l_gal,b_gal,format=fmt0
                     print
                     return
                     end
;
fname=!grsFiles[imap]
;
; is this FITS cube already loaded? If not, then load...
if fname ne !currentGRSfile then begin
                                 cube=readfits(fname,hdr)
                                 !currentGRSfile=fname
                                 end
;
deja_vu:
!grsSpect=0. ; initialize GRS spectrum - default is 659 channels
nspec=0.     ; number of spectra:  i.e. flags gaussian beam average, etc. 
;vel=fltarr(!nchan) & vel[0:!nchan-1]=0. &
;
nlong=sxpar(hdr,'NAXIS1')
nlat =sxpar(hdr,'NAXIS2')
nchan=sxpar(hdr,'NAXIS3')
!data_points=nchan
;!grsNchan=nchan
; set NREGIONs for RMS which is put in Tsys slot in TMB-IDL structure
start=ceil(0.025*nchan)
stop =nchan - ceil(0.025*nchan) - 1
!nrset=2
!nregion[0]=0    & !nregion[1]=start & 
!nregion[2]=stop & !nregion[3]=!data_points -1 &
;
delta_l=-!grsSpacing & delta_b=!grsSpacing &   ; spacing constant but watch signs!
delta_v=sxpar(hdr,'CDELT3')/1000.D    ; in km/sec
;
lmap0=sxpar(hdr,'CRPIX1') & bmap0=sxpar(hdr,'CRPIX2') & ; map BRC
;l_ref=sxpar(hdr,'CRVAL1')& b_ref=sxpar(hdr,'CRVAL2') & ; always 0 in GRS
;
; convert input (l_gal,b_gal) into cube pixels
;
lpix=round((l_gal/delta_l)+lmap0)-1
bpix=round((b_gal/delta_b)+bmap0)-1
if lpix eq nlong then lpix=lpix-1
if bpix eq nlat  then bpix=bpix-1
;print,lpix,bpix
;
for i=0,nchan-1 do begin
      !grsSpect[i]=cube[lpix,bpix,i]
      ; Generate the x array of velocities
      ;vel[i]=(i-!grsCenCh)*!grsDeltaV+!grsVcen
endfor
nspec=nspec+1
;
;!grsSpect=!grsSpect/0.48    ; convert to MB brightness temperature
;
case 1 of ; test to see if spectral channels are less than GRS max.
          (nchan lt !grsNchan): begin
                                !b[0].data[0:!grsNchan-1]=0.
                                !b[0].data[0:nchan-1]=!grsSpect[0:nchan-1]
                                end
                          else: !b[0].data=!grsSpect
endcase 
;
mask,dsig            ; get RMS in nregion:  will need case statement
                     ; here to deal with different nchans
                     ; maybe not.... look at default nrset above...
!b[0].tsys=dsig      ; replace Tsys with RMS in NREGIONs
;print,dsig,' RMS in NREGIONs'
;
;plot,vel,!grsSpect
;
; =========================
; convert to TMBIDL format
; =========================
;
;
l_grs=(lpix+1 - lmap0)*delta_l & b_grs=(bpix+1 - bmap0)*delta_b & ; GRS position
;  assign source name
if (b_grs lt 0.d) then $
   source='G'+fstring(l_grs,'(f6.3)')+fstring(b_grs,'(f6.3)') $
   else $
   source='G'+fstring(l_grs,'(f6.3)')+'+'+fstring(b_grs,'(f5.3)')   
; GRS position is in general OFFSET from requested (l_gal,b_gal)
offset=sqrt( (l_gal-l_grs)^2 + (b_gal-b_grs)^2 ) * 3600.  ; arcmin
offset=long(offset) ; temporarily stick offset into scan_num....
;
!b[0].source=byte(strtrim(source,2))
!b[0].observer=byte('BU-FCRAO')
!b[0].obsid=byte('Galactic Ring Survey')
!b[0].scan_num=666L
!b[0].beamxoff=offset        ; offset in arsec between commanded and GRS (l,b)
!b[0].line_id=byte('13CO(1-0)')
;
!b[0].ra=0.d
!b[0].dec=0.d
!b[0].epoch=1950.
!b[0].l_gal=l_grs
!b[0].b_gal=b_grs
!b[0].hor_offset=lpix
!b[0].ver_offset=bpix
;
!b[0].vel=!grsVcen*1.0d+3     ; TMB-IDL velocities in FITS convention: m/sec
!b[0].ref_ch=!grsCenCh
!b[0].rest_freq=110.201353D+9
!b[0].sky_freq =110.201353D+9
!b[0].delta_x=-(delta_v/!light_c)*!b[0].rest_freq
;
!b[0].bw=nchan*abs(!b[0].delta_x)
!b[0].tintg=float(nspec)*60.
!b[0].tcal=1.d
;
!b[0].data_points=!data_points
;
return
end 
