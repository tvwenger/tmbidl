pro fslide,help=help
;+
; NAME:
;       FSLIDE
;
;   fslide  Slides and flips REF spectrum: uses SDFITS freqoff value.
;   ------  RESHOWs atop SIG spectrum.
;
;              ========================
;              Syntax: fslide,help=help
;              ========================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'fslide' & return & endif
;
foff=!b[0].freqoff
nmax=!b[0].data_points
bw=!b[0].bw
fracbw=foff/bw
choff=fracbw*nmax
choff=nint(choff)
mask=abs(choff)
;
!b[0].data[0:mask]=0.0
!b[0].data[nmax-mask:nmax-1]=0.0
copy,0,1
copy,0,2
;
data=!b[0].data
!b[2].data=shift(data,choff)
;
;  assume signal data is being displayed
copy,2,0
scale,-1.00
reshow
;
return
end


