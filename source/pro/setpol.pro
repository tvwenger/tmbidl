pro setpol,pol,help=help
;+
; NAME:
;       SETPOL
;
;            ===========================================
;            Syntax: setpol, 'polalization_ID',help=help
;            ===========================================
;
;   setpol   Sets polarization for a SELECT search of ONLINE/OFFLINE data.
;   ------   If pol value not passed, prompts for string.
;   Syntax:  setpol,"LCP" <-- must pass a string "*" is wildcard 
;                    RCP
;
;            Migrating to proper Stokes:  LL and RR 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setpol' & return & endif
;
if n_params() eq 0 then begin
   print,'no quotes needed; <CR> means wildcard' 
   print
   pol=' '
   read,pol,prompt='Input Polarization: '
endif
;
!pol=strtrim(pol,2)
if !pol eq "" or !pol eq " " then !pol='*'
;
print,'Polarization for searches is: ' + !pol
;
return
end
