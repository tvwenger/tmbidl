;+
;NAME
;   PAUSEX
;  
;            ===============================================
;            Syntax: pausex
;            ===============================================
;
;    pausex  Pauses and gives chance to exit
;
;    rtr 06/09
;
;-
pro pausex,ans
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
print,'type x to exit procedure; anything else to continue'
ans=' '
ians=1
pause,ans,ians
;
return
end
