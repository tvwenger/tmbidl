pro setscan,scan,help=help
;+
; NAME:
;       SETSCAN
;
;            ===================================
;            Syntax: setscan, 'scan_#',help=help
;            ===================================
;
;   setscan   Set the scan number for a SELECT search of ONLINE/OFFLINE
;   -------   datafile.  If no input, prompts for scan #.
;
;    Syntax:  setscan,'1234'   <== sets !scan=1234  ' ' needed
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setscan' & return & endif
;
if n_params() eq 0 then begin
   print,'no quotes needed: <CR> means wildcard'
   print
   scan=' '
   read,scan,prompt='Input Scan #: '
endif
;
!scan=strtrim(scan,2)
if !scan eq "" or !scan eq " " then !scan='*'
;
print,'Scan Number for searches is: ' + !scan
;
return
end

