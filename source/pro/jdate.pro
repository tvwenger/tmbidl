pro jdate,jdate,help=help
;+
; NAME:
;       JDATE
;
;            =============================
;            Syntax: JDATE.jdate,help=help
;            =============================
;
;   JDATE      procedure to return modified Julian Date from !b[0] header
;   -----   
;
;-
; MODIFICATION HISTORY:
;
; V6.1 08feb2011 tmb 
; v7.0 15may2013 tmb added help and !debug 
;      09jul2013 tmb this code *assumes* the 
;                    format is: 2009-04-05T11:48:30.00
;                    which is NOT always the case 
;                    solution proferred here is that
;                    if !b[0].date is NOT in this format
;                    the .pro returns the reduced (MJD)
;                    of the CURRENT SYSTEM TIME
;                    MJD = JD - 2400000.
;                    GBT SDFITS returns MJD
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'jdate' & return & endif
;
obsdate=string(!b[0].date)
;
; test format of date 
;
test=strmid(obsdate,10,1)
if test ne 'T' then begin 
   jdate=systime(/julian,/utc) - 2400000.
   goto,get_out
endif
;
year=long(strmid(obsdate,0,4))
month=long(strmid(obsdate,5,2))
day=long(strmid(obsdate,8,2))
juldate,[year,month,day],jdate
;
get_out:
return
end
