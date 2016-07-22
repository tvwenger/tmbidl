pro dohe,help=help,fit=fit,base=base,nfit=nfit,nrset=nrset,nregion=nregion, $
         xmin=xmin,xmax=xmax,noflag=noflag,smo=smo,epoch=epoch
;+
; NAME:
;       DOHE
;
;       =================================================================================
;       Syntax: dohe,help=help,fit=fit,base=base,nfit=nfit,nrset=nrset,nregion=nregion, $
;                    xmin=xmin,xmax=xmax,noflag=noflag,smo=smo,epoch=epoch
;       =================================================================================
;
;   dohe  procedure to analyze the 3He spectral region in a standard, uniform manner
;   ----  fixes x-axis,nregions,nfit,and smoothing. 
;         prompts for 6-component Gaussian fit:
;         He171,7 H171,7 H222,16 3-He+ H213,14 H203,12 
;
;        SELECTS the data using lookhe.pro 
;             
;             If KEYWORD 'fit' is set then just fits whatever
;             is in !b[0].data.  Assumes a baseline removed. 
;
;             If KEYWORD 'base' is set then uses !b[0].data
;             and removes standard baseline and does fit 
;             
;   ASSUMES:  correct NSAVE file is attached
;             correct SOURCE is setsrc
;             correct TYPE   is settype e.g. 'S42' via settype,'S42'
;                     override with Keyword 'EPOCH' default is 'EPAV'
;                     after 08/10/2012 EPOCH style is 'EPAVE_XXX'
;
;   KEYWORDS:
;             HELP if set returns Command Syntax 
;             FIT  if set fits !b[0].data, 
;                  does no SELECTNS or BASEline
;
;             BASE if set uses !b[0].data and fits
;                  standard baseline and does fit
;
;             XMIN,XMAX does setx,xmin,xmax    DEFAULT is setx,1100,3000
;             NFIT  sets order of baseline fit DEFAULT is !nfit=6
;             NRSET sets number of NREGIONs    DEFAULT is !nrset=6
;             NREGION sets NREGIONs via !nregion[0:2*(!nrset)-1]=nregion
;                     see code for DEFAULT 
;             NOFLAG if set supresses flagging of the transitions
;             SMO    smoothes in velocity via smov,smo DEFAULT is smov,3.0
;
;-
; MODIFICATION HISTORY:
; 26 apr 2012  TMB 
; 28 jun 2012  TMB  used hephotom as model for enhancements 
; 10 aug 2012  tmb  tweaked to work better with lookhe.pro 
;                   added scaley.pro 
;                   n.b. needs /idl/tmbidl/sandboxes/tmb/gg.pro and
;                              /idl/tmbidl/sandboses/tmb/gfits.pro 
;-
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if Keyword_Set(help) then begin & get_help,'dohe' & return & end
;
; set default analysis parameters
;
case KeyWord_Set(xmin) and KeyWord_Set(xmax) of
     1: begin & setx,xmin,xmax & xx & end 
  else: begin & setx,1100,3000 & xx & end
endcase
if KeyWord_Set(nfit)  then !nfit=nfit else !nfit=6
if KeyWord_Set(nrset) then !nrset=nrset else !nrset=6
case KeyWord_Set(nregion) of
     0: !nregion[0:2*(!nrset)-1]=[1100,1309,1407,1566,1853,1936,2070,2118,2295,2541,2736,3000]
  else: !nregion[0:2*(!nrset)-1]=nregion
endcase
;
if Keyword_set(base) then goto, do_the_baseline
if Keyword_Set(fit)  then goto, do_the_fit
;
; default search via settype,epoch is epoch='EPAV' i.e. all of them
;
if ~Keyword_Set(epoch) then epoch='EPAV' else epoch=epoch 
print
print,'Search for data type = ',epoch
lookhe,epoch=epoch 
;
; set plot and analyze properties for 3-He spectral region
do_the_baseline:
;
dcsub & mk & b
;
do_the_fit:
;
nron
if KeyWord_Set(smo) then smov,smo else smov,3.0
scaley
xx & zline 
if ~KeyWord_Set(noflag) then rrlflag,dnmax=16 
;
trans=strarr(6)
trans=['He171,7 ','H171,7  ','H222,16 ','3-He+   ','H213,14 ','H203,12 '] 
lab=''
npts=n_elements(trans) 
for i=0,npts-1 do begin & lab=lab+trans[i] & endfor 
print & print,'Fit the 6 components:  '+ lab & print
;
gg,!nfit,/noinfo
gfits,fits,/noinfo
;
; now spit out the information
;
print & print,string(!b[0].source) & print
;
he=fits.height[0] & h=fits.height[1] & y=he/h
mask,rms
;
freq=!b[0].sky_freq & dnuperchan=abs(!b[0].delta_x)
dnu=fits.width*dnuperchan & width=(dnu/freq)*!light_c
dnu=fits.errwidth*dnuperchan & errwidth=(dnu/freq)*!light_c
;
fmt='(a,1x,f7.2,1x,f4.2,2x,f5.2,1x,f4.2)'
print,'Line      Height SigH  FWHM   SigFWHM'
print,'            mK         km/s'
print
for i=0,5 do begin
    print,trans[i],fits.height[i],fits.errheight[i],width[i],errwidth[i], $
          format=fmt
endfor
;             
print 
yval='4He/H = '+fstring(y,'(f5.3)')+'  RMS in NREGIONs is = ' 
yval=yval+fstring(rms,'(f7.3)')+' mK' 
print,yval
print
nroff
;
return
end
