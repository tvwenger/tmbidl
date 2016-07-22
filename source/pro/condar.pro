pro condar,infile,numrec,help=help
;+
; NAME:
;      CONDAR
;
;   condar   Looks at continuum data: Reads SDFITS DCR continuum data file.  
;   ------   Uses changes in parameters to parse data into discrete continuum
;            data records 
;
;     =========================================================
;     Syntax: condar,fully_qualified_file_name, $
;                    number_of_independent_data_units,help=help
;     =========================================================
;-
; V5.0 July 2007
; V5.1 Nov  2007  modified to make output summary file of contents
;                 cleaned up logic.  
;                 now gives positions at nominal center of data unit
; 12Dec07 tmb modified to return the number, NUMREC, of independent data units
;                 this is needed for the real time UPDATEC procedure    
; V7.0 3may2013 tvw - added /help, !debug   
;     26jun2013 tmb - cleaned up documentation
;                     fixed big/little endian bug for mrdfits
;       
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'condar' & return & endif
;
logfile=!condar_log  ; log of the input file
openw,loglun,logfile,/get_lun
logfmt='(i8,1x,i4,1x,a16,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6,i6)'
recfmt='(66x,a4,i4,a5,i2,a8,i4,a4)'
;
;infile='/idl/idl/data/Feb04.cal.dcr.fits' ; hardwire if you wish, but 
;goto,bypass                               ; must then kill the trap below
;
if n_params() eq 0 then begin
              print,'Input file name= no quotes necessary'
              filein=''
              read,filein,prompt='Set SDFITS File Name: '
              infile=strtrim(filein,2)   ; trim blanks fore and aft
              if infile eq "" or infile eq " " then begin
                        print,'Invalid Input file name'
                        return
                        endif
              find_file,infile
endif
;
bypass:
; force infile to big endian
openr,lun,infile,byteorder,/swap_if_little_endian,/get_lun
sdf=mrdfits(lun,1,hdr,status=status)
nrecs=n_elements(sdf)
;
header='SDFITS file: '+infile+' has '+fstring(nrecs,'(i6)')+ ' records '
if !batch eq 0 then begin & print & print,header & end
printf,loglun,header
printf,loglun
;
header='FITS REC SCAN       OBJECT     POL RAH RAM RAS DECD DMIN DSEC'
header=header+'  AZ    EL   SEQ TYPE    PTS  INDEX'
if !batch eq 0 then begin & print & print,header & print & end
printf,loglun,header
printf,loglun
;
old_scan  = sdf[0].scan 
ipol      = sdf[0].crval4
old_polid = findpol(ipol)
old_seq   = sdf[0].procseqn 
old_type  = strmid(sdf[0].obsmode,0,5)
;
idx=0L   
kount=0L
;
for i=0L,nrecs-1 do begin  ; use header values to define data size
;for i=0,2500 do begin
;
    scan=sdf[i].scan                         
    ipol=sdf[i].crval4
    polid=findpol(ipol)
    seq=sdf[i].procseqn                      
    type=strmid(sdf[i].obsmode,0,5)
;
    if seq   ne old_seq    or  $
       type  ne old_type   or  $
       polid ne old_polid  then begin
;
          old_seq=seq
          old_type=type
          old_polid=polid
          rec_num=i-kount
          center=rec_num+kount/2
;
          in= sdf[center] ; pack {tmbidl_data} header at nominal center position
          out=!b[0]       ; IDL structures passed by reference
          sd2Cgbt,in,out  ; not value hence this construction    
          !b[0]=out
;
          if !batch eq 0 then                                 $
          print,rec_num,                                      $
                !b[0].scan_num,                               $
                string(!b[0].source),                         $
                string(!b[0].pol_id),                         $
                adstring(!b[0].ra,!b[0].dec),                 $
                !b[0].az,!b[0].el,                            $
                !b[0].procseqn,                               $
                string(!b[0].scan_type),kount,idx,            $
                format=logfmt
;
          printf,loglun,rec_num,                              $
                !b[0].scan_num,                               $
                string(!b[0].source),                         $
                string(!b[0].pol_id),                         $
                adstring(!b[0].ra,!b[0].dec),                 $
                !b[0].az,!b[0].el,                            $
                !b[0].procseqn,                               $
                string(!b[0].scan_type),kount,idx,            $
                format=logfmt
;
          !b[0]=!blkrec          ; initialize buffer 0
          idx=idx+1 
          kount=0
    endif
;
    kount=kount+1
    if scan ne old_scan then old_scan=scan
;
endfor
;         now write out the final record
          rec_num=rec_num+kount
          center=rec_num+kount/2
          in= sdf[center] ; pack {tmbidl_data} header 
          out=!b[0]       ; IDL structures passed by reference
          sd2Cgbt,in,out  ; not value hence this construction    
          !b[0]=out
;
          if !batch eq 0 then                                 $
          print,rec_num,                                      $
                !b[0].scan_num,                               $
                string(!b[0].source),                         $
                string(!b[0].pol_id),                         $
                adstring(!b[0].ra,!b[0].dec),                 $
                !b[0].az,!b[0].el,                            $
                !b[0].procseqn,                               $
                string(!b[0].scan_type),kount,idx,            $
                format=logfmt
;
          printf,loglun,rec_num,                              $
                !b[0].scan_num,                               $
                string(!b[0].source),                         $
                string(!b[0].pol_id),                         $
                adstring(!b[0].ra,!b[0].dec),                 $
                !b[0].az,!b[0].el,                            $
                !b[0].procseqn,                               $
                string(!b[0].scan_type),kount,idx,            $
                format=logfmt
;
;print,'Last scan in file is= ',scan,format='(a,i4)'
;
numrec=idx+1
;
free_lun,lun
free_lun,loglun
;
return
end

