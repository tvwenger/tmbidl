pro fixplot,help=help
;+
; NAME:
;       FIXPLOT
;
;            ========================
;            Syntax: fixplot,help=help
;            ========================
;
;   fixplot  Fixes the plotter bug when a bad mouse read kills the plot
;   -------  We've all seen this--the plot becomes dashlined and funky
;            TMB never remembers this ASTROLIB RESET_RDPLOT.pro
;            command, so maybe calling it this will fix his (this) issue

;
; MODIFICATION HISTORY:
; V6.1 23jan2010 TMB 
; V7.0 3may2013 tvw - added /help, !debug
; v8.0 17jun2015 lda/tmb added device,decomposed=0
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'fixplot' & return & endif
;
RESET_RDPLOT
device,decomposed=0
;
return
end
