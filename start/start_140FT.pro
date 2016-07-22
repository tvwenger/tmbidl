pro start_140FT,help=help
;+
; NAME:
;       START_140FT
;
;            =============================
;            Syntax: start_140FT,help=help
;            =============================
;
;   start_140FT   INITIALIZES TMBIDL for UniPops data archive
;   ----------- 
;-
;  V5.0 July 2007                
;  V6.0 June 2009
;  V7.0 03may2013 tvw - added /help, !debug
;       08jul2013 tmb - brought UNI package online 
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_140FT' & return & endif
;
print
print,'Initializing TMBIDL for NRAO 140-FT UniPops NSAVE ARCHIVE data'
print
;
; 3-Helium experiment 140-FT archive 
;
fname='../unipops/data/archive_140.dat'
!data_points=256 & !nchan=!data_points & 
;
@tmbidl_header ; define {tmbidl_header} with tweaked header info
; define the {tmbidl_data} structure complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS
;
!recs_per_scan=1 
;
package,'UNI'
;
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_140FT.log'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
nson           ; write protect the nsave file
line           ; for spectral line  mode
tp             ; TP mode
datafile='ONLINE'
attach,datafile,fname ; attach archival data to ONLINE file
online
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
; MOD III AC had 256 channels.  that's right 256 channels.
; we always BDROPed the first 42 channels. RTR stuffed them with
; NREGION information, etc. 
;
min=42 & max=250 & 
!x.range=[min,max] ; filter x-axis 
;
fault:  begin
        print,!err_string
        return
        end
;
return
end
