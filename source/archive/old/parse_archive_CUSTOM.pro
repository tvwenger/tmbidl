;+
; NAME:
;       PARSE_ARCHIVE_CUSTOM
;
; Parse an input archive record structure in CUSTOM format 
; into meaningful data. Returns a named structure 'rec_out'
; that has meaningful tag names and correct variable type.
;     
; Syntax: parse_archive_CUSTOM,archive_structure_in,parsed_structure_out
; ======================================================================
;
; V5.0 July 2007
;-
pro parse_archive_CUSTOM,rec_in,rec_out
;
on_error,!debug ? 0 : 2
compile_opt idl2
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
