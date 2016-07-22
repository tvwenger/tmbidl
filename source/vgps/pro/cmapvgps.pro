pro cmapvgps,lgal,bgal,subdata=subdata,sname=sname,size=size,image=image,$
             nocontours=nocontours,vgps=vgps,gbt=gbt,eps=eps,$
             fname=fname,help=help,peak=peak,datapath=datapath,$
             radec=radec,length=length,minscale=minscale,maxscale=maxscale,$
             clip=clip,spider=spider
;+
; NAME:
;       CMAPVGPS
;
;            ==================================================
;            Syntax: cmapvgps,lgal,bgal,subdata=subdata,sname=sname,size=size,$
;                    image=image,nocontours=nocontours,$
;                    gbt=gbt,vgps=vgps,eps=eps,fname=fname,$
;                    help=help,peak=peak,datapath=datapath,$
;                    radec=radec, length=length, minscale=minscale, maxscale=maxscale,$
;                    clip=clip,spider=spider
;                    
;            ==================================================
;
;   cmapvgps  Procedue to create a L,B plot of continuum data 
;   --------  from the VLA Galactic Plane Survey (VGPS).
;
;      INPUT: Source galactic position as either lgal,bgal floats OR
;             as string in gname.pro format via sname keyword                
;
;              (some) Requirements:
;                VGPS_cont fits header
;                VGPS_cont data locationon NINKASI:
;                             /data/VGPS/continuum/
;                       override this location with keyword datapatn 
;                1024 datapoints
;              uses some code from lbmap.pro (T. Bania)
;                                  especially the COMMON block
;
;               NOTE:
;               Gives errors about CT_IN, CT_OUT if not running TMBIDL, but
;               everything works ok.
;   
;     OUTPUT: VGPS image array of specified size (in subimage keyword)
;
;   KEYWORDS:
;               sname - input source position as string in gname.pro format 
;                       THIS USEAGE OVERRIDES ANY INPUT LGAL,BGAL
;               size - square map size->in arcmin. Default is 10.0 arcmin;
;               image - displays a tv image also
;               nocontours - does not display contours
;               peak - normalize the contours to center of source
;                   default-normalize to max value of map
;               gbt - draws a circle representing the GBT beam size at X-band
;               vgps - draws a circle representing the VGPS Synthesized Beam Size
;               ps - postscript output
;               fname - overrides postscript output file
;               help - displays help text
;               datapath - fully qualified file path to the VGPS data
;                          default is ../../data/vgps/continuum/
;               radec - plot RA,Dec vectors through center. 
;               length - full length of the RA, dec vectors. Default is 10 arcminutes.
;               minscale - minimum value to map to color table
;               maxscale - maximum value to map to color table
;                           defaults use histogram_clip
;               clip - histogram clip to implement.  Defaults to 99%.
;               spider - plots RA,dec vectors and the rest of the spider scan paths
;
; MODIFICATION HISTORY:
;
; V1.0 TVW 06feb2012 Created
;      TVW 07feb2012 added peak keyword
;      TVW 21feb2012 changed beam keywords, added gbt beam size display
;                    added default size=10.0 arcminutes
;      TVW 22feb2012 added datapath keyword
;      TMB 22feb2012 modified to accept source position as either 
;                    lgal,bgal position or Gname.pro string via keyword
;      DSB 23feb2012 save/restore appropriate windows
;      LDA 23feb2012 use headfits,findgen for speed. No interpolation in image
;      TVW 25feb2012 added solo keyword (did not implement), radec keyword, linel keyword
;      TVW 26feb2012 corrected center offset problem
;      TVW 28feb2012 corrected radec and linel, make help work
;      TVW 29feb2012 removed solo keyword, added non-tmbidl functionality (LDA)
;      LDA 01mar2012 added subimage parameter, minscale, maxscale, clip,
;                    keywords.  Changed default image scaling.
;      TVW 01mar2012 only look for VGPS_cont files, changed linel to length
;                    put arrows on ra,dec vectors, changed subdata to keyword
;                    added keyword spider
;      DSB 19nov2012 use eps instead of ps
;      tvw 27jun2013 better window handling, added help
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers
;
@CT_IN            ; save color table information
;
common map_data,map,hor,ver,levs,thick,colors,style,label, $
                title,xsize,ysize,DPC,WBB
;
if Keyword_Set(help) then begin
    get_help,'cmapvgps'
    @CT_OUT
    return
