pro cavgstk,help=help
;+
; NAME: 
;       CAVGSTK
;
;   cavgstk   ACCUM and AVE the CONTINUUM records in the STACK
;   -------   (or any records that are NOT FS or TP pairs)
;
;                 Sytax: cavgstk,help=help
;                 ------------------------                               
;
; V5.0 Jan 2008 TMB
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cavgstk' & return & endif
;
; DO NOT PUT A 'SHOW' IN THIS PROCEDURE!
; IF YOU WANT A SHOW, PUT A MODIFIED PROC IN YOUR TEST DIRECTORY
;
for i=0,!acount-1 do begin 
      get,abs(!astack[i]) 
      accum 
endfor 
ave 
;
return
end
