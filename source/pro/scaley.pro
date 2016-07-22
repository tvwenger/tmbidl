pro scaley,help=help,yincr=yincr,pad=pad
;+
; NAME: SCALEY
;
;   ============================================
;   SYNTAX: SCALEY,help=help,yincr=yincr,pad=pad
;   ============================================
;
;   scaley   Create y-axis scaling pleasing to the eye. 
;   ------   Uses !b[0].data values in current !x.range. 
;            Works for any x-axis unit definition .
;                 
;   KEYWORDS: /help  - gives help
;             /yincr - % padding for Y-axis scaling [default is 0.1]
;             /pad   - increase the space above data ymax value
;                      this makes weak lines and limits look nicer
;
;-
; MODIFICATION HISTORY:
;
; V7.0 tmb 
;      05jul2013 tmb - there is an issue with !x.crange/!x.range
;                      behavior. fix is not clear
;                      here is the latest try
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if Keyword_Set(help) then begin & get_help,'scaley' & return & endif 
;
; !x.range must be explicitly set so force value from !x.crange
if !x.range[0] eq 0 and !x.range[1] eq 0 then !x.range = !x.crange
; size the y-axis based on !x.range 
vmin=!x.range[0] & vmax=!x.range[1] 
; figure out y-axis displayed channel range
idchan,vmin,xmin & idchan,vmax,xmax  
data=!b[0].data[xmin:xmax]
ymin=min(data, max=ymax)
yrange=ymax-ymin
if ~KeyWord_Set(yincr) then yincr=0.10
ymin=ymin-(yincr/2.)*yrange & ymax=ymax+yincr*yrange
if KeyWord_Set(pad) then ymax=ymax+2.*yincr*yrange
;
sety,ymin,ymax
;
return
end
