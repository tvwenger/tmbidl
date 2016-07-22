pro fetch,recon,help=help
;+
; NAME:
;      FETCH
;
;   fetch    Calculates the PS spectrum from TP ON/OFF records
;   -----    recon = ON data record; OFF rec# via !recs_per_scan
;
;            =============================
;            Syntax: fetch,recon,help=help
;            =============================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
; V8.0 12jul2014 tvw - added fix_vegas support -
;      08jun2015 tvw/tmb - removed fix_vegas
;      18jun2015 tmb - fixed OFFLINE minus rec bug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'fetch' & return & endif
;
recoff = recon - !recs_per_scan
get,abs(recon)     & copy,0,5 &
get,abs(recoff)    & copy,0,6 & 
copy,5,0                  ;  load the ON scan header 
;
tsyson=!b[5].tsys  & tsysoff=!b[6].tsys  &
!tsys = (tsyson+tsysoff)/2. & !time = !b[5].tintg+!b[6].tintg & 
!b[0].tsys=!tsys & !b[0].tintg=!time &
!b[0].tsys_on =tsyson
!b[0].tsys_off=tsysoff
;
!b[0].scan_type=''
!b[0].scan_type=byte('PS TP Pair')
;
on=!b[5].data & off=!b[6].data & 
!b[0].data = (on/off-1.)*tsysoff
;
if (!flag) then begin
           hdr
           print
           tc=tsyson-tsysoff
           print,'TsysON ' +fstring(tsyson, '(f5.1)')+' K '+$
                 'TsysOFF '+fstring(tsysoff,'(f5.1)')+' K '+$
                 'TC '+fstring(tc,'(f5.1)')+' K '+$
                 'Elev '+fstring(!b[0].el,'(f5.1)')
           endif
;
if (!dcsub) then dcsub 
;
; if doing VEGAS, fix the center channel
; if !config eq 6 then fix_vegas
;
copy,0,7
;
return
end


