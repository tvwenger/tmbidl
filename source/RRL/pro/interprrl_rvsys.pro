pro interpRRL_rvsys,nsaveList,nsaveRef,nsaveTrack,chMinus=chMinus,chPlus=chPlus,nsaveOut=nsaveOut,$
                    lineOffset=lineOffset,noquery=noquery,noRef=noRef,help=help
;+
;NAME: interpRRL_rvsys.pro 
;
;PURPOSE: 
; Interpolates one or more RRL transitions at different, but nearby,
; frequencies. This requires an interpolation and shift of one
; spectrum relative to another spectrum.  The interpolation is
; required since the velocity resolution is a function of frequency.  
; The shift is required since we need to align the spectra. Also, 
; since at the GBT there is only one Doppler tracking LO there is some
; smearing of the non-Doppler tracked spectrum, especially if the
; data are averaged over different seasons. We assume the smearing is
; negligible.
;
; Here we use RVSYS in the sdfits file which is the relativistic
; Doppler shift velocity to calculate the offset.
;
;===========================================================================   
;CALLING SEQUENCE: interpRRL_rvsys,nsaveList,nsaveRef,nsaveTrack,$
;                                  nsaveLOchMinus=chMinus,chPlus=chPlus,$
;                                  nsaveOut=nsaveOut,lineOffset=lineOffset,$
;                                   noquery=noquery,noRef=noRef,help=help
;===========================================================================   
;
;INPUTS:  
;     /help        gets this help
;     -nsaveList:  list of nsave locations to process
;     -nsaveRef:   nsave location of reference spectrum
;     -nsaveTrack: nsave location of the tracking LO spectrum
;
;OPTIONAL KEYWORDS:
;     -chMinus:    number of channels to use left of the H line
;     -chPlus:     number of channels to use right of the H line
;     -nsaveOut:   nsave location to store data
;     -lineOffset: channels offset for alpha line center estimate
;     -noquery:    turns queries off so process proceeds uninterupted
;     -noRef:      does not process the reference spectrum
;
;OUTPUTS:
;
;NOTE: Compile in the following order
;
;      .compile /export/home/duli/dbalser/data/idl/gbt/dsb/rrl/pro/sinc.pro
;      .compile /export/home/duli/dbalser/data/idl/gbt/dsb/rrl/pro/interpsinc.pro
;      .compile /export/home/duli/dbalser/data/idl/gbt/dsb/rrl/pro/interpRRL_rvsys.pro
;
;EXAMPLE: interpRRL_rvsys, [33,34,37,38,39,40], 35, 33
;
;-
;MODIFICATION HISTORY:
;    30 July 2008 - Dana S. Balser (taken from interpRRL_fitManual.pro)
;                   Use RVSYS to get offset instead of Gaussian fits.
;    08 August 2008 - (dsb) Correct lineOffset to be in units of velocity.
;                           Correct Vlsr in header for lineOffset.
;    20 Sep 2008 - (lda) Added noquery keyword so user doesn't have to keep
;                  pressing enter.  Also added lineoffset keyword to h00
;                  to account for shifts in the combined spectrum that
;                  are necessary for negative velocity sources.
;    24 Jan 2009 - (dsb) Check for inverted spectrum.
;    04 Feb 2009 - (dsb) change header info (sky_freq, ref_chan, data_points)
;    13 Feb 2009 - (dsb) Fix index error when calculating velocity array xi.
;                        Change lineOffset to shift line relative to flag.
;                        Remove invert flag and use sign of delta_x directly.
;                        Specify Vlsr at reference channel for interpolation.
;                        Put lineOffset in the header parameter freqoff.  
;    23 Feb 2009 - (dsb) Adjust sigVel to account for different resolutions.
;                        Add C-band configuration. Use strtrim on lineid.
;                        Apply lineOffset by changing chMinus and chPlus.
;    30 Jun 2009 - (dsb) Add 3He configuration.
;    17 Jun 2011 - (dsb) Modify Doppler shift equation (e.g., dopplerFreqRef) and 
;                        the sign of the Doppler offset (e.g., dopplerChanDelta).
;                        Effectively there is no change in the results.
;    04 Oct 2012 - (dsb) Added noRef as an option not to process the
;                        reference scan.
;    09 May 2013 - tmb   added /help and !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'interpRRL_rvsys' & return & endif
;
;set defaults
if (n_elements(chMinus) eq 0) then chMinus=643
if (n_elements(chPlus) eq 0) then chPlus=357
if (n_elements(nsaveOut) eq 0) then nsaveOut=!lastns+1
if (n_elements(lineOffset) eq 0) then lineOffset=0

; correct for the lineOffset
chMinus=chMinus+lineOffset
chPlus=chPlus-lineOffset

