;+
; NAME:
;      GETVS
;
;            ===========================
;            Syntax: getvs, vs_structure,vsave_slot_#,whichvs,/erase,
;                           /all,/nsave,/flag
;            ===========================
;
;   getvs  Gets a structure from VSAVE region specified by 'vs' argument.
;   -----  If vs not given then vs=!vsave, else !vsave=vs.
;          
;          a_st is a required structure. It should be a blank version
;          of the structure to be recovered. The recovered structure
;          will be returned in a_st
;
;          multiple files of the same structure require that whichvs
;                   be introduced to specify which is used. If omitted
;                   a menu will be given
;
;                The keyword nsave reads a standard tmbidl save file              
;              
;                The keyword /all considers or lists all vsave files
;                    whether they are active or not
;
;                The keyword /flag produces extra output
;               
;
; 
;
;+
pro getvs,a_st,vs,which,erase=erase,all=all,flag=flag,nsave=nsave     
; either input the vsave location explicitly or use !vsave value
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 then begin
   print,'GETVS Usage:  getvs, vs_structure,vsave_slot_#,whichvs,/erase,/all,/flag'
   print,'vs_structure is required'
   return
endif
vsave=!vsave
if n_params() ge 2 then begin
   vsave=vs
endif
use_vs=1
multi_warn=1
if n_params() eq 3 then begin
   use_vs=which
   multi_warn=0
endif
if keyword_set(nsave) then begin
   vs_type='LNS'
endif else begin
   vs_type=strtrim(string(a_st.vs_type),2)
endelse
found=0
ifound=intarr(!nvsf)
ifound=0
if !nvsf le 0 then begin
   print,'There are no VSAVE files in the table'
   return
endif
for i=0,!nvsf-1 do begin
   vst=strtrim(string(!vsf[i].vs_type),2)
   print,'searching',i,' vs_type=',vs_type,' tab type=',vst
   if strmatch(vs_type,vst) then begin
      active=!vsf[i].vs_active
      vs_use=i+1
      if keyword_set(all) and active le 0 then begin
         found=found+1
         ifound[found-1]=i
      endif
      if active gt 0 then begin
         found=found+1
         ifound[found-1]=i
      endif
   endif
end
if found le 0 then begin
   print,'No VSAVE files of type ',vs_type,' found'
   return
endif
if keyword_set(flag) then begin
   print,'VSAVE files found:'
   for i=1,found do begin
         prt_vs_info,ifound[i]
      end
end
if found gt 1 then begin
   if multi_warn gt 0 then begin
      print,'The are multiple files open for vs_type = ',vs_type
      for i=0,found-1 do begin
         prt_vs_info,ifound[i]
      end
      print,'Which do you want to use?'
      read,vs_use,prompt='Enter a number:'
      print,'You can avoid this message if you enter a third argument'
   endif
end
vsu=ifound[vs_use-1]
!vs_rec=!vsf[vsu]
!vsave=vs
;!vsunit=!vs_rec.vs_lun
!vsavefile=strtrim(string(!vs_rec.vs_file),2)+'.'+vs_type
;!vslogunit=!vs_rec.vs_log_lun
!vslogfile=!vsavefile+'.key'
!protectvs=!vs_rec.vs_protect
!vsavemax=!vs_rec.vsmax
;
openu,vsunit,!vsavefile,/get_lun       ;  associate vsave with the vsave file 
vsave = assoc(vsunit,a_st)             ;  a_st is structure for the pattern
;
openr,vslogunit,!vslogfile,/get_lun    ;  fetch latest version of !vsave_log
vslog=intarr(!vsavemax)
readu,vslogunit,vslog
;!vsave_log[0:!vsave_max-1]=vslog
close,vslogunit
;
if vslog[!vsave] le 0 then begin
   print, 'VSAVE bin ',!vsave,' is empty'
   close,vsunit
   free_lun,vsunit
   return
end
a_st=vsave[!vsave]     ; copy the vsave bin to the structure
print,'Read VSAVE= ',!vsave,' from ',!vsavefile
;
close,vsunit
free_lun,vsunit
!vs_rec.vsave=!vsave
!vsf[vsu]=!vs_rec
;                        
return
end
