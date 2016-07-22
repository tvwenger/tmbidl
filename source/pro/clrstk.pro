pro clrstk,help=help
;+
; NAME:
;      CLRSTK
;
;  clrstk,help=help   Empties the stack.  
;  ----------------
;                N.B. 'EMPTY' is an IDL defined variable
;
; V5.0 July 2007
;      18aug08 tmb added batch mode to supress the print statement
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'clrstk' & return & endif
;
!acount=0
n=n_elements(!astack)-1
!astack[0:n]=0
;
if not !batch then print,'STACK is now empty'
;
return
end
