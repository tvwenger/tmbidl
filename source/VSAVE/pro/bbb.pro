;+
; NAME:
;      BBB
;
;   bbb.pro   Fit polynomial baseline of order nfit to data in nregion zones 
;   -------   written by J.G. Lyon, Feb. 2004
;
;             bbb is better than bb
;
;             usage: bbb,nfit
;                    nfit=order of polynomial
;                         if no argument, nfit set to !nfit
;
;   V5.0 July 2007  not sure what this does anymore!  only mod was CT stuff
;   RTR  8/08 modified to default to !nfit in no argumemt supplied
;   RTR  8/08 placed rms in global !bfit_rms
;-
pro bbb,nfit   ;   nfit is order of the polynomial
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
copy,0,1
copy,0,2                         ;  original data to buffer2 1 and 2
;
mask,dsig,index                  ;  get index of NREGION mask channels and sigma of yaxis
;
xx=dblarr(n_elements(index))     ; data arrays for fit in double precision 
yy=dblarr(n_elements(index))
;
xx=!xx[index]                
yy=!b[0].data[index]
;
fitcoeffs=ortho_fit(xx,yy,!nfit,cfit,rms)   ; baseline fit routine
                                       ; the IDL supplied ones are not all that robust 
;
!b[1].data=ortho_poly(!xx,fitcoeffs)
;
clr=!cyan
get_clr,clr        ; determine if BW or CLR plot
oplot,!xx,!b[1].data,thick=3,color=clr
;
ans=' '
read,ans                               ; build in a pause  ans is any string
;
!b[0].data = !b[0].data - !b[1].data   ; subtract the baseline model
show
copy,0,3                             ; buffer 3 has the result too
;
mask,dsig
print
;print,'RMS in NREGIONs = ', rms(nfit) ; rtr fix? this produces an arror
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


