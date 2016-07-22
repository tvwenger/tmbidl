;
pro sizes,fname
;+
; NAME:
;       sizes
;
; PURPOSE: 
;       Read a GRS fits data file and output the map parameters into
;       an IDL file for use in TMBIDL direct access code. 
;
; CALLING SEQUENCE:
;       sizes
;
; INPUTS:
;       FITS datacube file name: fname 
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
; MODIFICATION HISTORY:
;   6 June 2006 , T.M. Bania, Boston University, IAR 
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
;fname='/drang/grs_data/grs-17-cube.fits'
openu,lun,'/drang/grs_data/GRS_size.dat',/get_lun,/append

;
cube=readfits(fname,hdr)
;
mapfile=sxpar(hdr,'OBJECT')
nlong=sxpar(hdr,'NAXIS1')
nlat =sxpar(hdr,'NAXIS2')
nchan=sxpar(hdr,'NAXIS3')
size=nlong*nlat
;
delta_l=sxpar(hdr,'CDELT1')           ; in degrees 
delta_b=sxpar(hdr,'CDELT2')           ; in degrees
delta_v=sxpar(hdr,'CDELT3')/1000.D    ; in km/sec
;
lmap0=sxpar(hdr,'CRPIX1') & l_ref=sxpar(hdr,'CRVAL1') &
bmap0=sxpar(hdr,'CRPIX2') & b_ref=sxpar(hdr,'CRVAL2') &
v_ref=sxpar(hdr,'CRPIX3')         ; pixel/channel of this velocity
v_cen=sxpar(hdr,'CRVAL3')/1000.D   ; LSR velocity of 'center' channel  
;
;print
;print,'(lmap0,bmap0)= ',lmap0,bmap0
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
l_max=l_trc & l_min=l_tlc & l_cen=0.5*(l_max + l_min) &
b_max=b_trc & b_min=b_brc & b_cen=0.5*(b_max + b_min) &
;
; print out relevant information
;
;print
;print,fname+' => '+mapfile
;print,'grsSize=[                 $'
fmt='(9x,i4,", ",i4,", ",i7,",  $")'
print,nlong,nlat,size,format=fmt
;print,'         ]'
printf,lun,nlong,nlat,size,format=fmt
;
free_lun, lun
;
return
end 
