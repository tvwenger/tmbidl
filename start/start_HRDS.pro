pro start_HRDS, filename,help=help
;+
; NAME:
;       START_HRDS
;
;       =====================================================
;       Syntax: start_HRDS,fully_qualified_filename,help=help
;       =====================================================
;
;
;   start_HRDS   INITIALIZES TMBIDL 
;   ----------   For GBT HRDS data 
;  
;                   If 'filename' passed, asks if this is 
;                   SDFITS (=0), ONLINE (=1), or NSAVE (=2) file. 
;                   Attaches accordingly.
;-
; V7.0 10jul2013 tmb - created to replace old "CUSTOM" option
;                      modelled on start_GBT_ACS.pro
;                      invokes package,'RRL' 
; V7.1 05aug2013 tmb - moved data file definition to
;                      .../tmbidl/data/INIT_DATA_FILES 
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_HRDS' & return & endif
;
print
print,'Initializing HRDS TMBIDL Mode'
print
;
ftype=99
nparm=n_params()
if filename eq '' then nparm=0
case nparm of
             0: goto,no_file_name_input
          else: goto,process_input_file
endcase
;
process_input_file:
filename=strtrim(filename,2)
print,'Input file is: '+filename
print,'Is file SDFITS (=0), TMBIDL(=1), or NSAVE (=2) ??? '
read,ftype,prompt='File type is: '
case ftype of 
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
                nslog=strmid(nsdat,0,len)+'.key'
                msg=datafile+' files are '+nsdat
                msg=msg+' and '+nslog
                end
           else:begin
                print
                print,'ERROR: Invalid file type choice!!'
                print
                goto,process_input_file
                end
endcase
;
no_file_name_input:
;
if ftype ne 0 then !data_points=4096  ; 3-Helium default
;
!nchan=!data_points 
; 
@tmbidl_header ; define {tmbidl_header} with tweaked header info
; define the {tmbidl_data} structure complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS
;
@../data/INIT_DATA_FILES  ; define data files
;
!recs_per_scan=16
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_GBT_ACS.log'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
; Attach data files if necessary
;
case ftype of 
              0: begin
                 make_ONLINE  ; create ONLINE data file from SDSFITS
                 online       ; attach this ONLINE file
                 end
              1: begin        ; attach existing ONLINE data file
                 attach,datafile,filename
                 online
                 end
              2: attach,datafile,nsdat,nslog ; attach existing NSAVE 
           else: 
endcase
;
type='ONLINE'
file='../data/line/Ldata.tmbidl'
attach,type,file
type='OFFLINE'
file='../data/continuum/Cdata.tmbidl'
attach,type,file
;
nson           ; write protect the nsave file
line           ; for spectral line  mode
tp             ; TP mode
!config=1      ; 7ALPHA ACS tuning
;
nsave='NSAVE'
nsavedat='../data/nsaves/nstest.LNS'
nsavelog='../data/nsaves/nstest.LNS.key'
attach,nsave,nsavedat,nsavelog
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
epoch="NOW"
start_epoch,epoch
;
package,'RRL'  ; HRDS needs RRL analysis code so make it default at start
;
fault:  begin
        print,!err_string
        return
        end
;
return
end
