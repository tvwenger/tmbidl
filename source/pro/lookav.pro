pro lookav,help=help
;+
; NAME:
;       LOOKAV
;
;            ========================
;            Syntax: lookav,help=help
;            ========================
;
;   lookav   Select and average all receivers
;   ------   STACK must be filled. Invokes QAV.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'lookav' & return & endif
;
rx=['1','2','3','4','5','6','7','8','9','10']
;
for i=0,!recs_per_scan/2-1 do begin 
      qav,rx[i] 
      ans=get_kbrd(1) 
      endfor 
;
return
end
