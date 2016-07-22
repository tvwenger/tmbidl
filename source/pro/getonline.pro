pro getonline,rec,help=help   ; must input the record number 
;+
; NAME:
;       GETONLINE
;
;            ==================================
;            Syntax: getonline, rec_#,help=help
;            ==================================
;
;   getonline   Fills buffer 0 with data record from ONLINE data file.
;   ---------
;-                  
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if (n_params() eq 0) or keyword_set(help) then begin & get_help,'getonline' & return & endif
;
openr,!onunit,!online_data
record = assoc(!onunit,!rec)    ; !rec is one {gbt_data} structure for the pattern
;
if ( rec gt !kon-1 ) then begin
   print,'EOF on ONLINE data file'
   close,!onunit
   return
   endif
;
!b[0]=record[rec]  ; copy record = rec into buffer 0
;
close,!onunit
;                        
return
end
