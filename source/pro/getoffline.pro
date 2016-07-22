pro getoffline,rec,help=help   ; must input the record number 
;+
; NAME:
;       GETOFFLINE 
;
;            ===================================
;            Syntax: getoffline, rec_#,help=help
;            ===================================
;
;   getoffline   Fills buffer 0 with data record from OFFLINE data file
;   ----------
;-                
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if (n_params() eq 0) or keyword_set(help) then begin & get_help,'getoffline' & return & endif
;
openr,!offunit,!offline_data
record = assoc(!offunit,!rec)    ; !rec is one {gbt_data} structure for the pattern
;
if ( rec gt !koff-1 ) then begin
   print,'EOF on OFFLINE data file'
   close,!offunit
   return
   endif
;
!b[0]=record[rec]  ; copy record = rec into buffer 0
;
close,!offunit
;                        
return
end
