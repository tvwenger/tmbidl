;+
;  sinc.pro   sinc function
;  --------
;             x - dependent variables
;
;-
function sinc, x
;
; check for zero values of x and set them to a small number
index = where(x eq 0.0)
if(min(index) ge 0)then begin
    x(index) = 1.0e-5
endif

; calculate the sinc function
f = sin(!dpi*x)/(!dpi*x)

; set function values where x = 0 to exactly 1.0
if(min(index) ge 0)then begin
    f(index) = 1.0
endif

return, f
end

