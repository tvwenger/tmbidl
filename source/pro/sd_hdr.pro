pro sd_hdr,rec,help=help
;+
; NAME:
;       SD_HDR
;
;            ==========================================
;            Syntax: sd_hdr, single_sdd_rec,help=help
;                    rec=sdd[rec#] OR   sd_hdr,sdd[111]
;                    sd_hdr,rec       
;            ==========================================
;
; sd_hdr  Print header variables for a single SDFITS record.
; ------  I.e. a single subcorrelator spectrum for a specific scan
;         'single_sdd_rec' (rec) is this single record.
;          
;         'rec' is an explicit reference to this single *SDFITS record*; 
;         it is NOT the record number of a spectrum in a {gbt_data} data file.
;
;  =====> For this procedure to work, MRDFITS must be used to generate a 
;         sdd[] structure array from the SDFITS data file:
;
;         To read the SDFITS data file in array sdd[] :
;
;         openr,lun,!datafile,/get_lun
;         sdd = mrdfits(lun, 1, hdr, status=status) ; makes SDFITS data structure array
;         free_lun,lun                     
;-          
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'sd_hdr' & return & endif
;
ra=rec.crval2 & dec=rec.crval3 & radec=strtrim(adstring(ra,dec),2) &
lst=rec.lst/3600.                             ; LST hours
slst=adstring(rec.lst/3600.)                  ; LST as HH MM SS string
fsky=rec.obsfreq/1.e6
f0=rec.restfreq/1.e6
bw=rec.bandwid/1.e6
nchan=n_elements(rec.data)
;
print
print,'Source= '+rec.object+'  Scan= '+fstring(rec.scan,'(i4)')+'  Mode= '+rec.obsmode
print,radec+'  LST= '+slst+' Date= '+rec.date_obs
print,rec.frontend+'  Sampler= '+rec.sampler+'  # channels= '+fstring(nchan,'(i6)')
print,'Fsky= '+fstring(fsky,'(f9.4)')+' MHz  Fo= '+fstring(f0,'(f9.4)')+$
      ' MHz  BW= '+fstring(bw,'(f8.4)')+' MHz'
print
;
return
end

