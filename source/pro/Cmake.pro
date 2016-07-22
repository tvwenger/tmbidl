pro cmake,infile,help=help
;+
; NAME:
;      CMAKE
;
;   cmake   Reads SDFITS DCR continuum data file.
;   -----   Uses changes in parameters to parse data into discrete 
;           continuum data records and converts these data into 
;           {tmbidl_data_v7.0} records stored to 
;           default file:  '../data/continuum/Cdata.tmbidl'
;
;   ====>   SDFITS does NOT pass the source position.
;           Positions need to be entered via a source catalog.
;           Default file: ../v7.0/catalogs/source_catalog
;
;   ====>   Makes a default log files with procedure and
;           data point information.  Defaults are: 
;           ../data/continuum/condar.log
;           ../data/continuum/cmake.log
;
;           Attaches this file to the OFFLINE file.
;           New data can be appended to this file via UPDATEC command.
;
;     =================================================
;     SYNTAX: cmake,fully_qualified_file_name,help=help
;     =================================================
;
;-
; V5.1 Nov  2007  
; V5.2 Dec  2007
;
; modified 11Dec07 dsb  Parse epoch from source catalog and sdfits
;                       file.  Make sure the epochs agree.
; modified 23Jan08 dsb  Add offline command near eof.
;          12Mar08 tmb  Add 'unknown' procedure type
;          05Aug08 tmb  Add l,b to TMBIDL header
;
; V6.0 June 2009
; v6/1 27feb2012 tmb  added 'Spider' code.  still is a work in progress


;
; V7.0 3may2013 tvw - added /help, !debug
;     23jun2013 tmb - fixed big/little endian bug for mrdfits
;     26jun2013 tmb - cleaned up documentation 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'Cmake' & return & endif
;
if n_params() eq 0 then begin
              print,'Input file name= no quotes necessary'
              filein=''
              read,filein,prompt='Set SDFITS  Data File Name: '
              infile=strtrim(filein,2)   ; trim blanks fore and aft
              if infile eq "" or infile eq " " then begin
                        print,'Invalid Input file name'
                        return
                        endif
              find_file,infile
endif
;
;infile= '/idl/idl/data/tests/T_7C43_01.cal.dcr.fits'  ; SDFITS file
!c_SDFITS=infile      ; set the continuum SDFITS file name for UPDATEC
batchon               ; first create the log file 
condar,infile         ; batch on/off supresses condar output
;
outfile=!continuum_data       ; {tmbidl_continuum_data}
logfile=!condar_log           ; log of the input file
gbtlog =!cmake_log            ; log of the !continuum_data file
; force infile to big endian 
openr,influn,infile,byteorder,/swap_if_little_endian,/get_lun
openr,loglun,logfile,/get_lun
openw,outlun,outfile,/get_lun
openw,gbtlun,gbtlog,/get_lun
logfmt='(i8,1x,i4,1x,a10,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6)'
gbtfmt='(i6,1x,i4,1x,a15,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a9,i6,i6)'
fmt='(a10,1x,a5,1x,i6)'
;goto, bypass
;
bypass:
;
sdf=mrdfits(influn,1,hdr,status=status) ; makes SDFITS data structure array
idx=-1                                  ; sdf[] index counter
;
free_lun,influn    ; get rid of SDFITS continuum infile
;
numrec=long(n_elements(sdf))  ;  # records in SDFITS file
print
print,'Scanning SDFITS continuum data file ==> ' + infile
print,infile + ' Contains ' + fstring (numrec,'(i10)') + ' records '
print
;
; now fetch the continuum logfile to see how to process these data
;
a=' '
hdr1=' ' & hdr2=' ' & hdr3=' '  & hdr4=' '  ;  file starts with 4 header lines
readf,loglun,hdr1 & readf,loglun,hdr2 & readf,loglun,hdr3 & readf,loglun,hdr4 &
print,hdr1 ; & print,hdr2 & print,hdr3 & print,hdr4 & print
;
kount=0
while not eof(loglun) do begin
      readf,loglun,a
      kount=kount+1
endwhile
print
print,'Number of discrete Continuum data records is '+string(kount,'(i5)')
print
close,loglun
;
rows=kount-4       ; first 4 records are headers
;                    rows are the number of data records in this file
openr,loglun,logfile
for i=0,3 do begin & readf,loglun,hdr2 & endfor
;
; loop through the log file to process the input SDFITS data file
;
num_rec=0
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
if !batch eq 0 then print,source,type,c_pts,format=fmt
;
     case type of
          'TCJ:N': proc_name = 'TCJ'
          'TCJ2:': proc_name = 'TCJ2'
          'Peak:': proc_name = 'Peak'
          'Focus': proc_name = 'Focus'
          'Spide': proc_name = 'Spide'
          'unkno': proc_name = 'unkno'
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
                            else: print,'Type ERROR !'
                          endcase 
                          end
                  'TCJ2': begin
                          case seq of 
                               1: begin & type='RA:'+type  & endcase 
                               2: begin & type='BRA:'+type  & endcase 
                               3: begin & type='DEC:'+type & endcase
                               4: begin & type='BDEC:'+type & endcase
                            else: print,'Type ERROR !'
                          endcase 
                          end
                  'Peak': begin
                          case seq of 
                               1: begin & type='AZ:'+type  & endcase 
                               2: begin & type='BAZ:'+type  & endcase 
                               3: begin & type='EL:'+type  & endcase
                               4: begin & type='BEL:'+type  & endcase
                            else: print,'Type ERROR !'
                          endcase 
                          end
                 'Focus': begin
                          case seq of 
                               1: begin & type=type  & endcase 
                               2: begin & type=type  & endcase
                            else: print,'Type ERROR !'
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
              in= sdf[idx]         ; pack {tmbidl_data} header 
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
;    now write out the data to the outfile after getting nominal
;    source RA/DEC from Continuum Source Catalog
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
     if error eq 1 then printf,gbtlun, $ 
        'NO MATCH!!! '+source+' is not in Continuum Source Catalog '+!source_catalog 
     out=!b[0]
     writeu,outlun,out
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
print
print,'Last scan in file is= ',scan,format='(a,i5)'
print,'Record  number in SDFITS file is= ',idx+1
print
print,'Made Continuum TMBIDL data file: ' + outfile
;
; attach this to the OFFLINE data file
;
off='OFFLINE'
attach,off,!continuum_data
;
free_lun,loglun
free_lun,gbtlun
free_lun,influn
free_lun,outlun
batchoff
;
offline
;
return
end

