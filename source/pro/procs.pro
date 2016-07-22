pro procs,help=help
;+
; NAME:
;       PROCS
;
;            =======================
;            Syntax: procs,help=help
;            =======================
;
;   procs   Output the names of all currently compiled procedures to std out.
;   -----
;               ===>   BEWARE BEWARE BEWARE BEWARE BEWARE BEWARE <===
;
;               Text above is IDL description of itself.  This is, however,
;               NOT what 'routine_info()' returns.  This IDL command
;               returns the names of all procedures that have been invoked
;               to date during the current IDL session.
;
;               If these calls fail, e.g. because the routing does not exist,
;               etc. THEY ARE STILL LISTED BY ROUTINE_INFO()
;
;               Better to use IDL 'help' which lists *compiled* procedures.
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'procs' & return & endif
print,'Procedures currently compiled:'
print,routine_info(),format='(5a16)'
;
return
end
