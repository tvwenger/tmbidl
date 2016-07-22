pro start_LDA,filename,help=help
;+
; NAME:
;       START_LDA
;
;            ====================================
;            SYNTAX: start_LDA,filename,help=help
;            ====================================
;
;   start_LDA  INITIALIZES TMBIDL for LDA
;   ---------
;-
; MODIFICATION HISTORY:
; V5.1 27aug08 tmb 
;
; V6.0 June 2009
; V7.0 03may2013 tvw - added /help, !debug
; V7.1 06aug2013 tmb - make it work as a placeholder
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_LDA' & return & endif
;
print
print,'Initializing TMBIDL for LDA'
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
@tmbidl_header  ; define {tmbidl_header} with tweaked header info
                ; that nonetheless has same 1024 byte size
;Now we know !data_points so define the {tmbidl_data} structure
;complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS          ; initialize system variables
;
@../data/INIT_DATA_FILES  ; define data files
;
!recs_per_scan=16
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_LDA'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
;cont      ; pick CONTinuum mode
line       ; pick spectral LINE mode
;
epoch='LDA'
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
