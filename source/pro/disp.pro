pro  disp,n,m,help=help
;+
; NAME:
;      DISP
;
;   disp   DISPlay:   SHOW buffer n and RESHOW  buffer m
;   ----   Default is SHOW !b[0]    and RESHOW !b[1]
;
;          ======================================================
;          Syntax: disp, buffer_#_SHOW, buffer_#_RESHOW,help=help
;          ======================================================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;- 
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'disp' & return & endif
;
if n_params() eq 0 then begin & n=0 & m=1 & endif &
;
copy,n,0
SHOW
copy,m,0
RESHOW
copy,9,0       ; put last SHOW buffer 9 into buffer 0
;
return
end

