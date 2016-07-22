PRO sizexy,xfact,yfact,help=help
;+
; NAME:
;       SIZEXY
;
;            ====================================
;            Syntax: sizexy,xfact,yfact,help=help
;            ====================================
;
;   sizexy  Resize the plot X,Y-axes using range of data intensities. 
;   ------  Defaults set:
;                    X-axis from xmin+0.05*xrange to xmax-0.05*xrange
;                    Y-axis from ymin-0.05*yrange to ymax+0.05*yrange
;
;          'xfact' is the factor by which the X-axis is scaled:
;           xfact = 0.05 makes the axis 5% LARGER (default)
;                  -0.05 makes the axis 5% SMALLER 
;
;           yfact is similar.
;
;           See documentation for associated .pro's: SIZEX and SIZEY 
;
;   USES THE ![X,Y].CRANGE ARRAYS THAT ARE ONLY SET *AFTER* A CALL TO 'SHOW'
;- 
; MODIFICATION HISTORY:
; V5.1 TMB 24jul08 
;
; v6.1 tmb 16aug10
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'sizexy' & return & endif
;
; what is passed?
;
npar =  n_params()
case napar of 
             0: begin    ; defaults to inner 5% of x 
                xfact=-.05 & yfact=+0.05
                end
             1: yfact=+0.05 
          else:
endcase
;
sizex,xfact
sizey,yfact
;
xx 
;
return
end
 
