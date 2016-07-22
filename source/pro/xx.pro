pro xx,pause=pause,charsize=charsize,help=help
;+
; NAME:
;       XX
;
;     ==================================================
;     SYNTAX: xx,pause=pause,charsize=charsize,help=help
;     ==================================================
;
;  xx    Renaming of SHOW procedure
;  --
;
;  KEYWORDS:
;            charsize - charsize for plotting stuff
;                       default is 2.0
;
;            pause    - if set pause after plot
;               
;-
; V5.0 July 2007
;      12aug08 tmb added /pause feature
;      tvw 30jul2012 - added charsize keyword
;
; V7.0 03may2013 tvw - added /help, !debug
;
;-
if keyword_set(help) then begin & get_help,'xx' & return & endif
;
erase
show,charsize=charsize
;
if Keyword_Set(pause) then pause
;
return
end
