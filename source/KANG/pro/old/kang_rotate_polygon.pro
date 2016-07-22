;+
; Rotates a polygon about xcenter, ycenter
; Angle is in degrees
;
; :Private:
;-
FUNCTION Kang_Rotate_Polygon, xcenter, ycenter, data, angle

cos_angle = cos(angle/!radeg)
sin_angle = sin(angle/!radeg)
    
x_recen = data[0, *] - xcenter
y_recen = data[1, *] - ycenter
x_rot = x_recen*cos_angle - y_recen*sin_angle + xcenter
y_rot = x_recen*sin_angle + y_recen*cos_angle + ycenter

RETURN, [x_rot, y_rot]
END; Kang_Rotate_Polygon--------------------------------------------------
