pro tagtype,msg,help=help
;+
; NAME:
;       TAGTYPE
;
;            ======================================
;            Syntax: tagtype, TYPE_STRING,help=help
;            ======================================
;
;
;   tagtype   Writes a byte(string) into !b[0].scan_id for annotation
;   -------   of scan type.  32 character maximum in {gbt_data}  
;             Truncates input string to fit.
;
;             If TYPE_STRINGmsg is passed explicitly, then must be a string
;                else system prompts for it.
;              => Overwrites !b[0].scan_type
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'tagtype' & return & endif
;
msg_max=n_elements(!b[0].scan_type)
idx=msg_max-1
;
if (n_params() eq 0) then begin
                     msg=' '
                     read,msg,prompt='Input scan_type: (no quotes!)'
                     !b[0].scan_type[0:idx]=''
                     !b[0].scan_type=byte(strmid(msg,0,msg_max))
                     return
                     endif
;
!b[0].scan_type[0:idx]=''                       ; erase previous scan_type
!b[0].scan_type=byte(strmid(msg,0,msg_max))    ; write message truncated to fit 
;
return
end
