pro grs2idl,lidx,bidx
;+
;
;  grs2idl.pro  Convert from GRS FITS data to TMB-IDL !b[0] format
;
;  written by T.M. Bania, 1 June 2006
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
common datacube,cube,hdr,nlong,nlat,nchan,delta_l,delta_b,delta_v,lmap0,bmap0     
;               current FITS datacube data and map parameters
;
fmt0='(i8,i4,i4,f8.4,f8.4,f12.2,2x,"contained NaN data")'
fmt1='("(",i4,",",i4,")",2x," contains NaN data !!!")'
;
if N_params() eq 0 then begin
    print,'grs2idl.pro'
    print,'Translates a GRS FITS lpix,bpix into TMBIDL !b[0] format'
    print,'*******************************************************************'
    print,'SYNTAX:  grs2idl,lpix,bpix'
    print
    print,'*******************************************************************'
    return
endif
;
!data_points=!grsNchan
!grsSpect[0:!grsNchan-1]=0.; initialize GRS spectrum - default is 659 channels
nspec=1.          ; each record is single spectrum at (lpix,bpix) in FITS cube
!b[0].procseqn=0L ; default flag says data are really there
;
!grsSpect[0:nchan-1]=cube[lidx,bidx,*]
;
;test_nan=where(!grsSpect ne !grsSpect)   ; look for NaNs and then flag
test_nan=where(finite(!grsSpect,/NAN),NaN_count)
if NaN_count gt 0 then begin
                       !b[0].procseqn=1L  ; FLAG that this slot is empty
                       !grsSpect[0:!grsNchan-1]=0.
                       NaN_count=0L
                       ;print,lidx,bidx,format=fmt1
endif
;
case 1 of ; test to see if spectral channels are less than GRS max.
          (nchan lt !grsNchan): begin
                                !b[0].data[0:!grsNchan-1]=0.
                                !b[0].data[0:nchan-1]=!grsSpect[0:nchan-1]
                                !data_points=nchan
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
; =========================
; convert to TMBIDL format
; =========================
;
l_grs=(lidx+1 - lmap0)*delta_l & b_grs=(bidx+1 - bmap0)*delta_b & ; GRS position
;  assign source name
if (b_grs lt 0.d) then $
   source='G'+fstring(l_grs,'(f6.3)')+fstring(b_grs,'(f6.3)') $
   else $
   source='G'+fstring(l_grs,'(f6.3)')+'+'+fstring(b_grs,'(f5.3)')   
; GRS position is in general OFFSET from requested (l_gal,b_gal)
offset=0.d ; by definition, the GRS pixels have no offset !!!!
offset=long(offset) ; temporarily stick offset into scan_num....
;
!b[0].source=byte(strtrim(source,2))
!b[0].observer=byte('BU-FCRAO')
!b[0].obsid=byte('Galactic Ring Survey')
!b[0].scan_num=666L             ; 'scan number' is rec position in file
!b[0].beamxoff=offset            ; offset in arsec between commanded and GRS (l,b)
                                 ; stuffed into beamxoff parameter
!b[0].line_id=byte('13CO(1-0)')
;
!b[0].ra=0.d
!b[0].dec=0.d
!b[0].epoch=1950.
!b[0].l_gal=l_grs
!b[0].b_gal=b_grs
!b[0].hor_offset=lidx+1
!b[0].ver_offset=bidx+1
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
if (!b[0].procseqn eq 1) then $
               print,!kount,lidx,bidx,l_grs,b_grs,!b[0].data[213],format=fmt0
;
return
end
