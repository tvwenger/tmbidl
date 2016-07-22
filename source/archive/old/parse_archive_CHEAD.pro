;+
; NAME:
;       PARSE_ARCHIVE_CHEAD
;
; Parse an input archive record structure in  CONTINUUM HEADER format 
; into meaningful data. Returns a named structure 'rec_out'
; that has meaningful tag names and correct variable type.
;     
; Syntax: parse_archive_CHEAD,archive_structure_in,parsed_structure_out
; =====================================================================
;
; V5.0 July 2007
;-
pro parse_archive_CHEAD,rec_in,rec_out
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
rec=rec_in
name='CHEAD'
;
print,'CHEAD is not yet implemented! '
;
flush:
return
end
