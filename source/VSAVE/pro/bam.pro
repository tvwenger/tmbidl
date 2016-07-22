;+  
; NAME:
;      BAM
;
;   bam.pro   ACCUM and AVE the records in the STACK
;   -------   Displays each scan pair and offers options: 
;             delete from the average (i.e. no ACCUM)              
;             and/or RFI excision
;
;             RTR adds writes to a message file 505
;             0609 RTR fixes the -NaN loop buster
;             Syntax: bam 
;             -----------
;
; V5.0 July 2007
;-   
pro bam
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
flag=!flag     ; force flagon
!flag=1
cursor=!cursor ; force curoff
!cursor=0
bmark=!bmark   ; force nregion display off
!bmark=0
zline=!zline   ; force zline display off
!zline=0
;
tossed=0.0d
for i=0,!acount-1 do begin 
    acquire,abs(!astack[i])
    tsys=!b[0].tsys
    if finite(tsys) ne 1 then begin
        scn=!b[0].scan_num
        rec=!astack[i]
        print,'Record ',rec,' Scan ',scn, '-NaN data. Tossed'
        tossed=tossed+!b[0].tintg 
        ans=' '
        print,'Type any key to continue'
        ans=get_kbrd(1)
        goto,endloop
    end
    xxf
    hdr
    print,'RECORD NUMBER = ' + fstring(!astack[i],'(i6)')
    start=ceil(0.05*!data_points)
    stop =!data_points - start 
    try_again:
    rms,sigma,start,stop             ;  calculate RMS in inner 90% of channels
    recno=abs(!astack[i])
    xrange=!x.range
    print,'Include in average? (y=yes q=exit the loop x=enter RFI excision mode anything else means NO)'
    ans=get_kbrd(1)
    case ans of
                'y': accum
                'q': return
                'x': begin
                     cursor=!cursor
                     !cursor=1         ; force cursor on
                     print,'Is RFI simple (s) or complex (c) ?'
                     ians=get_kbrd(1)
                     case ians of 
                                  's': begin
                                       print,'Set xrange with cursor:'
                                       setx & xxf &
                                       rfi                 
                                       data_edited,recno,'simple'
                                       end
                                  'c': begin
                                       print,'Set xrange with cursor:'
                                       setx & xx &
                                       print,'Input # NREGIONs for MRSET'
                                       nreg=0
                                       read,nreg,prompt='Input # nregs: '
                                       mrset,nreg
                                       print,'Input order of baseline fit: '  
                                       read,nreg,prompt='Input baseline nfit'        
                                       nrfi,nreg
                                       data_edited,recno,'complex'
                                       end
                                 else: begin
                                       print,'Not trying RFI excision'
                                       goto, try_again
                                       end 
                                   endcase
                     print,'<CR> to return'
                     ians=get_kbrd(1)  ; the pause that refreshes
                     !x.range=xrange & xxf &
                     !cursor=cursor
                     goto, try_again
                     end
              else : begin
                     print, 'Not averaging rec#'+ $
                             fstring(abs(!astack[i]),'(I10)')
                     tossed=tossed+!b[0].tintg 
                     data_tossed,recno,tossed
                     end
    endcase
endloop:
endfor 
ave 
show
tossed=tossed/60.d
print,fstring(tossed,'(f8.1)')+' Tintg not averaged'
;
!flag=flag         ;  return flag to original state
!cursor=cursor     ;  return cursor to original state
!bmark=bmark       ;  return nregion display mode to original state
!zline=zline       ;  return zline display mode to original state
;
return
end
