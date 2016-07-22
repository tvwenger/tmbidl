;+  
; NAME:
;       DAZE
;
;   daze   ACCUM and AVE the NSAVEs in the STACK
;   ----   Displaying each NSAVE and offer option
;          of deleting it from the average (i.e. no ACCUM)              
;
;                           
;              ============
;              Syntax: daze
;              ============
;              rtr fixed polid tag
;              3/09 rtr changed xx to xxf; changed epav flag from
;                                          EPAVE to EPAV
; V5.0 July 2007
;-   
pro daze
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
cursor=!cursor
!cursor=0         ; force cursor off
;
tossed=0.0d
npol=1
for i=0,!acount-1 do begin 
    getns,abs(!astack[i]) 
    xxf
    hdr
    polid=strtrim(string(!b[0].pol_id),2)           ; polarization ID
    if i eq 0 then polid1=polid                     ; if pol ID changes
    if polid ne polid1 then npol=2                  ; then thi is an L+R average
    start=ceil(0.05*!data_points)
    stop =!data_points - start 
    rms,sigma,start,stop             ;  calculate RMS in inner 90% of channels
;
    print
    print,'Include in average? (y=yes)'
    ans=get_kbrd(1)
    case ans of
                'y': accum
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
tagtype,'EPAV'+'_'+this_epoch
if npol eq 2 then polid='L+R'
!b[0].pol_id=byte(polid)
;
xxf
tossed=tossed/60.d
print,fstring(tossed,'(f8.1)')+' Tintg not averaged'
;
!cursor=cursor     ; return cursor to entry state
;
return
end
