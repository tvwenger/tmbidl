pro vlos,lgal,help=help,ps=ps,curve=curve,multi=multi,flag=flag,$
         dlos=dlos,vlsr=vlsr,rmax=rmax,dx=dx,noplot=noplot,$
         ymin=ymin,ymax=ymax,yscale=yscale
;+
; NAME:
;       VLOS
;
;    ===================================================================
;    Syntax: vlos,lgal,help=help,ps=ps,curve=curve,multi=multi,flag=flag,$
;                 dlos=dlos,vlsr=vlsr,rmax=rmax,dx=dx,noplot=noplot,$
;                 ymin=ymin,ymax=ymax,yscale=yscale
;    ===================================================================
;
;   vlos  calculate and plot the LSR velocity, vlsr, vs line of sight
;   ----  distance, dlos, for input galactic longitude, lgal, in degrees
;         assumes bgal=0.degrees
;         Works for any lgal. 
;
;   KEYWORDS:
;             HELP  switch to return Command Syntax 
;             PS    switch to generate PostScript output 
;             CURVE specify rotation curve:
;                   0 = Brandt/Burton [default]
;                   1 = Clemens
;                   2 = McClure-Griffiths
;             MULTI plot all three curves 
;             FLAG  flags the terminal velocity its LOS distance
;             DLOS  filled with the line of sight distance
;             VLSR  filled with the line-of-sight LSR velocity
;                    - NOTE: the above two keywords only get filled
;                            with the 'final curve. suggest not to
;                            use with MULTI
;             RMAX  max galactocentric distance to use [kpc] (default 12. kpc)
;             DX    los distance interval [kpc] (default 0.1 kpc)
;             VMIN  minimum LSR velocity to plot (default  -50 km/s)
;             VMAX  maximum LSR velocity to plot (default +150 km/s)
;           YSCALE  use the velocity range itself to define y-axis
;                   scaling to be YMIN-10 to YMAX+10
;-
; MODIFICATION HISTORY:
; 3 april  2011  TMB 
; 14 april 2012  tvw - added dlos,vlsr keywords. allows to be wrapped by los.pro
;                    - added RMAX,DX. more wrapping ease
; 25 march 2013  tvw - catch negative RMAX
;  5 may   2013  tmb - extended y-axis range (V_lsr) to work for any Lgal
;  6 may   2013  tmb - added KeyWords YMIN YMAX and YSCALE
;-
;

compile_opt idl2  ; compile with long integers 
on_error,!debug ? 0 : 2
;
if Keyword_Set(help) or n_params() eq 0 then begin
   get_help,'vlos'
   return
endif

;  test for lgal = 0.0 degrees which has LSR velocity 0.0 always 
;
if lgal eq 0.0 then begin
   print,'Galactic longitude 0 degrees has LSR velocity 0.0 always !'
   return
endif
;
if ~keyword_set(rmax) then rmax=12.d
if rmax le 0.0 then begin
   print,'Error: RMAX needs to be greater than 0.0'
   return
endif
if ~keyword_set(dx)   then dx  =0.1d 
;
if lgal lt 0.0 then lgal=360.0+lgal ; turn negative lgals's into positive 
;
;  KeyWord 'ps' for PostScript output
;
if ~Keyword_Set(curve) then curve=0 ; Brandt/Burton curve default
;
if Keyword_Set(multi)  then nplot=3 else nplot=1
;
;color=!red
case !clr of  ; take care of PostScript 
             1: clr=!red
          else: clr=!d.name eq 'PS' ? !black : !white
