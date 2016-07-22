pro tagid,msg,help=help
;+
; NAME:
;       TAGID
;
;            ==================================
;            Syntax: tagid, ID_STRING,help=help
;            ==================================
;
;
;   tagid   Writes a byte(string) into !b[0].line_id for annotation of 
;   -----   receiver/spectral line identification.
;            32 character maximum in {gbt_data}  
;            Truncates input string to fit,
;
;            If ID_STRING is passed explicitly, then must be a string.
;
;            => Overwrites !b[0].line_id 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'tagid' & return & endif
;
msg_max=n_elements(!b[0].line_id)
idx=msg_max-1
;
if (n_params() eq 0) then begin
                     msg=' '
                     read,msg,prompt='Input line_id: (no quotes!)'
                     !b[0].line_id[0:idx]=''
                     !b[0].line_id=byte(strmid(msg,0,msg_max))
                     return
                     endif
;
!b[0].line_id[0:idx]=''                       ; erase previous line_id
!b[0].line_id=byte(strmid(msg,0,msg_max))    ; write message truncated to fit 
;
return
end
