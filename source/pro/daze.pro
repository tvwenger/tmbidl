pro daze,help=help
;+  
; NAME:
;       DAZE
;
;   daze   ACCUM and AVE the NSAVEs in the STACK
;   ----   Displaying each NSAVE and offer option
;          of deleting it from the average (i.e. no ACCUM)              
;
;                           
;              ======================
;              Syntax: daze,help=help
;              ======================
;              rtr fixed polid tag
;
; V5.0 July 2007
;      1 July 2011 tmb  added RFI excision capability 
; V7.0 3may2013 tvw - added /help, !debug
;-   
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'daze' & return & endif
;
cursor=!cursor
!cursor=0         ; force cursor off
;
tossed=0.0d
npol=1
for i=0,!acount-1 do begin 
    getns,abs(!astack[i]) 
    xx
    hdr
    polid=strtrim(string(!b[0].pol_id),2)           ; polarization ID
    if i eq 0 then polid1=polid                     ; if pol ID changes
    if polid ne polid1 then npol=2                  ; then thi is an L+R average
    start=ceil(0.05*!data_points)
    stop =!data_points - start 
    try_again:
    rms,sigma,start,stop             ;  calculate RMS in inner 90% of channels
;
    print
    print,'Include in average? (y=yes x=enter RFI excision mode anything else means NO)'
    pause,ans
    case ans of
                'y': accum
                'x': begin
                     xrfi
                     print,'<CR> to return'
                     ians=get_kbrd(1)  ; the pause that refreshes
                     xroll & xx &
                     !cursor=cursor
                     goto, try_again
                     end
              else : begin
                     print, 'Not averaging NSAVE #'+ $
                             fstring(abs(!astack[i]),'(I10)')
                     tossed=tossed+!b[0].tintg 
                     end
    endcase
endfor 
ave 
;
this_epoch=string(!this_epoch)
data_type=string(!data_type)
tagtype,'EPAVE'+'_'+this_epoch
if npol eq 2 then polid='L+R'
!b[0].pol_id=byte(polid)
;
show
tossed=tossed/60.d
print,fstring(tossed,'(f8.1)')+' Tintg not averaged'
;
!cursor=cursor     ; return cursor to entry state
;
return
end
