pro read_archive,archive_structure,help=help
;+
; NAME:
;       READ_ARCHIVE
;
; read_archive   Reads a single record of archive information stored 
; ------------   in a user specified file !archivefile as creates
;                an anonymous structure 'archive_structure'
;                Does this in a very general way so the records in 
;                the ARCHIVE file need not be identical.
;                Must invoke proper translation of the returned
;                structure 'archive_structure'
;         ================================================
;         Syntax: read_archive,archive_structure,help=help
;         ================================================
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
on_ioerror,oops
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'read_archive' & return & endif
;
; Fetch an arbitrary record from the archive and make it into a structure
;     
buff=' '
readf,!archiveunit,buff
if !verbose then print,buff
;
xbuff=strsplit(buff,' ',count=cols,/extract)
if !verbose then $
   print,'Number of variables in this record is '+fstring(cols,'(I3)')
;
strname='arc'                ; name of data structure
tag_names=indgen(cols)       ; must supply a unique tag name
tag_names=string(tag_names)
;
tag=tag_names[0]             ; first make the named array
var=xbuff[0]
case (test_for_string(var)) of
     0:rec=create_struct(name=strname,tag,0.0d)
     1:rec=create_struct(name=strname,tag,' ')
endcase
;
for i=1,cols-1 do begin      ; then fill in the rest of the columns
      var=xbuff[i]
      tag=tag_names[i]
      case (test_for_string(var)) of
           0: rec=create_struct(rec,tag,0.0d)
           1: rec=create_struct(rec,tag,' ')
      endcase
endfor
;
if !verbose then print,rec
; now fill the structure
;
for i=0,cols-1 do begin
      var=xbuff[i]
      case (test_for_string(var)) of
           0: rec.(i) = double(var)
           1: rec.(i) = var
      endcase
endfor
;
if !verbose then print,rec
;
; now return this structure
;
archive_structure=rec
goto,finish
;
oops:
print,'I/O error: likely EOF on ARCHIVE file = '+!archivefile
print,!error_state.msg
;
finish:
return
end

