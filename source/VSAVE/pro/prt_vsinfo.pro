;+
; NAME:
;       PRT_VSINFO
;
;            =================================================
;            Syntax: prt_vsinfo, ivsf
;            =================================================
;
;
;   prt_vsinfo   prints info on the ivsf VSAVE file
;   ----------   
;
;                
;              
; MODIFICATION HISTORY:
; 9/08 RTR for line parameters
;-
pro prt_vsinfo,ivsf
;       
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() ne 1 then begin
   print,'Usage: prt_vsinfo,ivsf'
   return
   endif
;
!vs_rec=!vsf[ivsf-1]
vs_type=string(!vs_rec.vs_type)
vs_file=string(!vs_rec.vs_file)
print,ivsf,vs_type,vs_file,!vs_rec.vs_active,!vs_rec.vs_lun,!vs_rec.vs_log_lun, $
      !vs_rec.vs_protect,!vs_rec.vsave,!vs_rec.lastvs,!vs_rec.vsmax, $
      format='(i4,a8,1x,a32,1x,i2,2i4,i2,3i6)'
return
end
