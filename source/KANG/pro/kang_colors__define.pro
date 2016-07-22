FUNCTION Kang_Colors::Init, $
  beta=beta, $
  brightness=brightness, $
  contrast=contrast, $
  colornames=colornames, $
  colorindex=colorindex, $
  gamma=gamma, $
  ncolors=NColors, $
  red=r, $
  green=g, $
  blue=b, $
  scaling=scaling, $
  sigma=sigma

; Load current colors vectors if none are passed
TVLCT, r_cur, g_cur, b_cur, /Get
IF N_Elements(r) NE 0 THEN self.r=r ELSE self.r=r_cur
IF N_Elements(g) NE 0 THEN self.g=g ELSE self.g=g_cur
IF N_Elements(b) NE 0 THEN self.b=b ELSE self.b=b_cur

; Set defaults
IF N_Elements(brightness) NE 0 THEN self.brightness=(brightness>0.)<1. ELSE BEGIN
    self.brightness = 0.5
    self.rgb_brightness[*] = 0.5
    self.rgb_brightness_old[*] = 0.5
ENDELSE
IF N_Elements(contrast) NE 0 THEN self.contrast=(contrast>0.)<1. ELSE BEGIN
    self.contrast = 0.5
    self.rgb_contrast[*] = 0.5
    self.rgb_contrast_old[*] = 0.5
ENDELSE
IF N_Elements(NColors) NE 0 THEN self.ncolors=(NColors < 256L)>50L ELSE self.NColors=256L
IF N_Elements(beta) NE 0 THEN BEGIN
    IF N_Elements(beta) EQ 1 THEN self.beta[*]=beta 
    IF N_Elements(beta) EQ 3 THEN self.beta=beta
ENDIF ELSE self.beta[*] = 3
IF N_Elements(colornames) NE 0 THEN self->Load_ColorNames, colornames
IF N_Elements(gamma) NE 0 THEN BEGIN
    IF N_Elements(gamma) EQ 1 THEN self.gamma[*]=gamma 
    IF N_Elements(gamma) EQ 3 THEN self.gamma=gamma
ENDIF ELSE self.gamma[*] = 3
IF N_Elements(scaling) NE 0 THEN BEGIN
    IF N_Elements(scaling) EQ 1 THEN self.scaling[*]=scaling 
    IF N_Elements(scaling) EQ 3 THEN self.scaling=scaling 
ENDIF ELSE self.scaling[*] = 'Linear'
IF N_Elements(sigma) NE 0 THEN BEGIN
    IF N_Elements(sigma) EQ 1 THEN self.sigma[*]=sigma 
    IF N_Elements(sigma) EQ 3 THEN self.sigma=sigma
ENDIF ELSE self.sigma[*] = 5
IF N_Elements(colorindex) NE 0 THEN self->LoadCT, colorindex

; This will make the color ramp and load the new colors in the _new vectors
self->Make_Ramp
RETURN, 1
END ;Kang_Colors::Init---------------------------------------------------------------


PRO Kang_Colors::SetProperty, $
  brightness=brightness, $
  rgb_brightness=rgb_brightness, $
  contrast=contrast, $
  rgb_contrast=rgb_contrast, $
  colornames=colornames, $
  colorindex=colorindex, $
  ncolors=NColors, $
  red=r, $  
  green=g, $
  blue=b, $
  histramp=histramp, $
  scaling=scaling, $
  gamma=gamma, $
  beta=beta, $
  sigma=sigma
; Sets the properties of the object

IF N_Elements(brightness) NE 0 THEN self.brightness=0 > brightness < 1
IF N_Elements(rgb_brightness) NE 0 THEN self.rgb_brightness_old=(rgb_brightness>0.)<1.
IF N_Elements(contrast) NE 0 THEN self.contrast=0 > contrast < 1
IF N_Elements(rgb_contrast) NE 0 THEN self.rgb_contrast_old=(rgb_contrast>0.)<1.
IF N_Elements(NColors) NE 0 THEN self.ncolors=(NColors < 256L)>50L
IF N_Elements(colornames) NE 0 THEN self->Load_ColorNames, colornames
IF N_Elements(colorindex) NE 0 THEN self.colorindex = colorindex
IF N_Elements(r) NE 0 THEN BEGIN
    n_r = N_Elements(r)
    self.r[0:n_r-1]=r
ENDIF
IF N_Elements(g) NE 0 THEN BEGIN
    n_g = N_Elements(g)
    self.g[0:n_g-1]=g
ENDIF
IF N_Elements(b) NE 0 THEN BEGIN
    n_b = N_Elements(b)
    self.b[0:n_b-1]=b
ENDIF
IF N_Elements(histramp) NE 0 THEN BEGIN
    IF Ptr_Valid(self.histramp) THEN *self.histramp=histramp ELSE self.histramp = Ptr_New(histramp)
