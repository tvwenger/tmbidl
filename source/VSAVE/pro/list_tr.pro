;
;   list_tr.pro    Lists contents of current transition array
;
;                  Syntax: list_tr,t_name,/all
;                          t_name  transition name. If t_name is
;                                  absent, all transitions are listed
;                          keyword /all lists `deleted' entries as well
;
pro list_tr,t_name,all=all
;
on_error,!debug ? 0 : 2
compile_opt idl2
listall=0
!trans_found=0
if n_params() ne 1 then begin
                   print,'Listing all transitions'
                   t_name=' '
                   listall=1
                endif
if !trans_n le 0 then begin
   print,'The transition table is empty'
   return
end
!trans_i=0
t_name=strtrim(t_name,2)
t_name1=strmid(t_name,0,1)
if t_name1 eq '?' then begin
   lid=strtrim(string(!b[0].line_id),2)
   t_name=strmid(lid,0,3)
   print,'All transitions for band '+t_name
end
print,'   #    trans     band  ng          comment'
for i=0, !trans_n-1 do begin
   tr=strtrim(string(!tr[i].trans),2)
   tr0=tr
   band=strtrim(string(!tr[i].band),2)
   if t_name1 eq '?' then begin
      lid=band
      tr=strmid(lid,0,3)
   end
   ng=!tr[i].ngauss
   trcom=strtrim(string(!tr[i].comment),2)
   listit=0
   if listall then begin
      listit=1
   endif else begin
      t_comp=strmid(tr,0,strlen(t_name))
      b_comp=strmid(band,0,strlen(t_name))
      listit=0
      if strmatch(t_comp,t_name) then listit=1
      if strmatch(b_comp,t_name) then listit=1
      if listit eq 1 then begin
         !trans_found=!trans_found+1
         !trans_i=i
      end
   endelse
   if not keyword_set(all) then begin
      pos=strpos(tr,'#')
      if pos ge 0 then listit=0
   end
if listit then $
   print,i,tr0,band,ng,trcom,format='(i4,1x,a8,1x,a8,i4,1x,a16)'
end
;
return
end
