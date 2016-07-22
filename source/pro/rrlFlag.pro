pro rrlFlag, help=help, hydrogen=hydrogen, helium=helium, carbon=carbon, $
             nmin=min, nmax=nmax, dnmax=dnmax, restFreq=restFreq, $
             heii=heii, cii=cii, oii=oii, inf=inf, charsize=charsize
;+
;NAME: rrlFlag.pro 
;
;PURPOSE: Procedure to calculate RRL channel locations and draw flags.
;   
;CALLING SEQUENCE: 
; ===============================================================
; SYNTAX: rrlFlag, help=help, hydrogen=hydrogen, helium=helium, $
;         carbon=carbon, nmin=nmin, nmax=nmax, dnmax=dnmax,     $
;         restFreq=restFreq, heii=heii, cii=cii, oii=oii,       $
;         inf=inf,charsize=charsize
; ===============================================================
;
;INPUTS:  
;
;OPTIONAL KEYWORDS:
;
;     -help        give help on syntax
;     -hydrogen:   flag hydrogen transitions   DEFAULT ON
;     -helium:     flag helium transitions     DEFAULT ON
;     -carbon:     flag carbon transitions     DEFAULT ON
;     -nmin:       minimum n to flag           DEFAULT 40
;     -nmax:       maximum n to flag           DEFAULT 250
;     -dnmax:      maximum dn to flag          DEFAULT 7
;     -restFreg    override any internal restFreq (MHz)
;     -heii        add He+ atom
;     -cii         add C+ atom
;     -oii         add O+ atom
;     -inf         add infinte mass
;     -charsize    size of flag ID string      DEFAULT 2
;
;OUTPUTS:
;
;EXAMPLE: rrlflag, dnmax=10
;
;-
;MODIFICATION HISTORY:
;    07 Feb 2011 - Dana S. Balser
;
;  V6.1 12feb2911 tmb  tweaked to filter of 1jan2011 SDFITS change
;                      added KeyWord RestFreq to override !b[0].rest_freq
;
;    21 Apr 2011 - (dsb) Added switch for He+ (HeII), C+ (CII), and O+ (OII)
;    27 Apr 2011 - (dsb) Change RRL flag colors
;    28 Feb 2012 - (dsb) Add infinte mass
;    29 Feb 2012 - (dsb) Update the help
;  
;  V7.0 16may2013  tmb added help and !debug
;  V8.0 22jul2014  tmb added keyword charsize for his failing eyes
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'rrlflag' & return & endif 
;
; filter on SDFITS date
;
is_jd_ok,ok
if ok ne 1 and ~Keyword_Set(restFreq) then begin
   print,'Spectrum does not have a valid rest frequency.'
   return
endif
;
;set defaults
if (n_elements(hydrogen) eq 0) then hydrogen=1
if (n_elements(helium) eq 0) then helium=1
if (n_elements(carbon) eq 0) then carbon=1
if (n_elements(nmin) eq 0) then nmin=40
if (n_elements(nmax) eq 0) then nmax=250
if (n_elements(dnmax) eq 0) then dnmax=7
if ~KeyWord_Set(charsize) then charsize=2.0
;
; get header info
;
; use rest frequency in header unless overridden by KeyWord
;
if ~Keyword_Set(restFreq) then restFreq = !b[0].rest_freq/1.e6
refChan = !b[0].ref_ch
bw = !b[0].bw/1.e6
nchan = !b[0].data_points
deltaFreq = !b[0].delta_x/1.e6
; calculate freq of first and last channel
startFreq = -1.0*float(refChan)*deltaFreq + restFreq
endFreq = float(nchan - refChan)*deltaFreq + restFreq
; calculate min/max frequency in band
minFreq = min([startFreq, endFreq])
maxFreq = max([startFreq, endFreq])


; 3He+:
freq = 8665.649905
if (freq lt maxFreq) and (freq gt minFreq) then begin
    chan=(freq - restFreq)/deltaFreq + refChan
    label='^3He^+'
    xmin = !x.crange[0]
    xmax = !x.crange[1]
    if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
        flg_id,chan,textoidl(label),!magenta,charsize=charsize 
    endif
endif


