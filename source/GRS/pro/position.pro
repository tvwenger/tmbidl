;+
; position.pro   set cross at input center position xpos,ypos in degrees
; ------------   error is position error in degrees
;-
pro position,xpos,ypos,color,error
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if (n_params() eq 0) then begin
                     print,'Error in flag call:'
                     print,'Syntax:  position,xpos,ypos,color,error'
                     print,'                  error is position error'
                     print,'               All angles in degrees'
                     print,'         Default color is green'
                     return
                     endif
;
clr=getcolor('green') ; default color
if (n_params() ge 3) then clr=color
;
; get data ranges
;
xmin = !x.crange[0]
xmax = !x.crange[1]
ymin = !y.crange[0]
ymax = !y.crange[1]
xrange = xmax-xmin
yrange = ymax-ymin
xincr=0.025*xrange
yincr=0.025*yrange
;
; first plot the position
plots,xpos,ypos+yincr
plots,xpos,ypos-yincr,/continue,thick=5.,color=clr
plots,xpos+xincr,ypos
plots,xpos-xincr,ypos,/continue,thick=5.,color=clr
;
; plot the error box if error is specified
if (n_params() eq 4) then begin
                     err=error/2.
                     plots,xpos+err,ypos+err
                     plots,xpos+err,ypos-err,/continue,thick=2.,color=clr
                     plots,xpos-err,ypos-err,/continue,thick=2.,color=clr
                     plots,xpos-err,ypos+err,/continue,thick=2.,color=clr
                     plots,xpos+err,ypos+err,/continue,thick=2.,color=clr
;   include an error circle
                     pcircle,xpos,ypos,clr,err
endif 
;
return
end
