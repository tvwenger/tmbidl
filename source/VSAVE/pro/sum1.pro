;+
; NAME:
;       SUM1
;
;            ======================
;            Syntax: sum1, rec#, luntab 
;            ======================
;
;   sum1    Prints a singal line of info about a spectral line pair
;   --------  rec# = record number (assumed to be ON)
;             luntab = lun for file
;        
;        
;
;  V5. July 2008
;-
pro sum1,rec,luntab 
;
on_error,!debug ? 0 : 2
compile_opt idl2
if (n_params() eq 0) then begin
                          print,'ERROR:  Must specify a record number'
                          return
                          endif
if (n_params() eq 2) then lprt=luntab
;
get,rec
copy,0,1
src=strtrim(string(!b[0].source),2)             ; source name
src=string(!b[0].source)            ; source name
radec=strtrim(adstring(!b[0].ra,!b[0].dec,0),2) ; RA,DEC string
scn=!b[0].scan_num                              ; scan number
vel=!b[0].vel                                   ; source velocity  m/sec
polid=strtrim(string(!b[0].pol_id),2)           ; polarization ID
lid=strtrim(string(!b[0].line_id),2)            ; line ID
typ=strtrim(string(!b[0].scan_type),2)          ; scan type
date=strtrim(string(!b[0].date),2)              ; date of observation    
;
lst=!b[0].lst/3600.                             ; LST hours
slst=adstring(!b[0].lst/3600.)                  ; LST as HH MM SS string
ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ;  yes, they send lst in seconds and ra in degrees
ha = (ha gt 12.) ? (ha-24.) : ha   ; note use of the Ternary operator...!

az=!b[0].az                                     ; azimuth  degrees
el=!b[0].el                                     ; elevation degrees
za=90.-el                                       ; zenith angle degrees 
;
fsky=!b[0].sky_freq/1.0e+06                     ; sky freq MHz
frest=!b[0].rest_freq/1.0e+06                   ; rest freq MHz
bw=!b[0].bw/1.0e+06                             ; total bandwidth MHz
nchan=n_elements(!b[0].data)
res=(bw/nchan)*1.D3                             ; freq resolution kHz/channel
tcal=!b[0].tcal                                 ; Tcal Kelvin accuracy unknown
tsys=!b[0].tsys                                 ; Tsys Kelvin  -- not yet available
tintg=!b[0].tintg/60.                           ; integration time in minutes
;
comment=string(!b[0].history)
;
get,rec-16
tsysoff=!b[0].tsys                               ; Tsys Kelvin  OFF Scan
print,src,lid,scn,rec,date,ha,el,tsys,tsysoff,format='(a18,1x,a5,i6,i6,1x,a10,f6.1,1x,f4.1,2f6.1)'
if (luntab gt 0) then begin
   printf,luntab,src,lid,scn,rec,date,ha,el,tsys,tsysoff,format='(a18,1x,a5,i6,i6,1x,a10,f6.1,1x,f4.1,2f6.1)'
   endif
;
return
end