endcase
;
bgal=0. ; galactic longitude assumed to be zero
; galactic longitude in radians for trig functions
cl=cos(lgal*!dtor) & sl=sin(lgal*!dtor) 
;
R0=8.5d            ;  GC distance kpc
Theta0=220.        ;  Solar Orbital speed km/s
Omega0=Theta0/R0   ;  Solar Angular Velocity km/s/kpc
Rt=R0*sl           ;  Rmin, galactocentric tangent point kpc
;
dmax=R0+rmax
;
rmin=0.d
dnpts=dmax/dx & dnpts=dnpts+1 ; number of los positions 
;
; define arrays 
;
dlos=dblarr(dnpts) ; line of sight distances
for i=0,dnpts-1 do begin & dlos[i]=dx*double(i) & endfor
vlsr=dblarr(dnpts) ; LSR velocities
;
; loop for multiple plots
;
for k=0,nplot-1 do begin & if Keyword_Set(multi) then curve=k
   ;
   ; calculate Vlsr vs Dlos
   ;
   for i=0,dnpts-1 do begin
      d=dlos[i] 
      R=sqrt(d*d+R0*R0-2.*d*R0*cl) ; Galactocentric distance of dlos
      ;   pick the rotation curve
      case curve of
         0: rotcurv_wbb,R,Theta
         1: rotcurv_dpc,R,Theta
         2: rotcurv_nmg,R,Theta ; BEWARE valid only for 3<Rgal<8kpc
      else: begin & print,'Invalid Rotation Curve !' & return & end
      endcase
   ;
      omega=Theta/R 
      vlsr[i]=Rt*(Omega-Omega0) ; LSR velocity at this R
      if lgal le 0. then vlsr[i]=-vlsr[i]
   endfor
   ;
   if keyword_set(noplot) then return
   ;
   ; now make plots
   ;
   if ~KeyWord_Set(ymin) then ymin=-50.
   if ~KeyWord_Set(ymax) then ymax=150.
   if  KeyWord_Set(yscale) then begin
       ymin=min(vlsr,max=ymax) & ymin=ymin-10. & ymax=ymax+10. 
   endif
;
   if ~keyword_set(ps) then begin
      device,window_state=win_state
      if win_state[19] eq 1 then wset,19 else window,19,xsize=600,ysize=400,title="Line of Sight Rotation Curve"
   endif else printon,'rotationcurve'
   xtitle='Distance from Sun [kpc]' 
   ytitle='LSR Velocity [km/sec]'
   ;
   case k of 
      0: plot,dlos,vlsr,xrange=[0,dmax],/xstyle,yrange=[ymin,ymax],/ystyle, $
              title=title,xtitle=xtitle,ytitle=ytitle,charsize=1.5
      1: oplot,dlos,vlsr,linestyle=1
      2: oplot,dlos,vlsr,linestyle=2
   else: begin & print,'multiple error' & return & end
   endcase
   ;
   ; end multiple plot loop
endfor
;
;  plot zero velocity
;   pline,0.,0.,rmax,0.
plots,0.,0. & plots,dmax,0.,/continue
;  annotate
title='Galactic Longitude = + '
slgal=fstring(lgal,'(f6.1)')
title=title+slgal+' degrees'
xyouts,0.15,0.85,title,/normal,charsize=2.
;
;time=systime()
;xyouts,0.7,0.025,time,/normal,charsize=1.5
;
if ~Keyword_Set(multi) then begin
   case curve of
              0: clabel='Brandt Rotation Curve'
              1: clabel='Clemens Rotation Curve'
              2: clabel='McClure-Griffiths Rotation Curve'
           else: clabel='You should never see this'
   endcase
   xyouts,0.72,0.82,clabel,/normal,charsize=1.5
endif
;
if Keyword_Set(multi) then begin
   lineitems=['Brandt','Clemens','McClure-Griffiths']
   linestyle=[0,1,2]
   legend,lineitems,linestyle=linestyle,/norm,pos=[0.6,0.9],charsize=2.0           
end
;
if Keyword_Set(flag) then begin
;
;  get tangent point vtan and dlos 
;  use Brandt curve for multi-plots
if Keyword_Set(multi) then curve=0
   case curve of
       0: rotcurv_wbb,Rt,Theta
       1: rotcurv_dpc,Rt,Theta
       2: rotcurv_nmg,Rt,Theta ; BEWARE valid only for 3<Rgal<8kpc
   else: begin & print,'Invalid Rotation Curve !' & return & end
   endcase
   dtan=R0*cl & flag,dtan 
   Omega=Theta/RT & vtan=RT*(Omega-Omega0) & hline,vtan
endif
; 
if Keyword_Set(ps) then begin & clr & printoff & end
;
return
end
