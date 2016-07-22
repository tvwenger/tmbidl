PRO VT,l_gal,vt_dpc,vt_wbb,vt_nmg
;+
; NAME:
;   VT
; PURPOSE:
;   Calculate Galactic tangent point velocities in first quadrant.
;   Derived from the rotation curves of Clemens (1985),
;   Burton (1988) (see rotcurv_wbb.pro for real Brandt reference),
;   and McClure-Griffiths & Dickey 
;            
; CALLING SEQUENCE:
;    VT,l_gal,vt_dpc,vt_wbb,vt_nmg
;
;    l_gal is galactic longitude in degrees
;    returns Vtan for DPC, WBB, and NMG rotation curves
;
; REVISION HISTORY:
;    Written by T.M. Bania, 7 June 2006
;    Modified by TMB 28 Aug 2007 to include McClure-Griffiths & Dickey curve
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
RT=8.5D+0 * SIN(l_gal*!DTOR )
VT_DPC=0.d
VT_WBB=0.d
VT_NMG=0.d
THETA=0.D
;
ROTCURV_DPC,RT,THETA
VT_DPC = RT * ( (THETA/RT) - (25.88235D+0) ) ; 220.0 km/s / 8.5 kpc 
;
ROTCURV_WBB,RT,THETA
VT_WBB = RT * ( (THETA/RT) - (25.88235D+0) ) ; 220.0 km/s / 8.5 kpc 
;
ROTCURV_NMG,RT,THETA
IF THETA gt 0. THEN VT_NMG = RT * ( (THETA/RT) - (25.88235D+0) ) $
               ELSE VT_NMG=9999.
;
return
end
