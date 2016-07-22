;
;   Read VAX VMS direct access data file of BUAO HI Survey
;
pro buao
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
print,'header record'
print,hdr.gl1,hdr.gb1
print,hdr.gl2,hdr.gb2
print,hdr.deltal,hdr.deltab,hdr.nl,hdr.nb
;
xx=indgen(681)
vel=findgen(681)
dv=0.51529d
vel=0.0+dv*(vel-340.)
;
print,'data records'
rec=0L
for i=1,714 do begin  
;while not eof(lun) do begin
      readu,lun,dat 
      dat=conv_vax_unix(dat) 
      rec=rec+1L
;
    if (dat.nspectra ne 0) then begin
        print,rec,dat.gl,dat.gb,dat.nspectra,dat.epoch[0],dat.drec[0], $
              dat.dtson[0],dat.dtsoff[0],dat.wtot,dat.weight[0], $
              format='(i7,2f7.3,i2,1x,i2,i4,2f6.1,2f9.3)' 
;        yy=dat.data
;        plot,vel,yy,/xstyle,/ystyle
;        ans=' '
;        read,ans        
    endif
;endwhile
endfor
;
out={gbt_data}
in=dat
buao2gbt,rec,in,out
!b[0]=out
;
close,lun
return
end
