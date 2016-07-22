pro g, info=info, help=help
;+
; NAME:
;       G
;
;       ==============================
;       SYNTAX: g, info=info,help=help
;       ==============================
;
;  KEYWORDS:
;           /info if set plots the fit parameter values 
;                 default is to just plot the fit
;
;           /help if set gives help
;
;   g   Multiple gaussian fit to !b[0].data  
;   -  
;       Routine hardwired to fit gaussians with all initial values preset.
;       Presumably this is done via 'gg, #gaussians_to_fit' 
;       Another approach would be to use the HISTORY via 
;       history <=> rehash 
;
;       The gaussian h,c,w values for each component are in !a_gauss and
;       The fitting regions is delimited by !bgauss and !egauss
;
;-
; MODIFICATION HISTORY
; V5.0 July 2007
; modified 16Aug07 to force FWHM to be positive
; 12Dec07 tmb modified to work with backwards slewing continuum scans
;             L60
; 31Mar08 tmb fixed bug above for continuum backward scans in CHANnel mode
; 26jul08 tmb added capability of holding fixed arbitrary Gaussian
;              components using the 'parinfo' keword of 'mpcurvefit'
;
;  ===>  FIXED GAUSSIAN PACKAGE EXAMPLE: fix a parameter value for a single Gaussian
;
; 07Jan09 tmb modified velocity width calculation to use sky rather than rest frequency  
;
; V6.0 June 2009  yet to be modified to deal with freq/velocity axis flip 
;    26 jun 2009 - dsb modified to accomodate backwards velocity or frequency scans
;    22 Sep 2009 - dsb plot residuals over the bgauss-egauss range as in gg.pro
;
; V6.1 March 2010 tmb tweaked for seamless PS print output
;
; V6.1 march 2010 tmb tweaked for seamless PS handling
;                     added no_annotate keyword to suppress
;                     plotting the Gaussian fit parameters
;
;            Syntax: g,/no will suppress plotting fit parameters  
;            =============
;
; 18may2012 tmb  inverted functionality to make NO PLOT ANNOTATION THE DEFAULT
;           keyword /no_annotate eliminated and keyword /info added 
;
; V7.0 3may2013 tvw - added /help, !debug
;     27jun2013 tmb - fixed bug that gave kHz and km/sec for modes other than CHAN
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if Keyword_Set(help) then begin & get_help,'g' & return & end
;
@CT_IN
;
def_xaxis                ;   determine x-axis units
;
case !clr of 
       1: begin & clr1=!red & clr2=!orange & clr3=!yellow & end
    else: begin 
          clr1=!d.name eq 'PS' ? !black : !white
          clr2=!d.name eq 'PS' ? !black : !white
          clr3=!d.name eq 'PS' ? !black : !white
          end
endcase
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
a=fltarr(3*!ngauss)
a=!a_gauss[0:3*!ngauss-1]
sigmaa=fltarr(!ngauss*3)
;  fill the par_info structure
par_info=!parinfo[0:3*!ngauss-1]
;  
;  restrict range to !bgauss-!egauss
if !bgauss gt !egauss then begin
                      hold = !bgauss
                      !bgauss = !egauss
                      !egauss = hold
                      endif
junk=where(gauss_x lt !bgauss, bpix) ; returns # locations in gauss_x to bpix
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
if !b[0].delta_x gt 0.0 and !velo eq 1 then begin
    cbpix=(n_elements(!xx)-1)-bpix & cepix=(n_elements(!xx)-1)-epix
    if cbpix gt cepix then begin
        hold =cbpix
        cbpix=cepix
        cepix=hold
    endif
    bpix=cbpix & epix=cepix
endif
; adjust if frequency scale is inverted for line data
if !b[0].delta_x lt 0.0 and !freq eq 1 then begin
    cbpix=(n_elements(!xx)-1)-bpix & cepix=(n_elements(!xx)-1)-epix
    if cbpix gt cepix then begin
        hold =cbpix
        cbpix=cepix
        cepix=hold
    endif
    bpix=cbpix & epix=cepix
endif

