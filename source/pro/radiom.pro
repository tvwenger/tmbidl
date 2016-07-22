pro radiom,nfit,help=help
;+
; NAME:
;       RADIOM
;
;            =======================================
;            Syntax: radiom, nfit,help=help
;            =======================================
;
;   radiom   For STACK contents fit nfit order baseline to
;   ------   previously defined NREGIONs and calculate the 
;            rms vs integration time.
;            Pop Up a new graphics window and plot the
;            radiometer equation.
;            =>  RUN THIS PROCEDURE WITH X-AXIS IN CHANNELS
;                rms values with theoretical ones calculated via TH_RMS.
;            =>  Return window state via WRESET command
;-
; V5.0  July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'radiom' & return & endif
;
; check to see if NREGIONs are set
if !nrset eq 0 then begin
                    print,'Error: Must set NREGIONs before invoking RADIOM'
                    return
                    end
;
deja_vu=!deja_vu     ;  suppress AVE messages
!deja_vu=0
flag=!flag
!flag=0
;
window,4,title='Radiometer Equation for STACK Contents',xsize=1050,ysize=600
;  
!p.position=[0.13,0.15,0.93,0.95]     ;  !p.position=[xmin,ymin,xmax,ymax]
;
if (n_params() eq 0) then begin
                          print,'Error: Must input order of baseline fit'
                          print,'Syntax: radiom,order_of_polynomial_to_fit'
                          return
                      end
;
;  STACK contents defines plot axes
;
x_tintg = fltarr(!acount)
y_rms   = fltarr(!acount)
tsys    = fltarr(!acount)
;
; initialize with first element of STACK 
;
       fetch,abs(!astack[0])
       scale,1.0e+3                     ; scale to milliKelvin
;
       mask,dsig,index                  ;  get index of NREGION mask channels and sigma 
;
       xx=dblarr(n_elements(index))     ; data arrays for fit in double precision 
       yy=dblarr(n_elements(index))
;
       xx=!xx[index]                    ; fill these arrays with the relevant data 
       yy=!b[0].data[index]
;
       rms  =dblarr(nfit)               ; rms array holds Lyon's rms for every order of a
;                                       ; *single* baseline fit... 
;
       fitcoeffs=ortho_fit(xx,yy,nfit,cfit,rms)   ; baseline fit routine
;
       print
       print,'RMS in NREGIONs before any fit = ', dsig,$
             ' for ',n_elements(index),' channels',$
             format='(a,f12.6,a,i5,a)'
             print,'RMS in NREGIONs after nfit='+fstring(nfit,'(i2)'),rms[nfit]
;
;  first element
;
x_tintg[0] = !b[0].tintg/60.      ; integration time in minutes
y_rms[0]   = rms[nfit]
;
rms0=rms[nfit]
tintg0=!b[0].tintg/60.
tsys0=!b[0].tsys
tsys[0]=tsys0
;
for i=1, !acount-1 do begin       ; now calculate the rms
;
         for j=0,i do begin
               fetch,abs(!astack[j])
               accum
         endfor
;
    ave
    scale,1.0e+3                   ; in milliKelvins
    yy=!b[0].data[index]
;
    fitcoeffs=ortho_fit(xx,yy,nfit,cfit,rms) 
;
    x_tintg[i] = !b[0].tintg/60.
    y_rms[i]   = rms[nfit]
    tsys[i]    = !b[0].tsys
