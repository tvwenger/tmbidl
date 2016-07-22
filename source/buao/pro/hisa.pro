pro hisa,dim
;+
; NAME:
;       HISA
;
;   hisa  
;   ----
;
;-
; MODIFICATION HISTORY
; v7.0 12jul2013 tmb - based on v3.2
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'hisa' & return & endif
;
if n_params() eq 0 then dim=9 
if dim gt 25 then begin
             print,'Error! Grid size must be le 25'
             return
endif
;
map_pos=intarr(25)
gl=fltarr(25)
gb=fltarr(25)
exist=intarr(25)
mpos=[0,-1L,1L,-!n_ver,!n_ver,-!n_ver-1L,-!n_ver+1L,!n_ver-1L,!n_ver+1L, $
      -2.*!n_ver-2,-2.*!n_ver-1,-2.*!n_ver,-2.*!n_ver+1,-2.*!n_ver+2,    $
      2.*!n_ver-2,2.*!n_ver-1,2.*!n_ver,2.*!n_ver+1,2.*!n_ver+2,         $
      -2L,-!n_ver-2L,!n_ver-2L,2L,-!n_ver+2L,!n_ver+2L]
;
yellow=!yellow & cyan=!cyan & magenta=!magenta &
red=!red & blue=!blue & white=!white & clr=white &
;
l_gal=!b[0].l_gal & b_gal=!b[0].b_gal
getlb,l_gal,b_gal,rec
;rec=!b[0].scan_num
show
;
for i=0,dim-1 do begin
    get,rec+mpos[i]
    gl[i]=!b[0].l_gal & gb[i]=!b[0].b_gal & exist[i]=!b[0].last_on &
    if (i gt 0 and i le 4) then clr=magenta
    if (i gt 4 and i le 8) then clr=red
    if (i gt 8) then clr=blue
    if i gt 0 then reshow,color=clr
endfor
;
print
print,'Grid of '+fstring(dim,'(i2)')+' positions shown'
print,'mpos  l_gal  b_gal  exist?'
for i=0,dim-1 do begin
    print,mpos[i],gl[i],gb[i],exist[i],format='(i4,2f7.3,i3)'
endfor
;
print,'Do you want to see the positions of this grid? (y/n)'
ans=get_kbrd(1)           ;  the pause that refreshes
if (ans ne 'y') then goto, punt
;
syms,1,2,1
xmin=min(gl[0:dim-1]) & xmin=xmin-!del_hor &
xmax=max(gl[0:dim-1]) & xmax=xmax+!del_hor &
ymin=min(gb[0:dim-1]) & ymin=ymin-!del_ver &
ymax=max(gb[0:dim-1]) & ymax=ymax+!del_ver &
;print,xmin,xmax,ymin,ymax
plot,gl,gb,psym=8,$
     title='MAP POSITIONS',$
     xtitle='Galactic Longitude (deg)',$
     ytitle='Galactic Latitude (deg)',$
     xrange=[xmin,xmax],$
     yrange=[ymin,ymax],$
     /xstyle,/ystyle

;
punt:
return
end

