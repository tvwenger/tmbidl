;+
; NAME:
;       FIND_VEL
;
;            ============================
;            Syntax: find_vel,Vrrl,Cshift
;            ============================
;
;   find_vel Find an unknown HII region RRL velocity.
;   -------- Input: Gaussian fit to unknown RRL velocity
;            spectrum displayed in CHANnels.
;            Returns the velocity, Vrrl (km/s) and number
;            of channels needed to shift it to Hnalpha position
;            Must do this band by band because of changing
;            center frequency
;
; MODIFICATION HISTORY:
; V5.1  10 Feb 2008 TMB 
;  6.1  17 Mar 2010 TMB fix rest_freq sky_freq bug
;
;  ARECIBO version for HRDS  21 Oct 2011 tmb & dsb
;          'ALL' uses average center channel and rest freq for the
;          4 tunings
;  28 oct 2011 many tweaks.  use average freq for ALL sky_freq
;-
pro find_vel,Vrrl,Cshift
;
on_error,2
compile_opt idl2
;         x    x     x     x     x     x     x     x
llabel=['H89','H90','H91','H92','ALL']
rlabel=['rx1','rx2','rx3','rx4','ALL']
fcenter=[9175.611106, 8874.781377, 8586.9620275, 8311.455206, 8737.20]
CHnAlpha=[93.67, 90.51, 87.57, 84.76, 89.128]
;CHnAlpha=512.-CHnAlpha
CHnAlpha=513.5-CHnAlpha
;
Vsrc=!b[0].vel/1.0D+3  ; nominal center velocity in km/s
lineID=strtrim(string(!b[0].line_id),2)
lineID=strmid(lineID,0,3)
;index=where(lineID eq llabel)
index=where(lineID eq rlabel or lineID eq llabel)
if index eq 4 then begin & !b[0].sky_freq=8.73720e+09 & end
;
Calpha=CHnAlpha[index] ; pick the correct HnAlpha channel for !config=1
;
velo                   ; switch to velocity x-axis
idval,Calpha,Valpha, /float
Dvel=Vsrc-Valpha
;
chan
print,'Fit Gaussian: bgauss,peak,width,egauss'
gg,1
;
Chii=!a_gauss[1]
velo
idval,Chii,Vhii, /float
Vrrl=Vhii+Dvel
;
chan
Cshift=Calpha-Chii 
;
copy,0,10
b0=!b[0].data
newb=shift(b0,Cshift)
!b[0].data=newb
!b[0].vel=Vrrl*1.0D+3
reshow
;
cen_err=!g_sigma[1]             ; center error in channels
cen_err=cen_err*!xval_per_chan  ; center error in Hz
;Verr=(cen_err*1.0d+3*!light_c)/!b[0].sky_freq  ; center error in
;km/sec 
fzero=fcenter[index]*1.d+6
Verr=(cen_err*1.0d+3*!light_c)/fzero  ; center error in km/sec 
;
;  Annotate with source name synonyms
;
source=string(!b[0].source) 
src=' ' & gname,src=src
lab=source+' <=> '+src
lab=lab+' LSR velocity is '+fstring(Vrrl,'(f7.2)')
lab=lab+' km/s +/- '+fstring(Verr,'(f5.2)')
print,lab
print,'This corresponds to a channel shift of ',fstring(Cshift,'(f6.0)')+' channels'
print
print,Vrrl,Verr,format='(f7.2,1x,f5.2)'
;
return
end
