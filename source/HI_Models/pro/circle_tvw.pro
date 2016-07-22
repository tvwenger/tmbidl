;http://www.idlcoyote.com/tip_examples/circle.pro
; ie, plots,circle(1,1,1)
;
; tvw 26march2013 added npoints and CIRCINTER stuff
;
FUNCTION CIRCLE_TVW, xcenter, ycenter, radius, circinter=circinter
if ~keyword_set(circinter) then circinter=0.006*radius
npoints=2 * !dpi * radius / circinter
;print,npoints
points = (2 * !PI / (npoints-1)) * FINDGEN(npoints)
x = xcenter + radius * COS(points )
y = ycenter + radius * SIN(points )
RETURN, TRANSPOSE([[x],[y]])
END
