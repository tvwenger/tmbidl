pro tellstk,help=help
;+
; NAME:
;       TELLSTK
;
;            =========================
;            Syntax: tellstk,help=help
;            =========================
;
;
;   tellstk   Print contents of STACK. 
;   -------
;                 TELLSTacK
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'tellstk' & return & endif
;
if !acount eq 0 then begin
                 print,'STACK is empty'
                 return
endif
;
print,'STACK has !acount= ',!acount,format='(a19,i6)'
print,!astack[0:!acount-1],format='(10i6)'
;
return
end
