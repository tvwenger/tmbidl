pro cont,help=help
;+
; NAME:
;      CONT
;
;            ======================
;            Syntax: cont,help=help
;            ======================
;
;   cont   Switch to the CONTinuum data reduction mode.
;   ----
;
; V5.0 July 2007 
; modified by tmb 11aug07 for !nchan fix 
; feb08 tmb for !tp switch
; aug08 tmb/lda Changed to window system variables 
; V7.0 3may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cont' & return & endif
;
!LINE=0             ; toggle to CONT package
!tp=0               ; toggle off total power search for OFF scans during GET
!nchan=!c_pts       ; number of points in continuum scan
;
wset,!cont_win            ; get CONT window & iconify LINE window
wshow,!cont_win,iconic=0
wshow,!line_win,/iconic
;
return
end
