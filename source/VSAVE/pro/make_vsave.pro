;+
; NAME:
;       MAKE_VSAVE
;
;            =================================================
;            Syntax: make_vsave, a_struct,vs_file_name,/nsave
;            =================================================
;
;
;   make_vsave   Create a VSAVE file using the an arbitrary structure, a_struct. 
;   ----------   Also create a log file to record if a slot has been written.
;
;                Default for no input file is !vsavefile
;
;                vs_file is entered with no extension. The first variable in the
;                        structure is used to define the vsave type and automatically
;                        added as an extension
;
;                The basic idea here is to have something parallel to nsave but with
;                        different structures
;
;                The log file is automatically created
;  
;                The keyword nsave creates a standard tmbidl save file              
;              
; MODIFICATION HISTORY:
; 9/08 RTR for line parameters
;-
pro make_vsave,a_st,vsfile_in,nsave=nsave
;       
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 then begin
   print,'Usage: make_vsave,a_structure,vs_file_name'
   print,'     : a_structure is required'
   return
   endif
;
;  create the VSAVE file
;
if keyword_set(nsave) then begin
   vs_type='LNS'
endif else begin
   vs_type=strtrim(string(a_st.vs_type),2)
endelse
newvsf=!nvsf+1
if !nvsf gt 0 then begin
   for i=0,!nvsf-1 do begin
      vst=strtrim(string(!vsf[i].vs_type),2)
      print,i,' vs_type=',vs_type,' table type=',vst
      if strmatch(vs_type,vst) then begin
         print,'Existing VSAVE of type:',vs_type
         prt_vsinfo,i+1
         print,'replace? (r); inactivate? (i); keep? (k)
         ans=get_kbrd(1)
         case ans of
            'r': begin
               newvsf=i+1
            end
            'i': !vsf[i].vs_active=0
            'k': !vsf[i].vs_active=1+!vsf[i].vs_active
            else: begin
               print,'Invalid reply'
               return
            end
         endcase
      end
   end
end
if newvsf gt !nvsf_max then begin
   print,'This request will exceed the max number of VSAVE files'
   return
end
print,'Creating vsave file of type: ',vs_type
if n_params() eq 1 then begin
   vsfile=' '
   print,'Enter file name with no extension'
   read,vsfile
end
if n_params() eq 2 then begin
   vsfile=vsfile_in
end
vsfile=strtrim(vsfile,2)
vsfile_pre=vsfile
vsfile=vsfile+'.'+vs_type
vslog=vsfile+'.key'
if findfile(vsfile) eq '' then begin
   print,vsfile+' does not exist. File will be created'
   openw,vslun,vsfile,/get_lun
   openw,loglun,vslog,/get_lun
   print,'How many records should I allocate for ',vsfile
   rec_max=0L
   read,rec_max
;
   vs_template=replicate(a_st,rec_max)  ; 
   writeu,vslun,vs_template
   vs_log=intarr(rec_max)
   vs_log[0:rec_max-1]=0
   writeu,loglun,vs_log
   endif else begin
      print,vsfile+' already exits'
      return
   endelse
;
print
print,'Made VSAVE file '+vsfile+' with '+fstring(rec_max,'(i5)')+' slots'
print,'Made VSAVE LOG file '+vslog
print
; 
if newvsf gt !nvsf then !nvsf = newvsf
i=newvsf-1
!vsf[i].vs_type=byte(vs_type)
!vsf[i].vs_file=byte(vsfile_pre)
!vsf[i].vs_active=1
!vsf[i].vs_lun=vslun
!vsf[i].vs_log_lun=loglun
!vsf[i].vs_protect=1
!vsf[i].vsave=0
!vsf[i].lastvs=0
!vsf[i].vsmax=rec_max
write_vsinfo
close,vslun
close,loglun
free_lun,vslun
free_lun,loglun
;
return
end







