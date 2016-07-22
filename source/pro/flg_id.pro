pro flg_id,ch,lab,color,help=help,charsize=charsize 
;+
; NAME:
;       FLG_ID
;
;   flg_id   Set vertical flag at specified channel for line ID.
;   ------   ch=x-axis value for flag   
;            lab=string for flag label
;            clr= sys_colour_variable_name
;
;     ====================================================
;     Syntax: FLG_ID,x_axis_value_to_flag,'label',color, $
;                    help=help,charsize=charsize
;     ====================================================
;
;  KEYWORDS   /help     gives help
;             /charsize size of flag labels [default 1.0]
;          
;        colors: !black  !red    !orange   !green  !forest !yellow 
;                !cyan   !blue   !magenta  !purple !gray   !white
;
;
; V5.0 July 2007
;
; V6.1 March 2010 tmb seamless PS handling
;      23May2012  tmb added /help and /charsize 
; V7.0 3may2013 tvw - added /help, !debug
;-

;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if KeyWord_Set(help) then begin & get_help,'flg_id' & return & endif
@CT_IN
;
if ~KeyWord_Set(charsize) then charsize=1.0
;
if n_params() eq 0 then begin
   print,'Error: Insufficient information to execute'
   print,'Syntax: FLG_ID,channel_to_flag,label,color'
   print,'        label must be a "string"'
   return
endif
;
case !clr of
             1: clr=color 
          else: clr=!d.name eq 'PS' ? !black : !white
endcase
;get_clr,clr
;
; get data ranges
;
xmin = min(!x.crange,max=xmax) & ymin = min(!y.crange,max=ymax)
xrange = xmax-xmin & yrange = ymax-ymin
yincr=0.01*yrange 
;
plots,ch,ymin
plots,ch,ymax+yincr,/continue,color=clr
xyouts,ch,ymax+2.*yincr,lab,/data,alignment=0.5,color=clr,charsize=charsize
;
@CT_OUT
return
end
