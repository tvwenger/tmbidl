pro rehash, reset=reset, params=params, paramvals=paramvals,help=help
;+
; NAME:
;       REHASH
;
;            =========================================================================
;            Syntax: rehash, reset=reset, params=params, paramvals=paramvals,help=help
;            =========================================================================
;
;   rehash   Recovers !rec.history information and prints it.
;   ------   Gives values for: 
;                  size nfit nunit(X-axis units) nrset
;                  nregion
;                  ngauss
;                  bgauss egauss 
;                  a_gauss
;                  g_sigma 
;
;            /reset puts these data into the relevant system variables
;               ==> default is NOT to do this
;
;            /params ==> output fit parameter information for archiving
;  
;            paramvals ==> structure with fit parameters. If set,
;             nothing is printed to the display.
;
;             paramvals = {ngauss:ngauss, $
;                 height:fltarr(ngauss), $
;                 errheight:fltarr(ngauss), $
;                 width:fltarr(ngauss), $
;                 errwidth:fltarr(ngauss), $
;                 center:fltarr(ngauss), $
;                 errcenter:fltarr(ngauss)}
;-
; V5.0 June 2007 
;      July 2008 tmb modified to inform whether reset has occurred
;                    added Keyword 'params' to output record of fit info
;                    fixed bug in HA calculation
;      25jul08 tmb rearanged the /param output for better human readibility
;      17aug08 tmb added F_sky to the /params output 
;      18Sep08 lda added paramvals keyword
;
; V6.0 15aug2009  tmb integrated v6.0 and LDA code 
;  6.1 24sept2009 tmb tracked down g_sigma bug 
; V7.0 03may2013 tvw - added /help, !debug
; v7.1 20aug2013 tvw - fixed formatting error
;      30may2014 tmb/tvw - fixed tvw fix lol
;      08jun2014 tmb - more output format tweaks
;                      ad hoc fix of bug that is 1 byte off on
;                      code that looks for 'extra' info in the history
;                      lines 213 283
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'rehash' & return & endif
; 
IF ~Keyword_Set(reset) THEN reset=0  $ ; default is to NOT reset !variables
                       ELSE reset=1 
;
; If this keyword is present, default to params=1 and no printing
if Arg_Present(paramvals)then begin
    params = 1
    doprint = 0
endif else doprint = 1
;
history=!b[0].history
deja_vu=string(history[0:2])
size=long(deja_vu)
;

fmt= '(I3,1x,I2,1x,a4,1x,I2)'
fmt0='(I2,1x)'
comment=' COMMENT '
;
if deja_vu eq '' then begin
        comment='No HISTORY information yet stored for this spectrum: '
        scanid=fstring(!b[0].scan_num,'(i9)')
        print
        print,comment+scanid
        print
        return     
end
;
xx=history
;
nfit=long(string(xx[3:5]))
;
nunit=strtrim(string(xx[6:10]),2)
case nunit of ; set x_axis units for NREGIONs
              'CHAN':CHAN
              'FREQ':FREQ
              'VELO':VELO
              'VGRS':VGRS
              'AZXX':AZXX
              'ELXX':ELXX
              'RAXX':RAXX
              'DECX':DECX
          else:print,'screwy x-axis definition'
endcase
;
freex
;
nrset=long(string(xx[11:13]))
;if nrset lt 1 then goto, no_nregions
nr=2*nrset
; now positions can float so keep track va 'idx'
idx=14
;
case 1 of       ; NREGIONs
    (!chan eq 1):begin
                 nregion=lonarr(nr)
                 sz=6 ; remember the blank
                 for i=0,nr-1 do nregion[i]=long(string(xx[idx+i*sz:idx+i*sz+sz]))
                 fmtI='('+string(nr)+'I6)'
                 end
    else:        begin
                 nregion=fltarr(nr)
                 sz=11
                 for i=0,nr-1 do nregion[i]=float(string(xx[idx+i*sz:idx+i*sz+sz]))
                 fmtF='('+string(nr)+'F10.4)'
                 end
endcase
idx=idx+sz*nr   ; advance the pointer
;
case 1 of 
    (!chan eq 1):begin
                 sz=6 ; remember the blank
                 bgauss=long(string(xx[idx:idx+sz]))
                 fmtIbgauss='(2I6)'
                 end
    else:        begin
                 sz=11
                 bgauss=float(string(xx[idx:idx+sz]))
                 fmtFbgauss='(2F10.4)'
                 end
endcase
idx=idx+sz      ; advance the pointer
;
case 1 of 
    (!chan eq 1):begin
                 sz=6 ; remember the blank
                 egauss=long(string(xx[idx:idx+sz]))
                 end
    else:        begin
                 sz=11
                 egauss=float(string(xx[idx:idx+sz]))
                 end
