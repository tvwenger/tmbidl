pro settype,typ,help=help
;+
; NAME:
;       SETTYPE
;
;            =========================================
;            Syntax: settype, type_of_record,help=help
;            =========================================
;
;   settype  Sets scan type for a SELECT search of the ONLINE/OFFLINE data 
;   -------  data. Promps for input if none is supplied.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'settype' & return & endif
;
if n_params() eq 0 then begin
               print,'Scan Type = ON or OFF (no quotes needed)'
               typ=''
               read,typ,prompt='Set Scan Type: '
               endif
;
!typ=strtrim(typ,2)
if ( (!typ eq "") or (!typ eq " ") ) then !typ='*'
;
print,'Scan type for searches is: ' + !typ
;
return
end
