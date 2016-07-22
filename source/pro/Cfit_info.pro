pro Cfit_info,fname,help=help
;+
; NAME:
;       CFIT_INFO
;
;            =============================================================
;            Syntax: Cfit_info, fullly_qualified__output_filenam,help=help
;            =============================================================
;
;   Cfit_info  Output results of CONTINUUM data reduction
;   ---------  to file 'full_output_filename'.
;
;              Outputs to screen and datafile !continuum_fits
;  
;                  !c_flag  = 0   print only the numbers
;                             1   print ID info for output fields
;
;                  !c_print = 0   print only to screen
;                             1   print both to screen and datafile
; 
;   Output:
;----------------------------------------------------------------------------------------
;SOURCE                             Scan #      Date  
;SKY_FREQ  BAND_WIDTH
;  MHz        MHz         
;TCJ POL   RA       DEC      AZ       EL       LST     HA     Tsys   Tcal   RMS NFIT #G
;          deg      deg      deg      deg      hr      hr       K     K
; #   Center  Sig_c     Tpk     Sig_Tpk   FWHM    Sig_fwhm
;     arcsec  arcsec     K         K      arcsec  arcsec
;----------------------------------------------------------------------------------------
;      center position is w.r.t. mean position of the TCJ 
;             
; V5.0 July 2007
;  5.1 Jan  2008 tmb fixed bugs and modified to accomodate general TCJ
;                    stuff (e.g. TCJ2), including correct position of source
;      19aug08 tmb modified to force file name argument
;                  fixed formatting to accomodate mK sized numbers
;                  removed cos(DEC) correction as this is now done
;                  in the x-axis display for RA/BRA for !cosdec=1
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'Cfit_info' & return & endif
;
!continuum_fits=fname
if !c_print then begin
   find_file,fname ; does this file exist?
   openu,!cfitunit,!continuum_fits,/append ;  append to existing file
   end
;
;no_filter_yet:
;
    src=string(!b[0].source) & src=strtrim(src,2) &
    scn=!b[0].scan_num
    date=string(!b[0].date)
    sky_freq=!b[0].sky_freq/1.0D+6
    rest_freq=!b[0].rest_freq/1.0D+6
    bw=!b[0].bw/1.0D+6
    pol=string(!b[0].pol_id) & pol=strtrim(pol,2) &
;
;   Cmake.pro already parses nature of the data into !b[0].scan_type
;
    ID=strmid(!b[0].scan_type,0,8)
    seq=!b[0].procseqn         ; seq=1 RA TCJ  seq=2 Dec TCJ
    case seq of & 1:ID='RA ' & 2:ID='DEC' &  endcase &


    az=!b[0].az
    el=!b[0].el
    ra=!b[0].ra
    dec=!b[0].dec
    lst=!b[0].lst/3600.                   ; LST hours
    slst=adstring(!b[0].lst/3600.)        ; LST as HH MM SS string
    ha=(!b[0].lst/3600.)-(!b[0].ra/15.)   ;  lst in seconds and ra in degrees
    ha = (ha gt 12.) ? (ha-24.) : ha      ; note use of the Ternary operator...!
    tsys=!b[0].tsys
    tcal=!b[0].tcal
    mask,rms
    nfit=!nfit
    ngauss=!ngauss
;
stars='****************************************'
stars=stars+stars
label0='SOURCE                             Scan #      Date'
labelX='   Sky Freq    Bandwidth'
labelY='      MHz         MHz'
lab1='TCJ POL   RA       DEC      AZ       EL       '
lab2='LST     HA     Tsys   Tcal   RMS NFIT #G'
label1=lab1+lab2
lab3='          deg      deg      deg      deg      hr      hr       '
lab4='K     K'
label2=lab3+lab4
lab5=' #   Center  Sig_c     Tpk     Sig_Tpk   FWHM    ' 
lab6='Sig_fwhm'
label3=lab5+lab6
label4='     arcsec  arcsec     K         K      arcsec  arcsec'
;
format0='(a-32,1x,i8,2x,a-32)'
formatX='(3x,f11.4,1x,f9.4)'
fmt0='(a8,1x,a3,1x,f8.4,1x,f8.4,1x,f8.4,1x,f8.4,1x,'
fmt1='f7.4,1x,f7.4,1x,f6.2,1x,f5.2,1x,f7.4,1x,i2,1x,i2)'
format1=fmt0+fmt1
fmt2='(i2,1x,f9.4,1x,f7.4,1x,f10.4,1x,f7.4,1x,'
fmt3='f9.4,1x,f7.4)'
format2=fmt2+fmt3
;
if !c_print then printf,!cfitunit,stars,format='(a)'
if !c_flag then begin
   print,label0
   if !c_print then printf,!cfitunit,label0
endif
print,src,scn,date,format=format0
if !c_print then printf,!cfitunit,src,scn,date,format=format0
;
if !c_flag then begin
   print,labelX
   print,labelY
   if !c_print then begin
      printf,!cfitunit,labelX
      printf,!cfitunit,labelY
  endif
endif
print,sky_freq,bw,format=formatX
if !c_print then printf,!cfitunit,sky_freq,bw,format=formatX
;
if !c_flag then begin
   print,label1
   print,label2
   if !c_print then begin
      printf,!cfitunit,label1
      printf,!cfitunit,label2
   end
end
print,ID,pol,ra,dec,az,el,lst,ha,tsys,tcal,rms,nfit,ngauss, $
      format=format1
if !c_print then printf,!cfitunit,ID,pol,ra,dec,az,el,lst,  $
                        ha,tsys,tcal,rms,nfit,ngauss,format=format1
;
if !c_flag then begin
   print,label3
   print,label4
   if !c_print then begin
      printf,!cfitunit,label3
      printf,!cfitunit,label4
   end
end
;
a=fltarr(3*!ngauss)
a=!a_gauss[0:3*!ngauss-1]
sigmaa=!g_sigma[0:3*!ngauss-1]
dec=!b[0].dec
;
for i=0,!ngauss-1 do begin
        h=a[i*3+0]
        c=a[i*3+1]
        w=a[i*3+2]        
        sh=sigmaa[i*3+0]
        sc=sigmaa[i*3+1]
        sw=sigmaa[i*3+2]
;        ID=strmid(ID,0,2)
;        case ID of        ; can one do the thing below with a case statement?
;                  'DE' or 'BD':begin
;                               w=a[i*3+2]
;                               sw=sigmaa[i*3+2]
;                               end
;                  'RA' or 'BR':begin
;                               w=a[i*3+2]*cos(dec/!radeg)
;                               sw=sigmaa[i*3+2]*cos(dec/!radeg)
;                               end
;        endcase
;
        print,i+1,c,sc,h,sh,w,sw,format=format2    
;
        if !c_print then printf,!cfitunit,i+1,c,sc,h,sh,w,sw,format=format2
;
endfor
;
next:
if !c_print then close,!cfitunit
; 
return
end


