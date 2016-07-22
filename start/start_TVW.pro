pro start_TVW, filename,help=help
;+
; NAME:
;       START_TVW
;
;            ===========================
;            Syntax: start_TVW,help=help
;            ===========================
;
;   start_TVW  INITIALIZES TMBIDL for TVW:  Trey Wenger 
;   ---------
;-
; MODIFICATION HISTORY:
; V5.1 27aug08 tmb 
;
; V6.0 June 2009
;  6.1 tmb 22sept09  adjustments for HII Survey analysis
;      tmb 24jan12   added TVW 
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_TVW' & return & endif
;
print
print,'Initializing TMBIDL for TVW'
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
@../data/INIT_DATA_FILES  ; define data files
;
!recs_per_scan=16
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_TVW'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
!plot_file='/home/staff/tvw2pu/figures/idl.ps'
;
kpc3line="/data/gbt/hii/tmbidl/line/l.kpc3"
kpc3nsave="/home/staff/tvw2pu/tmbidl/data/nsaves/kpc3.lns.1"
kpc3nsavekey="/home/staff/tvw2pu/tmbidl/data/nsaves/kpc3.lns.key.1"
;
; HII Survey NSAVEs;
;
hii_line="/data/gbt/hii/tmbidl/line/l.hii"
hii_GBT="/idl/idl/hii/lda/master.survey.table"
GBTsurvey="GBT_VLSR_Rgal_cat.dat"
Paladini="PaladiniVLSR_Rgal_cat.dat"
;
nsav0="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.0"
nkey0="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.key.0"
nsav1="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.1"
nkey1="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.key.1"
nsav2="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.2"
nkey2="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.key.2"
nsav3="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.3"
nkey3="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.key.3"
nsav4="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.4"
nkey4="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.key.4"
nsav5="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.5"
nkey5="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.key.5"
nsall="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.all"
nskey="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.lns.key.all"
;
; continuum data 
;
;cdata='/data/gbt/hii/tmbidl/cont/c.hii'
;cnsav0="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.cns.0"
;cnkey0="/home/staff/tvw2pu/tmbidl/data/nsaves/hii.cns.key.0"
;
;type='ONLINE'
;file='../data/continuum/Cdata.tmbidl'
;file='/data/gbt/hii/tmbidl/cont/c.hii'
;file=hii_line
;attach,type,file
;
type='ONLINE'
;file='../data/continuum/Cdata.tmbidl'
file='/home/staff/tvw2pu/tmbidl/data/l.hii'
;file=cdata
attach,type,file
;
nsave='NSAVE'
;mode=0    ; analyze KPC3 project
mode=1     ; analyze HII Survey project
case mode of 
          0:begin
            ;attach,type,kpc3line
            attach,nsave,kpc3nsave,kpc3nsavekey
            epoch="KPC3"
         end
          1:begin 
            ;attach,type,nsav0
            attach,nsave,nsall,nskey
            epoch="HII"
         end
endcase
;
start_epoch,epoch
;
nson           ; write protect the nsave file
line           ; for spectral line  mode
;cont           ; for continuum mode
;
!config=1      ; 7ALPHA ACS tuning
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
freexy
xroll
;online
;offline
;
type='7A B S G'
settype,type
;
attach,nsave,nsall,nskey
getns,477
sx
;
;@/home/staff/tvw2pu/tmbidl/sandboxes/tmb/survey.tables
;
;restore,'/home/staff/tvw2pu/tmbidl/data/sav/hrdsV.sav'
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
