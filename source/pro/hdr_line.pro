pro hdr_line,rec,help=help
;+
; NAME:
;       HDR_LINE
;
;            ================================
;            Syntax: hdr_line, rec#,help=help
;            ================================
;
;   hdr_line  Prints header variables for a single data record.
;   --------  e.g. a single subcorrelator spectrum for a specific scan
;             This version is for GBT spectral line data. 
;
;        If !flag=1 then print out a full header. 
;        FLAGON/FLAGOFF toggles this
;-
;  V5.0 July 2007 
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'hdr_line' & return & endif
;
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
print
print,src,radec,scn,lid,polid,typ, format='(a8,1x,a22,f7.0,a6,1x,a3,1x,a20)'
print
if !flag then begin
   print,'LST '+slst,'   HA '+fstring(ha,'(f6.2)'),' ZA '+fstring(za,'(f6.2)'),$
         ' AZ '+fstring(az,'(f6.1)'),' EL '+fstring(el,'(f5.1)')
   print,'Fsky '+fstring(fsky,'(f9.4)')+' MHz  F0 '+fstring(frest,'(f9.4)')+$
         ' MHz  BW '+fstring(bw,'(f7.2)')+' MHz ->'+fstring(res,'(f9.4)')+' kHz/chan'
   print,'Tcal '+fstring(tcal,'(f5.2)')+' K  Tsys '+fstring(tsys,'(f5.1)')+$
         ' K   Tintg '+fstring(tintg,'(f7.1)')+$
         ' min       Vsrc '+fstring(vel/1.d+3,'(f7.2)')+' km/sec'
   if !verbose then begin
                    print
                    print,comment
   endif
   print
endif
;
return
end
