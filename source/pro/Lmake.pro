pro lmake,infile,outfile,n_points=num_points,n_recs=recs_per_scan,noid=noid,help=help
;+
; NAME:
;      LMAKE
;
;   lmake   Reads SDFITS spectral line data file and converts
;   -----   these data into {tmbidl_data} records stored to a
;           default file:  '../data/line/Ldata.tmbidl'
;           Attaches this file to the ONLINE file.
;   ==> New data can be appended to this file via UPDATE command.
;
;     ===========================================================
;     Syntax: lmake,fully_qualified_file_name,help=help,noid=noid
;     ===========================================================
;
;     INPUT    SDFITS fully_qualified_file_name
;
;     OUTPUT   {tmbidl_data} file named '../data/line/Ldata.tmbidl'
;
;     KEYWORDS     help    - gives this help
;                  noid    - if set supresses Line ID assignment
;                  outfile - writes to specified file instead of default 
;                  
;-
; V5.2 18 Dec 2007  tmb
;       4 Jan 2008  added /get_lun to fetch lun for SDFITS file
;      23Jan08 dsb set !kon=0 before loop to fix counter problem.
;                  added online command near eof.
;      05Aug08 tmb added l_gal,b_gal to TMBIDL header
;
; V6.0 June 2009
;
; V6.1 06feb2011 tmb 
;      21dec2011 tmb  modified to service new rxidrec.pro that 
;                     accounts for change in GBT sampler mapping 
; V7.0 03may2013 tvw - added /help, !debug
;      22jun2013 tmb - updated documentation 
;      23jun2013 tmb - fixed big/little endian mrdfits issue
;      09jul2014 tmb - tweaked for VEGAS v8.0
;      11jul2014 tmb - added /noid keyword for testing 
;                      now stores SDFITS line_id in !b[0].proc_id
;                     
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'Lmake' & return & endif
;
if n_params() eq 0 then begin
              print,'Input file name= no quotes necessary'
              filein=''
              read,filein,prompt='Set SDFITS Spectral Line Data File Name: '
              infile=strtrim(filein,2)   ; trim blanks fore and aft
              if infile eq "" or infile eq " " then begin
                        print,'Invalid Input file name'
                        return
                        endif
              find_file,infile
endif
;
; Initialize package: !data_points, !nchan, !recs_per_scan
;
if N_Elements(n_points) eq 0 then begin
   num_points=0
   print,'Input # data points per spectrum'
   read,num_points,prompt='Input # data points per spectrum:'
endif
!data_points=num_points & !nchan=!data_points &
print,'==> Spectra have '+fstring(!data_points,'(I6)')+' data points'
if N_Elements(recs_per_scan) eq 0 then begin
   recs_per_scan=0
   print,'Input # records per scan, i.e. # subcorrelators in configuration'
   read,recs_per_scan,prompt='Input # records per scan: '
endif
!recs_per_scan=recs_per_scan
print,'==> Each Scan makes '+fstring(!recs_per_scan,'(I3)')+' spectra'
;
; Read the SDFITS data file 
;
!datafile=infile      ; set the spectral SDFITS file name for UPDATE
;                       make sure big endian 
openr,inlun,!datafile,byteorder,/swap_if_little_endian,/get_lun
;
sdd = mrdfits(inlun, 1, hdr, status=status) ; makes SDFITS data structure array
free_lun,inlun
;
!kount=n_elements(sdd)
;
print
print,'Constructing ONLINE data file from SDFITS file ==> ' + !datafile
print
print,!datafile + ' Contains ' + fstring(!kount,'(i5)') + ' records '
print
;
;  create the ONLINE data file from an existing SDFITS file 
;
if n_elements(outfile) ne 0 then begin
   if ~file_test(outfile, /write) then begin
      print, 'File location not writable/does not exist.  Returning.'
      return
   endif
   !line_data = outfile
endif
!online_data=!line_data
openw,!onunit,!online_data      ;  use default value for spectral line data 
;
out={tmbidl_data}                  ;  convert SDFITS format to GBT format
;
if !config eq 6 then begin ; if VEGAS then load rest frequencies and ID labels
   catalogFile='../catalogs/rrls.catalog'
   catalog=' ' & read_table,catalogFile,data=catalog,/silent
endif 
;
!kon=0
for i=0,!kount-1 do begin
    in=sdd[i]
    sd_to_gbt,in,out
    line_id=out.line_id         ; SDFITS line_id for proper ID below 
    out.line_id[*]=''           ; clear out line_id to be filled by rxidrec(VEGAS)
    str_line_id = strtrim(string(line_id))
    out.proc_id=byte(str_line_id)         ; save SDFITS line_id 
    date_obs=out.date
    restFreq=out.rest_freq/1.d+6 ; rest frequency in MHz
;   ID spectral line
    if ~KeyWord_Set(noid) then begin
      case !config of  ; pick either ACS or VEGAS
                      6: rxidrecVEGAS,restFreq,line_id,catalog
                   else: rxidrec,line_id,date_obs
      endcase
    endif
    out.line_id=line_id 
    !b[0]=out
;   add the l_gal,b_gal to the TMBIDL header
    ra2lb,gl,gb & !b[0].l_gal=gl & !b[0].b_gal=gb 
    out=!b[0]
    writeu,!onunit,out
    !kon=!kon+1                 ; increment number of ONLINE data records
endfor
;
!recmax=!kon                    ; set maximum record number for gbt data
;
print
print,'Made ONLINE data file '+!online_data+' with '+$
      fstring(!kon,'(i5)')+' records'
print
; 
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
online
;
return
end
