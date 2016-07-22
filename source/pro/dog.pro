pro dog,pos_flag,help=help
;+
; NAME:
;       DOG
;
;            ====================================
;            Syntax: dog, position_flag,help=help
;            ====================================
;
;   dog  Automatic CONTINUUM data reduction.
;   ---  Assumes 3He 599 point TCJ RA/Dec DCR scan.
;        Assumes STACK is filled with what you want.
;
;        position_flag = 1  reduce RA  TCJ
;                        2  reduce Dec TCJ
;
;  V5.0 July 2007  
; V7.0 3may2013 tvw - added /help, !debug    
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'dog' & return & endif
;
freexy
;
kount=0
for nrec=0,!acount-1 do begin
    get,nrec
    seq=!b[0].procseqn         ; seq=1 RA TCJ  seq=2 Dec TCJ
    if seq ne pos_flag then goto,next
    case seq of
               1:raxx 
               2:decx
    endcase
;
    case kount of
                  0:begin
                    xx 
                    print,'set baseline NREGIONS' 
                    print,'input number of NREGIONS'
                    read,no_regions,prompt='# Regions = '
                    nrset,no_regions
                    print,'set NFIT' & read,nfit,prompt='NFIT = ' &
                    !nfit=nfit & freey & bb,!nfit & 
                    print,'set # Gaussians' & read,ngauss,prompt='NGAUSS = ' &
                    !ngauss=ngauss & gg,!ngauss &
;
                    !c_flag=1 & Cfit_info & !c_flag=0 &
                    end
               else:begin
                    b & freey & xx & g & 
                    Cfit_info 
                    end
    endcase
;
    pause    
;
kount=kount+1
next:
endfor
; 
return
end


