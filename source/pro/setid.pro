pro setid,id,help=help
;+
; NAME:
;       SETID
;
;            ==================================
;            Syntax: setid, 'line_id',help=help
;            ==================================
;
;   setid   Sets line ID for a SELECT search of ONLINE/OFFLINE data.
;   -----   if id value not passed, prompts for string.
;   Syntax: setid,"rx1.2" <-- must pass a string "*" is wildcard 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
if keyword_set(help) then begin & get_help,'setid' & return & endif
;
if n_params() eq 0 then begin
   print,'no quotes needed; <CR> means wildcard' 
   print
   id=' '
   read,id,prompt='Input line ID: '
endif
;
!id=strtrim(id,2)
if !id eq "" or !id eq " " then !id='*'
;
print,'Line ID for searches is: ' + !id
;
return
end
