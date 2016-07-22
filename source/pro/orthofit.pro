function ortho_fit,xx,yy,nfit,cfit,rms,help=help
;+
; NAME:
;       ORTHOFIT
;       ortho_fit,xx,yy,nfit,cfit,rms,help=help
;
;   ortho_fit   Function uses general orthogonal polynomial to 
;   ---------   do least squares fitting.
;                   *******************************************
;                   THIS FUNCTION NOT NORMALLY INVOKED BY USER:
;                   It is invoked by baseline fitting routines.
;                   *******************************************
;                   Despite the caveat below, routine almost never
;                   diverges.  It returns 'sane' fits for
;                   nfit =< 100 !!!
;
;  returns polyfit: contains information for fitting to arbitrary
;  points using the recursion relations
;
;  on return 
;       cfit has coefficients of the polynomial fit = sum(m) a_m x^m
;         because of round-off using this form gives unreliable
;         results above about order 15 even for double precision
;       rms is an array with the rms error for a polynomial fit for
;       each polynomial up to order nfit 
;
;   written by John G. Lyon, Feb. 2004 especially for this package
;
;
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;- 
;
on_error,!debug ? 0 : 2
compile_opt idl2 
if keyword_set(help) then begin & get_help,'orthofit' & return,-1 & endif
;
xsize=size(xx)
;  print,xsize
n = xsize[1]

; initialize needed arrays
polyfit = dblarr(4,nfit+1)
rms = dblarr(nfit+1)
coef = dblarr(nfit+1)
coef[0:nfit] = 0.0
c0 = coef 
c1 = coef
c2 = coef
cfit = coef 

fit = dblarr(n)
fit[0:n-1] = 0.
x = fit
f = fit
p0 = fit
p1 = fit
pnp1 = fit 
pn = fit 
pnm1 = fit

x[0:n-1] = xx[0:n-1]
f[0:n-1] = yy[0:n-1]


; get the first couple of polynomials

p0[0:n-1] = 1.0
xnorm = sqrt(total(p0^2))
p0 = p0/xnorm
c0[0] = 1./xnorm

a = total(x*p0)
p1 = x - a*p0
xnorm = sqrt(total(p1^2))
c1[1] = 1.0
p1 = p1/xnorm
c1 = (c1 - a*c0)/xnorm

; first couple of fit coefficients
coef[0] = total(f*p0)
coef[1] = total(f*p1)
polyfit[0,0] = c0[0]
polyfit[3,0] = coef[0]
polyfit[0:1,1] = c1[0:1]
polyfit[3,1] = coef[1]
rms[0] = total( (f-coef[0]*p0)^2)
cfit = coef[0]*c0 + coef[1]*c1
fit = coef[0]*p0 + coef[1]*p1
rms[1] = total( (f-fit)^2 )
;

; loop up the order, using general recursion relation
pnm1 = p0
pn = p1
cnm1 = c0
cn = c1
;  print, 'cfit before loop', cfit
for m=2,nfit do begin
     a = -1./total(x*pn*pnm1)
     b = -a*total(x*pn^2)
     ;  print,'iteration ',m,a,b
     pnp1 = (a*x + b)*pn + pnm1
     
     xnorm = sqrt(total(pnp1^2))
     pnp1 = pnp1/xnorm
     coef[m] = total(f*pnp1)
     ctmp = shift(cn,1)
     ctmp[0] = 0.
     cnp1 = (a*ctmp + b*cn + cnm1)/xnorm
     cfit = cfit + coef[m]*cnp1
     fit = fit + coef[m]*pnp1
     polyfit[0,m] = 1./xnorm
     polyfit[1,m] = b/xnorm
     polyfit[2,m] = a/xnorm
     polyfit[3,m] = coef[m]
     rms[m] = total( (f-fit)^2 )
     cnm1 = cn
     cn = cnp1
     pnm1 = pn
     pn = pnp1
 endfor

 rms = sqrt( rms/float(n) )

;help
 return, polyfit
end


function ortho_poly,x,cfit
; function returns the fitted points at x
; cfit(l,m) => cfit(0:3,0:nfit)
;     cfit(3,m) gives the weighting coefficient for the m-th
;     orthogonal polynomial
;     cfit(0:2,m) for m=2 are the recursion coefficients for p^(m) =
;     x*p^(m-1)*cfit(2,m) + p^(m-1)*cfit(1,m) + p^(m-2)*cfit(0,m)   
;     cfit(0,0) is the value of the constant term
;     p^(1) = cfit(1,1)*x + cfit(0,1)
;
a = size(x)
n = a[1]
b = size(cfit)
nfit = b[2]-1
fit = dblarr(n)

pnm1 = dblarr(n)
pn = pnm1
pnp1 = pnm1
pnm1(0:n-1) = cfit(0,0)
pn = x*cfit(1,1) + cfit(0,1)
fit = cfit(3,0)*pnm1 + cfit(3,1)*pn

for m=2,nfit do begin
    pnp1 = pn*(x*cfit(2,m) + cfit(1,m)) + pnm1*cfit(0,m)
    fit = fit + cfit(3,m)*pnp1
    pnm1 = pn
    pn = pnp1
endfor

return,fit
end
