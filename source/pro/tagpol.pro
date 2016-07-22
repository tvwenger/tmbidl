pro tagpol,msg,help=help
;+
; NAME:
;       TAGPOL
;
;            ====================================
;            Syntax: tagpol, POL_STRING,help=help
;            ====================================
;
;   tagpol   Writes a byte(string) into !b[0].pol_id for annotation of polarization
;   ------   of polarization.  4 character maximum in {gbt_data}  
;            Truncates to fit.
;
;             => Overwrites !b[0].pol_id 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'tagpol' & return & endif
;
msg_max=n_elements(!b[0].pol_id)
idx=msg_max-1
;
if (n_params() eq 0) then begin
                     msg=' '
                     read,msg,prompt='Input pol_id: (no quotes!)'
                     !b[0].pol_id[0:idx]=''
                     !b[0].pol_id=byte(strmid(msg,0,msg_max))
                     return
                     endif
;
!b[0].pol_id[0:idx]=''                       ; erase previous pol_id
!b[0].pol_id=byte(strmid(msg,0,msg_max))    ; write message truncated to fit 
;
return
end
