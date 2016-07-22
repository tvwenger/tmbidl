pro accum,help=help
;+
; NAME:
;      ACCUM
;
;            =======================
;            Syntax: accum,help=help
;            =======================
;
;  accum   Accumulates weighted data in buffer 3, !b[3].
;  -----   (as did UniPops)
;
;              weight is tintg/(Tsys)**2 for data
;                        tintg           for Tsys
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;     21may2013 tmb - merged with dsb/lda code 
;                     if !verbose then complain with a message
;                     should Tsys or Tintg be insane 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'accum' & return & endif
;
If !aaccum eq 0 then begin                   ; initialize if first call to ACCUM
                     copy,0,3                ; copy initial header 
                     !b[3].tsys=0.0 
                     !b[3].tsys_on=0.0 
                     !b[3].tsys_off=0.0 
                     !b[3].tintg=0.0
                     !b[3].data=0.0
                     endif
;
!tsys=!b[0].tsys  &  !time=!b[0].tintg &  
!wtd=(!time/(!tsys*!tsys)) > 0 & !wts=!time  &
;!wtd=!time/(!tsys*!tsys) & !wts=!time  & original tmb code 
;
; issue error message if !verbose
;
if !verbose then begin
   if !tsys le 0. or !time le 0. then begin
      msg='ERROR!!! Tsys = '+fstring(!tsys,'(f6.1)')
      msg=msg+'  Time = '+fstring(!time,'(f10.1)')
   endif
endif
;
!b[3].data = !wtd*!b[0].data + !b[3].data
;
!b[3].tintg    = !time               + !b[3].tintg 
!b[3].tsys     = !wts*!tsys          + !b[3].tsys 
!b[3].tsys_on  = !wts*!b[0].tsys_on  + !b[3].tsys_on
!b[3].tsys_off = !wts*!b[0].tsys_off + !b[3].tsys_off
;
!sumwtd = !wtd + !sumwtd
!sumwts = !wts + !sumwts
;
!accum[!aaccum] = !b[0].scan_num
!aaccum = !aaccum + 1
;
return
end

