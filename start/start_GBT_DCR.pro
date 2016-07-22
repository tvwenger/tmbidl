
pro start_GBT_DCR,filename,help=help
;+
; NAME:
;       START_GBT_DCR
;
;            ===============================
;            Syntax: start_GBT_DCR,help=help
;            ===============================
;
;   start_GBT_DCR   INITIALIZES TMBIDL for GBT DCR continuum data
;   ------------- 
;-
; MODIFICATION HISTORY:
; V5.0 July 2007                 
; by tmb 31jul07 to deal with {tmbidl_data] redefinition
;    tmb 19jul08 created DCR startup file for continuum
;
; V6.0 June 2009
; V7.0 03may2013 tvw - added /help, !debug
;      03jul2013 tmb - fixed .log vs .key NSAVE and ftype bugs
; V7.1 05aug2013 tmb - moved .../tmbidl/v7.1/startup/INIT_DATA_FILES
;                      to .../tmbidl/data/
;                tvw - provided DCR data NSAVE files 
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_GBT_DCR' & return & endif
;
print
print,'Initializing TMBIDL for GBT DCR Continuum Data'
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
typ=0
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
               print,'Invalid file type choice!!'
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
@tmbidl_header    ; define {tmbidl_header} with tweaked header info
                  ; that nonetheless has same 1024 byte size
;Now we know !data_points so define the {tmbidl_data} structure
;complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS      ; initialize system variables
;
@../data/INIT_DATA_FILES  ; define data files
;
!recs_per_scan=16
;!recs_per_scan=8
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_GBT_DCR'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
cont      ; pick CONTinuum mode
;
; PROVIDE THE CORRECT FILE NAMES !!! and uncomment the ATTACHes
;
!c_SDFITS=' '
;
onfile='ONLINE'
file='../data/line/Ldata.tmbidl'  ; GBT default
;attach,onfile,file
;online
offile='OFFLINE'
filename='../data/continuum/Cdata.tmbidl'
attach,offile,filename
offline
nsave='NSAVE'
data='../data/nsaves/nstest.CNS'
key='../data/nsaves/nstest.CNS.key'
attach,nsave,data,key
epoch='NOW'
start_epoch,epoch
;
!config=1      ; 7ALPHA ACS tuning
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
freexy
;
goto,flush
;
fault:  begin
        print,!err_string
        return
        end
;
flush:
return
end
