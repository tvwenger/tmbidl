pro make_cfits_file,fname,help=help
;+
; NAME:
;       MAKE_CFITS_FILE
;
;            =======================================
;            Syntax: make_cfits_file,fname,help=help
;            =======================================
;
;   make_cfits_file  Create file to store the CONTINUUM 
;   ---------------  data reduction Gaussian fits information.
;                    Prompts for filename if it is not supplied.
;           
;                    'fname' must be fully qualified file name
;-
; V5.0 July 2007
; tmb modified 11 Aug 07 per dsb request
;  "            3 Jan 08
; V5.1 19aug08 tmb added current !nsavefile name to file header
;
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'make_cfits_file' & return & endif
;
if n_params() eq 0 then begin
   print,'Input a fully qualified file name for CONTINUUM data reduction fits'
   print
   print,'Syntax: make_cfits_file,file_name'
   print,'================================='
   print
   print,'Now making default file: "'+string(!continuum_fits)+'"'
   fname=!continuum_fits
endif
;
get_lun,lun                          ;    assign lun for CONTINUUM file
!cfitunit=lun                        ;    we keep this lun throughout
;
openw,!cfitunit,fname
;
source=string(!b[0].source)
source=strtrim(source,2)
label=source+' CONTINUUM fits file. NSAVE data is in: '
label=label+!nsavefile
hash='---------------------------------------------'
hash=hash+hash
printf,!cfitunit,hash
printf,!cfitunit,label
printf,!cfitunit,hash
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
printf,!cfitunit,label0
printf,!cfitunit,labelX
printf,!cfitunit,labelY
printf,!cfitunit,label1
printf,!cfitunit,label2
printf,!cfitunit,label3
printf,!cfitunit,label4
printf,!cfitunit,hash
; 
close,!cfitunit
;
return
end


