
;+
; NAME:
;       START_EPOCH
;
;            =================================
;            Syntax: start_epoch, 'epoch_name'
;            =================================
;
;   start_gav   Prompts for info to set up GAV
;   -----------   Syntax: start_gav  
;  
;
; MODIFICATION HISTORY:
;   RTR new 03/09
; 
; 
;   
;-
pro start_gav
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
;
print,'Setting up to do grand averages'
print,'Enter 4 character identifier (no quotes)'
print,'For example, date 3/09'
epoch=' '
read,epoch,prompt='GAV ID: '
epoch=strtrim(epoch,2)
len=strlen(epoch)-1
!epoch=byte('    ')
!epoch[0:len]=byte(epoch)
!this_epoch=byte('    ')
!this_epoch[0:len]=byte(epoch)
!data_type=byte('    ')
!data_type=byte(' GAV')
print,'Enter NSAVE range for daily averages of this epoch: nslow,nshigh'
read,nslow,nshigh
!nslow=nslow
!nshigh=nshigh
print,'NSAVE RANGE for daily averages ',nslow,nshigh
;
print,'You are now set up to use epav to do grand aves'
return
end


