FUNCTION kang_sign, number
; Returns the sign of a value, -1 if negative, +1 otherwise

IF number EQ 0 THEN RETURN, 1 ELSE RETURN, number / abs(number)
END
