;
pro cubeinfo,fname
;+
; NAME:
;       cubeinfo
;
; PURPOSE: 
;       Read a GRS fits data file and output its parameters.
;
; CALLING SEQUENCE:
;       cubeinfo
;
; INPUTS:
;       parameter_value
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
; 
; 
; PROCEDURES CALLED:
;
; EXAMPLES:
;
; NOTES:
;
;
; MODIFICATION HISTORY:
;   23 Sept 2005, T.M. Bania, Boston University, IAR 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if n_params() eq 0 then begin;
                        print,'Error: must supply FITS cube filename'
                        return
                        end
;fname='/drang/grs_data/grs-27-cube.fits'
openu,lun,'/drang/grs_data/SURVEY.info',/get_lun,/append
;
cube=readfits(fname,hdr)
;
mapfile=sxpar(hdr,'OBJECT')
nlong=sxpar(hdr,'NAXIS1')
nlat =sxpar(hdr,'NAXIS2')
nchan=sxpar(hdr,'NAXIS3')
;
;CTYPE1  = 'GLON-GLS'           / L = (X-CRPIX1)*CDELT1+CRVAL1 
;CTYPE2  = 'GLAT-GLS'           / B = (Y-CRPIX2)*CDELT2+CRVAL2 
; (l,b) positions are in (x,y) pixel values wrt the galactic center
;       pixel spacing is 22.14 arcsec => 0.00615 deg/pixel
;CTYPE3  = 'VELOCITY'           / V = (Z-CRPIX3)*CDELT3+CRVAL3
;BUNIT   = 'K       '           / Antenna Temperature, Tb = Ta/0.48 
;
delta_l=sxpar(hdr,'CDELT1')           ; in degrees 
delta_b=sxpar(hdr,'CDELT2')           ; in degrees
delta_v=sxpar(hdr,'CDELT3')/1000.D    ; in km/sec
;
lmap0=sxpar(hdr,'CRPIX1') & l_ref=sxpar(hdr,'CRVAL1') &
bmap0=sxpar(hdr,'CRPIX2') & b_ref=sxpar(hdr,'CRVAL1') &
v_ref=sxpar(hdr,'CRPIX3')         ; pixel/channel of this velocity
v_cen=sxpar(hdr,'CRVAL3')/1000.D   ; LSR velocity of 'center' channel  
;
; Now let's calculate the map (l,b)-corners 
; l=(x - lmap0)*delata_l & b=(y - bmap0)*delta_b &
; N.B. these CLASS FITS cubes have indices: 1 -> nlong, nlat
; 
l_tlc=(1.d - lmap0)*delta_l    & b_tlc=(nlat - bmap0)*delta_b &
l_blc=(1.d - lmap0)*delta_l    & b_blc=(1.d - bmap0)*delta_b &
l_trc=(nlong - lmap0)*delta_l  & b_trc=(nlat - bmap0)*delta_b &
l_brc=(nlong - lmap0)*delta_l  & b_brc=(1.d - bmap0)*delta_b &
;
; print out relevant information
;
print
print,fname+' => '+mapfile
print,'Map corners are:'
print,'('+fstring(l_tlc,'(f7.4)')+','+fstring(b_tlc,'(f7.4)')+') <--> '+ $
      '('+fstring(l_trc,'(f7.4)')+','+fstring(b_trc,'(f7.4)')+')'
print,'('+fstring(l_blc,'(f7.4)')+','+fstring(b_blc,'(f7.4)')+') <--> '+ $
      '('+fstring(l_brc,'(f7.4)')+','+fstring(b_brc,'(f7.4)')+')'
print,'Map dimensions are: (l,b,v)=('+fstring(nlong,'(I3)')+','+ $
      fstring(nlat,'(I3)')+','+fstring(nchan,'(I3)')+')'+ $
              '  # spectral channels= '+fstring(nchan,'(i4)')
print,'(lmap0,bmap0) = ('+fstring(lmap0,'(f9.4)')+','+ $
       fstring(bmap0,'(f9.4)')+'  (l_ref,b_ref) = ('+ $
       fstring(l_ref,'(f5.2)')+','+fstring(b_ref,'(f5.2)')+')'
print,'(delta_l,delta_b) = ('+fstring(delta_l,'(f8.5)')+','+ $
       fstring(delta_b,'(f8.5)')+')'
print,'(v_ref,v_cen,vchan,delta_v)= ('+fstring(v_ref,'(f9.4)')+','+ $ 
       fstring(v_cen,'(f7.4)')+','+fstring(nchan,'(i4)')+','+ $
       fstring(delta_v,'(f7.4)')+')'
print
;
printf,lun
printf,lun, fname+' => '+mapfile
printf,lun, 'Map corners are:'
printf,lun, '('+fstring(l_tlc,'(f7.4)')+','+fstring(b_tlc,'(f7.4)')+') <--> '+ $
      '('+fstring(l_trc,'(f7.4)')+','+fstring(b_trc,'(f7.4)')+')'
printf,lun, '('+fstring(l_blc,'(f7.4)')+','+fstring(b_blc,'(f7.4)')+') <--> '+ $
      '('+fstring(l_brc,'(f7.4)')+','+fstring(b_brc,'(f7.4)')+')'
printf,lun, 'Map dimensions are: (l,b,v)=('+fstring(nlong,'(I3)')+','+ $
      fstring(nlat,'(I3)')+','+fstring(nchan,'(I3)')+')'+ $
              '  # spectral channels= '+fstring(nchan,'(i4)')
printf,lun,'(lmap0,bmap0) = ('+fstring(lmap0,'(f9.4)')+','+ $
       fstring(bmap0,'(f9.4)')+'  (l_ref,b_ref) = ('+ $
       fstring(l_ref,'(f5.2)')+','+fstring(b_ref,'(f5.2)')+')'
printf,lun,'(delta_l,delta_b) = ('+fstring(delta_l,'(f8.5)')+','+ $
       fstring(delta_b,'(f8.5)')+')'
printf,lun,'(v_ref,v_cen,vchan,delta_v)= ('+fstring(v_ref,'(f9.4)')+','+ $ 
       fstring(v_cen,'(f7.4)')+','+fstring(nchan,'(i4)')+','+ $
       fstring(delta_v,'(f7.4)')+')'
printf,lun
;
free_lun,lun
return
end 
