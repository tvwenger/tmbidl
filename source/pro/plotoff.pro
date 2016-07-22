pro plotoff,prt,help=help
;+
; NAME:
;       PLOTOFF
;
;            =====================================
;            Syntax: plotoff, print_flag,help=help
;            =====================================
;
;   plotoff   Closes the postscript plot file !plt_file
;   -------
;              If a 'print_flag' is supplied (it can be *anything*)
;              then prints this file to a postscript device.
;
;              Searches for env variable PSPRINTER, else uses 
;              PSprinter = 'ops4050'  -> GBT control room 
;
;              Use SETPRINTER to change printer assignments. 
;-
; V5.0 July 2007
;
; V6.1 tmb 22oct09 
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'plotoff' & return & endif
;
psoff                     ; Close file if PS device  -- restore to previous device 
;
if (n_params() eq 1) then begin
;
   file=!plot_file
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
endif
;
clr        ; toggle back to Xwin graphics annotation -- color
;
return
end



