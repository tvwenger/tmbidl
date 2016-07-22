;+
; NAME: 
;      ARCHIVE_140 
;
; archive_140     procedure to convert UNIPOPS NSAVE into TMBIDL format
; ===========     on a record by record basis 
; 
;            returns the hdr and data as string arrays
;
; V5.0 July 2007
;-
pro archive_140,record,hdr,data
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fname_in ='/idl/idl/unipops/nsave_140.arc'
fname_out='/idl/idl/unipops/archive_140.dat'
get_lun,in 
get_lun,out
openr,in,fname_in
openw,out,fname_out
;
recsize=650 & hsize=394 & dsize=256 &
record=strarr(recsize)
hdr= strarr(hsize)
data=strarr(dsize)
nchan=dsize
!data_points=nchan
@archive_data         ; define the output structure
arc={archive_data}
;
kount=0
while not eof(in) do begin
      readf,in, record
      hdr= record[0:hsize-1]
      data=record[hsize:hsize+dsize-1]
      kount=kount+1
  endwhile
;
print
print,'Read '+fstring(kount,'(i8)')+' Records from file: '+fname_in
print
;
close,in
openr,in,fname_in
;  ok, now start converting the record into Archival 'arc' structure
;
kwrite=0
while not eof(in) do begin
;  
      readf,in,record
      hdr= record[0:hsize-1]
      data=record[hsize:recsize-1]
;
      arc.data_points=nchan
      arc.data=0.
      arc.data=data
;
      scan=long(hdr[18])
      arc.scan_num=scan
      source=hdr[12]
      arc.source=''        ; strings in structure should be reset to blank
      arc.source=byte(strtrim(source,2))
      observer='ROOD/BANIA/BALSER'
      arc.observer=byte(strtrim(observer,2))
      obsid=hdr[11]
      arc.obsid=''
      arc.obsid=byte(strtrim(obsid,2))
      dtype=hdr[229]
      scan_type=dtype
      arc.scan_type=''
      arc.scan_type=byte(strtrim(scan_type,2))
      ltype=hdr[230]
      line_id=ltype
      arc.line_id=''
      arc.line_id=byte(strtrim(line_id,2))
      arc.lst=float(hdr[33])
      ;arc.date=byte(strtrim(date,2))  ;   date in hdr seems bogus
;
      arc.date=byte('140 FOOT UniPops Archive')
;     define these for 'history' space
      comment=hdr[41]                  ; 'solid' description of detection quality
      arc.comment=''
      arc.comment=byte(strtrim(comment,2)) 
      calfact=hdr[129]          
      calibration_factor=float(calfact)
      calfact=fstring(calfact,'(f8.6)')
if kwrite eq 666 then print,kwrite,calibration_factor,calfact
      arc.calfact=''
      arc.calfact=byte(strtrim(calfact,2))
      dstat=byte(strtrim(hdr[232],2))
      arc.dstat=''
      arc.dstat=dstat
      cmt=byte(strtrim(hdr[233],2))   ; is blank in this record?  ever used?
      arc.cmt=''
      arc.cmt=cmt       
      rxobs=byte(strtrim(hdr[234],2)) ; is blank in this record?  ever used?
      arc.rxobs=''
      arc.rxobs=rxobs
;
      arc.ra=float(hdr[84])              ; i think this is precessed to obs. epoch
      arc.dec=float(hdr[85])             ; it certainly is NOT 1950. co-ords
      arc.epoch=float(hdr[79])
      arc.l_gal=float(hdr[86])
      arc.b_gal=float(hdr[87])
      arc.az=float(hdr[88])
      arc.el=float(hdr[89])
;
      vel=float(hdr[158])
      arc.vel=vel*1.0d+3     ; TMBIDL velocities in FITS convention: m/sec
      ref_chan=float(hdr[330])
      arc.ref_ch=ref_chan
      rest_freq=float(hdr[321])*1.D+6
      arc.rest_freq=rest_freq
      sky_freq=float(hdr[320])*1.D+6
      arc.sky_freq =sky_freq
      delta_x=float(hdr[322])*1.D+6
      arc.delta_x=delta_x
      vel_def=hdr[159]
      arc.vel_def=''
      arc.vel_def=byte(strtrim(vel_def,2))
;
      bw=float(hdr[323])*1.D+6
      arc.bw=bw
      tintg=float(hdr[333])
      arc.tintg=tintg/60.D
      tcal=float(hdr[325])
      arc.tcal=tcal
      tsys=float(hdr[326])
      arc.tsys=tsys
      arc.tsys_on=tsys
      tsys_off=float(hdr[327])
      arc.tsys_off=tsys_off
;
writeu,out,arc
kwrite=kwrite+1
;
endwhile
;
print
print,'Wrote '+fstring(kwrite,'(i8)')+' Records to file: '+fname_out
print
close,in
close,out
;
return
end