; check configuration
config=!config
case config of
           -1: begin
               print
               print,'Need to specify ACS configuration for correct flags!!!'
               print
               print,'!config = 0 for GBT 3-Helium flags'
               print,'!config = 1 for GBT 7-alpha (X-band) flags'
               print,'!config = 2 for GBT 7-alpha (C-band) flags'
               ;print,'!config = 3 for ARECIBO 3-Helium flags'
               print
               return
               end
            0: begin
               chanAlpha=[2048.0,2192.1,3326.8]
               restFreq=[8665.3,8586.56, 8325.00]*1.e6
               llabel=['HE3a','A91','A92']
               rlabel=['rx1','rx2','rx4']
               end
            1: begin
               chanAlpha=[2842.6,3456.9,1650.8,0.0,2049.8,1278.8,2049.9,2412.1]
               restFreq=[9183.0, 9505.0, 9812.0, 8665.3, 8045.60495992323, 8300.0, 8584.82315062037, 8877.0]*1.e6
               llabel=['H89','H88','H87','HE3','H93','H92','H91','H90']
               rlabel=['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
               end
            2: begin
               chanAlpha=[1617.3,1577.3,1590.4,1603.6,1627.2,2276.0,1648.4,1672.0]
               restFreq=[5295.05, 5764.32, 5601.95, 5445.62, 5149.99, 5008.23, 4875.38, 4619.94]*1.e6
               llabel=['H107','H104','H105','H106','H108','H109','H110','H112']
               rlabel=['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
               end
         else: begin
               print,'ACS CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase


; define feedback parameter
ans = ' '  
; remember the first output nsave location
nsaveStart=nsaveOut
; set the reference channel
nref = chMinus
; set the velocity of the reference channel
xnref = 0.0
; create dummy array
nchan = chMinus+chPlus+1
chanVals = dindgen(nchan)
; turn off nregion marker
nroff
; turn cursor on
curon

; find the Doppler shift [Hz] for the tracking LO
getns, nsaveTrack
; determine line id
trackLineID = strtrim(string(!b[0].line_id),2)
indexTrackLine = where(trackLineID eq llabel or strmid(trackLineID,0,3) eq rlabel)
; Doppler shift radial velocity [km/s] 
rvsys = !b[0].rvsys/1000.0
; Doppler shift frequency [Hz]
dopplerFreqTrack = restFreq[indexTrackLine]*(1.0 - rvsys/!light_c)/sqrt(1.0 - (rvsys/!light_c)^2) - restFreq[indexTrackLine]


; -----process reference spectrum-----
print, ' '
print, 'Process the reference spectrum: ', nsaveRef
print, ' ' 
; get the reference spectrum
getns, nsaveRef
; determine the line id
refLineID = strtrim(string(!b[0].line_id),2)
; determine the velocity resolution (velocity scale is flipped w.r.t. frequency)
refDV = !light_c*(-!b[0].delta_x/!b[0].sky_freq)
; save the sky frequency of the reference band
refSkyFreq = !b[0].sky_freq
; determine the offset between reference spectrum and tracking LO spectrum
indexRefLine = where(refLineID eq llabel or strmid(refLineID,0,3) eq rlabel)
dopplerFreqRef = restFreq[indexRefLine]*(1.0 - rvsys/!light_c)/sqrt(1.0 - (rvsys/!light_c)^2) - restFreq[indexRefLine]
dopplerChanDelta = (dopplerFreqRef - dopplerFreqTrack)/!b[0].delta_x
; calculate reference channel
refChan = (chanAlpha[indexRefLine] + dopplerChanDelta)
; determine velocity of the reference channel
; correct for the delta from the channel center
chanDelta = refChan[0]-fix(refChan[0])
refVel = !b[0].vel/1.e3 - chanDelta*refDV
; determine velocity array of the reference spectrum
xi = (chanVals - nref+1)*refDV + refVel
; take the integer channel value
refChan = fix(refChan[0])
; include any offset plus channel delta
refHeaderChan = chMinus + chanDelta

IF ~Keyword_Set(noRef) THEN BEGIN
    ; remove dc offset
    dc = median(!b[0].data[(refChan-chMinus):(refChan+chPlus)])
    !b[0].data = !b[0].data - dc
    ; plot spectrum
    curoff
    setx,refChan-chMinus,refChan+chPlus
    curon
    xx & flags
    IF ~Keyword_Set(noquery) THEN BEGIN
        print, 'Reference Spectrum.  Hit return to continue'
        ans=get_kbrd(1)
    ENDIF
    ; put the processed data at the beginning of the spectrum 
    !b[0].data[0:(nchan-1)] = !b[0].data[(refChan-chMinus):(refChan+chPlus)]
    ; adjust line id
    lineid = strtrim(string(!b[0].line_id),2)
    foo = 'I' + lineid
    tagid, foo
    ; put the reference channel in the header
    !b[0].ref_ch = refHeaderChan
    ; put the number of data points in the header
    !b[0].data_points = nchan
    ; put the lineOffset in the frequency-switched offset location
    !b[0].freqoff = lineOffset
    ; plot spectrum
    curoff
    setx,0,nchan
    xx
    h00
    IF ~Keyword_Set(noquery) THEN BEGIN
        print, 'Processed reference spectrum.  Hit return to continue'
        ans=get_kbrd(1)
    ENDIF
    putavns, nsaveOut
    nsaveOut=nsaveOut+1
    ; store lineid and offset channel
    rrlID = [refLineID]
    rrlOffset = [dopplerChanDelta]
ENDIF



; -----process spectrum to interpolate-----
for i=0,n_elements(nsaveList)-1 do begin
    print, ' '
    print, 'Process the signal spectrum: ', nsaveList[i]
    print, ' ' 
    ; get the signal spectrum
    getns, nsaveList[i]
    ; determine the line id
    sigLineID = strtrim(string(!b[0].line_id),2)
    ; determine the velocity resolution (velocity scale is flipped w.r.t. frequency)
    sigDV = !light_c*(-!b[0].delta_x/!b[0].sky_freq)
    ; determine the offset between signal spectrum and tracking LO spectrum
    indexSigLine = where(sigLineID eq llabel or strmid(sigLineID,0,3) eq rlabel )
    dopplerFreqSig = restFreq[indexSigLine]*(1.0 - rvsys/!light_c)/sqrt(1.0 - (rvsys/!light_c)^2) - restFreq[indexSigLine]
    dopplerChanDelta = (dopplerFreqSig - dopplerFreqTrack)/!b[0].delta_x
    ; calculate signal channel
    sigChan = (chanAlpha[indexSigLine] + dopplerChanDelta)
    ; determine velocity of the signal channel
    ; correct for the delta from the channel center
    chanDelta = sigChan[0]-fix(sigChan[0])
    sigVel = !b[0].vel/1.e3 - chanDelta*sigDV - (sigDV-refDV)
    ; take the integer channel value
    sigChan=fix(sigChan[0])
    ; remove dc offset
    dc = median(!b[0].data[(sigChan-chMinus):(sigChan+chPlus)])
    !b[0].data = !b[0].data - dc
    ; plot spectrum
    curoff
    setx,sigChan-chMinus,sigChan+chPlus
    curon
    xx & flags
    IF ~Keyword_Set(noquery) THEN BEGIN
        print, 'Signal Spectrum.  Hit return to continue'
        ans=get_kbrd(1)
    ENDIF
    ; get the array of the processed signal spectrum
    f = !b[0].data[(sigChan-chMinus):(sigChan+chPlus)]
    ; interpolate
    ;fi = interpsinc(xi, f, xd=sigDV, nref=nref, xnref=xnref)
    fi = interpsinc(xi, f, xd=sigDV, nref=nref, xnref=sigVel)
    ; put the processed data at the beginning of the spectrum 
    !b[0].data[0:(nchan-1)] = fi
    ; adjust line id
    lineid = strtrim(string(!b[0].line_id),2)
    foo = 'I' + lineid
    tagid, foo
    ; put the reference channel in the header
    !b[0].ref_ch = refHeaderChan
    ; put the number of data points in the header
    !b[0].data_points = nchan
    ; put the lineOffset in the frequency-switched offset location
    !b[0].freqoff = lineOffset
    ; put ref sky frequency in the header
    !b[0].sky_freq = refSkyFreq
    ; plot spectrum
    curoff
    setx,0,nchan
    xx
    h00
    IF ~Keyword_Set(noquery) THEN BEGIN
        print, 'Processed signal spectrum.  Hit return to continue'
        ans=get_kbrd(1)
    ENDIF
    putavns, nsaveOut
    nsaveOut=nsaveOut+1
    ; store lineid and offset channel
    IF Keyword_Set(noRef) and (i eq 0) THEN BEGIN
        rrlID = [sigLineID]
        rrlOffset = [dopplerChanDelta]
    ENDIF ELSE BEGIN
        rrlID = [rrlID, sigLineID]
        rrlOffset = [rrlOffset, dopplerChanDelta]
    ENDELSE
end


; set the last output nsave location
nsaveEnd = nsaveOut-1
!lastns=nsaveEnd

; average the data and plot
print, ' '
print, 'Generate average'
for i=nsaveStart,nsaveEnd do begin
    getns,i
    if (i eq nsaveStart) then begin
        xx
    endif else begin
        reshow
    endelse
    accum
end
IF ~Keyword_Set(noquery) THEN BEGIN
    print, 'Hit return to view average'
    read,ans
ENDIF
ave
curoff
setx,0,(nchan-1)
curon
xx
h00

; print out channel offsets
print, ' '
for i=0,n_elements(rrlID)-1 do begin
    print, rrlID[i], ' ', rrlOffset[i]
end


return
end
