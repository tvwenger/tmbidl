pro spidercontour,nsave_start,nsave_end,help=help,krig=krig,tps=tps,eps=eps,cmap=cmap,$
                  gbt=gbt,size=size,save_file=save_file,radec=radec,spider=spider,length=length
;+
; NAME:
;       spidercontour
;
;            ==============================================
;            Syntax: spidercontour,nsave_start,nsave_end,help=help,$
;                    krig=krig,tps=tps,eps=eps,cmap=cmap,gbt=gbt,size=size,$
;                    save_file=save_file
;            ==============================================
;
;   spidercontour  procedure to 
;   -------------  make a contour map from spider scan averages
;                  of nsaves start through end
;                  extracts coordinates and data
;                  interpolates the data in 2D
;                  makes contour map
;           
;                 
;
;   KEYWORDS:
;              HELP - get syntax help
;              TPS  - use tps to interpolate
;              EPS  - make postscript plots
;              KRIG - use krigging to interpolate instead.
;              CMAP - plot cmapvgps image under spider contours
;              GBT  - draw GBT beam size at center
;              SIZE - full length size of map in arcminutes. default
;                     is 80 arcmin
;              SAVE_FILE - save a data file of data
;
; MODIFICATION HISTORY:
;
; V1.0 TVW 12june2012
;      tvw 17july2012 - allow loop through nsaves, 4 at a time.
;      dsb 15oct2012  - remove datapath from cmapvgps (i.e., use default)
;      dsb 19nov2012  - use eps instead of ps; add nroff and zline
;
;-
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers
@CT_IN
;
if keyword_set(help) then begin
   get_help,'spidercontour'
   return
