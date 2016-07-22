pro clook,brec,erec,help=help
;+
; NAME:
;       CLOOK
;
;            ===========================================
;            Syntax: clook, begin_rec, end_rec,help=help
;            ===========================================
;
;   clook  Take a quick look at the continuum data records
;   -----  in the OFFLINE data file.  Intended for real time
;          data quality check.
;
;          Puts all continuum scans into CHAN mode.
;          Flags the center channel.
;
; MODIFICATION HISTORY:
; V5.1 14 Jan 2008  TMB 
; V7.0 3may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'clook' & return & endif
;
chan 
;
for i=brec,erec do begin
      get,i
      freex
      xx
      center=(!c_pts+1)/2
      flag,center
      pause
endfor
;
return
end
