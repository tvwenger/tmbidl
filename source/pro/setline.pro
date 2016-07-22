pro setline,id,help=help
;+
; NAME:
;       SETLINE
;
;            =========================
;            Syntax: setline,id,help=help
;            =========================
;
;   setline   Sets line ID for a SELECT search of the ONLINE/OFFLINE
;   -------   data. If not passed, Prompts for line ID.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;      19jun2013 tvw - option for passing parameter
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setline' & return & endif
;
if n_params() eq 0 then begin
   print,'Line ID = e.g. rx1.1, rx2.2, rx1, rx2, .... (no quotes needed)'
   id=''
   read,id,prompt='Set Scan ID: <CR>=Wild Card'
endif
;
!id=strtrim(id,2)
if !id eq "" or !id eq " " then !id='*'
;
print,'Line ID for searches is: ' + !id
;
return
end
