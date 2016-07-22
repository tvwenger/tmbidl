pro setns,help=help
;+
; NAME:
;       SETNS
;
;            =======================
;            Syntax: setns,help=help
;            =======================
;
;   setns   Sets parameter values for selection filtering of data type.
;   -----   This procedure walks you through all the choices.
;       ==> Tailored for selecting on the NSAVE data file which
;           normally contains processed data.
;
;      ===> LOOK CAREFULLY AT THE IDL PROMPT WHICH CHANGES.
;      ===> Input strings must NOT be delimited by quotes.
;      ===> '' or ' ' or '*' (NO QUOTES!) return sets wildcard for search. 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setns' & return & endif
;
print,'Source Name= no quotes necessary'
src=''
read,src,prompt='Set Source Name: '
!src=strtrim(src,2)
if !src eq "" or !src eq " " then !src='*'
;
print,'Data Type = e.g. JN04_D1 or EPAVE etc'
typ=''
read,typ,prompt='Set Data Type: '
!typ=strtrim(typ,2)
if !typ eq "" or !typ eq " " then !typ='*'
;
print,'Line ID = e.g. HE3, A91, B115, A92, HE++, ...'
id=''
read,id,prompt='Set Line ID: '
!id=strtrim(id,2)
if!id eq "" or !id eq " " then !id='*'
;
print,'Polarization ID = e.g. LL or RR'
pol=''
read,pol,prompt='Set Pol ID: '
!pol=strtrim(pol,2)
if !pol eq "" or !pol eq " " then !pol='*'
;
print
print,'Selecting: Source= '+!src+'  Type= '+!typ+'  ID= '+!id+' Pol= '+!pol
;
return
end
