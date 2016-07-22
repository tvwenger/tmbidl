PRO ROTCURV_DPC,R,THETA 
;+
; NAME:
;   ROTCURV_DPC
; PURPOSE:
;   To calculate Galactic rotation curve as derived by Clemens (1985).
;
;   Clemens, D.P., 1985, ApJ, 295, 422-428. 
;            
; CALLING SEQUENCE:
;    ROTCURV_DPC,R,THETA   ;Input=  galactic radius in kpc 
;                          ;Output= circular rotation velocity in km/sec 
; INPUT: R which is the galactic radius in kpc 
;
; REVISION HISTORY:
;    Written ca. Aug. 1997 T.M. Bania in FORTRAN
;    Adapted to PC IDL.  T.M. Bania, July 3, 2002 
;    N.B. modified 1986 coefficients for (8.5,220) 
;-
R1=DBLARR(3)
C = DBLARR(8,4)
R1 = [0.77D0,3.83D0,13.6D0]
C(*,*) = [0.D0,3078.70187548D0,-15937.80906803D0,44623.47104835D0,$
     -69734.79267600D0,56395.86525824D0,-18305.31278690D0,$
     0.D0,319.25427818D0,-233.66005009D0,219.83040129D0,$
     -106.19056430D0,24.26673241D0,-2.05584939D0,0.D0,0.D0,$
     -2345.29882551D0,2510.34169244D0,-1025.21966866D0,$
     224.81807259D0,-28.44039195D0,2.07208388D0,$
     -0.08059951D0,0.00129494D0,234.90416993D0,0.D0,0.D0,0.D0,$
     0.D0,0.D0,0.D0,0.D0] 
;
I = 0
IF (R GE R1(0)) THEN  I = 1 
IF (R GE R1(1)) THEN  I = 2 
IF (R GE R1(2)) THEN  I = 3
OM = C(0,I) 
IF I EQ 3 THEN GOTO, OUT	
FOR J = 1, 7 DO OM = OM + C(J,I) * (R^(J)) 
;
OUT: THETA=OM
RETURN
END
