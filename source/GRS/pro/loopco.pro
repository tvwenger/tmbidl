;+
; NAME:
;       LOOPCO
;
;            ==============================================
;            Syntax: loopco,rec
;            ==============================================
;
;   loopco  procedure to loop GETCOFIT
;   ------   
;
;   KEYWORDS:
;
; MODIFICATION HISTORY:
; 21march2011 tmb 
;
;-
pro loopco,rec 
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if Keyword_Set(help) then begin
   print, '=============================================='
   print, 'Syntax: ;loopco'
   print, '=============================================='
   return
endif
;
if n_params() eq 0 then rec=0
loop:
getcofit,rec
print,'Completed Record # ',rec,' Keep Going? (y/n)'
pause,cans
if cans eq 'y' then begin
   rec=rec+1 & goto,loop
end
;
return
end
