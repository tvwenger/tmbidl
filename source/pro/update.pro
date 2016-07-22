pro update,help=help,noid=noid
;+
; NAME:
;       UPDATE
;
;            ==================================
;            Syntax: update,help=help,noid=noid
;            ==================================
;
;   update   Update ONLINE data file by appending new data to existing
;   ------   ONLINE data file.  INPUT data is from SDFITS data file.
;
;            Assumes SDFITS datafile is being updated: i.e. you are
;            observing at the GBT and continually filling the data.
;
;            Translates and appends new data to ONLINE data file. 
;
;            SDFITS !datafile defined by  INIT_DATA or MAKE_DATA
;                                         ---------    ---------
;            !kon  counts number of ONLINE data records currently in
;            file
;
;     KEYWORDS     help   - gives this help
;                  noid   - if set supresses Line ID assignment
;
; =========> ASSUMES SDFITS FILE IS CREATED WITH MODE=AVG <=============
;      =========> ASSUMES THIS IS SPECTRAL LINE DATA <=============
;
;-
; V5.0 July 2007
; V6.0 June 2009 tmb added l,b conversion 
; V6.1 Jan  2012 tmb tweaked to pass observing date to rxidrec for JD
;                    filter to account for GBT sampler mapping change
; v7.0 May2013 tmb/tvw added keyword help and new error handling
;      23jun2013 tmb - fixed mrdfits big/little endian bug
; v8.0 12jul2014 tvw/tmb - update for VEGAS v8.0
;
;-
;       
on_error,!debug ? 0 : 2
compile_opt idl2   
;
; Read the SDFITS data file 
;
get_lun,lun
; force big endian
openr,lun,!datafile,byteorder,/swap_if_little_endian
;
if keyword_set(help) then begin & get_help,'update' & return & endif
;
sdd = mrdfits(lun, 1, hdr, status=status) ; makes SDFITS data structure array
kount=n_elements(sdd)                     ; total number of records in file 
free_lun,lun
;
print
print,'Updating ONLINE data file from SDFITS file ==> ' + !datafile
print,!datafile + ' now contains ' + fstring(kount,'(i5)') + ' records '
xx=kount-!kon
print,'There are ' + fstring(xx,'(i5)') + ' more records since last update'
print
;
;  update the ONLINE data file from an existing SDFITS file 
;
openu,!onunit,!online_data,/append ;  append to ONLINE data file 
;
out=!blkrec  ;  convert SDFITS format to {tmbidl_data} format
;
if !config eq 6 then begin ; if VEGAS then load rest frequencies and ID labels
   catalogFile='../catalogs/rrls.catalog'
   catalog=' ' & read_table,catalogFile,data=catalog,/silent
endif 
;
rec_no=0L
for i=!kon,(kount-1) do begin   ;  start at beginning of the new data
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
    !b[0]=out
;   add the l_gal,b_gal to the TMBIDL header
    ra2lb,gl,gb & !b[0].l_gal=gl & !b[0].b_gal=gb 
    out=!b[0]
    writeu,!onunit,out
    rec_no=rec_no+1             ; increment number of ONLINE data records
endfor
;
!recmax=!kon+rec_no             ; set maximum record number for gbt data
;print,!recmax,!kon
!kon=!recmax 
;
close,!onunit
;
copy,0,10                       ; update the maximum scan number 
get,!kon-1
last_scan=!b[0].scan_num
copy,10,0
!scanmax=last_scan
;
print,'Updated ONLINE data file ' + !online_data 
print
online
; 
return
end







