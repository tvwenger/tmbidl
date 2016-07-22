;
;   find_tr.pro     Transfers fit info to !tr_rec with
;   -----------     option to store in tr table 
;
;                  Syntax: find_tr,t_name,band=band
;                          t_name  or transition name
;                          if band is set adopts current band
;
pro find_tr,t_name,band=band
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(band) then begin
    t_name=string(!b[0].line_id)
    endif else if n_params() eq 0 then begin
                   print,'Enter a transition or band name or table entry (no quotes necessary)'
                   t_name=' '
                   read,t_name,prompt='Name: '
                   print,'Transition name set to '+strtrim(t_name,2)
               end
endelse 
i=long(t_name) ; conversion triggers i/o error 
print,'Retrieving info for transiton ',i 
goto,unpk
conversion_error: 
;
!trans=strtrim(t_name,2)
list_tr,t_name
if !trans_found eq 0 then begin
   print,'There are no preexisting entries for: ',t_name
   return
end
if !trans_found eq 1 then begin
   print,'There is only preexisting entry for: ',t_name
   i=!trans_i
   !tr_rec=!tr[i]
   unpk_tr
   return
end
print,'Which option do you want?'
read,i
unpk:
!tr_rec=!tr[i]
unpk_tr
return
end
