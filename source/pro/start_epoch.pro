pro start_epoch,epoch,help=help
;+
; NAME:
;       START_EPOCH
;
;            ===========================================
;            Syntax: start_epoch, 'epoch_name',help=help
;            ===========================================
;
;   start_epoch   Prompts for epoch label: format is MMYY.
;   -----------   Syntax: start_epoch,'JN04'  
;                     If argument is omitted it will prompt.
;-
; MODIFICATION HISTORY:
;   MA05 RTR fixed Error
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug

;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'start_epoch' & return & endif
;
if n_params() eq 0 then begin
   print,'no quotes needed' 
   print
   epoch=' '
   read,epoch,prompt='What epoch is this? (format is MMYY): '
endif
;
epoch=strtrim(epoch,2)
len=strlen(epoch)-1
!epoch=byte('    ')
!epoch[0:len]=byte(epoch)
!this_epoch=byte('    ')
!this_epoch[0:len]=byte(epoch)
!data_type=byte('    ')
!data_type=byte('EPAV')
;
return
end


