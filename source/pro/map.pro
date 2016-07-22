pro map,help=help
;+
; NAME:
;       MAP
;
;            =====================
;            Syntax: map,help=help
;            =====================
;
;   map   Switch to the MAP window
;   ---
;-
; V6.1 22nov2010 tmb need to modify TMBIDL to handle 3 windows 
;      seamlessly
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'map' & return & endif
;
!LINE=2             ; toggle to MAP window 
;
wset,!map_win           ; select MAP window 
wshow,!map_win,iconic=0
;
return
end
