;+
; NAME:
;       TEST
;
; write_archive   archives information in a user specified file !archivefile
; -------------   writes a single formatted string with info from @archive
;
;              size,nfit,nunit,nrset,nregion,ngauss,a_gauss, g_sigma
;
;              'size' is size (bytes) of this information
;              'nunit' are the NREGION units
;
;               Syntax: write_archive,fully_qualified_file_name
;               ===============================================
;
;               default file is !archivefile
;
;               ONLY SUPPLY 'fully_qualified_file_name' IF IT ALREADY EXISTS
;
;               if !flag OR !verbose then prints this information to screen
;
; V5.0 July 2007
;-
pro arcwrite
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
;
@/idl/idl/archive/write_archive_header
;
;
return
end

