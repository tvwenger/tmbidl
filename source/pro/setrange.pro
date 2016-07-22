pro setrange,scanmin,scanmax,help=help
;+
; NAME:
;       SETRANGE
;
;       ============================================
;       SYNAX: setrange,scanmin,scanmax,help=help
;       ============================================
;
;   setrange   Set the scan range for a SELECT search of 
;   --------   ONLINE/OFFLINE data file. 
;              If no input, prompts for !scanmin,!scanmax
;
;   KEYWORDS:  /help - gives this help 
;
;-
;  V5.0 July 2007
;  V6.1 Sept 2009 tmb fixed bug if ONLINE or OFFLINE file is an NSAVE
;                     file which may have existing, but empty,
;                     records. 
;                 tmb remains confused about all this....
;       29jan2010 tmb attains enlightenment bug fixed
;       06jul2012 tvw checks for highest scan number in records, instead
;                     assuming last record is the highest scan
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setrange' & return & endif
;
;  find the last scan number in the ONLINE/OFFLINE data file
;
copy,0,10
;
checkmax=0
for k=0,!kount-1 do begin 
   get,k
   if !b[0].scan_num gt checkmax then checkmax=!b[0].scan_num
endfor
!last_scan=checkmax
;
; get,!kount-1
; !last_scan=!b[0].scan_num
;
if !last_scan eq 0 then begin
   print, "BEWARE!!! Last scan# in file is ZERO -- NSAVE file assumed!!!"
   !last_scan = !nsave_max - 1
   scanmax=!last_scan
endif
;
copy,10,0
;
if n_params() eq 0 then begin
   !scanmin=0 & !scanmax=!last_scan 
   print,'Select scan range for searches is: '$
         +fstring(!scanmin,'(i12)')+' to '+fstring(!scanmax,'(i12)')
   print,'Syntax: setrange,min_scan#,max_scan#'
   return
endif
;
if n_params() eq 1 then scanmax=!last_scan
;
if scanmax gt !last_scan then scanmax=!last_scan
if scanmin lt 0 then scanmin=0
;
!scanmin=scanmin & !scanmax=scanmax 
;
;  ARECIBO SCAN NUMBERS ARE REALLY, REALLY BIG!
;
print,'Select scan range for searches is: '$
      +fstring(!scanmin,'(i12)')+' to '+fstring(!scanmax,'(i12)')
;
return
end

