pro zline,value=value,help=help
;+
; NAME:
;       ZLINE
;
;            =======================
;            Syntax: zline,help=help
;            =======================
;
;   zline   Draw a line through zero intensity.
;   -----   
;               ZLON/ZLOFF toggle
;-
; V5.0  July 2007
;
; V6.1 March 2010 tmb turned plotting the 0. value into a Keyword
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'zline' & return & endif
@CT_IN
;
; get data ranges
;
xmin = !x.crange[0]
xmax = !x.crange[1]
ymin = !y.crange[0]
ymax = !y.crange[1]
xrange = xmax-xmin
yrange = ymax-ymin
xincr=0.015*xrange
;
plots,xmin,0.0 
plots,xmax,0.0,/continue
if Keyword_Set(value) then $
xyouts,xmax+xincr,0.0,fstring(0.0,'(f2.0)'),/data
;
@CT_OUT
return
end
