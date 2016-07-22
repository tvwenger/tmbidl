pro god,nrec,help=help
;+
; NAME:
;       GOD
;
;            ===========================
;            Syntax: god, nrec,help=help
;            ===========================
;
;   god  Automatic CONTINUUM data reduction.
;   ---  Assumes 3He 599 point TCJ RA/Dec DCR scan.
;
;        nrec= record number of TCJ
;-         
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'god' & return & endif
;
chan
!nfit=2                    ; parabolic baseline
curoff
nreg=[5,200,400,595]       ; hardwire 2 nregions for
nrset,2,nreg               ; baseline fit in CHAN mode
curon
;
get,nrec
b
freexy
;
seq=!b[0].procseqn         ; seq=1 RA TCJ  seq=2 Dec TCJ
;
case seq of
           1:begin 
             raxx 
             for i=0,2*!nrset-1 do begin
                   idval,!nregion[i],xval
                   !nregion[i]=xval
                   end
             xx 
             end
           2:begin 
             decx
             for i=0,2*!nrset-1 do begin
                   idval,!nregion[i],xval
                   !nregion[i]=xval
                   end
             xx
             end
endcase
;
gg,1
;
return
end


