pro photom,help=help,fit=fit,label=label,src=src,id=id,type=type, $
           setx=setx,nrset=nrset,nregion=nregion, $
           nfit=nfit,smo=smo,ngauss=ngauss
;+
; NAME:
;       PHOTOM
;
;  =======================================================================
;  Syntax: photom,help=help,fit=fit,label=label,src=src,id=id,type=type, $
;                 setx=setx,nrset=nrset,nregion=nregion, $ 
;                 nfit=nfit,smo=smo,ngauss=ngauss 
;  =======================================================================
;
;   photom  Does 'photometry' on specta to evaluate data quality. 
;   ------  Searches NSAVE file via SELECTNS, averages the STACK, 
;           and then fits. Executes HISTORY after the fit. 
;           Runs in either fully interactive or batch mode. 
;           A work in progress. Originally written for 3He H91 alpha
;
;           If KEYWORD 'fit' is set then just fits whatever
;           is in !b[0].data
;             
;   ASSUMES:  correct NSAVE file is attached
;             correct SOURCE is set using setsrc
;             correct TYPE   is set using, e.g., settype,'S42'
;             correct x,y axis ranges set 
;
;   KEYWORDS: DEFAULTS are *current* values for all variables 
;             UNLESS OTHERWISE STATED
;
;             HELP    - if set returns Command Syntax 
;             FIT     - if set fits !b[0].data, does no SELECTNS
;             LABEL   - if set does tagtype,label so label is annotation string
;             SRC     - if set does setsrc,src so src is string for source name 
;             ID      - if set does setid,id so id is string for Rx ID 
;             TYPE    - if set does settype,type so type is string for data type
;             NFIT    - if set sets order of baseline fit
;             NRSET   - if set sets number of regions used to fit baseline
;                     - INTERACTIVE! if set prompts for cursor definition
;             NREGION - if set sets values of baseline fitting regions
;                       BATCH! NREGION must be a 2*nrset element array
;                              in X-axis units. Array used to set NRSET value. 
;             ***===>   CANNOT simultaneously use  NRSET and NREGION keywords 
;             SMO     - if set sets number of channels to smooth 
;             NGAUSS  - if set set number of gaussians to fit 
;             SETX    - if set set X-axis range 'setx' must be a 2 element array 
;                       in X-axis units: setx=[start,stop];            
;
;-
; MODIFICATION HISTORY:
; 26 apr 2012  TMB 
; 11 jun 2012  tmb made general in regard to source 
; 25 jun 2012  tmb fixed bug to /fit works correctly
;  1 jun 2014  tmb/tvw modified he3photom.pro to be more general
;              added full error propagation for y value calculation
;              which is now calculated from line area.
;              tweaked to automatically add HISTORY 
; 05jun2014 tmb generalizes code by adding keywords: 
;               label,src,type,id,nfit,nrset,nregion
; 
;
;-
;
on_error,2          ; on error return to top level
compile_opt idl2    ; compile with long integers 
if Keyword_Set(help) then begin & get_help,'photom' & return & endif
;
; can hardwire different defaults here 
;
;setsrc,'Orion-E' & setid,'H105'   
settype,'EPAV'
!nrset=3 & !nfit=3 & nsmo=3 & ngauss=2
nron & !nrset=3
!nregion[0:2*(!nrset)-1]=[1700,1800,1900,1984,2113,2300]
;!nregion[0:2*(!nrset)-1]=[2100,2185,2320,2355,2510,2600]
;!nregion[0:2*(!nrset)-1]=[2525,2595,2677,2776,2870,2950]
;!nregion[0:2*(!nrset)-1]=[50,103,186,284,407,500] ; H128 beta
;!nregion[0:2*(!nrset)-1]=[2100,2153,2230,2317,2425,2500] ; H137 beta
;!nregion[0:2*(!nrset)-1]=[800,875,985,1066,1166,1250] ; H152 gamma
;!nregion[0:2*(!nrset)-1]=[2125,2186,2240,2264,2293,2344,2500,2580] ; H155 gamma Ori-S
; [2124,2184,2261,2284,2310,2339,2511,2580] ; H155 gamma Ori-E & W
;
setx,1700,2300   ; H150 alpha
;setx,50,500     ; H128 beta
;setx,2100,2500  ; H137 beta
;setx,800,1250   ; H152 gamma 
;setx,2125,2580   ; H155 gamma 
;
;

