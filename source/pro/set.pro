pro set,help=help
;+
;NAME:
;  SET
;
;            =====================
;            Syntax: set,help=help
;            =====================
;
;   set   Sets parameter values for selection filtering of data type.
;   ---   This procedure walks you through all the choices.
;
;      => LOOK CAREFULLY AT THE IDL PROMPT WHICH CHANGES
;      => Input strings must NOT be delimited by quotes
;      => '' or ' ' or '*' (NO QUOTES!) return sets wildcard for search 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'set' & return & endif
;
print,'Source Name= no quotes necessary'
src=''
read,src,prompt='Set Source Name: '
!src=strtrim(src,2)
if !src eq "" or !src eq " " then !src='*'
;
print,'Scan Type = ON or OFF'
typ=''
read,typ,prompt='Set Scan Type: '
!typ=strtrim(typ,2)
if !typ eq "" or !typ eq " " then !typ='*'
;
print,'Polarization ID = e.g. LL or RR or XX or YY or LCP or RCP'
pol=''
read,pol,prompt='Set Pol ID: '
!pol=strtrim(pol,2)
if !pol eq "" or !pol eq " " then !pol='*'
;
print,'Line ID = e.g. rx1.1, rx2.2, rx1, rx2, ....'
id=''
read,id,prompt='Set Scan ID: '
!id=strtrim(id,2)
if !id eq "" or !id eq " " then !id='*'
;
print,'Scan # = '
scan=''
read,scan,prompt='Set Scan #:'
!scan=scan
if !scan eq "" or !scan eq " " then !scan='*'
;
tellset
;
return
end
