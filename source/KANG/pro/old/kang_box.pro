;+
; Returns the x and y values of a box
; Angle is in degrees
;
; :Private:
;
;-
FUNCTION Kang_Box, xcenter, ycenter, width, height, angle

IF N_Elements(angle) EQ 0 THEN angle = 0

data = [[xcenter - width/2., ycenter - height/2.], $
        [xcenter - width/2., ycenter + height/2.], $
        [xcenter + width/2., ycenter + height/2.], $
        [xcenter + width/2., ycenter - height/2.], $
        [xcenter - width/2., ycenter - height/2.]]

; Rotate
data = Kang_Rotate_Polygon(xcenter, ycenter, data, angle)

RETURN, data
END; Kang_Box--------------------------------------------------------------------
