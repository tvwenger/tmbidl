;+
; NAME:
;       WRITE_VSINFO
;
;       write_vsinfo.pro     Writes info on current VSAVE files to a file
;
;                  Syntax: write_vsinfo,f_name
;                          f_name = file name
;                                   if no argument uses !tr_file
;
;-
pro write_vsinfo,f_name
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
   print,'File '+f_name+' not found' 
   ifound=0
   print,'Create '+f_name+' ?(y)'
   ans=get_kbrd(1)
   if ans ne 'y' then retall
   openw,lun,f_name,/get_lun
   vsi_lun=lun
endif else begin
   openu,lun,f_name,/get_lun
   vsi_lun=lun
endelse
!vsinfo_file=strtrim(f_name,2)
writeu,vsi_lun,!vsf
print,'VSAVE INFO File ',!vsinfo_file,' written'
close,vsi_lun
free_lun,vsi_lun
return
end
