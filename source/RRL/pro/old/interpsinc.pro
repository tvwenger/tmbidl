;+
;  interpsinc.pro   interpolate using sinc function 
;  --------------   (taken from Michael Minardi in matlab)
;
;                   xi    - x values to which you want to interpolate f(x)
;                   f     - function of x (assumed to be uniform) to interpolate.
;                   xd    - sample spacing of f (default = 1.0)
;                   nref  - reference element of f (default = 0.0)
;                   xnref - x value assigned to element nref (default = 0.0)    
;
;-
function interpsinc, xi, f, xd = xd, nref = nref, xnref = xnref
;
; set the defaults
if (n_elements(xd) eq 0) then xd=1.0
if (n_elements(nref) eq 0) then nref=0.0
if (n_elements(xnref) eq 0) then xnref=0.0

; convert xi from units of x to fractional index values
ni = double(nref + (xi - xnref)/xd)

; check if the requested interpolation points are outside the range
; of the sampled function
if (min(ni) lt 0.0 or max(ni) gt n_elements(f)) then begin
 print, 'Some points are outside the range of the input function.'
 print, 'You are EXTRAPOLATING not INTERPOLATING'
 print, min(ni), max(ni), n_elements(f)
endif

; create interpolation weights using the sinc function
foo1 = dindgen(size(f, /n_elements), 1) + 1.0
foo2 = dindgen(1, size(ni, /n_elements)) + 1.0 - dindgen(1, size(ni, /n_elements))
foo3 = dindgen(size(f, /n_elements), 1) + 1.0 - dindgen(size(f, /n_elements), 1)
foo = foo1#foo2 - foo3#ni
NI = sinc(foo)

; generate interpolated values
fi = f#NI

;
return, fi
end
