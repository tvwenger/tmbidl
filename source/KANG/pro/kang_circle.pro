;+
; Returns the x and y values of a circle
;
; :Private:
;
;-
FUNCTION Kang_Circle, xcenter, ycenter, radius, NPoints=NPoints

IF N_Elements(NPoints) EQ 0 THEN NPoints=100

seeds = Findgen(npoints)/(npoints-1)*2*!pi
xvals = sin(seeds)*radius+xcenter
yvals = cos(seeds)*radius+ycenter

RETURN, Transpose([[xvals], [yvals]])
END; Kang_Circle-------------------------------------------------------------------
