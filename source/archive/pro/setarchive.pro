pro setarchive,type,help=help
;+
; NAME:
;      SETARCHIVE
;    
;      setarchive,type  Sets the variable !archivetype that selects
;      ===============  the format of the ARCHIVE file write
;                       
;                =================================
;                Syntax: setarchive,type,help=help
;                =================================
;-
; V5.0 July 2007
; V5.1 July 2008 modified print statement 
; V7.0 03may2013 tvw - added /help, !debug
;-
;
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'setarchive' & return & endif
;
archiveformat=['LHEAD','CHEAD','FITINFO','CUSTOM']
;
if n_params() eq 0 then begin
   print
   print,'Current ARCHIVE format is '+archiveformat[!archivetype]
   print,'Syntax: setarchive,type'
   print,'Available formats are:'
   print,'          type = 0  LHEAD     Spectral Line Header info'
   print,'                 1  CHEAD     Continuum Header info'
   print,'                 2  FITINFO   Baseline and Gaussian fit info'
   print,'                 3  CUSTOM    Custom format'
   print,'Do you wish to keep the current ARCHIVE format selection? (y/n)'
   ans=get_kbrd(1)   
   if ans ne 'n' then goto,flush
;
   type=' '
   print,'Input ARCHIVE type with an integer: '
   read,type,prompt='Set ARCHIVE type to '
end
;
proceed:
!archivetype=type
;
flush:
print,'The format for the ARCHIVE record is now: ' + archiveformat[!archivetype]
;
return
end

