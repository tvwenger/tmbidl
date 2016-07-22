pro examine,cube,header,image,XRANGE=xrange,YRANGE=yrange,$
            RANGE=range,WIND=imwind
;+
; NAME:
;       EXAMINE
; PURPOSE:
;       Plots spectrum within a data cube at the x,y index determined by 
;       the cursor position at the left mouse click 
; EXPLANATION:
;       Examine allows one to interactively look at spectra based on 
;       the cursor position within a displayed image.  To plot a 
;       spectrum, move the cursor to a position within the image and 
;       left click the mouse.  The spectrum appears in window 20.
;       To exit the examine procedure, right click the mouse
;   
;
; CALLING SEQUENCE:
;       EXAMINE,cube,header,image, [xrange,yrange,range,imwind] 
;
; INPUT:
;       CUBE: Data cube with spectral axis on the inner most index 
;       HEADER:  FITS header array for CUBE, containing astrometry parameters
;       IMAGE: 2D template image of CUBE 
;
; OUTPUT:
;       No output arrays or values 
;      
; OPTIONAL INPUT KEYWORDS:
;       RANGE: 2 element vector whose values are the min/max to scale IMAGE
;             
;           
;       IMWIND: graphics window to display imwind (default: window 0) 
; EXAMPLE:
;       To initiate the examine procedure displaying the 2D image in window 2
;       with a lookup table scaled to -2 and 10
;
;           IDL>examine, CUBE,H,IM,RANGE=[-2,10],2

; PROCEDURES USED:
;       sxpar,imdisp
;
; REVISION HISTORY:
;       Written  M. Heyer, UMass                   September, 2002
;       Modified G. Narayanan, UMass. 28, Jan 2003
;       Added title and set histogram plot for avg plot

on_error,!debug ? 0 : 2
;error output
if N_params() LT 3 THEN BEGIN
    print,'Syntax - EXAMINE, cube, h,image, [xrange=[xmin,xmax],yrange=[ymin,ymax],range=[min,max],window=imwind]'
    return
endif


; read headers
sz=size(cube)
nv=sz[1]

cdelt1=sxpar(header,"CDELT1")
crpix1=sxpar(header,"CRPIX1")
crval1=sxpar(header,"CRVAL1")
ctype1=sxpar(header,"CTYPE1")
ctype2=sxpar(header,"CTYPE2")
cdelt2=sxpar(header,"CDELT2")
crpix2=sxpar(header,"CRPIX2")
crval2=sxpar(header,"CRVAL2")
cdelt3=sxpar(header,"CDELT3")
crpix3=sxpar(header,"CRPIX3")
crval3=sxpar(header,"CRVAL3")
bunit=sxpar(header,"BUNIT")
cdelt1=cdelt1/1000.
crval1=crval1/1000.
vlsr=crval1+(findgen(nv)-(crpix1-1.))*cdelt1
v1def=vlsr[0]
v2def=vlsr[nv-1]
if vlsr[0] gt vlsr[nv-1] then begin
  v1def=vlsr[nv-1]
  v2def=vlsr[0]
endif

; step thru optional parameters, if missing - fill in defaults
v1=v1def
v2=v2def
if keyword_set(xrange) then begin 
  v1=xrange[0]
  v2=xrange[1]
  if (v1 gt v2) then begin
    v2=tmp
    v2=v1
    v1=tmp
  endif
endif

if keyword_set(yrange) then begin
  ymin=yrange(0)
  ymax=yrange(1)
endif

rg=fltarr(2)
rg=[min(image),max(image)]
if keyword_set(range) then begin
 szr=size(range)
 if (szr(0) ne 1 and szr(1) ne 2) then begin
  print,"Input Intensity Range not a vector with size 2"
  return
 endif
 rg=range
endif 
 
 
image_window=0
if keyword_set(wind) then image_window=imwind

; open window for plotting spectra 
window, 20, xsize=384,ysize=307

while 1 do begin     ; start infinite loop -- exit with right button click
  wset,image_window
  imdisp,image,range=rg,/axis
  cursor,xcurs,ycurs
  ix=fix(xcurs)
  iy=fix(ycurs)
  xpos=string(ix,format='(F5.0)')
  ypos=string(iy,format='(F5.0)')
  tit='Offset ('+xpos+','+ypos+') '
  if (strpos(ctype2,"RA") ne -1) then begin 
    xpos=string(cdelt2*(ix-(crpix2-1))*60.0,format='(F7.2)')
    ypos=string(cdelt3*(iy-(crpix3-1))*60.0,format='(F7.2)')
    tit='Offset ('+xpos+','+ypos+') eq '
  endif 
  if (strpos(ctype2,"LON") ne -1) then begin 
    xpos=string(crval2+cdelt2*(ix-(crpix2-1)),format='(F8.3)')
    ypos=string(crval3+cdelt3*(iy-(crpix3-1)),format='(F8.3)')
    tit='Offset ('+xpos+','+ypos+') ga '
  endif
 
  if (!mouse.button eq 1) then begin
    wset, 20
    if not keyword_set(yrange) then begin
      ymin=min(cube[*,ix,iy])
      ymax=max(cube[*,ix,iy])
    endif
     
    plot,vlsr,cube[*,ix,iy],xtitle=ctype1, ytitle=bunit,xrange=[v1,v2],yrange=[ymin,ymax],title=tit,psym=10
       
  endif
  if (!mouse.button eq 2) then begin
     x1=fix(xcurs)
     y1=fix(ycurs)
     print," Click middle button to define other box corner"
     wait,1
     cursor,xcurs,ycurs
     if (!mouse.button eq 2) then begin
       x2=fix(xcurs)
       y2=fix(ycurs)
       if (x1 gt x2) then begin
         temp=x2
         x2=x1
         x1=temp
       endif
       if (y1 gt y2) then begin
         temp=y2
         y2=y1
         y1=temp
       endif
       xi=x1+indgen(x2-x1)
       yi=y1+indgen(y2-y1)
       AV=fltarr(nv)
       avgx = string(x2-x1,format='(I3)')
       avgy = string(y2-y1,format='(I3)')
       tit='Average of '+avgx+' X '+avgy+' pixels'
       for i=1,nv-1 do  AV[i]=mean(cube[i,xi,yi])
       if not keyword_set(yrange) then begin
        ymin=min(AV)
        ymax=max(AV)
       endif
     
       wset, 20
       plot,vlsr,AV,xtitle="Vlsr (km/s)", ytitle="T (K)",xrange=[v1,v2], $
         yrange=[ymin,ymax], psym=10, title=tit
     endif else begin 
       print,"Aborting box define"
       !mouse.button=0    ; reset mouse.button
    endelse
  endif

  if (!mouse.button eq 4) then break
  !mouse.button=0    ; reset mouse.button
endwhile
end
