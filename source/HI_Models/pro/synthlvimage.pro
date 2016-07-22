pro synthlvimage,clip=clip,ct=ct,minscale=minscale,$
                 maxscale=maxscale,noimage=noimage,contours=contours,$
                 ps=ps,fname=fname,help=help
;+
; NAME:
;       synthlvimage
;
;            ==============================================
;            Syntax:
;            synthlvimage,noimage=noimage,ct=ct,contours=contours,$
;                    minscale=minscale,maxscale=maxscale,clip=clip,$
;                    ps=ps,fname=fname,help=help
;            ==============================================
;
;   synthlvimage - just the figure creation from synthlv.pro  
;              
;
;
;   KEYWORDS:
;             HELP     = display syntax and documentation
;             PS       = plot everything to ps
;             FNAME   = name of file (without .ps) where l-v map goes
;                        default is 'lvmap'
;             NOIMAGE  = don't make an image
;             CT       = colortable for the l-v map. default is 3 (red temperature)
;             CONTOURS = make contours
;
;             MINSCALE = parameter for image making
;             MAXSCALE = parameter for image making
;             CLIP     = parameter for image making
;                        - don't worry about these
;
; MODIFICATION HISTORY:
;
; V1.0 TVW 29mar2013 - creation
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin
   get_help,'synthlvimage'
   return
endif
;
common lvmap,spects_save,vel_save,lgals_save
spects=spects_save
vel=vel_save
lgals=lgals_save
;
if ~keyword_set(fname) then fname='lvmap'
;
if ~keyword_set(ps) then begin
   device,window_state=win_state
   if win_state[25] eq 1 then wset,25 else window,25,xsize=500,ysize=700,title="L-V Map"
endif else printon,fname
;
; position of tv image
imageposition=[0.15,0.1,0.75,0.9]
legendposition=[0.8,0.2,0.9,0.8]
legend=fltarr(1,101)
legend[0,*]=findgen(101)/100.*(max(spects)-min(spects))+min(spects)
if N_Elements(clip) eq 0 then clip = 99
;
erase
;
if ~keyword_set(noimage) then begin
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
; plot axes if nocontours
    if ~keyword_set(contours) then begin
        plot,lgals,vel,/nodata,xstyle=1,ystyle=1,$
        xrange=[min(vel),max(vel)],yrange=[min(lgals),max(lgals)],$
        position=imageposition,/noerase,xtitle="Velocity (km/s)",ytitle="l (degrees)",$
        charsize=1.5
    endif
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
return
end