endif
;
if n_params() lt 2 and ~Keyword_Set(sname) then begin
    print
    print,'ERROR! No source position supplied. Ask for "cmapvgps,/help"'
    print
    @CT_OUT
return
endif
;
; check if we're running on TMBIDL
defsysv, '!prompt', exists=tmbidl
if tmbidl && !prompt eq "TMBIDL-->" then print,"  We are running TMBIDL!" $
else begin
    print,"  We are ***NOT*** running TMBIDL!"
    tmbidl=0
endelse
;
; check histogram clipping
if N_Elements(clip) eq 0 then clip = 99
; save window type
if tmbidl then line=!line
;
; default size is 10.0 arcmin
if ~Keyword_Set(size) then begin
    size=10.0
    print,'  Using default field length and width of 10.0 arcminutes. Change with keyword "size"'
endif
;
; if sname keyword is used then get galactic co-ordinates
; THIS OVERRIDES any input lgal,bgal 
; if lgal, bgal were input this returns the positions in the gname
if keyword_set(sname) then begin
    lgal=1.
    bgal=1.
    nameg,sname,lgal,bgal
    sourcename=sname
;print,lgal,bgal
endif else begin
    sourcename=' '
    gname,lgal,bgal,src=sourcename
endelse
;
; determine which data file to use
if keyword_set(datapath) then files=findfile(datapath+'VGPS_cont*') $
                         else files=findfile('../../data/vgps/continuum/VGPS_cont*')
;
; convert arcmin to degs
sizedeg = size/60.
;
; determine l and b range in degrees
; l is backwards
lrange=[lgal+(sizedeg/2.),lgal-(sizedeg/2.)];
brange=[bgal-(sizedeg/2.),bgal+(sizedeg/2.)]
;print,lrange,brange
;
; save some vars before loop
data=1.
lscale=1.
loffset=1.
bscale=1.
boffset=1.
;
; make sure file is found
found=0
;
for i=0,size(files,/n_elements)-1 do begin
    head=headfits(files[i], /silent)
;
; get pixel size and offset in l
    lscale=sxpar(head,"CDELT1")
    loffset=sxpar(head,"CRPIX1")
;    print,lscale,loffset
;
; get pixel size and offset in b
    bscale=sxpar(head,"CDELT2")
    boffset=sxpar(head,"CRPIX2")
;    print,bscale,boffset
;
; convert pixel to degs
    ldata=lscale*(findgen(1024)-loffset)
    bdata=bscale*(findgen(1024)-boffset)
;   print,ldata[0],ldata[1023]
;
; check that our area falls in range
;    print,min(ldata),max(ldata),min(bdata),max(bdata)
    if min(lrange) gt min(ldata) and min(brange) gt min(bdata) and $
    max(lrange) lt max(ldata) and max(brange) lt max(bdata) then begin
        found=1
        data=readfits(files[i],/silent)
        break
    endif
;
endfor
;
if ~found then begin 
    print,'Position not found in data. (Try a smaller size)'
    @CT_OUT
    if tmbidl then !line=line ; restore window type
    return
endif
;
if Keyword_Set(eps) then begin 
   if Keyword_Set(fname) then printon,fname,/eps else printon,/eps
endif
;
if tmbidl then begin
    xtitle_state=!xtitle & !xtitle='L [deg]' &
    ytitle_state=!ytitle & !ytitle='B [deg]'
