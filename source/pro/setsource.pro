pro setsource,src,help=help
;+
; NAME:
;       SETSOURCE
;
;            ==========================================
;            Syntax: setsource, 'source_name',help=help
;            ==========================================
;
;   setsource   SYNONYM FOR 'SETSRC' 
;   ---------   
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setsource' & return & endif
;
if n_params() eq 0 then begin
   print,'Source Name= no quotesneeded; <CR> means wildcard'
   print
   src=''
   read,src,prompt='Set Source Name: '
endif
;
!src=strtrim(src,2)
if !src eq "" or !src eq " " then !src='*'
;
print,'Source name for searches is: ' + !src
;
return
end
