pro tcj,pos_flag,fname,help=help
;+
; NAME:
;       TCJ 
;
;   =============================================
;   SYNTAX: tcj,position_flag,file_name,help=help
;   =============================================
;
;   tcj  automatic CONTINUUM data reduction
;   ---  assumes 3He 599 point TCJ RA/Dec DCR scan
;
;        Assumes the STACK is filled with correct TCJ scan#s
;        and that NREGIONs, NFIT, and Gfit parameters are set.
;        Goes through the STACK and automatically analyzes the TCJ.  
;        Only analzes the pos_flag TCJs in STACK:
;            position_flag = 1  reduce RA  TCJ
;                            2  reduce Dec TCJ
;        Writes the continuum header and fit information 
;        to file 'file_name' which must be fully qualified.
;        Default for no input fname is !continuum_fits.  
;        Asks if you want to print scan by scan so you can 
;        flush bad data.
;
; KEYWORDS  /help gives this help
;
;-
; V5.0 July 2007
;      24dec2012 dsb changes to freexy from freey
;
; V7.0 03may2013 tvw - added /help, !debug            
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'tcj' & return & endif
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
freexy
;
kount=0
for nrec=0,!acount-1 do begin
    get,!astack[nrec]
    seq=!b[0].procseqn         ; seq=1 RA TCJ  seq=2 Dec TCJ
    if seq ne pos_flag then goto,next
    case seq of
               1:raxx 
               2:decx
    endcase
;
    b & freexy & xx & g & Cfit_info,fname &
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


