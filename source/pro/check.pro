pro check,help=help
;+
; NAME:
;       CHECK
;
;            =======================
;            Syntax: check,help=help
;            =======================
;
;   check  Take a quick look at all the subcorrelators with appropriate flags.
;   -----   UPDATEs and SELECTS records for current source since last check 
;           and executes the RLOOK command.  
;
;           Invokes 'update'
;
;   ==> THIS IS A GBT REAL TIME DATA ACCESS PROCEDURE <==
;                  
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'check' & return & endif
;
update
src=string(!b[0].source)
!src=strtrim(src,2)
last_scan=!b[0].scan_num
scanmax=last_scan
scanmin=!last_look+1
if (scanmin ge scanmax) then scanmin=scanmax-1
if (scanmin lt 0) then scanmin=0
;
!scanmin=scanmin & !scanmax=scanmax &
;
!typ='ON'
qlook
;
return
end


