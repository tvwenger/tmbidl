pro makegclouds,help=help,noclouds=noclouds,$
                lgal=lgal,curve=curve,rmax=rmax,$
                gclouds=gclouds,$
                model=model,smodel=smodel,$
                err=err,ps=ps,noplot=noplot
;+
; NAME:
;       makegclouds
;
;            ==============================================
;            Syntax: makegclouds,help=help,noclouds=noclouds,$
;                                lgal=lgal,curve=curve,rmax=rmax,$
;                                gclouds=gclouds,$
;                                model=model,smodel=smodel,$
;                                err=err
;            ==============================================
;
;   makegclouds  procedure to make clouds on a face-on galaxy
;   -----------  can make clouds either with mouse, with prompts for
;                different parameters, or by passing in GCLOUDS.
;
;                part of Synthetic HI Radiative Transfer Modelling Package:
;                    synthlv.pro, radtrans.pro, los.pro, vlos.pro, makegclouds.pro,
;                    pspiral.pro
;                 
;   KEYWORDS:
;             HELP     = display syntax and documentation
;             NOCLOUDS = do not make any clouds (when only want spiral)
;
;             LGAL     = galactic longitude (degrees) for line of sight
;             CURVE    = assign velocity based on rotation curve (ignores any passed velocity)
;                         value   curve
;                           1       Brandt/Burton - Default if just using /curve
;                           2       Clemens
;                           3       McClure-Griffiths - only valid for 3 < d < 8 kpc
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
;             SMODEL   = for overlay spiral galaxy model. Creates a
;                        spiral galaxy with parameters:
;                                  [spin_temp,density,dispersion,narms,r0,   theta0,pitch,nturns]
;                        defaults: [40,       1.0,    5.,        2.,   2.52, 0.,    12.,  1.35  ]
;
;             ERR      = for los.pro, radtrans.pro error handling
;             PS       = plot everything to ps
;             NOPLOT   = do not make plots (used with synthlv.pro)
;
;
; MODIFICATION HISTORY:
;
; V1.0 TVW 24apr2012 to 23jan2013
;                    - modified to final version
;      tvw 11apr2013 - added distance option for cloud placement
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin
   get_help,'makegclouds'
   err=1
   return
endif
;
ysun=8.5
;
; assign defaults
if ~keyword_set(rmax) then begin
   rmax = 12.d
