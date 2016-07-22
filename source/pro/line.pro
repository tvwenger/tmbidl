pro line,help=help
;+
; NAME:
;       LINE
;
;            ======================
;            Syntax: line,help=help
;            ======================
;
;   line   Switch to the LINE data reduction mode.
;   ----
;-
; V5.0 July 2007
; modified 11aug07 by tmb for !nchan 
; Feb 08 tmb for !tp switch
; aug08 tmb/lda Changed to window system variables 
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'line' & return & endif
;
!LINE=1             ; toggle to LINE package
!tp=1               ; toggle on total power search for OFF scans during GET
                    ; or FETCH.  Need to defeat for FS data
!nchan=!data_points ; number of data points in line mode
;
wset,!line_win              ; get LINE window & iconify the CONT window
wshow,!line_win,iconic=0
wshow,!cont_win,/iconic
;
return
end
