pro gvegas,help=help,ps=ps,file=file,graph=graph,smooth=smooth, $
          alpha=alpha
;+
; NAME: VEGAS
;       
;
; ====================================================================
; Syntax: gvegas,help=help,ps=ps,file=file,graph=graph,smooth=smooth, $
;               alpha=alpha
; ====================================================================
;
;   vegas  examines VEGAS data 
;   -----  uses contents of the STACK 
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
;      08jun2015 tmb changed .pro name so vegas/gvegas compile separately
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
   line=['H87a','H88a','H89a','H90a','H91a','H92a','H93a']
;
pol=['LL','RR']
;print,line
;
;
fname='/home/groups/3helium/tmbidl/VEGAS/vegas.dat'
if KeyWord_Set(file) then openw,lun,fname,/get_lun
label='#   Src Scn# Bank freq     ID   Pol Type '
label=label+'Tcal  Ton  Toff  Tsys  Elev    Tpeak Tnorm' 
;fmt='(i2,1x,a4,1x,i4,a5,f7.1,1x,a6,1x,a3,1x,a3,1x,f4.1,4f6.1,2f8.4)'
fmt='(i2,1x,a4,1x,i4,a5,f7.1,1x,a6,1x,a3,1x,a3,1x,f4.1,4f6.1,2f8.4)'
;
clearset
setsrc,'W3'
settype,'ON'
;
; loop through the stack
;
; Line ID loop
;
;for k=0,n_elements(line)-1 do begin
for k=0,0 do begin
    setid,line[k]
;
; polarization loop 
;
for j=0,1 do begin 
    clearstk & setpol,pol[j] 
    case 1 of
              KeyWord_Set(alpha): setrange
                            else: setrange
    endcase
    select 
;
kount=0
old_scn=0
for i=0,!acount-1 do begin
;for i=0,9 do begin
    kount=kount+1
    fetch,!astack[i] 
    if KeyWord_Set(smooth) then smov, 3.0
    dcsub
;    b
    tpeak=max(!b[0].data[!x.range[0]:!x.range[1]])
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
; test to see if things scale with Tsys Use 140 Ft Tsys of 62.1 K 
;
    tnorm=tpeak*(62.1/tsys)
;
    if scn ne old_scn then begin &
              old_scn=scn & kount=1
              print & print,label
              if KeyWord_Set(file) then begin
                 printf,lun & printf,lun,label
              endif
    endif
    print,kount,src,scn,bank,freq,lineID,polID,type,tcal,tsysON, $
          tsysOFF,tsys,elev,tpeak,tnorm,format=fmt
    if KeyWord_Set(file) then $
       printf,lun,kount,src,scn,bank,freq,lineID,polID,type,tcal,tsysON, $
                  tsysOFF,tsys,elev,tpeak,tnorm,format=fmt
    if KeyWord_Set(graph) then begin
       case 1 of 
              kount eq 1: begin & scaley & xx & rrlflag & pause & end
                    else: begin & scaley & xx & rrlflag & pause & end
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
return
end
