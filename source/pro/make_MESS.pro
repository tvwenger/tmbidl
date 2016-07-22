pro make_mess,fmess,help=help
;+
; NAME:
;       MAKE_MESS
;
;            ==================================
;            Syntax: make_mess, fmess,help=help
;            ==================================
;
;   make_mess   Create the MESSage file using {tmbidl_data} 
;   ---------   Also create a log file flagging whether a slot 
;               has been written
;               WHERE IS THIS PUTATIVE LOG FILE?
;               'fmess' is the fully qualified message file name
;-
; V5.0 July 2007 
; V7.0 03may2013 tvw - added /help, !debug
;-
;       
on_error,!debug ? 0 : 2
compile_opt idl2 
if keyword_set(help) then begin & get_help,'make_MESS' & return & endif
;
if n_params() ne 0 then begin
   !messfile=fmess
endif
;
;  create the MESSAGE file
;
openw,!messunit,   !messfile       ;  
;
print
print,'Made MESSAGE file '+!messfile
print
; 
return
end