endcase
idx=idx+sz      ; advance the pointer
;
no_nregions:
;
ngauss=long(string(xx[idx:idx+3]))
idx=idx+3
sz=12          ; this is the bug?
ng=3*ngauss
sng=string(ngauss)
fmtGauss='('+sng+'('+'3(f10.4,1x),/))'
a_gauss=fltarr(ng)
g_sigma=fltarr(ng)
;
;if ngauss lt 1 then goto,no_gauss
;
for i=0,ng-1 do a_gauss[i]=float(string(xx[idx+i*sz:idx+i*sz+sz-1]))
idx=idx+sz*ng
sz=11
for i=0,ng-1 do g_sigma[i]=float(string(xx[idx+i*sz:idx+i*sz+sz-1]))
idx=idx+sz*ng
; fix indexing bug empirically  this should not be here.
;dx=idx-2*ngauss+1 
;
no_gauss:
;  Set all system variables to the values just retrieved
;
if reset eq 0 then goto,print_info  ; default is not to reset !variables
if not !batch then print,'Restored baseline and Gaussian fit parameters!'
;
!nfit=nfit
!nrset=nrset
!nregion=0
!nregion[0:2*nrset-1]=nregion
;if ngauss lt 1 then goto,print_info
!ngauss=ngauss
!bgauss=bgauss
!egauss=egauss
!a_gauss=0
!a_gauss[0:3*ngauss-1]=a_gauss
!g_sigma=0
!g_sigma[0:3*ngauss-1]=g_sigma
;
;  Now print the information just retrieved
;
print_info:
if Keyword_Set(params) then goto, output_fit_parameters
if not !batch then begin
;
; now all the HISTORY stuff
print
print,size,nfit,nunit,nrset,format=fmt
case 1 of 
          (!chan eq 1):print,nregion,format=fmtI
          else:        print,nregion,format=fmtF
endcase
print,ngauss,format=fmt0
case 1 of 
          (!chan eq 1):print,bgauss,egauss,format=fmtIbgauss
          else:        print,bgauss,egauss,format=fmtFbgauss
endcase
print,a_gauss,format=fmtGauss
print,g_sigma,format=fmtGauss
;
; Is there more in !b[0].history?  If so then write it out.
;
; there is a bug here we seem to be 1 byte off 
;if idx lt size then begin <== original code
if idx+1 lt size then begin
          extra=string(!b[0].history[idx-1:size-1])
          print
          print,extra
          print
          endif

endif
;
output_fit_parameters:
;  print a summary of source info
;  together with fit parameters
; tvw fix - format Cfmt needs a spot for sky frequency
;           made it f6.1
Cfmt= '(a,1x,a,1x,a,1x,a,1x,a,1x,f6.1,1x,f4.1,1x,f6.1,1x,1x,i5,5x,a)'
Cfmt1='(i2,1x,f8.2,1x,f6.2,1x,f7.2,1x,f5.2,3x,f8.2,1x,f5.2)'
src=strtrim(string(!b[0].source))
type=strtrim(string(!b[0].scan_type))
pol=strtrim(string(!b[0].pol_id))
scn=!b[0].scan_num
ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ; yes, they send lst in seconds and ra in degrees
ha = (ha gt +12.) ? (ha-24.) : ha      ; note use of the Ternary operator...!
ha = (ha lt -12.) ? (ha+24.) : ha      ; note use of the Ternary operator...!
za=90.0-!b[0].el
yunits=strtrim(string(!b[0].yunits),2)
ytype=strtrim(string(!b[0].ytype),2)
fsky=!b[0].sky_freq/1.0d+6             ; band center sky frequency in MHz
;
paramvals = {ngauss:ngauss, $
             height:fltarr(ngauss), $
             errheight:fltarr(ngauss), $
             width:fltarr(ngauss), $
             errwidth:fltarr(ngauss), $
             center:fltarr(ngauss), $
             errcenter:fltarr(ngauss)}
;
if doprint then begin
   print
   if not !batch then print,$
       'POL          TYPE      UNITS     HA  ZA   F_SKY   REC/NS#  SOURCE'
   print,pol,type,nunit,yunits,ytype,ha,za,fsky,scn,src, format=Cfmt
   print
   if not !batch then print,' #   HEIGHT  SIGMA    FWHM SIGMA     CENTER SIGMA'
endif
;
for i=0,ngauss-1 do begin
    ng=i+1
    paramvals.height[i] = a_gauss[0+i*3]
    paramvals.errheight[i] = g_sigma[0+i*3]
    paramvals.center[i] = a_gauss[1+i*3]
    paramvals.errcenter[i] = g_sigma[1+i*3]
    paramvals.width[i] = a_gauss[2+i*3]
    paramvals.errwidth[i] = g_sigma[2+i*3]

    if doprint then begin
        print,ng,a_gauss[0+i*3],g_sigma[0+i*3], $ ; height +/- error
              a_gauss[2+i*3],g_sigma[2+i*3], $ ; width
              a_gauss[1+i*3],g_sigma[1+i*3], format=Cfmt1 ; center
    endif
endfor
;
; Is there more in !b[0].history?  If so then write it out.
;
; same ad hoc issue 
;if idx lt size then begin  <== original code
if idx+1 lt size then begin
          extra=string(!b[0].history[idx-1:size-1])
          print
          print,extra
          print
       endif                        ;
flush:
return
end