endif
;
; get pixel range so we can extract subdata from data
; use ceil and floor so we get whole pixels from the data
; otherwise we try to pull out some fraction of a pixel
; and who knows what happens with that.
lpixrange=(lrange/lscale)+loffset
;print,lpixrange
;
; remember, lpix is forward
lpixrange[0]=floor(lpixrange[0])
lpixrange[1]=ceil(lpixrange[1])
;print,lpixrange
;
bpixrange=(brange/bscale)+boffset
;print,bpixrange
bpixrange[0]=floor(bpixrange[0])
bpixrange[1]=ceil(bpixrange[1])
;print,lpixrange,bpixrange
;
; correct lrange and brange (in degrees) so they correspond to the
; ends of the pixels that we pulled out right above
; lrange is backwards
lrange=lscale*(lpixrange-loffset)
brange=bscale*(bpixrange-boffset)
;print,lrange,brange
;
; get subdata of source
; -1's in subdata to account for pixel/location discrepency
subdata=data[min(lpixrange)-1:max(lpixrange)-1,min(bpixrange)-1:max(bpixrange)-1]
lsubdata=ldata[min(lpixrange):max(lpixrange)]
bsubdata=bdata[min(bpixrange):max(bpixrange)]
;
lmidpix=(max(lpixrange)-min(lpixrange))/2
bmidpix=(max(bpixrange)-min(bpixrange))/2
;
; set common block data
map=subdata
hor=lsubdata
ver=bsubdata
title="VGPS Continuum of "+sourcename
;
if ~Keyword_Set(eps) then begin
    if tmbidl then begin
        device,window_state=win_state
        if win_state[!map_win] eq 1 then wset,!map_win else $
           window,!map_win,title=title,xsize=1000,ysize=1000
        !line=2  ; ID window for TMBIDL
    endif else begin
       device,window_state=win_state
        if win_state[!map_win] eq 1 then wset,!map_win else $
           window,3,title=title,xsize=1000,ysize=1000
     endelse
endif
;
; position of tv image
imageposition=[0.1,0.1,0.9,0.9]
;
erase
;
if keyword_set(image) then begin
; generate tv image of data
    loadct,3,/silent
    if N_Elements(minscale) eq 0 or N_Elements(maxscale) eq 0 then $
       histogram_clip, subdata, clip, minscale, maxscale
    tvimage, bytscl(subdata, minscale, maxscale), position=imageposition,/keep_aspect_ratio, /noint

; plot axes if nocontours
    if keyword_set(nocontours) then begin
        plot,lsubdata,bsubdata,/nodata,xstyle=1,ystyle=1,$
        xrange=[max(lrange),min(lrange)],yrange=[min(brange),max(brange)],$
        position=imageposition,/noerase,/isotropic
    endif
endif
;
; return to old color table
if tmbidl then tvlct,!ct.oldr,!ct.oldg,!ct.oldb
;
;print,imageposition
;
if ~keyword_set(nocontours) then begin
; normalize data for contours
    if keyword_set(peak) then begin
        Nsubdata=subdata/subdata[lmidpix,bmidpix]
    endif else begin
        Nsubdata=subdata/max(subdata)
    endelse
