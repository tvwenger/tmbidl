pro plthdr,help=help
;+
; NAME:
;       PLTHDR
;
;            ========================
;            Syntax: plthdr,help=help
;            ========================
;
;   plthdr Annotate plot with header values.
;   ------ Assumes data are in !b[0] .
;-
; V5.0  July 2007
; V5.1  July 2008 tmb fixed bug in HA calculation
; V6.1  August 2011 tmb added 1 more sig. fig. to rest and sky freqs. 
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'plthdr' & return & endif
@CT_IN
;
; top level of info
;
sscn=fstring(!b[0].scan_num,'(I9)')
xyouts,0.,.94,sscn,/normal,charsize=2.0,charthick=2.0, $
       color=!cyan                                           ; scan #
src=strtrim(string(!b[0].source),2)
xyouts,.12,.94,src,/normal,charsize=2.5,charthick=2.5, $
       color=!magenta                                        ; src name
qqq='Vsrc= ' + fstring(!b[0].vel/1.0d3,'(f9.2)')
xyouts,.37,.94,qqq,/normal,charsize=1.5,charthick=1.5, $
       color=!cyan                                           ; Source velocity km/sec
polid=strtrim(string(!b[0].pol_id),2)
xyouts,.53,.94,polid,/normal,charsize=1.5,charthick=2.0,$
       color=!magenta                                         ; polarization
qqq=strtrim(string(!b[0].line_id),2)
xyouts,.6,.94,qqq,/normal,charsize=2.0,charthick=2.0, $
       color=!red                                            ; Line ID 
qqq=strtrim(string(!b[0].scan_type),2)
xyouts,.75,.94,qqq,/normal,charsize=1.5,charthick=2.0        ; scan type
;
; next level of info
;
xyouts,.025,.905,adstring(!b[0].ra,!b[0].dec,0),/normal,charsize=1.5,charthick=2.0 ; RA,DEC 
qqq='Fsky= ' + fstring(!b[0].sky_freq/1.0e+06,'(f10.4)')
xyouts,.4,.9,qqq,/normal,charsize=1.5,charthick=2.0          ; sky freq MHz
qqq='Frest= ' + fstring(!b[0].rest_freq/1.0e+06,'(f10.4)')      
xyouts,.6,.9,qqq,/normal,charsize=1.5,charthick=2.0          ; rest freq MHz
qqq='BW= ' + fstring(!b[0].bw/1.0e+06,'(f8.4)')
xyouts,.8,.9,qqq,/normal,charsize=1.5,charthick=2.0          ; BW MHz
; 
qqq='LST= ' + adstring(!b[0].lst/3600.)
xyouts,.04,.875,qqq,/normal,charsize=1.5,charthick=2.0, $
       color=!magenta                                         ;  LST
qqq='Tcal= ' + fstring(!b[0].tcal,'(f4.1)')
xyouts,.4,.875,qqq,/normal,charsize=1.5,charthick=2.0        ; Tcal in Kelvin   
qqq='Tsys= ' + fstring(!b[0].tsys,'(f6.1)')
xyouts,.55,.86,qqq,/normal,charsize=2.0,charthick=2.0, $
       color=!red                                            ; Tsys in Kelvin   
qqq='Tintg= ' + fstring(!b[0].tintg/60.,'(f8.1)')
xyouts,.75,.86,qqq,/normal,charsize=2.0,charthick=2.0, $
       color=!red                                            ; integration in  minutes
;
ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ; yes, they send lst in seconds and ra in degrees
ha = (ha gt +12.) ? (ha-24.) : ha      ; note use of the Ternary operator...!
ha = (ha lt -12.) ? (ha+24.) : ha      ; note use of the Ternary operator...!
qqq='HA= ' + fstring(ha,'(f6.2)')
xyouts,.04,.84,qqq,/normal,charsize=1.5,charthick=2.0, $
       color=!red                                            ;  hour angle
za=90.0-!b[0].el
qqq='ZA= ' + fstring(za,'(f4.1)')
xyouts,.16,.84,qqq,/normal,charsize=1.5,charthick=2.0, $
       color=!red                                            ;  zenith angle
qqq='AZ= ' +  fstring(!b[0].az,'(f5.1)')
xyouts,.3,.84,qqq,/normal,charsize=1.5,charthick=2.0         ;  Azimuth degrees
qqq='EL= ' +  fstring(!b[0].el,'(f4.1)')
xyouts,.425,.84,qqq,/normal,charsize=1.5,charthick=2.0         ;  Elevation degrees 

;
qqq=strtrim(string(!b[0].date),2)
xyouts,0.95,.02,qqq,/normal,charsize=1.5,alignment=1.0        ; date at bottom
qqq=strtrim(string(!b[0].date),2)
qqq=strtrim(string(!b[0].observer),2)
xyouts,0.05,.02,qqq,/normal,charsize=1.5,alignment=0        ; observer at bottom
;
@CT_OUT
return
end
