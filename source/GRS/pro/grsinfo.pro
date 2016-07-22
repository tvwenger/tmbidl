;
pro GRSinfo
;+
; NAME:
;       GRSinfo
;
; PURPOSE: 
;       Read a GRS fits data file and output its parameters.
;       Figure out how to read GRS FITS files and put them into 
;       the TMBIDL data package
;
; CALLING SEQUENCE:
;       TEST
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
;   16 Sept 2005, T.M. Bania, Boston University, IAR 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fname='/drang/grs_data/grs-27-cube.fits'
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
lmap0=sxpar(hdr,'CRPIX1')
bmap0=sxpar(hdr,'CRPIX2')
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
; stuff the velocity axis 
;
v_center=sxpar(hdr,'CRVAL3')/1000.D   ; LSR velocity of 'center' channel  
v_refchan=sxpar(hdr,'CRPIX3')         ; pixel/channel of this velocity
;
x=fltarr(nchan)
for i=0,nchan-1 do begin
    x[i]=(i-v_refchan)*delta_v+v_center
end
;
; print out relevant information
;
print
print,fname+' => '+mapfile
print,'Map corners are:'
print,'('+fstring(l_tlc,'(f6.3)')+','+fstring(b_tlc,'(f6.3)')+') <--> '+ $
      '('+fstring(l_trc,'(f6.3)')+','+fstring(b_trc,'(f6.3)')+')'
print,'('+fstring(l_blc,'(f6.3)')+','+fstring(b_blc,'(f6.3)')+') <--> '+ $
      '('+fstring(l_brc,'(f6.3)')+','+fstring(b_brc,'(f6.3)')+')'
print,'Map dimensions are: (l,b,v)=('+fstring(nlong,'(I3)')+','+ $
      fstring(nlat,'(I3)')+','+fstring(nchan,'(I3)')+')'
print,'# spectral channels= '+fstring(nchan,'(i4)')
print
;print,x[round(v_refchan)]
;print,x,format='(10f7.2)'
;
; Generate a Source name for arbitrary (l,b) 
;
l=27.d & b=0.d &
; change the longitude and latitude into pixels
lpix=round((l/delta_l)+lmap0)
bpix=round((b/delta_b)+bmap0)
l_map=(lpix - lmap0)*delta_l   
b_map=(bpix - bmap0)*delta_b 
;
if (b_map lt 0.d) then $
   source='G'+fstring(l_map,'(f6.3)')+fstring(b_map,'(f6.3)') $
   else $
   source='G'+fstring(l_map,'(f6.3)')+'+'+fstring(b_map,'(f5.3)')   
;
print,'Source name for this position is: '+source
;
;
return
end 
