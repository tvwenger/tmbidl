pro start_TMB, filename,help=help
;+
; NAME:
;       START_TMB
;
;            ===========================
;            Syntax: start_TMB,help=help
;            ===========================
;
;   start_TMB  INITIALIZES TMBIDL for TMB
;   ---------
;-
; MODIFICATION HISTORY:
; V5.1 27aug08 tmb 
;
; V6.0 June 2009
;  6.1 tmb 22sept09  adjustments for HII Survey analysis
;      tmb 02mar2011 adjustments for 3He Baseline Program 
; V7.0 03may2013 tvw - added /help, !debug
; V7.1 05aug2013 tmb - moved data definition to 
;                      .../tmbidl/data/
;                      deleted directory ../v7.1/data_def 
; V8.0 23feb2016 tmb - VEGAS Cband tests 14B_431_10
;      10mar2016 tmb - VEGAS 
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_TMB' & return & endif
;
print
print,'Initializing TMBIDL v8 for TMB'
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
;if ftype ne 0 then !data_points=4096  ; 3-Helium default
if ftype ne 0 then !data_points=8192  ; VEGAS default
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
;@/idl/tmbidl/sandboxes/tmb/INITIALIZE_TMB   ; define special TMB stuff
;@/idl/tmbidl/sandboxes/tmb/GLOBALS_TMB
;@/idl/tmbidl/sandboxes/tmb/COMPILE_TMB


;
;!recs_per_scan=16  ; ACS
!recs_per_scan=128 ; VEGAS C bans
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_TMB'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
;kpc3line="/data/gbt/hii/tmbidl/line/l.kpc3"
;kpc3nsave="/idl/tmbidl/data/nsaves/kpc3.lns.1"
;kpc3nsavekey="/idl/tmbidl/data/nsaves/kpc3.lns.key.1"
;
; HII Survey NSAVEs;
;
;hii_line="/data/gbt/hii/tmbidl/line/l.hii"
;hii_GBT="/idl/idl/hii/lda/master.survey.table"
;GBTsurvey="GBT_VLSR_Rgal_cat.dat"
;Paladini="PaladiniVLSR_Rgal_cat.dat"
;
;nsav0="/idl/tmbidl/data/nsaves/hii.lns.0"
;nkey0="/idl/tmbidl/data/nsaves/hii.lns.key.0"
;nsav1="/idl/tmbidl/data/nsaves/hii.lns.1"
;nkey1="/idl/tmbidl/data/nsaves/hii.lns.key.1"
;nsav2="/idl/tmbidl/data/nsaves/hii.lns.2"
;nkey2="/idl/tmbidl/data/nsaves/hii.lns.key.2"
;nsav3="/idl/tmbidl/data/nsaves/hii.lns.3"
;nkey3="/idl/tmbidl/data/nsaves/hii.lns.key.3"
;nsav4="/idl/tmbidl/data/nsaves/hii.lns.4"
;nkey4="/idl/tmbidl/data/nsaves/hii.lns.key.4"
;nsav5="/idl/tmbidl/data/nsaves/hii.lns.5"
;nkey5="/idl/tmbidl/data/nsaves/hii.lns.key.5"
;nsall="/idl/tmbidl/data/nsaves/hii.lns.all"
;nskey="/idl/tmbidl/data/nsaves/hii.lns.key.all"
nsav='/data/gbt/vegas/nsaves/14B/VEGAS.dat'
nskey='/data/gbt/vegas/nsaves/14B/VEGAS.key'
;
; continuum data 
;
;cdata='/data/gbt/hii/tmbidl/cont/c.hii'
;cnsav0="/idl/tmbidl/data/nsaves/hii.cns.0"
;cnkey0="/idl/tmbidl/data/nsaves/hii.cns.key.0"
;
; 3He baseline project
;
; line nsave
;lsav0='/data/gbt/he3/nsaves/line/he3.lns.0'
;lsav11A='/data/gbt/he3/nsaves/line/11A_043/he3.lns.0'
;lsav12A='/data/gbt/he3/nsaves/line/12A_114/he3.lns.0'
;lkey0='/data/gbt/he3/nsaves/line/he3.lns.key.0'
;lkey11A='/data/gbt/he3/nsaves/line/11A_043/he3.lns.key.0'
;lkey12A='/data/gbt/he3/nsaves/line/12A_114/he3.lns.key.0'
;
; continuum nsave
;csav0='/data/gbt/he3/nsaves/cont/he3.cns.0'
;ckey0='/data/gbt/he3/nsaves/cont/he3.cns.key.0'
; ONLINE file
;onfile='/data/gbt/he3/tmbidl/line/l.he3'
;onfile=tl05
;offile=tl06
;offile=lsav12A
;
offline='OFFLINE'
;file='../data/continuum/Cdata.tmbidl'
;file='/data/gbt/hii/tmbidl/cont/c.hii'
;file=hii_line
attach,offline,line12
offline
;
online='ONLINE'
;file='../data/continuum/Cdata.tmbidl'
;file='/data/gbt/hii/tmbidl/line/l.hii'
;file=cdata
;onfile='/idl/tmbidlV8/data/line/14B/Ldata_14B_431_10.tmbidl'
attach,online,lineall
online
;
nsave='NSAVE'
;mode=0    ; analyze KPC3 project
;mode=1    ; analyze HII Survey project
;mode=2     ; analyze 3He baseline project 
mode=2     ; analyze VEGAS C band tests
;
case mode of 
          0:begin
            ;attach,type,kpc3line
            attach,nsave,kpc3nsave,kpc3nsavekey
            epoch="KPC3"
         end
          1:begin 
            ;attach,type,nsav0
            attach,nsave,cnsav0,cnkey0
            epoch="HII"
         end
          2:begin 
            ;attach,type,nsav0
;            attach,nsave,lsav11A,lkey11A
;            attach,nsave,lsav12A,lkey12A
            attach,nsave,nsav,nskey
;            attach,online,onfile
;            attach,offline,offile
            epoch="NOW"
            day="S10"
         end
endcase
;
start_epoch,epoch
day=' '
;read,day,prompt='Input Session (Sxx): '
;start_day,day
;
nson           ; write protect the nsave file
nroff          ; turn off NREGION display
line           ; for spectral line  mode
;cont           ; for continuum mode
;
;!config=1     ; 7ALPHA ACS tuning
;!config=4      ; 11A_043 & 12A_114 3-He tuning
!config=6      ;VEGAS tuning
;
files          ; show which files are being used 
clrstk         ; must clear the STACK because IDL starts arrays at 0
online
clearset
setsrc,'M51'
settype,'ON'
setid,'H107a'
;
select
;
;fetch,1152 & xroll & rrlflag
;
; invoke VEGAS package
package,'VEGAS'
;
;
;offline
;
;fetch,16
;freexy
;xx
;xroll
;xx
;
;type='7A B S G'
;settype,type
;
;GBTsurvey="/data/hii/GBT_VLSR_Rgal_cat.dat"
;data=1.
;read_table,GBTsurvey,data=data,/global
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
