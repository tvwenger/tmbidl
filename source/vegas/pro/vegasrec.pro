pro vegasrec,rec,help=help,xmin=xmin,xmax=xmax,file=file,silent=silent, $
             rfi=rfi
;+
; NAME:
;       VEGASREC
;
;       =====================================================
;       Syntax: vegasrec,rec,help=help,xmin=xmin,xmax=xmax, $
;                        file=file,silent=silent,rfi=rfi
;       =====================================================
;
;   vegasrec   VEGAS tests for input record number 'rec'
;   --------   intended to be modified as needed 
;  
; KEYWORDS    help   - if set gives this help
;             xmin   - sets min x channel DEFAULT=500
;             xmax   - sets max x channel        7692
;             file   - if set ouputs info on this rec to
;                      a file named 'vegasrec.dat' 
;                      fully qualified file name is hardwired
;             silent - if set runs as a batch mode process:
;                      supresses all command line activity
;                      including plots and pauses
;             rfi    - if set invokes autorfi.pro 
;-
; MODIFICATION HISTORY:
; V8.0 TMB 03jun2015
;      tmb 01jul2015 polished code 
;      tmb 11mar2016 added xmin,xmax,file,silent keywords
;      tmb 23mar2016 added rfi keyword
;
;-
on_error,2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'vegasrec' & return & endif
;
if n_params() eq 0 then begin 
   print,'ERROR! Must Supply Record number to fetch!'
   get_help,'vegasrec' & return
endif
;
if keyword_set(file) then begin
   name='/home/bania/GBT/VEGAS/mar16/vegasrec.dat'
   openu,lun,name,/get_lun,/append
endif
;
if ~keyword_set(xmin) then xmin=500
if ~keyword_set(xmax) then xmax=7692
setx,xmin,xmax
;
;nreg=[3000,3408,3466,3750,4435,4800]
;nrset,3,nreg
;nreg=[3000,3650,4410,5000]
;nrset,2,nreg
;
fetch,abs(rec)
mk
;
;bbb,nfit,/no
dcsub
;smo,5
rms,sig,xmin,xmax
;
    src= strtrim(string(!b[0].source),2) 
    scn=!b[0].scan_num
    bank=strtrim(string(!b[0].proc_id),2) 
    lineID=strtrim(string(!b[0].line_id),2)
    freq=!b[0].rest_freq/1.d+6
    polID=strtrim(string(!b[0].pol_id),2)
    type=strtrim(string(!b[0].scan_type),2)
    tcal=!b[0].tcal
    tsysON=!b[0].tsys_on
    tsysOFF=!b[0].tsys_off
    tsys=!b[0].tsys
    elev=!b[0].el 
    tintg=!b[0].tintg
    stintg=strtrim(fstring(tintg,'(f13.2)'),2)
    sscan=strtrim(fstring(scn,'(i3)'),2)
    srec=strtrim(fstring(rec,'(i6)'),2)
    stsys=strtrim(fstring(tsys,'(f6.1)'),2)
    ssig=strtrim(fstring(sig,'(f7.2)'),2)
;
label='scn= '+sscan+' rec#= '+srec+' '
label=label+src+' '+lineID+' '+bank+' '+polID+' '
label=label+'Tsys= '+stsys+' K '
label=label+'RMS= '+ssig+' mK '
label=label+'tintg= '+stintg+' sec'
print
print,label
print
;
lbl=sscan+' '+srec+' '+src+' '
lbl=lbl+lineID+' '+bank+' '+polID+' '+stsys+' '
lbl=lbl+ssig+' '+stintg
;print
;print,lbl
;print
if keyword_set(file) then printf,lun,lbl
;
scaley
tagtype,bank
xx
;
if keyword_set(rfi) then autorfi
;
rrlflag,charsize=2
zline
;hline,4.
;
if ~keyword_set(silent) then pause
;
if keyword_set(file) then free_lun,lun
;
return
end
