pro data_edited,rec,intmode,help=help
;+
; NAMES:
;       DATA_EDITED
;
; data_edited.pro   writes a message to message file to record
; ---------------   data editted for RFI in DAZE average
;
;               Syntax: data_edited,rec,intmode,help=help
;               =========================================
;                       rec = record number
;                       intmode = 'simple' or 'complex'
;
;                  assumes that the data are in !b[0]
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() lt 2 or keyword_set(help) then begin & get_help,'data_edited' & return & endif
;
; Define the message file first time invoked: either create a new one 
;                                             or attach an existing one
;
default='../data/messages'      ; default name assigned in INIT_FILES_V5.0
if strmatch(!messfile,default) then begin
   print
   print,'Must initialize MESSAGE FILE !'
   fname=' '
   read,fname,prompt='Enter fully qualified file name (no quotes!): '
   fname=strtrim(fname,2)
;
   print,'Does this MESSAGE FILE already exist?  (y/n)'
   ans=get_kbrd(1)
   case ans of
       'y':begin
           openw,!messunit,fname
           !messfile=fname
           print,'Creating MESSAGE FILE named ' + fname
           printf,!messunit,'==========================================='
           printf,!messunit,'     TMBIDL Message File for Epoch: ' + string(!this_epoch)
           printf,!messunit,'==========================================='
           close,!messunit
           end
      else:print,'Attaching existing MESSAGE FILE named ' + fname 
   endcase
end
;
why=''
why=intmode
src=string(!b[0].source)            ; source name
scn=!b[0].scan_num                              ; scan number
polid=strtrim(string(!b[0].pol_id),2)           ; polarization ID
lid=strtrim(string(!b[0].line_id),2)            ; line ID
date=strtrim(string(!b[0].date),2)              ; date of observation    
;
slst=adstring(!b[0].lst/3600.)                  ; LST as HH MM SS string
az=!b[0].az                                     ; azimuth  degrees
el=!b[0].el                                     ; elevation degrees
day=''
day=string(!data_type)
fmt1='(''#AVG_IntEd: '',a8,1x,i6,i6,a3,a6,1x,a4,i4,i4,1x,a8)'
lun=!messunit
file=!messfile
openu,lun,file,/append
printf,lun,src,scn,rec,polid,lid,day,az,el,why, FORMAT=fmt1
print,src,scn,rec,polid,lid,day,az,el,why, FORMAT=fmt1
;
close,lun
;
return
end

