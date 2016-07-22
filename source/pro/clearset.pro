pro clearset,help=help
;+
; NAME:
;      CLEARSET
;      clearset,help=help
;
;   clearset.pro   Initializes SELECT variables to wild card values.
;   ------------   Does NOT alter record or scan search ranges.
;                  Use SETREC and SETRANGE to do this.
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'clearset' & return & endif
;
!src='*'
!id='*'
!typ='*'
!pol='*'
!scan='*'
;
return
end