if Keyword_Set(src)     then begin & setsrc,src        & endif ; default is !src
if Keyword_Set(type)    then begin & settype,type      & endif ; default is !type
if Keyword_Set(id)      then begin & setid,id          & endif ; default is !id 
if Keyword_Set(nfit)    then begin & !nfit=nfit        & endif ; default is !nfit=3
if Keyword_Set(smo)     then begin & nsmo=smo          & endif ; default is nsmo=3
if Keyword_Set(ngauss)  then begin & !ngauss=ngauss    & endif ; default is ngauss=2
;
src=strtrim(!src,2) & id=strtrim(!id,2) & 
;
; code below for spectral line relative photometry 
;
;case src of
;           'NGC7538G'  : tpk=1003.4
;           'G29.9G'    : tpk= 656.6
;           'S206'      : tpk= 221.8
;           'S209'      : tpk= 165.0
;           'W3'        : tpk=4353.7
;           'NGC3242'   : tpk=  38.9
;           'NGC6543'   : tpk=  95.0
;           'M16G'      : tpk= 264.0
;           'G201.6'   :  tpk=  25.0 
;                  else : begin & print,'No photometry available for '+src & return & end                  
;endcase
;
;print,'Photometry based on Tpk = '+fstring(tpk,'(f6.1)')+' for '+src
;
if Keyword_Set(fit) then goto, do_the_fit
;
clrstk & selectns & catns & avgns & dcsub & mk & xx & rrlflag,dnmax=16
;
if Keyword_Set(setx) then begin 
   if n_elements(setx) ne 2 then begin
   msg='ERROR: setx must be 2 element array giving X-axis start & stop'
   print,msg & print & return & endif
   setx,setx[0],setx[1]
endif 
; 
if Keyword_Set(nrset) and Keyword_Set(nregion) then begin 
   print,'ERROR: Cannot us KeyWords "nrset" & "nregion" simultaneously'
   return
endif
;
if Keyword_Set(nrset) then begin 
   print,'Define '+fstring(nrset,'(i2)')+' NREGIONs with 2 clicks per box, left to right' 
   nrset,nrset
endif ; default is !nrset=3
;
if Keyword_Set(nregion) then begin  ; default is !nregion
   num=n_elements(nregion)
       if num mod 2 ne 0 then begin
          print,'ERROR! NREGIONs must be specified in argument pairs !'
       return & endif
   !nregion[0:num-1]=nregion & !nrset=num/2
endif
;
flagon & smo,nsmo & flagoff & b & print
;
; set plot and analysis properties for 
do_the_fit:
;
xx & zline & rrlflag,dnmax=16 
print & print,'Fit '+fstring(!ngauss,'(i2)')+' components' & print
gg,ngauss
gfits,fits,/noinf
print,'Tsys = '+fstring(!b[0].tsys,'(f6.1)')+' K'
;
; N.B. this code below assumes ngauss=2 
;
TpkHe=fits.height[0] & fwhmHe=fits.width[0]
sigTpkHe=fits.errheight[0] & sigfwhmHe=fits.errwidth[0]
TpkH =fits.height[1] & fwhmH =fits.width[1]
sigTpkH=fits.errheight[1] & sigfwhmH=fits.errwidth[1]
ewHe=TpkHe*fwhmHe & ewH=TpkH*fwhmH 
y=ewHe/ewH
; now propagate error in y=4He/H ratio of line areas
sigewHe=  sqrt( (fwhmHe*sigTpkHe)^2 + (TpkHe*sigfwhmHe)^2 )
sigewH=   sqrt( (fwhmH*sigTpkH)^2   + (TpkH*sigfwhmH)^2   )
sigy= y * sqrt( (sigewHe/ewHe)^2    + (sigewH/ewH)^2     )
print
yval='4He/H = '+fstring(y,'(f5.3)')+' +/- '+fstring(sigy,'(f6.4)')
print,yval
print
;
;h910=tpk & sh910=fstring(h910,'(f6.1)')            
; H91alpha intensity for fiducial epoch
;print,'H91 alpha standard photometry based on Tpk = '+fstring(tpk,'(f6.1)')+' for '+src
;r=h/h910
;label='H91 alpha relative to '+sh910+' = '
;label=label+fstring(h,'(f6.1)')+'/'+sh910+' = '
;label=label+fstring(r,'(f5.3)')+' => '
;
;case r ge 1. of
;           1: begin
;              p=100*(r-1.)
;              label=label+fstring(p,'(f4.1)')+' % HIGHER than nominal'
;              print,label
;              end
;        else: begin
;              p=100*(1.-r)
;              label=label+fstring(p,'(f4.1)')+' % LOWER than nominal'
;              print,label
;              end
;endcase
;             
; set up for saving these fits 
;
nron
tagtype,'H108 alpha Fit'
if Keyword_Set(label) then tagtype,label
scaley & xx & g,/info & zline & rrlflag & history 
;
return
end
