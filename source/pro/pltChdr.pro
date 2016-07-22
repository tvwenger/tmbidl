pro pltChdr,help=help
;+
; NAME:
;       PLTCHDR
;
;            =========================
;            Syntax: pltchdr,help=help
;            =========================
;
;   pltChdr  Annotate plot with header values -- CONTINUUM version
;   -------  Assumes data are in !b[0]
;-
; V5.0 July 2007
; V5.1  July 2008 tmb fixed bug in HA calculation
; V6.1 March 2010 tmb tweaked for seamless PS output
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'pltChdr' & return & endif
@CT_IN
; top level of info
;
sscn=fstring(!b[0].scan_num,'(I9)')
xyouts,0.,.94,sscn,/normal,charsize=2.0,charthick=1.5         ; scan #
src=strtrim(string(!b[0].source),2)
xyouts,.15,.94,src,/normal,charsize=2.0,charthick=1.5         ; src name
;qqq='Vsrc= ' + fstring(!b[0].vel/1.0d3,'(f9.2)')
;xyouts,.3,.94,qqq,/normal,charsize=2.0                       ; Source velocity km/sec
polid=strtrim(string(!b[0].pol_id),2)
xyouts,.53,.94,polid,/normal,charsize=2.0,charthick=1.5       ; polarization
qqq=strtrim(string(!b[0].line_id),2)
xyouts,.6,.94,qqq,/normal,charsize=1.5                       ; Line ID 
qqq=strtrim(string(!b[0].scan_type),2)
xyouts,.75,.94,qqq,/normal,charsize=1.5              ; scan type
;
; next level of info
;
xyouts,.025,.905,adstring(!b[0].ra,!b[0].dec,0),/normal,charsize=2.0 ; RA,DEC 
qqq='Fsky= ' + fstring(!b[0].sky_freq/1.0e+06,'(f9.4)')
xyouts,.4,.9,qqq,/normal,charsize=1.5                         ; sky freq MHz
;qqq='Frest= ' + fstring(!b[0].rest_freq/1.0e+06,'(f9.4)')      
;xyouts,.6,.9,qqq,/normal,charsize=1.5                         ; rest freq MHz
qqq='BW= ' + fstring(!b[0].bw/1.0e+06,'(f8.4)')
xyouts,.6,.9,qqq,/normal,charsize=1.5                         ; BW MHz
; 
qqq='Tcal= ' + fstring(!b[0].tcal,'(f3.1)')
xyouts,.6,.875,qqq,/normal,charsize=1.5                       ; Tcal in Kelvin   
qqq='Tsys= ' + fstring(!b[0].tsys,'(f5.1)')
xyouts,.8,.875,qqq,/normal,charsize=1.5                       ; Tsys in Kelvin   
qqq='Tintg= ' + fstring(!b[0].tintg,'(f7.3)')
xyouts,.8,.9,qqq,/normal,charsize=1.5                       ; integration in seconds
;
qqq='LST= ' + adstring(!b[0].lst/3600.)
xyouts,.04,.85,qqq,/normal,charsize=1.5                      ;  LST
ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ;  yes, they send lst in seconds and ra in degrees
ha = (ha gt +12.) ? (ha-24.) : ha      ; note use of the Ternary operator...!
ha = (ha lt -12.) ? (ha+24.) : ha      ; note use of the Ternary operator...!
qqq='HA= ' + fstring(ha,'(f6.2)')
xyouts,.25,.85,qqq,/normal,charsize=1.5                        ;  hour angle
za=90.0-!b[0].el
qqq='ZA= ' + fstring(za,'(f6.1)')
xyouts,.4,.85,qqq,/normal,charsize=1.5                         ;  zenith angle
qqq='Az= ' +  fstring(!b[0].az,'(f7.1)')
xyouts,.6,.85,qqq,/normal,charsize=1.5                         ;  Azimuth degrees
qqq='Elev= ' +  fstring(!b[0].el,'(f6.1)')
xyouts,.8,.85,qqq,/normal,charsize=1.5                        ;  Elevation degrees 

;
qqq=strtrim(string(!b[0].date),2)
xyouts,0.95,.02,qqq,/normal,charsize=1.,alignment=1.0        ; date at bottom
;
@CT_OUT
return
end
