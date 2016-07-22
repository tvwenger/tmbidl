pro procName,parm1,parm2,help=help 
;+
; NAME:
;       procName
;
;  =========================================================
;  SYNTAX: procName,parm1,parm2,help=help 
;  =========================================================
;
;  procName Documentation about what this does.
;  -------- 
;
;  PARAMETERS: parm1 what is this?
;              parm2 and this?
;
;  KEYWORDS:  help  gives this help
;-
; MODIFICATION HISTORY
; V7.0 TMBIDL needs !debug code to restore on_error 
;             functionality lost after IDL v8
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'procName' & return & endif
;
@CT_IN  ; color table handling
;

;
@CT_OUT ; restore color table
;
return
end

