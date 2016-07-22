pro tagsrc,msg,help=help
;+
; NAME:
;       TAGSRC
;
;            =============================================
;            Syntax: tagsrc, SOURCE_NAME__STRING,help=help
;            =============================================
;
;
;   tagsrc   Writes a byte(string) into !b[0].source for reassigning
;   ------   the source name
;            32 character maximum in {tmbidl_header}  
;            Truncates input string to fit,
;
;            If SOURCE_NAME__STRING is passed explicitly, then must be a string.
;
;            => Overwrites !b[0].source
;-
; V6.1 tmb 22sept09
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'tagsrc' & return & endif
;
msg_max=n_elements(!b[0].source)
idx=msg_max-1
;
if (n_params() eq 0) then begin
                     msg=' '
                     read,msg,prompt='Input Source Name: (no quotes!)'
                     !b[0].source[0:idx]=''
                     !b[0].source=byte(strmid(msg,0,msg_max))
                     return
                     endif
;
!b[0].source[0:idx]=''                       ; erase previous line_id
!b[0].source=byte(strmid(msg,0,msg_max))    ; write message truncated to fit 
;
return
end
