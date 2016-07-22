;+
; NAME:
;       SUM1_STK
;
;            ======================
;            Syntax: sum1_stk, tabfile 
;            ======================
;
;   sum1_stk    Prints a singal line of info about a spectral line pair
;   --------    for each entry in the stack
;               if tabfile is given it also writes to file=tabfile
;        
;        
;
;  V5. July 2008
;-
pro sum1_stk,tabfile 
;
on_error,!debug ? 0 : 2
compile_opt idl2
luntab=0L
if (n_params() eq 1) then begin
                          print,'Table being written to file ',tabfile
                          openw,luntab,tabfile,/get_lun
                          print,'logical unit is ',luntab
                          endif
if (!acount eq 0) then begin
                       print,'The STACK is empty'
                       return
                    endif
print,"Source              LID   Scan  Rec  Date         HA  EL  TsysON TsysOFF"
if (luntab gt 0) then begin
                      printf,luntab,"Source              LID   Scan  Rec  Date         HA  EL  TsysON TsysOFF"
                      endif
for i = 1, !acount do begin
   sum1,!astack[i-1],luntab
endfor
;
if luntab gt 0 then free_lun,luntab
return
end
