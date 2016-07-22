pro mkns,nsave1,help=help
;+
; NAME:
;       MKNS
;
;            ==============================
;            Syntax: mkns, nsave#,help=help
;            ==============================
;
;   mkns   Gets an nsave
;   ----   Converts to mk
;          Removes dcoffset-- modified by tmb so
;               dcoffset is made based on current x-axis display
;          Plots and adds line markers.
;
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'mkns' & return & endif
;
if n_params() eq 0 then begin
   nsave1=!nsave
   return
end
;
getns,nsave1
;
; DC subtract based on currently displayed x-axis range
;
start=!x.range[0] & stop=!x.range[1]
dcsub,start,stop
mk
xx
lmarker
;
return
end

