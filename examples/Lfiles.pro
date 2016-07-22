;
print
print,'==> Executing "EXAMPLES" batch file to initialize data file definitions.'
print
pwd
;
sdfits='SDFITS' & online='ONLINE' & offline='OFFLINE' & nsave='NSAVE'
;
; Example GBT spectral line data from 3-Helium project 
;
Lfits='../examples/AGBT12A_114_76.avg.acs.fits'
attach,sdfits,Lfits
;
ONfile='../examples/L_12A_114_76.tmbidl'
attach,online,ONfile
;
;
; Example GBT continuum  data from 3-Helium project 
;
Cfits='../examples/AGBT12A_114_76.cal.dcr.fits'
!c_SDFITS=Cfits
;attach,sdfits,Cfits 
OFFfile='../examples/C_12A_114_76.tmbidl'
attach,offline,OFFfile
;
; TMBIDL NSAVE file for 4096 data points
;
nson = '../examples/NSAVE.LNS'
nskey='../examples/NSAVE.LNS.KEY'
attach,nsave,nson,nskey
;
