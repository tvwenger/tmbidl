pro rlook,rxid, avg=avg,help=help
;+
; NAME:
;       RLOOK
;
;   rlook  Uses STACK to ACQUIRE spectra and plot them with a DC level
;   -----  a DC level subtracted -- routine assumes x,y-axes are set properly
;          Uses 'rxid' and !config to flag ACS spectral transition locations
;
;               ======================================
;               Syntax: rlook, rxid, avg=avg,help=help
;               ======================================     
;-
; v5.0 08 Jan 2008 tmb complete rewrite of rlook
;
; v6.1 20 jan 2012 tmb added keyword avg which if set averages 
;         and shows the STACK contents instead of each STACK record
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'rlook' & return & endif
;
dcon               ;  turn DC level remove ON
;
; if keyword avg set then average the stack 
;
if keyword_set(avg) then begin
   avgstk & xx & acs_flags,rxid & pause &
   goto, flush
endif
;
acquire,!astack[0]
rec_info,!astack[0]
show
acs_flags,rxid
pause
;
for i=1,!acount-1 do begin
      acquire,!astack[i] 
      rec_info,!astack[i]
      show 
      acs_flags,rxid
      pause
endfor
;
flush: 
;
scn=!b[0].scan_num
!last_look=scn    
;
dcoff              ;  turn DC level remove OFF  
;
return
end

