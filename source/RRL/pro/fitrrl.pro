pro fitRRL,srcName,polType,lineType,scanType,CFLL=CFLL,CFRR=CFRR,nsaveOut=nsaveOut,$
           outFile=outFile,fitDefault=fitDefault,help=help
;+
;NAME: fitRRL.pro 
;
;PURPOSE: fit RRL data and save results to file.
;   
;SYNTAX: fitRRL,srcName,polType,lineType,scanType,CFLL=CFLL,CFRR=CFRR,$
;               nsaveOut=nsaveOut,outFile=outFile,fitDefault=fitDefault,help=help
;
;INPUTS:  
;     -srcName:    source name 
;     -polType:    polarization type ('LL', 'RR', or 'L+R' to average)
;     -lineType:   line type (e.g., 'H91')
;     -scanType:   scan type (e.g., '<RRL>')
;
;OPTIONAL KEYWORDS:
;     /help        gets this help 
;     -CFLL:       calibration factor for LL data
;     -CFRR:       calibration factor for RR data
;     -nsaveOut:   nsave location to store data
;     -outFile:    output filename
;     -fitDefault: use default baseline and Gaussian parameters
;
;OUTPUTS:
;
;EXAMPLE: fitRRL, 'DR21', 'L+R', 'AH91', '<RRL>'
;
;-
;MODIFICATION HISTORY:
;    25 Jan 2009 - Dana S. Balser
;    06 Feb 2009 - (dsb) Change fitting and output.
;    24 Feb 2009 - (dsb) Add C-band configuration.
;    15 Dec 2012 - (dsb) Add scan type.
;     9 May 2013 - tmb added /help and !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'fitRRL' & return & endif
;
;set defaults
; CF using all lines
;if (n_elements(CFLL) eq 0) then CFLL=1.041
;if (n_elements(CFRR) eq 0) then CFRR=1.014
; CF using all lines except H90
if (n_elements(CFLL) eq 0) then CFLL=1.056
if (n_elements(CFRR) eq 0) then CFRR=1.005
if (n_elements(nsaveOut) eq 0) then nsaveOut=!lastns+1
if (n_elements(outFile) eq 0) then outFile='/export/home/duli/dbalser/data/idl/te/data/fitLine.txt'
if (n_elements(fitDefault) eq 0) then fitDefault=0

ans=' '

print, ' '
print, 'Processing source: ', srcName, '; pol: ', polType, '; line: ', lineType, '; type: ', scanType
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
               ; H, He, and C rest frequencies of 87alpha
               freqH = 9816.867
               freqHe = 9820.864
               freqC = 9821.761
               llabel=['H89','H88','H87','H93','H92','H91','H90']
               end
            2: begin
               ; H, He, and C rest frequencies of 104alpha
               freqH = 5762.88
               freqHe = 5765.23
               freqC = 5765.76
               llabel=['H107','H104','H105','H106','H108','H109','H110','H112']
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
        scantype=strtrim(string(!b[0].scan_type),2)
        lineid=strtrim(string(!b[0].line_id),2)
        pol=strtrim(string(!b[0].pol_id),2) 
        stype = strtrim(string(!b[0].scan_type),2)
        ; select source name and pol
        ; if polType='L+R' then we need to find two scans
        if (polType eq 'L+R') then begin
            if (sname eq srcName) and (lineid eq lineType) and (stype eq scanType) then begin
                ; find LL and store in 5
                if (pol eq 'LL') then begin
                    print, 'Found LL match with nsave = ', i
                    copy,0,5
                    match=match+1
                endif
                ; find RR and store in 6
                if (pol eq 'RR') then begin
                    print, 'Found RR match with nsave = ', i
                    copy,0,6
                    match=match+1
                endif
                ; average pols after calibration
                if (match eq 2) then begin
                    copy,5,0
                    scale, CFLL
                    accum
                    copy,6,0
                    scale, CFRR
                    accum
                    ave
                    tagpol, 'L+R'
                    tagtype, scantype
                    break
                endif
            endif
        endif else begin
            if (sname eq srcName) and (pol eq polType) and (lineid eq lineType) then begin
                print, 'Found match with nsave = ', i
                if (pol eq 'LL') then scale, CFLL
                if (pol eq 'RR') then scale, CFRR
                match=1
                break
            endif
        endelse
    endif
