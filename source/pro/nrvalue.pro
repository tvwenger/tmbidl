pro nrvalue,nr,help=help,noInfo=noInfo
;+
; NAME: 
;       NRVALUE
;
;            ==========================================
;            Syntax: nrvalue,nr,help=help,noInfo=noInfo
;            ==========================================
;
;   nrvalue   Returns "nr" array containing the 
;   -------   *channels* of the NREGION values.
;             NREGIONs in current X-axis units
;             are then !xx[nr] 
;
;   ========> !nregion and !nrtype are NOT changed
;
;   KEYWORDS: /help   - gives help
;             /noInfo - stops info print
;
;-
; MODIFICATION HISTORY:
;
; V7.0 tmb - 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  
;
if Keyword_Set(help) then begin & get_help,'nrvalue' & return & endif 
;
nr=!nregion[0:2*!nrset-1] ; copy the NREGION values in native units 
;
case !nrtype of       ; first must get native NREGION values into !xx 
    0: chan 
    1: freq
    2: velo
    3: vgrs
    4: elxx
    5: azxx
    6: decx
    7: raxx 
 else: begin & print,'ERROR ! Invalid NREGION data type' & return & end
endcase 
;
; translate native NREGION values to current X-axis units
; store result in 'nr'
;
for i=0,2*!nrset-1 do begin & 
    idchan,!nregion[i],xval
;    case !nrtype of
;             0: idval,!nregion[i],xval
;          else: idchan,!nregion[i],xval
;       endcase
    nr[i]=xval
end
;
; print out information unless this is supressed 
;
if Keyword_Set(noInfo) then goto,skip_the_info 
;   
label=' ==> !nrtype = '+fstring(!nrtype,'(i2)')
print,label
print,!nregion[0:2*!nrset-1]
print,nr[0:2*!nrset-1]
;
skip_the_info:
;
return
end
