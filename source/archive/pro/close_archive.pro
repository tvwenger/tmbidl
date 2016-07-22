pro close_archive,help=help
;+
; NAME:
;      CLOSE_ARCHIVE
;
;      close_archive  Closes the currently open ARCHIVE file
;      =============
;                     Syntax: close_archive,help=help
;                     ===============================
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'close_archive' & return & endif
;
close,!archiveunit
;
return
end

