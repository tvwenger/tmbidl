pro lpc,start_rec,nsaveScan=nsaveScan,avgPol=avgPol,nfit=nfit,help=help
;+
; NAME:
;       LPC
;
;     =================================================================
;     SYNTAX: lpc,start_rec,nsaveScan=nsaveScan,avgPol=avgPol,nfit=nfit
;     =================================================================
;
;        lpc  Use current fits to measure local pointing corrections
;        ---  (LPCs) or offset coordinates for extended sources.
;             Currently works ONLY for PEAK and TCJ2 observing
;             procedures.
;
;        KEYWORDS: start_rec  starting record number (assumes 4 scans)
;                  nsaveScan  use nsave averages (assumes 2 scans)
;                  avgPol     average polarizations
;                  nfit       set nfit (default is nfit=3)
;
;        EXAMPLES: lpc, 23              process offline records 23-26
;                  lpc, 40, /nsaveScan  process nsave averages 40,42
;                  lpc, 23, /avgPol     process offline and avgerage pols
;                  lpc, 23, nfit=5      process offline using nfit=5
;
;-
;  10Dec07 by DSB
;  11Feb08 dsb add option to use averages in nsaves (e.g., via tcjavg)
;  14Jul09 dsb modify to use new version of bb that invokes nrset
;  15Jul09 dsb modify code that processes from nsave (assume sequential)
;  27Dec11 dsb change /avg to /nsaveScan; add /avgPol flag; add print outs
;  29Dec11 dsb add nift parameter
;
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'lpc' & return & endif
;
if (n_elements(nfit) eq 0) then nfit=3  ; default nfit = 3
; process tcj averages
; assume RA: start_rec and Dec: start_rec+1
;
; do we want to work in NSAVE space?
if keyword_set(nsaveScan) then begin
    ; arrays to store fits
    nfits=2
    h=dblarr(nfits) & hs=dblarr(nfits)
    c=dblarr(nfits) & cs=dblarr(nfits)
    w=dblarr(nfits) & ws=dblarr(nfits)
    brms=dblarr(nfits)
    ; RA scan
    print, 'Process <RA> Scan'
    print, 'Set the baseline regions'
    getns, start_rec
    raxx & freex & xx & bb,nfit & gg,1 & pause
    offset12 = !a_gauss[1]/3600.0
    h[0]=!a_gauss[0] & c[0]=!a_gauss[1] & w[0]=!a_gauss[2]
    hs[0]=!g_sigma[0] & cs[0]=!g_sigma[1] & ws[0]=!g_sigma[2]
    brms[0]=!bfit_rms
    ; Dec scan
    print, 'Process <Dec> Scan'
    print, 'Set the baseline regions'
    getns, start_rec+1
    decx & freex & xx & bb,nfit & gg,1 & pause
    offset34 = !a_gauss[1]/3600.0
    h[1]=!a_gauss[0] & c[1]=!a_gauss[1] & w[1]=!a_gauss[2]
    hs[1]=!g_sigma[0] & cs[1]=!g_sigma[1] & ws[1]=!g_sigma[2]
    brms[1]=!bfit_rms
    ; get cardinal coordinates
    ra = !b[0].ra
    dec = !b[0].dec
    ; historical artifact
    styp='BDE'
    ; skip code below
    goto, output
endif


; process either PEAK or TCJ2 scans

; arrays to store fits
nfits=4
h=dblarr(nfits) & hs=dblarr(nfits)
c=dblarr(nfits) & cs=dblarr(nfits)
w=dblarr(nfits) & ws=dblarr(nfits)
brms=dblarr(nfits)

