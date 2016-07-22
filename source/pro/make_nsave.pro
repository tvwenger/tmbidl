pro make_nsave,fdata,auto=auto,nsbins=nsbins,fname=fname,help=help
;+
; NAME:
;       MAKE_NSAVE
;
;    ============================================================
;    SYNTAX: make_nsave,fdata,auto=auto,nsbins=nsbins, $
;                       fname=fname,help=help
;    ============================================================
;
;
;   make_nsave  Create NSAVE file using the {tmbidl_data} structure. 
;   ----------  Also create a 'key' file for slot bookkeeping.
;               If input 'fdata', the data file name, 
;                  then fname="../../data/nsaves/'fdata'"
;               Automatically appends '.dat' and '.key' for 
;               data and key file extensions.
;
;   Keywords:   help -- gives this help
;              fname -- if set OVERIDES all other names
;                       'fname' MUST be a fully qualified file name
;             nsbins -- number of NSAVE slots to make (default 4096)
;               auto -- if set adopts RTR standard file names:
;                       fdata.LNS   fdata.LNS.key
;                       fdata.CNS   fdata.CNS.key
;
;                       if not set OR n_param() ne 1 then file names
;                       default to '../../data/nsaves/NSAVE.dat'
;                                  '../../data/nsaves/NSAVE.key'
;
;-              
; MODIFICATION HISTORY:
; V5.0 July 2007
;
;           RTR adds /auto option adds prompt for number of bins
;     06/09 RTR adds code to check for existing files to prevent overwriting
;     12 oct 2012 (dsb) add continuum nsave files (CNS); assume offline
;
; V7.0 03may2013 tvw - added /help !debug
;      15may2013 tmb - incorporates dsb's tweaks 
;      17jul2013 tmb - fix CNS bug cleaned up code and documentation
;                      only need one input file name just assume .key 
;                      added keyword nsbins changed default behavior 
;
;      18jul2013 tmb - added 'fname' keyword so that one can pass
;                      a fully qualified file name and put the NSAVE
;                      file anywhere. this overrides all other names
; V7.1 06may2014 tmb - tweaked the /help text to be more lucid
;                      changed back to RTR naming convention for /auto 
; V8.0 23feb2016 tmb - V8 directory tree adjustment line 59
;-
;       
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'make_nsave' & return & endif
;
; here is where TMBIDL normally stores NSAVEs
;
nsave='../data/nsaves/' ; V8 directory tree modification
;
npar=n_params()
case npar of
          0: begin & !nsavefile=nsave+'NSAVE'  & end
       else: begin & !nsavefile=nsave+fdata & end
endcase
;
if keyword_set(auto) then begin 
   case !online of ; if ONLINE the LNS else CNS
                1: begin & !nsavefile=!nsavefile+'.LNS' & end
             else: begin & !nsavefile=!nsavefile+'.CNS' & end
   endcase
endif
;
; Is there a fully qualified file name requested?
;
if keyword_set(fname) then !nsavefile=fname
;
!nslogfile=!nsavefile+'.key' ; & !nsavefile=!nsavefile+'.dat'
;
;  create the NSAVE file
;
if ~Keyword_Set(nsbins) then nsbins=4096 ; default number of bins
;
!nsave_max=nsbins
nsfile=!nsavefile & nslfile=!nslogfile
; if 'there' ne '' then print,'WARNING ',nsfile,' EXISTS'
; need to add file check here
there=findfile(nsfile)
if there ne '' then print,'***===> !!! WARNING !!! ',nslfile,' EXISTS'
print,'Creating NSAVE files',!nsavefile,' ',!nslogfile,' with ',nsbins,' bins'
print,'Proceed? (y or n)'
pause,ans
if ans ne 'y' then begin & print,'Aborting MAKE_NSAVE' & return & endif
;
openw,!nsunit,   !nsavefile       ;  
openw,!nslogunit,!nslogfile
;
nsave_file=replicate(!blkrec,!nsave_max)  ;  !rec is the tmbidl_data structure
writeu,!nsunit,nsave_file
nslog=intarr(nsbins)
nslog[0:nsbins-1]=0
writeu,!nslogunit,nslog           ;  somehow this got changed
;
print
print,'Made NSAVE data file '+!nsavefile+' with '+fstring(!nsave_max,'(i5)')+' slots'
print,'Made NSAVE.key  file '+!nslogfile
print
; 
close,!nsunit
close,!nslogunit
;
return
end







