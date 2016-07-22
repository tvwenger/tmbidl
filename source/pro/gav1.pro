pro gav1,nsave1,nsave2,help=help
;+
; NAME:
;       GAV1
;
;            ======================================
;            Syntax: gav1, nsave1, nsave2,help=help
;            ======================================
;
;   gav1  Averages 2 EPAVs tags as GAV and SAVEs
;   ----   
;         nsave1 & nsave2 are epoch avs
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() lt 2 or keyword_set(help) then begin & get_help,'gav1' & return & endif
;
clrstk
add,nsave1
add,nsave2
daze
this_epoch=string(!this_epoch)
data_type=' RAV' 
tagtype,data_type+'_'+this_epoch
xx
lmarker
!lastns=!lastns+1
lastns=!lastns
print,'Save in NSAVE= '+fstring(lastns,'(i4)')+' ? (y or n)'  
ans=get_kbrd(1)
case ans of
        'y': begin
             putavns,lastns
             end
      else : begin
             print, 'Enter new NSAVE location (0 aborts)'
             read,lastns
             if lastns le 0 then begin
                print,'Data NOT saved!'
                goto, loop
                end
             putavns,lastns
             !lastns=lastns
             end
endcase
;
    loop:
return
end

