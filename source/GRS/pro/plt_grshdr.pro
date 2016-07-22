;+
;
;   plt_grshdr.pro   ;  annotate plot with header values for GRS data
;   --------------
;                    ;  assumes data are in !b[0] 
;
; 
; V5.0 July 2007
;-
pro plt_grshdr
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
@CT_IN
; top level of info
;
sscn='Offset='+fstring(!b[0].beamxoff,'(I3)')+'"'
xyouts,0.04,.9,sscn,/normal,charsize=2.0,charthick=2.0, $
  color=!cyan                   ; position offset
                                ; between GRS position and input (l,b)
src=strtrim(string(!b[0].source),2)
xyouts,.02,.94,src,/normal,charsize=2.5,charthick=2.5, $
       color=!magenta                                        ; src name
sscn=fstring(!b[0].scan_num,'(I7)')    ; record number in datafile is scan number
xyouts,.35,.94,sscn,/normal,charsize=2.5,charthick=2.5, $
       color=!purple
;qqq='Vsrc= ' + fstring(!b[0].vel/1.0d3,'(f9.2)')
;xyouts,.37,.94,qqq,/normal,charsize=1.5,charthick=1.5, $
;       color=!cyan                                           ; Source velocity km/sec
polid='GRS'
xyouts,.6,.94,polid,/normal,charsize=2.0,charthick=2.5,$
       color=!yellow                                         ; polarization
qqq=strtrim(string(!b[0].line_id),2)
xyouts,.75,.94,qqq,/normal,charsize=2.0,charthick=2.0, $
       color=!red                                            ; Line ID 
qqq=strtrim(string(!b[0].scan_type),2)
xyouts,.04,.835,qqq,/normal,charsize=2.0,charthick=2.0, $     ; BEAM smooth note
       color=!orange 
;
; next level of info;
;xyouts,.025,.905,adstring(!b[0].ra,!b[0].dec,0),/normal,charsize=1.5,charthick=2.0 ; RA,DEC 
qqq='L= ' + fstring(!b[0].l_gal,'(f6.3)')
xyouts,.2,.9,qqq,/normal,charsize=2.0,charthick=2.0,color=!yellow ; galactic longitude
qqq= 'B= ' + fstring(!b[0].b_gal,'(f6.3)')   
xyouts,.2,.85,qqq,/normal,charsize=2.0,charthick=2.0,color=!yellow ; galactic latitude 
;
qqq='Lpix= ' + fstring(!b[0].hor_offset,'(f8.3)')
xyouts,.4,.9,qqq,/normal,charsize=2.0,charthick=2.0,color=!green ; galactic longitude
qqq= 'Bpix= ' + fstring(!b[0].ver_offset,'(f8.3)')   
xyouts,.4,.85,qqq,/normal,charsize=2.0,charthick=2.0,color=!green ; galactic latitude 
;qqq='BW= ' + fstring(!b[0].bw/1.0e+06,'(f8.4)')
;xyouts,.8,.9,qqq,/normal,charsize=1.5,charthick=2.0          ; BW MHz
; 
;qqq='LST= ' + adstring(!b[0].lst/3600.)
;xyouts,.04,.875,qqq,/normal,charsize=1.5,charthick=2.0, $
       color=!yellow                                         ;  LST
;qqq='Tcal= ' + fstring(!b[0].tcal,'(f4.1)')
;xyouts,.4,.875,qqq,/normal,charsize=1.5,charthick=2.0        ;    
qqq='RMS= ' + fstring(!b[0].tsys,'(f5.3)')
xyouts,.6,.9,qqq,/normal,charsize=2.0,charthick=2.0, $
       color=!red                                            ; RMS  in Kelvin   
if !b[0].procseqn ne 0 then begin
   qqq='NO DATA !!!'
   xyouts,.8,.875,qqq,/normal,charsize=3.0,charthick=3.0, $
      color=!orange                                            ; FLAG for blank pixel
end
qqq='Nspec= ' + fstring(!b[0].tintg/60.,'(f8.1)')
xyouts,.6,.85,qqq,/normal,charsize=2.0,charthick=2.0, $
       color=!red                                            ; # spectra in avg
;
;ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ;  yes, they send lst in seconds and ra in degrees
;ha = (ha gt 12.) ? (ha-24.) : ha   ; note use of the Ternary operator...!
;qqq='HA= ' + fstring(ha,'(f6.2)')
;xyouts,.04,.84,qqq,/normal,charsize=1.5,charthick=2.0, $
       color=!red                                            ;  hour angle
;za=90.0-!b[0].el
;qqq='ZA= ' + fstring(za,'(f4.1)')
;xyouts,.16,.84,qqq,/normal,charsize=1.5,charthick=2.0, $
       color=!forest                                           ;  zenith angle
;qqq='AZ= ' +  fstring(!b[0].az,'(f5.1)')
;xyouts,.3,.84,qqq,/normal,charsize=1.5,charthick=2.0         ;  Azimuth degrees
;qqq='EL= ' +  fstring(!b[0].el,'(f4.1)')
;xyouts,.4,.84,qqq,/normal,charsize=1.5,charthick=2.0         ;  Elevation degrees 

;
;qqq=strtrim(string(!b[0].date),2)
;xyouts,0.95,.02,qqq,/normal,charsize=1.5,alignment=1.0        ; date at bottom
;qqq=strtrim(string(!b[0].date),2)
;qqq=strtrim(string(!b[0].observer),2)
;xyouts,0.05,.02,qqq,/normal,charsize=1.5,alignment=0        ; observer at bottom
;
@CT_OUT
return
end
