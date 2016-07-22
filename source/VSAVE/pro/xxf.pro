;+
; NAME:
;       XXF
;
;            ==========
;            Syntax: xxf
;            ==========
;
;  xxf    Renaming of SHOW procedure plus displaying line flags
;  --
;               
;
; V5.1 July 2008
;-
pro xxf
;
erase
show
lid=strtrim(string(!b[0].line_id),2)
lid3=strmid(lid,0,3)
lid2=strmid(lid,0,2)
if lid2 eq 'rx' then lid=lid3
acs_flags,lid
;
return
end
