pro make_ONLINE,recs_per_scan,help=help,noid=noid
;+
; NAME:
;      MAKE_ONLINE
;
;            =====================================================
;            Syntax: make_ONLINE,recs_per_scan,help=help,noid=noid
;            =====================================================
;
;   make_ONLINE  Create ONLINE data file using the {TMBIDL_DATA_V5.0} format.
;   -----------  New data can be appended to this file via UPDATE command.
;
;                !kon  counts number of ONLINE data records currently in file
;                recs_per_scan is the number of subcorrelators per scan#
;
;           ==>  !datafile MUST BE defined by INIT_DATA  <==   
;                ====================================   
;           ==>  Execute INIT_DATA BEFORE make_ONLINE    <==     
;                ====================================
;
;                This  INPUT data is an SDFITS filled data file.  
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
; v8.0 19jun2015 tvw/tme - v8.0 for VEGAS
;
;;-
;       
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'make_ONLINE' & return & endif
;
; DO YOU WANT TO MAKE AN ONLINE DATA FILE?
print,'Current ONLINE file definition is:'
print,'ONLINE file will be= ' + !online_data, ' LUN= ' + fstring(!dataunit,'(I3)')
print
print,'Do you want to make the ONLINE file? (y/n) '
ans=get_kbrd(1)
if ans eq 'n' then begin
       !online_data=''
       print
       print,'*************************************************'
       print,'There is NO ONLINE data file!'
       print,'Please ATTACH one and issue ONLINE command.'
       print,'*************************************************'
       print
;      Must initialize package even if no ONLINE file created
;      !data_points, !nchan, !recs_per_scan
;
       num_points=0
       print,'Input # data points per spectrum'
       read,num_points,prompt='Input # data points per spectrum:'
       !data_points=num_points & !nchan=!data_points &
       print,'==> Spectra have '+fstring(!data_points,'(I6)')+' data points'
       recs_per_scan=0
       print,'Input # records per scan, i.e. # subcorrelators in configuration'
       read,recs_per_scan,prompt='Input # records per scan: '
       !recs_per_scan=recs_per_scan
       print,'==> Each Scan makes '+fstring(!recs_per_scan,'(I3)')+' spectra'
;
       return
endif
;

;
if n_params() eq 0 then begin
   recs_per_scan=0
   print,'Input # records per scan, i.e. # subcorrelators in configuration'
   read,recs_per_scan,prompt='Input # records per scan: '
   !recs_per_scan=recs_per_scan
endif
;
print,'==> Each Scan makes '+fstring(!recs_per_scan,'(I3)')+' spectra'
;
; Read the SDFITS data file 
;
openr,lun,!datafile,/get_lun
;
sdd = mrdfits(lun, 1, hdr, status=status) ; makes SDFITS data structure array
free_lun,lun
;
!kount=n_elements(sdd)
;
print
print,'Constructing ONLINE data file from SDFITS file ==> ' + !datafile
print,!datafile + ' Contains ' + fstring(!kount,'(i5)') + ' records '
print
;
;  create the ONLINE data file from an existing SDFITS file 
;
openw,!onunit,!online_data      ;  use default value for ONLINE data file name
;
out={tmbidl_data}                  ;  convert SDFITS format to GBT format
;
if !config eq 6 then begin ; if VEGAS then load rest frequencies and ID labels
   catalogFile='../catalogs/rrls.catalog'
   catalog=' ' & read_table,catalogFile,data=catalog,/silent
endif 
;
for i=0,(!kount-1) do begin
    in=sdd[i]
    sd_to_gbt,in,out
    line_id=out.line_id         ; set line_id using subcorrelator band flag
    out.line_id[*]=''           ; clear out line_id to be filled by rxidrec(VEGAS)
    str_line_id = strtrim(string(line_id))
    out.proc_id=byte(str_line_id)         ; save SDFITS line_id 
    date_obs=in.date_obs        ; need date to calculate JD for sampler mapping
    restFreq=out.rest_freq/1.d+6 ; rest frequency in MHz
;   ID spectral line
    if ~KeyWord_Set(noid) then begin
      case !config of  ; pick either ACS or VEGAS
                      6: rxidrecVEGAS,restFreq,line_id,catalog
                   else: rxidrec,line_id,date_obs
      endcase
   endif
    out.line_id=line_id 
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
return
end







