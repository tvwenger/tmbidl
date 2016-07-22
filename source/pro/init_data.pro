pro init_data,fname,help=help
;+
; NAME:
;       INIT_DATA
;
;            =====================================================
;            Syntax: init_data, fully_qualified_filename,help=help
;            =====================================================
;
;   init_data   Reads input SDFITS filled data file 'fully_qualified_filename'
;   ---------   Sets parameters of the {TMBIDL_DATA_V5.0} data structure.
; 
;               Input the name of the SDD data file. 
;               Default is !datafile.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'init_data' & return & endif
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
sdd = mrdfits(lun, 1, hdr, status=status) ; makes data structure array
free_lun,lun
;
!kount=n_elements(sdd)
;
print
print,'Scanning contents of SDFITS file ==> ' + !datafile
print,!datafile + ' Contains ' + fstring(!kount,'(i5)') + ' records '
print
;
!data_points=0L
for i=0,!kount-1 do begin
      nchan=n_elements(sdd[i].data)
      if (!data_points lt nchan) then begin
          !data_points=nchan
          print,'Spectrum has '+fstring(nchan,'(I6)')+' data points at record '$
                +fstring(i,'(I6)')
                                      endif
end
;
!nchan=!data_points
;
return
end


