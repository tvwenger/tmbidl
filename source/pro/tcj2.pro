pro tcj2,pos_flag,fname,help=help
;+
; NAME:
;       TCJ2 
;
;            ===========================================
;            Syntax: tcj2, position_flag, fname,help=help
;            ===========================================
;
;   tcj2 automatic CONTINUUM data reduction
;   ---  assumes 3He 599 point TCJ2 RA/Dec DCR scan
;
;        Assumes the STACK is filled with correct TCJ2 scan#s
;        and that NREGIONs, NFIT, and Gfit parameters are set.
;        Goes through the STACK and automatically analyzes the TCJ2.  
;        Only analzes the pos_flag TCJs in STACK:
;            position_flag = 1  reduce RA  TCJ2
;                            2  reduce RA  TCJ2
;                            3  reduce Dec TCJ2
;                            4  reduce Dec TCJ2
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
if n_params() eq 0 or keyword_set(help) then begin & get_help,'tcj2' & return & endif
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
    seq=!b[0].procseqn         ; seq=1 RA TCJ2  seq=2 RA TCJ2  seq=3 Dec TCJ2  seq=4 Dec TCJ2
    if seq ne pos_flag then goto,next
    case seq of
               1:raxx 
               2:raxx
               3:decx 
               4:decx
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


