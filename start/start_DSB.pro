pro start_DSB,filename,help=help
;+
; NAME:
;       START_DSB
;
;            ===========================
;            Syntax: start_DSB,help=help
;            ===========================
;
;   start_DSB  INITIALIZES TMBIDL for DSB
;   ---------
;-
; MODIFICATION HISTORY:
; V5.1 27aug08 tmb 
;
; V6.0 June 2009
; V6.1 August 2011 modified for GBT Project 11B17 Methanol Masers  Ku
; band
; V7.0 03may2013 tvw - added /help, !debug
; V7.1 06aug2013 tmb - tweaked so that it compiles 
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_DSB' & return & endif
;
print
print,'Initializing TMBIDL for DSB'
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
@../data/INIT_DATA_FILES  ; define data files
;
!recs_per_scan=16
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_DSB'
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
nsavekey='../data/nsaves/nstest.LNS.key'
attach,nsave,nsavedat,nsavekey
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
epoch="NONE"
start_epoch,epoch
;
fault:  begin
        print,!err_string
        return
        end

return
end
