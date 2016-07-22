;+
; NAME:
;       GG
;
;            =============================================
;            Syntax: gg, #_gaussian_components_to_fit
;
;            Click: bgauss #_gauss(center,hw_right) egauss
;            =============================================
;
;   gg   Multiple gaussian fit to !b[0].data
;   --   MUST remove a baseline first

;        if FLAGON (!flag=1) then overplot the residual=data-fit
;
; V5.0 July 2007 tmb continuum modified version
;                    added new overplot to show bgauss, egauss region
; modified 16Aug07 to make sure FWHM always positive
; 12Dec07 tmb modified to work with backwards slewing continuum scans
;             L100
; 31Mar08 tmb fixed bug in above for CHAN mode x-axis
; 07Jan09 tmb modified velocity width calculation to use sky rather
;             than rest frequency: both GBT and Arecibo send same
;             sky freq no matter what...
; 25 Feb 2009 - dsb modified to accomodate backwards velocity or frequency scans
;-
pro gg,ngauss   ; ngauss = # gaussian components to fit 
;
on_error,!debug ? 0 : 2
compile_opt idl2
@CT_IN
;
clr1=!magenta
clr2=!orange   
clr3=!yellow
;
!except=0       ; turn off underflow messages (and, alas, *all* math errors)
;
if (n_params() eq 0) then begin
                     print,'Useage: gg,#_gaussian_components_to_fit'
                     return
                     endif
;
def_xaxis                ;   determine x-axis units
;
;
case !LINE of 
              1:begin              ; LINE data
                gauss_x=!xx        ; assumes spectrum is in buffer 0 
                gauss_y=!b[0].data ; x-axis set to current x-axis units 
                end                ; i.e. it uses y-axis from last SHOW 
                                   ; but supercedes x-axis to channels
              0:begin              
                gauss_x=!xx[0:!c_pts-1]          ; CONTINUUM
                gauss_y=!b[0].data[0:!c_pts-1] ; must mask 
                end
endcase 
;
copy,0,2                 ;   copy buffer 0 to buffer 2 just in case...
copy,0,1                 ;   buffer 1 holds the GMODEL (gfit)
copy,0,8                 ;   buffer 8 holds the data-model difference
;
!ngauss=ngauss
a=fltarr(!ngauss*3)
sigmaa=fltarr(!ngauss*3)
;
iflag=!flag              ;   supress cursor positioning information
!flag=0
;
print,"Click: bgauss #_gauss(center,hw_right) egauss"
       ccc,x,y
       idchan,x,xchan
       !bgauss=!xx[xchan]
;
       for i=0,!ngauss-1 do begin 
           ccc,x,y                              ;     
           idchan,x,xchan
           c=!xx[xchan]                              ; flag center position
           h=!b[0].data[xchan]                  ; peak y_value is at center = c
           ccc,x,y                              ; flag half-width position on right side
           idchan,x,hw
           w=abs(2*(!xx[hw]-c))
           a[i*3+0]=h
           a[i*3+1]=c
           a[i*3+2]=w
        endfor
;
        ccc,x,y       
        idchan,x,xchan
        !egauss=!xx[xchan]
;
;  restrict range to bgauss-egauss
if !bgauss gt !egauss then begin
                      hold = !bgauss
                      !bgauss = !egauss
                      !egauss = hold
                 endif
;
junk=where(gauss_x lt !bgauss, bpix)
junk=where(gauss_x lt !egauss, epix)
weightf=fltarr(epix-bpix+1)+1.0      ; weight 1.0 in mask region
;
; need to deal with backwards continuum scans
;
typ=strtrim(string(!b[0].scan_type),2) & typ=strmid(typ,0,1)
;  flip positions for backwards continuum scans 
;  *unless* we are in CHAN mode in X-axis display...
if typ eq 'B' and !chan ne 1 then begin
              cbpix=!c_pts-bpix & cepix=!c_pts-epix
              if cbpix gt cepix then begin
                                hold =cbpix
                                cbpix=cepix
                                cepix=hold
                           endif
              bpix=cbpix & epix=cepix
endif
; adjust if velocity scale is inverted for line data
if (!b[0].delta_x gt 0.0) and (!velo eq 1) then begin
    cbpix=(n_elements(!xx)-1)-bpix & cepix=(n_elements(!xx)-1)-epix
    if cbpix gt cepix then begin
        hold =cbpix
        cbpix=cepix
        cepix=hold
    endif
    bpix=cbpix & epix=cepix
endif
; adjust if frequency scale is inverted for line data
if (!b[0].delta_x lt 0.0) and (!freq eq 1) then begin
    cbpix=(n_elements(!xx)-1)-bpix & cepix=(n_elements(!xx)-1)-epix
    if cbpix gt cepix then begin
        hold =cbpix
        cbpix=cepix
        cepix=hold
    endif
    bpix=cbpix & epix=cepix
