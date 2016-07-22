pro getpl,nsave,help=help
;+
; NAME:
;       GETPL
;
;   getpl,nsave,help=help    Study of 3He Pseudo Line 
;   -----------
;
;-
; V5.0 June 2007 
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if keyword_set(help) then begin & get_help,'getpl' & return & endif
;
getns,nsave
mk
xxx
;
return
end
