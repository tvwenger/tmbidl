;+
; NAME:
;      INCRSTK
;
;   incrstk.pro    Increments each entry in the stack by inc
;   -----------    Useful, eg, to step from one rx to next
;                
;  
;        Syntax:  incrstk,inc 
;        ===========================================
;
;
;
;
; V5.1 July 2008 rtr
;-
pro incrstk,inc
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 then begin
                   print,'INCRSTK requires an argument'
                   print,'Syntax: incrstk,inc'
                   return
                   endif
;
if !acount eq 0 then begin
                print,'STACK is empty'
                return
             endif
;
for i=0, !acount-1 do begin
    !astack[i]=!astack[i]+inc
 endfor
;
return
end

