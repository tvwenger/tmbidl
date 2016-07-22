pro ps,on_rec,off_rec,help=help
;+
; NAME:
;       PS
;
;            =================================================
;            Syntax: ps, on_rec#, off_rec#,help=help
;            =================================================
;
;
;   ps    Calculates the PS spectrum from TP ON/OFF records.
;   --    
;             on_rec  = ON  data record # => copied to buffer 5
;             off_rec = OFF data record # => copied to buffer 6
;             TP spectrum copied to buffer 7
;
;             DCON/DCOFF toggles automatic DC level subtraction          
;          => Also create a TP pair using: FETCH,on_rec 
;             (this assumes off_rec=on_rec-8)             
;-             
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'ps' & return & endif
;
get,on_rec     & copy,0,5 & ;  copy ON  to buffer 5
get,off_rec    & copy,0,6 & ;  copy OFF to buffer 6
copy,5,0                    ;  load the ON scan header 
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
copy,0,7
;
return
end


