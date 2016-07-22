pro cgbt_win,help=help
;+
; NAME:
;       CGBT_WIN
;       cgbt_win,help=help
;
;   cgbt_win.pro   Create a TMBILD plot window for continuum data.
;   ------------   
;
; V5.0 July 2007
; v5.1 25aug08 tmb/lda fetch and store WID in system variable
;
; V6.1 22oct09 tmb
;
; V7.0  3may2013 tvw - added /help, !debug
;      21jun2013 tmb - changed window label to v7.0
; V7.1 06aug2013 tmb - changed label to v7.1 made tad larger
; v8.0 18jun2015 tmb - changed label to v8.0
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cgbt_win' & return & endif
;
window,4,title='CONTINUUM DATA --- TMBIDL V8.0', $
xsize=1000,ysize=750
wshow,0,/iconic
;
!cont_win = !D.Window ; Store window ID number
;
return
end
