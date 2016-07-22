FUNCTION Kang_SpaceOrComma, var
; Separates string into values based regardless of whether a comma or
; a space has been used for delimiters

newvar = RepStr(var, ',', ' ')
newvar = StrCompress(var)
newvar=Strsplit(newvar, ' ', /Extract)

RETURN, newvar
END; --------------------------------------------------------------------------------
