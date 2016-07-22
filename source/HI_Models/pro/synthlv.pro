pro synthlv,ex,help=help,dl=dl,noplot=noplot,$
            dx=dx,ps=ps,fname=fname,$
            curve=curve,rmax=rmax,$
            gclouds=gclouds,noclouds=noclouds,$
            model=model,expdisk=expdisk,dispgrad=dispgrad,smodel=smodel,$
            noimage=noimage,ct=ct,contours=contours,$
            minscale=minscale,maxscale=maxscale,clip=clip,$
            spects=spects,vel=vel,lgals=lgals,pause=pause,$
            noprogress=noprogress,verbose=verbose, $
            vmin=vmin,vmax=vmax,dv=dv
;+
; NAME:
;       synthlv
;
;            ======================================================================
;            Syntax:
;            synthlv,ex,help=help,dl=dl,noplot=noplot,$
;                    dx=dx,ps=ps,fname=fname,$
;                    curve=curve,rmax=rmax,$
;                    gclouds=gclouds,noclouds=noclouds,$
;                    model=model,expdisk=expdisk,dispgrad=dispgrad,smodel=smodel,$
;                    noimage=noimage,ct=ct,contours=contours,$
;                    minscale=minscale,maxscale=maxscale,clip=clip,$
;                    spects=spects,vel=vel,lgals=lgals,pause=pause,$
;                    noprogress=noprogress, verbose=verbose, $
;                    vmin=vmin,vmax=vmax,dv=dv
;            ======================================================================
;
;   synthlv  procedure to 
;   -------  make an l-v map for a model distribution of HI in the galaxy    
;
;            part of Synthetic HI Radiative Transfer Modelling Package:
;                synthlv.pro, radtrans.pro, los.pro, vlos.pro, makegclouds.pro,
;                pspiral.pro                 
;
;   INPUTS:       ex = run a pre-defined experiment
;                  0 = make a model galaxy of homogeneous HI distribution with
;                      spin_temp = 110 K
;                      density   = 0.4 #/CC
;                      dispersion= 5.0 km/s
;                      Clemens Rotation Curve
;                  1 = make a model spiral galaxy. HI in spiral arms and bulge have:
;                      spin_temp = 40 K
;                      density   = 1.0 #/CC
;                      dispersion= 5.0 km/s
;                      Clemens Rotation Curve
;                      2-armed Spiral with r0=2.52 kpc, theta0=0. degs, pitch=12. degs, and 1.6 turns
;                  2 = combine ex=0 and ex=1, i.e. a homogeneous distribution with a spiral on top          
;
;   KEYWORDS:
;             HELP     = display syntax and documentation
;             DL       = increment in galactic longitude for the l-v map
;                        - Default is 10.0 degree (smaller = better but longer run-time)
;
;             DX       = line-of-sight step size [kpc] (smaller = better but longer run-time)
;                        - Default is 0.1 kpc
;             PS       = plot everything to ps
;             FNAME   = name of file (without .ps) where l-v map goes
;                        default is 'lvmap'
;             NOPLOT  = don't show intermediate plots (shorter run-time)
;                        *** FOR THE LOVE OF GOD, DO NOT DO /PS WITHOUT /NOPLOT ***
;                            I'M NOT ENTIRELY SURE WHAT WOULD HAPPEN
;
;             CURVE    = assign velocity based on rotation curve (ignores any passed velocity)
;                         value   curve
;                           0       Brandt/Burton - Default
;                           1       Clemens
;                           2       McClure-Griffiths - only valid for 3 < d < 8 kpc
;             RMAX     = maximum line-of-sight or galactocentric distance to be used in plot [kpc]
;                        default is 12 kpc
;             
;             GCLOUDS  = can be used to pass in galactic cloud info
;                        *IF EMPTY* it is filled with array of gcloud structures 
;                        {gcloud,x:0.d,y:0.d,size:0.d,den:0.d,temp:0.d,sigma:0.d}
;             NOCLOUDS = do not make any clouds (when only want spiral)
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
;             NOIMAGE  = don't make an image
;             CT       = colortable for the l-v map. default is 3 (red temperature)
;             CONTOURS = make contours
;
;             MINSCALE = parameter for image making
;             MAXSCALE = parameter for image making
;             CLIP     = parameter for image making
;                        - don't worry about these
;
;             PAUSE    = pause between each iteration. can also be started/ended
;                        with buttons on progressbar
;             NOPROGRESS = do not display a progress bar (ie, with no xwindows)
;             VERBOSE  = detailed output
;           VMIN/VMAX  = for adjusting LSR velocity axis. defaults -150 and +150 km/s
;             DV       = velocity resolution of the spectrum [default=0.25 km/s]
;
;  OUTPUTS:
;             SPECTS   = where the spectra go. form: data=[[lgals],[velocities]]
;             VEL      = where the velocities go
;             LGALS    = where the galactic longitudes go
;-
; MODIFICATION HISTORY:
;
; V1.0 TVW 18jan2013 to 24jan2013
;                    - modified to final version
;      tvw 26mar2013 - added pause features, added NOPROGRESS keyword
;      tvw 28mar2013 - added VERBOSE
;      tvw 11apr2013 - added EXPDISK
;      tmb 04may2013 - modified for TMBIDL. added keywords VMIN/VMAX
;                      and DV
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'synthlv' & return & endif
;
start_time=systime() & start_sec=systime(1)
print,"Start: ",start_time
;
common lvmap,spects_save,vel_save,lgals_save
;
if n_params() gt 0 then begin
   case ex of 
         0: begin
            curve=1
            model=[110.,0.4,5.0]
            noclouds=1
            end
         1: begin 
            curve=1
            smodel=[40.,1.0,5.0]
            noclouds=1
            end
         2: begin
            curve=1
            model=[110.,0.4,5.0]
            smodel=[40.,1.0,5.0]
            noclouds=1
            end
      else: begin
            print,'Model is undefined. Try again.'
            return
            end
   endcase
