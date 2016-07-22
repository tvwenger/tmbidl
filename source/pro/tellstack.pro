pro tellstack,help=help
;+
; NAME
;      TELLSTACK
;      tellstack,help=help
;
;   tellstack.pro   synonym for 'tellstk'
;   -------------
; V5.0 July 2007     
; V7.0 03may2013 tvw - added /help, !debug 
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'tellstack' & return & endif
;
tellstk
;
return
end


