;+
;
; NAME: put_lph
;;
;   put_lph.pro    Transfers header information from !b[0] to !lp_hdr
;   ----------     
;
;                  Syntax: put_lph
;
;-
pro put_lph
;
on_error,!debug ? 0 : 2
compile_opt idl2
!lp_hdr=!lp_blk
!lp_hdr.source=!b[0].source
!lp_hdr.scan_num=!b[0].scan_num
!lp_hdr.pol_id=!b[0].pol_id
!lp_hdr.line_id=!b[0].line_id
!lp_hdr.scan_type=!b[0].scan_type
!lp_hdr.date=!b[0].date
!lp_hdr.sky_freq=!b[0].sky_freq
!lp_hdr.delta_x=!b[0].delta_x
!lp_hdr.tsys=!b[0].tsys
!lp_hdr.tsys_on=!b[0].tsys_on
!lp_hdr.tsys_off=!b[0].tsys_off
!lp_hdr.tintg=!b[0].tintg
!lp_hdr.calfact=!b[0].calfact
!lp_hdr.calstat=!b[0].calstat
!lp_hdr.dstat=!b[0].dstat
!lp_hdr.comment=!b[0].comment
return
end
