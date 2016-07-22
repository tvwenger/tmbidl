;+
; NAME:
;      WRITE_ARCHIVE_TEMPLATE
;
;   WRITE to ARCHIVE file information packed by this procedure into
;   a single string 'archive'  which contains string formatted 
;   variables delimited by a ' ' which is used later by 
;   'read_archive' to split this record into an IDL structure.
;
;   Syntax: write_archive_template,archive
;   ======================================
;
; V5.0 July 2007
;-
pro write_archive_template,archive
; 
on_error,!debug ? 0 : 2
compile_opt idl2
;
archive_type='NAME_OF_YOUR_FORMAT'  ;  use short names as these become
                                    ;  the NAME of the structure returned
                                    ;  by 'parse_archive'
b=' '  ; force blanks between variables for later strsplit
;
; first fetch the variables from !b[0]
; turn them all to strings via =fstring(,'()') 
; e.g. 
source=strtrim(string(!b[0].source,2) 
;
nfit=fstring(nfit,'(I2)')
tsys=fstring(tsys,'(f5.1)')
;
archive=source+b+nfit+b+tsys+b
archive=archive_type+b+archive
;
; all ARCHIVE scripts must return a single string called 'archive'
; first entry is ID of archive_type FORMAT defined HERE   
;
flush:
return
end
