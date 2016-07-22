pro los,d,vel,size,den,temp,sigma,$
        help=help,dx=dx,ps=ps,noplot=noplot,$
        clouds=clouds,noclouds=noclouds,$
        lgal=lgal,curve=curve,rmax=rmax,$
        gclouds=gclouds,$
        model=model,expdisk=expdisk,dispgrad=dispgrad,smodel=smodel,$
        err=err,ymin=ymin,ymax=ymax,yscale=yscale
;+
; NAME:
;       LOS
;
;    ===================================================================
;    Syntax: los,d,vel,size,den,temp,sigma,$
;                help=help,dx=dx,ps=ps,noplot=noplot,$
;                clouds=clouds,noclouds=noclouds,$
;                lgal=lgal,curve=curve,rmax=rmax,$
;                gclouds=gclouds,$
;                model=model,expdisk=expdisk,dispgrad=dispgrad,smodel=smodel,$
;                err=err,ymin=ymin,ymax=ymax,yscale=yscale
;    ===================================================================
;
;   los  procedure to establish line of sight cloud distribution for HI 
;   ---  spectral models with radtrans.pro
;
;        part of Synthetic HI Radiative Transfer Modelling Package:
;            synthlv.pro, radtrans.pro, los.pro, vlos.pro, makegclouds.pro,
;            pspiral.pro
;
;   INPUTS: all are optional, otherwise prompted for each
;             d     = los distance (kpc)
;             vel   = los LSR velocity (km/s) 
;             size  = size (pc) 
;             den   = density (# cm-3) 
;             temp  = spin temperature (K) 
;             sigma = velocity dispersion (km/s)
;
;   KEYWORDS:
;             HELP     = display syntax and documentation
;             DX       = line-of-sight step size [kpc] (smaller = better but longer run-time)
;                        - Default is 0.1 kpc
;             PS       = plot everything to ps
;             NOPLOT   = do not make plots (used with synthlv.pro)
;
;             CLOUDS   = can be used to pass in line-of-sight cloud info
;                        *IF EMPTY* it is filled with array of cloud structures 
;                        {cloud,d:0.d,vel:0.d,size:0.d,den:0.d,temp:0.d,sigma:0.d}
;             NOCLOUDS = do not make any clouds (when only want spiral)
;
;             LGAL     = make galactic clouds via makegclouds.pro. 
;                        use this galactic longitude (degrees) for line of sight
;             CURVE    = assign velocity based on rotation curve (ignores any passed velocity)
;                         value   curve
;                           0       Brandt/Burton - Default
;                           1       Clemens
;                           2       McClure-Griffiths - only valid for 3 < d < 8 kpc
;             RMAX     = maximum galactocentric distance to be used in plot [kpc]
;                        default is 12 kpc
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
;             ERR      = for radtrans.pro error handling 
;
;           YMIN/YMAX  = for scaling y-axis in V_lsr vs D_sun plot
;           YSCALE     = for scaling this plot using the data themselves 
;
;-
; MODIFICATION HISTORY:
; 9apr2012 tmb
; 9apr2012 to 23jan2013 tvw 
;          - modified in to final version. 
; 11apr2013 tvw - added EXPDISK, DISPGRAD
;  6may2013 tmb - added YMIN, YMAX, and YSCALE
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
; common block for wrapping
;
common lineofsight,dlos,vlos,denlos,tlos,siglos,intensity
;
; Check for help
;
if Keyword_Set(help) then begin
   get_help,'los'
   err=1
   return
endif
;
if keyword_set(model) and ~keyword_set(lgal) then begin
   print,"Need to supply LGAL when using MODEL!"
   err=1
   return
endif else if keyword_set(smodel) and ~keyword_set(lgal) then begin
   print,"Need to supply LGAL when using SMODEL!"
   err=1
   return
endif
;
err=0
dtor=!dpi/180.d
xsun=0.d
ysun=8.5d
;
; set defaults
;
if ~keyword_set(rmax) then rmax=18.d
if ~keyword_set(dx) then dx=0.1d
;
dmax=rmax+ysun
;
; define cloud and gcloud structure template
;
newcloud={cloud,d:0.d,vel:0.d,size:0.d,den:0.d,temp:0.d,sigma:0.d}
newgcloud={gcloud,x:0.d,y:0.d,size:0.d,den:0.d,temp:0.d,sigma:0.d}
;
;
; keep track of /model cloud number
modelcloud = -1
modelgcloud= -1
;
; if we're using lgal, time to makegclouds
if keyword_set(lgal) then begin
   ; number of clouds
   kcld=0
   ; keep track of supplied gclouds
   ; more will be added by makegclouds if using smodel
   if keyword_set(gclouds) then begin
      orgclouds=gclouds 
      ;print,'restoring saved gclouds'
   endif else orgclouds=0
   ;
   ; find out if we're going to make some gclouds, if so we want to keep using those
   if ~keyword_set(gclouds) and ~keyword_set(noclouds) then begin
      saveclouds=1
   endif else saveclouds=0
   ;
   makegclouds,noclouds=noclouds,$
               lgal=lgal,curve=curve,rmax=rmax,$
               gclouds=gclouds,$
               model=model,smodel=smodel,$
               err=err,ps=ps,noplot=noplot
   ;
   ; catch any errors from makegclouds
   if err then return
   ;
   ; convert glcouds to clouds
   ; 
   kgcld=n_elements(gclouds)
   ;print,"in los ",gclouds
   ;help,gclouds
   sizemax=0.d
   for nc=0,kgcld-1 do begin
      ; los distance
      ;d = sqrt(gclouds[nc].x^2. + (8.5-gclouds[nc].y)^2.)
      ; vel is defined later
      vel = 0.0
      ; need to see if our line of sight intersects this cloud
      cloudcircle=circle_tvw(gclouds[nc].x,gclouds[nc].y,gclouds[nc].size/2.d3)
      ;
      ; keep track of which cloud is /model cloud
      if (gclouds[nc].size eq 2.d3*rmax) then begin
         modelcloud=kcld 
         modelgcloud=nc
      endif
      ;
      ;print,cloudcircle
      ; find intersection between l.o.s. and arms/bulge
      xf=xsun+dmax*sin(lgal*dtor)
      yf=ysun-dmax*cos(lgal*dtor)
      ;
      longl=fltarr(2,2)
      longl[0,0]=xsun
      longl[0,1]=xf
      longl[1,0]=ysun
      longl[1,1]=yf
      ;
      xl=findgen(1001)/1000.*(longl[0,1]-longl[0,0])+longl[0,0]
      yl=findgen(1001)/1000.*(longl[1,1]-longl[1,0])+longl[1,0]
      ;
      ;print,xl,yl
      ;
      intersect2d,transpose(cloudcircle),[[xl],[yl]],inter=inter,thresh=0.005*rmax
      ;help,inter
      ;print,inter
      ;
      if n_elements(inter[0,*]) gt 2 then begin
         ;print,'More than 2 intersection points in with cloud. Only using first two...'
      endif   
      if n_elements(inter[0,*]) ge 2 then begin
         xc=(inter[0,1]+inter[0,0])/2.
         yc=(inter[1,1]+inter[1,0])/2.
         d = sqrt((xc-xsun)^2. + (yc-ysun)^2.)
         size=sqrt( (inter[0,1]-inter[0,0])^2. + (inter[1,1]-inter[1,0])^2. )*1000.
         ;print,'center of intersection: ',xc,yc
         ;print,'distance to intersection: ',d
         ;print,'size of intersection',size
      endif else if n_elements(inter) eq 2 then begin
         xc=(xsun+inter[0])/2.
         yc=(ysun+inter[1])/2.
         d = sqrt((xc-xsun)^2. + (yc-ysun)^2.)
         size=sqrt( (xsun-inter[0])^2. + (ysun-inter[1])^2. )*1000.
         ;print,'center of intersection: ',xc,yc
         ;print,'distance to intersection: ',d
         ;print,'size of intersection',size
      endif else begin
         print,"no intersection found!"
         continue
      endelse
      ;
      den  = gclouds[nc].den
      temp = gclouds[nc].temp
      sigma= gclouds[nc].sigma
      newcloud={cloud,d,vel,size,den,temp,sigma}
      if kcld eq 0 then clouds=[newcloud] else clouds=[clouds,newcloud]
      kcld+=1
      if size gt sizemax then sizemax = size
      ;
   endfor
   ; check to see if we're only using created gclouds. ie, no noclouds.
   ; cut back gclouds to originial
   if saveclouds then begin
      orgclouds=gclouds
      ;print,'saving gclouds for later'
      ;print,'modelgcloud is ',modelgcloud
      ; get rid of /model cloud if we're using it
      if (modelgcloud ne -1) then begin
         if (modelgcloud+1 gt n_elements(orgclouds)-1) then begin
            orgclouds=orgclouds[0:modelgcloud-1]
         endif else begin
            orgclouds=[orgclouds[0:modelgcloud-1],orgclouds[modelgcloud+1:n_elements(orgclouds)-1]]
         endelse
      endif
   endif
   gclouds=orgclouds
   
endif else begin
   ;
   ;  if no cloud parameters input then query for them
   sizemax = 0.d                ; finding the max size
   ;
   if n_params() eq 6 then begin
      newcloud={cloud,d,vel,size,den,temp,sigma}
      clouds=[newcloud]
      kcld=1
      sizemax = size
   endif else if keyword_set(clouds) && ~(n_elements(clouds) eq 0) then begin
      kcld=n_elements(clouds)
      ;print,'Found '+fstring(kcld,'(I0)')+' clouds.'
      for k=0,kcld-1 do if clouds[k].size gt sizemax then $
         sizemax=clouds[k].size
   endif else begin
      kcld=0
      cans='y'
      while cans eq 'y' do begin
         kcld=kcld+1
         print,'Enter cloud parameters: '
         read,d,     prompt='los distance [kpc]   = '
         read,vel,   prompt='los velocity [km/s]  = '
         read,size,  prompt='diameter [pc]        = '
         read,den,   prompt='density [#/cm^3]     = '
         read,temp,  prompt='spin temperature [K] = '
         read,sigma, prompt='dispersion [km/s]    = '
         ;
         newcloud={cloud,d,vel,size,den,temp,sigma}
         ;
         if kcld eq 1 then clouds=[newcloud] $
         else clouds=[clouds,newcloud]
         ;
         if size gt sizemax then sizemax = size
         ;
         print
         print,'Define another cloud? (y/n)'
         pause,cans,ians
         print
      endwhile
   endelse
endelse
;
dnpts=dmax/dx + 1 ; number of los points
;print,dnpts
;
dlos   = dindgen(dnpts)*dx  ; los distance [kps]
vlos   = dblarr(dnpts)   ; los velocity [km/s]
denlos = dblarr(dnpts)   ; los density [#/cm3]
tlos   = dblarr(dnpts)   ; los temperature [K]
siglos = dblarr(dnpts)   ; los dispersion [km/s]
;
; fill up arrays with cloud values
;
kcld=n_elements(clouds)
;print,kcld
;print,clouds
;
; in case we are doing expdisk, need to get rlos from dlos by law of cosines
if keyword_set(expdisk) then begin
   ;print,dlos
   rlos = ysun^2.d + dlos^2.d - 2.d*ysun*dlos*cos(lgal*dtor)
   rlos = sqrt(rlos)
   ;help,rlos
   ;print,rlos
endif
;
for i=0,dnpts-1 do begin
   ;print,i
   ;print,modelcloud
   ;
   ; do model cloud first, then do other clouds in order
   if (modelcloud ne -1) then begin
      cstart = clouds[modelcloud].d - clouds[modelcloud].size/2.d3
      cend = clouds[modelcloud].d + clouds[modelcloud].size/2.d3
      ;
      ;print,cstart,cend
      ;
      if dlos[i] ge cstart && dlos[i] le cend then begin
         ;
         ;print,'MODEL!'
         ; if we're using an exponential disk and this cloud
         if (keyword_set(expdisk)) then begin
            modelden = clouds[modelcloud].den
            ; from Knapp, Tremaine, Gunn 1978
            denlos[i] = modelden * exp( (1.d - rlos[i]/ysun)/ 0.43d )
         endif else denlos[i] = clouds[modelcloud].den
         tlos[i]   = clouds[modelcloud].temp
         ;
         ; if we're using DISPGRAD...
         if keyword_set(dispgrad) then begin
            ; from Burton's thesis
            modelsigma = clouds[modelcloud].sigma
            if rlos[i] lt ysun then begin
               fact = 10.10d - modelsigma
               fact = fact / ysun
               siglos[i] = 10.10d - fact * rlos[i]
            endif else begin
               siglos[i] = modelsigma
            endelse
         endif else siglos[i] = clouds[modelcloud].sigma
      endif
   endif
   ;
   ; now do other clouds, we may overwrite the /model cloud
   for k=0,kcld-1 do begin
      ; skip the /model cloud
      if (modelcloud eq k) then continue
      ;
      cstart = clouds[k].d - clouds[k].size/2.d3
      cend   = clouds[k].d + clouds[k].size/2.d3
      ;print,dlos[i],cstart,cend
      ;
      if dlos[i] ge cstart && dlos[i] le cend then begin
         vlos[i]   = clouds[k].vel
         denlos[i] = clouds[k].den
         tlos[i]   = clouds[k].temp
         siglos[i] = clouds[k].sigma
      endif
   endfor
endfor
;
;print,denlos
;
; if using a rotation curve, then apply that now
;
if keyword_set(lgal) then begin
   vlos,lgal,curve=curve,dlos=dlos,vlsr=vlos,rmax=rmax,dx=dx,ps=ps,noplot=noplot,$
        ymin=ymin,ymax=ymax,yscale=yscale
endif
;
; make the plot
;
if ~keyword_set(noplot) then begin
   if ~keyword_set(ps) then begin
      device,window_state=win_state
      if win_state[20] eq 1 then wset,20 else window,20,xsize=600,ysize=400,title="Line of Sight Clouds"
   endif else printon,'lineofsight'
   ; 
   xtitle="Distance from Sun [kpc]"
   ytitle="Size [kpc]"
   ;
   plot,dlos,vlos,/nodata,xrange=[0.,dmax],yrange=[-1.d-3*sizemax,1.d-3*sizemax],$
        xtitle=xtitle,ytitle=ytitle,/xstyle,/ystyle,charsize=1.5
   oplot,[0.,dmax],[0.,0.]
   for k=0,kcld-1 do begin
      plots,circle_tvw(clouds[k].d,0.,clouds[k].size/2.d3)
                                ;
      if keyword_set(lgal) then begin
        for findvel=0,dnpts-1 do begin
           if abs(dlos[findvel]-clouds[k].d) lt 0.1 then begin
              clouds[k].vel = vlos[findvel]
                                ;print,'Found middle velocity: ',clouds[k].vel
           endif
        endfor
     endif
                                ;
      ann_x = clouds[k].d - 0.04*dmax
      tempstr = 'T = '+fstring(clouds[k].temp,'(D0.1)')
      velstr  = textoidl("v_{center} = ")+fstring(clouds[k].vel,'(D0.1)')
      denstr  = textoidl("\rho = ")+fstring(clouds[k].den,'(D0.1)')
      sigmastr= textoidl("\sigma = ")+fstring(clouds[k].sigma,'(D0.1)')
                                ;
      xyouts,ann_x,clouds[k].size/2.d3+sizemax*0.16d-3,tempstr,charsize=1.75,/data
      xyouts,ann_x,clouds[k].size/2.d3+sizemax*0.06d-3,velstr,charsize=1.75,/data
      xyouts,ann_x,-1*clouds[k].size/2.d3-sizemax*0.08d-3,denstr,charsize=1.75,/data
      xyouts,ann_x,-1*clouds[k].size/2.d3-sizemax*0.18d-3,sigmastr,charsize=1.75,/data
   endfor
   ;
   ;  annotate
   title='Line-of-sight clouds'
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
   if Keyword_Set(ps) then begin & clr & printoff & endif
endif
;
return
end