endif
;
; set up lvmap
; set defaults
if ~keyword_set(dl) then dl=10.
if ~keyword_set(dx) then dx=0.10
if ~Keyword_Set(vmax) then vmax=+150.d
if ~Keyword_Set(vmin) then vmin=-150.d
if ~Keyword_Set(dv)   then dv  =0.25d 
;
n_vel=(double(vmax)-double(vmin))/double(dv)
vel=dindgen(n_vel)*double(dv) + double(vmin) ; velocities to plot
spect=dblarr(n_vel)  ; intensity vs. velocity
nlgals=360./dl
;
; this is where the spectra and lgals will go
spects=fltarr(nlgals+1,n_vel)
lgals=findgen(nlgals+1)*dl-180.
;
;
; make a progres bar
if ~keyword_set(noprogress) then begin
   progressBar = Obj_New("CGPROGRESSBAR_TVW")
   progressBar -> Start
endif
;
if keyword_set(pause) then pauseon=1 else pauseon=0
;flag if we're pausing
;
dx0=dx                           ; refine dx step near galactic center 
for i=0,nlgals do begin
   if ~keyword_set(noprogress) then begin
      progressBar -> Update, float(i)/nlgals*100.
      if progressBar -> CheckCancel() then begin
         print,"Canceling!"
         progressBar -> Destroy
         return
      endif
      if progressBar -> CheckPause() and ~pauseon then begin
         print,"Pausing!"
         pauseon=1
      endif
   endif
   ;print,"lgal = ",lgals[i]
   ; skip lgal = 0.0
   if lgals[i] eq 0.0 then continue ; skip past the scary galactic center
;   
   if abs(lgals[i]) le 5.0 then dx=dx0/10. else dx=dx0 
   ;radtrans,lgal=lgals[i],curve=curve,rmax=rmax,dx=dx,ps=ps,homog=homog,isoth=isoth,$
   ;         disp=disp,gal=gal,spect=spect,vel=vel,/noplot,spiral=spiral,sparams=sparams
   ;
   err=0
   radtrans,lgal=lgals[i],dx=dx,ps=ps,noplot=noplot,$
            curve=curve,rmax=rmax,vmin=vmin,vmax=vmax,dv=dv,$
            gclouds=gclouds,noclouds=noclouds,/yscale,$
            model=model,expdisk=expdisk,dispgrad=dispgrad,smodel=smodel,$
            spect=spect,vel=vel,err=err,verbose=verbose
   ; error catch
   if err then begin
      print,"Found error, aborting synthlv"
      if ~keyword_set(noprogress) then progressBar -> Destroy
      return
   endif
   ;print,gclouds
   ;
   ; save the spectrum
   spects[i,*]=spect
   if pauseon then begin
      print,"Iteration ",i," of ",nlgals
      print,"Push any key to continue. q=unpause c=abort"
      pause,cans,ians
      if cans eq 'q' then pauseon=0
      if cans eq 'c' then begin
         print,"Canceling!"
         if ~keyword_set(noprogress) then progressBar -> Destroy
         return
      endif
   endif
