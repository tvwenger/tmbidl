pro gbt_win,help=help
;+
; NAME:
;      GBT_WIN
;      gbt_win,help=help
;
;   gbt_win   create a plot window tailored to the GBT data reduction system
;   -------   creates the LINE graphics window
;-
; V4.0 July 2007
; v5.1 25aug08 tmb/lda fetch and store WID in system variable
;
; V6.1 22oct09 tmb
; V7.0  3may2013 tvw - added /help, !debug
;      21jun2013 tmb - changed window label to v7.0
; V7.1 06aug2013 tmb - changed label to v7.1 made window a tad bigger
; v8.0 18jun2015 tmb - changed label to v8.0
;
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'gbt_win' & return & endif
;
window,0,title='SPECTRAL LINE DATA --- TMBIDL V8.0', $
xsize=1000,ysize=750
wshow,0,/iconic
;
!line_win = !D.Window ; Store window ID number
;
return
end
