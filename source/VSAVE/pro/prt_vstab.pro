;+
; NAME:
;       PRT_VSTAB
;
;            =================================================
;            Syntax: prt_vstab
;            =================================================
;
;
;   prt_vstab    prints info on the table of VSAVE files
;   ----------   
;
;                
;              
; MODIFICATION HISTORY:
; 9/08 RTR for line parameters
;-
pro prt_vstab
;       
on_error,!debug ? 0 : 2
compile_opt idl2
;
if !nvsf le 0 then begin
   print,'There are no entries in the vsave table'
   print,'Perhaps it has not been read
   return
   endif
;
for i=1,!nvsf do prt_vsinfo,i
return
end
