pro start_GRS,help=help
;+
; NAME:
;       START_GRS
;
;            ===========================
;            Syntax: start_GRS,help=help
;            ===========================
;
;   start_GRS   INITIALIZES TMBIDL for GRS.  Attaches GRS
;   ---------   data files automatically.
;
;  V5.0 July 2007                 
;
;  V6.0 June 2009
;  V6.1 Sept 2010 tmb finally migrates GRS from INANNA to NINKASI
;  V7.0 03may2013 tvw - added /help, !debug
;       13may2013 tmb - modified for package.pro 
;       02jul2013 tmb - tweaked proper startup
;  V7.1 05aug2013 tmb - removed unnecessary @INIT_DATA_FILES 
;  V8.0 15jun2016 tmb - hacked for NINKASI
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_GRS' & return & endif
;
try_again:
if n_params() eq 1 then begin
              filename=strtrim(filename,2)
              print,'Is file SDFITS (=0), TMBIDL(=1), or NSAVE (=2) ??? '
              typ=0
              read,typ,prompt='File type is: '
              case typ of 
                         0:begin
                           init_data,filename
                           end
                         1:begin
                           datafile='ONLINE'
                           print,datafile+' file is '+filename
                           end
                         2:begin 
                           datafile='NSAVE'
                           nsdat=filename 
                           len=strlen(nsdat) & len=len-4 &
                           nslog=strmid(nsdat,0,len)+'.log'
                           msg=datafile+' files are '+nsdat
                           msg=msg+' and '+nslog
                           end
                      else:begin
                           print
                           print,'Invalid file type choice!!'
                           print
                           goto,try_again
                           end
              endcase
endif
;
!data_points=659 ; GRS default
;
!nchan=!data_points 
; 
@tmbidl_header ; define {tmbidl_header} with tweaked header info
;
; define the {tmbidl_data} structure complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS  
;
;@INIT_DATA_FILES  ; define data files
;
print,'Initializing TMBIDL for BU-FCRAO Galactic Ring Survey: GRS'
;
package,'GRS'   ; install the GRS analysis package 
;
print,'============================================='
print,'Loaded GRS package system variables and files'
print,'============================================='
print     
; tmb 02jul2013 changes here 
;vgrs     ; default to LSR velocity x-axis
;freegrs  ; moved to GLOBALS_GRS
;nrtype   ; tmb added 
;
;
!recs_per_scan=1
;
!jrnl_file='../saves/jrnl_GRS.log'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
;if typ eq 0 then make_ONLINE  ; create ONLINE data file from SDSFITS
;if typ eq 1 then begin
;                 attach,1,filename
;                 online
;             endif
;if typ eq 2 then attach,3,nsdat,nslog
;if typ ne 2 then init_NSAVE   ; if not NSAVE file ask to make one 
;
;
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win        ; need to open even if no GRS continuum
;
line           ; for spectral line  mode
tp             ; TP mode
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
;fname='../data/grs/data/LVmap.dat'
fname='/data/GRS/data/LVmap.dat'     ; NINKASI hack 
online='ONLINE'
attach,online,fname
online
;
;nsdat='../data/nsaves/GRS/hrdsGRS.dat'
;nskey='../data/nsaves/GRS/hrdsGRS.key'
; NINKASI hacks 
nsdat='/data/GRS/nsaves/hrdsGRS.dat'
nskey='/data/GRS/nsaves/hrdsGRS.key'
nsave='NSAVE'
attach,nsave,nsdat,nskey
;
;attach,online,nsdat
;
nson           ; write protect the nsave file
;
files          ; show which files are being used 
;
;initgrs <== this for HRDS/CO analysis execute on command line 
;
fault:  begin
        print,!err_string
        return
        end
;
return
end
