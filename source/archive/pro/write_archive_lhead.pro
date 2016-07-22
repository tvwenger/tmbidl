pro write_archive_LHEAD,archive,help=help
;+
; NAME:
;      WRITE_ARCHIVE_LHEAD
;
;
;   WRITE to ARCHIVE file Spectral Line HEADER information
;   This is a modified form of much of the information in the standard
;   plot header
;
;   Outputs 'archive' which is a single string containing the following
;   information delimited by a ' ' blank
;
;   INFORMATION PACKED IS:
;   archive_type,source,scan,line_id,scan_type,pol_id,position,v_source,
;   date,lst,hour_angle,zenith_angle,Azimuth,Elevation,
;   Fsky,Frest,BW,
;   Tcal,Tsys,Tintg
;   
;   =============================================
;   Syntax: write_archive_LHEAD,archive,help=help
;   =============================================
;
;   if !verbose then print out information
;
; V5.0 July 2007
; V7.0 May 2013 tmb/tvw added /help !debug
;
;-

; 
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'write_archive_LHEAD' & return & endif
;
archive_type='LHEAD'
b=' '                ; force blanks between variables for later strsplit
;
; first fetch the variables from !b[0]
; turn them all to strings via =fstring(,'()') 
;
source=strtrim(string(!b[0].source),2) 
scan=fstring(!b[0].scan_num,'(I9)')                    ; beware BOZO !
line_id=strtrim(string(!b[0].line_id),2)
scan_type=strtrim(string(!b[0].scan_type),2)
pol_id=strtrim(string(!b[0].pol_id),2)
;position=adstring(!b[0].ra,!b[0].dec,0)    
;position=strtrim(position,2) ; variables cannot have embedded blanks
ra=fstring(!b[0].ra,'(f9.4)')           ; all positions in degrees
dec=fstring(!b[0].dec,'(f8.4)')
epoch=fstring(!b[0].epoch,'(f6.1)') ; hope the bastards do not pass B1950
                                ;                                   J2000
l_gal=fstring(!b[0].l_gal,'(f9.4)')
b_gal=fstring(!b[0].b_gal,'(f8.4)')
;
v_source=fstring(!b[0].vel/1.0d3,'(f9.2)')
date=strtrim(string(!b[0].date))
;lst=strtrim(adstring(!b[0].lst/3600.))
lst=fstring(!b[0].lst/3600.,'(f8.4)')  ; LST in hours
ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ; yes, they send lst in seconds and ra in degrees
ha = (ha gt 12.) ? (ha-24.) : ha      ; note use of the Ternary operator...!
hour_angle=fstring(ha,'(f6.2)')
za=90.0-!b[0].el
zenith_angle=fstring(za,'(f4.1)')
Azimuth=fstring(!b[0].az,'(f6.2)')
Elevation=fstring(!b[0].el,'(f4.1)')
Fsky=fstring(!b[0].sky_freq/1.0e+06,'(f9.4)')
Frest=fstring(!b[0].rest_freq/1.0e+06,'(f9.4)') 
BW=fstring(!b[0].bw/1.0e+06,'(f8.4)')
Tcal=fstring(!b[0].tcal,'(f4.1)')
Tsys=fstring(!b[0].tsys,'(f6.1)')
Tintg=fstring(!b[0].tintg/60.,'(f8.1)')
;
if !verbose then begin
print,'Source Name = '+ source
print,'Scan Number = '+ scan
print,'Line ID     = '+ line_id
print,'Scan Type   = '+ scan_type
print,'Pol ID      = '+ pol_id
print,'R.A.        = '+ ra + ' deg'
print,'Dec.        = '+ dec + ' deg'
print,'Epoch       = '+ epoch
print,'L_gal       = '+ l_gal + ' deg'
print,'B_gal       = '+ b_gal + ' deg'
print,'Source Vel  = '+ v_source + ' km/sec'
print,'Date        = '+ date
print,'LST         = '+ lst + ' hrs'
print,'Hour Angle  = '+ hour_angle + ' hrs'
print,'Zenith Angle= '+ zenith_angle + ' deg'
print,'Azimuth     = '+ Azimuth + ' deg'
print,'Elevation   = ', Elevation + ' deg'
print,'Fsky        = '+ Fsky + ' MHz'
print,'Frest       = '+ Frest + ' MHz'
print,'Band Width  = '+ BW + ' MHz'
print,'Tcal        = '+ Tcal + ' K'
print,'Tsys        = '+ Tsys + ' K'
print,'Tintg       = '+ Tintg 
endif
                             ;
archive=archive_type+b+source+b+scan+b+line_id+b+scan_type+b+pol_id+b
archive=archive+ra+b+dec+b+epoch+b+l_gal+b+b_gal+b
archive=archive+v_source+b+date+b+lst+b+hour_angle+b
archive=archive+zenith_angle+b+Azimuth+b+Elevation+b+Fsky+b+Frest+b
archive=archive+BW+b+Tcal+b+Tsys+b+Tintg
;
; all ARCHIVE scripts must return a single string called 'archive'
; first entry is ID of archive_type  
;
if !verbose then print,archive
;
flush:
return
end
