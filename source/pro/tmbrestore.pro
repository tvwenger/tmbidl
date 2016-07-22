pro tmbrestore,help=help
;+
; NAME:
;       TMBRESTORE
;
;            ============================
;            Syntax: tmbrestore,help=help
;            ============================
;
;   tmbrestore   RESTORES all system + local variables and 
;   ----------   user defined procedures + functions from 
;                !save_idl_state  and !save_idl_procs files,
;                respectively
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'tmbrestore' & return & endif
;
restore, filename=!save_idl_state  ; system and local variables
;
restore, filename=!save_idl_procs  ; user defined procedures and functions
;
return
end
