;+
;   init_data_bozo.pro   Package setup for Arecibo.  Hardwired for 3He.
;   ------------------   Sets parameters of the IDL GBT data structure 
; 
;
;   USEAGE:  init_data,datafile   input the name of raw telescope data file
;                                 'datafile' must be fully qualified
;                                 file name
;-
pro init_data_bozo,fname
;
;
if (n_params() eq 0) then fname=!datafile
;
find_file,fname   ; does this file exist?
;
!datafile=fname
;
get_lun,lun
openr,lun,!datafile
!dataunit=lun
;
close,lun
;
!kount=0L   ; who knows how many elements are in this data file?
;
!data_points=1024L   ; hardwire spectrum size for Arecibo 3He configuration
;
!nchan=!data_points
;
return
end


