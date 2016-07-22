pro jpeg,fname,help=help,jpeg=jpeg,png=png
;+
; NAME:
;       JPEG
;
;            ==============================================
;            Syntax: jpeg,fname,help=help,jpeg=jpeg,png=png
;            ==============================================
;
;   jpeg  procedure to capture the graphics screen and 
;   ----  write it out as a JPEG file named FNAME.jpg:
;         '../../jpeg/fname.jpg'
;
;         if FNAME omitted default is 'idl.jpg' in
;         directory !jpeg_file which is '../../jpeg/'
;        
;
;   KEYWORDS:
;             /jpeg  makes JPEG .jpg file [default]
;             /png   makes PNG  .png file
;
;-
; MODIFICATION HISTORY:
;
; 27feb2011 tmb 
; 01mar2011 tmb modified for V6.1 file structure
; V7.0 03may2013 tvw - added /help, !debug
;      13may2013 tmb - updated to use cgSnapshot
;                      fname can be local or fully
;                      qualified a la printon.pro
;      /jpeg makes .jpg /png makes .png
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'jpeg' & return & endif
;
; use default !jpeg_file if no fname supplied
;
if n_params() eq 0 then fname=!jpeg_file
;
if keyword_set(png) then ext='png' else ext='jpg'
;
fname=strtrim(fname,2)
fdecomp,fname,disk,dir,name,old_ext  ; find out where plots go
; if passed fname is not a fully qualified file name use default directory 
if dir eq '' then begin
   file_name=name
   fdecomp,!jpeg_file,disk,dir,name,old_ext 
   name=file_name
endif
;
jpeg_file=dir+name+'.'+ext       ; put fname into full file name
;
snap=cgSnapshot(filename=jpeg_file,/NoDialog) 
;
print
print,'Wrote snapshot image to file = ',jpeg_file
print
;
return
end
