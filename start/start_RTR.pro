pro start_RTR,filename,help=help
;+
; NAME:
;       START_RTR
;
;            ===========================
;            Syntax: start_RTR,help=help
;            ===========================
;
;   start_RTR  INITIALIZES TMBIDL for RTR
;   ---------
;-
; MODIFICATION HISTORY:
; V5.1 27aug08 tmb 
;
; V6.0 June 2009
;
; v6.1 1march2012 tmb configured for SpiderContinuum work 
;       25oct2012 tmb configured for OSC arm analysis 12B_294
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_RTR' & return & endif
;
print
print,'Initializing TMBIDL for RTR'
print
;
ftype=99
nparm=n_params()
;if filename eq '' then nparm=0
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
;@INIT_DATA_FILES  ; define data files
;
!recs_per_scan=16
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_RTR'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
;cont      ; pick CONTinuum mode
line       ; pick spectral LINE mode
;
epoch='TLW'
start_epoch,epoch
;
!config=5      ; C-band Orion Te Project
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
freexy
;
ldata=tl01  ; s01 for 12B_129
sonline='ONLINE'
attach,sonline,ldata
online
nsdat='/data/gbt/te/nsaves/13B_189.LNS.dat'
nskey='/data/gbt/te/nsaves/13B_189.LNS.key'
snsave='NSAVE'
attach,snsave,nsdat,nskey
files
;
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
