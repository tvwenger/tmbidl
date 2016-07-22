pro axon,help=help
;+
; NAME:
;       AXON
;       axon,help=help
;
;   axon.pro   toggle ON the labelling of the plot axes
;   --------
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
if keyword_set(help) then begin & get_help,'axon' & return & endif
!x.title=!xtitle_old    ;  restore the old x and y axes labels
!y.title=!ytitle_old
;
return
end
