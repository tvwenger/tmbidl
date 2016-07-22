pro ksr,help=help
;+
; NAME:
;       KSR
;
;            =====================
;            Syntax: ksr,help=help
;            =====================
;
;   ksr  Continous version of KURSOR.             
;   ---  
;        Left-click mouse ==> KURSOR executes Right-click mouse ==> EXIT and return
;
;             !mouse.button=1L <== left click
;                           2      middle click
;                           4      right click
;
;   'Continous cursor activated:  Left-click for cursor reads; Right-click to exit'
;
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'ksr' & return & endif
;
print,'Continous cursor activated:  Left-click for cursor reads; Right-click to exit'
;
while (!mouse.button ne 4) do kursor
!mouse.button=1
;
return
end
