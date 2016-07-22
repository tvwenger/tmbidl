pro bbb,nfit,noPause=noPause,help=help   ;   nfit is order of the polynomial
;+
; NAME:
;      BBB
;
;   bbb   Fit order nfit polynomial baseline to NREGION data zones .
;   ---   Assumes that the NREGIONS are already set. If not use
;         nrset.pro or bb.pro 
;         Uses orthofit.pro by J.G. Lyon, Feb. 2004.
;
;   ==========================================
;   SYNTAX: bbb,nfit,noPause=noPause,help=help
;   ==========================================
;  
;   PARAMETERS: nfit = order of polynomial
;                      if not input uses current !nfit
;
;   KEYWORDS:   help    -  gives this help
;               noPause -  stops the pause before 
;                          baseline model subtraction
;
;-
; MODIFICATION hISTORY
;   V5.0 July 2007   not sure what this does anymore!  only mod was CT stuff
;   v5.1 tmb 22aug08 fixed rms() bug.
; V7.0 3may2013 tvw - added /help, !debug
;     20may2013 tmb - cleaned up code and improved documentation 
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'bbb' & return & endif
@CT_IN
;
; test if NREGIONs are set 
if !nrset eq 0 then begin 
          print,'ERROR:  Must set NREGIONs !!!' & return & endif
; set the number of polynomials
; no input defaults to !nfit 
if n_params() eq 1 then !nfit=nfit
;
copy,0,1
copy,0,2                     ;  original data to buffer2 1 and 2
;
mask,dsig,index              ;  get index of NREGION mask channels and sigma of yaxis
;
xx=dblarr(n_elements(index)) ; data arrays for fit in double precision 
yy=dblarr(n_elements(index))
;
xx=!xx[index]                
yy=!b[0].data[index]
;
fitcoeffs=ortho_fit(xx,yy,!nfit,cfit,rms)   ; baseline fit routine by John Lyon 
;
!b[1].data=ortho_poly(!xx,fitcoeffs)
;
clr=!cyan
get_clr,clr        ; determine if BW or CLR plot
oplot,!xx,!b[1].data,thick=3,color=clr
;
if ~keyword_set(noPause) then pause,ans
;
!b[0].data = !b[0].data - !b[1].data   ; subtract the baseline model
show
copy,0,3                             ; buffer 3 has the result too
;
mask,dsig
print
print, !nfit,dsig,format='("For NFIT =",i3,"     RMS in NREGIONs =",f7.4)'
print
;
if !zline then zline
if !bmark then bmark
;
@CT_OUT
return
end


