pro bb,nfit,noNrset=noNRset,help=help   ;   nfit is order of the polynomial
;+
; NAME:
;      BB
;
;   bb   Fit order nfit polynomial baseline to NREGION data zones. 
;   --   Uses Lyon's orthofit.pro  Invokes nrset.pro by default.
;        To bypass this either use bbb.pro or set /noNRset keyword. 
;
;   ==========================================
;   SYNTAX:  bb,nfit,noNRset=noNRset,help=help
;   ==========================================
;
;   PARAMETERS: nfit = order of polynomial
;                      if not input uses current !nfit
;
;   KEYWORDS:   help    -  gives this help
;               noNRset -  stops the default automatic
;                          invocation of nregion.pro 
;-
; MODIFICATION HISTORY
; V5.0 July 2007
;   modified by tmb 11aug07 for CONTinuum mode
;   RTR  8/08 modified to default to !nfit if no argumemt supplied
;   RTR  8/08 placed rms in global !bfit_rms
;   DSB  06feb2009 added nrset and noNRset keyword
; V6.0 tmb 24june2009  modified rtr's version to use pause
; V7.0 03may2013 tvw - added /help, !debug
;      20may2013 tmb - reconciled with dsb code 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'bb' & return & endif
@CT_IN
;
; set the number of polynomials
; no input defaults to !nfit 
if n_params() eq 1 then !nfit=nfit
;
; get the nregions unless keyword stops this
if ~keyword_set(noNrset) then nrset
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
;
!b[1].data=ortho_poly(!xx,fitcoeffs)    ; John Lyon
;
oplot,!xx,!b[1].data,thick=3,color=!cyan
;
pause,c_ans,i_ans    ; pause to take a look
;
; subtract the baseline model
!b[0].data[0:!nchan-1] = !b[0].data[0:!nchan-1] - !b[1].data[0:!nchan-1]   
;
show
;
mask,dsig
print
print, !nfit,dsig,format='("For NFIT =",i3,"     RMS in NREGIONs =",f7.4)'
print
; put rms in global
!bfit_rms=dsig
;
if !zline then zline
if !bmark then bmark
;
@CT_OUT
return
end
