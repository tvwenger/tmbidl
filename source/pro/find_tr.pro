pro find_tr,t_name,band=band,help=help
;
;   find_tr.pro     Transfers fit info to !tr_rec with
;   -----------     option to store in tr table 
;
;                  Syntax: find_tr,t_name,band=band,help=help
;                          t_name  or transition name
;                          if band is set adopts current band
; V7.0 3may2013 tvw - added /help, !debug
;
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'find_tr' & return & endif
;
if keyword_set(band) then begin
    t_name=string(!b[0].line_id)
    endif else begin
        if n_params() eq 0 then begin
            print,'Enter a transition or band name or table entry (no quotes necessary)'
            t_name=' '
            read,t_name,prompt='Name: '
            print,'Transition name set to '+strtrim(t_name,2)
        endif
    endelse
on_ioerror,conversion_error,!debug ? 0 : 2
i=long(t_name) ; conversion triggers i/o error 
print,'Retrieving info for transiton ',i 
goto,unpk
conversion_error,!debug ? 0 : 2
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
