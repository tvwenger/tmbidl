pro batchon,help=help
;+
; NAME:
;      BATCHON
;      batchon,help=help
;
;   batchon.pro   turn the !batch flag ON for various control functions
;   -----------
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'batchon' & return & endif
;
!batch=1
;
return
end
