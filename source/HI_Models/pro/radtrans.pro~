pro radtrans,help=help,spect=spect,vel=vel,dv=dv,$
             dx=dx,ps=ps,noplot=noplot,$
             clouds=clouds,noclouds=noclouds,$
             lgal=lgal,curve=curve,rmax=rmax,$
             gclouds=gclouds,$
             model=model,expdisk=expdisk,dispgrad=dispgrad,smodel=smodel,$
             err=err,verbose=verbose,cont=cont,$
             sumtau=sumtau,annotate=annotate, $
             vmin=vmin,vmax=vmax,ymin=ymin,ymax=ymax,yscale=yscale
;+
; NAME:
;       RADTRANS
;
;            =====================================================
;            Syntax: radtrans,help=help,spect=spect,vel=vel,$
;                             dv=dv,dx=dx,ps=ps,noplot=noplot,$
;                             clouds=clouds,noclouds=noclouds,$
;                             lgal=lgal,curve=curve,rmax=rmax,$
;                             gclouds=gclouds,$
;                             model=model,expdisk=expdisk,$
;                             dispgrad=dispgrad,smodel=smodel,$
;                             err=err,verbose=verbose,cont=cont,$
;                             sumtau=sumtau,annotate=annotate,$
;                             vmin=vmin,vmax=vmax,ymin=ymin,$
;                             ymax=ymax,yscale=yscale
;            =====================================================
;
;   radtrans  procedure to calculate synthetic HI spectra 
;   --------  radiative transfer in optically thin limit   
;             based on "pennsyl.pl1" from 1972 by tmb
;             for modelling Galactic HI 
;             
;             part of Synthetic HI Radiative Transfer Modelling Package:
;                 synthlv.pro, radtrans.pro, los.pro, vlos.pro, makegclouds.pro,
;                 pspiral.pro
;
;   INPUTS:   some keywords are required for things to work right...
;
;   KEYWORDS:
;             HELP     = display syntax and documentation
;             SPECT    = where the spectrum goes (ie, the y values)
;             VEL      = where the velocities go (ie, the x values)
;             DV       = velocity resolution of the spectrum [default=0.25 km/s]
;             DX       = line-of-sight step size [kpc] (smaller = better but longer run-time)
;                        - Default is 0.1 kpc
;             PS       = plot everything to ps
;             ANNOTATE = annotate this text on to the spectrum plot
;             NOPLOT   = do not make plots (used with synthlv.pro)
;
;             CLOUDS   = can be used to pass in line-of-sight cloud info
;                        *IF EMPTY* it is filled with array of cloud structures 
;                        {cloud,d:0.d,vel:0.d,size:0.d,den:0.d,temp:0.d,sigma:0.d}
;             CONT     = create a background continuum at this temperature [K]
;             SUMTAU   = the total optical depth at different velocities
;             NOCLOUDS = do not make any clouds (when only want spiral)
;
;             LGAL     = make galactic clouds via makegclouds.pro and use
;                        this galactic longitude (degrees) for line of sight
;             CURVE    = assign velocity based on rotation curve (ignores any passed velocity)
;                         value   curve
;                           0       Brandt/Burton - Default
;                           1       Clemens
;                           2       McClure-Griffiths - only valid for 3 < d < 8 kpc
;             RMAX     = maximum line-of-sight or galactocentric distance to be used in plot [kpc]
;                        default is 18 kpc
;
;             GCLOUDS  = can be used to pass in galactic cloud info
;                        *IF EMPTY* it is filled with array of gcloud structures 
;                        {gcloud,x:0.d,y:0.d,size:0.d,den:0.d,temp:0.d,sigma:0.d}
;
;             MODEL    = for single, homogeneous galaxy parameters
;                        creates a single cloud and overwrites CLOUDS
;                        or GCLOUDS
;                                  [spin_temp,density,dispersion]
;                        defaults: [110,      0.4,    5.        ]
;             EXPDISK  = use an exponential disk with density at Ro = model density
;             DISPGRAD = use gradient in disk disp with disp at and beyond Ro = model disp
;             SMODEL   = for overlay spiral galaxy model. Creates a
;                        spiral galaxy with parameters:
;                                  [spin_temp,density,dispersion,narms,r0,   theta0,pitch,nturns]
;                        defaults: [40,       1.0,    5.,        2.,   2.52, 0.,    12.,  1.35  ]          
;
;             ERR      = for synthlv.pro error handling
;
;           VMIN/VMAX  = for adjusting LSR velocity axis. defaults -150 and +150 km/s
;           YMIN/YMAX  = for adjusting Y-axis of the V_lsr vs D_sun (defaults -50,+150 km/s)
;           YSCALE     = gets YMIN/YMAX from the data and sets ymin=ymin-10. and ymax=ymax+10.
;
;
;-
; MODIFICATION HISTORY:
;
; V6.1  tmb 16apr2011
;       tvw 27mar2012 to 23jan2013
;                     - modified in to final version.
;       tvw 25mar2013 - fixed velocity=0 problem not displaying correct
;                       spectrum
;                     - added y-axis buffer to make spectrum look nicer
;       tvw 28mar2013 - added VERBOSE, CONT, SUMTAU
;       tvw 11apr2013 - added EXPDISK
;       tvw 29apr2013 - removed recalculation of dx. dx is given by los.pro
;       tmb  3may2013 - HI spectrum now in TMBIDL graphics screen        
;                       added VMIN,VMAX keywords to make LSR velocity axis flexible 
;                       added DV keyword to set velocity resolution of spectrum
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'radtrans' & return &  endif
;
if ~keyword_set(lgal) then lgal=0.d ; 
;
; handle errors
err=0
;
; Currently we assume the models are for bgal = 0 degrees
;
bgal=0.d
;
;
;los,clouds=clouds,lgal=lgal,curve=curve,rmax=rmax,dx=dx,ps=ps,$
;    homog=homog,isoth=isoth,disp=disp,err=err,gal=gal,noplot=noplot,$
;    spiral=spiral,sparams=sparams
;
;if keyword_set(gclouds) then print,"Found gclouds in radtrans"
;
if keyword_set(verbose) then print,"Setting up clouds..."
los,dx=dx,ps=ps,noplot=noplot,$
    clouds=clouds,noclouds=noclouds,$
    lgal=lgal,curve=curve,rmax=rmax,$
    gclouds=gclouds,$
    model=model,expdisk=expdisk,dispgrad=dispgrad,smodel=smodel,$
    err=err,yscale=yscale
