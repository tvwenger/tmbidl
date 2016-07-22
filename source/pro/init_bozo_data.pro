pro init_bozo_data,fname,help=help
;+
;   init_bozo_data.pro   Reads input Arecibo ONLINE data file
;   ------------------   Figures out number of channels in the TMBIDL 
;                        data structure !data_points then defines
;                        the {gbt_data} data structure
; 
;
;   USEAGE:  init_bozo_data,datafile,help=help   Arecibo ONLINE data file 
;                           'datafile' must be fully qualified file
;                           name
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
;
if keyword_set(help) then begin & get_help,'init_bozo_data' & return & endif
;
if (n_params() eq 0) then fname=!datafile
;
find_file,fname   ; does this file exist?
;
!datafile=fname
;
print
print,'Scanning contents of Arecibo ONLINE file ==> ' + !datafile
print
;
@tmb_data         ; the {gbt_data} structure without the data array 
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
tmb=create_struct(tmb,'data',fltarr(!data_points))
;
; Now figure out the total number of records in !datafile 
; checking to see if number of data points changes from first record
;
openr,lun,!datafile
data_points=!data_points      ; first record has !data_points
!kount=0L
while (not EOF(lun)) do begin
      readu,lun,tmb
      nchan=tmb.data_points
      if (data_points ne nchan) then begin
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


