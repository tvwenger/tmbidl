pro processRRL_rvsys,srcName,polType,refLine=refLine,trackLine=trackLine,chMinus=chMinus,$
                     chPlus=chPlus,nsaveOut=nsaveOut,lineOffset=lineOffset,noquery=noquery,$
                     noRef=noRef,scanType=scanType,maxNsave=maxNsave,help=help
;+
;NAME: processRRL_rvsys.pro 
;
;PURPOSE: 
; Process RRL data: using the source name and polarization as input,
; search the nsave file for all RRLs for current configuration.  Run
; interpRRL_rvsys to interpolate spectra and save.
;   
;===========================================================================
;SYNTAX: processRRL_rvsys,srcName,pol,refLine=refLine,trackLine=trackLine,$
;                         chMinus=chMinus,chPlus=chPlus,nsaveOut=nsaveOut,$
;                         lineOffset=lineOffset,noquery=noquery,noRef=noRef,$
;                         scanType=scanType,maxNsave=maxNsave,help=help
;===========================================================================
;
;INPUTS:  
;     -srcName:    source name
;     -polType:    polarization type ('LL' or 'RR')
;
;OPTIONAL KEYWORDS:
;     /help        gets this help 
;     -refLine:    line id for transition to use as reference (H87 is the default)
;     -trackLine:  line id for transition to use as tracking LO (H89 is the default)
;     -chMinus:    number of channels to use left of the H line
;     -chPlus:     number of channels to use right of the H line
;     -nsaveOut:   nsave location to store data
;     -lineOffset: channels offset for alpha line center estimate
;     -noquery:    turns queries off so process proceeds uninterupted
;     -noRef:      does not process the reference spectrum
;     -scanType:   filter on scan type
;     -maxNsave:   maximum nsave value for searching
;
;OUTPUTS:
;
;NOTE: Compile in the following order
;
;      .compile /export/home/duli/dbalser/data/idl/gbt/dsb/rrl/pro/sinc.pro
;      .compile /export/home/duli/dbalser/data/idl/gbt/dsb/rrl/pro/interpsinc.pro
;      .compile /export/home/duli/dbalser/data/idl/gbt/dsb/rrl/pro/interpRRL_rvsys.pro
;      .compile /export/home/duli/dbalser/data/idl/gbt/dsb/rrl/pro/processRRL_rvsys.pro
;
;EXAMPLE: processRRL_rvsys, 'DR7', 'LL'
;
;-
;MODIFICATION HISTORY:
;    30 July 2008 - Dana S. Balser
;    18 Sep. 2008 - LDA Added noquery keyword so user doesn't
;                   have to keep pressing enter.
;    04 Feb 2009 - (dsb) add some print statements
;    02 Apr 2012 - (dsb) include keyword for scan type
;    04 Oct 2012 - (dsb) Added noRef as an option not to process the
;                        reference scan.
;    09 May 2013 -  tmb  added /help and !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'processRRL_rvsys' & return & endif
;
;set defaults
if (n_elements(refLine) eq 0) then refLine='H87'
if (n_elements(trackLine) eq 0) then trackLine='H89'
if (n_elements(chMinus) eq 0) then chMinus=643
if (n_elements(chPlus) eq 0) then chPlus=357
if (n_elements(nsaveOut) eq 0) then nsaveOut=!lastns+1
if (n_elements(lineOffset) eq 0) then lineOffset=0
if (n_elements(scanType) eq 0) then scanType='*'
if (n_elements(maxNsave) eq 0) then maxNsave=!nsave_max

; initialize the nsave locations
nsaveList = [-1]
nsaveRef = -1
nsaveTrack = -1

; check configuration
config=!config
case config of
           -1: begin
               print
               print,'Need to specify ACS configuration for correct flags!!!'
               print
               ;print,'!config = 0 for GBT 3-Helium flags'
               print,'!config = 1 for GBT 7-alpha (X-band) flags'
               print,'!config = 2 for GBT 7-alpha (C-band) flags'
               ;print,'!config = 3 for ARECIBO 3-Helium flags'
               print
               return
               end
            1: begin
               llabel=['H89','H88','H87','H93','H92','H91','H90']
               end
            2: begin
               llabel=['H107','H104','H105','H106','H108','H109','H110','H112']
               end
         else: begin
               print,'ACS CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase

; loop through the nsave to search for source name and polarization locations
for i=0,maxNsave-1 do begin 
    if (!nsave_log[i] eq 1) then begin 
        ; get data and relevant header parameters
        getns,i
        sname=strtrim(!b[0].source,2) 
        lineid=strtrim(string(!b[0].line_id),2)
        pol=strtrim(string(!b[0].pol_id),2) 
        type=strtrim(!b[0].scan_type,2)
        ; select source name, pol, and scan type
        if (sname eq srcName) and (pol eq polType) and (strmatch(type,scanType)) then begin
            ; select only RRLs for this configuration
            index = where(lineid eq llabel)
            ; store nsave locations
            if (index ge 0) then begin
                if (lineid eq trackLine) then begin
                    nsaveTrack = i
                endif
                if (lineid eq refLine) then begin
                    nsaveRef = i
                endif else begin
                    if (nsaveList[0] eq -1) then begin
                        nsaveList[0] = i
                    endif else begin
                        nsaveList = [nsaveList, i]
                    endelse
                endelse
            endif 
        endif
    endif
endfor

;print, 'Spectra to interpolate: ', nsaveList
;print, 'Interpolation reference spectrum: ', nsaveRef
;print, 'Doppler tracking reference spectrum: ', nsaveTrack

; run the interpolation
if (nsaveList[0] ge 0) and (nsaveRef ge 0) and (nsaveTrack ge 0) then begin
    interpRRL_rvsys, nsaveList, nsaveRef, nsaveTrack, chMinus=chMinus, chPlus=chPlus, nsaveOut=nsaveOut, lineOffset=lineOffset, noquery=noquery, noRef=noRef
endif else begin
    print, 'Insufficient RRL transitions: ', nsaveList[0], ' ', nsaveRef, ' ', nsaveTrack
endelse
 
return
end