; loop over the four scans (e.g., PEAK,TCJ2)
; N.B., assumes two polarizations have been filled
for i=start_rec,(start_rec+6),2 do begin

    ; get the record
    ; average pols if avgPol is set
    if keyword_set(avgPol) then begin
        get, i
        accum
        get, i+1
        accum
        ave
    endif else begin
        get,i
    endelse

    ; find the scan type
    type=string(!b[0].scan_type)
    styp=strmid(type,0,3)

    ; get cardinal coordinates [degree]
    az = !b[0].az
    el = !b[0].el
    ra = !b[0].ra
    dec = !b[0].dec

    ; find the scan type and determine the offsets [degree]
    ; (N.B., the Gaussian parameters are in arcsec)
    case styp of
        'AZ:': begin
               print, 'Process Az Scan'
               print, 'Set the baseline regions'
               azxx & freex & xx & bb,nfit & gg,1 & pause
               offset1 = !a_gauss[1]/3600.0
               h[0]=!a_gauss[0] & c[0]=!a_gauss[1] & w[0]=!a_gauss[2]
               hs[0]=!g_sigma[0] & cs[0]=!g_sigma[1] & ws[0]=!g_sigma[2]
               brms[0]=!bfit_rms
               end
        'BAZ': begin
               print, 'Process BAz Scan'
               azxx & freex & xx & b,/disp & g & pause
               offset2 = !a_gauss[1]/3600.0
               h[1]=!a_gauss[0] & c[1]=!a_gauss[1] & w[1]=!a_gauss[2]
               hs[1]=!g_sigma[0] & cs[1]=!g_sigma[1] & ws[1]=!g_sigma[2]
               brms[1]=!bfit_rms
               end
        'EL:': begin
               print, 'Process AEl Scan'
               print, 'Set the baseline regions'
               elxx & freex & xx & bb,nfit & gg,1 & pause
               offset3 = !a_gauss[1]/3600.0
               h[2]=!a_gauss[0] & c[2]=!a_gauss[1] & w[2]=!a_gauss[2]
               hs[2]=!g_sigma[0] & cs[2]=!g_sigma[1] & ws[2]=!g_sigma[2]
               brms[2]=!bfit_rms
               end
        'BEL': begin
               print, 'Process BEl Scan'
               elxx & freex & xx & b,/disp & g & pause
               offset4 = !a_gauss[1]/3600.0
               h[3]=!a_gauss[0] & c[3]=!a_gauss[1] & w[3]=!a_gauss[2]
               hs[3]=!g_sigma[0] & cs[3]=!g_sigma[1] & ws[3]=!g_sigma[2]
               brms[3]=!bfit_rms
               end
        'RA:': begin
               print, 'Process RA Scan'
               print, 'Set the baseline regions'
               raxx & freex & xx & bb,nfit & gg,1 & pause
               offset1 = !a_gauss[1]/3600.0
               h[0]=!a_gauss[0] & c[0]=!a_gauss[1] & w[0]=!a_gauss[2]
               hs[0]=!g_sigma[0] & cs[0]=!g_sigma[1] & ws[0]=!g_sigma[2]
               brms[0]=!bfit_rms
               end
        'BRA': begin
               print, 'Process BRA Scan'
               raxx & freex & xx & b,/disp & g & pause
               offset2 = !a_gauss[1]/3600.0
               h[1]=!a_gauss[0] & c[1]=!a_gauss[1] & w[1]=!a_gauss[2]
               hs[1]=!g_sigma[0] & cs[1]=!g_sigma[1] & ws[1]=!g_sigma[2]
               brms[1]=!bfit_rms
               end
        'DEC': begin
               print, 'Process Dec Scan'
               print, 'Set the baseline regions'
               decx & freex & xx & bb,nfit & gg,1 & pause
               offset3 = !a_gauss[1]/3600.0
               h[2]=!a_gauss[0] & c[2]=!a_gauss[1] & w[2]=!a_gauss[2]
               hs[2]=!g_sigma[0] & cs[2]=!g_sigma[1] & ws[2]=!g_sigma[2]
               brms[2]=!bfit_rms
               end
        'BDE': begin
               print, 'Process BDec Scan'
               decx & freex & xx & b,/disp & g & pause
               offset4 = !a_gauss[1]/3600.0
               h[3]=!a_gauss[0] & c[3]=!a_gauss[1] & w[3]=!a_gauss[2]
               hs[3]=!g_sigma[0] & cs[3]=!g_sigma[1] & ws[3]=!g_sigma[2]
               brms[3]=!bfit_rms
               end
         else: begin
               print,'Not a valid type'
               return
               end
    endcase
endfor

; average forward/backward to remove hysteresis [degree]
offset12 = (offset1 + offset2)/2.0
offset34 = (offset3 + offset4)/2.0


