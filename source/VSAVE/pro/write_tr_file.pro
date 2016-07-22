;+
; NAME:
;       WRITE_TR_FILE
;
;   write_tr_file.pro     Writes transition fit info to a file
;
;                  Syntax: write_tr_file,f_name
;                          f_name = file name
;                                   if no argument uses !tr_file
;
;-
pro write_tr_file,f_name
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
   print,'Create '+f_name+' ?(y)'
   ans=get_kbrd(1)
   if ans ne 'y' then retall
   openw,lun,f_name,/get_lun
   tr_lun=lun
endif else begin
   openu,lun,f_name,/get_lun
   tr_lun=lun
endelse
print,'Using lun '+fstring(tr_lun,'(I4)')
!tr_file=strtrim(f_name,2)
nwrt=0
ndel=0
wrtdel=0
for i=0,!trans_n-1 do begin
   tr=strtrim(string(!tr[i].trans),2)
   wrtit=1
   pos=strpos(tr,'#')
   if pos ge 0 then begin
      ndel=ndel+1
      if ndel le 1 then begin
         print,'Table contains transitions flagged for deletion'
         print,'Write these to the file? (y)
         ans=get_kbrd(1)
         if ans eq 'y' then wrtdel=1
      endif
      if not wrtdel then wrtit=0
  end
   if wrtit then begin
      writeu,tr_lun,!tr[i]
      nwrt=nwrt+1
   end
end
!trans_n=nwrt
print,'File contains '+fstring(nwrt,'(i4)')+' transitions'
if ndel gt 0 then begin
   del_com=' deleted'
   if wrtdel then del_com='copied'
   print,'There were '+fstring(ndel,'(i4)')+' flagged transitions '+del_com
end
close,tr_lun
free_lun,tr_lun
return
end
