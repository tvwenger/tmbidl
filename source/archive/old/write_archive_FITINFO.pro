;+
; NAME:
;      WRITE_ARCHIVE_FITINFO
;
;   WRITE to ARCHIVE file 'history.pro' information, eliminating 'size'
;   add 'archive_type' to select subsequent parsing
;
;   INFORMATION PASSED IS:
;   nfit,nunit,nrset,Nregb,ngauss,Agaussb,Gsigmab
;
;   Syntax: write_archive_FITINFO,archive
;   ======================================
;
; V5.0 July 2007
;-
pro write_archive_FITINFO,archive
; 
on_error,!debug ? 0 : 2
compile_opt idl2
;
archive_type='FITINFO'
;
; what is NREGION ?
nunit=''
case 1 of 
          (!chan eq 1):nunit='CHAN'
          (!freq eq 1):nunit='FREQ'
          (!velo eq 1):nunit='VELO'
          (!vgrs eq 1):nunit='VGRS'
          (!azxx eq 1):nunit='AZXX'
          (!elxx eq 1):nunit='ELXX'
          (!raxx eq 1):nunit='RAXX'
          (!decx eq 1):nunit='DECX'
          else:        print,'screwy x-axis definition'
endcase
;
nfit=!nfit            ; order of baseline fit
nrset=!nrset          ; number of baseline regions
ngauss=!ngauss        ; number of gaussians fitted
nr=nrset              ; must truncate arrays so only real
ng=ngauss             ; information is passed
;
nregion=!nregion[0:2*nr-1] ; values of these regions in CHANNELS 
agauss= !a_gauss[0:3*ng-1] ; parameters of these gaussians
gsigma= !g_sigma[0:3*ng-1] ; errors of these fits
;
; turn them all to strings via =fstring(,'()') 
;
b=' '
nfit=fstring(nfit,'(I2)')
nunit=fstring(nunit,'(a4)')
nrset=fstring(nrset,'(I2)')
;
case 1 of 
          (!chan eq 1):nregion=fstring(nregion,'(I5)')  ; in channels
          else:        nregion=fstring(nregion,'(f10.4)'); anything else
endcase
Nregb=''
for i=0,2*nr-1 do Nregb=Nregb+nregion[i]+b
;
ngauss=fstring(ngauss,'(I2)')
;
agauss=fstring(agauss,'(f10.4)')
Agaussb=''
for i=0,3*ng-1 do Agaussb=Agaussb+agauss[i]+b
;
gsigma=fstring(gsigma,'(f10.4)')
Gsigmab=''
for i=0,3*ng-1 do Gsigmab=Gsigmab+gsigma[i]+b
;
archive=nfit+b+nunit+b+nrset+b+Nregb+ngauss+b+Agaussb+Gsigmab
;
archive=archive_type+b+archive
;
; all ARCHIVE scripts must return a single string called 'archive'
; 
flush:
return
end
