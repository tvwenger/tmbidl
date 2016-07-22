PRO ROTCURV_WBB,R,THETA 
;+
; NAME:
;   ROTCURV_WBB
; PURPOSE:
;   To calculate Galactic rotation curve as quoted by by W. B. Burton
;   in Galactic and Extragalactic Radio Astronomy.  According to WBB
;   the curve is from: Brand, J., \& Blitz, L, 1987, in press but it
;   never appeared.
;
;   Burton, W.B. 1974, in ``Galactic and Extragalactic Radio
;   Astronomy'', second edition, K. I. Kellermann \& G. L. Verschuur,
;   eds., (Springer-Verlag: New York), pg. 312.
;
; OK:  Butler says everyone cites: 
;             Brand, J., \& Blitz, L. 1993,  Astron. Ap., 275, 67.
; but maintains this is incorrect and proper reference should be:
;             Brand, J. 1986, PhD Thesis, Leiden Univ. (Netherlands)
;            
; CALLING SEQUENCE:
;    ROTCURV_WBB,R,THETA   ;Input=  galactic radius in kpc 
;                          ;Output= circular rotation velocity in km/sec 
; INPUT: R which is the galactic radius in kpc 
;
; REVISION HISTORY:
;    Writen by T.M. Bania, July 9, 2002 
;    N.B. valid for (R0,@0)XS = (8.5,220) 
;-
R0=8.5D+0
THETA0=220.0D+0
C=[1.0074D+0,0.0382D+0,0.00698D+0]
;
THETA = THETA0 * ( C(0) * (R/R0)^C(1) + C(2) ) 
RETURN
END
