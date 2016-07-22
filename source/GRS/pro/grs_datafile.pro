;
pro GRS_datafile
;+
; NAME:
;       datafile
;
; PURPOSE: 
;       Read a GRS FITS data file and output its parameters into
;       an IDL file in TMB-IDL format for direct access....  
;
; CALLING SEQUENCE:
;       datafile
;
; INPUTS:
;       None.
;
;
; MODIFICATION HISTORY:
;   23 Sept 2005, T.M. Bania, Boston University, IAR 
;   31 May  2006, TMB did squat of worth with the first version
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
common datacube,cube,hdr,nlong,nlat,nchan,delta_l,delta_b,delta_v,lmap0,bmap0     
;               current FITS datacube data and map parameters
;
fmt0='(a,i4,i4,i5,f12.2,f12.2)'
;
;if n_params() eq 0 then begin;
;                        print,'Error: must supply FITS cube filename'
;                        return
;                        end
;
nfits=!grsNfiles
;
!b[0]={gbt_data}      ; initialize the TMB-IDL structure
;
!currentGRSfile=' ' ; starts with no FITS file open and in common datacube 
;
;for i=0,nfits-1 do begin     ; do it all!
for i=9,9 do begin
      infile=!grsFiles[i] & outfile=!grsIDLfiles[i] &
;
; is this FITS cube already loaded? If not, then load & parse 
;                                   FITS cube map parameters
      if infile ne !currentGRSfile then begin
                   !currentGRSfile=infile
                   openw,lun,outfile,/get_lun
;
                   cube=readfits(infile,hdr)
;
                   nlong=sxpar(hdr,'NAXIS1')
                   nlat =sxpar(hdr,'NAXIS2')
                   nchan=sxpar(hdr,'NAXIS3')
                   delta_l=-!grsSpacing & delta_b=!grsSpacing &   
                   delta_v=sxpar(hdr,'CDELT3')/1000.D    ; in km/sec
                   lmap0=sxpar(hdr,'CRPIX1') & bmap0=sxpar(hdr,'CRPIX2') & ; map BRC
                   !data_points=nchan
                   ;print,nlong,nlat,nchan
;                  set NREGIONs for RMS which is put in Tsys slot in TMB-IDL structure
                   start=ceil(0.025*nchan)
                   stop =nchan - ceil(0.025*nchan) - 1
                   !nrset=2
                   !nregion[0]=0    & !nregion[1]=start & 
                   !nregion[2]=stop & !nregion[3]=!data_points -1 &
                   print,infile,nlong,nlat,nchan,lmap0,bmap0,format=fmt0
                   end
;
;
      !kount=0L
;     FITS cubes use FORTRAN indexes...... Dummy..... 1->nlong,nlat
;     
      for j=0,nlong-1 do begin
;       for j=0,2 do begin      
            for k=0,nlat-1 do begin            
;            for k=100,300 do begin
                  grs2idl,j,k            ; FITS cube 
                  !b[0].scan_num=!kount  ; !kount is ASSOC index 'scan_number'
                  writeu,lun,!b[0]       ; write out record to file
                  !kount=!kount+1L
            endfor
      endfor
;      print relevant info
;
print,'File '+outfile+' created with '+fstring(!kount,'(i10)')+' records'
print,!grssize[*,i]   ; compare this to what is in !grsSize database
;
endfor
;
free_lun,lun
;
return
end 