ENDIF
IF N_Elements(scaling) NE 0 THEN BEGIN
    IF N_Elements(scaling) EQ 1 THEN self.scaling[*]=scaling 
    IF N_Elements(scaling) EQ 3 THEN self.scaling=scaling 
ENDIF
self.rgb_brightness = (self.rgb_brightness_old*(self.brightness/2.+0.75))
self.rgb_contrast = (self.rgb_contrast_old*(self.contrast/2.+0.75))
IF N_Elements(beta) NE 0 THEN BEGIN
    IF N_Elements(beta) EQ 1 THEN self.beta[*]=beta 
    IF N_Elements(beta) EQ 3 THEN self.beta=beta 
ENDIF
IF N_Elements(sigma) NE 0 THEN BEGIN
    IF N_Elements(sigma) EQ 1 THEN self.sigma[*]=sigma 
    IF N_Elements(sigma) EQ 3 THEN self.sigma=sigma
ENDIF
IF N_Elements(gamma) NE 0 THEN BEGIN
    IF N_Elements(gamma) EQ 1 THEN self.gamma[*]=gamma 
    IF N_Elements(gamma) EQ 3 THEN self.gamma=gamma 
ENDIF

; Make the color ramp in case the parameters have changed
self->Make_Ramp

END;Kang_Colors::SetProperty--------------------------------------------------------


PRO Kang_Colors::GetProperty, $
  brightness=brightness, $
  rgb_brightness=rgb_brightness, $
  contrast=contrast, $
  rgb_contrast=rgb_contrast, $
  ncolors=NColors, $
  colornames=colornames, $
  colorindex=colorindex, $
  red=r, $
  green=g, $
  blue=b, $
  ramp=ramp, $
  scaling=scaling
; Returns the properties of this object

IF Arg_Present(brightness) THEN brightness=self.brightness
IF Arg_Present(rgb_brightness) THEN rgb_brightness=self.rgb_brightness_old
IF Arg_Present(contrast) THEN contrast=self.contrast
IF Arg_Present(rgb_contrast) THEN rgb_contrast=self.rgb_contrast_old
IF Arg_Present(NColors) THEN ncolors=self.NColors
IF Arg_Present(colornames) THEN IF Ptr_Valid(self.colornames) THEN colornames = *self.colornames ELSE colornames = ''
IF Arg_Present(colorindex) THEN colorindex = self.colorindex
IF Arg_Present(r) THEN r=self.r
IF Arg_Present(g) THEN g=self.g
IF Arg_Present(b) THEN b=self.b
IF Arg_Present(ramp) THEN ramp=self.ramp
IF Arg_Present(scaling) THEN scaling=self.scaling

END;Kang_Colors::GetProperty---------------------------------------------------------------


PRO Kang_Colors::Load_ColorNames, colornames
; This method loads the passed array of color names into the top
; indexes.  These color names are used to draw regions, etc. This is
; not a new color table.

IF N_Elements(colornames) EQ 0 THEN BEGIN
    print, 'Please pass an array of colornames.'
    RETURN
ENDIF

; Store color names
colornames = StrTrim(colornames, 2)
IF Ptr_Valid(self.colornames) THEN *self.colornames = StrLowCase(colornames) ELSE $
  self.colornames = Ptr_New(StrLowCase(colornames))

; Set the number of colors used for drawing.
NColorNames = N_Elements(colornames)
self.NColors = Long(256-N_Elements(colornames)-1)

; Determine the correcct index for the color name
FOR i = 0, NColorNames-1 DO BEGIN
    color = FSC_Color(colornames[i], /Triple)
    self.r[255-i] = color[0]
    self.g[255-i] = color[1]
    self.b[255-i] = color[2]
ENDFOR

END;Kang_Colors::Load_ColorNames------------------------------------------------------


PRO Kang_Colors::LoadCT, colorindex
; Loads a new color table.

IF N_Elements(colorindex) NE 0 THEN self.colorindex = colorindex

; Load color table
LoadCT, self.colorindex, NColors = self.NColors, /Silent

; Save r, g, b variables
TVLCT, r, g, b, /Get
self.r[0:self.NColors-1] = r[0:self.NColors-1]
self.g[0:self.NColors-1] = g[0:self.NColors-1]
self.b[0:self.NColors-1] = b[0:self.NColors-1]

; Load the colors
self->TVLCT

END;Kang_LoadCT------------------------------------------------------------------------


FUNCTION Kang_Colors::ColorIndex, colornames
; Finds which index applies to the input colorname(s)