;
if err then return
;
common lineofsight,dlos,vlos,denlos,tlos,siglos,intensity
npoints=n_elements(dlos)
;print,dlos
;print,vlos
;print,denlos
;
;dx=(max(dlos)-min(dlos))/npoints ; get dlos point width in kpc
;
if ~Keyword_Set(vmax) then vmax=+150.d
if ~Keyword_Set(vmin) then vmin=-150.d
if ~Keyword_Set(dv)   then dv  =0.25d 
n_vel=(double(vmax)-double(vmin))/double(dv)
vel=dindgen(n_vel)*double(dv) + double(vmin) ; velocities to plot
spect=dblarr(n_vel)  ; intensity vs. velocity
;
sumtau=dblarr(n_vel)     ; sum of optical depth at each velocity
tau = 0.d               ; running tau
;
if keyword_set(verbose) then print,"Evaluating equations of radiative transfer..."
for i=0,npoints-1 do begin             ; start at farthest distance and come in
    ;
    den=denlos[i]
    temp=tlos[i]
    slabV=vlos[i]
    sigma=siglos[i]
    if (~den || ~temp || ~sigma) then continue
    ;
    ;print,den,temp,slabV,sigma
    ;
    for j=0,n_vel-1 do begin               ; calculate the velocity spectrum
        ;kon=den*33.52d/temp/sigma
        ;
        ; equation for HI: 
        ; Column Density [cm-2] = den[cm -3] * dx[kpc] * 3.09d21[cm/kpc] = 
        ; = 3.18d18 * temp[K] * tau * dispersion[km/s]
        ;
        tau=exp(-0.5d*((vel[j]-slabV)/sigma)^2.d)
        tau=tau*den*dx*972.d/temp/sigma
        ;tau=kon*(dx/0.05d) ; Burton's tau is for 50pc slab
        ;                   ; tau is optical depth for k-th slab
        spect[j]=spect[j]+temp*(1.0d - exp(-tau))*exp(-sumtau[j])
        ;
        sumtau[j]=tau+sumtau[j] ; sumtau is total optical depth for j-th slab
        ;if j eq n_vel/2. then begin
        ;   print,tau,sumtau[j],spect[j]
        ;endif
    endfor
endfor
if keyword_set(cont) then begin
   spect=spect+cont*exp(-sumtau)
endif
;
; Plot the spectrum, putting it in the TMBIDL !line_win graphics window
;
if keyword_set(verbose) then print,"Plotting spectrum..."
;       now make the plot
if ~keyword_set(noplot) then begin
   if ~keyword_set(ps) then begin
      device,window_state=win_state
      if win_state[21] eq 1 then wset,21 else window,21,title="Spectrum",xsize=600,ysize=400
   endif else printon,'spectrum'
   ;
   xtitle='LSR Velocity '+textoidl('[km s^{-1}]')
   ytitle='Brightness Temperature [K]' 
   ;
   xrange=[vmin,vmax]
   yrange=[0,max(spect)*1.1]
   ;
   plot,vel,spect,xtitle=xtitle,ytitle=ytitle,$
        xrange=xrange,yrange=yrange,/xstyle,/ystyle,charsize=1.5
   ;  annotate
   title='Velocity Spectrum'
   xyouts,0.15,0.85,title,/normal,charsize=2.
   ;
   ;time=systime()
   ;xyouts,0.7,0.025,time,/normal,charsize=1.5
   ;
   if keyword_set(lgal) then begin
      llabel='lgal = '+fstring(lgal,'(f6.1)')+' degrees'
      xyouts,0.72,0.85,llabel,/normal,charsize=1.5
   endif
   ;
   if Keyword_Set(lgal) then begin
      if ~keyword_set(curve) then curve=0
      case curve of
         0: clabel='Brandt Rotation Curve'
         1: clabel='Clemens Rotation Curve'
         2: clabel='McClure-Griffiths Rotation Curve'
         else: clabel='You should never see this'
      endcase
      xyouts,0.72,0.82,clabel,/normal,charsize=1.5
   endif
   ;
   if keyword_set(annotate) then begin
      if keyword_set(ps) then color=!black else color=!white
      tag,annotate,0.05,0.925,align="B",color=color,size=1.8,thick=2.0
   endif
   ;
;
;  Transfer spectrum to TMBIDL structure
;
@/idl/tmbidl/v7.0/HI_Models/pro/trey2tom.pro
;
   if Keyword_Set(ps) then begin & clr & printoff & endif
endif
;
; Display and annotate in uniform manner with TMBIDL graphics
;
;pause
wset,!line_win   ; switch to TMBIDL graphics window 
;wreset
velo             ; switch to velocity axis
setx,vmin,vmax
xx
zline
flag,0.  ; flag LSR 0 km/sec 
;
return
end
