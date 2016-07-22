pro info,help=help
;+
; NAME:
;       INFO
;
;            ======================
;            Syntax: info,help=help
;            ======================
;
;  info     Print information for !b[0] contents.
;  ----     Useful for debugging.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'info' & return & endif
;
fmt1='(a12,1x,a22,f6.1,1x,a5,1x,a3,1x,i5,1x,a3)'
;blank_sky     07 42 16.2  +40 37 60   0.0    rx1.1  RCP  444   String
hdr=' Source          R.A.        Dec.    Vel   Rx   Pol Scan#  Type'
;
sname=strmid(!b[0].source,0,12)             ; truncate input 16 char string to 12
sradec=adstring(!b[0].ra,!b[0].dec,0)  ; 22 char string which is inefficient

scan=!b[0].scan_num                         ; GBT scan number
vel=!b[0].vel                               ; source velocity
rxno=strtrim(string(!b[0].line_id),2)         ; 'receiver' # via line_id 
pol=strtrim(string(!b[0].pol_id),2)         ; receiver polarization
styp=string(!b[0].scan_type)                ; fetch scan_type
;
if (!flag) then print,hdr
print,sname,sradec,vel,rxno,pol,scan,styp,$
      FORMAT=fmt1
;
return
end
