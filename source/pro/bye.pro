pro bye,help=help
;+
; NAME:
;       BYE
;
;            =====================
;            Syntax: bye,help=help
;            =====================
;
;   bye  procedure to copy the journal file to 
;   ---  a file in '../journal/' and then exit IDL
;
;        TMBIDL creates !jrnl_file name at startup
;        that is DIFFERENT for each configuration.
;  
;        BYE uses the name and the system time to
;        define the journal file name written to
;        ../journal/
;
;  EXAMPLE:  start,10 is the TMB IDL sandbox which
;            has !jrnl_file = '../saves/jrnl_TMB'
;
;  TMBIDL-->bye
;  Wed_Mar__2_09:44:15_2011
;
;  Copied Journal file to: ../journal/jrnl_TMB_Wed_Mar__2_09:44:15_2011
;
;  Now exiting IDL in standard fashion.
;
; MODIFICATION HISTORY:
;
; 27feb2011 tmb 
; 01mar2011 tmb modified for V6.1 file structure
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'bye' & return & endif
;
journal ; close the open journal file with 'journal' command
;
journal_file=!jrnl_file
fdecomp,journal_file,disk,dir,name,old_ext
;
time=systime()
pos=0
; replace blanks in time string with '_' 
while pos ne -1 do begin & 
      pos=strpos(time,' ') &
      if pos ne -1 then strput,time,'_',pos &
endwhile
;
new_jou_file='../journal/'+name+'_'+time
;
; copy journal file 
;
command='cp '+!jrnl_file+' '+new_jou_file
spawn,command
;
print,time
print
print,'Copied Journal file to: ',new_jou_file
print
print,'Now exiting IDL in standard fashion.'
print
;
; now exit IDL
;
exit 
;
return
end
