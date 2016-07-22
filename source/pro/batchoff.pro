pro batchoff,help=help
;+
; NAME:
;      BATCHOFF
;      batchoff,help=help
;
;   batchoff.pro   turn the !batch flag OFF for various control functions
;   ------------
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'batchoff' & return & endif
;
!batch=0
;
return
end
