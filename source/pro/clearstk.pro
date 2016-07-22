pro clearstk,help=help
;+
; NAME:
;      CLEARSTK
;      clearstk,help=help
;
;  clearstk   Empties the stack.  Synonym for CLRSTK
;  --------
;
; V5.1 18aug08 tmb added synonym because he always forgets
; V7.0 3may2013 tvw - added /help, !debug
;
;-
if keyword_set(help) then begin & get_help,'clearstk' & return & endif
;
clrstk
;
return
end
