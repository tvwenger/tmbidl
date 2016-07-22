pro avgns,help=help
;+
; NAME:
;       AVGNS
;
;   avgns.pro   ACCUM and AVE the NSAVE records in the STACK
;   ---------
;               Syntax: avgns,help=help
;               =======================
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'avgns' & return & endif
;
for i=0,!acount-1 do begin 
    getns,!astack[i]
    accum 
endfor 
;
; DO NOT PUT A 'SHOW' IN THIS PROCEDURE!
; IF YOU WANT A SHOW IN 'AVGNS' MODIFY PROC 
; AND PUT IT IN YOUR TEST DIRECTORY AND RECOMPILE 'AVGNS'
; FROM THERE
;
ave 
;
return
end
