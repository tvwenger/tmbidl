PRO tellgfix,help=help
;+
; NAME:
;       TELLGFIX
;
;            ==========================
;            Syntax: tellgfix,help=help
;            ==========================
;
;   tellgfix  List the current values of the !parinfo[] structure variables.
;   --------  
;             !parinfo[0].parname  = ID string e.g. 'Height_1'
;                        .value    = initial value to start the fit
;                        .fixed    = Boolean:  1 fixed; 0 floats
;                        .comment  = comment string 
;-
; MODIFICATION HISTORY:
; V5.1 TMB 27jul08 
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'tellgfix' & return & endif
;
; fetch the !parinfo[] parameters for !ngauss components
parinfo=!parinfo[0:3*!ngauss-1]
;
print
print,'Current state of Gaussian "!PARINFO[IDX#].parameter_name" is:
print,'Idx# PARNAME  FIXED(=1) VALUE=!A_GAUSS[ ]'
fmt='(i3,a10,1x,i3,1x,f12.3,7x,i3,1x,a)'
for i=0,3*!ngauss-1 do begin    ; print out the PARINFO data for !ngauss components
      print,i,parinfo[i].parname,parinfo[i].fixed,!a_gauss[i], $
            i,parinfo[i].comment, format=fmt
endfor
print
;
return
end
 
