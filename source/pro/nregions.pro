pro nregions,nr,help=help,noInfo=noInfo,noFlag=noFlag
;+
; NAME: 
;       NREGIONS
;
;   ==================================================
;   Syntax: nregions,nr,help=help,noInfo=noInfo,noFlag
;   ==================================================
;
;   nregions Convert !nregion values to current X-axis units.
;   -------- Flags these locations unless supressed.   
;
;   KEYWORDS: /help   - gives help
;             /noInfo - stops NREGION info print
;             /noFlag - stops drawing the flags
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
if Keyword_Set(help) then begin & get_help,'nregions' & return & endif 
;
def_xaxis,npts  ; this fills !xx with x_units values and npts in array
                ; this should be unnecessary 
;
nr=!nregion[0:2*!nrset-1] ; copy the NREGION values in native units 
;
case 1 of       ; TMBIDL v7.0 valid X-axis data units 
;                 translate !nregion values to these units
    !chan: begin & label='X-axis in CHANNELS  '  
           nrvalue,nr,/noInfo 
           chan  & end      
    !freq: begin & label='X-axis in FREQUENCY  ' 
           nrvalue,nr,/noInfo 
           freq  & end
    !velo: begin & label='X-axis in VELOCITY  '  
           nrvalue,nr,/noInfo 
           velo  & end
    !vgrs: begin & label='X-axis in VELOCITY  '  
           nrvalue,nr,/noInfo 
           vgrs  & end
    !elxx: begin & label='X-axis in ARCSEC  '    
           nrvalue,nr,/noInfo 
           elxx & end
    !azxx: begin & label='X-axis in ARCSEC  '    
           nrvalue,nr,/noInfo 
           azxx  & end
    !decx: begin & label='X-axis in ARCSEC  '    
           nrvalue,nr,/noInfo 
           decx  & end
    !raxx: begin & label='X-axis in ARCSEC  '    
           nrvalue,nr,/noInfo 
           raxx  & end
     else: begin & print,'ERROR ! Invalid x-axis units' & return & end
endcase 
;   
nr=!xx[nr]
;
case !nrtype of       ; what are the !NREGION units ?
     0: label0='NREGIONs in CHANNELS'
     1: label0='NREGIONs in FREQUENCY'
     2: label0='NREGIONs in VELOCITY'
     3: label0='NREGIONs in VELOCITY'
     4: label0='NREGIONs in ARCSEC'
     5: label0='NREGIONs in ARCSEC'
     6: label0='NREGIONs in ARCSEC'
     7: label0='NREGIONs in ARCSEC'
else: begin & print,'ERROR ! Invalid NREGION units' & return & end
endcase 
;
if Keyword_Set(noInfo) then goto,skip_the_info
;
label=label+label0+' ==> !nrset = '+fstring(!nrset,'(i2)')
print,label
print,!nregion[0:2*!nrset-1]
print,nr[0:2*!nrset-1]
;
skip_the_info:
; flag the NREGIONs
;
if ~Keyword_Set(noFlag) then begin
    for i=0,2*!nrset-1 do begin & flag,nr[i] & endfor
end
;
return
end
