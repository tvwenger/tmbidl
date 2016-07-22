pro mrset,n,nreg,help=help
;+
; NAME:
;      MRSET
;
;            ==============================
;            Syntax: mrset,n,nreg,help=help
;            ==============================
;
;  mrset.pro    Sets NREGION mask in x-axis units.
;  ---------    If !cursor=0 (CUROFF) then returns with error.
;               Sets beginning and ending of NREGIONs to display
;               xmin,xmax (!x.range)
;
;               n is the number of nregions to set 
;               nreg is array of x-axis value pairs of (begin,end)
;                    EXCEPT the first begin and last end are by
;                    default the displayed xmin,xmax
; 
;           =>  First click is END of first NRESION <=
;           =>  Last click is BEGINNING of last NREGION <=                              
;-
; V5.0 July 2007
;  5.1 Jan  2008 modified to work with backwards scans
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'mrset' & return & endif
;
flag_state=!flag           ; capture flag state
!flag=1              ; force flag to stop cursor routine from writing
;
if !cursor ne 1    then begin
                   print,'Error: cursor must be enabled! Invoke CURSOR'
                   return
                   endif
if n_params() eq 0 then begin
                   print,'Must specify number of baseline mask regions: nrset,#'
                   return
                   endif
;
nmax=n_elements(!nregion)-1
!nregion[0:nmax]=0.     ;  zero out old nregions
!nrset=n        ;  
xmin=min(!x.crange,max=xmax)
idchan,xmin,min_chan & idchan,xmax,max_chan  ; get xrange of display
min_chan=min(min_chan) ; fix for backwards continuum scans
;
for i=1,2*!nrset-2 do begin
      ccc,xpos,ypos
      idchan,xpos,xchan
      !nregion[i]=!xx[xchan]
endfor
!nregion[0]=!xx[min_chan] & !nregion[2*!nrset-1]=!xx[max_chan] &
;  
kount=0             
for i=0,2*!nrset-1,2 do begin
      kount=kount+1
      print,'set nreg= ',kount,!nregion[i],!nregion[i+1],$
            format='(a10,I3,2f9.2)'
endfor
mask,dsig
print
print,'RMS in NREGIONs = ', dsig
print
;
for i=0,2*!nrset-1 do flag,!nregion[i]
;
!flag=flag_state     ;  restore flag state upon invocation
;
return
end

