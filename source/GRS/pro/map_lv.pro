;+
;   map_lv   Takes input file of GRS spectra sorted in l_gal and
;   ------   makes an (l,v) contour map. 
;             
;   Syntax:  map_lv,fully_qualified_file_name
;   =========================================
;
; V5.0 July 2007
; written 14 Aug by tmb 
;
;-
pro map_lv,Nmap,bins,histdata
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN                      ; forces array indices to be [] 
;
common map_data,map,hor,ver,levs,thick,colors,style,label, $
                title,xsize,ysize,DPC,WBB
;
fmt='("Terminal Velocities at L =",f7.4,2x,"Vt_DPC (magenta) = ",' 
fmt=fmt+'f5.1,"  Vt_WBB (green) = ",f5.1)'
fmt0='(a,1x,f5.1,a,1x,f5.1)'
;
if N_params() gt 3 then begin
    print,'map_lv'
    print,'Plots a (l_gal,v_lsr) contour map at fixed b_gal'
    print,''
    print,'*****************************************'
    print,'SYNTAX: map_lv, map, bins, histdata'
    print,'*****************************************'
    return
endif
;
filename='/drang/data/LVmap.dat'
onfile='ONLINE'
attach,onfile,filename
online
get,0
l_min=!b[0].l_gal
get,!recmax
l_max=!b[0].l_gal
print
print,'L-V map for the range: l_min=',L_min,'   L-max=',l_max,format=fmt0
ytitle_state=!ytitle & !ytitle='GALACTIC LONGITUDE L (deg)'
;
b_gal=0.
delta_l=!grsSpacing
nlong=ceil((l_max-l_min)/delta_l)
lvmap=fltarr(!grsNchan,nlong)
ver=fltarr(nlong)
hor=fltarr(!grsNchan)
for i=0L,!grsNchan-1 do hor[i]=(i-!grsCenCh)*!grsDeltaV+!grsVcen
DPC=ver  ; arrays to show terminal velocity
WBB=ver
;
;     get terminal velocity for center of longitude range
l_gal=(l_max+l_min)/2.
vt,l_gal,vt_dpc,vt_wbb
print
print,l_gal,vt_dpc,vt_wbb,format=fmt
;
openw,lun,'/drang/data/LVmaplist',/get_lun
idx=0
for i=0,nlong-1 do begin
    get,i
;    smo,3
    l_gal=!b[0].l_gal
    b_gal=!b[0].b_gal
    T_max=max(!b[0].data)
    Nspec=!b[0].tintg/60.
    printf,lun,i,l_gal,T_max,Nspec
    ver[idx]=l_gal
;
    vt,l_gal,vt_dpc,vt_wbb
    DPC[idx]=vt_dpc
    WBB[idx]=vt_wbb
;
    lvmap[*,idx]=!b[0].data
    idx=idx+1                
endfor
close,lun
;
window,!map_win,title='L-V Plot',xsize=1200,ysize=1000
;
plot_title='SPECTRA AVERAGED OVER GALACTIC LATITUDE : ' + filename
;
; smooth surface before contouring???
;smomap=min_curve_surf(lvmap,/regular)  ;  IDL packs arrays in a funny way
; map is too large for this to work,apparently....
map=lvmap
;
map=map/0.48   ; convert to brightness temperture
;
Mmax=max(map,min=Mmin)
print,'Tmb_max=',Mmax,' Tmb_min',Mmin
Mmax=1.5 & Mmin=0. &
;
binsize=0.05
numbins=(Mmax-Mmin)/binsize
bins=fltarr(numbins)
for i=0,numbins-1 do bins[i]=0.+float(i)*binsize
histdata=histogram(map,binsize=binsize,min=Mmin,max=Mmax)
;
print,'# bins = ',numbins
; normalize to account for dynamic range
;Nmap=map/Mmax
Nmap=map
;  define look and feel of the contour plots
;levs =[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
;thick=[1.0,1.5,1.5,2.0,2.5,2.5,3.0,4.0,5.0]
levs= [0.1,0.3,0.6,1.0]
thick=[0.5,1.0,1.5,2.0]
label=[  0,  1,  0,  0,  1,  1,  1,  1,  0]
style=[  0,  2,  0,  2,  0,  2,  0,  2,  0]
c_size=n_elements(levs)
colors=fltarr(c_size)
colors[0]=!blue
colors[1]=!green
colors[2]=!yellow
colors[3]=!orange
;colors[0:c_size-1]=!orange
;colors[0]=!white & colors[1:2]=!red & colors[3:4]=!magenta & 
;colors[5]=!cyan  & colors[6]=!yellow &
;
contour,Nmap,hor,ver,/xstyle,/ystyle,/follow,title=plot_title,levels=levs, $
        c_thick=thick,c_colors=colors,c_linestyle=style,c_labels=label,   $
        charsize=1.5,charthick=1.5
;
oplot,DPC,ver,color=!magenta
oplot,WBB,ver,color=!green
;
vbar=[55.0,112.5]
lbar=[15.0,32.0]
oplot,vbar,lbar,color=!red,linestyle=0,thick=3.
;
fname='/drang/data/VT.data'
fmt='(f7.4,1x,f7.4,1x,f8.4)'
openr,lun,fname,/get_lun
kount=0
while not eof(lun) do begin 
      readf,lun,l_gal,vt_lat,vt_max,format=fmt 
      kount=kount+1 
endwhile
close,lun
print,kount
l_gal =fltarr(kount)
vt_lat=fltarr(kount)
vt_max=fltarr(kount)
openr,lun,fname
for i=0,kount-1 do begin 
      readf,lun,ll,bb,vtt,format=fmt 
      l_gal[i]=ll
      vt_lat[i]=bb 
      vt_max[i]=vtt 
endfor
close,lun
;
oplot,vt_max,l_gal,color=!purple,psym=3,thick=1.
;
print
print,'================================================='
print,'Enter "q" to return to normal graphics'
print,'(issue "wreset" at any time to do the same thing)'
print,'================================================='
ans=get_kbrd(1)
if (ans eq 'q') then wreset
;
!ytitle=ytitle_state
;
@CT_OUT
return
end
