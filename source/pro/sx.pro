pro sx,reset=reset,help=help
;+
; NAME:
;       SX
;
;       ================================
;       SYNTAX: sx,reset=reset,help=help
;       ================================
;
;   sx  Forces x-axis to HRDS <Hn alpha> range. 
;   --  
;
;  KEYWORDS:  
;           help  - gives this help
;           reset - recover HISTORY &reset parameters
;
;-
; MODIFICATION HISTORY:
; V6.1 TMB 12feb2010
;
; v7.0 tmb 21may2013 update added /help and !debug
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'sx' & return & endif
;
if Keyword_Set(reset) then rehash,/reset
;
if !chan eq 1 then setx, 0, 1000
if !velo eq 1 then begin &  idval,0,vmin & idval,1000,vmax & setx,vmin,vmax & end
xx
;
return
end
