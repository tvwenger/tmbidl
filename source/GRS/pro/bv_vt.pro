;+
;   bv_vt.pro   takes input l_gal and makes a (b,v) contour map
;   ---------   of GRS data 
;               each spectrum has the GRS beam  convolved with
;               adjacent data\\
;
;               Finds the terminal velocity for each b_gal and plots it          
;             
;               Syntax:  bv_lt,l_gal
;                         
;                        l_gal in degrees
;
; V5.0 August 2007
;
;-
pro bv_vt,l_gal
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN                ; forces array indices to be [] 
;
common map_data,map,hor,ver,levs,thick,colors,style,label, $
                title,xsize,ysize,DPC,WBB
;
fmt='(/,"(l,v) map for l = ",f7.4,2x,/,"Vt_DPC (magenta) = ",' 
fmt=fmt+'f5.1,"  Vt_WBB (green) = ",f5.1,2x,'
fmt=fmt+'"Vt_NMG (cyan) = ",f6.1,/)'
;
;@def_colors
;
if N_params() eq 0 then begin
    print,'bv_vt.pro'
    print,'Plots a (b_gal,v_lsr) contour map at fixed l_gal and finds Vt'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:   bv_lt,l_gal'
    print
    print,'          input l_gal in degrees'
    print
    print,'*******************************************************************'
    return
endif
;
b_gal=0.  ; first find the right datacube
findGRS,l_gal,b_gal,found,imap
;
beam_state=!grsBeam & !grsBeam=1 & ; flag to stop 'getlb' from looking for datacube 
ytitle_state=!ytitle & !ytitle='L gal (degrees)' &
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
bmin=!grsMaps[5,imap] & bmax=!grsMaps[4,imap] & ; get b_gal range
nlat=!grsSize[1,imap]
;
bvmap=fltarr(!grsNchan,nlat)
hor=fltarr(!grsNchan)
for i=0L,!grsNchan-1 do hor[i]=(i-!grsCenCh)*!grsDeltaV+!grsVcen
ver=fltarr(nlat)
vtb=fltarr(nlat)
;
;     get terminal velocity
vt,l_gal,vt_dpc,vt_wbb,vt_nmg
print,l_gal,vt_dpc,vt_wbb,vt_nmg,format=fmt
;
idx=0
;for b_gal=bmin,bmax,!grsSpacing do begin  
for i=0,nlat-1 do begin
                  b_gal=bmin+!grsSpacing*i
                  Beamlb,l_gal,b_gal,found,imap,offset
;
                  ver[i]=b_gal
                  bvmap[*,idx]=!b[0].data
                  findVT,vt
                  vtb[i]=vt
                  idx=idx+1L                
               endfor
;
window,!map_win,title='B-V Plot',xsize=1200,ysize=1000
;
plot_title='GALACTIC LONGITUDE = '+fstring(l_gal,'(f7.4)')
bvmap=bvmap/0.48   ; convert to brightness temperture
index=finite(bvmap)
tmax=max(bvmap[index]) & tmin=min(bvmap[index]) &
print,'Tmb_max=',tmax,' Tmb_min',tmin
;
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
; smooth surface before contouring???
;map=min_curve_surf(lvmap,hor,ver)
map=bvmap
;
contour,map,hor,ver,/xstyle,/ystyle,/follow,title=plot_title,levels=levs, $
        c_thick=thick,c_colors=colors,c_linestyle=style,c_labels=label,   $
        charsize=1.5,charthick=1.5
;
flag,vt_dpc,!magenta
flag,vt_wbb,!green
flag,vt_nmg,!cyan
;
vmax=!xx[!data_points-1]
vmin=0.4*(vt_dpc+vt_wbb)
index=where(vtb lt vmax and vtb gt vmin)
valid_lat=ver[index]
valid_vt =vtb[index]
vt_max=max(valid_vt)
;
;oplot,valid_vt,valid_lat,color=!white,psym=4,thick=2.5
;
chmax=where(valid_vt eq vt_max)
vt_lat=valid_lat[chmax]
vt_lat=mean(vt_lat)      ; in case vmax is more than one channel 
;
print,l_gal,vt_lat,vt_max
flag, vt_max
hline,vt_lat
;
if !zline then zline
;
if !flag then begin
              print,'Enter "q" to return to normal graphics'
              print,'          (issue "wreset" at any time to do the same thing)'
              ans=get_kbrd(1)
              if (ans eq 'q') then wreset
         end
;
;
!grsBeam=beam_state & !ytitle=ytitle_state &
;
@CT_OUT
return
end
