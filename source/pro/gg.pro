pro gg,ngauss,help=help,noinfo=noinfo,resid=resid,gdata=gdata   ; ngauss = # gaussian components to fit 
;+
; NAME:
;       GG
;
;   ====================================================
;   SYNTAX: gg, #_gaussian_components_to_fit,help=help,$
;               noinfo=noinfo,resid=resid,gdata=gdata
;   ====================================================
;   ============================================================
;   USEAGE==> LEFT CLICK: bgauss #_gauss(center,hw_right) egauss
;   ============================================================
;
;   gg   Multiple gaussian fit to !b[0].data
;   --   MUST remove a baseline first
;
;   KEYWORDS  /help   gives this information
;             /noinfo suppresses plot annotation of gfits
;             /resid  plot residual of data minus model
;             /gdata  replot data in region that was fit 
;
;-
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
;
; V6.0 June 2009 adopt dsb version 
;
; V6.1 March 2010 tmb tweak for seamless PS printing
; V6.1 Jan   2011 tmb made it work for GRS spectra
;
; V7.0 28jun2012 tmb - tweaked to suppress annotating plot
;      20jul2012 tvw - checks if nregions are set to stop dsig crashes
;
;      03may2013 tvw - added /help, !debug
;      21may2013 tmb - added /gdata keyword merged all previous versions
;                      including 20July2012 tvw bug fix for !nrset=0 case
;      26jun2013 tmb - set width in kHz and km/sec to zero for all cases
;                      save CHAN display mode 
; V7.1 04jun2014 tmb - added y-axis units to baseline RMS info
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if  keyword_set(help)  then begin & get_help,'gg' & return & endif
if ~KeyWord_Set(resid) then resid=0 ; default is NOT to plot the residual
;
@CT_IN
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
!except=0       ; turn off underflow messages (and, alas, *all* math errors)
;
if n_params() eq 0 then begin
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
!flag=0                  ;   and everything else with flagon 
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
if (!b[0].delta_x gt 0.0) and (!velo eq 1 or !vgrs eq 1) then begin    ; <== v6.1
;if (!b[0].delta_x lt 0.0) and (!velo eq 1 or !vgrs eq 1) then begin   ; tmb thinks this is wrong.
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
;yfit=curvefit(gauss_x[bpix:epix],gauss_y[bpix:epix],$
;              weightf,a,sigmaa,function_name="mgauss",$
;              chisq=chi,/double,itmax=200)
;
yfit = mpcurvefit(gauss_x[bpix:epix],gauss_y[bpix:epix],$
                  weightf,a,sigmaa,function_name="mgauss",$
                  chisq=chisq,itmax=2000,quiet=1)
;
dof=n_elements(gauss_x[bpix:epix]) - n_elements(a)  ; deg of freedom
csigma=fltarr(!ngauss*3)
csigma=sigmaa * sqrt(chisq / dof)                   ; scaled uncertainties
sigmaa=csigma
!g_sigma[0:!ngauss*3-1]=csigma   ;  gaussian fit errors to system variable
;
yfit=fltarr(n_elements(gauss_x))
;
if !flag eq 1 then begin
;
   print,bpix,epix
   print,gauss_x[bpix:epix]
   print,'DOF= ',dof,'  ChiSq= ',chisq
   print,'sigmaa= ', sigmaa
   print,'a= ',a
   print,'weightf= ',weightf
endif
;
if ~KeyWord_Set(noinfo) then begin
   print
   print,"G#       Height +/- sigma     Center +/- sigma       FWHM +/- sigma"+ $
         "   ==>     kHz        km/sec"
endif
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
                  if !chan ne 1 then begin & fw=0. & vw=0. & endif
                  sh=sigmaa[i*3+0]
                  sc=sigmaa[i*3+1]
                  sw=sigmaa[i*3+2]
                  ycomp=h*exp(-4.0*alog(2)*(gauss_x-c)^2/w^2)
                  yfit=yfit+ycomp
;                 oplot,gauss_x,ycomp,thick=0.5,color=clr1
                  if ~KeyWord_Set(noinfo) then print,i+1,h,sh,c,sc,w,sw,fw,vw, $
                                               format='(i2,1x,4(f11.3,1x,f11.3))'
                   endfor
;
if ~KeyWord_Set(noinfo) then begin
   if !chan eq 1 then print,'Center/FWHM in channels'
   if !freq eq 1 then print,'Center/FWHM in frequency (kHz)'
   if !velo eq 1 then print,'Center/FWHM in LSR velocity (km/sec)'
   if !vgrs eq 1 then print,'Center/FWHM in LSR velocity (km/sec)'
   if (!azxx eq 1) or (!elxx eq 1) or (!raxx eq 1) or (!decx eq 1) $
                 then print,'Center/FWHM in arcseconds'   
endif
;
case !LINE of  ; LINE mode
              1:begin
                !b[1].data=yfit
                !b[1].line_id=byte('GMODEL')
                get_clr,clr1      ; determine CLR or BW plot
                oplot,!xx,yfit,thick=1.0,color=clr1
;
                !b[8].data=gauss_y-yfit
                !b[8].line_id=byte('RESIDUAL')
;
                if resid eq 1 then begin
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
                oplot,!xx,yfit,thick=1.0,color=clr1
;
                !b[8].data[0:!c_pts-1]=gauss_y-yfit
                !b[8].line_id=byte('RESIDUAL')
;
                if resid eq 1 then begin
                    get_clr,clr2
                    fit_x=gauss_x[bpix:epix]
                    res_y=gauss_y[bpix:epix]-yfit[bpix:epix]
;                    oplot,gauss_x,gauss_y-yfit,thick=0.5,color=clr2
                    oplot,fit_x,res_y,thick=0.5,color=clr2
                    end
                end
endcase
;
; are nregions defined?
if !nrset eq 0 then begin &
      if !flag eq 1 then print,'NREGIONs not defined so cannot MASK !!'
   goto,skip_the_mask & endif
;
mask,dsig
;
if ~KeyWord_Set(noinfo) then begin
   print
   print,'RMS in NREGIONs = ', dsig, fstring(string(!b[0].yunits),'(1x,a)')
   print
endif
;
skip_the_mask:
;
; overplot the data inside !bgauss,!egauss in !blue
if keyword_set(gdata) then begin 
   fit_x=gauss_x[bpix:epix] & fit_y=gauss_y[bpix:epix]
   oplot,fit_x,fit_y,thick=2.0,color=clr3
endif

;
!except=1                  ; return math error flag to default
;
!a_gauss[0:3*!ngauss-1]=a
if ~KeyWord_Set(noinfo) then pltg
;
!flag=iflag   ;  reset !iflag to input value
;
@CT_OUT
return
end