endfor



if (match eq 0) then begin
    print, 'No match found'
    return
endif

; save the unprocessed data
copy,0,7

; set x-axis in channels
chan
setx,0,!b[0].data_points
nroff
xx 

; process the line data
if (fitDefault) then begin
    ; change to velocity 
    velo & xx & h00
    print, 'Input transitions to fit [return--> c he h]'
    read, ans
    if(ans eq '') then begin
        ans='c he h'
    endif
    xa=strsplit(ans,' ',count=cols,/extract)
    ; fit the data
    b & xx & g & h00
end else begin
    ; change to velocity 
    velo & xx & h00
    print, 'Input transitions to fit [return--> c he h]'
    read, ans
    if(ans eq '') then begin
        ans='c he h'
    endif
    xa=strsplit(ans,' ',count=cols,/extract)
    ; fit the data
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
    gg,n_elements(xa)
endelse

; define arrays for fits
nlines = n_elements(xa)
ta = fltarr(nlines)
sig_ta = fltarr(nlines)
fwhm = fltarr(nlines)
sig_fwhm = fltarr(nlines)
vlsr = fltarr(nlines)
sig_vlsr = fltarr(nlines)

; calculate the fits in the appropriate units
; correct velocity for He and C
for i=0,nlines-1 do begin
    ; intensity [mK]
    ta[i] = !a_gauss[0+i*3]*1.e3
    sig_ta[i] = !g_sigma[0+i*3]*1.e3
    ; determine LSR velocity [km/s]
    vlsr[i] = !a_gauss[1+i*3]
    ; correct for He,C offsets
    ; get velocity direction
    velSign = -!b[0].delta_x/abs(!b[0].delta_x)
    if (xa[i] eq 'he') then vlsr[i] = vlsr[i] + velSign*((freqHe - freqH)*1.e6/!b[0].sky_freq)*!light_c
    if (xa[i] eq 'c') then vlsr[i] = vlsr[i] + velSign*((freqC - freqH)*1.e6/!b[0].sky_freq)*!light_c
    sig_vlsr[i] = !g_sigma[1+i*3]
    ; fwhm width [km/s]
    fwhm[i] = !a_gauss[2+i*3]
    sig_fwhm[i] = !g_sigma[2+i*3]
endfor

; rms [mK]
mask,rms
rms=rms*1.e3
; integration time [minutes]
tingt = !b[0].tintg/60.0

; print out the fits
openu,lun,outFile,/get_lun 
; go to eof
tmp = fstat(lun) 
point_lun, lun, tmp.size 
printf, lun, srcName, polType, lineType, rms, tingt, $
        format='(a16,1x,a3,1x,a5,1x,2(e14.6,1x))'
for i=0,nlines-1 do begin
    j=nlines-1-i
    printf, lun, xa[j], ta[j], sig_ta[j], vlsr[j], sig_vlsr[j], fwhm[j], sig_fwhm[j], $
        format='(a3,1x,6(e14.6,1x))'
endfor
free_lun,lun

; get back the unprocessed data
copy,7,0

; store fits to history file
; comment out for now since
;  1. Not large enough when fitting multiple Gaussians
;  2. Does not save Gaussian initial values to regenerate fits
;history
; add comment
foo = 'CFLL ' + fstring(CFLL,'(f5.3)') + ' CFRR ' + fstring(CFRR,'(f5.3)')
comment, foo

; save data
putavns, nsaveOut
!lastns=!lastns+1




return
end
