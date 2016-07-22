pro h00, refChan=refChan, vlsr=vlsr, help=help
;+
;
;   h00.pro   Flag in channels the position of the H87alpha, He87alpha, and C87alpha
;   -------   We interpolate all other RRLs to this velocity scale
;             Use channel 643.0 as the reference for the alpha lines
;
;   Syntax:  h00, refChan=refChan, vlsr=vlsr, help=help
;   ==================================================
;
;             Velocity resolution = (50.0/4096)*3.0e5/9816.867 = 0.373 km/s
;
;             H87alpha:  9816.867 MHz;   0.00 km/s; 643.00 ch    0    ch 
;             He87alpha: 9820.864 MHz; 122.15 km/s; 315.52    -327.48
;             C87alpha:  9821.761 MHz; 149.56 km/s; 242.03    -400.97
;
;
;             Aug08 LDA Added lineoffset keyword to account for line
;                       shifts that are necessary for negative
;                       velocity sources.
;             28 Jan 2009 (dsb) add refChan keyword
;             04 Feb 2009 (dsb) Use header to get refChan by default but allow
;                               user to input value; Remove lineoffset.
;             05 Feb 2009 (dsb) Add vlsr keyword
;             23 Feb 2009 (dsb) Add configurations
;             30 Jun 2009 (dsb) Add 3He configuration.
;   v6.1 18may2012 tmb tweaked style  added /help keyword           
;
;-
;
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if KeyWord_Set(help) then begin & get_help,'h00' & return & endif 
;
if ~KeyWord_Set(refChan) then refChan=!b[0].ref_ch
if ~KeyWord_Set(vlsr) then vlsr=!b[0].vel/1.e3


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
               ; H, He, and C rest frequencies of 91alpha
               freqH = 8584.82
               freqHe = 8588.32
               freqC = 8589.10
               end
            1: begin
               ; H, He, and C rest frequencies of 87alpha
               freqH = 9816.867
               freqHe = 9820.864
               freqC = 9821.761
               end
            2: begin
               ; H, He, and C rest frequencies of 104alpha
               freqH = 5762.88
               freqHe = 5765.23
               freqC = 5765.76
               end
         else: begin
               print,'ACS CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase

; H, He, and C channels
chanH = refChan
chanHe = (freqHe - freqH)*1.e6/!b[0].delta_x + chanH
chanC = (freqC - freqH)*1.e6/!b[0].delta_x + chanH

; H, He, and C velocities
if (!velo eq 1) then begin
    chanH = !b[0].vel/1.e3 + (vlsr-!b[0].vel/1.e3)
    chanHe = (chanHe - refChan)*(-!b[0].delta_x/!b[0].sky_freq)*!light_c + chanH 
    chanC = (chanC - refChan)*(-!b[0].delta_x/!b[0].sky_freq)*!light_c + chanH
endif

;
; define channel array
;
xchan=fltarr(3)
xchan=[chanH, chanHe, chanC]
label=['H','He','C']
color=fltarr(3)
color=[!red,!red,!red]

;
; get x data range
;
xmin = !x.crange[0]
xmax = !x.crange[1]
;
for i=0,n_elements(xchan)-1 do begin
      ;print,xchan[i],' ',label[i],color[i]
;
      if ((xchan[i] gt xmin) and (xchan[i]lt xmax)) then $
         flg_id,xchan[i],textoidl(label[i]),color[i]
endfor
;
return
end
