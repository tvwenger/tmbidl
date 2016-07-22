pro is_jd_ok,ok,help=help
;+
; NAME:
;       IS_JD_OK
;
;            =============================
;            Syntax: IS_JD_OK,ok,help=help
;            =============================
;
;   IS_JD_OK   procedure to test whether the Julian Date of !b[0] data 
;   --------   is before or after 1 Jan 2011 when SDFITS changed.
;
;-
; MODIFICATION HISTORY:
;
; V6.1 09feb2011 tmb 
; v7.0 15may2013 tmb added help and !debug
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'is_jd_ok' & return & endif
;
ok=0
;
; filter this change via JD of observations
; SDFITS Break point JD assumed here to be:  2011 01 01 => jd0
;
juldate,[2011,01,01],jd0
;
; JD of data in !b[0]
;
jdate,jd
;
if jd ge jd0 then ok=1
;
return
end
