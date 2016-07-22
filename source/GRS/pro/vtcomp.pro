PRO VTCOMP
;+
; NAME:
;   VTCOMP
; PURPOSE:
;   Compare the DPC and WDD terminal velocities over the GRS lgal range
;            
; CALLING SEQUENCE:
;    VTCOMP
;
; REVISION HISTORY:
;    Written by T.M. Bania, 10 January 2007 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
lmin=14.d & lmax=56.d &  ; lgal in degrees
deltal=0.5d & 
npts=fix((lmax-lmin)/deltal)+1
Vtwbb=fltarr(npts)
Vtdpc=fltarr(npts)
DV=Vtwbb
lgal=fltarr(npts)
;
k=0
for l=lmin,lmax,deltal do begin
                       lgal[k]=l
                       vt,l,dpc,wbb
                       Vtdpc[k]=dpc
                       Vtwbb[k]=wbb
                       k=k+1
endfor                     
;
for i=0,npts-1 do begin
    DV[i]=Vtwbb[i]-Vtdpc[i]
    print,lgal[i],Vtdpc[i],Vtwbb[i],DV[i],format='(4f8.1)'
endfor
;
xtitle='Lgal (deg)'
ytitle='Vt (km/sec)'
clr=!white
plot,lgal,Vtdpc,thick=2.0,linestyle=0,xtitle=xtitle,ytitle=ytitle, $
     color=clr,xrange=[10.,60.],yrange=[30.,160.],/xstyle,/ystyle
dv[0:npts-1]=0.
oplot,lgal,Vtwbb,thick=2.0,linestyle=2
;
;xtitle='Lgal (deg)'
;ytitle='Vt(WBB) - Vt(DPC) (km/sec)'
;clr=!white
;plot,lgal,DV,thick=2.0,linestyle=0,xtitle=xtitle,ytitle=ytitle, $
;     color=clr,xrange=[10.,60.],yrange=[-15.,25.],/xstyle,/ystyle
;dv[0:npts-1]=0.
;oplot,lgal,dv,thick=2.0,linestyle=2
;
return
end
