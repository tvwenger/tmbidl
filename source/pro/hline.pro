pro hline,val,color=color,no_value=no_value,help=help
;+
; NAME:
;       HLINE
;
;            ======================================================================
;            Syntax: hline, y_value_to_draw,color=color,no_value=no_value,help=help
;            ======================================================================
;
; hline   Draw horizontal line at specific y-axis value 'y_value_to_draw'
; -----   no_value flag supresses plotting the value 
;-
; V5.0 July 2007
;
; V6.1 March 2010 tmb seamless PS handling and value flag for plot
;
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'hline' & return & endif
;
if ~Keyword_Set(color) then color=!magenta

case !clr of
             1: clr=color 
          else: clr=!d.name eq 'PS' ? !black : !white
endcase
;get_clr,clr
;
; get data ranges
;
xmin = !x.crange[0] & xmax = !x.crange[1]
ymin = !y.crange[0] & ymax = !y.crange[1]
xrange = xmax-xmin  & yrange = ymax-ymin
xincr=0.02*xrange
;
plots,xmin,val
;
case Keyword_Set(no_value) of 
     0:begin
       plots,xmax+xincr,val,/continue,color=clr
       xyouts,xmax+xincr,val,fstring(val,'(f6.2)'),/data,color=clr
       end
  else:plots,xmax,val,/continue,color=clr
endcase
;
@CT_OUT
return
end
