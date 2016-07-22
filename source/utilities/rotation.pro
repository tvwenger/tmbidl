PRO ROTPLOT, ps=ps, fname=fname
;+
; NAME:
;   ROTPLOT
; PURPOSE:
;   To calculate and plot Galactic rotation curves as derived by Clemens (1985).
;   and Burton (1988) in 2nd ed. Galactic and Extragalactic Radio Astronomy 
;            
; CALLING SEQUENCE:
;    ROTCURV
; INPUT: NONE
;
; REVISION HISTORY:
;    Written by T.M. Bania, July 3, 2002 
;    N.B. modified 1986 coefficients for (8.5,220) 
;-
;
on_error,2                
compile_opt idl2              
@CT_IN
;
if ~Keyword_Set(ps) then ps=0
if ~Keyword_Set(fname) then fname='/idl/tmbidl/figures/PSfig'
;
ylab='Rotational Velocity'+'(km s!U-1!N)'
xlab='Galactic Radius (kpc)'
xsize=10. & ysize=5. 
;
if ps ne 0 then $          
;
psopen,fname,xsize=xsize,ysize=ysize,/encap,/inch,/color
;
COMMON R,THETA
R=DBLARR(1000)
THETA=DBLARR(1000) 
;
FOR J = 0,200 DO BEGIN
      R[J] = 0.D0 + 0.1D0 * J
      THE = THETA[J]
      ROTCURV_DPC,R[J],THE
      THETA[J]=THE
ENDFOR
;
R=R[0:J-1]
THETA=THETA[0:J-1]
;
!p.multi=0 ; ******  single plot figure
;
; Rotational Velocity (km/sec) vs Galactic Radius (kpc) 
plot,R,THETA,linestyle=0,ytitle=ylab,xtitle=xlab, $
     yrange=[175.,250.],xrange=[2.,15.],/xstyle,/ystyle, $
     xthick=3,ythick=3
;
FOR J = 0,200 DO BEGIN
      R[J] = 0.D0 + 0.1D0 * J
      THE = THETA[J]
      ROTCURV_WBB,R[J],THE
      THETA[J]=THE
ENDFOR
;
oplot,R,THETA,linestyle=5
;
FOR J = 0,200 DO BEGIN
      R[J] = 0.D0 + 0.1D0 * J
      THE = THETA[J]
      ROTCURV_nmg,R[J],THE
      THETA[J]=THE
ENDFOR
;
idx=where(R ge 3.0 and R le 8.0)
R=R[idx]
THETA=THETA[idx]
oplot,R,THETA,linestyle=1
;
flush:
!p.multi=0
;
@CT_OUT
if ps ne 0 then psclose
;
return
END