endfor
if ~keyword_set(noprogress) then progressBar -> Destroy
;
if ~keyword_set(fname) then fname='lvap'
;
; make the l-v map 
;
if ~keyword_set(ps) then begin
   device,window_state=win_state
   if win_state[25] eq 1 then wset,25 else window,25,xsize=800,ysize=1000,title="L-V Map"
endif else printon,fname
;
erase  ; kill the previous plot
;
; position of tv image
imageposition=[0.15,0.1,0.75,0.9]
legendposition=[0.8,0.2,0.9,0.8]
legend=fltarr(1,101)
legend[0,*]=findgen(101)/100.*(max(spects)-min(spects))+min(spects)
if N_Elements(clip) eq 0 then clip = 99
;
; generate tv image of data
    if ~keyword_set(ct) then ct=13
    @CT_IN ; save color table information
    loadct,ct,/silent
    if N_Elements(minscale) eq 0 or N_Elements(maxscale) eq 0 then $
       histogram_clip, spects, clip, minscale, maxscale
    tvimage, bytscl(transpose(spects), minscale, maxscale), position=imageposition,/noint
    tvimage, bytscl(legend, minscale, maxscale), position=legendposition,/noint
    ;
    ; return to old color table
    @CT_OUT
    ;
    plot,fltarr(101),legend[0,*],/nodata,xstyle=4,ystyle=4,$
         yrange=[min(legend[0,*]),max(legend[0,*])],position=legendposition,$
         /noerase,charsize=1.5
    axis,yaxis=0,ytickformat='(A1)',ytitle=''
    axis,yaxis=1,ytitle="Brightness Temperature (K)",charsize=1.5
;

;
if ~keyword_set(noimage) then begin
; plot axes if nocontours
    if ~keyword_set(contours) then begin
        plot,lgals,vel,/nodata,xstyle=1,ystyle=1,$
        xrange=[min(vel),max(vel)],yrange=[min(lgals),max(lgals)],$
        position=imageposition,/noerase,xtitle="Velocity (km/s)",ytitle="l (degrees)",$
        charsize=1.5
    endif
;
;
endif
;
if keyword_set(contours) then begin
; normalize data for contours 
   Nspects=spects/max(spects)
; Contour code from lbmap.pro (T.Bania)
;  define look and feel of the contour plots
    levs =[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
    thick=[1.0,1.5,1.5,2.0,2.5,2.5,3.0,4.0,5.0]
    label=[  0,  1,  0,  0,  1,  1,  1,  1,  0]
    style=[  0,  2,  0,  2,  0,  2,  0,  2,  0]
    c_size=n_elements(levs)
    colors=fltarr(c_size)
    colors[0:c_size-1]=!orange
    colors[0]=!white & colors[1:2]=!red & colors[3:4]=!magenta & 
    colors[5]=!cyan  & colors[6]=!yellow &
    contour,transpose(Nspects),vel,lgals,xstyle=1,ystyle=1,/follow,levels=levs,c_thick=thick,$
            c_colors=colors,c_linestyle=style,c_labels=label,charsize=1.5,charthick=1.5,$
            xrange=[min(vel),max(vel)],yrange=[min(lgals),max(lgals)],$
            position=imageposition,/noerase,xtitle="Velocity (km/s)",ytitle="l (degrees)"
endif
;
if keyword_set(ps) then printoff
;
spects_save=spects
vel_save=vel
lgals_save=lgals
;
stop_time=systime() & stop_sec=systime(1)
print,"End: ",stop_time
print
time=stop_sec - start_sec
time=time/3600.d & dt=sixty(time)
label='Execution time = '
label=label+fstring(dt[0],'(i3)')+' hr '
label=label+fstring(dt[1],'(i2)')+' min '
label=label+fstring(dt[2],'(f6.3)')+' sec '
print,label
print
;

;
return
end
