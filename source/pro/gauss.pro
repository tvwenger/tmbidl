pro gauss,help=help
;+
; NAME:
;      GAUSS
;      gauss,help=help
;
;   gauss,pro   full-blown, walk through it all code to fit multiple Gaussians
;   ---------   MUST subtract a baseline first
;               modified by t.m.bania from astrolib? code
;               Uses 'mpcurvefit' from Markwardt for curve fitting.
; 
;              "Options:"
;              "(q) exit
;              "(s) set initial parameters"
;              "(d) clear and start again"
;              "(f) fit"
;
;              'Enter number of Gaussians:'
;              "Click on range to fit: bgauss,egauss"
;              
;               For each component to fit:
;              "Gaussian"
;              "     Click on center" 
;              "     Click on FWHM points"
;              
;              assumes intensity at center guess for initial fit
;
; V5.0 July 2007
; 12Dec07 tmb modified to work with backwards slewing continuum scans
;             L120
; 31Mar08 tmb fixed bug in above modification to deal with backwards
;             continuum scans in CHANnel mode
; V7.0 3may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'gauss' & return & endif
@CT_IN
;
def_xaxis                ;   determine x-axis units
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
                         ;   it expects to work on the data displayed by
                         ;   the last SHOW command
copy,0,2                 ;   copy buffer 0 to buffer 2 just in case...
copy,0,1                 ;   buffer 1 holds the GMODEL (gfit)
copy,0,8                 ;   buffer 8 holds the data-model difference
;
choice='y'
ngauss=1
clr=!cyan
get_clr,clr
;
while choice ne 'q' do begin
     print,"Options:"
     print,"(q) exit"
     print,"(s) set initial parameters"
     print,"(d) clear and start again"
     print,"(f) fit"
;
     choice=get_kbrd(1) ; this is how one fetches a single character from the keyboard
;
     case choice of

     's': begin

             read,ngauss,prompt='Enter number of Gaussians:'

             print,"Click on range to fit: bgauss,egauss"
             ccc,x,y
             oplot,[x],[y],PSYM=7,color=clr
             idchan,x,xchan
             !bgauss=!xx[xchan]
             ccc,x,y
             oplot,[x],[y],PSYM=7,color=clr
             idchan,x,xchan
             !egauss=!xx[xchan]
             !ngauss=ngauss
;
             a=fltarr(!ngauss*3)
             a=!a_gauss[0:3*!ngauss-1]
             sigmaa=fltarr(!ngauss*3)
             
             for i=0,ngauss-1 do begin
                print,"Gaussian",i
                print,"     Click on center"
                ccc,x,y
                oplot,[x],[y],PSYM=7,color=clr
                idchan,x,xchan
                c=!xx[xchan]
;               assume peak is at center
                h=!b[0].data[xchan]
                print,"     Click on FWHM points"
                ccc,x1,y
                idchan,x1,xchan1
                oplot,[x1],[y],PSYM=7,color=clr
                ccc,x2,y
                idchan,x2,xchan2
                oplot,[x2],[y],PSYM=7,color=clr
                w=!xx[abs(xchan2-xchan1)]
                a[i*3+0]=h
                a[i*3+1]=c
                a[i*3+2]=w
            end

            ;  restrict range to bgauss-egauss
            if !bgauss gt !egauss then begin
               hold = !bgauss
               !bgauss = !egauss
               !egauss = hold
            endif
            junk=where(gauss_x lt !bgauss, bpix)
            junk=where(gauss_x lt !egauss, epix)
            weightf=fltarr(epix-bpix+1)+1.0      ; weight 1.0 in mask region
;
;           need to deal with backwards continuum scans
;
            typ=strtrim(string(!b[0].scan_type),2) 
            typ=strmid(typ,0,1)
;  flip positions for backwards continuum scans 
;  *unless* we are in CHAN mode in X-axis display...
            if typ eq 'B' and !chan ne 1 then begin
                          cbpix=!c_pts-bpix 
                          cepix=!c_pts-epix
                          if cbpix gt cepix then begin
                                            hold =cbpix
                                            cbpix=cepix
                                            cepix=hold
                          endif
            bpix=cbpix & epix=cepix
            endif
        end     

    'f': begin
       ; fit the gaussians to the data;  'curvefit' is IDL   'mpcurvefit' is Markwardt
;              yfit=curvefit(gauss_x(bpix:epix),gauss_y(bpix:epix),$
;                            weightf,a,sigmaa,function_name="mgauss",$
;                            /double,itmax=100)
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
                 vw=(fw*1.0d+3*!light_c)/!b[0].rest_freq  ; width in km/sec 
                 sh=sigmaa[i*3+0]
                 sc=sigmaa[i*3+1]
                 sw=sigmaa[i*3+2]
                 ycomp=h*exp(-4.0*alog(2)*(gauss_x-c)^2/w^2)
                 yfit=yfit+ycomp
                 oplot,gauss_x,ycomp,thick=0.5,color=clr
;
                 print
                 print,i,h,sh,c,sc,w,sw,fw,vw, $
                       format='(i2,1x,4(f11.3,1x,f11.3))'
                 print
         end
;
             if !chan eq 1 then print,'Center/FWHM in channels'
             if !freq eq 1 then print,'Center/FWHM in frequency (kHz)'
             if !velo eq 1 then print,'Center/FWHM in LSR velocity (km/sec)'
             if !azxx eq 1 or !elxx eq 1 or !raxx eq 1 or !decx eq 1 $
                           then print,'Center/FWHM in arcseconds'   
;
             !flag=iflag   ;  reset !iflag to input value
;
                case !LINE of  ; LINE mode
                     1:begin
                       !b[1].data=yfit
                       !b[1].line_id=byte('GMODEL')
                       clr=!red
                       get_clr,clr
                       oplot,!xx,yfit,thick=1.5,color=clr
;
                       !b[8].data=gauss_y-yfit
                       !b[8].line_id=byte('RESIDUAL')
                       if !flag then begin
                          clr=!orange
                          get_clr,clr
                          oplot,gauss_x,gauss_y-yfit,thick=0.5,color=clr
                          endif
                       end
                 ; CONTinuum mode
                     0:begin
                       !b[1].data[0:!c_pts-1]=yfit
                       !b[1].line_id=byte('GMODEL')
                       clr=!red
                       get_clr,clr
                       oplot,!xx,yfit,thick=1.5,color=clr
;
                       !b[8].data[0:!c_pts-1]=gauss_y-yfit
                       !b[8].line_id=byte('RESIDUAL')
                       if !flag then begin
                          clr=!orange
                          get_clr,clr
                          oplot,gauss_x,gauss_y-yfit,thick=0.5,color=clr
                          endif
                       end
                  else:print,'Invalid !LINE value'
                endcase   
         end
;    
     'd': plot,gauss_x,gauss_y,/xstyle,/ystyle

     'q': print,"Exiting"
     else: print,"Invalid entry"
     endcase
endwhile
;
!a_gauss[0:3*!ngauss-1]=a
pltg
;
@CT_OUT
return
end


