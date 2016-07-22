;+
; NAME:
;      WRITE_ARCHIVE_CHEAD
;
;   WRITE to ARCHIVE file Spectral Line HEADER information
;   This is a modified form of much of the information in the standard
;   plot header
;
;   Outputs 'archive' which is a single string containing the following
;   information delimited by a ' ' blank
;
; 
;   INFORMATION PASSED IS:
;   archive_type,source,scan,
;
;
;   Syntax: write_archive_CHEAD,archive
;   ===================================
;
; V5.0 July 2007
;-
pro write_archive_CHEAD,archive
; 
on_error,!debug ? 0 : 2
compile_opt idl2
;
archive_type='CHEAD'
b=' '                ; force blanks between variables for later strsplit
;
; first fetch the variables from !b[0]
; turn them all to strings via =fstring(,'()') 
;
source=strtrim(string(!b[0].source),2) 
scan=fstring(!b[0].scan_num,'(I9)')                    ; beware BOZO !
;
print,'Source Name = '+ source
print,'Scan Number = '+ scan
;
archive=archive_type+b+source+b+scan+b
;
; all ARCHIVE scripts must return a single string called 'archive'
; first entry is ID of archive_type  
;
print,archive
;
flush:
return
end
