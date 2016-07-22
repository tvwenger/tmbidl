pro flag,ch,color=color,no_value=no_value,thick=thick,$
         charthick=charthick,help=help
;+
; NAME:
;       FLAG
;
;   flag   Plot vertical flag at specified x-axis position.
;   ----   Plots value of this position at top of the flag.
;          This is toggled off by /no_value 
;
;   =========================================================
;   SYNTAX: pro flag,ch,color=color,$
;               no_value=no_value,thick=thick,$
;               charthick=charthick,help=help
;   =========================================================
;
;   INPUTS:    ch       - x-value to flag in current units 
;
;   KEYWORDS:  help     - gives this help
;              color    - flag and text color 
;                         (default is !orange)
;              thick    - line thickness (default is 1.0)
;              charthick - flag value char thickness
;              no_value - no not plot flag value
;
;-
; MODIFICATION HISTORY
; V5.0 July 2007 tmb modified to GRS version with asks for color 
;
; V6.1 March 2010 tmb seamless PS handling  value off toggle
;                     GRS option will barf with this code
;      11sep2012 tvw - changed procedure to just plot a line
;                      instead of plotting increments
;                      added thick keyword
;
; V7.0 03may2013 tvw - added /help, !debug
;      23may2013 tmb - merged tvw and v7.0 
;      19jun2013 tvw - bug fix -> changed THICK keyword in xyouts
;                                 to CHARTHICK
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'flag' & return & endif
@CT_IN
;
if ~Keyword_Set(color) then color=!orange  ; default colour
case !clr of
             1: clr=color 
          else: clr=!d.name eq 'PS' ? !black : !white ; make white black for .ps 
       endcase
if ~keyword_set(thick) then thick=1
if ~keyword_set(charthick) then charthick=1
;
;get_clr,clr ; vestigal code may need resurrection if cannot pass !sys_color_names
;
; get data ranges for yincr which is hardwired to be 2% of yrange 
;
xmin = min(!x.crange,max=xmax) & ymin = min(!y.crange,max=ymax)
xrange = xmax-xmin & yrange = ymax-ymin
yincr=0.02*yrange
;
; ALWAYS plot the flag within the plot box
oplot,[ch,ch],[ymin,ymax],thick=thick,col=color
; plot label UNLESS explicitly told not to 
if ~Keyword_Set(no_value) then begin
   plots,ch,ymin  
   plots,ch,ymax+yincr,/continue,color=clr,thick=thick
   xyouts,ch,ymax+yincr+yincr/5,fstring(ch,'(i6)'), $
              /data,alignment=0.5,color=color,charthick=charthick
endif
;
@CT_OUT
return
end
