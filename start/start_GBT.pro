pro start_GBT,filename,help=help
;+
; NAME:
;       START_GBT
;
;            ====================================================
;            Syntax: start_GBT,fully_qualified_filename,help=help
;            ====================================================
;
;
;   start_GBT   INITIALIZES TMBIDL for GBT 3-Helium data.
;   --------- 
;               If 'filename' passed, asks if this is 
;               SDFITS (=0), ONLINE (=1), or NSAVE (=2) file. 
;               Attaches accordingly.
;-
; V5.0 July 2007                 
; modified Oct 2007 by tmb to do input file connection correctly
;
; V6.0 June 2009
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_GBT' & return & endif
;
print
print,'Initializing TMBIDL for GBT 3-Helium data'
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
;try_again:
;print,'Input fully qualified data file name (no quotes!)'
;filename=' '
;read,filename,prompt='File name is: '
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
                nslog=strmid(nsdat,0,len)+'.log'
                msg=datafile+' files are '+nsdat
                msg=msg+' and '+nslog
                end
           else:begin
                print
                print,'Invalid file type choice!!'
                print
;                goto,try_again
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
!recs_per_scan=16
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_GBT_3He.log'
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
           else: init_NSAVE   ; else ask to make an NSAVE 
endcase
;
type='ONLINE'
file='/users/tbania/idl/data/line/dat/Ldata.gbt'
attach,type,file
type='OFFLINE'
file='/users/tbania/idl/data/continuum/dat/Cdata.gbt'
attach,type,file
;
nson           ; write protect the nsave file
line           ; for spectral line  mode
tp             ; TP mode
!config=1      ; 7ALPHA ACS tuning
;
nsave='NSAVE'
nsavedat='/users/tbania/idl/data/nsave/ljun08.dat'
nsavelog='/users/tbania/idl/data/nsave/ljun08.log'
attach,nsave,nsavedat,nsavelog
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
epoch="JN08"
start_epoch,epoch
;
fault:  begin
        print,!err_string
        return
        end
;
return
end
