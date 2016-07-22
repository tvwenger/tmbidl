pro close_datafile,help=help
;+
; NAME:
;      CLOSE_DATAFILE
;      close_datafile,help=help
;
;   close_datafile   Closes ALL the TMBIDL datafiles using their
;   --------------   !unitnames.
;                    Useful when i/o error occurs during IDL session.
;                    IDL doesn't care if you close an already closed 
;                    unit so close them all for optimal utility.
;
; V5.0 July 2007  TMB modifies to close ALL datafiles.
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'close_datafile' & return & endif
;
close,!onunit       ; ONLINE file
close,!offunit      ; OFFLINE file
close,!dataunit     ; DATA file (most likely SDFITS file)
close,!nsunit       ; NSAVE file
close,!messunit     ; MESSAGE file
close,!archiveunit  ; ARCHIVE file
close,!cfitunit     ; CONTINUUM FITS file
close,!lfitunit     ; LINE FITS file
;
return
end
