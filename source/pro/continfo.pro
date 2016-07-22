pro continfo,infile,help=help
;+
; NAME:
;      CONTINFO
;
;   continfo   Scan SDFITS continuum data file and determine the number
;   --------   of continuum data points per record.  Prompts for filename 
;              if none is input. Uses changes in scan number, polarization,           
;              scan type, and sequence number to flag new data records.
;              Note that different continuum observing procedures, e.g.
;              PEAK, FOCUS, etc. will have different number of data
;              points. 
;
;      Syntax: continfo,fully_qualified_file_name,help=help
;      ==========================================
;
; V5.0 July 2007  TMB changes pol_id to LL and RR as per GBT/SDFITS
; now
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'continfo' & return & endif
;
;infile='/idl/idl/data/Feb04.cal.dcr.fits' ; hardwire if you wish, but 
;goto,bypass                               ; must then defeat trap below
if n_params() eq 0 then begin
               print,'Input continuum file name= no quotes necessary'
               infile=''
               read,infile,prompt='Set SDFITS File Name: '
               infile=strtrim(infile,2)   ; trim blanks fore and aft
               if ( (infile eq "") or (infile eq " ") ) then begin
                                   print,'Invalid Input file name'
                                   return
                                   endif
               find_file,infile
endif
;
; Read the SDFITS Continuum data file 
;
bypass:
openr,lun,infile,/get_lun
sdf=mrdfits(lun,1,hdr,status=status)
;
free_lun,lun    ; get rid of infile
;
numrec=long(n_elements(sdf))  ;  # records in SDFITS file
print
print,'Scanning SDFITS data file ==> ' + infile
print,infile + ' Contains ' + fstring(numrec,'(i5)') + ' records '
print
;
;=================================================================
old_scan=-1                  ; initialize data elements   
old_seq =-1
old_type='blank'
old_polid='XXX'
kount=0L
rec_no=-1L
;
print,'REC#     SCAN   OBJECT   POL     RA           DEC       AZ    EL   SEQ  TYPE   #_DATA_PTS'
;print,'SCAN   OBJECT      RA           DEC       AZ    EL   SEQ TYPE      #_DATA_PTS'
print
;
for i=0L,numrec-1 do begin
;
    scan=sdf[i].scan                             ; use header values to define data size
    polid=(sdf[i].crval4 eq -1) ? 'RR' : 'LL'
    seq=sdf[i].procseqn                      
    type=strmid(sdf[i].obsmode,0,5)
;
;    if (type ne 'Peak:') then goto,next         ; filter here for particular data type 
;
    if ( polid ne old_polid or $
         seq ne old_seq     or $
         type ne old_type ) then begin
;
          old_polid=polid
          old_seq=seq
          old_type=type
;
;          if (i ne 0) then begin
                           in= sdf[i]      ; pack {gbt_data} header 
                           out=!b[0]       ; IDL structures passed by reference
                           sd2Cgbt,in,out  ; not value hence this construction    
                           !b[0]=out
                           print,i,                                            $
                                 !b[0].scan_num,                               $
                                 string(!b[0].source),                         $
                                 string(!b[0].pol_id),                         $
                                 adstring(!b[0].ra,!b[0].dec),                 $
                                 !b[0].az,!b[0].el,                            $
                                 !b[0].procseqn,                               $
                                 string(!b[0].scan_type),kount,                $
                           format='(i8,1x,i4,1x,a10,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6)'
;          end
;
          !b[0]=!blkrec          ; initialize buffer 0 
          kount=0L            ; initialize channel count for this data record
    endif
;
    kount=kount+1
    if scan ne old_scan then old_scan=scan
;
next:
endfor
;
                           print,rec_no,                                       $
                                 !b[0].scan_num,                               $
                                 string(!b[0].source),                         $
                                 string(!b[0].pol_id),                         $
                                 adstring(!b[0].ra,!b[0].dec),                 $
                                 !b[0].az,!b[0].el,                            $
                                 !b[0].procseqn,                               $
                                 string(!b[0].scan_type),kount,                $
                           format='(i8,1x,i4,1x,a10,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6)'
print
print,'Last scan in file is= ',scan,format='(a,i4)'
print,'Record  number in SDFITS file is= ',i
;
;
print
print,'Used SDFITS CONTINUUM data file '+infile
print
;
free_lun,lun
;
return
end
