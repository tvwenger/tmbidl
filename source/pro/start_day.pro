pro start_day,day,help=help
;+
; NAME:
;       START_DAY
;
;            ==================================
;            Syntax: start_day, day_#,help=help
;            ==================================
;
;
;   start_day   Initialize a daily average setup.
;   ---------   If argument is omitted it will prompt.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'start_day' & return & endif
;
if n_params() eq 0 then begin
   print,'no quotes needed' 
   print
   day=' '
   read,day,prompt='What day is this? (format D1, D2, etc.): '
endif
;
day=strtrim(day,2)
len=strlen(day)-1
!data_type=byte('    ')
!data_type[0:len]=byte(day)
print,'Is data from more than one day included in the input file? (y,n)
ans=get_kbrd(1)
scan1=1           ;   new compile option makes all integers long
scan2=99999999    ; 
scan_range_format='Enter first and last scans for the day (format: start,stop): '  
                  ;   i.e. setrange sets !scanmax,!scanmin which are L
        case ans of
                'y': begin
                     read,scan1,scan2,prompt=scan_range_format
                     end
              else : begin
                     fname=!offline_data
                     if (!online) then fname=!online_data
                     print, 'Processing entire file= '+fname
                     end
        endcase
;
setrange,scan1,scan2
!begin_day_scan=scan1
!end_day_scan=scan2
;
return
end


