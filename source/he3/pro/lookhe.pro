pro lookhe,epoch=epoch,help=help,nsave=nsave
;+
; NAME: LOOKHE
;
;            ================================================
;            Syntax: lookhe,epoch=epoch,help=help,nsave=nsave
;            ================================================
;
;   lookhe  procedure to look at 3He spectra for current 3He tuning
;   ------  assumes epoch averages in NSAVEs
;           hardwired for:  /data/gbt/he3/nsaves/line/12A_114/he3.lns.0
;           must setsrc,source_name before invoking                  
;
;   KEYWORDS: 'epoch' a string that sets the epoch name to be selected
;                     Default is 'EPAV'
;
;             'help'  if set gives HELP
;
;             'nsave' if set gives NSAVE file to be selected
;                     MUST be fully qualified file name
;             Default ==> fnsave='/data/gbt/he3/nsaves/line/12A_114/he3.lns.0'
;  
;-
; MODIFICATION HISTORY:
;
; V6.1  tmb date
;       20 april 2012 tmb 
;       30 june  2012 tmb freey scaling before showing average
;       10 aug   2012 tmb minor tweaks. set polarization search to '*'
;                         will not deal with 'L+R' anymore because
;                         of epav.pro issue 
;-
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'lookhe' & return & end
;
if ~KeyWord_Set(nsave) then begin
    fnsave='/data/gbt/he3/nsaves/line/12A_114/he3.lns.0'
    fnsavelog=strmid(fnsave,0,strlen(fnsave)-2)+'.key.0'
endif
;
attach,3,fnsave,fnsavelog
;
; channel shifts for 11B_043 and 12A_114 tuning
;
cshift=3.d/(50.d/4096.d)
shift=[0.d,cshift,2.d*cshift,3.d*cshift]
rxid=['rx1','rx3','rx5','rx7']
;
; fill the stack 
;
clrstk
if ~Keyword_Set(epoch) then epoch='EPAV' ; default search epoch is all 
settype,epoch
pol='*'   & setpol,pol
for i=0,3 do begin & id=rxid[i] & setid,id & selectns & endfor
catns
;
; now show the spectra  
; first get nice y-axis range
;
getns,!astack[0] & dcsub & mk & xx
yincr=1.25 
ymax=!y.crange[1]*yincr & ymin=!y.crange[0]*yincr
sety,ymin,ymax
;
for i=0,!acount-1 do begin
    getns,!astack[i] & dcsub & mk
    scnrx=strmid(string(!b[0].line_id),0,3)
;   how big is the shift for this spectrum?
    idx=where(rxid eq scnrx)
    if idx eq -1 then begin & print,'ERROR! NSAVE is NOT a 3-He spectrum' & end
    shiftc=shift[idx] & wrap,shiftc ; shift for tuning 
    case i of 
           0: begin & xx & rrlflag & accum & pause & end
        else: begin & reshow & accum & pause & end
        endcase
 endfor
;
; now show the average
;
ave
type='He3 ALL' & tagid,type
!b[0].data[0:3*cshift]=0.
!b[0].tintg=!b[0].tintg/4.
scaley,pad=0.1
xx
;
return
end
