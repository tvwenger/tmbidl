pro vegasList,help=help
;+
; NAME:
;       VEGASLIST
;
;            ===========================
;            Syntax: VEGASLIST,help=help
;            =========================== 
;
;   vegaslist  looks at VEGAS TP PS data in record space
;   ---------  uses records in STACK
;              setx,2000,6000  !nfit=5 
;              nrset=3,[2000,2550,3140,3740,4445,6000]
;
; KEYWORDS     help  - if set gives this help
;-
; MODIFICATION HISTORY:
; V8.0 23mar2016 tmb 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'vegaslist' & return & endif
;
print,'Contents of STACK'
;
oldcur=!cursor & curoff
oldflg=!flag   & flagoff

!nrset=1 & !nregion[0:!nregion_max*2-1]=0
xrange=[500,7692]
!nregion[0:1]=xrange
;
print
print,'  src  lineid  restFreq  bank  scn  pol  Tsys    rms'
print,'                  MHz                     K      mK'

fmt='(a7,1x,a5,1x,f9.4,1x,a5,1x,i4,2x,a2,1x,f6.1,1x,f7.2)'
;
for i=0,!acount-1 do begin
;for i=0,0 do begin
    fetch,abs(!astack[i])
    mk & dcsub & mask,sig
;
    src= strtrim(string(!b[0].source),2) 
    scn=!b[0].scan_num
    bank=strtrim(string(!b[0].proc_id),2) 
    lineID=strtrim(string(!b[0].line_id),2)
    freq=!b[0].rest_freq/1.d+6
    polID=strtrim(string(!b[0].pol_id),2)
    type=strtrim(string(!b[0].scan_type),2)
    tcal=!b[0].tcal
    tsysON=!b[0].tsys_on
    tsysOFF=!b[0].tsys_off
    tsys=!b[0].tsys
    elev=!b[0].el 
    tintg=!b[0].tintg
    stintg=strtrim(fstring(tintg,'(f13.2)'),2)
    sscan=strtrim(fstring(scn,'(i3)'),2)
;    srec=strtrim(fstring(rec,'(i6)'),2)
    stsys=strtrim(fstring(tsys,'(f6.1)'),2)
    ssig=strtrim(fstring(sig,'(f7.2)'),2)
;
    print,src,lineid,freq,bank,scn,polID,tsys,sig, $
          format=fmt
;
  
endfor
;
!cursor = oldcur
!flag   = oldflg

return
end
