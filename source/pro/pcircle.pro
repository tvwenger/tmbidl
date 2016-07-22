pro pcircle,xpos,ypos,radius,color=color,help=help
;+
; NAME:
;       PCIRCLE
;
;   ======================================================
;   SYNTAX: pcircle,xpos,ypos,radius,color=color,help=help
;   ======================================================
;
; pcircle   Plot a circle at xpos,ypos with input radius.
; --------  Only makes sense to use on a position-position plot
;           or a plot with the same units on the x and y axes.
;
;   PARAMETERS: xpos,ypos,radius are all in same units
;                                e.g. degrees
;
;   KEYWORDS:  /help gets this help
;              color sets color of the circle [default is !green]
;
;-
; V5.0 Jul 2007 
; v6.1 Nov 2010  tmb modified so /color is now a keyword  
;      04may2011 tmb fixed long standing bug wherin azimuth
;                    was in degrees not radians!             
;
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
;
@CT_IN ; color table management
;
if n_params() lt 3 or keyword_set(help) then begin & get_help,'pcircle' & return & endif
;
if ~Keyword_Set(color) then color=!green ; default color
;
; first move to position at theta=0: xpos+radius,ypos
; 
plots,xpos+radius,ypos
; plot the error circle
for theta=0.,2.*!dpi,.01 do begin
    x=radius*cos(theta) & y=radius*sin(theta) &
    plots,xpos+x,ypos+y,/continue,thick=2.,color=color
    ;print,theta,xpos+x,ypos+y
end
;
@CT_OUT
;
return
end
