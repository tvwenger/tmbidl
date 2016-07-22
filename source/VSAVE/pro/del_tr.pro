;
;   del_tr.pro     marks an entry in the transition table for deletion
;   ----------     Does not actually delete entry; sets a flag
;
;                  Flagged entries can be deleted when the file is
;                  written
;
;                  Syntax: del_tr
;                         
;
pro del_tr
;
on_error,!debug ? 0 : 2
compile_opt idl2
list_tr
print,'Which  transition entry to flag for deletion'
read,n_del
t_del=strtrim(string(!tr[n_del].trans),2)
t_del=t_del+'#'
!tr[n_del].trans=byte(t_del)
return
end
