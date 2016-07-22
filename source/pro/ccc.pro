pro ccc,xpos,ypos,WaitFlag,help=help
;+
; NAME:
;      CCC
;
;   ccc.pro   Invokes cursor and returns its position in PLOT units.
;   -------   'rdplot' is from ASTROLIB and is a full screen cursor. 
;
;             ===============================
;             Syntax: ccc,xpos,ypos,help=help   
;             ===============================
;-
; V5.0 July 2007  
;
; V7.0 June 2012 tmb  
; V7.0 3may2013 tvw - added /help, !debug
;     10jun2013 tvw - updated to use TR_RDPLOT.pro
;     26jun2013 tmb - returned to RDPLOT.pro
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
;
if KeyWord_Set(help) then begin & get_help,'ccc' & return & endif

;
@CT_IN
;
rdplot,xpos,ypos,/down,/data,/fullcursor,color=!red
;
if !flag eq 0 then $
   print,'Cursor is at Xpos=',xpos,' Ypos=',ypos,' in PLOT units'
;
@CT_OUT
return
end
