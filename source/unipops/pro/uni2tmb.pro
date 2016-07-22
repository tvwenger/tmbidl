;
; un2tmb     procedure to convert UNIPOPS NSAVE into TMBIDL format
;            on a record by record basis 
; 
;            returns the hdr and data as string arrays
;
pro uni2tmb,record,hdr,data
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fname='/idl/idl/unipops/nsave'
;
;rec=''
recsize=650 & hsize=394 & dsize=256 &
record=strarr(recsize)
hdr= strarr(hsize)
data=strarr(dsize)
;
openr, 1,fname
;
kount=0
while not eof(1) do begin
      readf, 1, record
      hdr= record[0:hsize-1]
      data=record[hsize:hsize+dsize-1]
      kount=kount+1
  endwhile
print,record[recsize-1]
;
close,1
;
;  ok, now start converting the record into TMBIDL !b[0]
;
;  first fill the spectral data array
;

;
nchan=dsize
!data_points=nchan
!b[0]={gbt_data}                  ;  initialize !b[0] array 
!b[0].data_points=nchan
!b[0].data=0.
!b[0].data[0:nchan-1]=data
;
scan=long(hdr[18])
!b[0].scan_num=scan
source=hdr[12]
!b[0].source=byte(strtrim(source,2))
observer=hdr[8]
!b[0].observer=byte(strtrim(observer,2))
obsid=hdr[11]
!b[0].obsid=byte(strtrim(obsid,2))
dtype=hdr[229]
scan_type=dtype
!b[0].scan_type=byte(strtrim(scan_type,2))
ltype=hdr[230]
line_id=ltype
!b[0].line_id=byte(strtrim(line_id,2))
!b[0].lst=float(hdr[33])
;!b[0].date=byte(strtrim(date,2))    ;   date in hdr seems bogus


comment=hdr[41]                      ; 'solid' description of detection quality
!b[0].history=byte(strtrim(comment,2)) 
calfact=float(hdr[129])              ; define these for 'history' space
dstat=hdr[232]
cmt=hdr[233]                         ; is blank in this record?  ever used?
rxobs=hdr[234]
;
!b[0].ra=float(hdr[84])              ; i think this is precessed to obs. epoch
!b[0].dec=float(hdr[85])             ; it certainly is NOT 1950. co-ords
!b[0].epoch=float(hdr[79])
!b[0].l_gal=float(hdr[86])
!b[0].b_gal=float(hdr[87])
!b[0].az=float(hdr[88])
!b[0].el=float(hdr[89])
;
vel=float(hdr[158])
!b[0].vel=vel*1.0d+3     ; TMBIDL velocities in FITS convention: m/sec
ref_chan=float(hdr[330])
!b[0].ref_ch=ref_chan
rest_freq=float(hdr[321])*1.D+6
!b[0].rest_freq=rest_freq
sky_freq=float(hdr[320])*1.D+6
!b[0].sky_freq =sky_freq
delta_x=float(hdr[322])*1.D+6
!b[0].delta_x=delta_x
vel_def=hdr[159]
!b[0].vel_def=byte(strtrim(vel_def,2))
;
bw=float(hdr[323])*1.D+6
!b[0].bw=bw
tintg=float(hdr[333])
!b[0].tintg=tintg/60.D
tcal=float(hdr[325])
!b[0].tcal=tcal
tsys=float(hdr[326])
!b[0].tsys=tsys
!b[0].tsys_on=tsys
tsys_off=float(hdr[327])
!b[0].tsys_off=tsys_off
;
;
return
end
