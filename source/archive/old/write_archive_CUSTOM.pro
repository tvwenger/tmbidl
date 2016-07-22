;+
; NAME:
;      WRITE_ARCHIVE_CUSTOM
;
;   WRITE to ARCHIVE file information packed by this procedure into
;   a single string 'archive'  which contains string formatted 
;   variables delimited by a ' ' which is used later by 
;   'read_archive' to split this record into an IDL structure.
;
;   Syntax: write_archive_CUSTOM,archive
;   ====================================
;
; V5.0 July 2007
;-
pro write_archive_CUSTOM,archive
; 
on_error,!debug ? 0 : 2
compile_opt idl2
;
archive_type='CUSTOM'  ;  use short names as these become
                                    ;  the NAME of the structure returned
                                    ;  by 'parse_archive'
b=' '  ; force blanks between variables for later strsplit
;
; first fetch the variables from !b[0]
; turn them all to strings via =fstring(,'()') 
; e.g. 
;
print,'CUSTOM is not yet implemented !'
;
flush:
return
end
