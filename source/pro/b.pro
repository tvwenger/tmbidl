pro b,disp=disp,help=help       ;   !nfit is order of the polynomial
;+
; NAME:
;      B
;
;   b   Fit order nfit polynomial baseline to NREGION data zones.
;   -   Does the fit automatically, so all relevant parameters must be set.
;       This is a Batch Mode procedure by default so it shows neither the 
;       baseline model nor the baseline subtracted spectrum.
;
;   =============================
;   SYNTAX: b,disp=disp,help=help
;   =============================
;
;   KEYWORDS:  help - if set gives this help
;              disp - if set shows the baseline subtracted spectrum.
;
;-
; MODIFICATION HISTORY
;  V5.0 July 2007
;      27 Dec 11 (dsb) put rms in global
;      28 Dec 11 (dsb) add display options
; V7.0 3may2013 tvw - added /help, !debug
;     20may2013 tmb - merged dsb code into v7.0 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'b' & return & endif
@CT_IN
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
; show fit
if keyword_set(disp) then begin
   oplot,!xx,!b[1].data,thick=3,color=!cyan & pause,cans,ians & endif
;
; subtract the baseline model
!b[0].data[0:!nchan-1] = !b[0].data[0:!nchan-1] - !b[1].data[0:!nchan-1]   
;
; show if keyword set
if keyword_set(disp) then show
;
mask,dsig
!bfit_rms=dsig
;
if !batch eq 0 then begin
    print
    print, !nfit,dsig,format='("For NFIT =",i3,"     RMS in NREGIONs =",f7.4)'
    print
endif
;
@CT_OUT
return
end
