pro nrtype,help=help
;+
; NAME: 
;       NRTYPE
;
;            ==========================
;            Syntax: nrtype,help=help
;            ==========================
;
;   nrtype   Sets !nrtype of X-axis units used to define !nregion  
;   --------   
;
;    !chan ==> !nrtype=0  X-axis in CHANNELS
;    !freq ==> !nrtype=1  X-axis in FREQUENCY
;    !velo ==> !nrtype=2  X-axis in VELOCITY
;    !vgrs ==> !nrtype=3  X-axis in VELOCITY
;    !elxx ==> !nrtype=4  X-axis in ARCSEC
;    !azxx ==> !nrtype=5  X-axis in ARCSEC
;    !decx ==> !nrtype=6  X-axis in ARCSEC
;    !raxx ==> !nrtype=7  X-axis in ARCSEC
;
;   KEYWORDS: /help gives help
;
; MODIFICATION HISTORY:
;
; V7.0 tmb - 
;      tvw 28jun2013 changed nrtype 7 from chan to raxx
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  
;
if Keyword_Set(help) then begin & get_help,'nrtype' & return & endif 
;
def_xaxis,npts  ; this fills !xx with x_units values and npts in array
;
case 1 of       ; TMBIDL v7.0 valid x-axis data units 
    !chan: !nrtype=0  ; print,'X-axis in CHANNELS'
    !freq: !nrtype=1  ; print,'X-axis in FREQUENCY'
    !velo: !nrtype=2  ; print,'X-axis in VELOCITY'
    !vgrs: !nrtype=3  ; print,'X-axis in VELOCITY'
    !elxx: !nrtype=4  ; print,'X-axis in ARCSEC'
    !azxx: !nrtype=5  ; print,'X-axis in ARCSEC'
    !decx: !nrtype=6  ; print,'X-axis in ARCSEC'
    !raxx: !nrtype=7  ; print,'X-axis in ARCSEC'
else: begin & print,'ERROR ! Invalid x-axis units' & return & end
endcase 
;
return
end
