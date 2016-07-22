pro init_tmbidl_data,fname,help=help
;+
; NAME:
;       INIT_TMBIDL_DATA
;
;            ====================================================
;            Syntax: init_tmbidl_data, 'full_file_name',help=help
;            ====================================================
;
;   init_tmbidl_data   Reads input 'full_file_name' and 
;   ----------------   figures out number of channels in the TMBIDL 
;                      data structure !data_points then defines
;                      the {tmbidl_data} data structure.
;   
;   Default is current ONLINE data file.
;   Recomend that the input file be ONLINE data or NSAVE data
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'init_tmbidl_data' & return & endif
;
;if n_params() eq 0 then fname=!datafile
if n_params() eq 0 then fname=!online_data
;
find_file,fname   ; does this file exist?
;
!datafile=fname
;
print
print,'Scanning contents file ==> ' + !datafile
print
;
@tmbidl_header_v5.0   ; the header
;
get_lun,lun
openr,lun,!datafile
!dataunit=lun
readu,lun,tmb
!data_points=tmb.data_points
print,'First record contains '+fstring(!data_points,'(i8)')+' data points'
close,lun
;
;  Now that we know the number of data points define the complete data structure
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
; Now figure out the total number of records in !datafile 
; checking to see if number of data points changes from first record
;
openr,lun,!datafile
data_points=!data_points      ; first record has !data_points
!kount=0L
while EOF(lun) ne 1 do begin
      readu,lun,tmb
      nchan=tmb.data_points
      if data_points ne nchan then begin
         data_points=nchan
         print,'Spectrum has '+fstring(nchan,'(I6)')+' data points at record '$
               +fstring(!kount,'(I6)')
                                      endif
      !kount=!kount+1L
end
;
!nchan=!data_points
free_lun,lun
;
print
print,!datafile + ' Contains ' + fstring(!kount,'(i5)') + ' records '
print
;
return
end


