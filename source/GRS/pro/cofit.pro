;+
; NAME: COFIT 
;
;    ===========================================================================
;    Syntax: cofit, gvname, lastns=lastns, skip=skip 
;    ===========================================================================
;
;   cofit -- Fit Gaussians to GRS 13-CO spectra associated with HRDS targets. 
;   -----    
;            Input HRDS source GVNAME: G18.156+0.099+53.0
;             
;             lastns=lastns can override exisitng !lastns value
;
; =====> Parses the l_gal, b_gal, and vlsr from source name 
;        using PGVNAME.pro and gets GRS CO spectrum via Beamlb.pro
;
; =====> If keyword_set(skip)then DOES NOT SEARCH AT ALL but just
;         analyzes the current !b[0] spectrum
;
; =====> Spectra with stored Gaussian Fits are in the NSAVE:
;        /idl/tmbidl/data/nsaves/GRS/hrdsGRS.dat and hrdsGRS.key
;
; =====> Gaussian Fit Parameters are stored in a table:
;        /idl/tmbidl/HRDS_GRS_CO_FITS
;
;        Archive begins with !lastns=999
;
;  V6.1 11feb2011 tmb from rrlfit.pro as starting point
;
;-
PRO cofit,gvname,lastns=lastns,skip=skip
; 
on_error,2
compile_opt idl2
@CT_IN
;
tablename='/idl/tmbidl/tables/HRDS_GRS_CO_FITS'
openu,lun,tablename,/append,/get_lun
;
IF Keyword_Set(lastns) THEN !lastns = lastns ELSE lastns = !lastns
If Keyword_Set(skip) then goto, skip_to_fit
;
;goto,skip_this_for_the_nonce
IF N_Params() eq 0 THEN BEGIN
    print,'====================' 
    print,'Syntax: cofit,gvname'
    print,'====================' 
    print, 'Must specify all parameters!'
    RETURN
    ENDIF
;
skip_this_for_the_nonce:
; Turn off write protection
redo_nson = 0
IF !protectns THEN BEGIN
    print, 'NSAVE write protection is ON.  Turn it OFF? (y/n)'
    pause,ians
    IF StrUpCase(ians) EQ 'Y' THEN BEGIN
        nsoff
        redo_nson = 1
    END
ENDIF
;
; parse the GVNAME into (l,b,v) and generate string output
;
pgvname,gvname,lgal,bgal,vlsr,out=out
;
nroff
grsdisplay,lgal,bgal,vlsr        ; fetch spectrum & flag HRDS velocity +/- 10 km/sec
;
Xrange:
read,xmin,xmax, prompt='Enter X-axis Range: Vmin and Vmax:  '
setx,xmin,xmax
TryAgain:
xx & zline & flag,vlsr,color=!red & flag,vlsr-10. & flag,vlsr+10.
;
print,'Is the X-axis range OK? (y/n)'
pause,cans
if StrUpCase(cans) eq 'N' then goto, Xrange
;
print,'Is this baseline OK? (y/n)'
pause,cans
if StrUpCase(cans) eq 'Y' then goto, FitGauss
Baseline:
nron
print,'Enter Number of NREGIONS:  '
pause,cans,nreg
nrset,nreg
print,'Enter Order of Baseline fit:  '
pause,cans,nfit
bb,nfit
zline & flag,vlsr,color=!red & flag,vlsr-10. & flag,vlsr+10.
print,'Is this baseline fit OK? (y/n)'
pause,cans
if StrUpCase(cans) eq 'N' then goto, TryAgain
;
FitGauss:
;
skip_to_fit:
;
; Fit the Gaussian 
;        
unhappy = 1
WHILE unhappy DO BEGIN
    print, 'Number of Gaussians to fit to this spectrum:'
    pause, cans, ians
    gg, ians
;    
    print, 'Are you happy with this fit? (y/n)'
    pause, ians
    IF StrUpCase(ians) EQ 'Y' THEN unhappy = 0 ELSE BEGIN
    xx & zline & flag,vlsr,color=!red & flag,vlsr-10. & flag,vlsr+10. 
   ENDELSE
ENDWHILE
;
; store fit information in header
;
flag_state=!flag & flagoff & history & !flag=flag_state
;
; print fit information to file
;
gfits,fits,/noinfo,/nohdr
mask,rms & rms=rms*1000.
ngauss=fits.ngauss
sfit=strarr(ngauss)
;
for i=0,ngauss-1 do begin
;
Vco=fits.center[i] & errVco=fits.errcenter[i] 
Tco=fits.height[i] & errTco=fits.errheight[i]
Wco=fits.width[i]  & errWco=fits.errwidth[i]
;
sfit[i]=fstring(Vco,'(f7.2)')+' '+fstring(errVco,'(f5.2)')+' '
sfit[i]=sfit[i]+fstring(Tco,'(f6.2)')+' '+fstring(errTco,'(f5.2)')+' '
sfit[i]=sfit[i]+fstring(Wco,'(f5.2)')+' '+fstring(errWco,'(f5.2)')+' '
sfit[i]=sfit[i]+fstring(rms,'(f6.2)')+' '
;
print & print,out+sfit[i]
;
print
print,'Do you want to write this fit to the Table File? (y/n)'
pause,cans
IF StrUpCase(cans) EQ 'Y' THEN BEGIN 
   printf,lun,out+sfit[i]
ENDIF ELSE BEGIN & goto, flush & ENDELSE
;
endfor
;
; store spectrum plus fits in NSAVE
;
print
print,'Store this is NSAVE= '+fstring(lastns+1,'(i5)')+'? (y/n)'
pause,cans
IF StrUpCase(cans) EQ 'Y' THEN BEGIN 
   putns, lastns + 1 & lastns = lastns + 1 & 
ENDIF ELSE BEGIN & goto, flush & ENDELSE
;
flush:
!lastns=lastns  ; bookeeping of !lastns
nroff ; turn off nregion boxes
free_lun,lun
;
@CT_OUT
;
return
END
