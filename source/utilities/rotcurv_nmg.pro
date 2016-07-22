PRO ROTCURV_NMG,R,THETA 
;+
; NAME:
;   ROTCURV_NMG
; PURPOSE:
;   To calculate Galactic rotation curve as derived by 
;   Naomi McClure-Griffiths & John Dickey 2007 ApJ, in the press
;
;   This linear curve is valid only for 3 <= R <= 8 kpc
;            
; CALLING SEQUENCE:
;    ROTCURV_NMG,R,THETA   ;Input=  galactic radius in kpc 
;                          ;Output= circular rotation velocity in
;                          km/sec 
;    
; INPUT: R which is the galactic radius in kpc 
;
; If R is not in valid range returns THETA=-99.
;
; REVISION HISTORY:
;    Writen by T.M. Bania, 28 Aug 2007
;    N.B. valid for (R0,@0)XS = (8.5,220) 
;-
R0=8.5D+0
THETA0=220.0D+0
C=[0.887D+0,0.186D+0]
;
THETA=-99.D+0
;
IF R ge 3. and R le 8. then THETA = THETA0 * ( c[0] + c[1] * R/R0 )
;
RETURN
END
