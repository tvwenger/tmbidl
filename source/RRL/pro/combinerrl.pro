pro combineRRL,nsaveList,nsaveRef,fwhmRef,hpbwList,hpbwRef,nsaveOut=nsaveOut,$
               noquery=noquery,help=help
;+
;NAME: combineRRL.pro 
;
;PURPOSE: combine two or more adjacent RRLs.  Although we expect the
; line intensity to be the same for adjacent RRLs, since the HPBW is 
; a function of frequency the line intensity will vary depending on how the
; telescope's beam couples with source structure.  Assuming
; Gaussian beams and brightness distributions we can calculate a
; correction factor.  A reference RRL must be specified and the other
; RRLs scaled to this transition.  The observed angular source size 
; at the reference RRL frequency must be measured along with the HPBWs
; of all RRLs. 
;
;=========================================================================   
;CALLING SEQUENCE: combineRRL,nsaveList,nsaveRef,fwhmRef,hpbwList,hpbwRef,$
;                             nsaveOut=nsaveOut,noquery=noquery,help=help
;=========================================================================
;
;INPUTS:  
;     -nsaveList:  list of nsave locations to process
;     -nsaveRef:   nsave location of reference spectrum
;     -fwhmRef:    continuum FWHM observed angular size
;     -hpbwList:   list of HPBW of spectra to process
;     -hpbwRef:    HPBW of reference spectrum
;
;OPTIONAL KEYWORDS:
;     /help        gets this help
;     -nsaveOut:   nsave location to store data
;     -noquery:    turns queries off so process proceeds uninterupted
;
;OUTPUTS:
;
;EXAMPLE: calibrateRRL, [1608,1609,1610,1611,1612,1614], 1613, 88.5046, [73.0,79.4,77.7,91.0,86.2,80.7], 85.9 
;
;-
;MODIFICATION HISTORY:
;    19 September 2008 - Dana S. Balser
;          24 Feb 2009 - (dsb) Change querry option to behave like interpRRL_rvsys.
;                              Add lineid in print statement.
;          14 Dec 2012 - (dsb) reshow now uses a keyword for the color.
;           9 May 2013 - tmb added /help and !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'combineRRL' & return & endif
;
;set defaults
if (n_elements(nsaveOut) eq 0) then nsaveOut=!lastns+1

; define feedback parameter
ans = ' '  

; get the reference spectrum
getns, nsaveRef
ymin = min(!b[0].data[fix(!x.range[0]):fix(!x.range[1])])
ymax = max(!b[0].data[fix(!x.range[0]):fix(!x.range[1])])
delta = ymax-ymin
curoff & sety,(ymin-0.25*delta),(ymax+0.25*delta) & curon
xx
h00
accum

; print some info
print, 'white spectrum ---> reference'
print, ' blue spectrum ---> before correction'
print, '  red spectrum ---> after correction'
print, ' ' 

; print header
print, 'Nsave ID    CF' 

; loop through the list
for i=0,n_elements(nsaveList)-1 do begin
    ; get spectrum to process
    getns, nsaveList[i]
    reshow, color=!blue
    ; calculate the correction factor
    cf = (fwhmRef^2 - hpbwRef^2 + hpbwList[i]^2)/(fwhmRef^2)
    ; print some info
    print, nsaveList[i], strtrim(string(!b[0].line_id),2), cf, $
           format='(i4,1x,a5,1x,f6.3)'
    ; scale the data and system temperature
    scale,cf
    !b[0].tsys_on = cf*!b[0].tsys_on
    !b[0].tsys_off = cf*!b[0].tsys_off
    !b[0].tsys = cf*!b[0].tsys
    ; average the data
    reshow, color=!red
    IF ~Keyword_Set(noquery) THEN BEGIN
        ans=get_kbrd(1)
    ENDIF
    accum
endfor

; average and save
ave
freey
xx
h00
IF ~Keyword_Set(noquery) THEN BEGIN
    ans=get_kbrd(1)
ENDIF
; change the id and type
tagtype, '<RRL>'
lineid = strtrim(string(!b[0].line_id),2)
foo = ' '
reads, lineid, foo, format='(1x,a)'
tagid, 'A' + foo 
; save
putavns, nsaveOut
!lastns=!lastns+1

return
end
