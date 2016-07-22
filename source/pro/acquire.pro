pro acquire,rec_no,help=help
;+
; NAME:
;       ACQUIRE
;
;   acquire.pro   Uses !tp flag to either FETCH (!tp=1) or GET (!tp=0)
;   -----------   record in either ONLINE or OFFLINE data file
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'acquire' & return & endif
;
case 1 of
         !tp eq 1: fetch,rec_no
             else: get,rec_no
endcase  
;
return
end
