pro close_files,help=help
;+
; NAME:
;      CLOSE_FILES
;      close_files,help=help
;
;   close_files   Closes ALL the TMBIDL datafiles using their !unitnames.
;   -----------   
;                 Synonym for CLOSE_DATAFILE because TMB can never remember
;                 that name....
;
; V5.1 26aug08 tmb
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'close_files' & return & endif
;
close_datafile
;
return
end
