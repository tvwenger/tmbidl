pro pspiral,r0,theta0,pitch,help=help,$
            noplot=noplot,galplot=galplot,ps=ps,$
            narms=narms,nturns=nturns,color=color,$
            lgal=lgal,arms=arms,bulge=bulge,longl=longl,$
            err=err,rmax=rmax
;+
; NAME:
;       PSPIRAL
;
;       =========================================================
;       Syntax: pspiral,r0,theta0,pitch,help=help,$
;                       noplot=noplot,galplot=galplot,ps=ps,$
;                       narms=narms,nturns=nturns,color=color,$
;                       lgal=lgal,arms=arms,bulge=bulge,longl=longl,$
;                       err=err,rmax=rmax
;       =========================================================
;
;  pspiral  Plot a logarithmic spiral Milky Way galaxy
;           Default parameters are from Vallee (ApJ 2005)
;
;  INPUT
;           r0     - logarithmic spiral parameter, default = 2.52 kpc
;           theta0 - logarithmic spiral parameter, default = 0 degrees
;           pitch  - logarithmic spiral parameter, default = 12 degrees
;
;  KEYWORDS
;           narms   - number of arms in galaxy. (Use 1,2, or 4)
;                    default = 2
;           nturns  - how many turns of the spiral arms
;                     default = 1.35
;           color   - color of plot. default = white
;           lgal    - plot a line of lgal on the spiral
;           arms    - returns a multidimensional array of the spiral
;                     arm locations.
;                     [[0, 0, 0, 0,...], [0, 0, 0, 0,...], [0, 0, ...
;                      arm1 x positions arm1 y posiitons  arm2 x ...
;           bulge   - returns location of outer radius of bulge
;           longl   - return line of longitude
;           help    - get syntax help
;           noplot  - do not make plot
;           galplot - make plot on makegclouds plot
;           ps      - plot to ps
;           err     - error handling 
;           rmax    - maximum galactocentric radius
;               
; V6.1 04may2011 tmb 
;      19apr2012 tvw - added help, plot to different window
;      16jan2013 tvw - make astrophysically relavent plot
;                      update comments
;      20jan2013 tvw - added noplot, galplot
;      26mar2013 tvw - added rmax
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be []
;
if keyword_set(help) then begin
    get_help,'pspiral'
    err=1
    return
 endif
;
if ~keyword_set(rmax) then rmax=12.d
;
if ~keyword_set(noplot) then begin
; create a window for display
   if keyword_set(galplot) then begin
      if ~keyword_set(ps) then wset,22 
   endif else begin
      if keyword_set(ps) then printon,'pspiral.ps' else begin
         device,window_state=win_state
         if win_state[23] eq 1 then wset,23 else window,23,xsize=600,ysize=600,title="Face on Galaxy"
      endelse
   endelse
endif
;
xsun=0 & ysun=8.5
dtor=!dpi/180.d
;
if ~keyword_set(noplot) then begin
; set plot info
   xrange=[-rmax,rmax] & yrange=[-rmax,rmax]
   xtitle="(kpc)" & ytitle="(kpc)"
;
; create plot
   if ~keyword_set(galplot) then $
   plot,[0],[0],xrange=xrange,yrange=yrange,$
        xtitle=xtitle,ytitle=ytitle,charsize=1.5,/xstyle,$
        /ystyle,/iso,/nodata
endif
;
; set defaults
if ~Keyword_Set(color) then color=!white
if ~keyword_set(narms) then narms=2
if ~Keyword_Set(nturns) then nturns=1.35
if n_params() eq 0 then begin
   r0=2.54
   pitch=12.0d
   theta0=0.0d
endif
;
; convert to radians
pitch=pitch*dtor
theta0=theta0*dtor
;
; plot each arm
if narms eq 3 then begin
   print,"narms=3 does not work... use narms 1,2 or 4."
   err=1
   return
endif
;
narmpoints=2.*!dpi*nturns/0.01 + 1
arms=fltarr(2*narms,narmpoints)
for arm=1,narms do begin
   ;set arm offset
   case arm of
      1: armth=0
      2: armth=!dpi
      3: armth=-1.*!dpi/2.
      4: armth=!dpi/2.
      else: 
   endcase
   ;
   ; plot the arm
   theta=findgen(narmpoints)*0.01+theta0
   r=r0*exp(pitch*theta)
   if ~keyword_set(noplot) then begin
      for dw=-0.3,0.3,0.1 do begin
         thisr=r+dw
         x= thisr*sin(theta+armth)
         y=-thisr*cos(theta+armth)
         oplot,x,y,color=!red,thick=5.
                                ;print,r[0]
      endfor
   endif
   ;
   ; put arm center in array
   arms[2*(arm-1)  ,*]= r*sin(theta+armth); x
   arms[2*(arm-1)+1,*]=-r*cos(theta+armth); y
endfor
;
; plot the Galactic Bulge
nbulgepoints=2.*!dpi/0.01+1
bulge=fltarr(2,nbulgepoints)
theta=findgen(nbulgepoints)*0.01
if ~keyword_set(noplot) then begin
   for dr=0.,3.0,0.1 do begin
      x=dr*sin(theta)
      y=-dr*cos(theta)
      oplot,x,y,color=!red,thick=5.
   endfor
endif
bulge[0,*]= 3.0*sin(theta)
bulge[1,*]=-3.0*cos(theta)
;
if ~keyword_set(noplot) then begin
; plot the Galactic longitude axes
   oplot,[xsun,xsun],[-rmax,rmax],linestyle=2,thick=2.0
   oplot,[-rmax,rmax],[ysun,ysun],linestyle=2,thick=2.0
   xyouts,0.05*rmax,-0.95*rmax,'0 deg',charsize=1.5,charthick=2.0
   xyouts,0.75*rmax,ysun+0.025*rmax,'90 deg',charsize=1.5,charthick=2.0
   xyouts,0.05*rmax,0.9*rmax,'180 deg',charsize=1.5,charthick=2.0
   xyouts,-0.95*rmax,ysun+0.025*rmax,'270 deg',charsize=1.5,charthick=2.0
   ; plot the sun
   syms,1,2,1
   oplot,[xsun],[ysun],psym=8
   xyouts,0.05*rmax,ysun+0.025*rmax,"Sun",charsize=2.0,charthick=2.0
   ;
   ; plot the Galactic Center
   oplot,[0],[0],psym=8
   xyouts,0.05*rmax,0,"GC",charsize=2.0,charthick=2.0
   ;
endif
;
; plot line of lgal
if keyword_set(lgal) then begin
   xf=xsun+30*sin(lgal*dtor)
   yf=ysun-30*cos(lgal*dtor)
   
   if ~keyword_set(noplot) then begin
      oplot,[xsun,xf],[ysun,yf],thick=2.0
      xyouts,0.3,0.82,'lgal = '+fstring(lgal,'(f6.1)')+' degrees',/norm,charsize=1.5,charthick=2.0
   endif
   longl=fltarr(2,2)
   longl[0,0]=xsun
   longl[0,1]=xf
   longl[1,0]=ysun
   longl[1,1]=yf
endif
;
return
end
