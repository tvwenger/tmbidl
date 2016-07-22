PRO gfix,fixid,value,help=help
;+
; NAME:
;       GFIX
;
;            ==================================
;            Syntax: gfix,fixid,value,help=help
;            ==================================
;
;   gfix  Set a Gaussian parameter to be fixed to a specific value
;   ----  during the Gaussian fit made by MPCURVEFIT.
;          
;         If no parameters passed shows current state of fit variables:
;         FIXED (1) or FREE (0) and the current VALUE.
;         
;         VALUE is either fixed value (1) or starting value (0) for
;         fit. 
;
;       ==> Assumes that the Gaussian fit parameters, !n_gauss,!a_gauss, 
;           have already been established via, say, 'gg'
;-
; MODIFICATION HISTORY:
; V5.1 TMB 27jul08 
; V7.0 3may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'gfix' & return & endif
;
if n_params(0) ne 2 then begin
   parinfo=!parinfo[0:3*!ngauss-1]
   print
   print,'Current state of Gaussian fit parameters PARINFO  is:'
   print,'Idx#       ID  FIXED(=1) VALUE=!A_GAUSS[ ]'
   fmt='(i3,a10,1x,i3,1x,f12.3,7x,i3,1x,a)'
   for i=0,3*!ngauss-1 do begin    ; print out the PARINFO data for !ngauss components
       print,i,parinfo[i].parname,parinfo[i].fixed,!a_gauss[i], $
             i,parinfo[i].comment, format=fmt
   endfor
   print
   print,'Syntax: gfix,fixid,value  <== fixid = Idx# in above list'
   print,'========================'
   print
   return
end
;
n=fixid
if n lt 0 then begin
   print,'Invalid parameter ID number: must be integer ge 0'
   return
endif
;
; Set the n-th Gaussian parameter FIXED to VALUE
!parinfo[n].fixed=1
!a_gauss[n]=value
;
return
end
 
