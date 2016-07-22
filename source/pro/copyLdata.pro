;+
; NAME:
;       copyLdata
;
;            ==============================================
;            Syntax: copyLdata, tmbidl_Ldata_filename
;            ==============================================
;
;   copyLdata  procedure to copy tmbidl data from default
;   ---------  file produced by Lmake to another place
;              This filename passed by argument:
;              tmbidl_Ldata_filename  
;
; MODIFICATION HISTORY:
;
;  v6.1 04mar2011 tmb for 11A034 book keeping
;       21mar2011 tmb added explicit print message for sanity
;
;-
pro copyldata, lsave
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if n_params() eq 0 then begin 
   print,'===================================='
   print,'Syntax: copyldata, tmbidl_Ldata_file'
   print,'===================================='
   return
endif
;
Ldata='../../data/line/Ldata.tmbidl'
;
cmd='cp '+Ldata+' '+lsave
spawn,cmd
;
print,'Copied '+Ldata+' to '+lsave
;
return
end
