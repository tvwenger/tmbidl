pro parse_archive_CUSTOM,rec_in,rec_out,help=help
;+
; NAME:
;       PARSE_ARCHIVE_CUSTOM
;
; Parse an input archive record structure in CUSTOM format 
; into meaningful data. Returns a named structure 'rec_out'
; that has meaningful tag names and correct variable type.
;     
; =======================================================================
; Syntax:
; parse_archive_CUSTOM,archive_structure_in,parsed_structure_out,$
;                      help=help
; ========================================================================
;
; V5.0 July 2007
; V7.0 May 2013 tmb/tvw added /help and updated error handling
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'parse_archive_CUSTOM' & return & endif
;
rec=rec_in
name='CUSTOM'
;
print,'CUSTOM is not yet implemented! '
;

;
rec_out=arc
;
flush:
return
end
