pro vegas,help=help,ps=ps,file=file,graph=graph,smooth=smooth, $
          alpha=alpha
;+
; NAME: VEGAS
;       
;
; ====================================================================
; Syntax: vegas,help=help,ps=ps,file=file,graph=graph,smooth=smooth, $
;               alpha=alpha
; ====================================================================
;
;   vegas  examines VEGAS data for C band Rx 
;   -----  uses contents of the STACK 
;          fits baseline and single gaussian => assumes nregions set
;                 
;
;   KEYWORDS: /help   gives help
;             /ps     creates .ps file 
;             /file   prints to file
;             /graph  plots each spectrum
;             /smooth issues smov,3. command
;             /alpha  do alpha transitions only 
;
;-
; MODIFICATION HISTORY:
;
; V8.0 13jul2014 tmb/tvw created
;      23jul2014 tmb extended
;      15jun2015 tmb baseline and gaussian tweak 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  
;
if Keyword_Set(help) then begin & get_help,'vegas' & return & endif 
;
if Keyword_Set(ps) then printon
;
oldcursor=!cursor
!cursor=-1        ; turn off cursor 
!deja_vu=0
;
color=!red
case !clr of  ; take care of PostScript 
             1: clr=color 
          else: clr=!d.name eq 'PS' ? !black : !white
endcase
;
; LINE LIST FOR INITIAL TESTS
;
line=['H91a','C8H-(7-6)','C8H-(8-7)','H109b','H110b','H111b','H112b','H113b', $
      'H114b','H115b','H116b','H117b','H124g','H125g','H126g','H127g','H128g',$
      'H129g','H130g','H131g','H132g','H133g','H137d','H138d','H139d','H140d',$
      'H141d','H142d','H143d','H144d','H145d','H146d','H147e','H148e','H149e',$
      'H150e','H151e','H152e','H153e','H154e','H155e','H156e','H156z','H157e',$
      'H157z','H158z','H159z','H160z','H161z','H162z','H163z','H164z','H165z',$
      'H166z','H167z','H87a','H88a','H89a','H90a','H92a','H93a','HC9N(15-14)',$
      'HC9N(16-15)','He3']
;
if KeyWord_Set(alpha) then $
   line=['H87a','H88a','H89a','H90a','H91a','H92a','H93a', $
         'H107a']
;
pol=['LL','RR','XX','YY']
;print,line
;
;
;fname='/home/groups/3helium/tmbidl/VEGAS/VEGAS20jun15gauss.dat'
;fname='/home/groups/3helium/tmbidl/VEGAS/VEGAS_X_jun19gauss.dat'
fname='/home/groups/3helium/tmbidl/VEGAS/W3s2_C_jun19gauss.dat'
;
if KeyWord_Set(file) then openw,lun,fname,/get_lun
;
title=' W3 VEGAS Tests C band velocity offset 19 June 2015'
label='No  Src Scn Bank freq     ID   Pol Type '
label=label+'Tcal  Ton  Toff   Tsys  Elev  Tpeak TsysTpeak RMS' 
units='                   MHz                    K    K     K     K             K             mK'
;fmt='(i2,1x,a4,1x,i4,a5,f7.1,1x,a6,1x,a3,1x,a3,1x,f4.1,4f6.1,2f8.4)'
fmt='(i2,1x,a4,1x,i4,a5,f7.1,1x,a6,1x,a3,1x,a3,1x,f4.1,4f6.1,2f8.4,1x,f6.1)'
;
clearset
setsrc,'W3s2'
settype,'ON'
setrange,13,16
setx,2000,6000
;setx,3000,7000
;
; loop through the stack
;
; Line ID loop
;
Cband=n_elements(line)-1
;for k=0,n_elements(line)-1 do begin
;for k=0,0 do begin
for k=Cband,Cband do begin
    setid,line[k]
;
; polarization loop 
;
;for j=0,0 do begin
;for j=0,1 do begin 
for j=2,3 do begin 
    clearstk & setpol,pol[j] 
    case 1 of
              KeyWord_Set(alpha): setrange,13,16
                            else: setrange
    endcase
    select 
;
nfit=7
kount=0
old_scn=0
;
for i=0,!acount-1 do begin
;for i=0,0 do begin
    kount=kount+1
    fetch,!astack[i] 
    if KeyWord_Set(smooth) then smov, 3.0
    dcsub
    bbb,nfit,/no
    g
    gfits,fitvals
    tpeak=fitvals[0].height
    rms,sigma,4800,6000 
    dsig=1.d3*sigma     ; baseline rms in mK
;
;    tpeak=max(!b[0].data[!x.range[0]:!x.range[1]])
;
    src= strtrim(string(!b[0].source),2) 
    scn=!b[0].scan_num
    bank=strtrim(string(!b[0].proc_id),2) 
    lineID=strtrim(string(!b[0].line_id),2)
    freq=!b[0].rest_freq/1.d+6
    polID=strtrim(string(!b[0].pol_id),2)
    type=strtrim(string(!b[0].scan_type),2)
    tcal=!b[0].tcal
    tsysON=!b[0].tsys_on
    tsysOFF=!b[0].tsys_off
    tsys=!b[0].tsys
    elev=!b[0].el 
;
; Gain variation?
;
    tnorm=tsys/tpeak 
;
    tagtype,bank    
;
    if scn ne old_scn then begin &
              old_scn=scn & kount=1
              print & print,label
              if KeyWord_Set(file) and !deja_vu eq 0 then begin
                 printf,lun,title & printf,lun,label & printf,lun,units
                 !deja_vu=1
              endif
    endif
    print,kount,src,scn,bank,freq,lineID,polID,type,tcal,tsysON, $
          tsysOFF,tsys,elev,tpeak,tnorm,dsig,format=fmt
    if KeyWord_Set(file) then $
       printf,lun,kount,src,scn,bank,freq,lineID,polID,type,tcal,tsysON, $
                  tsysOFF,tsys,elev,tpeak,tnorm,dsig,format=fmt
    if KeyWord_Set(graph) then begin
       case 1 of 
              kount eq 1: begin & scaley & xx & rrlflag & 
                                  zline  & hline,4.24 & pause & end
                    else: begin & scaley & xx & rrlflag & 
                                  zline  & hline,4.24 & pause & end
;                    else: reshow
       endcase
    endif
;
 endfor ; i loop
endfor  ; j loop
endfor  ; k loop
;
If Keyword_Set(file) then free_lun,lun
If Keyword_Set(ps) then printoff
;
!cursor=oldcursor
;
return
end
