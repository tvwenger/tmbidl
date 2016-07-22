pro viewCont,source,tcjList,xrange=xrange,hardcopy=hardcopy,help=help
;+
;NAME: 
;      VIEWCONT
;
; ===============================================
; SYNTAX: viewCont,source,tcjList,xrange=xrange,$
;         hardcopy=hardcopy,help=help
; ===============================================
;
;  VIEWCONT  Display multiple TCJ2 observations.   
;  --------  Plots RA and DEC, forward/backward, 
;            and LL/RR scans plus average.
;
;  ==>  N.B. Writes to NSAVE file after turning off
;            write protection !!!!  So make SURE
;            to attach an empty 'dummy' NSAVE file.
;
; INPUTS:  
;     -source:     source name
;     -tcjList:    list of first record for each tcj2 observation
;
; KEYWORDS: help   - gives this help 
;           xrange - range of x-axis (+/-) in arcsec (e.g., 2300.0)
;         hardcopy - produces a hardcopy
;
;EXAMPLE: viewCont, 'G043.432+0.521', [560,1436], /hardcopy
;         =================================================
;NOTES: 
; Make sure nsave file is a dummy file
; Use !batch=1 (batchon)
; For large concatenated files use:  !scanmax=5000 (large number)
;
;-
;MODIFICATION HISTORY:
;    13 February 2012 - Dana S. Balser
;
; V7.0 24may2013 tmb - modified for v7.0 
;                      cleaned up documentation 
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'viewcont' & return & endif
;
@CT_IN  ; color table handling
on_error,!debug ? 0 : 2
compile_opt idl2

; check that the user specifies tcjList
if n_params() eq 0 then begin
   print
   print,'The tcj starting record list is required'
   print,'==============================================='
   print,'SYNTAX: viewCont,source,tcjList,xrange=xrange,$'
   print,'        hardcopy=hardcopy,help=help'
   print,'==============================================='
endif

; defaults
if n_elements(xrange) eq 0 then xrange=2400.0

; preserve setting
recmin=!recmin
recmax=!recmax
protectns=!protectns

; Assume the nsave file is a dummy so we do not run 
; out of nsave locations.  So set !lastns=0 each time.
; And remove the nsave overwrite protection.
!lastns=0
nsoff

; Use tcjavg which processes data in the stack
; and saves various averages in locations 1-18.
; We need to run it multiple times since by
; default it averages over each direction.

; each tcj separately
for i=0,n_elements(tcjList)-1 do begin
    clrstk
    setsrc, source
    setrec,tcjList[i],tcjList[i]+7
    select
    ;cat
    ;print,tcjList[i],tcjList[i]+7
    ;pause
    tcjavg
endfor

; all tcj's to get grand average
clrstk
setsrc, source
setrec,0,!recmax
select
;cat
;print,0,!recmax
;pause
tcjavg


; =====RA plot=====
; RA LL, IBRA LL, RA RR, IBRA RR
scans = [1,5,9,13]
raxx & freexy 
; plot average
getns, (n_elements(tcjList)+1)*18 - 1
;print, 'RA: ', (n_elements(tcjList)+1)*18 - 1
;pause
; adjust the range
setx,-xrange,xrange
xx
delta = (!y.crange[1] - !y.crange[0])*0.20
sety, (!y.crange[0] - delta), (!y.crange[1] + delta);
; make a hardcopy
if Keyword_Set(hardcopy) then printon, source + '_RA', /eps
xx
; plot each scan
for i=0,n_elements(tcjList)-1 do begin
    for j=0,n_elements(scans)-1 do begin
        getns, scans[j] + i*18
        reshow, color=!red
        ;print, 'RA: ', scans[j] + i*18
        ;pause
    endfor
endfor

; plot average (again)
getns, (n_elements(tcjList)+1)*18 - 1
reshow, color=!cyan
zline
;print, 'RA: ', (n_elements(tcjList)+1)*18 - 1
pause
; make a hardcopy
if Keyword_Set(hardcopy) then printoff




; =====Dec plot=====
; DEC LL, IBDEC LL, DEC RR, IBDEC RR
scans = [3,7,11,15]
decx & freexy 
; plot average
getns, (n_elements(tcjList)+1)*18
;print, 'Dec: ', (n_elements(tcjList)+1)*18
;pause
; adjust the range
setx,-xrange,xrange
xx
delta = (!y.crange[1] - !y.crange[0])*0.20
sety, (!y.crange[0] - delta), (!y.crange[1] + delta)
; make a hardcopy
if Keyword_Set(hardcopy) then printon, source + '_Dec', /eps
xx
; plot each scan
for i=0,n_elements(tcjList)-1 do begin
    for j=0,n_elements(scans)-1 do begin
        getns, scans[j] + i*18
        reshow, color=!red
        ;print, 'Dec: ', scans[j] + i*18
        ;pause
    endfor
endfor

; plot average (again)
getns, (n_elements(tcjList)+1)*18
reshow, color=!cyan
zline
;print, 'Dec: ', (n_elements(tcjList)+1)*18
; make a hardcopy
if Keyword_Set(hardcopy) then printoff


; restore setting
!recmin=recmin
!recmax=recmax
!protectns=protectns
;
@CT_OUT ; restore color table
;
return
end
