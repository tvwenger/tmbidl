
;+
;   lvmap.pro   takes input l_gal and makes an (l,v) contour map
;   ---------   of GRS data for input b_gal 
;               each spectrum has the GRS beam convolved with
;               adjacent data. hardwired for T_main_beam
;             
;               Syntax:  lvmap,l_gal,b_gal,l_range
;                         
;                        l_gal,b_gal,l_range in degrees
;
; V5.0 July 2007
;-
pro lvmap,l_gal,b_gal,l_range
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN                      ; forces array indices to be [] 
;
common map_data,map,hor,ver,levs,thick,colors,style,label, $
                title,xsize,ysize,DPC,WBB
;
fmt='("(l,v) map for l = ",f7.4,2x,"Vt_DPC (magenta) = ",' 
fmt=fmt+'f5.1,"  Vt_WBB (green) = ",f5.1)'
;
if N_params() eq 0 then begin
    print,'lvmap.pro'
    print,'Plots a (l_gal,v_lsr) contour map at fixed b_gal'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:   lvmap,l_gal,b_gal,l_range'
    print
    print,'          input l_gal,b_gal,l_range in degrees'
    print
;    print,'                   offset -- angular difference in degrees between '
;    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'*******************************************************************'
    return
endif
;
l_min=l_gal
l_max=l_gal+l_range
l_gal=(l_min+l_max)/2.
delta_l=!grsSpacing
nlong=ceil((l_max-l_min)/delta_l)
; first find the right datacube
findGRS,l_gal,b_gal,found,imap
;
beam_state=!grsBeam & !grsBeam=1 & ; flag to stop 'getlb' from looking for datacube 
ytitle_state=!ytitle & !ytitle='GALACTIC LONGITUDE L (deg)' &
;
fname=!grsIDLfiles[imap]
;
; is this TMB-IDL cube already loaded? If not, then load as ONLINE file
if fname ne !currentGRSfile then begin  ; faster not to go through 'attach'
                                 !online_data=fname
                                 !kon=!grsSize[2,imap] ; #recs in file
                                 close,!onunit
                                 openu,!onunit,!online_data
                                 print
                                 print,'ONLINE data file is ' + !online_data
                                 print
;                                 attach,'ONLINE',fname
                                 !currentGRSfile=fname
                                 end
;
c_lmin=!grsMaps[5,imap] & c_lmax=!grsMaps[4,imap] & ; get c_gal range of cube
c_nlong=!grsSize[0,imap]
;
lvmap=fltarr(!grsNchan,nlong)
hor=fltarr(!grsNchan)
for i=0L,!grsNchan-1 do hor[i]=(i-!grsCenCh)*!grsDeltaV+!grsVcen
ver=fltarr(nlong)
DPC=ver
WBB=ver
;
;     get terminal velocity for center of longitude range
vt,l_gal,vt_dpc,vt_wbb
print,l_gal,vt_dpc,vt_wbb,format=fmt
;
idx=0
for l_gal=l_min,l_max,!grsSpacing do begin  
;for i=0,nlong-1 do begin
                  l_gal=l_min+float(!grsSpacing*idx)
                  Beamlb,l_gal,b_gal,found,imap,offset
;                  print,l_gal,b_gal
                  ver[idx]=l_gal
;
                  vt,l_gal,vt_dpc,vt_wbb
                  DPC[idx]=vt_dpc
                  WBB[idx]=vt_wbb
;
                  lvmap[*,idx]=!b[0].data
                  idx=idx+1L                
               endfor
;
window,!map_win,title='L-V Plot',xsize=1200,ysize=1000
;
plot_title='GALACTIC LATITUDE = '+fstring(b_gal,'(f7.4)')
;
; smooth surface before contouring???
;smomap=min_curve_surf(lvmap,/regular)  ;  IDL packs arrays in a funny way
; map is too large for this to work,apparently....
map=lvmap
;
map=map/0.48   ; convert to brightness temperture
tmax=max(map) & tmin=min(map) &
;
print,'Tmb_max=',tmax,' Tmb_min',tmin
;  define look and feel of the contour plots
levs =[0.5,1.0,1.5,2.0,2.5,3.0,4.0,5.0,6.0]
thick=[1.0,1.5,1.5,2.0,2.0,2.5,3.0,3.5,4.0]
label=[  0,  1,  0,  1,  0,  1,  1,  1,  1]
style=[0  ,  0,  2,  0,  2,  0,  0,  0,  0]
c_size=n_elements(levs)
colors=fltarr(c_size)
colors[0:c_size-1]=!orange
colors[0]=!white & colors[1:2]=!red & colors[3:4]=!magenta & 
colors[5]=!cyan  & colors[6]=!yellow &
;
contour,map,hor,ver,/xstyle,/ystyle,/follow,title=plot_title,levels=levs, $
        c_thick=thick,c_colors=colors,c_linestyle=style,c_labels=label,   $
        charsize=1.5,charthick=1.5
;
oplot,DPC,ver,color=!magenta
oplot,WBB,ver,color=!green
if !zline then zline
;
print,'Enter "q" to return to normal graphics'
print,'          (issue "wreset" at any time to do the same thing)'
ans=get_kbrd(1)
if (ans eq 'q') then wreset
;
;
!grsBeam=beam_state & !ytitle=ytitle_state &
;
@CT_OUT
return
end
