pro tmbsave,help=help
;+
; NAME:
;       TMBSAVE
;
;            =========================
;            Syntax: tmbsave,help=help
;            =========================
;
;   tmbsave   SAVES all system + local variables and user defined procedures and
;   -------   functions in !save_idl_state and !save_idl_procs files, respectively
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'tmbsave' & return & endif
;
save, /all,      filename=!save_idl_state  ; system and local variables
;
save, /routines, filename=!save_idl_procs  ; user defined procedures and functions
;
return
end
