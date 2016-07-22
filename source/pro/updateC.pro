pro updateC,help=help
;+
; NAME:
;       UPDATEC
;
;            =========================
;            Syntax: updateC,help=help
;            =========================
;
;   updateC   Update OFFLINE CONTINUUM data file by appending new data 
;   -------   to existing OFFLINE data file.  
;             INPUT data is from SDFITS data file.
;
;             Assumes SDFITS datafile is being updated: i.e. you are
;             observing at the GBT and continually filling the data.
;
;             Translates and appends new data to OFFLINE data file. 
;
;             SDFITS !c_SDFITS defined by CMAKE
;                                         ----- 
;             !koff  counts number of OFFLINE data records currently in file
;
; =========> ASSUMES SDFITS FILE IS CREATED WITH MODE=CAL <=============
; =========> ASSUMES THIS IS CONTINUUM DATA               <=============
;
;-
; V5.0 12Dec07 by TMB
;      This is a lot trickier than spectral line UPDATE because we
;      need to figure out the size of each continuum data entity 
; V6.0 June 2009 tmb added l,b to !b[0]
; v6.1 12apr2012 tmb added 'Spider' code.  still is a work in progress
; v7.0 may2013 tmb/tvw added keyword help and new error handling
;      23jun2013 tmb - fixed mrdfits big/little endian bug 
;
;-
;       
on_error,!debug ? 0 : 2
compile_opt idl2   
;
if keyword_set(help) then begin & get_help,'updateC' & return & endif
;
; Read the SDFITS data file 
;
infile=!c_SDFITS              ; SDFITS data file set by Cmake.pro
logfile=!condar_log           ; log of the input file
outfile=!continuum_data       ; {tmbidl_continuum_data}
!offline_data=!continuum_data ; selbstverstandlich
gbtlog =!cmake_log            ; log of the !continuum_data file
;
; first make a new condar log file
;
batchon                  ; supress condar output
condar,infile,numrec 
;
print
print,'Updating OFFLINE CONTINUUM data file from SDFITS file ==> ' + !c_SDFITS
print,!c_SDFITS + ' now contains ' + fstring(numrec,'(i6)') + ' records '
xx=numrec-!koff
print,'There are ' + fstring(xx,'(i4)') + ' more records since last update'
print
if xx eq 0 then begin & print,'NO NEW DATA!!!!' & return & endif
;
; now open all the files
;
; force big endian for infile
openr,influn,infile,byteorder,/swap_if_little_endian,/get_lun
openr,loglun,logfile,/get_lun
openu,gbtlun,gbtlog,/get_lun,/append
openu,!offunit,!offline_data,/append ;  append to OFFLINE data file 
;
logfmt='(i8,1x,i4,1x,a10,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6)'
gbtfmt='(i6,1x,i4,1x,a15,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a9,i6,i6)'
fmt='(a10,1x,a5,1x,i6,1x,i6)'
;
sdf=mrdfits(influn,1,hdr,status=status) ; makes SDFITS data structure array
idx=-1                                  ; sdf[] index counter
;
free_lun,influn    ; get rid of SDFITS continuum infile
;
; now fetch the continuum logfile to see how to process these data
;
a=' ' & for i=0,3 do begin & readf,loglun,a & endfor ; file header
;
index=0   ; space forward to the new data
while index ne !koff-1 do begin
      readf,loglun,a
      xa=strsplit(a,' ',count=cols,/extract)
      FITSrec=long(xa[0])
      c_pts=  long(xa[14])     
      index=  long(xa[15])
endwhile
;
idx=FITSrec+c_pts-1
;
print,'Found the first new data record: index = '+fstring(index+1,'(i5)')
;
num_rec=!koff   ;
while not eof(loglun) do begin
;for kk=0,2 do begin
     readf,loglun,a
     xa=strsplit(a,' ',count=cols,/extract)
     rec=    long(xa[0])
     scan=   long(xa[1])
     source= xa[2]
     pol=    xa[3]
     rah=    float(xa[4])
     ram=    float(xa[5])
     ras=    float(xa[6])
     decd=   float(xa[7])
     decm=   float(xa[8])
     decs=   float(xa[9])
     az=     float(xa[10])
     el=     float(xa[11])
     seq=    long(xa[12])
     type=   xa[13]
     c_pts=  long(xa[14])
     index=  long(xa[15])
;
;    print,a
if !batch eq 0 then print,source,type,c_pts,index,format=fmt
;
     case type of
          'TCJ:N': proc_name = 'TCJ'
          'TCJ2:': proc_name = 'TCJ2'
          'Peak:': proc_name = 'Peak'
          'Focus': proc_name = 'Focus'
          'Spide': proc_name = 'Spide'
             else: begin
                   print,'Invalid Procedure Name'
                   return
                   end
     endcase
;
     !c_pts=c_pts    ; set number of data points in continuum proc
     !b[0]=!blkrec   ; initialize the record
     !b[0].c_pts=c_pts 
     procid=strtrim(proc_name,2)
     !b[0].proc_id=byte(procid)
     kount=0
;
     for j=0,c_pts-1 do begin   ; do the continuum data record
           kount=kount+1
           idx=idx+1         
           ra= sdf[idx].crval2   
           dec=sdf[idx].crval3  
           az=sdf[idx].azimuth
           el=sdf[idx].elevatio 
           data=sdf[idx].data    
