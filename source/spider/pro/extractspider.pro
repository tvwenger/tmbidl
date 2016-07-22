pro extractspider,ns_start,ns_end,help=help
;+
; NAME:
;       extractspider
;
;            ==============================================
;            Syntax: extractspider,ns_start,ns_end,help=help
;            ==============================================
;
;   extractspider  procedure to 
;   -------------  extract Gaussian information from fits
;                  fit 2D Gaussian
;                 
;
;   KEYWORDS:
;              HELP - get syntax help
;
; MODIFICATION HISTORY:
;
; V1.0 TVW 02july2012
;      DSB 19nov2012  - modify TeX file format
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin
   get_help,'extractspider'
   return
endif
;
openw,lun,'~/extractspider.tex',/get_lun
;
for ns=ns_start,ns_end,4 do begin
   ; RA
   getns,ns
   sname=(strsplit(string(!b[0].source),' ',/extract))[0]
   print,'Working on '+sname
   rehash,/reset,paramvals=RAp
   if RAp.ngauss ne 1 then begin
      print,'Error: RA does not have only 1 Gaussian!'
      close,lun
      return
   endif
   ;
   ; find bgauss and egauss
   idchan,!bgauss,bchan
   idchan,!egauss,echan
   ; put them in least to greatest order
   if bchan gt echan then begin & temp=echan & echan=bchan & bchan=temp & endif
   ;
   raxx
   freex
   xx
   RA=!xx[bchan:echan]
   print,n_elements(RA)
   decx
   freex
   xx
   DEC=!xx[bchan:echan]
   data=!b[0].data[bchan:echan]
   ;
   ; CC
   getns,ns+1
   rehash,/reset,paramvals=CCp
   if CCp.ngauss ne 1 then begin
      print,'Error: CC does not have only 1 Gaussian!'
      close,lun
      return
   endif
   ;
   ; find bgauss and egauss
   idchan,!bgauss,bchan
   idchan,!egauss,echan
   ; put them in least to greatest order
   if bchan gt echan then begin & temp=echan & echan=bchan & bchan=temp & endif
   ;
   raxx
   freex
   xx
   RA=[RA,!xx[bchan:echan]]
   decx
   freex
   xx
   DEC=[DEC,!xx[bchan:echan]]
   data=[data,!b[0].data[bchan:echan]]
   ;
   ; Dec
   getns,ns+2
   rehash,/reset,paramvals=DECp
   if DECp.ngauss ne 1 then begin
      print,'Error: DEC does not have only 1 Gaussian!'
      close,lun
      return
   endif
   ;
   ; find bgauss and egauss
   idchan,!bgauss,bchan
   idchan,!egauss,echan
   ; put them in least to greatest order
   if bchan gt echan then begin & temp=echan & echan=bchan & bchan=temp & endif
   ;
   raxx
   freex
   xx
   RA=[RA,!xx[bchan:echan]]
   decx
   freex
   xx
   DEC=[DEC,!xx[bchan:echan]]
   data=[data,!b[0].data[bchan:echan]]
   ;
   ; CW
   getns,ns+3
   rehash,/reset,paramvals=CWp
   if CWp.ngauss ne 1 then begin
      print,'Error: CC does not have only 1 Gaussian!'
      close,lun
      return
   endif
   ;
   ; find bgauss and egauss
   idchan,!bgauss,bchan
   idchan,!egauss,echan
   ; put them in least to greatest order
   if bchan gt echan then begin & temp=echan & echan=bchan & bchan=temp & endif
   ;
   raxx
   freex
   xx
   RA=[RA,!xx[bchan:echan]]
   decx
   freex
   xx
   DEC=[DEC,!xx[bchan:echan]]
   data=[data,!b[0].data[bchan:echan]]
   ;
   aveHeight=RAp.height[0]+DECp.height[0]+CCp.height[0]+CWp.height[0]
   aveHeight/=4.
   ;
   ; fit 2D Gaussian
   print,'Gaussian:'
   guess=dblarr(7)
   guess[0]=0.            ; baseline guess
   guess[1]=aveHeight     ; peak guess
   guess[2]=RAp.width[0]/2.35482  ; x width guess
   guess[3]=DECp.width[0]/2.35482 ; y width guess
   guess[4]=0.            ; x centroid guess
   guess[5]=0.            ; y centroid guess
   guess[6]=0.            ; TILT (not used)
   print,"guess is: ",guess
   params=mpfit2dfun('mpfit2dpeak_gauss',RA,DEC,data,0,guess,weights=1.,/quiet,perror=perror)
   print,'Baseline:  ',params[0]
   print,'Peak    :  ',params[1]
   print,'RA FWHM:  ',params[2]*2.35482
   print,'Dec FWHM: ',params[3]*2.35482
   print,'X Center:  ',params[4]
   print,'Y Center:  ',params[5]
   ;
   h3d=params[1]
   h3dunc=perror[1]
   ;
   ; peak percent differences
   RaHerr=100.*abs(RAp.height[0]-h3d)/h3d
   CCHerr=100.*abs(CCp.height[0]-h3d)/h3d
   DecHerr=100.*abs(DECp.height[0]-h3d)/h3d
   CWHerr=100.*abs(CWp.height[0]-h3d)/h3d
   ;
   printf,lun,' '
   printf,lun,'\clearpage'
   printf,lun,'\begin{figure}'
   printf,lun,'\centering'
   printf,lun,'\includegraphics[angle=90.,scale=0.5]{figures/'+sname+'.eps}'
   printf,lun,'\includegraphics[angle=90.,scale=0.5]{figures/'+sname+'_spiderscan_small.eps}'
   printf,lun,'\end{figure}'
   printf,lun,' '
   printf,lun,'\clearpage'
   printf,lun,' '
   printf,lun,'\begin{figure}'
   printf,lun,'\centering'
   printf,lun,'\includegraphics[angle=90.,scale=0.30]{figures/'+sname+'_RA__ra.eps}'
   printf,lun,'\includegraphics[angle=90.,scale=0.30]{figures/'+sname+'_CC__ra.eps}'
   printf,lun,'\includegraphics[angle=90.,scale=0.30]{figures/'+sname+'_DEC_dec.eps}'
   printf,lun,'\includegraphics[angle=90.,scale=0.30]{figures/'+sname+'_CW__dec.eps}'
   printf,lun,'\end{figure}'
   printf,lun,' '
   printf,lun,'\begin{deluxetable}{lccccc}'
   printf,lun,'\tablecaption{Gaussian Fits: '+sname+' }'
   printf,lun,'\tablewidth{0pt}'
   printf,lun,'\tablehead{'
   printf,lun,'\colhead{} & \colhead{$T_{\rm C}$} & \colhead{$\sigma(T_{\rm C})$} & \colhead{$\sigma(T_{\rm C})^{2D}$} & \colhead{$\Delta{V}$} & \colhead{$\sigma(\Delta{V})$} \\'
   printf,lun,'\colhead{Scan} & \colhead{(mK)} & \colhead{(mK)} & \colhead{(percent)} & \colhead{(arcsec)} & \colhead{(arcsec)}'
   printf,lun,'} '
   printf,lun,'\startdata '
   printf,lun,RAp.height, RAp.errheight, RaHerr, RAp.width, RAp.errwidth, $
          format='("RA  & ",f8.4," & ",f7.4," & ",f6.2," & ",f8.3," & ",f7.3," \\ ")'
   printf,lun,CCp.height, CCp.errheight, CCHerr, CCp.width*sqrt(2.), CCp.errwidth*sqrt(2.), $
          format='("CC  & ",f8.4," & ",f7.4," & ",f6.2," & ",f8.3," & ",f7.3," \\ ")'
   printf,lun,Decp.height, Decp.errheight, DecHerr, Decp.width, Decp.errwidth, $
          format='("Dec & ",f8.4," & ",f7.4," & ",f6.2," & ",f8.3," & ",f7.3," \\ ")'
   printf,lun,CWp.height, CWp.errheight, CWHerr, CWp.width*sqrt(2.), CWp.errwidth*sqrt(2.), $
          format='("CW  & ",f8.4," & ",f7.4," & ",f6.2," & ",f8.3," & ",f7.3," \\ ")'
   printf,lun,h3d,h3dunc,params[2]*2.35482,perror[2]*2.35482, $
          format='("2D & ",f8.4," & ",f7.4," & RA: & ",f8.3," & ",f7.3," \\ ")'
   printf,lun,params[3]*2.35482,perror[3]*2.35482, $
          format='(" & & & Dec: & ",f8.3," & ",f7.3," \\ ")'
   printf,lun,'\enddata '
   printf,lun,'\end{deluxetable}'


   ;
   openw,lun2,'~/extractspider_data.txt',/get_lun
   printf,lun2,'# '+string(guess[1])+'*exp(-0.5*( (x+'+string(guess[4])+')**2/'+string(guess[2])+'**2 + (y+'+string(guess[5])+')**2/'+string(guess[3])+'**2 ))'
   printf,lun2,'# '+string(params[1])+'*exp(-0.5*( (x+'+string(params[4])+')**2/'+string(params[2])+'**2 + (y+'+string(params[5])+')**2/'+string(params[3])+'**2 ))'
   print,n_elements(RA)
   for i=0,n_elements(RA)-1 do begin
      printf,lun2,i,RA[i],DEC[i],data[i]
   endfor
   close,lun2
   ;
endfor
;
close,lun
;
return
end
