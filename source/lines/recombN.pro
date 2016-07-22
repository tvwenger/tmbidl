;+
;
;   recombN.pro   Flag N recombination lines 
;   -------        dn=quantum jump; dn=1==\alpha,dn=2==\beta etc
;
;                 Written by G. Langston March 2004
;-
pro recombN,dn,Z
;
on_error,!debug ? 0 : 2
;
; Molecular Formula from Tools of RadioAstronomy, Rolfs and Wilson,
; 2000, pg 334
;
;  v_ki = Z^2 R_M ( 1/i^2  - 1/k^2), where R_M = R_infinity/(1 + m/M)
;  v_ki = R_A     ( 1/i^2  - 1/k^2) (k > i)
; Nitrogen values (MHz)
if keyword_set(Z) then Z = Z else Z = 1.
if Z lt 1. then Z = 1.
;
Ra = Z*Z*3.28971314E9
; do alpha lines by default
if keyword_set(dn) then dn = dn else dn = 1
if dn lt 1 then dn = 1
;
xmin = !x.crange[0]
xmax = !x.crange[1]
ymin = !y.crange[0]
ymax = !y.crange[1]
xrange = xmax-xmin
yrange = ymax-ymin
yincr=0.025*yrange
;
xminij = xmin/Ra
xmaxij = xmax/Ra
;
greeks=['\alpha','\beta','\gamma','\delta','\epsilon',$
        '\zeta','\eta','\theta','\iota','\kappa', $
        '\lambda','\mu','\nu','\xi','\omikron','\pi']
;
if (dn lt 15) then greek = 'N' + greeks[dn-1]
if (dn gt 14) then greek='N:' + fstring(dn,'(I2)') + ':'
;
; now step through all likely lines
for i = 2,200 do begin
  k = i + dn
  vij = (1./(i*i)) - (1./(k*k))
  if ((vij gt xminij) && (vij lt xmaxij)) then begin
    xij = vij*Ra
    if (k le 9)            then textLabel = textoidl(greek + fstring(k,'(I1)'))
    if (k gt 9 && k lt 100)then textLabel = textoidl(greek + fstring(k,'(I2)'))
    if (k gt 99)           then textLabel = textoidl(greek + fstring(k,'(I3)'))
    flg_id, xij, textLabel, !cyan
  endif
endfor
;
return
end
