pro rfi,help=help
;+
; NAME:
;       RFI
;
;            =====================
;            Syntax: rfi,help=help
;            =====================
;
;
;  rfi    Replaces spectral region contanimated with RFI with values gotten
;  ---    from a baseline fit. 
;         Prompts to define a *single*  RFI zone via MRSET,2
;         Spectral values are replaced for *all* channels *outside* the NREGIONs
;         that are also*inside* the plotted display.
;
;         By default nfit=9.
;
;             Syntax: rfi
;             ===========
;-
; V5.0  July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'rfi' & return & endif
@CT_IN
;
bmark=!bmark
!bmark=1                         ; force NREGION display
cursor=!cursor                   
!cursor=1                        ; force curson to be on
!nfit=9                          ; set nfit=9
;
print,'Bracket the RFI with two clicks:'
mrset,2
;
copy,0,2                         ; original data to buffer 2
;
mask,dsig,index                  ; get index of NREGION mask & sigma of yaxis
;
nindx=n_elements(index)
xx=dblarr(nindx)                 ; data arrays for fit in double precision 
yy=dblarr(nindx)
;
xx=!xx[index]                
yy=!b[0].data[index]
;
fitcoeffs=ortho_fit(xx,yy,!nfit,cfit,rms)   ;  John Lyon's fitter 
;
!b[1].data=ortho_poly(!xx,fitcoeffs)        ;  fitted polynomial in buffer 1
;                                  
oplot,!xx,!b[1].data,thick=3,color=!cyan    ;  overplot the fit 
;
print,'<CR> to return'
ans=get_kbrd(1)                             ;  the pause that refreshes
;
;  now replace RFI with baseline values
;
xmin = !nregion[1] & xmax = !nregion[2] &
!b[0].data[xmin:xmax]=!b[1].data[xmin:xmax] 
;
xx
;
!bmark=bmark       ;  restore entry bmark state
!cursor=cursor     ;  restore entry cursor state
;
@CT_OUT
return
end

