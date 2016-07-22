pro start_GENERIC,filename,data_points=data_points,help=help
;+
; NAME:
;       START_GENERIC
;
;       ================================================================
;       Syntax: start_GENERIC,filename,data_points=data_points,help=help
;       ================================================================
;
;   start_GENERIC   INITIALIZES TMBIDL for GENERIC data.
;   -------------   These are not necessarily even telescope data.  
;                   Certainly not necessarily radio telescope data. 
;                   If fully qualified 'filename' passed, 
;                   attaches to ONLINE file.
;
;   Keywords:  /help       - gives this help 
;              data_points - number of data points
;                            Default is 4096
;
;   ===> TO LOAD A DEFAULT TMBIDL PACKAGE THAT USES AN ARBITRAY NUMBER
;        OF DATA POINTS USE THE data_points KEYWORD
;        THIS *MUST* BE DONE ON THE IDL COMMAND LINE OUTSIDE OF start.pro
;        VIA THE COMMAND:  start_generic,data_points=the_number_you_want
;                          =============================================
;-
; V5.0 July 2007                 
;
; V6.0 June 2009
; V7.0 03may2013 tvw - added /help, !debug
;      04jul2013 tmb - added data_points keyword
;                      now has 4096 points as default
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
;
if  keyword_set(help) then begin & get_help,'start_GENERIC' & return & endif
if ~Keyword_Set(data_points) then data_points=4096
if n_params() eq 0 then filename=''
;
print
print,'Initializing generic TMBIDL: '
print,'             -------'
msg='{data} structure will have '+string(data_points)+' data points'
print,msg
print
!data_points=data_points & !nchan=!data_points 
; 
@tmbidl_header ; define {tmbidl_header} with tweaked header info
               ; define the {tmbidl_data} structure complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS  
;
!recs_per_scan=1 
gbt_win         ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_GENERIC.log'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
nson           ; write protect the nsave file
line           ; for spectral line  mode
tp             ; TP mode
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
; N.B. default TMBIDL files will not work unless 4096 data points 
;
files          ; show which files are being used 
print
print,'These data files will not work if number of !data_points is not 4096 !'
print
;
 if filename ne '' then begin
                  datafile='ONLINE'
                  attach,datafile,filename ; attach to ONLINE file
                  online
                  print,'==> You have ATTACHed a new ONLINE data file <=='
                  endif
;
;
fault:  begin
        print,!err_string
        return
        end
;
return
end