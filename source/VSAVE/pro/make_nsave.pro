;+
; NAME:
;       MAKE_NSAVE
;
;            =================================================
;            Syntax: make_nsave, data_file_name, log_file_name, /auto
;            =================================================
;
;
;   make_nsave   Create the NSAVE file using the {tmbidl_data_v5.0} structure. 
;   ----------   Also create a log file to record if a slot has been written.
;
;                If /auto not given the
;                Default for no input is !nsavefile, !nslogfile
;
;                Files must be fully qualified file names.
;                Please use '.dat' and '.log' for data, log file
;                extensions.
;
;                rtr: Does not require fully qualified file names
;
;                If /auto is given adopts RTR new standard names
;              
; MODIFICATION HISTORY:
; V5.0 July 2007
;
; RTR adds /auto option
;     adds prompt for number of bins
;     06/09 RTR adds code to check for existing files to prevent discussion
;-
pro make_nsave,fdata,flog,auto=auto
;       
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(auto) then begin
    autoname=' '
    if n_params() gt 0 then begin
        autoname=fdata
    endif else begin
        print,'Enter NSAVE file name with no extensions. No quotes needed'
        read,autoname
    endelse
    !nsavefile=autoname+'.LNS'
    !nslogfile=!nsavefile+'.key'
endif else begin
    print,'Defaulting to old tmb mode'
    if n_params() ne 0 then begin
        !nsavefile=fdata
        !nslogfile=flog
    endif
endelse
;
;  create the NSAVE file
;
nsbins=128
print,'Enter number of NSAVE bins'
read,nsbins
!nsave_max=nsbins
nsfile=!nsavefile
nslfile=!nslogfile
there=findfile(nsfile)
if there ne '' then print,'WARNING ',nsfile,' EXISTS'
there=findfile(nslfile)
if there ne '' then print,'WARNING ',nslfile,' EXISTS'
print,'Creating NSAVE files',!nsavefile,' ',!nslogfile,' with ',nsbins,' bins'
print,'Proceed? (y,n)
ans=' '
ans=get_kbrd(1)
if ans ne 'y' then begin
    print,'Aborting makesave'
    return
end
; need to add file check here
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
print,'Made NSAVE.DAT file '+!nsavefile+' with '+fstring(!nsave_max,'(i5)')+' slots'
print,'Made NSAVE.LOG file '+!nslogfile
print
; 
close,!nsunit
close,!nslogunit
;
return
end