endif


;
;  fit the gaussians to the data;  'curvefit' is IDL   'mpcurvefit' is Markwardt
;
;yfit=curvefit(gauss_x(bpix:epix),gauss_y(bpix:epix),$
;              weightf,a,sigmaa,function_name="mgauss",$
;              chisq=chi,/double,itmax=200)
;
yfit = mpcurvefit(gauss_x[bpix:epix],gauss_y[bpix:epix],$
                  weightf,a,sigmaa,function_name="mgauss",$
                  chisq=chisq,itmax=500,quiet=1)
;
dof=n_elements(gauss_x[bpix:epix]) - n_elements(a)  ; deg of freedom
csigma=fltarr(!ngauss*3)
csigma=sigmaa * sqrt(chisq / dof)                   ; scaled uncertainties
sigmaa=csigma
!g_sigma[0:!ngauss*3-1]=csigma   ;  gaussian fit errors to system variable
;
yfit=fltarr(n_elements(gauss_x))
;
print
print,"G#       Height +/- sigma     Center +/- sigma       FWHM +/- sigma"+ $
      "   ==>     kHz        km/sec"
;
!xval_per_chan=abs(!b[0].delta_x)/1.0d+3 ; kHz;
;
for i=0,!ngauss-1 do begin
                  h=a[i*3+0]      ; in current y-axis units
                  c=a[i*3+1]      ; in current x-axis units
                  w=abs(a[i*3+2]) ; in current x-axis units
;                           code below is wrong for km/sec x axis
                  fw=w*!xval_per_chan                      ; width in kHz
                  vw=(fw*1.0d+3*!light_c)/!b[0].sky_freq  ; width in km/sec 
                  sh=sigmaa[i*3+0]
                  sc=sigmaa[i*3+1]
                  sw=sigmaa[i*3+2]
                  ycomp=h*exp(-4.0*alog(2)*(gauss_x-c)^2/w^2)
                  yfit=yfit+ycomp
;                 oplot,gauss_x,ycomp,thick=0.5,color=clr1
                  print,i+1,h,sh,c,sc,w,sw,fw,vw, $
                        format='(i2,1x,4(f11.3,1x,f11.3))'
                   endfor
;
if (!chan eq 1) then print,'Center/FWHM in channels'
if (!freq eq 1) then print,'Center/FWHM in frequency (kHz)'
if (!velo eq 1) then print,'Center/FWHM in LSR velocity (km/sec)'
if (!vgrs eq 1) then print,'Center/FWHM in LSR velocity (km/sec)'
if ( (!azxx eq 1) or (!elxx eq 1) or (!raxx eq 1) or (!decx eq 1) ) $
                then print,'Center/FWHM in arcseconds'   
;
!flag=iflag   ;  reset !iflag to input value
;
case !LINE of  ; LINE mode
              1:begin
                !b[1].data=yfit
                !b[1].line_id=byte('GMODEL')
                get_clr,clr1      ; determine CLR or BW plot
                oplot,!xx,yfit,thick=2.0,color=clr1
;
                !b[8].data=gauss_y-yfit
                !b[8].line_id=byte('RESIDUAL')
                if (!flag) then begin
                    get_clr,clr2
                    fit_x=gauss_x[bpix:epix]
                    res_y=gauss_y[bpix:epix]-yfit[bpix:epix]
                    oplot,fit_x,res_y,thick=0.5,color=clr2
;                    oplot,gauss_x,gauss_y-yfit,thick=0.5,color=clr2
                    end
                end
               ; CONTinuum mode
              0:begin
                !b[1].data[0:!c_pts-1]=yfit
                !b[1].line_id=byte('GMODEL')
                get_clr,clr1      ; determine CLR or BW plot
                oplot,!xx,yfit,thick=2.0,color=clr1
;
                !b[8].data[0:!c_pts-1]=gauss_y-yfit
                !b[8].line_id=byte('RESIDUAL')
                if (!flag) then begin
                    get_clr,clr2
                    fit_x=gauss_x[bpix:epix]
                    res_y=gauss_y[bpix:epix]-yfit[bpix:epix]
;                    oplot,gauss_x,gauss_y-yfit,thick=0.5,color=clr2
                    oplot,fit_x,res_y,thick=0.5,color=clr2
                    end
                end
endcase
;
mask,dsig
print
print,'RMS in NREGIONs = ', dsig
print
;
; overplot the data inside !bgauss,!egauss in !blue
;
fit_x=gauss_x[bpix:epix]
fit_y=gauss_y[bpix:epix]
;oplot,fit_x,fit_y,thick=2.0,color=clr3
;
;
!except=1                  ; return math error flag to default
;
!a_gauss[0:3*!ngauss-1]=a
pltg
;
@CT_OUT
return
end


