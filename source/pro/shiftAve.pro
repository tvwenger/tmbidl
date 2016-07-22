pro shiftAve,nsref,nsave,help=help,zero=zero,buffer=buffer
;+
; NAME: 
;      SHIFTAVE
;
;    ==============================================================
;    SYNTAX: shiftAve,nsref,nsave,help=help,zero=zero,buffer=buffer
;    ==============================================================
;
;  shiftave   Shift one NSAVE spectrum relative to another by an integer
;             amount and then average.  The rest frequency in the header
;             is used to determine the shift.  The velocity scale is not
;             regridded.
;   
;  INPUTS:
;     -nsref       reference nsave location
;     -nsave       nsave location to average
;
;  KEYWORDS: help  -  give help on syntax
;            zero   - use zero array as the reference
;            buffer - use buffer arrays (1-2;4-8) instead of nsaves
;                    ==> N.B. buffers 3 and 9 are being used!!!
;
;  EXAMPLE: shiftAve, 5, 6
;           ==============
;-
; MODIFICATION HISTORY
;    11 Mar 2011 - Dana S. Balser
;    07 May 2013 - (dsb) add buffer keyword
; V7.0 19may2013 - tmb migrated to v7.0 style
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) or n_params() eq 0 then begin 
              get_help,'shiftave' & return & endif
;
@CT_IN  ; color table handling
;
;
; filter on SDFITS date
;
is_jd_ok,ok
if ok ne 1 and ~Keyword_Set(restFreq) then begin
   print,'Spectrum does not have a valid rest frequency.'
   return
endif
;

; get nsref
if Keyword_Set(zero) then begin
    print, 'Using zero array as reference'
endif else begin
    if Keyword_Set(buffer) then begin
        copy, nsref, 0
    endif else begin
        getns, nsref
    endelse
endelse
;xx
copy,0,9
refRestFreq = !b[0].rest_freq/1.e6
refRefChan = !b[0].ref_ch
refDeltaFreq = !b[0].delta_x/1.e6
nchan = !b[0].data_points
accum

; get nsave
if Keyword_Set(buffer) then begin
    copy, nsave, 0
endif else begin
    getns, nsave
endelse
aveData = !b[0].data
aveRestFreq = !b[0].rest_freq/1.e6
aveRefChan = !b[0].ref_ch
aveDeltaFreq = !b[0].delta_x/1.e6
tsys = !b[0].tsys
tsys_on = !b[0].tsys_on
tsys_off = !b[0].tsys_off
tintg = !b[0].tintg

; check that the resolutions are the same
if refDeltaFreq ne aveDeltaFreq then begin
    print, 'Spectra have different frequency resolution'
    return
endif

; get the amount of shift in channels
deltaChan = (refRestFreq - aveRestFreq)/aveDeltaFreq + (refRefChan - aveRefChan)
; find the beginning and ending channel
if deltaChan < 0 then begin
    aveBeginChan = deltaChan
    aveEndChan = (nchan - 1)
endif else begin
    aveBeginChan = deltaChan
    aveEndChan = (nchan - 1) - deltaChan
endelse

; use reference nsave 
copy,9,0
; update tsys and tintg
!b[0].tsys = tsys
!b[0].tsys_on = tsys_on
!b[0].tsys_off = tsys_off
!b[0].tintg = tintg

; update data
j = aveBeginChan
for i=0,(nchan-1) do begin
    if (j lt 0) || (j gt aveEndChan) then begin
        !b[0].data[i] = 0.0
    endif else begin
        !b[0].data[i] = aveData[j]
    endelse
    j = j + 1
endfor
accum

; average the data
ave
tagtype,'ShiftAve'
;
@CT_OUT ; restore color table
;
return
end