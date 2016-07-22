pro hdr_grs,rec,help=help
;+
; NAME:
;       HDR_GRS
;
;            ===============================
;            Syntax: hdr_grs, rec#,help=help
;            ===============================
;
;   hdr_grs  Prints header variables for a single data record.
;   -------  e.g. a single subcorrelator spectrum for a specific scan
;            This version is for BU-FCRAO GRS 13-CO spectral line data. 
;
;        If !flag=1 then print out a full header. 
;        FLAGON/FLAGOFF toggles this
;-
;  V5.0 July 2007 
;  modified Aug07 for GRS data
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'hdr_grs' & return & endif
;
src=strtrim(string(!b[0].source),2)             ; source name
lgal='L=' + fstring(!b[0].l_gal,'(f6.3)')
bgal='B=' + fstring(!b[0].b_gal,'(f6.3)') 
scn=!b[0].scan_num                              ; scan number
sscn=fstring(!b[0].scan_num,'(I7)')    ; record number in datafile is scan number
vel=!b[0].vel                                   ; source velocity  m/sec
polid='GRS'                                     ; ID as GRS 
lid=strtrim(string(!b[0].line_id),2)            ; line ID
typ=strtrim(string(!b[0].scan_type),2)          ; BEAM smooth notes
;
fsky=!b[0].sky_freq/1.0e+06                     ; sky freq MHz
frest=!b[0].rest_freq/1.0e+06                   ; rest freq MHz
bw=!b[0].bw/1.0e+06                             ; total bandwidth MHz
nchan=n_elements(!b[0].data)
res=(bw/nchan)*1.D3                             ; freq resolution kHz/channel
tcal=!b[0].tcal                                 ; Tcal Kelvin accuracy unknown
tsys=!b[0].tsys                                 ; Tsys Kelvin  -- not yet available
tintg=!b[0].tintg/60.                           ; GRS # recs averaged for this spectrum
;
comment=string(!b[0].history)
note=''
if !b[0].procseqn ne 0 then note='NO DATA !!!'
;
print
print,src,lgal,bgal,sscn,lid,polid,typ,note, $
      format='(a13,1x,a8,1x,a8,1x,a7,1x,a9,1x,a3,1x,a10,1x,a)'
print
if !flag then begin
   print,'Fsky '+fstring(fsky,'(f12.4)')+' MHz  F0 '+$
          fstring(frest,'(f12.4)')+' MHz'
   print,'Nspec= '+fstring(tintg,'(f8.1)')+$
         '        Vsrc '+fstring(vel/1.d+3,'(f7.2)')+' km/sec'
   if !verbose then begin
                    print
                    print,comment
   endif
   print
endif
;
return
end
