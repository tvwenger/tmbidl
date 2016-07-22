pro buao_hdr,help=help         ;   read only the header
;
;   Read VAX VMS direct access data file of BUAO HI Survey
;
;-
; MODIFICATION HISTORY
; 2004??? tmb writes v3.2 version
; v7.0 11jul2013 tmb - implementing  deleted globals call to 
;                      conform with new package protocols
;
on_error,2
;
;  Define the basic BUAO data structure format
;
;  This is a VAX VMS Direct Access Fortran Data File
;  that starts with a header and then has fixed length record
;  data
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
file='/home/bania/buao/survey/survey.dat'
openr,lun,file,/get_lun
;
readu,lun,hdr
hdr=conv_vax_unix(hdr)
print,'BUAO HI Survey header record'
print,hdr.gl1,hdr.gb1,format='("     Start position: ",f8.4,",",f8.4)'
print,hdr.gl2,hdr.gb2,format='("     Stop  position: ",f8.4,",",f8.4)'
print,hdr.deltal,hdr.deltab,$
      format='("     Coordinate increments: (",f7.4,",",f7.4,")")'
print,hdr.nl,hdr.nb, $
      format='("     Giving a map dimension of ", I3," x",i3)'
;
;@buao_globals
;
!gl0=hdr.gl1          &  !gb0=hdr.gb1         &
!delata_l=hdr.deltal  &  !delta_b=hdr.deltab  &
!nl=long(hdr.nl)      &  !nb=long(hdr.nb)     &
;
close,lun
return
end