;
;  fit the gaussians to the data: 'curvefit' is IDL   'mpcurvefit' is Markwardt
;
;yfit=curvefit(gauss_x(bpix:epix),gauss_y(bpix:epix),$
;              weightf,a,sigmaa,function_name="mgauss",$
;              /double,itmax=100)
; 
yfit = mpcurvefit(gauss_x[bpix:epix],gauss_y[bpix:epix],$
                  weightf,a,sigmaa,function_name="mgauss",$
                  parinfo=par_info,chisq=chisq,itmax=1000,/quiet)
;
dof=n_elements(gauss_x[bpix:epix]) - n_elements(a)  ; deg of freedom
csigma=fltarr(!ngauss*3)
csigma=sigmaa * sqrt(chisq / dof)                   ; scaled uncertainties
sigmaa=csigma
!g_sigma[0:!ngauss*3-1]=csigma  ; copy to system variable
;
yfit=fltarr(n_elements(gauss_x))
;
; 
if !flag then begin
              print,"G#       Height +/- sigma    Center +/- sigma"+ $
                    "      FWHM +/- sigma  ==>  kHz       km/sec"
              print
              end
;
!xval_per_chan=abs(!b[0].delta_x)/1.0d+3 ; kHz
;
clr=!red
get_clr,clr
;
for i=0,!ngauss-1 do begin
                  h=a[i*3+0]
                  c=a[i*3+1]
                  w=abs(a[i*3+2])
                  fw=w*!xval_per_chan                      ; width in kHz
                  vw=(fw*1.0d+3*!light_c)/!b[0].sky_freq  ; width in km/sec 
                  if !chan ne 1 then begin & fw=0.0 & vw=0.0 & endif
                  sh=sigmaa[i*3+0]
                  sc=sigmaa[i*3+1]
                  sw=sigmaa[i*3+2]
                  ycomp=h*exp(-4.0*alog(2)*(gauss_x-c)^2/w^2)
                  yfit=yfit+ycomp
;                  oplot,gauss_x,ycomp,thick=0.5,color=clr
;
                  if !flag then begin
                                print,i+1,h,sh,c,sc,w,sw,fw,vw, $
                                      format='(i3,1x,4(f11.3,2x,f8.3))'
                                end
                  endfor
                  if !flag then begin
                           if !chan eq 1 then print,'Center/FWHM in channels'
                           if !freq eq 1 then print,'Center/FWHM in frequency (kHz)'
                           if !velo eq 1 then print,'Center/FWHM in LSR velocity (km/sec)'
                           if (!azxx eq 1) or (!elxx eq 1) or (!raxx eq 1) or (!decx eq 1) $
                                         then print,'Center/FWHM in arcseconds'   
                                end
;
case !LINE of  ; LINE mode
              1:begin
                !b[1].data=yfit
                !b[1].line_id=byte('GMODEL')
                clr=clr1
                get_clr,clr1
                oplot,!xx,yfit,thick=1.5,color=clr1
;
                !b[8].data=gauss_y-yfit
                !b[8].line_id=byte('RESIDUAL')
                if !flag then begin
                   clr=clr2
                   get_clr,clr2
;                   oplot,gauss_x,gauss_y-yfit,thick=0.5,color=clr2 ; tmb version
                   oplot,gauss_x[bpix:epix],gauss_y[bpix:epix]-yfit[bpix:epix],thick=0.5,color=clr    
                endif
                end
               ; CONTinuum mode
              0:begin
                !b[1].data[0:!c_pts-1]=yfit
                !b[1].line_id=byte('GMODEL')
                clr=clr1
                get_clr,clr1
                oplot,!xx,yfit,thick=1.5,color=clr1
;
                !b[8].data[0:!c_pts-1]=gauss_y-yfit
                !b[8].line_id=byte('RESIDUAL')
                if !flag then begin
                    clr=clr3
                    get_clr,clr3
;                    oplot,gauss_x,gauss_y-yfit,thick=0.5,color=clr3 ; tmb version
                     oplot,gauss_x[bpix:epix],gauss_y[bpix:epix]-yfit[bpix:epix],thick=0.5,color=clr
                endif
                end
endcase
;
!a_gauss[0:3*!ngauss-1]=a
if Keyword_Set(info) then pltg
;
@CT_OUT
return
end


