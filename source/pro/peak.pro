pro peak,pos_flag,fname,help=help
;+
; NAME:
;       PEAK 
;
;            ===========================================
;            Syntax: peak, position_flag, fname,help=help
;            ===========================================
;
;   peak automatic CONTINUUM data reduction
;   ---  assumes 3He 599 point PEAK Az/El DCR scan
;
;        Assumes the STACK is filled with correct Peak scan#s
;        and that NREGIONs, NFIT, and Gfit parameters are set.
;        Goes through the STACK and automatically analyzes the PEAK.  
;        Only analzes the pos_flag Peaks in STACK:
;            position_flag = 1  reduce Az Peak
;                            2  reduce Az Peak
;                            3  reduce El Peak
;                            4  reduce El Peak
;        Writes the continuum header and fit information 
;        to file 'fname' which must be fully qualified.
;        Default for no input fname is !continuum_fits.  
;        Asks if you want to print scan by scan so you can 
;        flush bad data.
;-
; V5.0 July 2007   
; V7.0 03may2013 tvw - added /help, !debug        
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'peak' & return & endif
;
case n_params() of
                  1:fname=!continuum_fits
                  2:!continuum_fits=fname
              endcase
;
;                  !c_flag  = 0   print only the numbers
;                             1   print ID info for output fields
;
;                  !c_print = 0   print only to screen
;                             1   print both to screen and datafile
cflag=!c_flag
cprint=!c_print  ; save initial state
!c_flag=0 & !c_print=0 &
;
freey
;
kount=0
for nrec=0,!acount-1 do begin
    get,!astack[nrec]
    seq=!b[0].procseqn         ; seq=1 Az Peak  seq=2 Az peak  seq=3 El Peak  seq=4 El Peak
    if seq ne pos_flag then goto,next
    case seq of
               1:azxx 
               2:azxx
               3:elxx 
               4:elxx
    endcase
;
    b & freey & xx & g & Cfit_info,fname &
    print,'Do you want to SAVE this fit ?? (y or n)'
    ans=' '
    read,ans,prompt='Save fit to file '+fname+' ???  '
;
    case ans of 
               'y':begin
                   !c_flag=0 & !c_print=1 &
                   Cfit_info,fname
                   !c_flag=0 & !c_print=0 &
                   print,'FIT SAVED TO FILE = '+fname
                   end
              else:print,'FIT NOT SAVED'
    endcase
;
kount=kount+1
next:
endfor
;
!c_flag=cflag
!c_print=cprint  ; return flag states
; 
return
end


