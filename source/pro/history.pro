pro history,help=help
;+
; NAME:
;      HISTORY
;
;            =========================
;            Syntax: history,help=help
;            =========================
;
;   history -- Archives information in the header 'history' string: 
;   -------    size,nfit,nunit,nrset,nregion,ngauss,a_gauss,g_sigma 
;
;              'size' is size (bytes) of this record.
;              'nunit' are the NREGION units (string).
;              Stores baseline and gaussian fit information.
;
;              If !flag OR !verbose then prints this information to screen
;-
; V5.0 June 2007 
;      20aug08 tmb minor format change to accomodate mK intensities
;                  for strong sources 
; v5.1 28jan09 tmb fixed dsb found bug in 'size' calculation
; V7.0 03may2013 tvw - added /help, !debug
; v7.1 20may2013 tvw - put blank at end like supposed to
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be []
if keyword_set(help) then begin & get_help,'history' & return & endif
;
; Is there history information already?
;
history=!b[0].history
deja_vu=string(history[0:2])
if deja_vu ne '' then begin
        print,'There already is HISTORY information stored for this spectrum !'
        size=long(deja_vu)
        print,fstring(size,'(i3)') + ' bytes already stored'
        print,'Do you wish to overwrite this information? (y/n)'
        ians=' '
        ians=get_kbrd(1)
        if ians eq 'y' then goto, doit
        return     
end
;
doit:
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
bgauss=!bgauss
egauss=!egauss
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
           !chan eq 1: begin
                       nregion=fstring(nregion,'(I5)')  ; in channels
                       bgauss =fstring(bgauss,'(I5)')
                       egauss =fstring(egauss,'(I5)')
                       end
                 else: begin
                       nregion=fstring(nregion,'(f10.4)'); anything else
                       bgauss =fstring(bgauss,'(f10.4)')
                       egauss =fstring(egauss,'(f10.4)') 
                       end
endcase
Nregb=''
for i=0,2*nr-1 do Nregb=Nregb+nregion[i]+b
;
ngauss=fstring(ngauss,'(I2)')
;
agauss=fstring(agauss,'(f11.4)')
Agaussb=''
for i=0,3*ng-1 do Agaussb=Agaussb+agauss[i]+b
;
gsigma=fstring(gsigma,'(f10.4)')
Gsigmab=''
for i=0,3*ng-1 do Gsigmab=Gsigmab+gsigma[i]+b
;
history=nfit+b+nunit+b+nrset+b+Nregb+bgauss+b+egauss+b
; added blank at end here:
history=history+ngauss+b+Agaussb+Gsigmab+b
;
max_size=n_elements(!rec.history)
hist_size=strlen(history)+3    ; must account for I3 size of 'size' !
;                                plus the blank, but IDL starts at idx=0...
;
;print,hist_size,max_size
size=fstring(hist_size,'(I3)')
history=size+b+history
;
;print,'          1         2         3         4         5         6         7         8'
;print,'012345678901234567890123456789012345678901234567890123456789012345678901234567890'
;
if !flag or !verbose then print,history
;
if hist_size le max_size then begin
                              !b[0].history='' ;          
                              !b[0].history=byte(history)     
                              goto,flush
                              end
print,'HISTORY too large ! Nothing written !'
;
flush:
return
end
