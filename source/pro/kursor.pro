pro kursor,xpos,ypos,help=help
;+
; NAME:
;       KURSOR
;
;            ==============================================
;            Syntax: kursor, xpos_read, ypos_read,help=help
;            ==============================================
;
;;
;   kursor   Invoke cursor and read its position once.  Output x,y co-ordinates in PLOT
;   ------   units to standard output.  Return these values in xpos,ypos.  Plot this
;            position and its values on graphics screen via FLAG and HLINE.  Invokes CCC.
;
;       ==>  CURSOR is an IDL command hence this name. <==
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'kursor' & return & endif
;
ccc,xpos,ypos
flag,xpos
hline,ypos
;
return
end

