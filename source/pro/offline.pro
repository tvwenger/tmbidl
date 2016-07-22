pro offline,help=help
;+
; NAME:
;      OFFLINE
;      offline,help=help
;
;   offline.pro   Choose OFFLINE data file for SELECT searches.
;   -----------   Toggles boolean !ONLINE, sets !koff, !recmin, !recmax,
;                 !scanmin, !scanmax.
;
;              => Use ATTACH to change OFFLINE file.  
;              => Must then issue OFFLINE to get correct file size parameters.
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'offline' & return & endif
;
!online=0     ;  choose the OFFLINE data file
;
print,'OFFLINE data file: '+!offline_data+' selected for searches'
;
openr,!offunit,!offline_data
;
kount=0L
rec=!rec
while eof(!offunit) ne 1 do begin
      readu,!offunit,rec
      kount=kount+1L
endwhile
;
!kount=kount & !koff=kount & !recmax=kount & !recmin=0 &
print,'OFFLINE data file contains '+fstring(!koff,'(i12)')+' records'
close,!offunit
!recmax=!recmax-1
get,!recmax
scan_max=!b[0].scan_num     ; set scan range to entire file
setrange,0,scan_max
;
return
end
