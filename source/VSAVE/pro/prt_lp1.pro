;+
; NAME:
;       PRT_LP1
;
;            ======================
;            Syntax: prt_lp1 
;            ======================
;
;   prt_lp1  Prints a 1 line record of line parameters using info in !lp_rec
;   --------  
;  RTR 8/08
;-
pro prt_lp1
;
on_error,!debug ? 0 : 2
compile_opt idl2
; 
;
src=string(!lp_rec.source)            ; source name
l_name=string(!lp_rec.l_name)
ns=!lp_rec.nsaves[0]
nsf=' '
if !lp_rec.nsaves[1] ne 0 then nsf='*'
hgt=!lp_rec.hgt
hgterr=!lp_rec.hgterr
cen=!lp_rec.cen
cenerr=!lp_rec.cenerr
fwhm=!lp_rec.fwhm
fwhmerr=!lp_rec.fwhmerr
sky_freq=!lp_hdr.sky_freq
delta_c=!lp_rec.delta_c
delta_x=!lp_hdr.delta_x
sm_stat=!lp_rec.sm_stat
smflag='  '
if sm_stat gt 0 then smflag='SM'
mkflag='  '
if !lp_rec.mk_on gt 0 then mkflag='mK'
!xval_per_chan=abs(!b[0].delta_x)/1.0d+3 ; kHz
;
fwhm_khz=fwhm*!xval_per_chan
fwhm_kms=(fwhm_khz*1.0d+3*!light_c)/sky_freq
fwhmerr_khz=fwhmerr*!xval_per_chan
fwhmerr_kms=(fwhmerr_khz*1.0d+3*!light_c)/sky_freq
print,ns,nsf,src,l_name,hgt,mkflag,hgterr,fwhm_kms,fwhmerr_kms,cen,cenerr,delta_c,smflag, $
      format='(i4,a1,1x,a12,1x,A12,1x,f8.1,a2,f6.1,f7.2,f6.2,f8.1,f6.1,f6.1,1x,a2)'
return
end
