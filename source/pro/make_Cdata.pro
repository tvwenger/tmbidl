pro make_Cdata,infile,outfile,proc_name,c_pts,help=help
;+
; NAME:
;       MAKE_CDATA
;
;  =============================================================================
;  Syntax: make_cdata, SDFITS_infile, TMBIDL_outfile, proc_name, c_pts,help=help
;  =============================================================================
;
; make_Cdata   Create CONTINUUM data file using the {tmbidl_data_v5.1} format.
; ----------   
;              INPUT data is from SDFITS filled data file. 
;              !kon  counts number of data records currently in file.
;              OUTPUT data is {tmbidl_data_v5.0} format to specified
;              file TMBIDL_outfile which must be fully qualified name.
;              This file must then be attached via ATTACH command.
;
; SDFITS_infile   => input GBT data file
; TMBIDL_outfile  => converted {tmbidl_data_v5.1} output file
; proc_name => continuum observing procedure string: 'TCJ', 'TCJ2',
;              'Peak', etc.
; c_pts => number of data points per record for this procedure
;-
; MODIFICATION HISTORY:
; written by TMB June 2004 and updated in June 2007
; V5.0 July 2007
; modified Oct 2007 by dsb and tmb to include proc_name and c_pts
; making it general for any continuum procedure less than 891 points long
;
; V5.1 November 2007
; modified to hardwire max 891 points and store actual number of
; continuum data points, c_pts, in !b[0].c_pts
;
; V7.0 03may2013 tvw - added /help, !debug
;-
;       
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
nparm=n_params()
;
;goto,no_filter_yet    ; skip past the fancy parm stuff below
;
if nparm eq 0 or keyword_set(help) then begin & get_help,'make_Cdata' & return & endif
;
if nparm lt 2 then begin
              print,'Input file name= no quotes necessary'
              filein=''
              read,filein,prompt='Set SDFITS File Name: '
              infile=strtrim(filein,2)   ; trim blanks fore and aft
              if infile eq "" or infile eq " " then begin
                 print,'Invalid Input file name'
                 return
                 endif
              find_file,infile
              print,'Output file name= no quotes necessary'
              fileout=''
              read,fileout,prompt='Set Output File Name: '
              outfile=strtrim(fileout,2)
              if outfile eq "" or outfile eq " " then begin
                 print,'Invalid Input file name'
                 return
                 endif
endif
;
if nparm lt 3 then proc_name = 'TCJ' ; default to TCJ
if nparm lt 4 then c_pts = !c_pts    ; default to existing !c_pts
;
no_filter_yet:
;
; Read the SDFITS Continuum data file 
;
;infile='/idl/idl/data/AGBT02A_041_01.cal.dcr.fits'   ; SDFITS file
;outfile='/idl/idl/data/Ctest.gbt'                    ; {continuum_data}
;
openr,lun,infile,/get_lun
sdf=mrdfits(lun,1,hdr,status=status)      ; makes SDFITS data structure array
;
free_lun,lun    ; get rid of infile
;
numrec=long(n_elements(sdf))  ;  # records in SDFITS file
print
print,'Scanning SDFITS continuum data file ==> ' + infile
print,infile + ' Contains ' + fstring (numrec,'(i10)') + ' records '
print
;
;
;  create the OUTPUT data file from an existing SDFITS file 
;
get_lun,lun
openw,lun,outfile 
;
;====================================================================================================
;
old_scan=-1             ; initialize data elements 
old_polid='XXX'
old_seq =-1
old_type='blank'
;
!c_pts=c_pts            ; set number of data points in proc_name
kount=0
rec_no=-1
;
case proc_name of
            'TCJ': type_name = 'TCJ:N'
           'TCJ2': type_name = 'TCJ2:'
           'Peak': type_name = 'Peak:'
          'Focus': type_name = 'Focus'
             else: begin
                   print,'Invalid Procedure Name'
                   return
                   end
endcase
;
print
print,'REC# SCAN   OBJECT   POL     RA           DEC       AZ    EL   SEQ  TYPE   # PTS'
;
for i=0,numrec-1 do begin
;
    scan=sdf[i].scan                             ; use header values to define data size
    polid=(sdf[i].crval4 eq -1) ? 'RR' : 'LL'
    seq=sdf[i].procseqn                      
    type=strmid(sdf[i].obsmode,0,5)
;
    if type ne type_name then goto,next    ; choose input proc_name to process
