function rydberg, n, dn, atom, help=help
;+
;NAME: rydberg.pro 
;
;PURPOSE: Function to calculate RRL frequencies from the Rydberg formula.
;   
;CALLING SEQUENCE: rydberg, n, dn, atom
;
;INPUTS:  
;     -n:      principal quantum number
;     -dn:     change in n
;     -atom:   atom
;
;OPTIONAL KEYWORDS:
;
;OUTPUTS:
;
;EXAMPLE: foo = rydberg(91,1,'H')
;
;-
;MODIFICATION HISTORY:
;    07 Feb 2011 - Dana S. Balser
;    21 Apr 2011 - (dsb) Add C+ and O+
;    28 Feb 2012 - (dsb) Add Infinte mass
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then get_help,'rydberg' 
;define some constants (NIST)
c = double(2.99792458e+10)
rinf = double(1.0973731568e+05)
me = double(9.10938188e-28)

; mass of atom and charge
if atom eq 'H' then begin
    ma = double(1.67352e-24)
    z = double(1.0)
endif else if atom eq 'He' then begin
    ma = double(6.64644e-24)
    z = double(1.0)
endif else if atom eq 'He+' then begin
    ma = double(6.64644e-24)
    z = double(2.0)
endif else if atom eq 'C' then begin
    ma = double(1.992636e-23)
    z = double(1.0)
endif else if atom eq 'C+' then begin
    ma = double(1.992636e-23)
    z = double(2.0)
endif else if atom eq 'O+' then begin
    ma = double(2.656698e-23)
    z = double(2.0)
endif else if atom eq 'Inf' then begin
    ma = double(1.0)
    z = double(1.0)
endif else begin
    print, atom, ' is not a valid atom'
    return, 0.0
endelse

; calculate the RRL frequency


freq = z^2*c*rinf/(1.0 + me/ma)*(1.0/double(n)^2 - 1.0/(double(n) + double(dn))^2)/double(1.e6)

return, freq
end
