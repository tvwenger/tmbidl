;+
;NAME: calibrateRRL.pro 
;
;PURPOSE: test the combineRRL procedure.  Fit line data from different
; transitions and different levels of processing.  An ASCII file is
; produced with the line fits and some continuum info.
;   
;CALLING SEQUENCE: calibrateRRL, srcName, polType, lineType, contFile=contFile, outFile=outFile, fitDefault=fitDefault
;
;INPUTS:  
;     -srcName:    source name 
;     -polType:    polarization type ('LL' or 'RR')
;     -lineType:   line type (e.g., 'H91')
;
;OPTIONAL KEYWORDS:
;     -contFile:   continuum filename
;     -outFile:    output filename
;     -fitDefault: use default baseline and Gaussian parameters
;
;OUTPUTS:
;
;EXAMPLE: calibrateRRL, 'DR21', 'LL', 'H91', fitDefault=1
;
;MODIFICATION HISTORY:
;    01 Oct 2008 - Dana S. Balser
;    24 Feb 2009 - (dsb) Modify to use with new version of bb.pro.
;-

pro calibrateRRL, srcName, polType, lineType, contFile=contFile, outFile=outFile, fitDefault=fitDefault

;set defaults
if (n_elements(contFile) eq 0) then contFile='/export/home/duli/dbalser/data/idl/te/data/tmb.jul08'
if (n_elements(outFile) eq 0) then outFile='/export/home/duli/dbalser/data/idl/te/data/fits.txt'
if (n_elements(fitDefault) eq 0) then fitDefault=0

ans=' '

print, ' '
print, 'Processing source: ', srcName, '; pol: ', polType, '; line: ', lineType
print, ' '

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
               ; based on 3C147 ja08 calibration
               hpbw = [ 79.4, 77.7, 73.9, 91.0, 86.2, 85.9, 80.7]
               end
         else: begin
               print,'ACS CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase


match = 0
; loop through the nsave to search for source name and polarization locations
for i=0,!nsave_max-1 do begin 
    if (!nsave_log[i] eq 1) then begin 
        ; get data and relevant header parameters
        getns,i
        sname=strtrim(!b[0].source,2) 
        lineid=strtrim(string(!b[0].line_id),2)
        pol=strtrim(string(!b[0].pol_id),2) 
        ; select source name and pol
        if (sname eq srcName) and (pol eq polType) and (lineid eq lineType) then begin
            print, 'Found match with nsave = ', i
            match=1
            break
        endif
    endif
endfor

if (match eq 0) then begin
    print, 'No match found'
    return
endif

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


; process the line data

; set the x-axis scale
if (fitDefault) then begin
    ; check if using interpolated data
    foo=' '
    reads, lineType, foo, format='(a1)'
    if (foo eq 'I') or (foo eq 'A') then begin
        b & xx & g & h00 &
    endif else begin
        b & xx & g & flags &
    endelse
end else begin
    ; check if using interpolated data
    foo=' '
    reads, lineType, foo, format='(a1)'
    if (foo eq 'I') or (foo eq 'A') then begin
        curoff & setx,0,1001 & curon & xx & h00 &
    endif else begin
        xroll & xx & flags & 
        print, 'Set x-scale using the cursor'
        setx & xx & flags &
    endelse
    ; fit the baseline
    print, 'Set the baseline regions'
    print, 'Enter order of polynomial fit: [return-->3]'
    read,ans
    if(ans eq '') then begin
        nfit=3
        bb,nfit
    endif else begin
        nfit=float(ans)
        bb,nfit
    endelse
    ; fit Gaussian and store center
    print, 'Set Gaussian parameters'
    gg,1
endelse

; print out the fits
openu,lun,outFile,/get_lun 
; go to eof
tmp = fstat(lun) 
point_lun, lun, tmp.size 
printf, lun, srcName, polType, lineType, !a_gauss[0], !g_sigma[0], !a_gauss[1], !g_sigma[1], !a_gauss[2], !g_sigma[2], tcRef, fwhmRef, $
        format='(a16,1x,a3,1x,a5,1x,8(e14.6,1x))'
free_lun,lun


return
end
