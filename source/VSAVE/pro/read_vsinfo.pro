;+
; NAME:
;       READ_VSINFO
;
;       read_vsinfo.pro     Reads info on current VSAVE files to a file
;
;                  Syntax: read_vsinfo,f_name
;                          f_name = file name
;                                   if no argument uses !tr_file
;
;-
pro read_vsinfo,f_name
;
on_error,!debug ? 0 : 2
compile_opt idl2
if n_params() eq 0 then begin
                   f_name=strtrim(!vsinfo_file,2)
                   print,'No argument given. Using '+strtrim(!vsinfo_file,2)
                   print,'Is this ok?(y,n)'
                   ans=get_kbrd(1)
                   if ans ne 'y' then begin
                      f_name=' '
                      read,f_name,prompt='New file name:'
                   end
                endif
if findfile(f_name) eq '' then begin
   print,'read_vsinfo: File '+f_name+' not found' 
   return
endif else begin
   openu,lun,f_name,/get_lun
   vsi_lun=lun
endelse
!vsinfo_file=strtrim(f_name,2)
vstmp=!vsf
readu,vsi_lun,vstmp
!vsf=vstmp
print,'VSAVE INFO File ',!vsinfo_file,' read'
close,vsi_lun
free_lun,vsi_lun
!nvsf=0
i=0
while strtrim(string(!vsf[i].vs_type),2) ne '' $
      and i+1 le !nvsf_max do begin
   print,i,strtrim(string(!vsf[i].vs_type),2)
   !nvsf=i+1
   i=i+1
endwhile
print,!vsinfo_file, ' has ',!nvsf,' entries'
prt_vstab
return
end