; 
endfor
;
;   fetch the theoretical radiometer equation
;
t_sys=!b[0].tsys*1000.         ; Tsys in milliKelvins
npol=2.d                       ; number of polarizations or independent signals
df=abs(!b[0].delta_x)
k1=9                           ; backend sampling          9 -> 9-level
;                                                          3 -> 3-level
;
k2=1                           ; correlator weighting      1 -> uniform
;                                                          2 -> Hanning
;
xmin=min(x_tintg) & xmax=max(x_tintg) &
time_x=fltarr(500) & rms_y=fltarr(500) & no_pts=500 &
;
th_rms,t_sys,df,npol,k1,k2,xmin,xmax,no_pts,time_x,rms_y
;
; th_rms returns arrays time_x in minutes and rms_y in milliKelvins
;
;  calculate the Q factor : Q = (rms/rms0) (Tsys0/Tsys) sqrt(tintg/tintg0)
;
q=(y_rms/tsys)*sqrt(x_tintg)
fact=(tsys0/rms0)*(1./sqrt(tintg0))
q=q*fact
q[0]=1.000  ; by definition
;
print
print,'Calculated Radiometer Equation using NFIT= '+fstring(nfit,'(i3)')
print
print,'      Tintg   RMS      Q     Tsys'
print,'      (min)   (mK)            (K)' 
;
for i=0,!acount-1 do print,i,x_tintg[i],y_rms[i], q[i], tsys[i], $
                           format='(i3,1x,f7.0,2(1x,f7.3),1x,f5.1)'
;
;
; plot rms vs tintg
;
xmin=min(x_tintg)*0.90  & xmax=max(x_tintg)*1.10 &
ymin=min(y_rms)*0.90  &  ymax=1.05*dsig  &
;
syms,4,2,1            ; set a custom symbol
;
plot,x_tintg,y_rms,/xstyle,/ystyle, $
     xrange=[xmin,xmax],yrange=[ymin,ymax],$
     title='RADIOMETER EQUATION',$
     xtitle='Integration Time (minutes)',$
     ytitle='RMS (milliKelvin)', $
     charthick=2.0,charsize=1.5,thick=2.0, psym=8     
oplot,time_x,rms_y,color=!red,thick=2.0
;
qqq='NFIT = ' + fstring(nfit,'(i2)')      
xyouts,.25,.96,qqq,/normal,charsize=2.5,charthick=2.5,color=!cyan

hline,dsig
;
print,'Enter <CR> to continue'
ans=get_kbrd(1)
;
;   plot log rms vs log tintg
;
xmin=alog10(min(x_tintg)*0.95)  & xmax=alog10(max(x_tintg)*1.10) &
ymin=alog10(min(y_rms)*0.90)    &  ymax=alog10(1.05*dsig)  &
;
syms,4,2,1            ; set a custom symbol
;
plot,alog10(x_tintg),alog10(y_rms),/xstyle,/ystyle, $
     xrange=[xmin,xmax],yrange=[ymin,ymax],$
     title='RADIOMETER EQUATION',$
     xtitle='log Integration Time [min]',$
     ytitle='log RMS [mK]', $
     charthick=2.0,charsize=1.5,thick=2.0, psym=8     
oplot,alog10(time_x),alog10(rms_y),color=!red,thick=2.0
xyouts,.25,.96,qqq,/normal,charsize=2.5,charthick=2.5,color=!cyan
;
hline,alog10(dsig)
;
print,'Enter <CR> to continue'
ans=get_kbrd(1)
;
;   now do it in Q space:  Q vs tintg
;
xmin=min(x_tintg)*0.95  & xmax=max(x_tintg)*1.05 &
ymin=0.9 & ymax=1.1 &
;
syms,4,2,1            ; set a custom symbol
;
plot,x_tintg,q,/xstyle,/ystyle, $
     xrange=[xmin,xmax],yrange=[ymin,ymax],$
     title='RADIOMETER EQUATION',$
     xtitle='Integration Time [min]',$
     ytitle='Q = (RMS/Tsys) sqrt(Time)', $
     charthick=2.0,charsize=1.5,thick=2.0, psym=8  
xyouts,.25,.96,qqq,/normal,charsize=2.5,charthick=2.5,color=!cyan
;
hline,1.00
;
print,'Enter "q" to return to normal graphics'
ans=get_kbrd(1)
if (ans eq 'q') then wreset
;
!deja_vu=deja_vu                    ; return to initial state
!flag=flag
;
@CT_OUT
return
end
