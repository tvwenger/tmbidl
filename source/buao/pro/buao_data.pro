;+
;   buao_data.pro   Reads input BUAO VAX data file
;   -------------   Sets parameters of the IDL GBT data structure 
; 
;-
; MODIFICATION HISTORY
; 2004? tmb original v3.2 code
; v7.0 11jul2013 tmb - implementing.  deleted globals call to
;                      conform to new package protocols
;-
pro buao_data,fname
;
on_error,2
;
if (n_params() eq 0) then fname=!datafile
;
find_file,fname   ; does this file exist?
;
!datafile=fname
;
get_lun,lun
openr,lun,!datafile
!dataunit=lun
;
;
;  Define the basic BUAO data structure format
;
;  This is a VAX VMS Direct Access Fortran Data File that starts 
;  with a header and then has 2888 byte fixed length record data
;
;
hdr = {buao_header, $                 ;  # bytes -> # bytes
       gl1:0.0D, $                    ;     8           8   start GL
       gb1:0.0D, $                    ;     8          16   start GB
       gl2:0.0D, $                    ;     8          24   end GL
       gb2:0.0D, $                    ;     8          32   end GB
       deltal:0.0D, $                 ;     8          40   GL spacing arcmin
       deltab:0.0D, $                 ;     8          48   GB spacing arcmin
       nl:0,        $                 ;     2          50   no. cells in L
       nb:0,        $                 ;     2          52   no. cells in B
       xx:intarr(4), $                ;     8          60   ???
       yy:intarr(4), $                ;     8          68
       pad:bytarr(2820)   $           ;  2820        2888
;
}                        ; end of definition
;
dat = {buao_data,   $                 ;  # bytes -> # bytes
       gl:0.0D,     $                 ;     8           8   GL
       gb:0.0D,     $                 ;     8          16   GB
       nspectra:0,  $                 ;     2          18   flag if data there?
       wtot:0.0D,   $                 ;     8          26   total weight
       epoch:intarr(3),   $           ;     6          32   observing epoch
       dscan:dblarr(3),   $           ;    24          56   scan# dddy###
       drec:fltarr(3),    $           ;    12          68   # data records
       dtcal:fltarr(3),   $           ;    12          80   Tcal (K)
       dza:fltarr(3),     $           ;    12          92   zenith angle (deg)
       dtson:fltarr(3),   $           ;    12         104   Tsys on (K)
       dtsoff:fltarr(3),  $           ;    12         116   Tsys off (K)
       dtintg:fltarr(3),  $           ;    12         128   tintg (sec)
       weight:dblarr(3),  $           ;    24         152   weight factor?
       fact:fltarr(3),    $           ;    12         164   ???
       data:fltarr(681)   $           ;  2724        2888   
;
}                        ; end of definition
;
readu,lun,hdr
hdr=conv_vax_unix(hdr)
print
print,'BUAO HI Survey header record'
print
print,hdr.gl1,hdr.gb1,format='("     Start position: ",f8.4,",",f8.4)'
print,hdr.gl2,hdr.gb2,format='("     Stop  position: ",f8.4,",",f8.4)'
print,hdr.deltal,hdr.deltab,$
      format='("     Coordinate increments: (",f7.4,",",f7.4,")")'
print,hdr.nl,hdr.nb, $
      format='("     Giving a map dimension of ", I3," x",i3)'
;
!kount=long(hdr.nl*hdr.nb)
print
print,!datafile + ' Contains ' + fstring(!kount,'(i6)') + ' records '
print
;
nchan=n_elements(dat.data)
!data_points=long(nchan)
print,'Each spectrum has '+fstring(nchan,'(I6)')+' data points'
;
!nchan=!data_points
;
;@buao_globals
;
!gl0=hdr.gl1          &  !gb0=hdr.gb1         &
!delata_l=hdr.deltal  &  !delta_b=hdr.deltab  &
!nl=long(hdr.nl)      &  !nb=long(hdr.nb)     &
print
print,'Defined BUAO map global variables'
print
;
free_lun,lun
;
return
end


