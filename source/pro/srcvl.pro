pro srcvl,ch,help=help
;+
; NAME:
;       SRCVL
;
;            ================================================
;            Syntax: srcvl, sourc_velocity_position,help=help
;            ================================================
;
;
;   srcvl   Plots vertical flag at specified source velocity 
;   -----   ch= position of flag.  Must be in current x-axis units.
;-
; V5.0  July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'srcvl' & return & endif
;
case !clr of 
       1: clr=!cyan
    else: clr=!d.name eq 'PS' ? !black : !white
endcase
;
get_clr,clr
;
; get data ranges
;
xmin = !x.crange[0]
xmax = !x.crange[1]
ymin = !y.crange[0]
ymax = !y.crange[1]
xrange = xmax-xmin
yrange = ymax-ymin
yincr=0.025*yrange
;
vel=!b[0].vel  & cvel='Vsrc'
plots,vel,ymin
plots,vel,ymax+yincr,/continue,color=clr
; cvel=cvel+fstring(vel,'(f5.2)')
xyouts,vel,ymax+yincr+yincr/5,cvel,/data,alignment=0.5,color=clr
;
@CT_OUT
return
end
