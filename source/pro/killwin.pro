PRO Killwin,help=help
;+
; NAME:
;       KILLWIN
;
;            =========================
;            Syntax: killwin,help=help
;            =========================
;
; killwin   Kill off all the windows. 
; -------
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'killwin' & return & endif
While !D.Window NE -1 DO WDelete, !D.Window
END
