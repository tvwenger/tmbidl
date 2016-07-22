pro find_file,fname,help=help
;+
; NAME:
;      FIND_FILE
;
;   find_file   Does this file_name exist?
;   ---------   Uses IDL built_in procedure findfile()
;
;        ======================================================
;        Syntax: find_file, fully_qualified_file_name,help=help
;        ======================================================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'find_file' & return & endif
;
if n_params() eq 0 then begin
                        print,'Input fully_qualified_file_name (no quotes)'
                        fname=''
                        read,fname,prompt='Look for file named '
                        fname=strtrim(fname,2)
                        endif
;
if findfile(fname) eq '' then begin
                        print,'File '+fname+' not found'
                        retall
                        endif
 ;
return
end