; RRLs: loop through (n,dn)
for i=nmin,nmax do begin
    for j=1,dnmax do begin
        ; determine the color based on RRL order
        case j of
            1 : color=!cyan
            2 : color=!red
            3 : color=!green
            4 : color=!blue
            5 : color=!purple
            6 : color=!yellow
            7 : color=!forest
            else : color=!gray
        endcase
        ; Hydrogen
        if (hydrogen eq 1) then begin
            freq = rydberg(i, j, 'H')
            if (freq lt maxFreq) and (freq gt minFreq) then begin
                chan=(freq - restFreq)/deltaFreq + refChan
                label='H'+ strtrim(i,2) + '(' + strtrim(j,2) + ')'
                xmin = !x.crange[0]
                xmax = !x.crange[1]
                if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
                    flg_id,chan,textoidl(label),color,charsize=charsize
                endif
            endif
        endif
        ; Helium
        if (helium eq 1) then begin
            freq = rydberg(i, j, 'He')
            if (freq lt maxFreq) and (freq gt minFreq) then begin
                chan=(freq - restFreq)/deltaFreq + refChan
                ;label='He'+ strtrim(i,2) + '(' + strtrim(j,2) + ')'
                label=' '
                xmin = !x.crange[0]
                xmax = !x.crange[1]
                if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
                    flg_id,chan,textoidl(label),color,charsize=charsize
                endif
            endif
        endif
        ; Carbon
        if (carbon eq 1) then begin
            freq = rydberg(i, j, 'C')
            if (freq lt maxFreq) and (freq gt minFreq) then begin
                chan=(freq - restFreq)/deltaFreq + refChan
                ;label='C'+ strtrim(i,2) + '(' + strtrim(j,2) + ')'
                label=' '
                xmin = !x.crange[0]
                xmax = !x.crange[1]
                if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
                    flg_id,chan,textoidl(label),color,charsize=charsize
                endif
            endif
        endif
        ; Helium (He+)
        if keyword_set(heii) then begin
            freq = rydberg(i, j, 'He+')
            if (freq lt maxFreq) and (freq gt minFreq) then begin
                chan=(freq - restFreq)/deltaFreq + refChan
                label='He+'+ strtrim(i,2) + '(' + strtrim(j,2) + ')'
                ;label=' '
                xmin = !x.crange[0]
                xmax = !x.crange[1]
                if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
                    flg_id,chan,textoidl(label),color,charsize=charsize
                endif
            endif
        endif
        ; Carbon (C+)
        if keyword_set(cii) then begin
            freq = rydberg(i, j, 'C+')
            if (freq lt maxFreq) and (freq gt minFreq) then begin
                chan=(freq - restFreq)/deltaFreq + refChan
                label='C+'+ strtrim(i,2) + '(' + strtrim(j,2) + ')'
                ;label=' '
                xmin = !x.crange[0]
                xmax = !x.crange[1]
                if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
                    flg_id,chan,textoidl(label),color,charsize=charsize
                endif
            endif
        endif
        ; Oxygen (O+)
        if keyword_set(oii) then begin
            freq = rydberg(i, j, 'O+')
            if (freq lt maxFreq) and (freq gt minFreq) then begin
                chan=(freq - restFreq)/deltaFreq + refChan
                label='O+'+ strtrim(i,2) + '(' + strtrim(j,2) + ')'
                ;label=' '
                xmin = !x.crange[0]
                xmax = !x.crange[1]
                if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
                    flg_id,chan,textoidl(label),color,charsize=charsize
                endif
            endif
        endif
        ; Infinite mass
        if keyword_set(inf) then begin
            freq = rydberg(i, j, 'Inf')
            if (freq lt maxFreq) and (freq gt minFreq) then begin
                chan=(freq - restFreq)/deltaFreq + refChan
                ;label='Inf'+ strtrim(i,2) + '(' + strtrim(j,2) + ')'
                label=' '
                xmin = !x.crange[0]
                xmax = !x.crange[1]
                if (!xx[chan] gt xmin) and (!xx[chan] lt xmax) then begin
                    flg_id,chan,textoidl(label),color,charsize=charsize
                endif
            endif
        endif
    end
end


return
end