colornames = StrLowCase(colornames)
N_Names = N_Elements(colornames)
index_arr = LonArr(N_Names)
FOR i = 0, N_Names-1 DO index_arr[i] = 255-where(colornames EQ *self.colornames)

IF N_Names EQ 1 THEN RETURN, index_arr[0] ELSE RETURN, index_arr
END;Kang_Colors::ColorIndex------------------------------------------------------------


PRO Kang_Colors::TVLCT
; Just loads current color table

TVLCT, self.r[self.ramp[*, 0]], self.g[self.ramp[*,1]], self.b[self.ramp[*,2]]
END;Kang_Colors::TVLCT-----------------------------------------------------------------


PRO Kang_Colors::Make_Ramp
; The ramp determines how the color table is scaled.  It is affected
; by the brightness and contrast, but also by the scaling type.

index = Findgen(self.NColors)
FOR i = 0, 2 DO BEGIN
    CASE StrUpCase(self.scaling[i]) OF
        'ASINH': ramp = asinhscl(index, beta=self.beta,  OMax=self.NColors-1)
        'GAUSSIAN': ramp = gaussscl(index, sigma=self.sigma, OMax=self.NColors-1)
        'HISTEQ': ramp = *self.histramp
        'LINEAR': ramp = Byte(index)
        'LOG':  ramp = logscl(index, OMax=self.NColors-1)
        'POWER': ramp = gmascl(index, gamma=self.gamma, OMax=self.NColors-1)
        'SQUARED': ramp = BytScl(index^2.) / 255. * (self.NColors-1)
        'SQUARE ROOT': ramp = BytScl(index^(0.5)) / 255. * (self.NColors-1)
    ENDCASE

; Find slope and intercept
; The brightness and contrast are scaling strangely - but this is what looks good
    x = (self.rgb_brightness[i] * 8.333333333333 - 3.666666666667) * (self.NColors-1)
    y = (self.rgb_contrast[i] * 4 - 1.5)*(self.NColors-1)
    high = x+y
    low = x-y
    diff = (high-low) > 1
    slope = float(self.NColors-1)/diff
    intercept = -slope*low

; The ramp just tells the color vectors how to increase from 0 to 256
    ramp = long(ramp*slope+intercept) < (self.NColors-1)
    IF self.NColors LT 256 THEN self.ramp[*,i] = [ramp, BindGen(256-self.NColors)+self.NColors] ELSE self.ramp[*,i] = ramp
ENDFOR

END; Kang_Colors::Make_Ramp----------------------------------------------------------


PRO Kang_Colors::Reverse
; Reverses the color table.

self.r[0:self.nColors-1] = Reverse(self.r[0:self.nColors-1])
self.g[0:self.nColors-1] = Reverse(self.g[0:self.nColors-1])
self.b[0:self.nColors-1] = Reverse(self.b[0:self.nColors-1])

END; Kang_Colors::Reverse------------------------------------------------------------


PRO Kang_Colors::Invert
; Inverts the color table

self.r[0:self.nColors-1] = 255 - self.r[0:self.nColors-1]
self.g[0:self.nColors-1] = 255 - self.g[0:self.nColors-1]
self.b[0:self.nColors-1] = 255 - self.b[0:self.nColors-1]

END; Kang_Colors::Invert-------------------------------------------------------------


PRO Kang_Colors::Cleanup
; Frees the pointers

Ptr_Free, self.colornames
Ptr_Free, self.histramp
END; Kang_Colors::Cleanup------------------------------------------------------------


PRO Kang_Colors__Define
; Very important that ramp be a long array and not a byte. A byte
; array will "wrap around" and give strange results

struct = { KANG_COLORS, $
           brightness:0., $     ; Value from 0 to 100
           rgb_brightness:FltArr(3), $ ; Used for three color images
           rgb_brightness_old:FltArr(3), $ ; I forget what this is for
           contrast:0., $       ; Value from 0 to 100.
           colorindex:-1, $     ; Index of the loaded color table
           rgb_contrast:FltArr(3), $ ; Used for three color images
           rgb_contrast_old:FltArr(3), $ ; I forget what this is for
           colornames:Ptr_New(), $ ; Names of the drawing colors
           nColors:0L, $        ; The number of colors used to display the image.
           r:BytArr(256), $     ; The R color vector
           g:BytArr(256), $     ; The G color vector
           b:BytArr(256), $     ; The B color vector
           ramp:LonArr(256, 3), $ ; Scaling ramp
           histramp:Ptr_New(), $ ; Histogram equalization ramp
           scaling:StrArr(3), $ ; Scaling type.  Three values for 3 color images.
           gamma:0., $          ; The power law scaling index.
           beta:0., $           ; The asinch scaling index.
           sigma:0. $           ; The Gaussian scaling index.
         }

END ;Kang_Colors__Define--------------------------------------------------------------------
