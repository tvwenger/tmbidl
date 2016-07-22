;+
;NAME: processRRL_combine.pro 
;
;PURPOSE: 
; Process RRL data: using the source name and polarization as input,
; search the nsave file for all RRLs for current configuration.  Run
; combineRRL to combine spectra and save.  To combine spectra the data
; have to be corrected for different HPBW's; this requires the
; observed angular size for a reference RRL and the HPBWs of
; all RRLs to be processed.  We import the observed angular
; sizes from a file.  The HPBWs are set in the configuration directly
; using a calibration source.
;   
;CALLING SEQUENCE: processRRL_combine, srcName, pol, refLine=refLine, badLines=badLines, contFile=contFile, nsaveOut=nsaveOut, noquery=noquery
;
;INPUTS:  
;     -srcName:    source name
;     -polType:    polarization type ('LL' or 'RR')
;
;OPTIONAL KEYWORDS:
;     -refLine:    line id for transition to use as reference (H91 is the default)
;     -badLines:   list of line id's that are bad and should not be included.
;     -contFile:   continuum file (including path)
;     -nsaveOut:   nsave location to store data
;     -noquery:    turns queries off so process proceeds uninterupted
;
;OUTPUTS:
;
;EXAMPLE: processRRL_combine, 'DR21', 'LL'
;
;MODIFICATION HISTORY:
;    19 September 2008 - Dana S. Balser
;          24 Feb 2009 - (dsb) Change querry option to behave like interpRRL_rvsys.
;                              Add bad lines to exclude in average.
;-

pro processRRL_combine, srcName, polType, refLine=refLine, badLines=badLines, contFile=contFile, nsaveOut=nsaveOut, noquery=noquery

;set defaults
if (n_elements(refLine) eq 0) then refLine='IH91'
if (n_elements(badLines) eq 0) then badLines=['None']
if (n_elements(contFile) eq 0) then contFile='/export/home/duli/dbalser/data/idl/te/data/tmb.jul08'
if (n_elements(nsaveOut) eq 0) then nsaveOut=!lastns+1

print, ' '
print, 'Processing source: ', srcName, '; pol: ', polType
print, ' '

; initialize the nsave locations
nsaveList = [-1]
nsaveRef = -1
hpbwList = [-1]
hpbwRef = -1
labelRef = 'None'
labelList = ['None']

; check configuration
config=!config
case config of
           -1: begin
               print
               print,'Need to specify ACS configuration for correct flags!!!'
               print
               ;print,'!config = 0 for GBT 3-Helium flags'
               print,'!config = 1 for GBT 7-alpha (X-band) flags'
               ;print,'!config = 2 for GBT 7-alpha (C-band) flags'
               ;print,'!config = 3 for ARECIBO 3-Helium flags'
               print
               return
               end
            1: begin
               llabel=['H89','H88','H87','H93','H92','H91','H90']
               ; based on 3C147 ja08 calibration
               hpbw = [ 79.4, 77.7, 73.9, 91.0, 86.2, 85.9, 80.7]
               end
         else: begin
               print,'ACS CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase

; loop through the nsave to search for source name and polarization locations
for i=0,!nsave_max-1 do begin 
    if (!nsave_log[i] eq 1) then begin 
        ; get data and relevant header parameters
        getns,i
        sname=strtrim(!b[0].source,2) 
        lineid=strtrim(string(!b[0].line_id),2)
        pol=strtrim(string(!b[0].pol_id),2) 
        ; select source name and pol
        if (sname eq srcName) and (pol eq polType) then begin
            ; select only interpolated RRLs for this configuration
            index = where(lineid eq 'I'+llabel)
            ; do not use bad lines
            indexBad = where(lineid eq badLines)
            if (indexBad ge 0) then index = -1
            ; store nsave locations
            if (index ge 0) then begin
                if (lineid eq refLine) then begin
                    nsaveRef = i
                    hpbwRef = hpbw[index]
                    labelRef = llabel[index]
                endif else begin
                    if (nsaveList[0] eq -1) then begin
                        nsaveList[0] = i
                        hpbwList[0] = hpbw[index]
                        labelList[0] = llabel[index]
                    endif else begin
                        nsaveList = [nsaveList, i]
                        hpbwList = [hpbwList, hpbw[index]]
                        labelList = [labelList, llabel[index]]
                    endelse
                endelse
            endif 
        endif
    endif
endfor

; check that the lists are the same size
if (n_elements(nsaveList) eq n_elements(hpbwList)) then begin
    print, 'Nsave ID  HPBW' 
    print, nsaveRef, labelRef, hpbwRef, $
           format='(i4,1x,a4,1x,f4.1, " (Reference)")'
    for j=0,n_elements(nsaveList)-1 do begin
        print, nsaveList[j], labelList[j], hpbwList[j], $
               format='(i4,1x,a4,1x,f4.1)'
    endfor
endif else begin
    print, 'The nsave and hpbw lists are not the same size.'
    return
endelse

; find the continuum info
; open file
openr,lun,contFile,/get_lun  
a = ' '
; search entire file
while not eof(lun) do begin
    readf,lun,a
    xa=strsplit(a,' ',count=cols,/extract)
    ; find source of interest
    if (n_elements(xa) eq 9) then begin
        foo = xa[8] & name = strtrim(foo,2)
        if (srcName eq name) then begin
            ; assume standard format with only one component
            ; use first occurrence.  For example,
            ;
            ; L+R F_RA_AVG RAXX mK TA    5.8 63.5  1143 DR7G
            ; 1  6129.27  59.73  130.12  2.13      11.99  0.66
            ; L+R F_DEC_AVG DECX mK TA    5.8 63.7  1144 DR7G
            ; 1  6392.72  82.82  151.27  2.32     -16.96  0.95
            ;
            readf,lun,a
            xra=strsplit(a,' ',count=cols,/extract)
            readf,lun,a
            readf,lun,a
            xdec=strsplit(a,' ',count=cols,/extract)
            ; intensity [K] (arithmetic mean)
            tcRef = mean([float(xra[1]), float(xdec[1])])/1.0e3
            ; convolved angular size [arcsec] (geometric mean)
            fwhmRef = sqrt(float(xra[3])*float(xdec[3]))
        endif
    endif
endwhile
free_lun,lun

print, ' '
print, 'Continuum: Tpk[K] = ', tcRef, '; FWHM[arcsec] = ', fwhmRef
print, ' '

; run the RRL combination
if (nsaveList[0] ge 0) and (nsaveRef ge 0) then begin
    combineRRL, nsaveList, nsaveRef, fwhmRef, hpbwList, hpbwRef, nsaveOut=nsaveOut, noquery=noquery
endif else begin
    print, 'Insufficient RRL transitions: ', nsaveList[0], ' ', nsaveRef
endelse
 
return
end
