pro he4Fit,rec,idx=idx,hfit=hfit,hefit=hefit,help=help
;+
; NAME:
;       he4Fit
;
;  ==========================================================
;  SYNTAX: he4Fit,rec,idx=idx,hfit=hfit,hefit=hefit,help=help
;  ==========================================================
;
;  he4FIT  Process 4-He data to get 4-He+/H+ ratio information.
;  ------  RETURNS the following data structure: 
;
;  rec={he4Data,$ 
;       tH:findgen(8),tHSig:findgen(8),wH:findgen(8),wHSig:findgen(8),$
;       cH:findgen(8),cHSig:findgen(8),$
;       tHe:findgen(8),tHeSig:findgen(8),wHe:findgen(8),wHeSig:findgen(8),$
;       cHe:findgen(8),cHeSig:findgen(8),$
;       areaH:findgen(8),areaHSig:findgen(8),$
;       areaHe:findgen(8),areaHeSig:findgen(8),$
;       y:findgen(8), ySig:findgen(8)} 
;
;      --------------------------------------
;  ==> N.B. Assumes bbb and gg have been run.
;      --------------------------------------
;
;  PARAMETERS: rec - RETURNS data structure above. 
;
;  KEYWORDS:  help  - gives this help
;             idx   - index for he4Data
;             hfit  - Gaussian component to use for H
;             hefit - Gaussian component to use for He 
;
;  RELATED CODE:  he4Area.pro does quick ration of 4-He+/H+ line areas
;
;-
;MODIFICATION HISTORY:
;
;   22 Sep 2009 - dsb Allow velocity scale for x-axis
;   23 Sep 2009 - dsb Add hfit and hefit parameters
;
; V7.0 18may2013 tmb migrated code to V7.0
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) or n_params() eq 0 then begin & get_help,'he4fit' & return & endif
;
; set default parameters
if ~keyword_set(idx)   then idx=0
if ~keyword_set(hfit)  then hfit=2
if ~keyword_set(hefit) then hefit=1

; Get the Gaussian parameters 
heightHe = !a_gauss[(hefit-1)*3]
centerHe = !a_gauss[(hefit-1)*3+1]
widthHe =  !a_gauss[(hefit-1)*3+2]
heightH =  !a_gauss[(hfit-1)*3]
centerH =  !a_gauss[(hfit-1)*3+1]
widthH =   !a_gauss[(hfit-1)*3+2]

; find the channels of the Gauss fitting region
idchan,!bgauss,bgauss
idchan,!egauss,egauss
; check for inverted spectrum
if (bgauss gt egauss) then begin
    foo = bgauss
    bgauss=egauss
    egauss=foo
endif
;
; Accuracy of the fit (Kaper et al. 1966)
;
; sum of squares of the residuals from the model (Eq. 1.4)
s = total((!b[8].data[bgauss:egauss])^2)
; mean error of fitting (Eq. 3.16)
mu2 = s/((egauss - bgauss + 1) - 3.0*2.0)
; sampling interval (assumed to be uniform and in channels)
h = 1.0
;
; He line
;
; dispersion (convert from fwhm to sigma)
sigmaHe = widthHe/2.35
; uncertainty in center or width (Eq. 5.8)
sHeightHe = sqrt( (3.0*h*mu2) / (2.0*sqrt(!pi)*sigmaHe) )
sCenterHe = sqrt( (2.0*h*sigmaHe*mu2) / (sqrt(!pi)*heightHe^2) )
sWidthHe = 2.35*sCenterHe
;
; H line
;
; dispersion (convert from fwhm to sigma)
sigmaH = widthH/2.35
; uncertainty in center or width (Eq. 5.8)
sHeightH = sqrt( (3.0*h*mu2) / (2.0*sqrt(!pi)*sigmaH) )
sCenterH = sqrt( (2.0*h*sigmaH*mu2) / (sqrt(!pi)*heightH^2) )
sWidthH = 2.35*sCenterH
; get area under the Gaussian profile
; He
areaHe = heightHe*widthHe
sAreaHe = areaHe*sqrt( (sHeightHe/heightHe)^2 + (sWidthHe/widthHe)^2 )
; H
areaH = heightH*widthH
sAreaH = areaH*sqrt( (sHeightH/heightH)^2 + (sWidthH/widthH)^2 )
; get y ratio
y = areaHe/areaH
sY = y*sqrt( (sAreaHe/areaHe)^2 + (sAreaH/areaH)^2 )
;
print, 'He Parameters:  ', heightHe, sHeightHe, centerHe, sCenterHe, widthHe, sWidthHe, $
       format='(a16, 3(f11.3,1x,f7.3))'

print, ' H Parameters:  ', heightH, sHeightH, centerH, sCenterH, widthH, sWidthH, $
       format='(a16, 3(f11.3,1x,f7.3))'

print, '         Area:  ', areaHe, sAreaHe, areaH, sAreaH, $
       format='(a16, 2(f11.3,1x,f7.3))'
   
print, '   He/H Ratio:  ', y, sY, $
       format='(a16, f11.5,1x,f7.5)'
;
; fill structure
; helium
rec.tHe[idx]=heightHe
rec.tHeSig[idx]=sHeightHe
rec.wHe[idx]=widthHe
rec.wHeSig[idx]=sWidthHe
rec.cHe[idx]=centerHe
rec.cHeSig[idx]=sCenterHe
rec.areaHe[idx]=areaHe
rec.areaHeSig[idx]=sAreaHe
; hydrogen
rec.tH[idx]=heightH
rec.tHSig[idx]=sHeightH
rec.wH[idx]=widthH
rec.wHSig[idx]=sWidthH
rec.cH[idx]=centerH
rec.cHSig[idx]=sCenterH
rec.areaH[idx]=areaH
rec.areaHSig[idx]=sAreaH
; ratio
rec.y[idx]=y
rec.ySig[idx]=sY
;
return
end
