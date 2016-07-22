pro date,src,date,time,help=help
;+
; NAME:
;      DATE
;
;   date   Prints information on date and time of an observation
;   ----   based on !b[0].date value.
;          N.B. these data passed as strings by SDFITS
;
;          Syntax: date,src,date,time,help=help
;          ====================================
;
;          RETURNS:  Source, Date, Time as strings       
;          ---------------------------------------
;
; V5.0 July 2007 TMB modified to return source, date, time
;                    and added !batch mode trap for print
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'date' & return & endif
;
src=strtrim(string(!b[0].source),2)             ; source name
src=string(!b[0].source)                        ; source name
xx=strtrim(string(!b[0].date),2)         
date=strmid(xx,0,10)                            ; date of observation    
time=strmid(xx,10,13)                           ; time of observation
;
if not !batch then begin
   print
   print,src,date,time, format='(a8,1x,a,1x,a)'
   print
endif
;
return
end
