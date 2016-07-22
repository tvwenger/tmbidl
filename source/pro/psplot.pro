pro psplot,filename,help=help
;+
; NAME:
;       PSPLOT
;
;            ===================================================
;            Syntax: psplot, fully_qualified_file_name,help=help
;            ===================================================
;
; 
;   psplot   Print a postscript file.
;   ------   Searches for env variable PSPRINTER, else uses 
;                     PSprinter = 'ops4050', the GBT control room. 
;
;            If filename not input, 'idl' is assumed.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'psplot' & return & endif
;
if N_elements(filename) NE 1 then filename = 'idl' 
   fdecomp,!plot_file,disk,dir,name,ext     ; get file info from !plot_file
   if ext EQ '' then ext = 'ps'
   file = disk+dir+filename+'.'+ext         ; assign full name to file  
;
;
psfile = findfile(file,count=nfound)
if nfound EQ 0 then message,'Unable to find postscript file ' + file
;
PSprinter = getenv('PSPRINTER')
   if (PSprinter eq '') then begin
      PSprinter = 'ops4050'
   endIF
   st = 'lpr -P '+PSprinter + ' ' + file      ; Print file (UNIX command).
       print,' $ '+st
spawn,st
;
return
end