; Contour code from lbmap.pro (T.Bania)
;  define look and feel of the contour plots
    levs =[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
    thick=[1.0,1.5,1.5,2.0,2.5,2.5,3.0,4.0,5.0]
    label=[  0,  1,  0,  0,  1,  1,  1,  1,  0]
    style=[  0,  2,  0,  2,  0,  2,  0,  2,  0]
    c_size=n_elements(levs)
    colors=fltarr(c_size)
    if tmbidl then begin
       colors[0:c_size-1]=!orange
       colors[0]=!white & colors[1:2]=!red & colors[3:4]=!magenta & 
       colors[5]=!cyan  & colors[6]=!yellow &
    endif else begin
       colors[0:c_size-1]=fsc_color('orange')
       colors[0]=fsc_color('white') & colors[1:2]=fsc_color('red') & colors[3:4]=fsc_color('magenta') & 
       colors[5]=fsc_color('cyan') & colors[6]=fsc_color('yellow') &
    endelse
;
    contour,Nsubdata,lsubdata,bsubdata,xstyle=1,ystyle=1,/follow,levels=levs,c_thick=thick,$
            c_colors=colors,c_linestyle=style,c_labels=label,charsize=1.5,charthick=1.5,$
            xrange=[max(lrange),min(lrange)],yrange=[min(brange),max(brange)],$
            position=imageposition,/noerase,/isotropic
endif
;
; plot RA and DEC lines
if keyword_set(radec) || keyword_set(spider) then begin
    linelength=10./60.
    if keyword_set(length) then linelength=length/60. $
    else print, '  Using default RA,Dec line length of 10.0 arcminutes. Change with keyword "linel"'
    ;
    step=linelength/101.
    ;
    glactc,racenter,deccenter,2000.,lgal,bgal,2,/degree
    ;
    ;print,racenter,deccenter
    ;
    ra=findgen(101)-50
    dec=findgen(101)-50
    ;
    ra=ra*step + racenter
    decmid=fltarr(101)+deccenter
    ;
    dec=dec*step + deccenter
    ramid=fltarr(101)+racenter
    ;print,sixty(ra[100]*24./180.),sixty(dec[100])
    ;
    glactc,ramid,dec,2000.,ralinel,ralineb,1,/degree
    glactc,ra,decmid,2000.,declinel,declineb,1,/degree
    ;
    ;print,declinel[100],declineb[100]
    ;
    if tmbidl then ra_color=!gray else ra_color=fsc_color('gray')
    if tmbidl then dec_color=!orange else dec_color=fsc_color('orange')
    ;
    ; this is the increasing DEC vector
    oplot,ralinel,ralineb,color=dec_color,thick=5.0
    arrow,ralinel[99],ralineb[99],ralinel[100],ralineb[100],/data,color=dec_color,thick=5.0
    ;
    ; this is the increasing RA Vector
    oplot,declinel,declineb,color=ra_color,thick=5.0
    arrow,declinel[99],declineb[99],declinel[100],declineb[100],/data,color=ra_color,thick=5.0
    ;
    rahours=sixty(racenter*24./360.)
    decdegs=sixty(deccenter)
    ;
    rastr="RA   "+fstring(rahours[0],'(I2)')+":"+fstring(rahours[1],'(I2)')+":"+fstring(rahours[2],'(F4.1)')
    ;
    ; correct negative sign location
    if decdegs[1] lt 0 || decdegs[2] lt 0 then begin
        decdegs[1] = abs(decdegs[1])
        decdegs[2] = abs(decdegs[2])
        decstr="Dec -"+fstring(decdegs[0],'(I1)')+":"+fstring(decdegs[1],'(I2)')+":"+fstring(decdegs[2],'(F4.1)')
    endif else decstr="Dec "+fstring(decdegs[0],'(I3)')+":"+fstring(decdegs[1],'(I2)')+":"+fstring(decdegs[2],'(F4.1)')
    ;print,rahours,rastr
    ;print,decdegs,decstr
    xyouts,0.65,0.96,rastr,/normal,charsize=2.0,charthick=2.0,color=ra_color
    xyouts,0.65,0.93,decstr,/normal,charsize=2.0,charthick=2.0,color=dec_color
    ;
    if keyword_set(spider) then begin
        line1ra=findgen(101)-50
        line1dec=findgen(101)-50
        line2ra=findgen(101)-50
        line2dec=findgen(101)-50
        ;
        line1ra=line1ra*step/1.414 + racenter
        line1dec=line1dec*step/1.414 + deccenter
        ;
        line2ra=-1*line2ra*step/1.414 + racenter
        line2dec=line2dec*step/1.414 + deccenter
        ;
        glactc,line1ra,line1dec,2000.,line1l,line1b,1,/degree
        glactc,line2ra,line2dec,2000.,line2l,line2b,1,/degree
        ;
        ;print,line2l
        ;print,line2b
        ;
        if tmbidl then spider_color=!cyan else spider_color=fsc_color('cyan')
        oplot,line1l,line1b,color=spider_color,thick=5.0
        oplot,line2l,line2b,color=spider_color,thick=5.0
    endif
endif
;
if keyword_set(vgps) then begin
    vgps_beam_synth=45./3600.; degrees
    if tmbidl then circle_color = !blue else circle_color = fsc_color('blue')
    pcircle,lgal,bgal,vgps_beam_synth,color=circle_color
    xyouts,0.10,0.92,"VGPS Beam Size",/normal,charsize=1.5,charthick=2.0,color=circle_color
;    print,vgps_beam_synth
endif
;
if keyword_set(gbt) then begin
    gbt_beam=82./3600.; degrees
    if tmbidl then circle_color = !green else circle_color = fsc_color('green')
    pcircle,lgal,bgal,gbt_beam,color=circle_color
    xyouts,0.40,0.92,"GBT Beam Size (X-band)",/normal,charsize=1.5,charthick=2.0,color=circle_color
endif
;
if tmbidl then center_color = !green else center_color = fsc_color('green')
position,lgal,bgal,center_color  ; plot map center
if tmbidl then annotation_color = !cyan else annotation_color = fsc_color('cyan')
xyouts,0.10,.96,title,/normal,charsize=2.5,charthick=3.0, $
  color=annotation_color
;
if tmbidl then begin
    !xtitle=xtitle_state & !ytitle=ytitle_state
    !line=line ; restore window type
    wset,!line
endif
if Keyword_Set(eps) then printoff
@CT_OUT
return
end
