;+
; NAME:
;       PRT_LPTAB
;
;            =================================================
;            Syntax: prt_lptab,n1,n2,/stack
;            =================================================
;
;
;   prt_lptab    prints a table of line parameters from an LP VSAVE file
;   ----------   
;                n1, n2 are first and last bins in a sequence
;                if /stack is set uses numbers stored in !vs_stack
;
;
; STACK OPTIONS TO BE ADDED               
;              
; MODIFICATION HISTORY:
; 9/08 RTR for line parameters
;-
pro prt_lptab,n1,n2,stack=stack
;       
on_error,!debug ? 0 : 2
compile_opt idl2
;
for i=n1,n2 do begin
   lp=!lp_blk
   getvs,lp,i
   !lp_rec=lp
   prt_lp1
end
return
end
