pro avgInterpRRL,srcName,polType,nsaveOut=nsaveOut,help=help
;+
;NAME: avgInterpRRL.pro 
;
;PURPOSE: 
; For each interpolated RRL transition average over different epochs.
; N.B., this will average over all scan types.
;   
;==========================================================================
;CALLING SEQUENCE: avgInterpRRL,srcName,polType,nsaveOut=nsaveOut,help=help
;==========================================================================
;
;INPUTS:  
;     -srcName:    source name
;     -polType:    polarization type ('LL' or 'RR')
;
;OPTIONAL KEYWORDS:
;     /help        gets this help
;     -nsaveOut:   nsave value to use (default is !lastns+1)
;
;
;OUTPUTS:
;
;EXAMPLE: avgInterpRRL, 'DR7', 'LL'
;-
;
;MODIFICATION HISTORY:
;    14 December 2012 - Dana S. Balser
;     9 May 2013 - tmb added /help and !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'avgInterpRRL' & return & endif
;
;set defaults
if (n_elements(nsaveOut) eq 0) then nsaveOut=!lastns+1

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
               llabel=['IH89','IH88','IH87','IH93','IH92','IH91','IH90']
               end
            2: begin
               llabel=['IH107','IH104','IH105','IH106','IH108','IH109','IH110','IH112']
               end
         else: begin
               print,'ACS CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase


; loop through all RRL transitions and then all nsave locations
for j=0,n_elements(llabel)-1 do begin
    ; initialize the nsave locations
    nsaveList = [-1]
    for i=0,!nsave_max-1 do begin 
        if (!nsave_log[i] eq 1) then begin 
            ; get data and relevant header parameters
            getns,i
            sname=strtrim(!b[0].source,2) 
            lineid=strtrim(string(!b[0].line_id),2)
            pol=strtrim(string(!b[0].pol_id),2) 
            ; select source name, pol, and scan type
            if (sname eq srcName) and (pol eq polType) and (lineid eq llabel[j]) then begin
                ; select only RRLs for this configuration
                if (nsaveList[0] eq -1) then begin
                    nsaveList[0] = i
                endif else begin
                    nsaveList = [nsaveList, i]
                endelse
            endif
        endif
    endfor
    ; perform average
    if (nsaveList[0] ne -1) then begin
        for k=0,n_elements(nsaveList)-1 do begin
            getns, nsaveList[k]
            accum
        endfor
        ave
        tagtype, 'GRAV'
        putavns, nsaveOut
        nsaveOut=nsaveOut+1
        !lastns=!lastns+1
    endif
endfor



return
end
