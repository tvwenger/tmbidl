pro xroll,help=help
;+
; NAME:
;       XROLL
;
;            =======================
;            Syntax: xroll,help=help
;            =======================
;
;   xroll   Sets x-axis range to inner 90% of total range. 
;   -----   Eliminates correlator filter rolloff effects .
;-
; V5.0 July 2007
;
; V6.1 1sept09 tmb incorporate KANG
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'xroll' & return & endif
;
@CT_IN
;
start=ceil(0.05*!data_points)
stop =!data_points - start 
!x.range=[!xx[start],!xx[stop]]
;
@CT_OUT
;
return
end