;
           !b[0].data[j]=data         ; pack the continuum data, and the positions
           !b[0].data[j+!c_chan]=az   ; of each data point in AZ, EL, RA, and DEC
           !b[0].data[j+2*!c_chan]=el ; all in the !b[0].data array, 
           !b[0].data[j+3*!c_chan]=ra ; modulo !c_chan
           !b[0].data[j+4*!c_chan]=dec
;          use the center channel of the data record to pack continuum header
           if kount eq long(c_pts/2) then begin 
              ra= sdf[idx].crval2     
              dec=sdf[idx].crval3  
              az= sdf[idx].azimuth       ; from center channel of data 
              el= sdf[idx].elevatio 
;
;             change observing mode to show RA/Dec TCJ
;             use procseqn   seq=1 RA TCJ  seq=2 Dec TCJ
;             procseqnumber is different for each continuum procedure
;             The 'B' notation flags scans done is opposite direction
;
              type=strtrim(sdf[idx].obsmode,2)
;
              case proc_name of
                   'TCJ': begin
                          case seq of 
                               1: begin & type='RA:'+type  & endcase 
                               2: begin & type='DEC:'+type & endcase
                          endcase 
                          end
                  'TCJ2': begin
                          case seq of 
                               1: begin & type='RA:'+type  & endcase 
                               2: begin & type='BRA:'+type  & endcase 
                               3: begin & type='DEC:'+type & endcase
                               4: begin & type='BDEC:'+type & endcase
                          endcase 
                          end
                  'Peak': begin
                          case seq of 
                               1: begin & type='AZ:'+type  & endcase 
                               2: begin & type='BAZ:'+type  & endcase 
                               3: begin & type='EL:'+type  & endcase
                               4: begin & type='BEL:'+type  & endcase
                          endcase 
                          end
                 'Focus': begin
                          case seq of 
                               1: begin & type=type  & endcase 
                               2: begin & type=type  & endcase
                          endcase 
                          end
                 'Spide': begin
                          case seq of 
                               1: begin & type='RA:'  +type  & endcase 
                               2: begin & type='BRA:' +type  & endcase
                               3: begin & type='CC:'  +type  & endcase
                               4: begin & type='BCC:' +type  & endcase
                               5: begin & type='DEC:' +type  & endcase
                               6: begin & type='BDEC:'+type  & endcase
                               7: begin & type='CW:'  +type  & endcase
                               8: begin & type='BCW:' +type  & endcase
                            else: print,'Type ERROR !'                           
                          endcase 
                          end
             
                 'unkno': type=type
             
                    else: begin
                          print,'Invalid Procedure Name'
                          return
                          end
              endcase
;
              sdf[idx].obsmode=type
;
              in= sdf[idx]         ; pack {tmbidl_data_v5.1} header 
              out=!b[0]            ; IDL structures passed by reference
              sd2Cgbt,in,out       ; not value hence this construction    
              !b[0]=out
;              !b[0].scan_num=num_rec
              num_rec=num_rec+1
;
           endif
;
     endfor
;
;  Get nominal source RA/DEC from Continuum Source Catalog
;
     get_source,source,ra,dec,epoch,error
     !b[0].ra=ra & !b[0].dec=dec &
     ; check that the source epoch matches the sdfits data epoch
     case epoch of
         'B1950': begin
                  if !b[0].epoch ne 1950.0 then begin
                      print, 'Source and data epoch do not match: ', epoch, !b[0].epoch
                  endif
                  end
         'J2000': begin
                  if !b[0].epoch ne 2000.0 then begin
                      print, 'Source and data epoch do not match: ', epoch, !b[0].epoch
                  endif
                  end
            else: begin
                  print, 'Invalid epoch'
                  end
     endcase
;
; add the l_gal,b_gal to the TMBIDL header
     ra2lb,gl,gb & !b[0].l_gal=gl & !b[0].b_gal=gb 
;

     if error eq 1 then printf,gbtlun,  $ 
        'NO MATCH!!! '+source+' is not in Continuum Source Catalog '+!source_catalog 
     out=!b[0]
     writeu,!offunit,out
     print,idx+1,                                        $
           !b[0].scan_num,                               $
           string(!b[0].source),                         $
           string(!b[0].pol_id),                         $
           adstring(!b[0].ra,!b[0].dec),                 $
           !b[0].az,!b[0].el,                            $
           !b[0].procseqn,                               $
           string(!b[0].scan_type),kount,index,          $
           format=gbtfmt
;    also write this to a file
     printf,gbtlun,idx+1,                                $
           !b[0].scan_num,                               $
           string(!b[0].source),                         $
           string(!b[0].pol_id),                         $
           adstring(!b[0].ra,!b[0].dec),                 $
           !b[0].az,!b[0].el,                            $
           !b[0].procseqn,                               $
           string(!b[0].scan_type),kount,index,          $
           format=gbtfmt
;         
     kount=0      
;
endwhile
;endfor
;
print,'Updated OFFLINE data file ' + !offline_data 
print
print,'Last scan in file is= ',scan,format='(a,i5)'
;print,'Record  number in SDFITS file is= ',idx+1
print
close,!offunit
offline
; 
free_lun,influn
free_lun,loglun
free_lun,gbtlun
batchoff
;
return
end







