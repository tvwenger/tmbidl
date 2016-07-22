pro bam,exclude,auto=auto,flags=flags,message=message,help=help
;+  
; NAME:
;      BAM
;
;      ===================================================================
;      SYNTAX: bam,exclude,auto=auto,flags=flags,message=message,help=help
;      ===================================================================
;
;   bam   ACCUM and AVE the records in the STACK
;   ---   Displays each scan pair and offers options: 
;         delete from the average (i.e. no ACCUM)              
;         and/or RFI excision
;
;         OUTPUT:  exclude - array of records to ignore
;                            in all further processing
;
;         KEYWORDS:  help    -- gives this help
;                    auto    --  skips queries for each spectrum 
;                                i.e. AUTOmatically averages 
;                                (default is NOT \auto) 
;                    message -- if set asks for reason
;                               that data are bad
;                    flags   -- choose whether and how to show the flags:
;                               0=> NO flags (default) 1=>'rrlflag' 2=> 'flags'
;
;-
;             RTR adds writes to a message file 505
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;      16jul2013 tmb - added exclude a la lda 
;                      added keywords /message /auto /flags
;      17jul2013 tmb - fixed RFI 'cans' bug
;
;-   
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'bam' & return & endif
if Keyword_Set(auto) then cans='y'  ; YES include everything in the average
if ~Keyword_Set(flags) then flags=0 
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
exclude=lonarr(!acount) ; define exclude array based on STACK
for i=0,!acount-1 do begin 
    acquire,abs(!astack[i])
    xx
    hdr
    print,'RECORD NUMBER = ' + fstring(!astack[i],'(i6)')
    start=ceil(0.05*!data_points)
    stop =!data_points - start 
    try_again:
    rms,sigma,start,stop             ;  calculate RMS in inner 90% of channels
    recno=abs(!astack[i])
;
    if Keyword_Set(auto) then goto,auto_mode ; skip the inquiry of /auto set
; sturm und drang over the damn flagging
    case flags of 
               1: rrlflag
               2: flags
            else: 
    endcase
    IF finite(!b[0].tsys) THEN BEGIN ; lda change 16sep12
       print,'Include in average? (y=yes x=enter RFI excision mode anything else means NO)'
       pause,cans
    ENDIF ELSE BEGIN
       cans='n'
       print,'Spectrum is NaNs !!! Excluding from further analysis.'
    ENDELSE
;
auto_mode:
;
    case cans of
                'y': accum
                'x': begin
                     cursor=!cursor
                     !cursor=1         ; force cursor on
                     print,'Is RFI simple (s) or complex (c) ?'
                     pause,cans,ians
                     case cans of 
                                  's': begin
                                       print,'Set xrange with cursor:'
                                       setx & xx &
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
                     if ~Keyword_Set(auto) then pause ; the pause that refreshes
                     xroll & xx &
                     !cursor=cursor
                     goto, try_again
                     end
              else : begin
                     print, 'Not averaging rec#'+ $
                             fstring(abs(!astack[i]),'(I10)')
                     exclude[i]=1
                     tossed=tossed+!b[0].tintg 
                     if Keyword_Set(message) then data_tossed,recno,tossed
                     end
    endcase
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
