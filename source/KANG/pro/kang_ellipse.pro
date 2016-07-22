;+
; Returns the x and y values of an ellipse
;
; :Private:
;
;-
FUNCTION Kang_Ellipse, xcenter, ycenter, rmax, rmin, angle, NPoints=NPoints

IF N_Elements(NPoints) EQ 0 THEN NPoints=100
IF N_Elements(angle) EQ 0 THEN angle = 0

seeds = Findgen(npoints)/(npoints-1)*2*!pi
xvals = xcenter + rmax*cos(seeds)
yvals = ycenter + rmin*sin(seeds)

; Rotate
data = Kang_Rotate_Polygon(xcenter, ycenter, transpose([[xvals], [yvals]]), angle)

RETURN, data
END; Kang_Ellipse--------------------------------------------------------------------------------
