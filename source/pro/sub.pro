pro sub,rec,help=help
;+
; NAME:
;       SUB
;
;            =============================================
;            Syntax: sub,rec#_currently_in_STACK,help=help
;            =============================================
;
;   sub  Subtract a record number from the stack.
;   ---        
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'sub' & return & endif
;
if n_params() eq 0 then message,'Nothing to SUBTRACT from STACK'
;
for i=0,!acount-1 do begin 
        if !astack[i] eq rec then goto, expunge
endfor
;
begin & print,'Record ',rec,' not in STACK' & return & end &
;
expunge:   for j=i,!acount-2 do begin 
                   !astack[j]=!astack[j+1]
           endfor
;
!acount=!acount-1
;
return
end

