pro write_archive,fname,create_flag,help=help
;+
; NAME:
;       WRITE_ARCHIVE
;
; write_archive   archives information in a user specified file !archivefile
; -------------   writes a single formatted string with info from
;                 @archive scripts chosen by !archivetype
;
; MAKE SURE TO SET '!archivetype' BEFORE INVOKING THIS PROCEDURE !
; Use 'setarchive,type' to do this
; Available formats are:
;          type = 0  LHEAD     Spectral Line Header info
;                 1  CHEAD     Continuum Header info
;                 2  FITINFO   Baseline and Gaussian fit info
;                 3  CUSTOM    Custom format
; 
;       =====================================================================
;       Syntax: write_archive,fully_qualified_file_name,create_flag,help=help
;       =====================================================================
;
;               default file is !archivefile
;               if 'create' is supplied (anything will do) makes file 
;               named input fully_qualified_file_name
;
;               ONLY SUPPLY 'fully_qualified_file_name' IF IT ALREADY EXISTS
;
;               if !flag OR !verbose then prints this information to screen
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'write_archive' & return & endif
;
default='../archive/archive'      ; default name assigned in INIT_FILES_V5.0
if n_params() eq 1 then !archivefile=fname  
if n_params() eq 2 then begin
                   !archivefile=fname
                   ans='n'
                   goto,make_archive
                   end
;
; Define the ARCHIVE file first time invoked: either create a new one 
;                                             or attach an existing one
;

if strmatch(!archivefile,default) then begin
   print
   print,'Must initialize ARCHIVE file !'
   fname=' '
   read,fname,prompt='Enter fully qualified file name (no quotes!): '
   fname=strtrim(fname,2)
 ;
   print,'Does this ARCHIVE file: '+fname+' already exist?  (y/n)'
   ans=get_kbrd(1)
   make_archive:
   case ans of
       'n':begin
           openw,!archiveunit,fname
           !archivefile=fname
           print,'Creating ARCHIVE named ' + fname
           printf,!archiveunit,'==========================================='
           printf,!archiveunit,'     TMBIDL ARCHIVE File for Epoch: ' + string(!this_epoch)
           printf,!archiveunit,'==========================================='
           close,!archiveunit
           end
      else:begin
           !archivefile=fname
           print,'Attaching existing ARCHIVE file named ' + fname 
           end
   endcase
end
;
; Fetch the information to be archived and string format it. 
; This is individually tailored via a @write_archive_... scripts
; that are in ../archive/ directory
;
archiveformat=['LHEAD','CHEAD','FITINFO','CUSTOM']
;
case !archivetype of 
                  0:write_archive_LHEAD,archive
                  1:write_archive_CHEAD,archive
                  2:write_archive_FITINFO,archive
                  3:write_archive_CUSTOM,archive
               else:begin
                    print,'Invalid ARCHIVE format ! '
                    goto,flush
                    end
endcase
;
; script produced a single string named 'archive' 
;
openu,!archiveunit,!archivefile,/append
printf,!archiveunit,archive
close,!archiveunit
;
flush:
return
end