endif
;
if ~keyword_set(size) then size=80.
;
;num_nsaves=nsave_end-nsave_start
;
for num=nsave_start,nsave_end,4 do begin
   for i=num,num+3 do begin
      getns,i
      raxx
      freexy & nroff
      goodsname=(strsplit(string(!b[0].source),' ',/extract))[0]
      goodtype=strmid(string(!b[0].scan_type),0,strpos(!b[0].scan_type,' '))
      if keyword_set(eps) then printon,goodsname+"_"+goodtype+"_ra",/eps
      xx & zline
      if keyword_set(eps) then printoff
      if i eq num then RA=!xx[0:!c_pts-1] else RA=[RA,!xx[0:!c_pts-1]]
      decx
      freexy & nroff
      if keyword_set(eps) then printon,goodsname+"_"+goodtype+"_dec",/eps
      xx & zline
      if keyword_set(eps) then printoff
      if i eq num then begin
         dec=!xx[0:!c_pts-1]
         temp=!b[0].data[0:!c_pts-1]
      endif else begin
         dec=[dec,!xx[0:!c_pts-1]]
         temp=[temp,!b[0].data[0:!c_pts-1]]
      endelse
   endfor
   ;
   if keyword_set(save_file) then begin
      fname="~/tables/spider_"+string(!b[0].source)+"_map.txt"
      openw,lun,fname,/get_lun
      printf,lun,"#Spider map"
      printf,lun,"RA_offset dec_offset temp"
      printf,lun,"arcsec    arcsec     K"
      for i=0,!c_pts*num_nsaves-1 do printf,lun,RA[i],dec[i],temp[i]
      close,lun
   endif
   ;
   ; make a circle of 1000 points, radius = size*60 /2., whose values are 0.
   ;RA=[RA, (size/2.*60.) * sin(findgen(1000)*2.*3.1415926/1000.)]
   ;dec=[dec, (size/2.*60.) * cos(findgen(1000)*2.*3.1415926/1000.)]
   ;temp=[temp,fltarr(1000)]
   ;
   xax=findgen(1001)*(max(RA)-min(RA))/1000.+min(RA)
   ;print,min(RA),min(xax)
   ;print,max(RA),max(xax)
   ;print,min(RA),max(RA),xax[0],xax[n_elements(xax)-1]
   yax=findgen(1001)*(max(dec)-min(dec))/1000.+min(dec)
   ;print,min(dec),min(yax)
   ;print,max(dec),max(yax)
   ;print,min(dec),max(dec),yax[0],yax[n_elements(yax)-1]
   ;xax=findgen(1001)*800.*60./1000.-40.*60.
   ;yax=xax
   ;
   ;xrange=[max(xax),min(xax)]
   ;yrange=[min(yax),max(yax)]
   xrange=[size/2.*60.,-size/2.*60.]
   yrange=[-size/2.*60.,size/2.*60.]
   ;
   xtitle="RA offset [arcsec]"
   ytitle="dec offset [arcsec]"
   sname=string(!b[0].source)
   title=sname+" Spider Scan Map"
   ;
   if ~keyword_set(eps) then begin
      window,!map_win,xsize=1000,ysize=1000,title=title
      xtitle_state=!xtitle
      ytitle_state=!ytitle
      line=!line
      !line=2
   endif else printon,goodsname+"_spiderscan",/eps
   ;
   position=[0.1,0.1,0.9,0.9]
   ;
   erase
   if keyword_set(cmap) then begin
      if keyword_set(eps) then printoff
      cmapvgps,sname=sname,subdata=subdata,/image,size=size,/eps,$
               /peak,spider=spider,length=length,gbt=gbt,fname=goodsname+"_cmap_small"
      if keyword_set(eps) then printon,goodsname+"_spiderscan_small",/eps
      loadct,3,/silent
      histogram_clip, subdata, 99, minscale, maxscale
      tvimage, bytscl(subdata, minscale, maxscale),position=position,/keep_aspect_ratio,/noint
      RA=RA/3600.+!b[0].ra
      dec=dec/3600.+!b[0].dec
      xax=xax/3600.+!b[0].ra
      yax=yax/3600.+!b[0].dec
                                ;print,min(RA),min(xax)
                                ;print,max(RA),max(xax)
                                ;print,min(dec),min(yax)
                                ;print,max(dec),max(yax)
      glactc,RA,dec,2000.,lgal,bgal,1,/degree
                                ;glactc,xax,yax,2000.,xlgal,ybgal,1,/degree
      xax=findgen(1001)*(max(lgal)-min(lgal))/1000.+min(lgal)
      yax=findgen(1001)*(max(bgal)-min(bgal))/1000.+min(bgal)
                                ;print,min(lgal),min(xlgal)
                                ;print,max(lgal),max(xlgal)
                                ;print,min(bgal),min(ybgal)
                                ;print,max(bgal),max(ybgal)
      xrange=[!b[0].l_gal+size/2./60.,!b[0].l_gal-size/2./60.]
      yrange=[!b[0].b_gal-size/2./60.,!b[0].b_gal+size/2./60.]
      xtitle="L [deg]"
      ytitle="b [deg]"
      xyouts,0.10,0.92,"VGPS Continuum image",/normal,charsize=1.5,charthick=2.0,color=!white
   ;
   endif
   ;
   tvlct,!ct.oldr,!ct.oldg,!ct.oldb
   ;
   levs =[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
   thick=[1.0,1.5,1.5,2.0,2.5,2.5,3.0,4.0,5.0]
   label=[  0,  1,  0,  0,  1,  1,  1,  1,  0]
   style=[  0,  2,  0,  2,  0,  2,  0,  2,  0]
   c_size=n_elements(levs)
   colors=fltarr(c_size)
   colors[0:c_size-1]=!orange
   colors[0]=!white & colors[1:2]=!red & colors[3:4]=!magenta
   colors[5]=!cyan  & colors[6]=!yellow
   ;
   @CT_IN
   ;
   if keyword_set(tps) or keyword_set(krig) then begin
      print,"Interpolating... (may take several minutes)"
      if keyword_set(krig) then begin
         xyouts,0.8,0.96,"Krig2D interpolation",/normal,charsize=1.5,charthick=1.5,color=!orange
         E=[100.0,0.0]
         if keyword_set(cmap) then begin
            interpolated=krig2d(temp,lgal,bgal,expon=E,nx=n_elements(xax),ny=n_elements(yax))
         endif else begin
            interpolated=krig2d(temp,RA,dec,expon=E,nx=n_elements(xax),ny=n_elements(yax))
         endelse
      endif else begin
         xyouts,0.8,0.96,"Grid_TPS interpolation",/normal,charsize=1.5,charthick=1.5,color=!orange
         if keyword_set(cmap) then begin
            interpolated=grid_tps(lgal,bgal,temp,ngrid=[n_elements(xax),n_elements(yax)])
         endif else begin
            help,RA
            help,dec
            help,temp
            help,xax
            help,yax
            interpolated=grid_tps(RA,dec,temp,ngrid=[n_elements(xax),n_elements(yax)])
         endelse
      endelse
      help,interpolated
      ;help,xlgal
      ;help,ybgal
      ;
      normalized=interpolated/interpolated[n_elements(xax)/2.,n_elements(yax)/2.]
      ;
      if keyword_set(cmap) then begin
         contour,normalized,xax,yax,xrange=xrange,yrange=yrange,xtitle=xtitle,ytitle=ytitle,$
                 /xstyle,/ystyle,/follow,levels=levs,c_thick=thick,c_colors=colors,c_linestyle=style,$
                 c_labels=label,charsize=1.5,charthick=1.5,/iso,position=position,/noerase
         ;pcircle,!b[0].l_gal,!b[0].b_gal,40./60.,color=!gray
      endif else begin
         contour,normalized,xax,yax,xrange=xrange,yrange=yrange,xtitle=xtitle,ytitle=ytitle,$
                 /xstyle,/ystyle,/follow,levels=levs,c_thick=thick,c_colors=colors,c_linestyle=style,$
                 c_labels=label,charsize=1.5,charthick=1.5,/iso,position=position,/noerase
         ;pcircle,0,0,60.*40.,color=!gray
      endelse
   endif else begin
      normalized=temp/temp[!c_pts/2.]
      xyouts,0.8,0.96,"IDL interpolation",/normal,charsize=1.5,charthick=1.5,color=!orange
      if keyword_set(cmap) then begin
         contour,normalized,lgal,bgal,xrange=xrange,yrange=yrange,xtitle=xtitle,ytitle=ytitle,$
                 /xstyle,/ystyle,/follow,levels=levs,c_thick=thick,c_colors=colors,c_linestyle=style,$
                 c_labels=label,charsize=1.5,charthick=1.5,/iso,position=position,/irregular,/noerase
         ;pcircle,!b[0].l_gal,!b[0].b_gal,40./60.,color=!gray
      endif else begin
         contour,normalized,RA,dec,xrange=xrange,yrange=yrange,xtitle=xtitle,ytitle=ytitle,$
                 /xstyle,/ystyle,/follow,levels=levs,c_thick=thick,c_colors=colors,c_linestyle=style,$
                 c_labels=label,charsize=1.5,charthick=1.5,/iso,position=position,/irregular,/noerase
         ;pcircle,0,0,60.*40.,color=!gray
      endelse
   ;contour,temp,RA,dec,xrange=xrange,yrange=yrange,xtitle=xtitle,ytitle=ytitle,$
   ;        /xstyle,/ystyle,/follow,/iso,position=position,/irregular
   endelse
   ;
   ; plot RA and DEC lines
   if keyword_set(radec) || keyword_set(spider) then begin
      racenter=!b[0].ra
      deccenter=!b[0].dec
                                ;print,racenter
                                ;print,deccenter
      linelength=10./60.
      if keyword_set(length) then linelength=length/60. $
      else print, '  Using default RA,Dec line length of 10.0 arcminutes. Change with keyword "length"'
                                ;
      step=linelength/101.
                                ;
                                ;glactc,racenter,deccenter,2000.,lgal,bgal,2,/degree
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
      ra_color=!gray
      dec_color=!orange
                                ;
                                ; this is the increasing DEC vector
      oplot,ralinel,ralineb,color=dec_color,thick=5.0
                                ;print,ralinel[0],ralineb[0]
      arrow,ralinel[99],ralineb[99],ralinel[100],ralineb[100],/data,color=dec_color,thick=5.0
                                ;
                                ; this is the increasing RA Vector
      oplot,declinel,declineb,color=ra_color,thick=5.0
      arrow,declinel[99],declineb[99],declinel[100],declineb[100],/data,color=ra_color,thick=5.0
                                ;
                                ;print,racenter
                                ;print,deccenter
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
      xyouts,0.60,0.96,rastr,/normal,charsize=2.0,charthick=2.0,color=ra_color
      xyouts,0.60,0.93,decstr,/normal,charsize=2.0,charthick=2.0,color=dec_color
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
         spider_color=!cyan
         oplot,line1l,line1b,color=spider_color,thick=5.0
         oplot,line2l,line2b,color=spider_color,thick=5.0
      endif
   endif
;
   if keyword_set(gbt) then begin
      gbt_beam=82./3600.
      if keyword_set(cmap) then pcircle,!b[0].l_gal,!b[0].b_gal,gbt_beam,color=!green $
      else pcircle,0,0,gbt_beam*3600.,color=!green
      xyouts,0.40,0.92,"GBT Beam Size (X-band)",/normal,charsize=1.5,charthick=2.0,color=!green
   endif
;
   xyouts,0.10,0.96,sname,/normal,charsize=2.5,charthick=3.0,color=!cyan
   xyouts,0.40,0.96,"Spider Scan Contour Map",/normal,charsize=1.5,charthick=1.5,color=!cyan
;
   if ~keyword_set(eps) then begin
      !line=line
      !xtitle=xtitle_state
      !ytitle=ytitle_state
   endif else printoff
   @CT_OUT
endfor
return
end
