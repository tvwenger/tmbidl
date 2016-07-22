;+
; NAME:
;      BB
;
;   bb.pro   fit polynomial baseline of order !nfit  to data in nregion zones 
;   ------   uses IDL poly_fit.  BBB is *much* better
;
;;             usage: bb,nfit
;                    nfit=order of polynomial
;                         if no argument, nfit set to !nfit
;
; V5.0 July 2007
; modified by tmb 11aug07 for CONTinuum mode
;   RTR  8/08 modified to default to !nfit if no argumemt supplied
;   RTR  8/08 placed rms in global !bfit_rms
;-
pro bb,nfit   ;   nfit is order of the polynomial
;
on_error,!debug ? 0 : 2
compile_opt idl2
@CT_IN
;
if (n_params() ne 1) then begin
                          nfit=!nfit
                          endif
if (n_params() eq 1) then !nfit=nfit
;
copy,0,2                         ;  original data to buffer 2
;
mask,dsig,index                  ;  get index of NREGION mask channels and sigma of yaxis
;
xx=dblarr(n_elements(index))     ; data arrays for fit in double precision 
yy=dblarr(n_elements(index))
;
xx=!xx[index]                
yy=!b[0].data[index]
;
fitcoeffs=ortho_fit(xx,yy,!nfit,cfit,rms)   ;  John Lyon's fitter 
;fitcoeffs=poly_fit(xx,yy,!nfit,/double,status=stat,sigma=fsig)   ; IDL fitter
;
!b[1].data=ortho_poly(!xx,fitcoeffs)    ; John Lyon
;!b[1].data=poly(!xx,fitcoeffs) ; IDL
;
oplot,!xx,!b[1].data,thick=3,color=!cyan
;
ans=' '
read,ans                              ; build in a pause  ans is any string
;
; subtract the baseline model
!b[0].data[0:!nchan-1] = !b[0].data[0:!nchan-1] - !b[1].data[0:!nchan-1]   
;
show
;
mask,dsig
print
print,'RMS in NREGIONs = ', dsig
!bfit_rms=dsig
print
;
if (!zline) then zline
if (!bmark) then bmark
;
@CT_OUT
return
end
