;+
;   LBMAP
;
;   lbmap  Makes an L,B map of GRS Wco centered at l_gal,b_gal.
;   -----  Map dimensions are input l_range & b_range.
;          Wco calculated for v_range centered at v_lsr.
;   ===========================================================           
;   Syntax:  lbmap,l_gal,b_gal,v_lsr,l_range,b_range,v_range, $
;   ======         ps=ps,help=help,anno=anno,beam=beam
;   ===========================================================
;            l_gal,b_gal,l_range,b_range in degrees
;            v_lsr,v_range in km/sec
;           
;   Keywords help=help gives syntax   
;   ======== ps=ps toggels for PostScript output
;            anno=anno annotates plot 
;            beam=beam plots circle of beam (arcsec) 
;                  radius centered at l_gal,b_gal
;
; TMB Modified 27 Apr 2007 Calculates map average spectrum via
;     accum/ave leaves result in !b[0] & !b[15] 
;     max num_pts is !accum[20000]
;
; V5.0 July 2007
; v6.1 Nov 2010  tmb  Max number of points is now !accum[409600]
;      added keywords: /ps PostScript, /help, /anno, and /beam
;      cleaned up window handling for postscript
;
;-
pro lbmap,l_gal,b_gal,v_lsr,l_range,b_range,v_range, $
          ps=ps,help=help,anno=anno,beam=beam
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN                ; forces array indices to be [] 
;
common map_data,map,hor,ver,levs,thick,colors,style,label, $
                title,xsize,ysize,DPC,WBB
;
;fmt='("(l,v) map for l = ",f7.4,2x,"Vt_DPC (magenta) = ",' 
;fmt=fmt+'f5.1,"  Vt_WBB (green) = ",f5.1)'
;
;@def_colors
;
if N_params() eq 0 or Keyword_Set(help) then begin
    print
    print,'lbmap'
    print,'====='
    print,'Makes an L,B map of GRS Wco centered at l_gal,b_gal.'
    print,'Map dimensions are input l_range,b_range.'
    print,'Wco calculated for v_range centered at v_lsr.'
    print
    print,'*******************************************************************'
    print,'SYNTAX: lbmap,l_gal,b_gal,v_lsr,l_range,b_range,v_range, &'
    print,'              ps=ps,help=help,anno=anno,beam=beam'
    print
    print,'   l_gal,b_gal,l_range,b_range in degrees'
    print,'   v_lsr,v_range in km/sec'
    print
    print,'   Keywords: help=help gives syntax'  
    print,'             ps=ps toggels for PostScript output'
    print,'             anno=anno annotates plot '
    print,'             beam=beam plots circle of beam (arcsec) radius'
    print,'                     at l_gal,b_gal'
    print,'*******************************************************************'
    return
endif
;
if Keyword_Set(ps) then printon
;
case n_params() of 
       5: v_range=5.
       4: b_range=10./60.
       3: l_range=10./60.
    else:
endcase
;
l0=l_gal & b0=b_gal & v0=v_lsr &
l_min=l0-l_range/2. & l_max=l0+l_range/2. &
b_min=b0-b_range/2. & b_max=b0+b_range/2. &
v_min=v0-v_range/2. & v_max=v0+v_range/2. &
nlong=ceil((l_max-l_min)/!grsSpacing)
nlat =ceil((b_max-b_min)/!grsSpacing) 
lbmap=fltarr(nlong,nlat) 
hor=fltarr(nlong)
ver=fltarr(nlat)
vel=fltarr(!grsNchan)
for i=0,nlong-1 do hor[i]=l_max-float(i)*!grsSpacing
for i=0,nlat -1 do ver[i]=b_min+float(i)*!grsSpacing
for i=0,!grsNchan-1 do vel[i]=(i-!grsCenCh)*!grsDeltaV+!grsVcen
; first find the right datacube
findGRS,l_gal,b_gal,found,imap
;
beam_state=!grsBeam & !grsBeam=1 & ; flag to stop 'getlb' from looking for datacube 
xtitle_state=!xtitle & !xtitle='L (deg)' &
ytitle_state=!ytitle & !ytitle='B (deg)' &
;
fname=!grsIDLfiles[imap]
;
; is this TMB-IDL cube already loaded? If not, then load as ONLINE file
if fname ne !currentGRSfile then begin  ; faster not to go through 'attach'
                                 !online_data=fname
                                 !kon=!grsSize[2,imap] ; #recs in file
                                 close,!onunit
                                 openr,!onunit,!online_data
                                 print
                                 print,'ONLINE data file is ' + !online_data
                                 print
                                 !currentGRSfile=fname
                                 end
