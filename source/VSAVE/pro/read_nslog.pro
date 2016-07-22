;+
; NAME:
;       NSLOG
;
;            ====================================
;            Syntax: nslog, start_ns_#, stop_ns_# 
;            ====================================
;
;   nslog   Print information for NSAVE data records 
;   -----
;
; MODIFICATION HISTORY:
; By rtr in mar 05 to list a range of nsaves
; By tmb in summer 06 to add GRS capability
; V5.0 July 2007
;      21 June 2008 fixed output bug 
;-
pro read_nslog,nslow,nshigh
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
;  find the last ns number in the NSAVE file
;
nsmax=!nsave_max
;
if (n_params() eq 0) then begin
                     nslow=!nslow & nshigh=!nshigh &
                     endif
;
if (nshigh gt nsmax-1) then nshigh=nsmax-1
if (nslow lt 0) then nslow=0
;
print,'Listing NSAVEs from ',nslow,nshigh,nsmax
;
openr,!nslogunit,!nslogfile
for i=nslow,nshigh do begin 
;
;
    nss=999
    readu,!nslogunit,nss
    print,i,nss
endfor
;
close,!nslogunit
return
punt: print,'EOF on NSAVE file: probably due to incompatible file sizes'
;
out:
return
end
