pro bsearch,nmax,help=help
;+
; NAME:
;      BSEARCH
;      bsearch,nmax,help=help
;
;   bsearch.pro   Fit baselines with polynomials of order 0 to 100
;   -----------   Pop up graphics window and plot RMS of fit vs
;                 polynomial order
;
;                 nmax is maximum order to plot -- nmax=100 is default
;
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'bsearch' & return & endif
;
window,1,title='Baseline Search Plot',xsize=1050,ysize=600
;
nfit=100        ; Search for best baseline up to nfit=100   !!
;
if (n_params() eq 0) then nmax=nfit
;
copy,0,2                         ;  original data to buffer 2
;
mask,dsig,index                  ;  get index of NREGION mask channels and sigma of yaxis
;
xx=dblarr(n_elements(index))     ; data arrays for fit in double precision 
yy=dblarr(n_elements(index))
xnfit=dindgen(nfit)
rms  =dblarr(nfit)
;
xx=!xx[index]                
yy=!b[0].data[index]
;
fitcoeffs=ortho_fit(xx,yy,nfit,cfit,rms)   ; baseline fit routine
;
print
print,'RMS in NREGIONs before any fit = ', dsig,$
      ' for ',n_elements(index),' channels',$
      format='(a,f12.6,a,i5,a)'
print
;
xmin=0.  & xmax=float(nmax)-1 &
ymin=min(rms[0:nmax-1])  &  ymax=1.1*dsig  &
;
plot,xnfit,rms,/xstyle,/ystyle,title='RMS of Fit vs Order of Fit',$
     xtitle='Order of Fit',yrange=[ymin,ymax],$
     ytitle='RMS of Fit',  xrange=[xmin,xmax]
;
hline,dsig
;
for i=0,nmax-1 do print,i,rms[i],format='(i4,1x,d12.6)'
;
print,'Enter "q" to return to normal graphics'
ans=get_kbrd(1)
if (ans eq 'q') then wreset
;
return
end