;
c_lmin=!grsMaps[5,imap] & c_lmax=!grsMaps[4,imap] & ; get c_gal range of cube
c_nlong=!grsSize[0,imap]
;
l_idx=0 
nspec=0
for l_gal=l_max,l_min,-!grsSpacing do begin  
    l_gal=l_max-float(!grsSpacing*l_idx)
    b_idx=0 
    for b_gal=b_min,b_max,!grsSpacing do begin 
        b_gal=b_min+float(!grsSpacing*b_idx)
        Beamlb,l_gal,b_gal,found,imap,offset
;       calculate map average spectrum
        accum
        nspec=nspec+1
        case 1 of 
             v_range eq 0.:begin
                           Wco=total(!b[0].data)*!grsDeltav
                           v_title='ALL'
                           end
                      else:begin ; get locations with in Delta V
                           index=where(vel ge v_min and vel le v_max)
                           Wco=total(!b[0].data[index])*!grsDeltav
                           title=fstring(v0,'(f5.1)')+' '
                           title=title+textoidl("\Delta")+'V = '
                           title=title+fstring(v_range,'(f4.1)')
                           v_title=title
                           end
        endcase
    lbmap[l_idx,b_idx]=Wco
    ;print,l_gal,b_gal
     b_idx=b_idx+1L
     endfor ; b_gal loop
;
     l_idx=l_idx+1L                
endfor ; l_gal loop
;
; map average spectrum:  l,b of map center 
ave
sname='Map Average'
print,'Nspec in map average is = ',nspec
!b[0].scan_num=nspec
!b[0].tintg=nspec*60.
!b[0].scan_type=''
!b[0].source=''
!b[0].source=byte(strtrim(sname,2))
!b[0].l_gal=l0
!b[0].b_gal=b0
copy,0,15
;
scale=nlong>nlat
scale=float(scale) & long=float(nlong) & lat=float(nlat) &
;print,nlong,nlat,scale
xsize=1000.*(nlong/scale) & ysize=1000.*(nlat/scale) &
title='L-B Plot at LSR V ='+fstring(v_lsr,'(f5.1)')
;
if ~Keyword_Set(ps) then begin
    window,!map_win,title=title,xsize=1000,ysize=1000
    !line=2  ; ID window for TMBIDL
endif
;
map=lbmap
Mmax=max(map) & Mmin=min(map) &
;
print,'Wco_max=',Mmax,' Wco_min',Mmin
; normalize to account for dynamic range
Nmap=map/Mmax
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
;
contour,Nmap,hor,ver,/xstyle,/ystyle,/follow,title=plot_title,levels=levs, $
        c_thick=thick,c_colors=colors,c_linestyle=style,c_labels=label,    $
        charsize=1.5,charthick=1.5,position=[0.10,0.10,0.90,0.90],     $
        xrange=[l_max,l_min],yrange=[b_min,b_max], $
        /isotropic
;       /isotropic forces identical x,y axis scaling
;
if Keyword_Set(beam) then begin 
   radius=beam/3600. 
   pcircle,l0,b0,radius
endif
;
; Annotate plot?
;
if Keyword_Set(anno) then begin
;
;position,l0,b0,!green,0.1  ; plot map center with 0.1 deg error box
;
name=' '
gname,l0,b0,src=name
title=name+'  '+textoidl("V_{LSR}")+' = '+v_title
;
xyouts,0.10,.96,title,/normal,charsize=2.5,charthick=3.0, $
  color=!cyan
qqq=' Peak Wco '+fstring(Mmax,'(f5.1)')+' K km/s'
qqq=qqq+'  N('+textoidl("H_2")+') = '
htwocolumn=4.92e+20*Mmax
htwocolumn=fstring(htwocolumn,'(e10.2)')
qqq=qqq+htwocolumn
xyouts,0.10,0.92,qqq,/normal,charsize=2.0,charthick=2.0, $
  color=!orange
;
; Tangent point velocities: DPC is magenta and WBB is green
;
vt,l0,vt_dpc,vt_wbb ; map center l_gal
qqq='V tangent: '+' DPC '+fstring(vt_dpc,'(f6.1)')
qqq=qqq+' WBB '+fstring(vt_wbb,'(f6.1)')
xyouts,0.1,0.015,qqq,/normal,charsize=1.5,charthick=1.0, $
  color=!magenta
endif
;
if !flag then begin
              print,'Enter "q" to return to normal graphics'
              print,'          (issue "wreset" at any time to do the same thing)'
              ans=get_kbrd(1)
              if (ans eq 'q') then wreset
         end
;
!grsBeam=beam_state & !xtitle=xtitle_state & !ytitle=ytitle_state &
l_gal=l0 & b_gal=b0& v_lsr=v0 &
;
punt:
if Keyword_Set(ps) then printoff
;
@CT_OUT
return
end
