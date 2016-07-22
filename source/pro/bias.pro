pro  bias,y_offset,help=help
;+
; NAME:
;      BIAS
;      bias,y_offset,help=help
;
;   bias.pro   Displace spectrum in  !b[0].data by y_offset 
;   --------
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'bias' & return & endif
;
if (n_params() eq 0) then y_offset=!y_offset ;  default is current value of !y_offset
;
!y_offset=y_offset
;
!b[0].data=!y_offset+!b[0].data
;
return
end

