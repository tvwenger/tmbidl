;+
; NAME:
;       PRT_LPH
;
;            ======================
;            Syntax: prt_lph 
;            ======================
;
;   prt_lph  Prints a header for a set of line fits !lp_rec
;   --------  
;  RTR 8/08
;-
pro prt_lph
;
on_error,!debug ? 0 : 2
compile_opt idl2
; 
source=string(!lp_hdr.source)
scan_num=!lp_hdr.scan_num
pol_id=strtrim(string(!lp_hdr.pol_id),2)
line_id=strtrim(string(!lp_hdr.line_id),2)
scan_type=strtrim(string(!lp_hdr.scan_type),2)
date=strmid(strtrim(string(!lp_hdr.date),2),0,10)
sky_freq=!lp_hdr.sky_freq/1.0D6
tsys=!lp_hdr.tsys
tsys_on=!lp_hdr.tsys_on
tsys_off=!lp_hdr.tsys_off
tintg=!lp_hdr.tintg/60
calfact=strtrim(string(!lp_hdr.calfact),2)
calstat=strtrim(string(!lp_hdr.calstat),2)
dstat=strtrim(string(!lp_hdr.dstat),2)
comment=strtrim(string(!lp_hdr.comment),2)
mk_on=!lp_rec.mk_on
src_delta_v=!lp_rec.src_delta_v
src_delta_c=!lp_rec.src_delta_c
bfit_rms=!lp_rec.bfit_rms*1.0D3
sm_stat=!lp_rec.sm_stat
nfit=!lp_rec.nfit
print,source,scan_num,date,pol_id,line_id,scan_type,$
      format='(a12,i6,1x,a11,1x,a4,1x,a6,1x,a10)'
print,calfact,calstat,dstat,comment,$
      format='(a8,1x,a8,1x,a8,1x,a32)'
print,'Fsky='+fstring(sky_freq,'(f9.4)')+' Tintg='+fstring(tintg,'(f7.1)')+$
      ' Tsys='+fstring(tsys,'(f5.1)')+' K Tsys-off='+fstring(tsys_off,'(f5.1)')+' K'
print,'Src_delta_V='+fstring(src_delta_v/1d3,'(f7.2)'),' Nfit='+fstring(nfit,'(I3)')+$
      ' Baseline RMS='+fstring(bfit_rms,'(f7.1)')+' mK  V_smooth='+fstring(sm_stat,'(f5.1)')
return
end
