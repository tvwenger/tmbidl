pro online,help=help
;+
; NAME:
;      ONLINE
;      online,help=help
;
;   online.pro   Choose ONLINE data file for SELECT searches.
;   ----------   toggles boolean !ONLINE, sets !kon, !recmin, !recmax,
;                !scanmin, !scanmax.
;
;             => Use ATTACH to change ONLINE file. 
;             => Must then issue ONLINE to get correct file size parameters.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
on_ioerror,oops
if keyword_set(help) then begin & get_help,'online' & return & endif
;
!online=1     ;  choose the ONLINE data file
;
print,'ONLINE data file: '+!online_data+' selected for searches'
;
openr,!onunit,!online_data
kount=0
rec=!rec
while eof(!onunit) ne 1 do begin 
      readu,!onunit,rec
      kount=kount+1
endwhile
;
!kount=kount & !kon=kount & !recmax=kount & !recmin=0 &
print,'ONLINE data file contains '+fstring(!kon,'(i12)')+' records'
;
close,!onunit
!recmax=!recmax-1
get,!recmax
scan_max=!b[0].scan_num     ; set scan range to entire file
setrange,0,scan_max
;
goto,flush
;
oops: begin
      print,'I/O error'
      print,'kount= ', kount
      close,!onunit
      return
      end
;
flush:
return
end
