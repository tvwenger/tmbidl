pro sety,ymin,ymax,help=help
;+
; NAME:
;       SETY
;
;            ==================================
;            Syntax: sety, ymin, ymax,help=help
;            ==================================
;
;
;  sety   Set ymin and ymax for y-axis range on SHOW.
;  ----   CURON/CUROFF toggles behavior:
;         If !cursor=1 then set with the cursor
;            else set via command line parameters ymin,ymax
;
; V5.0 July 2007
;
;lV6.1 1sept09 tmb change behavior to act like GBTIDL
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'sety' & return & endif
;
!last_y=!y.range            ; remember current scaling
cursor = !cursor            ; remember cursor setting
@CT_IN
;
if n_params() eq 0 then begin
    !cursor=1
    ccc,xpos,ypos
    ymin=ypos
    ccc,xpos,ypos
    ymax=ypos
    !y.range=[ymin,ymax]
endif else begin
    !y.range=[ymin,ymax]
end
;
; return cursor to previous state
!cursor = cursor
@CT_OUT
;
return
end

