;+
; NAME:
;
;   update_bozo.pro   Update ONLINE data file by appending new data to existing
;   ---------------   ONLINE data file.  
;
;                     Syntax: update,on_scan_number
;                     -----------------------------
;                     Translates and appends new data to ONLINE data file. 
;
;                     !kon  counts number of ONLINE data records currently in file
;                     !last_scan keeps track of last valid OnOFF ON scan processed
;
; T.M. Bania July 2005
;-
pro update_bozo,on_scan_number
;       
on_error,!debug ? 0 : 2
;
if (n_params() eq 0) then begin
                     print
                     print,'Error: must input a valid ON scan number'
                     print,'Syntax: update,on_scan_#'
                     return
                 end
;
;  update the ONLINE data file from translation of raw telescope data 
;
openu,!onunit,!online_data,/append ;  append to ONLINE data file 
close,!dataunit                    ;  force !dataunit state
openr,!dataunit,!datafile          ;  raw telescope data file
;
scan=on_scan_number
!last_scan=scan   ; last ON scan processed
;
istat=corposonoff(!dataunit,b,t,cals,bonrecs,boffrecs,/sclcal,scan=scan)
;
if (istat ne 1) then begin
                     print,'ERROR: PS not successful'
                     return
                 end
;
write_to_buffer=0
;
rec_no=0L   ; counter of new records added to ONLINE
;
for ijk=0,2 do begin  ; loop over PS, ON, and OFF processing
       case (ijk) of 
                   0: begin
                      a=b     ; the PS data
                      proc='PS'
                      write_to_buffer=1
                      end
                   1: begin
                      a=coravgint(bonrecs) ; the ON data
                      proc='ON'
                      write_to_buffer=0
                      end
                   2: begin
                      a=coravgint(boffrecs) ; the OFF data
                      proc='OFF'
                      write_to_buffer=0
                      end
        endcase
;
nbrds=a.b1.h.cor.numbrdsused  ; number of correlator boards used
npol=n_elements(a.b1.p)       ; number of polarizations
;
k=7
for i=0,nbrds-1 do begin 
    for j=0,npol-1 do begin 
;
        out={gbt_data}  ; output data record
        in=a
        ao2gbt,i,j,in,out
;
        scn=a.(i).h.std.scannumber  & scn=strtrim(string(scn),2) &
        rxid='rx'+strtrim(string(i+1),2)+'.'+strtrim(string(j+1),2)
        if j eq 0 then polid='LL' else polid='RR'
        polid=strtrim(polid,2)
        rest_freq=a.(i).h.dop.freqBCRest  ; band center freq. in MHz
        sky_freq=rest_freq + a.(i).h.dop.freqoffsets[i]
        fsky=fstring(sky_freq,'(f9.4)')
;
        output=scn+' '+proc+' '+rxid+' '+polid+' '+fsky
        print,output
;
        out.scan_type=byte(proc)
        out.line_id=byte(rxid)
        out.pol_id=byte(polid)
        out.sky_freq=fsky*1.D+6
;
;       now cals and Tsys
;
        aocals=cals.calval
        tsyson=t.on
        tsysoff=t.off
        tsys=(tsyson+tsysoff)/2.
        out.tcal     =aocals[j,i]
        out.tsys     =tsys[j,i]
        out.tsys_on  =tsyson[j,i]
        out.tsys_off =tsysoff[j,i]
;
        writeu,!onunit,out
        rec_no=rec_no+1             ; increment number of ONLINE data records
;
        if (write_to_buffer eq 1) then begin
                                       !b[k]=out
                                       k=k+1
                                       end
;
    endfor
endfor
;
endfor  ; the IJK loop
;
!recmax=!kon+rec_no             ; set maximum record number for gbt data
;print,!recmax,!kon
!kon=!recmax 
;
out:
;
close,!dataunit
close,!onunit
;
copy,0,6                       ; update the maximum scan number 
get,!kon-1
last_scan=!b[0].scan_num
copy,6,0
!scanmax=last_scan
;
print
print,'Updated ONLINE data file '+!online_data+ $
               ' with '+strtrim(string(rec_no),2)+' new records'
print
online
; 
return
end
