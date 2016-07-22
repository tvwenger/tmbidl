;
;   read_tr_file.pro     Writes transition fit info to a file
;   ----------------
;                        Syntax: read_tr_file,f_name
;                                f_name = file name
;                                   if no argument uses !tr_file
;
pro read_tr_file,f_name
;
on_error,!debug ? 0 : 2
compile_opt idl2
if n_params() eq 0 then begin
                   f_name=strtrim(!tr_file,2)
                   print,'No argument given. Using '+strtrim(!tr_file,2)
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
   return
endif else begin
   openu,lun,f_name,/get_lun
   tr_lun=lun
   !tr_file=f_name
endelse
print,'Using lun '+fstring(tr_lun,'(I4)')
nrd=0
tr_rec=!tr_rec
while not eof(tr_lun) and nrd lt !trans_max do begin
   readu,tr_lun,tr_rec
   nrd=nrd+1
   !tr[nrd-1]=tr_rec
endwhile
!trans_n=nrd
print,'Transition file read and stored with'+fstring(nrd,'(i4)')+' transitions'
close,tr_lun
free_lun,tr_lun
return
end
