;+
;
; NAME: put_lp
;   put_lp.pro     Transfers line parameter information to !lp_rec
;   ----------     
;
;                  Syntax: put_lph,igauss
;                          igauss is the index in a multigauss fit
;
;-
pro put_lp,igauss
;
on_error,!debug ? 0 : 2
compile_opt idl2
if n_params() ne 1 then begin
                   print,'Required Usage: put_lp,igauss'
                   return
                   endif
!lp_rec=!lp_hdr
!lp_rec.trans=!trans
!lp_rec.ngauss=!ngauss
!lp_rec.igauss=igauss
!lp_rec.bgauss=!bgauss
!lp_rec.egauss=!egauss
igauss=igauss-1
!lp_rec.hgt=!a_gauss[igauss*3+0]
!lp_rec.hgterr=!g_sigma[igauss*3+0]
cen=!a_gauss[igauss*3+1]
!lp_rec.cen=cen
!lp_rec.cenerr=!g_sigma[igauss*3+1]
!lp_rec.fwhm=!a_gauss[igauss*3+2]
!lp_rec.fwhmerr=!g_sigma[igauss*3+2]
!lp_rec.fixc=0
!lp_rec.fixhw=0
band=!band
acs_tags,band,cen,tag,loffset
!lp_rec.l_name=byte(tag)
!lp_rec.delta_c=loffset
!lp_rec.mk_on=!mk_on
!lp_rec.src_delta_v=!src_voffset
!lp_rec.src_delta_c=!src_coffset
!lp_rec.bfit_rms=!bfit_rms
!lp_rec.sm_stat=!line_sm_vel
!lp_rec.nfit=!nfit
!lp_rec.nrset=!nrset
!lp_rec.xrange=!x.range
!lp_rec.sregion=!nregion[0:15]
if !nsave_list[0] eq 0 then begin
   !lp_rec.nsaves=0
   !lp_rec.nsaves[0]=!nsave
endif else begin
   !lp_rec.nsaves=!nsave_list
endelse
nsave_id=!nsave_id
!lp_rec.nsave_file=byte(strtrim(nsave_id,2))
print,'Enter a Comment to describe this line, e.g., marginal detection'
lp_com='               '
read,lp_com
!lp_rec.lcom=byte(strtrim(lp_com,2))
;

;
return
end
