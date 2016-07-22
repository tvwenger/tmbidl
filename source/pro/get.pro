pro get,rec,help=help
;+
; NAME:
;       GET
;
;            ============================
;            Syntax: get, rec_#,help=help
;            ============================
;
;   get  Copy rec# into buffer !b[0]
;   ---
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
; V8.0 12jul2014 tvw - added fix_vegas support
;                      removed fix_vegas from this pro - it exists
;                      in fetch.pro
;      08jun2015 tvw/tmb - removed fix_vegas
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if (n_params() eq 0) or keyword_set(help) then begin & get_help,'get' & return & endif
;
;if (rec ge 0) then !ONLINE=1 else !ONLINE=0             ;  1=ONLINE data 0=OFFLINE data
rec=abs(rec)
;
if (!ONLINE eq 1) then getonline,rec else getoffline,rec ;  1=ONLINE data 0=OFFLINE data
;
!tsys = !b[0].tsys 
!time = !b[0].tintg
;
; if using VEGAS data, fix center channel problem
; if !config eq 6 then fix_vegas
;
return
end
