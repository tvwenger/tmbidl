PRO ROTPLOT
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
COMMON R,THETA
R=DBLARR(1000)
THETA=DBLARR(1000) 
FOR J = 0,200 DO BEGIN
      R[J] = 0.D0 + 0.1D0 * J
      THE = THETA[J]
      ROTCURV_DPC,R[J],THE
      THETA[J]=THE
ENDFOR
R=R[0:J-1]
THETA=THETA[0:J-1]
;FOR J = 0,200 DO PRINT,R[J],THETA[J]
;
; chose fonts:  -1 for vector generated  0 for harware
;
!p.font=-1
;
; chose character size  1.0 default.  not used if !p.font=0
;
!p.charsize=1.5
;
; Now make plots
;
!p.multi=0 ; ******  single plot figure
;
; Rotational Velocity (km/sec) vs Galactic Radius (kpc) 
plot,R,THETA,linestyle=0,thick=2.,ytitle='!17Rotational Velocity (km/sec)',$
xtitle='!17Galactic Radius ]kpc)',yrange=[0.,300.],xrange=[-1.,20.],/xstyle
;
FOR J = 0,200 DO BEGIN
      R[J] = 0.D0 + 0.1D0 * J
      THE = THETA[J]
      ROTCURV_WBB,R[J],THE
      THETA[J]=THE
ENDFOR
;
oplot,R,THETA,linestyle=0,thick=4
;
END
