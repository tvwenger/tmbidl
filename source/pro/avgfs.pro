pro avgfs,help=help
;+
; NAME:
;       AVGFS
;
;   avgfs.pro   ACCUM and AVE the records in the STACK for frequency
;   ---------   switched data 
;               Syntax: avgfs,help=help
;               -----------------------
;
; V5.0 JULY 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'avgfs' & return & endif
;
for i=0,!acount-1 do begin 
    get,abs(!astack[i]) 
    accum 
endfor 
;
; DO NOT PUT A 'SHOW' IN THIS ROUTINE!  IF YOU WANT A 'SHOW'
; THEN PUT IT IN A 'AVGFS' IN YOUR OWN DIRECTORY AND RECOMPILE
;
ave 
;
return
end
