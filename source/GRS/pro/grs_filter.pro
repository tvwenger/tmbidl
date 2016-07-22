;
pro GRSfilter,l_gal,b_gal
;+
; NAME:
;       GRSfilter
;
; PURPOSE: Search for the correct survey data file given
;          an input (l,b) galactic position
;
; CALLING SEQUENCE:
;       GRSfilter,l_gal,b_gal
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
;   23 Sept 2005, written by T.M. Bania
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fname=['/drang/grs_data/grs-15-cube.fits','/drang/grs_data/grs-16-cube.fits', $
       '/drang/grs_data/grs-17-cube.fits','/drang/grs_data/grs-18-cube.fits', $
       '/drang/grs_data/grs-19-cube.fits','/drang/grs_data/grs-20-cube.fits', $
       '/drang/grs_data/grs-21-cube.fits','/drang/grs_data/grs-22-cube.fits', $
       '/drang/grs_data/grs-23-cube.fits','/drang/grs_data/grs-24-cube.fits', $
       '/drang/grs_data/grs-25-cube.fits','/drang/grs_data/grs-26-cube.fits', $
       '/drang/grs_data/grs-27-cube.fits','/drang/grs_data/grs-28-cube.fits', $
       '/drang/grs_data/grs-29-cube.fits','/drang/grs_data/grs-30-cube.fits', $
       '/drang/grs_data/grs-31-cube.fits','/drang/grs_data/grs-32-cube.fits', $
       '/drang/grs_data/grs-33-cube.fits','/drang/grs_data/grs-34-cube.fits', $
       '/drang/grs_data/grs-35-cube.fits','/drang/grs_data/grs-36-cube.fits', $
       '/drang/grs_data/grs-37-cube.fits','/drang/grs_data/grs-38-cube.fits', $
       '/drang/grs_data/grs-39-cube.fits','/drang/grs_data/grs-40-cube.fits', $
       '/drang/grs_data/grs-41-cube.fits','/drang/grs_data/grs-42-cube.fits', $
       '/drang/grs_data/grs-43-cube.fits','/drang/grs_data/grs-44-cube.fits', $
       '/drang/grs_data/grs-45-cube.fits','/drang/grs_data/grs-46-cube.fits', $
       '/drang/grs_data/grs-47-cube.fits','/drang/grs_data/grs-48-cube.fits', $
       '/drang/grs_data/grs-49-cube.fits','/drang/grs_data/grs-50-cube.fits', $
       '/drang/grs_data/grs-51-cube.fits','/drang/grs_data/grs-52-cube.fits', $
       '/drang/grs_data/grs-53-cube.fits','/drang/grs_data/grs-54-cube.fits', $
       '/drang/grs_data/grs-55-cube.fits','/drang/grs_data/grs-56-cube.fits' ]
;
nfiles=n_elements(fname)
;
outfile='/drang/grs_data/cube_info.dat'
openw,lun,outfile,/get_lun
printf,lun
printf,lun,'grsMaps=[                 $'
printf,lun
free_lun,lun
;
for i=0,nfiles-1 do begin
;                 fparms,fname[i]
;                 centers,fname[i]
;                 sizes,fname[i]
                  cubeinfo,fname[i]
endfor
;
openu,lun,outfile,/get_lun,/append
printf,lun,'         ]'
free_lun, lun
;
return
end 
