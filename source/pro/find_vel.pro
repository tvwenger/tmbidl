pro find_vel,Vrrl,Cshift,help=help
;+
; NAME:
;       FIND_VEL
;
;            ======================================
;            Syntax: find_vel,Vrrl,Cshift,help=help
;            ======================================
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
; V7.0 3may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'find_vel' & return & endif
;         x     x     x     x     x     x     x     x
llabel=['H89','H88','H87','HE3','H93','H92','H91','H90']
rlabel=['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
CHnAlpha=[2842.6,3456.9,1650.8,2020.3,2049.8,1278.8,2049.9,2412.1]
;
Vsrc=!b[0].vel/1.0D+3  ; nominal center velocity in km/s
lineID=strtrim(string(!b[0].line_id),2)
lineID=strmid(lineID,0,3)
;index=where(lineID eq llabel)
index=where(lineID eq rlabel or lineID eq llabel)
Calpha=CHnAlpha[index] ; pick the correct HnAlpha channel for !config=1
;
velo                   ; switch to velocity x-axis
idval,Calpha,Valpha
Dvel=Vsrc-Valpha
;
chan
print,'Fit Gaussian: bgauss,peak,width,egauss'
gg,1
;
Chii=!a_gauss[1]
velo
idval,Chii,Vhii
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
Verr=(cen_err*1.0d+3*!light_c)/!b[0].sky_freq  ; center error in km/sec 
;
lab='H II region velocity is '+fstring(Vrrl,'(f7.2)')
lab=lab+' km/s +/- '+fstring(Verr,'(f5.2)')
print,lab
print,'This corresponds to a channel shift of ',fstring(Cshift,'(f6.0)')+' channels'
print
print,Vrrl,Verr,format='(f7.2,1x,f5.2)'
;
return
end