output:


; print out results
; Gaussian fits
print, ' '
print, '------------------------------------------------------------------'
print, '        Height            Center            Width           rms'
print, '         [K]             [arcsec]          [arcsec]         [K]'
for i=0,nfits-1 do begin
    print,h[i],hs[i]*100.0/abs(h[i]),c[i],cs[i]*100.0/abs(c[i]),w[i],ws[i]*100.0/abs(w[i]),brms[i], $
          format = '(f8.3,1x,"(",f5.1,"%)",2x,f8.3,1x,"(",f5.1,"%)",2x,f8.3,1x,"(",f5.1,"%)",2x,f8.5)'
endfor
; back and forward scans
if (nfits eq 4) then begin
    print, ' '
    print, mean(h[0:1]),stddev(h[0:1])*100.0/abs(mean(h[0:1])),mean(c[0:1]),stddev(c[0:1])*100.0/abs(mean(c[0:1])),mean(w[0:1]),stddev(w[0:1])*100.0/abs(mean(w[0:1])), $
           format = '(f8.3,1x,"(",f5.1,"%)",2x,f8.3,1x,"(",f5.1,"%)",2x,f8.3,1x,"(",f5.1,"%)   RA/Az")'
    print, mean(h[2:3]),stddev(h[2:3])*100.0/abs(mean(h[2:3])),mean(c[2:3]),stddev(c[2:3])*100.0/abs(mean(c[2:3])),mean(w[2:3]),stddev(w[2:3])*100.0/abs(mean(w[2:3])), $
           format = '(f8.3,1x,"(",f5.1,"%)",2x,f8.3,1x,"(",f5.1,"%)",2x,f8.3,1x,"(",f5.1,"%)   Dec/El")'

endif
; all scans
print, ' '
print,mean(h),stddev(h),stddev(h)*100.0/mean(h),mean(h)/abs(mean(brms)), $
      format='("<Height> = ",f8.3,1x,"(",f8.5,") K ",3x,"(", f5.1,"%)  S/N = ",f6.2)'

; Offsets
; (N.B. use angle on the sky for the horizontal coordinate---e.g., cross elevation)
if (styp eq 'BEL') then begin
    print, '------------------------------------------------------------------'
    print,offset12*3600.0*cos(el/!radeg),offset34*3600.0, $
          format = '("LPCs  (XEl = ", f6.2, " arcsec; El = ", f6.2, " arcsec)")' 
    print, ' ' 
    print, '     Az            El'
    radec,az,el,ideg,imin,xsec,idg,imn,xsc
    print,ideg,imin,xsec,idg,imn,xsc, $
          format='(i02,1x,i02,1x,f07.4,2x,i03,1x,i02,2x,f06.3, "  (Original)")'
    radec,(az+offset12),(el+offset34),ideg,imin,xsec,idg,imn,xsc
    print,ideg,imin,xsec,idg,imn,xsc, $
          format='(i02,1x,i02,1x,f07.4,2x,i03,1x,i02,2x,f06.3, "  (Corrected)")'
    print, '------------------------------------------------------------------'
    print, ' '
endif
if (styp eq 'BDE') then begin
    print, '------------------------------------------------------------------'
    print,offset12*3600.0*cos(dec/!radeg),offset34*3600.0, $
          format = '("LPCs  (XDec = ", f6.2, " arcsec; Dec = ", f6.2, " arcsec)")' 
    print, ' ' 
    print,!b[0].epoch, format='("     RA              Dec       (",f7.2,")")' 
    radec,ra,dec,ideg,imin,xsec,idg,imn,xsc
    print,ideg,imin,xsec,idg,imn,xsc, $
          format='(i02,1x,i02,1x,f07.4,2x,i03,1x,i02,2x,f06.3, "  (Original)")'
    radec,(ra+offset12),(dec+offset34),ideg,imin,xsec,idg,imn,xsc
    print,ideg,imin,xsec,idg,imn,xsc, $
          format='(i02,1x,i02,1x,f07.4,2x,i03,1x,i02,2x,f06.3, "  (Corrected)")'
    print, '------------------------------------------------------------------'
    print, ' '
endif

return
end
