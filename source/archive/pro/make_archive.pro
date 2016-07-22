pro make_ARCHIVE,fname,fheader,help=help
;+
; NAME:
;       MAKE_ARCHIVE
;
; make_archive   creates an ARCHIVE file !archivefile
; ------------   prompts for input string to annotate file
;                and then writes a three record file header
;
;       ====================================================================
;       Syntax: make_archive,fully_qualified_file_name,file_header,help=help
;       ====================================================================
;
;               prompts for file name if none provided
;               prompts for file header annotation if none provided
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'make_ARCHIVE' & return & endif
;
defaultheader='     TMBIDL ARCHIVE File for Epoch: ' + string(!this_epoch)
banner='========================================'
banner=banner+banner
;
if n_params() eq 0 then begin
   print
   print,'Must initialize ARCHIVE file !'
   fname=' '
   read,fname,prompt='Enter fully qualified file name (no quotes!): '
   !archivefile=fname
   archiveheader=defaultheader
end
;
if n_params() eq 1 then begin
   !archivefile=fname 
   archiveheader=defaultheader
endif
;
if n_params() eq 2 then begin
   !archivefile=fname
   archiveheader=fheader
   ans='n'
   goto,make_archive
end
;
print,'Default annotation for this ARCHIVE file = '+fname+' header is: '
print
print,archiveheader
print
print,'Do you wish to change this header annotation? (y/n)'
ans=get_kbrd(1)
;
make_archive:
case ans of
     'y':begin
         fheader=' '
         read,fheader,prompt='Enter file header annotation (no quotes!): '
         archiveheader=fheader
         openw,!archiveunit,fname
         print,'Creating ARCHIVE named ' + fname
         printf,!archiveunit,banner
         printf,!archiveunit,archiveheader
         printf,!archiveunit,banner
         close,!archiveunit
         end
    else:begin   ; anything but 'y' create with default header
         openw,!archiveunit,fname
         print,'Creating ARCHIVE named ' + fname
         printf,!archiveunit,banner
         printf,!archiveunit,archiveheader        
         printf,!archiveunit,banner
         close,!archiveunit
         end
endcase
;
flush:
return
end

