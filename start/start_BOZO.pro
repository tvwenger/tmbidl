pro start_BOZO,filename,help=help
;+
; NAME:
;       START_BOZO
;
;            =====================================================
;            Syntax: start_BOZO,fully_qualified_filename,help=help
;            =====================================================
;
;   start_BOZO   INITIALIZES TMBIDL for ARECIBO data.
;   ---------- 
;               If 'filename' passed, asks for file type. 
;               Attaches accordingly.
;-
; V5.0 September 2007  
; V5.1 30Jan2009 tmb
;
; V6.0 June 2009
; V6.1 Oct 09 tmb verify interface to Bozo NSAVE data
;
; 2 April 2012 tmb A2500 HII region data
; V7.0 03may2013 tvw - added /help, !debug
;      03jul2013 tmb - modified to conform to start_GBT_ACS file handling...
;               
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_BOZO' & return & endif
;
;print
print,'=========================================='
print,'Initializing TMBIDL for ARECIBO ICORR data'
print,'=========================================='
;print
;
; Hardwire for A1804 and A2351 data
; Apr 2012 A2500 HII Region data 
; ==> v7.0 GIT install does NOT do this 
;
ftype=99
nparm=n_params()
if filename eq '' then nparm=0
case nparm of
     0: goto,no_file_name_input
  else: goto,process_input_file
endcase
process_input_file:
;
filename=strtrim(filename,2)
print,'Input file is: '+filename
print,'Is file SDFITS (=0), TMBIDL(=1), or NSAVE (=2) ??? '
read,ftype,prompt='File type is: '
case ftype of 
             0:begin ; translate the FITS file.  should be done at Arecibo
               init_data,filename
               end
             1:begin ; attach this tmbidl data file ONLINE
               datafile='ONLINE'
               print,datafile+' file is '+filename
               end
             2:begin ; attach this tmbidl data file as NSAVE
                     ; the key file must exist or you will be sorry
               datafile='NSAVE'
               nsdat=filename 
               len=strlen(nsdat) & len=len-4 &
               nskey=strmid(nsdat,0,len)+'.key'
               msg=datafile+' files are '+nsdat
               msg=msg+' and '+nskey
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
if ftype ne 0 then !data_points=1024  ; ARECIBO ICORR default
;
!nchan=!data_points 
; 
@tmbidl_header     ; define {tmbidl_header} with tweaked header info
; define the {tmbidl_data} structure complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS
;
package,'BOZO'   ; invoke Arecibo analysis package
;
!config=3        ; set flags for ARECIBO Interim Correlator
!recs_per_scan=8 ; 4 tunings x 2 polarizations 
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_BOZO.log'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
; act depending on input file type if any 
;
case ftype of 
             0: make_ONLINE  ; create ONLINE data file from SDSFITS
             1: begin        ; this is tmbidl format 
                attach,datafile,filename
                online
                end
             2: attach,datafile,nsdat,nskey ; tmbidl format to NSAVE
          else: 
endcase
               ;
nson           ; write protect the nsave file
line           ; for spectral line  mode
tp             ; TP mode
;
;
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
online='ONLINE' & offline='OFFLINE' & nsave='NSAVE'
nsdat='../arecibo/data/nsBOZO.dat'
nskey='../arecibo/data/nsBOZO.key'
attach,nsave,nsdat,nskey
;
;online='ONLINE'
;onfile='/data/idl/bozo/line/Lbozo.a2351.oct09'
;attach,online,onfile
;
;offline='OFFLINE'
;offfile='/data/idl/bozo/line/Lbozo.a1804.jan09'
;attach,offline,offfile
;
files
;
fault:  begin
        print,!err_string
        return
        end
;
return
end
