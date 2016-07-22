pro open_archive,action,fname,help=help
;+
; NAME:
;      OPEN_ARCHIVE
;
;      open_archive  Opens an ARCHIVE file
;      ============
;                    Syntax: open_archive,action,fully_qualified_file_name,help=help
;                    ===============================================================
;
;      action =  0   open file for reading, skipping past header
;                    default is reading
;                1   open file for appending writing
;
;      ONLY SUPPLY 'fully_qualified_file_name' IF IT ALREADY EXISTS
;-
; V5.0 July 2007
;  5.1 Jan  2008 TMB modified to do two things
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'open_archive' & return & endif
;
if n_params() lt 2 then fname=!archivefile
!archivefile=fname
if n_params() eq 0 then action=0  ; default is reading
;
if not !batch then print,'Opening existing ARCHIVE file named ' + fname 
;
find_file,!archivefile
openr,!archiveunit,!archivefile
a=' '
kount=0
while eof(!archiveunit) ne 1 do begin
      readf,!archiveunit,a
      kount=kount+1
endwhile
!num_archive_recs=kount-3    ;  adjust for header records
close,!archiveunit
;!num_archive_recs_read=0     ;  counter for this ARCHIVE file NOT USED
;
if not !batch then $
   print,'File '+!archivefile+' contains '+fstring(kount-3,'(I6)')+' total records'
;
case action of 
            0: begin
               openr,!archiveunit,!archivefile
;              three line header for all ARCHIVE files
               hdr1=' ' & hdr2=' ' & hdr3=' '    
               readf,!archiveunit,hdr1
               readf,!archiveunit,hdr2
               readf,!archiveunit,hdr3
               if not !batch then begin
                  print,'Reading this file: '
                  print,hdr1 & print,hdr2 & print,hdr3 & print
               endif
               end 
            1: begin
               openu,!archiveunit,!archivefile,/append
               if not !batch then print,'Appending data to file '+!archivefile
               end
         else: begin
               print,'Not a valid ARCHIVE file action!' 
               return
           end
endcase
;                             ;
return
end

