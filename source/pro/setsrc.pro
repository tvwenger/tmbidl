pro setsrc,src,help=help
;+
; NAME:
;       SETSRC
;
;            =======================================
;            Syntax: setsrc, 'source_name',help=help
;            =======================================
;
;   setsrc  Set the source name for a SELECT search of the  
;   ------  ONLINE/OFFLINE data.
;   Useage: setsrc,'NGC3242'  <-- must pass a string  
;           setsrc, '*' is wildcard
;           Promts for input if none supplied
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setsrc' & return & endif
;
if n_params() eq 0 then begin
   print,'Source Name= no quotes needed; <CR> means wildcard'
   print
   src=' '
   read,src,prompt='Input source name: '
endif
;
!src=strtrim(src,2)
if !src eq "" or !src eq " " then !src='*'
;
print,'Source name for searches is: ' + !src
;
return
end

