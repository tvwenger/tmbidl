pro start_GBT_VEGAS, filename,help=help
;+
; NAME:
;       START_GBT_VEGAS
;
;            ==========================================================
;            Syntax: start_GBT_VEGAS,fully_qualified_filename,help=help
;            ==========================================================
;
;
;   start_GBT_VEGAS   INITIALIZES TMBIDL 
;   ---------------   For GBT VEGAS spectral line data.
;  
;                   If 'filename' passed, asks if this is 
;                   SDFITS (=0), ONLINE (=1), or NSAVE (=2) file. 
;                   Attaches accordingly.
;-
; V7.1 08jul2014 tvw - creation
;      09jul1214 tmb - tweaked
;      27may2015 tmb - tweaked for VEGAS tests 
;       1jul2015 tmb - cleaned up startup appearance
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_GBT_VEGAS' & return & endif
;
print
print,'Initializing GBT VEGAS Spectral Line TMBIDL v8.0'
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
;if ftype ne 0 then !data_points=4096  ; 3-Helium default
if ftype ne 0 then !data_points=8192   ; VEGAS default
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
; Code below is executed by ../startup/START.TMBIDL
;@../../data/INIT_DATA_FILES  ; define data files
;@../data/INIT_DATA_FILES  ; define data files
;
!recs_per_scan=128
; initialize the plot window and iconify, perhaps;
gbt_win
cgbt_win
line
;
!jrnl_file='../saves/jrnl_GBT_VEGAS.log'
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
;type='ONLINE'
;file='/data/gbt/vegas/tmbidl/Ldata_14B_431_06.tmbidl'
;file='/idl/tmbidlV8/data/line/14B/Ldata_14B_431_08.tmbidl'
;attach,type,file
;
;type='OFFLINE'
;file='/data/gbt/vegas/tmbidl/Ldata_14B_431_07.tmbidl'
;attach,type,file
;
nson           ; write protect the nsave file
line           ; for spectral line  mode
tp             ; TP mode
!config=6      ; VEGAS tuning 
;
nsave='NSAVE'
;nsavedat='../../data/nsaves/VEGAS.LNS'
;nsavelog='../../data/nsaves/VEGAS.LNS.key'
;attach,nsave,nsavedat,nsavelog
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
epoch="NOW"
start_epoch,epoch
;
; invoke VEGAS package
package,'VEGAS'
;
; Oct 2014 SDFITS data
;fvegas='/home/scratch/dbalser/vegas/AGBT14B_431_04.avg.vegas.fits'
;
; Apr 2015 VEGAS SDFITS
;
fault:  begin
        print,!err_string
        return
        end
;
return
end
