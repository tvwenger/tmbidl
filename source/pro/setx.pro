pro setx,xmin,xmax,help=help
;+
; NAME:
;       SETX
;
;            ==================================
;            Syntax: setx, xmin, xmax,help=help
;            ==================================
;
;  setx  Set xmin and xmax for x-axis range on SHOW.
;  ----  If no parameters then turns on cursor.
;        (This matches GBTIDL functionality.)
;-
; V5.0 July 2007  
;      05 Feb 2009 - (dsb) change behavior to act like GBTIDL
;
; V6.0 June 2009 adopt dsb version
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setx' & return & endif
;
@CT_IN
!last_x=!x.range            ; remember current scaling
cursor = !cursor            ; remember cursor setting
;
if n_params() eq 0 then begin
    !cursor=1
    ccc,xpos,ypos
    xmin=xpos
    ccc,xpos,ypos
    xmax=xpos
    !x.range=[xmin,xmax]
endif else begin
    !x.range=[xmin,xmax]
end

; return cursor to previous state
!cursor = cursor
@CT_OUT
;
return
end

