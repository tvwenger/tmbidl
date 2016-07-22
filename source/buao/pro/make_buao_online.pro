;+
;
;   make_BUAO_ONLINE.pro   create ONLINE data file using the GBT data structure format
;   -------------------- 
;
;                     !kon  counts number of ONLINE data records currently in file
;                     recs_per_scan is the number of subcorrelators per scan#
;
;                     INPUT data is from BUAO VAXdata file 
;                     !datafile defined by init_data.pro which MUST be run
;                     before make_ONLINE   -------------
;
;                     Syntax: make_BUAO_ONLINE 
;-
pro make_BUAO_ONLINE
;       
on_error,2   
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
; DO YOU WANT TO MAKE AN ONLINE DATA FILE?
print,'Current ONLINE file definition is:'
print,'ONLINE file will be= ' + !online_data, ' LUN= ' + fstring(!dataunit,'(I3)')
print
print,'Do you want to make the ONLINE file? (y/n) '
ans=get_kbrd(1)
if (ans eq 'n') then begin
                     !online_data=''
                     print
                     print,'*************************************************'
                     print,'There is NO ONLINE data file!'
                     print,'Please ATTACH one and issue ONLINE command.'
                     print,'*************************************************'
                     print
;                    Must initialize package even if no ONLINE file created
;                    !data_points, !nchan, !recs_per_scan
;
                     num_points=0L
                     print,'Input # data points per spectrum'
                     read,num_points,prompt='Input # data points per spectrum:'
                     !data_points=num_points & !nchan=!data_points &
                     print,'==> Spectra have '+fstring(!data_points,'(I6)')+' data points'
                     recs_per_scan=0L
                     print,'Input # records per scan, i.e. # subcorrelators in configuration'
                     read,recs_per_scan,prompt='Input # records per scan: '
                     !recs_per_scan=recs_per_scan
                     print,'==> Each Scan makes '+fstring(!recs_per_scan,'(I3)')+' spectra'
;
                     return
                     end
;

;
if (n_params() eq 0) then begin
                    recs_per_scan=0L
                    print,'Input # records per scan, i.e. # subcorrelators in configuration'
                    read,recs_per_scan,prompt='Input # records per scan: '
                    !recs_per_scan=recs_per_scan
                    end
;
print,'==> Each Scan makes '+fstring(!recs_per_scan,'(I3)')+' spectra'
;
; Read the VAX VMS BUAO data file 
;
get_lun,lun
openr,lun,!datafile
;
print & print,'Processing BUAO data file '+!datafile & print &
readu,lun,hdr
;
;  create the ONLINE data file from BUAO VAX VMS file 
;
openw,!onunit,!online_data      ;  use default value for ONLINE data file name
;

in={buao_data}
out={gbt_data}                  ;  convert VAX VMS -> {buao_data}  -> {gbt_data}
;
!kon=0L & rec=0L &
print,'rec#     l_gal  b_gal ? eph drc  Ton   Toff    Wtot      Wt   Hoff  Voff'
print
;for i=1,100 do begin  
while not eof(lun) do begin
      readu,lun,dat             ;  read VMS into {buao_data}
      dat=conv_vax_unix(dat) 
      in=dat
      hor=floor(rec/!nb)        ;  calculate hor,ver offsets in spacing units
      ver=rec mod !nb           ;  assume rec=0 is origin
;
      buao2gbt,rec,hor,ver,in,out       ;  {buao_data}  -> {gbt_data
      writeu,!onunit,out
;
      print,rec,dat.gl,dat.gb,dat.nspectra,dat.epoch[0],dat.drec[0], $
            dat.dtson[0],dat.dtsoff[0],dat.wtot,dat.weight[0],hor,ver, $
            format='(i7,2f7.3,i2,1x,i2,i4,2f6.1,2f9.3,1x,2i4)' 
;
      rec=rec+1L
      !kon=!kon+1L
;      
;endfor
endwhile
;
!recmax=!kon                    ; set maximum record number for ONLINE data
;
print
print,'Made ONLINE data file '+!online_data+' with '+$
      fstring(!kon,'(i7)')+' records'
print
;
!b[0]=out
; 
close,lun
close,!onunit
;
;  find value of last scan number
;
copy,0,10
get,!kount-1
!last_scan=!b[0].scan_num
copy,10,0
setrange,0,!last_scan
;
return
end







