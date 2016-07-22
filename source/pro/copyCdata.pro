;+
; NAME:
;       copyCdata
;
;            ==============================================
;            Syntax: copyCdata, tmbidl_Cdata_filename
;            ==============================================
;
;   copyCdata  procedure to copy tmbidl data from default
;   ---------  file produced by Cmake to another place
;              This filename passed by argument:
;              tmbidl_Cdata_filename  
;
; MODIFICATION HISTORY:
;
;  v6.1 04mar2011 tmb for 11A034 book keeping
;       21mar2011 tmb added print info for sanity
;
;-
pro copycdata, csave
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if n_params() eq 0 then begin 
   print,'===================================='
   print,'Syntax: copyCdata, tmbidl_Cdata_file'
   print,'===================================='
   return
endif
;
Cdata='../../data/continuum/Cdata.tmbidl'
;
cmd='cp '+Cdata+' '+csave
spawn,cmd
;
print,'Copied '+Cdata+' to '+csave
;
return
end