endif
;
dmax=rmax+ysun
;
; define galaxy cloud structure template
; x    = x center location [pc from center]
; y    = y center location (0,0) is galactic center
; size = diameter or width [pc]
; den  = density [#/cm3]
; temp = temperature [K]
; sigma = dispersion [km/s]
;
dtor=!dpi/180.d
newgcloud={gcloud,x:0.d,y:0.d,size:0.d,den:0.d,temp:0.d,sigma:0.d}
kcld=0
if keyword_set(gclouds) then kcld=n_elements(gclouds)
;
;print,'no clouds is '
;if keyword_set(noclouds) then print,'true!'
;
if ~keyword_set(noclouds) and ~keyword_set(gclouds) then begin
   ;
   ; point and click clouds
   ; set up plot
   device,window_state=win_state
   if win_state[22] eq 1 then wset,22 else window,22,xsize=600,ysize=600,title="Face on Galaxy"
   erase
   ;
   xrange = [-rmax,rmax]
   yrange = [-rmax,rmax]
   xtitle = "(kpc)"
   ytitle = "(kpc)"
   xsun=0 & ysun=8.5
   plot,[0],[0],xrange=xrange,yrange=yrange,$
        xtitle=xtitle,ytitle=ytitle,charsize=1.5,/xstyle,$
        /ystyle,/iso,/nodata
   ; plot the Galactic longitude axes
   oplot,[xsun,xsun],[-rmax,rmax],linestyle=2,thick=2.0
   oplot,[-rmax,rmax],[ysun,ysun],linestyle=2,thick=2.0
   xyouts,0.05*rmax,-0.95*rmax,'0 deg',charsize=1.5,charthick=2.0
   xyouts,0.75*rmax,ysun+0.025*rmax,'90 deg',charsize=1.5,charthick=2.0
   xyouts,0.05*rmax,0.9*rmax,'180 deg',charsize=1.5,charthick=2.0
   xyouts,-0.95*rmax,ysun+0.025*rmax,'270 deg',charsize=1.5,charthick=2.0
   ;
   ; plot the sun
   syms,1,2,1
   oplot,[xsun],[ysun],psym=8
   xyouts,0.05*rmax,ysun+0.025*rmax,"Sun",charsize=2.0,charthick=2.0
   ;
   ; plot the Galactic Center
   oplot,[0],[0],psym=8
   xyouts,0.05*rmax,0,"GC",charsize=2.0,charthick=2.0
   ;
   ; plot line of lgal
   if keyword_set(lgal) then begin
      xf=xsun+dmax*sin(lgal*dtor)
      yf=ysun-dmax*cos(lgal*dtor)
      oplot,[xsun,xf],[ysun,yf],thick=2.0
      xyouts,0.3,0.82,'lgal = '+fstring(lgal,'(f6.1)')+' degrees',/norm,charsize=1.5,charthick=2.0
      longl=fltarr(2,2)
      longl[0,0]=xsun
      longl[0,1]=xf
      longl[1,0]=ysun
      longl[1,1]=yf
   endif
   ;
   cans='y'
   while (cans eq 'y') do begin
      ;
      print,"Assign gcloud position with mouse (m) or by distance (d)?"
      pause,cans2,ians2
      if cans2 eq 'd' then begin
         read,dist,prompt='distance [kpc]       = '
         mousex = dist*sin(lgal*dtor)
         mousey = ysun-dist*cos(lgal*dtor)
      endif else begin
         print,"Select cloud location with the mouse"
         cursor,mousex,mousey,/down,/data
      endelse
      print,"Cursor at x=",mousex," and y=",mousey
      if abs(mousex) gt rmax or abs(mousey) gt rmax then begin
         print,"That position is out of range!"
         print,"Try again..."
         continue
      endif
      syms,1,1,1
      oplot,[mousex],[mousey],psym=8
      read,size,  prompt='diameter [pc]        = '
      read,den,   prompt='density [#/cm^3]     = '
      read,temp,  prompt='spin temperature [K] = '
      read,sigma, prompt='dispersion [km/s]    = '
                                ;
      newgcloud={gcloud,mousex,mousey,size,den,temp,sigma}
      ;
      if kcld eq 0 then gclouds=[newgcloud] $
      else gclouds=[gclouds,newgcloud]
      ;
      plots,circle_tvw(mousex,mousey,size/2.d3)
      ;
      kcld = kcld+1
      print,"Make another cloud? (y/n)"
      pause,cans,ians
   endwhile
endif
;
if keyword_set(model) then begin
   ; single galaxy model
   ; check that model has either 1 (ie. /model) or all elements
   if n_elements(model) eq 1 then begin
      ; assign defaults
      temp  =110.
      den =0.4
      sigma=5.
   endif else if n_elements(model) eq 3 then begin
      temp  =model[0]
      den   =model[1]
      sigma=model[2]
   endif else begin
      print,'use /MODEL or supply all three MODEL parameters'
      err=1
      return
   endelse
   if kcld eq 0 then begin
      gclouds=[{gcloud,0,0,2.d3*rmax,den,temp,sigma}]
   endif else begin
      gclouds=[gclouds,{gcloud,0,0,2.d3*rmax,den,temp,sigma}]
   endelse
   ;print,"after model ",gclouds
   ++kcld
endif 
;
; set up final plot, get ready for pspiral
;
if ~keyword_set(noplot) then begin
   if ~keyword_set(ps) then begin
      device,window_state=win_state
      if win_state[22] eq 1 then wset,22 else window,22,xsize=600,ysize=600,title="Face on Galaxy"
      erase
   endif else printon,"galacticmap"
   xrange = [-rmax,rmax]
   yrange = [-rmax,rmax]
   xtitle = "(kpc)"
   ytitle = "(kpc)"
   xsun=0 & ysun=8.5
   plot,[0],[0],xrange=xrange,yrange=yrange,$
        xtitle=xtitle,ytitle=ytitle,charsize=1.5,/xstyle,$
        /ystyle,/iso,/nodata
endif
;
; Apply spiral, only interested if lgal is supplied also
if keyword_set(smodel) then begin
   if ~keyword_set(lgal) then begin 
      print,'Spiral useless without lgal...'
      err=1
      return
   endif
   ;
   ; check that smodel has either 1 (ie., /smodel), 3, or all elements
   ;
   if n_elements(smodel) eq 1 then begin
      ; assign defaults
      temp  =40.
      den   =1.0
      sigma =5.0
      narms =2.
      r0    =2.52
      theta0=0.
      pitch =12.
      nturns=1.35
   endif else if n_elements(smodel) eq 3 then begin
      temp  =smodel[0]
      den   =smodel[1]
      sigma =smodel[2]
      narms =2.
      r0    =2.52
      theta0=0.
      pitch =12.
      nturns=1.35
   endif else if n_elements(smodel) eq 8 then begin
      temp  =smodel[0]
      den   =smodel[1]
      sigma =smodel[2]
      narms =smodel[3]
      r0    =smodel[4]
      theta0=smodel[5]
      pitch =smodel[6]
      nturns=smodel[7]
   endif else begin
      print,'use /SMODEL, supply first 3, or supply all SMODEL parameters'
      err=1
      return
   endelse
   ;
   err=0
   ; generate spiral, make it print on this plot
   pspiral,r0,theta0,pitch,nturns=nturns,narms=narms,$
           lgal=lgal,arms=arms,bulge=bulge,longl=longl,$
           noplot=noplot,galplot=1,ps=ps,err=err,rmax=rmax
   ;
   ; catch any pspiral errors
   if err then return
   ;
   ; find intersection between l.o.s. and arms/bulge
   xl=findgen(1001)/1000.*(longl[0,1]-longl[0,0])+longl[0,0]
   yl=findgen(1001)/1000.*(longl[1,1]-longl[1,0])+longl[1,0]
   ;
   intersect2d,transpose(bulge),[[xl],[yl]],inter=inter,thresh=0.005*rmax
   ;print,'Bulge'
   ;print,inter
   ;print,inter[0,0]
   ;print,inter[0,1]
   if n_elements(inter[0,*]) gt 2 then begin
      print,'More than 2 intersection points in bulge...'
   endif else if n_elements(inter[0,*]) eq 2 then begin
      xc=(inter[0,1]+inter[0,0])/2.
      yc=(inter[1,1]+inter[1,0])/2.
      size=sqrt( (inter[0,1]-inter[0,0])^2. + (inter[1,1]-inter[1,0])^2. )*1000.
      newgcloud={gcloud,xc,yc,size,den,temp,sigma}
      ;print,'made cloud'
      ;print,'xc: ',xc
      ;print,'yc: ',yc
      ;print,'size: ',size
      if kcld eq 0 then gclouds=newgcloud else $
      gclouds=[gclouds,newgcloud]
      ++kcld
   endif
   ;
   ; now arms
   narms = n_elements(arms[*,0])/2
   for thisarm=0,narms-1 do begin
      ;print,'Arm',thisarm
      armdata=arms[2*thisarm:2*thisarm+1,*]
      intersect2d,transpose(armdata),[[xl],[yl]],inter=inter,thresh=0.005*rmax
      ;print,inter
      if n_elements(inter) lt 2 then continue
      for thisinter=0,n_elements(inter[0,*])-1 do begin
         xc=inter[0,thisinter]
         yc=inter[1,thisinter]
         size=500.
         newgcloud={gcloud,xc,yc,size,den,temp,sigma}
         ;print,'made cloud'
         ;print,'xc: ',xc
         ;print,'yc: ',yc
         ;print,'size: ',size
         if kcld eq 0 then gclouds=newgcloud else $
            gclouds=[gclouds,newgcloud]
         ++kcld
      endfor
   endfor
endif
;
;print,"after spiral ",gclouds
;
; -- make galactic plot --
if ~keyword_set(noplot) then begin
   xrange = [-rmax,rmax]
   yrange = [-rmax,rmax]
   xtitle = "(kpc)"
   ytitle = "(kpc)"
   xsun=0 & ysun=8.5
   if ~keyword_set(smodel) then begin
      plot,[0],[0],xrange=xrange,yrange=yrange,$
           xtitle=xtitle,ytitle=ytitle,charsize=1.5,/xstyle,$
           /ystyle,/iso,/nodata
   endif
   ; plot the Galactic longitude axes
   oplot,[xsun,xsun],[-rmax,rmax],linestyle=2,thick=2.0
   oplot,[-rmax,rmax],[ysun,ysun],linestyle=2,thick=2.0
   xyouts,0.05*rmax,-0.95*rmax,'0 deg',charsize=1.5,charthick=2.0
   xyouts,0.75*rmax,ysun+0.025*rmax,'90 deg',charsize=1.5,charthick=2.0
   xyouts,0.05*rmax,0.9*rmax,'180 deg',charsize=1.5,charthick=2.0
   xyouts,-0.95*rmax,ysun+0.025*rmax,'270 deg',charsize=1.5,charthick=2.0
   ;
   ; plot the sun
   syms,1,2,1
   oplot,[xsun],[ysun],psym=8
   xyouts,0.05*rmax,ysun+0.025*rmax,"Sun",charsize=2.0,charthick=2.0
   ;
   ; plot the Galactic Center
   oplot,[0],[0],psym=8
   xyouts,0.05*rmax,0,"GC",charsize=2.0,charthick=2.0
      
;
; plot line of lgal
   if keyword_set(lgal) then begin
      xf=xsun+dmax*sin(lgal*dtor)
      yf=ysun-dmax*cos(lgal*dtor)
      oplot,[xsun,xf],[ysun,yf],thick=2.0
      xyouts,0.3,0.82,'lgal = '+fstring(lgal,'(f6.1)')+' degrees',/norm,charsize=1.5,charthick=2.0
      longl=fltarr(2,2)
      longl[0,0]=xsun
      longl[0,1]=xf
      longl[1,0]=ysun
      longl[1,1]=yf
   endif
;
   for i=0,n_elements(gclouds)-1 do begin
      plots,circle_tvw(gclouds[i].x,gclouds[i].y,gclouds[i].size/2.d3)
   endfor
   if keyword_set(ps) then printoff
endif
;
return
end
