pro fixfreq,plt=plt,help=help
;+
; NAME:
;       FIXFREQ
;
;            =================================
;            Syntax: fixfreq,plt=plt,help=help
;            =================================
;
;   fixfreq Fix incorrect SDFITS rest frequency assignment.
;   ------- This bug is rare.  Showed up for PN NGC6543 
;           Reassigns *all* rest freqs for all bands using
;           info from the rxFreq array
;           
;           Assumes that the STACK is filled with the NSAVEs
;           of the spectra that need fixing. 
;
;
; KeyWords: /plt  plots the spectra with flags
;           /help gives this help
;
;-
; MODIFICATION HISTORY:
; V6.1 14may2011 TMB 
; V7.0 16may2013 tmb added help and !debug
;
;-

;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'fixfreq' & return & endif
;
nsoff
;
;  The correct rest frequencies:
;
rxFreq=[8.6653d+9, 8.58656d+9,8.6623d+9, 8.44d+9, $
        8.6593d+9, 8.918d+9,  8.6563d+9, 8.474d+9]
;
msg0=' MHz Frest changed to ' 
msg1=' MHz difference is '
;
for i=0,!acount-1 do begin
    ns=!astack[i]
    getns,ns
    id=strtrim(string(!b[0].line_id),2)
    id5=strmid(id,0,5) & id=strmid(id,0,3)
    rxnum=fix(strmid(id,2,1))
    restfreq=!b[0].rest_freq & skyfreq=!b[0].sky_freq
;    print,id5,restfreq,rxFreq[rxnum-1],restfreq - rxFreq[rxnum-1]
;
    newRestFreq=rxFreq[rxnum-1]
    !b[0].rest_freq=newRestFreq
    putns,ns
;
    restfreq=restfreq/1.d6 
    newfreq=rxFreq[rxnum-1]/1.d6
    diff=restfreq-newfreq 
    srestfreq=fstring(restfreq,'(f10.4)')
    snewfreq=fstring(newfreq,'(f10.4)')
    sdiff=fstring(diff,'(f10.4)')
    msg=id5+srestfreq+msg0+snewfreq+msg1+sdiff+' MHz'
    print,msg      
    if KeyWord_Set(plt) then begin xx & rrlflag & pause & end
endfor
;
nson
;
return
end