;   if (type ne 'Peak:') then goto,next          ; choose only PEAK scans 
;   if (type ne 'TCJ:N') then goto,next          ; choose only TCJ scans 
;
; HERE IS WHERE YOU WRITE OUT THE PREVIOUS DATA and initialize !b[0]
;
    if polid ne old_polid   or $
       seq   ne old_seq     or $
       type  ne old_type    then begin
;
          old_polid=polid
          old_seq=seq
          old_type=type

          if kount eq c_pts then begin
                   rec_no=rec_no+1
                   !b[0].c_pts=c_pts
                   procid=strtrim(proc_name,2)
                   !b[0].proc_id=byte(procid)
                   out=!b[0]
                   writeu,lun,out
                   print,rec_no,                                       $
                         !b[0].scan_num,                               $
                         string(!b[0].source),                         $
                         string(!b[0].pol_id),                         $
                         adstring(!b[0].ra,!b[0].dec),                 $
                         !b[0].az,!b[0].el,                            $
                         !b[0].procseqn,                               $
                         string(!b[0].scan_type),kount,                $
                   format='(i4,1x,i4,1x,a10,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6)'
          end
;
          !b[0]=!blkrec          ; initialize buffer 0 
          kount=0L            ; initialize channel count for this data record
      endif
;
    if scan ne old_scan then old_scan=scan
;
    kount=kount+1
;
    src=sdf[i].object
    ra= sdf[i].crval2   
    dec=sdf[i].crval3  
    az=sdf[i].azimuth
    el=sdf[i].elevatio 
    data=sdf[i].data    
;
    idx=kount-1
    !b[0].data[idx]=data                  ; we pack the continuum data, and the positions
    !b[0].data[idx+!c_chan]=az             ; of each data point in AZ, EL, RA, and DEC
    !b[0].data[idx+2*!c_chan]=el           ; all in the !b[0].data array, 
    !b[0].data[idx+3*!c_chan]=ra           ; modulo !c_chan
    !b[0].data[idx+4*!c_chan]=dec
;
    if kount eq floor(c_pts/2L) then begin  ; pack continuum header with infomation
       ra= sdf[i].crval2                     ; from center channel of data 
       dec=sdf[i].crval3  
       az= sdf[i].azimuth
       el= sdf[i].elevatio 
;
;  change observing mode to show RA/Dec TCJ
;  use procseqn   seq=1 RA TCJ  seq=2 Dec TCJ
;  procseqnumber is different for each continuum procedure
;
       type=strtrim(sdf[i].obsmode,2)
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
                                    2: begin & type='RA:'+type  & endcase 
                                    3: begin & type='DEC:'+type & endcase
                                    4: begin & type='DEC:'+type & endcase
                         endcase 
                         end
                 'Peak': begin
                         case seq of 
                                    1: begin & type='AZ:'+type  & endcase 
                                    2: begin & type='AZ:'+type  & endcase 
                                    3: begin & type='EL:'+type & endcase
                                    4: begin & type='EL:'+type & endcase
                         endcase 
                         end
       endcase
;
       sdf[i].obsmode=type
;
       in= sdf[i]           ; pack {tmbidl_data_v5.1} header 
       out=!b[0]            ; IDL structures passed by reference
       sd2Cgbt,in,out       ; not value hence this construction    
       !b[0]=out
;
;       print,scan,src,polid,adstring(ra,dec),az,el,seq,type,kount, $
;             format='(i4,1x,a10,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6)'
    end
;
next:
endfor
; CODE BELOW OUPUTS THE VERY LAST RECORD
rec_no=rec_no+1
!b[0].c_pts=c_pts
procid=strtrim(proc_name,2)
!b[0].proc_id=byte(procid)
out=!b[0]
writeu,lun,out
print,rec_no,                                       $
      !b[0].scan_num,                               $
      string(!b[0].source),                         $
      string(!b[0].pol_id),                         $
      adstring(!b[0].ra,!b[0].dec),                 $
      !b[0].az,!b[0].el,                            $
      !b[0].procseqn,                               $
      string(!b[0].scan_type),kount,                $
      format='(i4,1x,i4,1x,a10,1x,a3,1x,a24,f7.1,f6.1,i4,2x,a5,i6)'
print
print,'Last scan in file is= ',scan,format='(a,i4)'
print,'Record  number in SDFITS file is= ',i
;
;
print
print,'Used SDFITS CONTINUUM data file '+infile
print,'Made {tmbidl_data} CONTINUUM data file '+outfile+' with '+$
      fstring(rec_no+1,'(i5)')+' records'
print
; 
free_lun,lun      ; close the output {tmbidl_data} file
;
return
end







