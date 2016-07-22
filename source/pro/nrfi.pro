pro nrfi,nfit,help=help
;+
; NAME:
;       NRFI
;
;            ============================
;            Syntax: nrfi, nfit,help=help
;            ============================
;
;  nrfi    Replaces spectral region contanimated with RFI with values gotten
;  ----    from a baseline fit. Must define RFI zone via either NRSET or MRSET.
;          MRSET is recommended.
;          Spectral values are replaced for *everything* that is both 
;          *outside* the NREGIONs and also *inside* the plotted display.
;
;          Prompts if nfit, the order of the baseline fit, not given.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
;
if (n_params() ne 1) or keyword_set(help) then begin & get_help,'nrfi' & return & endif
@CT_IN
;
!nfit=nfit
;
bmark=!bmark
!bmark=1            ; force NREGION display
;
copy,0,2                         ;  original data to buffer 2
;
mask,dsig,index                  ;  get index of NREGION mask channels and sigma of yaxis
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
;  now replace RFI with baseline values
;
xmin = !x.crange[0] & xmax = !x.crange[1] & 
!b[0].data[xmin:xmax]=!b[1].data[xmin:xmax]
;
for i=0,nindx-1 do begin                
      ch=index[i]
      !b[0].data[ch]=!b[2].data[ch]
      endfor
;
xx
;
!bmark=bmark       ;  restore entry bmark state
;
@CT_OUT
return
end

