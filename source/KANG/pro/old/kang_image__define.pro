FUNCTION Kang_Image::Init, $
  image, $
  header, $
  axisColor = axisColor, $
  axisCName = axisCName, $
  backColor = backColor, $
  backCName = backCName, $
  bartitle = bartitle, $
  charsize = charsize, $
  charthick = charthick, $
  colorbar_pos = colorbar_pos, $
  deltavel = deltavel, $
  filename = filename, $
  font = font, $
  position = position, $
  minor = minor, $
  NColors = NColors, $
  newlimits = newlimits, $
  noaxis = noaxis, $
  nobar = nobar, $
  pix_newlimits = pix_newlimits, $
  sexadecimal = sexadecimal, $
  subtitle = subtitle, $
  ticks = ticks, $
  tickColor = tickColor, $
  tickCName = tickCName, $
  ticklen = ticklen, $
  title = title, $
  xtitle = xtitle, $
  ytitle = ytitle, $
  C_Annotation = C_Annotation, $
  C_Charsize = C_Charsize, $
  C_Charthick = C_Charthick, $
  C_Colors = C_Colors, $
  C_Labels = C_Labels, $
  C_Linestyle = C_Linestyle, $
  C_Thick = C_Thick, $
  Downhill = Downhill, $
  Levels = Levels, $
  NLevels = NLevels, $
  Max_Value = Max_Value, $
  Min_Value = Min_Value, $
  percent = percent

; Load the image. This sets many of the important parameters
;--------------------------------------------------------------------------------
; Assume filename, no header input
IF size(image, /tname) EQ 'STRING' THEN BEGIN
    filename = image
    IF file_test(filename, /Read) THEN BEGIN ; Check if file exists
; Read in image, send array to kang_load_image
        image = ReadFits(filename, header, /Silent)
        self->Load, temporary(image), header, /temporary
;        good_image = 1B
    ENDIF ELSE BEGIN
; File doesn't exist
        print, 'ERROR: The file ' + filename + ' cannot be found. Check spelling.'
;        good_image = 0B
    ENDELSE
ENDIF ELSE BEGIN
    IF N_Elements(image) NE 0 THEN self->Load, image, header ELSE $
      print, 'ERROR: Image variable passed is undefined.'
ENDELSE

IF N_Elements(axisColor) NE 0 THEN self.axisColor=axisColor ELSE self.axisColor = 0B
IF N_Elements(axisCName) NE 0 THEN self.axisCName=axisCName ELSE self.axisCName = 'Black'
IF N_Elements(backColor) NE 0 THEN self.backColor=backColor ELSE self.backcolor = 255B
IF N_Elements(backCName) NE 0 THEN self.backCName=backCName ELSE self.backCName = 'White'
IF N_Elements(bartitle) NE 0 THEN self.bartitle=bartitle
IF N_Elements(charsize) NE 0 THEN self.charsize=charsize ELSE self.charsize = 1.4
IF N_Elements(charthick) NE 0 THEN self.charthick=charthick ELSE self.charthick = 1
IF N_Elements(colorbar_pos) NE 0 THEN self.colorbar_pos=colorbar_pos ELSE $
  self.colorbar_pos = [0.1, 0.1, 0.9, 0.9]
IF N_Elements(deltavel) NE 0 THEN self.deltavel=deltavel
IF N_Elements(font) NE 0 THEN self.font=font ELSE self.font = -1
IF N_Elements(filename) NE 0 THEN self.filename=filename
IF N_Elements(position) NE 0 THEN self.position=position ELSE self.position = [0.1, 0.1, 0.86, 0.9]
self.newposition = self.position
self.oldposition = self.position
IF N_Elements(minor) NE 0 THEN self.minor=minor
IF N_Elements(NColors) NE 0 THEN self.NColors= 0B > NColors < 255B ELSE self.ncolors = 255B
; Need to check these
IF N_Elements(newlimits) NE 0 THEN self.newlimits=newlimits
IF N_Elements(noaxis) NE 0 THEN BEGIN
    self.noaxis=noaxis
; Set the positions
    IF self.noaxis THEN BEGIN
        self.position[0] = 0.
        self.position[1] = 0.
        self.position[2] = 1.
    ENDIF
ENDIF
IF N_Elements(nobar) NE 0 THEN self.nobar=nobar
IF N_Elements(pix_newlimits) NE 0 THEN self.pix_newlimits=pix_newlimits
IF N_Elements(sexadecimal) NE 0 THEN self.sexadecimal=sexadecimal
IF N_Elements(subtitle) NE 0 THEN self.subtitle=subtitle
IF N_Elements(ticks) NE 0 THEN self.ticks=ticks
IF N_Elements(tickColor) NE 0 THEN self.tickColor=tickColor ELSE self.tickColor = 0B
IF N_Elements(tickCName) NE 0 THEN self.tickCName=tickCName ELSE self.tickCName = 'Black'
IF N_Elements(ticklen) NE 0 THEN self.ticklen=ticklen ELSE self.ticklen = 0.02
IF N_Elements(title) NE 0 THEN self.title=title
IF N_Elements(xtitle) NE 0 THEN self.xtitle=xtitle
IF N_Elements(ytitle) NE 0 THEN self.ytitle=ytitle

IF N_Elements(c_annotation) NE 0 THEN self.c_annotation = Ptr_New(c_annotation) ELSE self.c_annotation = Ptr_New('')
IF N_Elements(c_charsize) NE 0 THEN self.c_charsize = Ptr_New(c_charsize) ELSE self.c_charsize = Ptr_New(1)
self.s_charsize = '1'
IF N_Elements(c_charthick) NE 0 THEN self.c_charthick = Ptr_New(c_charthick) ELSE self.c_charthick = Ptr_New(1)
self.s_charthick = '1'
IF N_Elements(c_colors) NE 0 THEN self.c_colors = Ptr_New(c_colors) ELSE self.c_colors = Ptr_New(255)
self.s_colors = 'White'
IF N_Elements(c_labels) NE 0 THEN self.c_labels = Ptr_New(c_labels) ELSE self.c_labels = Ptr_New(0)
IF N_Elements(c_linestyle) NE 0 THEN self.c_linestyle = Ptr_New(c_linestyle) ELSE self.c_linestyle = Ptr_New(0)
self.s_linestyle = '0'
IF N_Elements(c_thick) NE 0 THEN self.c_thick= Ptr_New(c_thick) ELSE self.c_thick = Ptr_New(1)
self.s_thick = '1'
IF N_Elements(downhill) NE 0 THEN self.downhill= downhill
IF N_Elements(levels) NE 0 THEN self.levels= Ptr_New(levels) ELSE self.levels = Ptr_New(0)
IF N_Elements(nlevels) NE 0 THEN self.nlevels = nlevels ELSE self.nlevels = 6
IF N_Elements(max_value) NE 0 THEN self.max_value = max_value
IF N_Elements(min_value) NE 0 THEN self.min_value = min_value
IF N_Elements(percent) NE 0 THEN self.percent = percent ELSE self.percent = 1B

; Peak Fitting stuff
self.fitType = 'Gaussian'
self.tilt = 1B

; DAOPhot stuff
self.sharplim = [0.2, 1.0]
self.roundlim = [-1.0, 1.0]

RETURN, 1
END; Kang_Image::Init-------------------------------------------------------


FUNCTION Kang_Image::GetProperty, $
  astr=astr, $
  axisColor=axisColor, $
  axisCName=axisCName, $
  backColor=backColor, $
  backCName=backCName, $
  bartitle=bartitle, $
  charsize=charsize, $
  charthick=charthick, $
  circular=circular, $
  colorbar_pos=colorbar_pos, $
  current_coords = current_coords, $
  deltavel=deltavel, $
  filename=filename, $
  fitType=fitType, $
  font=font, $
  fwhm=fwhm, $
  header=header, $
  image=image, $
  byt_image=byt_image, $
  position=position, $
  xsize=xsize, $
  ysize=ysize, $
  limits=limits, $
  minor=minor, $
  native_coords=native_coords, $
  native_limits=native_limits, $
  newheader=newheader, $
  newposition=newposition, $
  newlimits=newlimits, $
  noaxis=noaxis, $
  nobar=nobar, $
  pix_limits=pix_limits, $
  pix_newlimits=pix_newlimits, $
  reverse_x=reverse_x, $
  reverse_y=reverse_y, $
  sexadecimal=sexadecimal, $
  skyval=skyval, $
  skysig=skysig, $
  stars=stars, $
  subtitle=subtitle, $
  tickColor=tickColor, $
  tickCName=tickCName, $
  ticklen=ticklen, $
  ticks=ticks, $
  tilt=tilt, $
  title=title, $
  type=type, $
  vel_astr=vel_astr, $
  velocity=velocity, $
  xtitle=xtitle, $
  ytitle=ytitle, $
  _Extra = extra

IF Keyword_Set(astr) THEN RETURN, *self.astr
IF Keyword_Set(axisColor) THEN RETURN, self.axisColor
IF Keyword_Set(axisCName) THEN RETURN, self.axisCName
IF Keyword_Set(backColor) THEN RETURN, self.backColor
IF Keyword_Set(backCName) THEN RETURN, self.backCName
IF Keyword_Set(bartitle) THEN RETURN, self.bartitle
IF Keyword_Set(charsize) THEN RETURN, self.charsize
IF Keyword_Set(charthick) THEN RETURN, self.charthick
IF Keyword_Set(circular) THEN RETURN, self.circular
IF Keyword_Set(colorbar_pos) THEN RETURN, self.colorbar_pos
IF Keyword_Set(current_coords) THEN RETURN, self.current_coords
IF Keyword_Set(deltavel) THEN RETURN, self.deltavel
IF Keyword_Set(filename) THEN RETURN, self.filename
IF Keyword_Set(font) THEN RETURN, self.font
IF Keyword_Set(fitType) THEN RETURN, self.fitType
IF Keyword_Set(fwhm) THEN RETURN, self.fwhm
IF Keyword_Set(header) THEN RETURN, self.header
IF Keyword_Set(image) THEN RETURN, *self.image
IF Keyword_Set(byt_image) THEN RETURN, *self.byt_image
IF Keyword_Set(position) THEN RETURN, self.position
IF Keyword_Set(xsize) THEN RETURN, self.xsize
IF Keyword_Set(ysize) THEN RETURN, self.ysize
IF Keyword_Set(limits) THEN RETURN, self.limits
IF Keyword_Set(minor) THEN RETURN, self.minor
IF Keyword_Set(native_coords) THEN RETURN, self.native_coords
IF Keyword_Set(native_limits) THEN RETURN, self.native_limits
IF Keyword_Set(newheader) THEN RETURN, self.newheader
IF Keyword_Set(newposition) THEN RETURN, self.newposition
IF Keyword_Set(newlimits) THEN RETURN, self.newlimits
IF Keyword_Set(noaxis) THEN RETURN, self.noaxis
IF Keyword_Set(nobar) THEN RETURN, self.nobar
IF Keyword_Set(pix_limits) THEN RETURN, self.pix_limits
IF Keyword_Set(pix_newlimits) THEN RETURN, self.pix_newlimits
IF Keyword_Set(reverse_x) THEN RETURN, self.reverse_x
IF Keyword_Set(reverse_y) THEN RETURN, self.reverse_y
IF Keyword_Set(roundlim) THEN RETURN, self.roundlim
IF Keyword_Set(sexadecimal) THEN RETURN, self.sexadecimal
IF Keyword_Set(sharplim) THEN RETURN, self.sharplim
IF Keyword_Set(skyval) THEN RETURN, self.skyval
IF Keyword_Set(skysig) THEN RETURN, self.skysig
IF Keyword_Set(stars) THEN IF Ptr_Valid(self.stars) THEN RETURN, *self.stars ELSE RETURN, -1
IF Keyword_Set(subtitle) THEN RETURN, self.subtitle
IF Keyword_Set(tickColor) THEN RETURN, self.tickColor
IF Keyword_Set(tickCName) THEN RETURN, self.tickCName
IF Keyword_Set(ticklen) THEN RETURN, self.ticklen
IF Keyword_Set(ticks) THEN RETURN, self.ticks
IF Keyword_Set(tilt) THEN RETURN, self.tilt
IF Keyword_Set(title) THEN RETURN, self.title
IF Keyword_Set(type) THEN RETURN, self.image_type
IF Keyword_Set(vel_astr) THEN RETURN, *self.vel_astr
IF Keyword_Set(velocity) THEN RETURN, self.velocity
IF Keyword_Set(xtitle) THEN RETURN, self.xtitle
IF Keyword_Set(ytitle) THEN RETURN, self.ytitle

RETURN, -1
END; Kang_Image::GetProperty (function)-------------------------------------


PRO Kang_Image::GetProperty, $
  astr=astr, $
  axisColor=axisColor, $
  axisCName=axisCName, $
  backColor=backColor, $
  backCName=backCName, $
  bartitle=bartitle, $
  charsize=charsize, $
  charthick=charthick, $
  colorbar_pos=colorbar_pos, $
  current_coords = current_coords, $
  deltavel=deltavel, $
  dimensions=dimensions, $
  filename=filename, $
  font=font, $
  header=header, $
  image=image, $
  byt_image=byt_image, $
  position=position, $
  xsize=xsize, $
  ysize=ysize, $
  limits=limits, $
  minor=minor, $
  native_coords=native_coords, $
  native_limits=native_limits, $
  newheader=newheader, $
  newposition=newposition, $
  newlimits=newlimits, $
  noaxis=noaxis, $
  nobar=nobar, $
  pix_limits=pix_limits, $
  pix_newlimits=pix_newlimits, $
  reverse_x=reverse_x, $
  reverse_y=reverse_y, $
  sexadecimal=sexadecimal, $
  subtitle=subtitle, $
  tickColor=tickColor, $
  tickCName=tickCName, $
  ticklen=ticklen, $
  ticks=ticks, $
  title=title, $
  type=type, $
  vel_astr=vel_astr, $
  velocity=velocity, $
  xtitle=xtitle, $
  ytitle=ytitle, $

; Fit parameters
  circular=circular, $
  fitType=fitType, $
  fitParams=fitParams, $
  fitError=fitError, $
  tilt=tilt, $

; DAOPhot parameters
  fwhm=fwhm, $
  err_fwhm=err_fwhm, $
  roundlim=roundlim, $
  ps_threshold=ps_threshold, $
  sharplim=sharplim, $
  skyval=skyval, $
  skysig=skysig, $
  stars=stars, $

; Contouring parameters
  C_Annotation = C_Annotation, $
  C_Charsize = C_Charsize, $
  C_Charthick = C_Charthick, $
  C_Colors = C_Colors, $
  C_Labels = C_Labels, $
  C_Linestyle = C_Linestyle, $
  C_Thick = C_Thick, $
  Downhill = Downhill, $
  Levels = Levels, $
  NLevels = NLevels, $
  Lev_Out = Lev_Out, $
  Max_Value = Max_Value, $
  Min_Value = Min_Value, $
  percent = percent, $
  s_nlevels = s_nlevels, $
  All = All

IF Arg_Present(astr) THEN BEGIN
    IF Ptr_Valid(self.astr) THEN astr=*self.astr ELSE astr = ''
ENDIF
IF Arg_Present(axisColor) THEN axisColor=self.axisColor
IF Arg_Present(axisCName) THEN axisCName=self.axisCName
IF Arg_Present(backColor) THEN backColor=self.backColor
IF Arg_Present(backCName) THEN backCName=self.backCName
IF Arg_Present(bartitle) THEN bartitle=self.bartitle
IF Arg_Present(charsize) THEN charsize=self.charsize
IF Arg_Present(charthick) THEN charthick=self.charthick
IF Arg_Present(colorbar_pos) THEN colorbar_pos=self.colorbar_pos
IF Arg_Present(current_coords) THEN current_coords=self.current_coords
IF Arg_Present(deltavel) THEN deltavel=self.deltavel
IF Arg_Present(dimensions) THEN dimensions=[self.pix_limits[1]+1, self.pix_limits[3]+1]
IF Arg_Present(filename) THEN filename=self.filename
IF Arg_Present(font) THEN font=self.font
IF Arg_Present(header) THEN header=*self.header
IF Arg_Present(image) THEN image=*self.image
IF Arg_Present(byt_image) THEN byt_image=*self.byt_image
IF Arg_Present(position) THEN position=self.position
IF Arg_Present(xsize) THEN xsize=self.xsize
IF Arg_Present(ysize) THEN ysize=self.ysize
IF Arg_Present(limits) THEN limits=self.limits
IF Arg_Present(minor) THEN minor=self.minor
IF Arg_Present(native_coords) THEN native_coords=self.native_coords
IF Arg_Present(native_limits) THEN native_limits=self.native_limits
IF Arg_Present(newheader) THEN newheader=*self.newheader
IF Arg_Present(newposition) THEN newposition=self.newposition
IF Arg_Present(newlimits) THEN newlimits=self.newlimits
IF Arg_Present(noaxis) THEN noaxis=self.noaxis
IF Arg_Present(nobar) THEN nobar=self.nobar
IF Arg_Present(pix_limits) THEN pix_limits=self.pix_limits
IF Arg_Present(pix_newlimits) THEN pix_newlimits=self.pix_newlimits
IF Arg_Present(reverse_x) THEN reverse_x=self.reverse_x
IF Arg_Present(reverse_y) THEN reverse_y=self.reverse_y
IF Arg_Present(sexadecimal) THEN sexadecimal=self.sexadecimal
IF Arg_Present(subtitle) THEN subtitle=self.subtitle
IF Arg_Present(tickColor) THEN tickColor=self.tickColor
IF Arg_Present(tickCName) THEN tickCName=self.tickCName
IF Arg_Present(ticklen) THEN ticklen=self.ticklen
IF Arg_Present(ticks) THEN ticks=self.ticks
IF Arg_Present(title) THEN title=self.title
IF Arg_Present(type) THEN type=self.image_type
IF Arg_Present(velocity) THEN velocity=self.velocity
IF Arg_Present(vel_astr) THEN IF Ptr_Valid(self.vel_astr) THEN vel_astr = *self.vel_astr
IF Arg_Present(xtitle) THEN xtitle=self.xtitle
IF Arg_Present(ytitle) THEN ytitle=self.ytitle

; Fit parameters
If Arg_Present(circular) THEN circular=self.circular
If Arg_Present(fitType) THEN fitType=self.fitType
If Arg_Present(fitParams) THEN fitParams=self.fitParams
If Arg_Present(fitError) THEN fitError=self.fitError
If Arg_Present(tilt) THEN tilt=self.tilt

; DAOPhot parameters
IF Arg_Present(fwhm) THEN fwhm=self.fwhm
IF Arg_Present(err_fwhm) THEN fwhm=self.err_fwhm
IF Arg_Present(roundlim) THEN roundlim=self.roundlim
IF Arg_Present(ps_threshold) THEN ps_threshold=self.ps_threshold
IF Arg_Present(sharplim) THEN sharplim=self.sharplim
IF Arg_Present(skyval) THEN skyval=self.skyval
IF Arg_Present(skysig) THEN skysig=self.skysig
IF Arg_Present(stars) THEN BEGIN
    IF Ptr_Valid(self.stars) THEN stars = *self.stars ELSE stars = -1
ENDIF

; Contouring parameters
IF Arg_Present(c_annotation) THEN c_annotation = *self.c_annotation
IF Arg_Present(c_charsize) THEN  c_charsize = *self.c_charsize
IF Arg_Present(c_charthick) THEN c_charthick = *self.c_charthick
IF Arg_Present(c_colors) THEN c_colors= *self.c_colors
IF Arg_Present(c_labels) THEN c_labels= *self.c_labels
IF Arg_Present(c_linestyle) THEN c_linestyle= *self.c_linestyle
IF Arg_Present(c_thick) THEN c_thick= *self.c_thick
IF Arg_Present(downhill) THEN downhill= self.downhill
IF Arg_Present(levels) THEN levels= *self.levels
IF Arg_Present(nlevels) THEN nlevels= self.nlevels
IF Arg_Present(lev_out) THEN lev_out= self.lev_out
IF Arg_Present(max_value) THEN max_value = self.max_value
IF Arg_Present(min_value) THEN min_value = self.min_value
IF Arg_Present(all) THEN BEGIN
    all = {s_annotation:self.s_annotation, $
           s_charsize:self.s_charsize, $
           s_charthick:self.s_charthick, $
           s_colors:self.s_colors, $
           s_labels:self.s_labels, $
           s_levels:self.s_levels, $
           s_linestyle:self.s_linestyle, $
           s_nlevels:self.s_nlevels, $
           s_thick:self.s_thick, $
           downhill:self.downhill, $
           levels:self.levels, $
           nlevels:self.nlevels, $
           max_value:self.max_value, $
           min_value:self.min_value, $
           percent:self.percent}
ENDIF
IF Arg_Present(percent) THEN percent = self.percent
IF Arg_Present(s_nlevels) THEN s_nlevels = self.s_nlevels

END; Kang_Image::GetProperty------------------------------------------------


PRO Kang_Image::SetProperty, $
  axisColor=axisColor, $
  axisCName=axisCName, $
  backColor=backColor, $
  backCName=backCName, $
  bartitle=bartitle, $
  charsize=charsize, $
  charthick=charthick, $
  colorbar_pos=colorbar_pos, $
  current_coords=current_coords, $
  deltavel=deltavel, $
  filename=filename, $
  font=font, $
  image=image, $
  header=header, $
  position=position, $
  minor=minor, $
  ncolors=ncolors, $
  noaxis=noaxis, $
  nobar=nobar, $
  sexadecimal=sexadecimal, $
  subtitle=subtitle, $
  tickColor=tickColor, $
  tickCName=tickCName, $
  ticklen=ticklen, $
  ticks=ticks, $
  title=title, $
  xtitle=xtitle, $
  ytitle=ytitle, $

; Fit Parameters
  circular=circular, $
  tilt=tilt, $
  fitType=fitType, $

; Contour Parameters
  C_Annotation = C_Annotation, $
  C_Charsize = C_Charsize, $
  C_Charthick = C_Charthick, $
  C_Colors = C_Colors, $
  C_Labels = C_Labels, $
  C_Linestyle = C_Linestyle, $
  C_Thick = C_Thick, $
  S_Annotation = S_Annotation, $
  S_Charsize = S_Charsize, $
  S_Charthick = S_Charthick, $
  S_Colors = S_Colors, $
  S_Labels = S_Labels, $
  S_Levels = S_Levels, $
  S_Linestyle = S_Linestyle, $
  S_Thick = S_Thick, $
  Downhill = Downhill, $
  Levels = Levels, $
  NLevels = NLevels, $
  Max_Value = Max_Value, $
  Min_Value = Min_Value, $
  percent = percent

IF N_Elements(axisColor) NE 0 THEN self.axisColor=axisColor
IF N_Elements(axisCName) NE 0 THEN self.axisCName=axisCName
IF N_Elements(backColor) NE 0 THEN self.backColor=backColor
IF N_Elements(backCName) NE 0 THEN self.backCName=backCName
IF N_Elements(bartitle) NE 0 THEN self.bartitle=bartitle
IF N_Elements(charsize) NE 0 THEN self.charsize=charsize
IF N_Elements(charthick) NE 0 THEN self.charthick=charthick
IF N_Elements(colorbar_pos) NE 0 THEN self.colorbar_pos=colorbar_pos
IF N_Elements(current_coords) NE 0 THEN self.current_coords=current_coords
IF N_Elements(deltavel) NE 0 THEN self.deltavel=deltavel
IF N_Elements(filename) NE 0 THEN self.filename=filename
IF N_Elements(font) NE 0 THEN self.font=font
IF N_Elements(image) NE 0 THEN self->Load, image, header
IF N_Elements(position) NE 0 THEN self.position=position
IF N_Elements(minor) NE 0 THEN self.minor=minor
IF N_Elements(ncolors) NE 0 THEN self.ncolors=ncolors
IF N_Elements(noaxis) NE 0 THEN BEGIN
    self.noaxis=noaxis
; Set the positions
;    IF self.noaxis THEN BEGIN
;        self.position[0] = 0.
;        self.position[1] = 0.
;        self.position[3] = 1.
;    ENDIF ELSE self.position = self.oldposition
ENDIF
IF N_Elements(nobar) NE 0 THEN BEGIN
    self.nobar=nobar
;    IF self.nobar THEN self.position[2] = 1. ELSE self.position = self.oldposition
ENDIF
IF N_Elements(sexadecimal) NE 0 THEN self.sexadecimal=sexadecimal
IF N_Elements(subtitle) NE 0 THEN self.subtitle=subtitle
IF N_Elements(tickColor) NE 0 THEN self.tickColor=tickColor
IF N_Elements(tickCName) NE 0 THEN self.tickCName=tickCName
IF N_Elements(ticklen) NE 0 THEN self.ticklen=ticklen
IF N_Elements(ticks) NE 0 THEN self.ticks=ticks
IF N_Elements(title) NE 0 THEN self.title=title
IF N_Elements(xtitle) NE 0 THEN self.xtitle=xtitle
IF N_Elements(ytitle) NE 0 THEN self.ytitle=ytitle

; Fit Parameters
IF N_Elements(circular) NE 0 THEN self.circular = circular
IF N_Elements(fitType) NE 0 THEN self.fitType = fitType
IF N_Elements(tilt) NE 0 THEN self.tilt = tilt

; Contour Parameters
IF N_Elements(c_annotation) NE 0 THEN *self.c_annotation = c_annotation
IF N_Elements(c_charsize) NE 0 THEN  *self.c_charsize = c_charsize
IF N_Elements(c_charthick) NE 0 THEN *self.c_charthick = c_charthick
IF N_Elements(c_colors) NE 0 THEN *self.c_colors = c_colors
IF N_Elements(c_labels) NE 0 THEN *self.c_labels = c_labels
IF N_Elements(c_linestyle) NE 0 THEN *self.c_linestyle = c_linestyle
IF N_Elements(c_thick) NE 0 THEN *self.c_thick= c_thick
IF N_Elements(downhill) NE 0 THEN self.downhill= downhill
IF N_Elements(levels) NE 0 THEN *self.levels= levels
IF N_Elements(nlevels) NE 0 THEN BEGIN
    self.nlevels = nlevels
    self->Calculate_Levels
ENDIF
IF N_Elements(max_value) NE 0 THEN BEGIN
    self.max_value = max_value
    self->Calculate_Levels
ENDIF
IF N_Elements(min_value) NE 0 THEN BEGIN
    self.min_value = min_value
    self->Calculate_Levels
ENDIF
IF N_Elements(s_annotation) NE 0 THEN self.s_annotation = s_annotation
IF N_Elements(s_charsize) NE 0 THEN  self.s_charsize = s_charsize
IF N_Elements(s_charthick) NE 0 THEN self.s_charthick = s_charthick
IF N_Elements(s_colors) NE 0 THEN self.s_colors = s_colors
IF N_Elements(s_labels) NE 0 THEN self.s_labels = s_labels
IF N_Elements(s_levels) NE 0 THEN self.s_levels = s_levels
IF N_Elements(s_linestyle) NE 0 THEN self.s_linestyle = s_linestyle
IF N_Elements(s_thick) NE 0 THEN self.s_thick = s_thick
IF N_Elements(percent) NE 0 THEN self.percent= percent

END; Kang_Image::SetProperty------------------------------------------------


PRO Kang_Image::Limits, limits, pixel = pixel
; Sets the axes ranges for the image

IF Keyword_Set(pixel) THEN pix_newlimits = limits ELSE BEGIN
    newlimits = self->Convert_Coord(limits[0:1], limits[2:3], new_coords = 'Image')
    x = [newlimits[0], newlimits[2]]
    y = [newlimits[1], newlimits[3]]
    pix_newlimits = [min(x), max(x), min(y), max(y)]
ENDELSE

; Check values
pix_newlimits[0] = pix_newlimits[0] > self.pix_limits[0]
pix_newlimits[1] = pix_newlimits[1] < self.pix_limits[1]
pix_newlimits[2] = pix_newlimits[2] > self.pix_limits[2]
pix_newlimits[3] = pix_newlimits[3] < self.pix_limits[3]

; Make sure at least 4 pixels are shown
pix_newlimits[0] = pix_newlimits[0] < (pix_newlimits[1] - 1)
pix_newlimits[2] = pix_newlimits[2] < (pix_newlimits[3] - 1)
self.pix_newlimits = pix_newlimits

; Update the x and y size
self.xsize = Fix(self.pix_newlimits[1]-self.pix_newlimits[0]+1)
self.ysize = Fix(self.pix_newlimits[3]-self.pix_newlimits[2]+1)

; Find_newlimits
self->Find_Newlimits

END; Kang_Image::Limits---------------------------------------------------------


PRO Kang_Image::Load, image, header, temporary = temporary
; Loads the image into the self structure and set some important parameters

; store image and header, contour sections
; need to set these properties in contour object: , max_value = scale_max, min_value = scale_min

; Store image as pointer - if already a pointer store that.
pointer = size(image, /TName) EQ 'POINTER' 
IF pointer THEN image_size = size(*image, /Dimensions) ELSE $
  image_size = size(image, /Dimensions)

; ---------------------------------Data Cubes------------------------------------
; Load cubes in, set vel_axis parameters
IF N_Elements(image_size) EQ 3 THEN BEGIN

; This routine makes the vel_astr structure, and transposes the image
; if necessary
    self->ThreeD_Load, image, header, pointer=pointer
    self.image_type = 'Cube'
    
; Find the limits again after possible transpose
    IF pointer THEN image_size = size(*image, /Dimensions) ELSE $
      image_size = size(image, /Dimensions)
    
ENDIF ELSE BEGIN
; 2-D images
    self.image_type = 'Image'
ENDELSE

; Determine the pixel limits, basically just the size, of the image,
; so we can use them for subscripting later
self.pix_limits[1] = image_size[0]-1
self.pix_limits[3] = image_size[1]-1
IF N_Elements(image_size) EQ 3 THEN self.pix_limits[5] = image_size[2]-1 ELSE self.pix_limits[5] = 0

;------------------------Extract the astrometry----------------------------------
IF N_Elements(header) EQ 0 THEN noparams = -1 ELSE IF header[0] EQ '' THEN noparams = -1
IF N_Elements(noparams) NE 1 THEN BEGIN
    extast, header, astr, noparams

; Successfully loaded    
    IF noparams NE -1 THEN BEGIN
; Add a projection to use if missing a projection type
        IF StrTrim(astr.ctype[0], 2) EQ 'GLON' THEN BEGIN
            astr.ctype[0] = 'GLON-CAR'
            astr.ctype[1] = 'GLAT-CAR'
        ENDIF
        
; Fix the projection from GLS(old name) to SFL(new name) and update header
        astr.ctype[*] = RepStr(astr.ctype[*], '-GLS', '-SFL')
        SXADDPAR, header, 'CTYPE1', astr.ctype[0]
        SXADDPAR, header, 'CTYPE2', astr.ctype[1]

; If cdelt1 keyword is positive, flip the axis around
;        IF astr.cdelt[0] GT 0 THEN BEGIN
;            astr.cdelt[0] = -astr.cdelt[0]
;            image = reverse(image, 1)
;;            astr.crpix[0] = astr.naxis[0]  - (astr.crpix[0]-1)
;            astr.crpix[0] = N_Elements(image[*,0,0]) - (astr.crpix[0]-1)
;        ENDIF

; Store astrometry and coordinate types
        self.astr = Ptr_New(astr)
        CASE strMid(astr.ctype[0], 0, 4) OF
            'GLON': self.native_coords = 'Galactic'
            'ELON': self.native_coords = 'Ecliptic'
            'RA--': BEGIN
                equinox = Get_Equinox(header, code)
                IF code EQ -1 THEN self.native_coords = 'J2000' ; No equinox - assume J2000

                CASE equinox OF
                    2000: self.native_coords = 'J2000'
                    1950: self.native_coords = 'B1950'
                    ELSE:       ;could precess here?
                ENDCASE
            END
            
            ELSE: self.native_coords = 'Image' 
        ENDCASE

; -----------------Replace the blank values----------------------
        blank = sxpar( header, 'BLANK', Count = N_blank) 
        IF N_blank GT 0 THEN BEGIN
            wh_blank = where(image EQ blank)
            IF wh_blank[0] NE -1 THEN image[wh_blank] = !VALUES.F_NAN
        ENDIF
    ENDIF
ENDIF

; This is if the header was bad, use image coordinates
IF noparams EQ -1 THEN BEGIN
    self.native_coords = 'Image'
    IF N_Elements(image_size) EQ 3 THEN self.image_type = 'Cube Array' ELSE self.image_type = 'Array'
ENDIF
self.current_coords = self.native_coords

; ----------------------------Limits---------------------------------------------
IF self.image_type EQ 'Cube' OR self.image_type EQ 'Cube Array' THEN BEGIN
    zmin=(self.pix_limits[4]+1 - (*self.vel_astr).crpix)*(*self.vel_astr).cdelt+(*self.vel_astr).crval
    zmax=(self.pix_limits[5]+1 - (*self.vel_astr).crpix)*(*self.vel_astr).cdelt+(*self.vel_astr).crval
ENDIF ELSE BEGIN
    zmin = 0
    zmax = 0
ENDELSE

; Rearrange limits if necessary. most images will have x-axis reversed
; Find the limits in data coordinates
self.pix_newlimits = self.pix_limits
self.pix_newlimits[5] = 0       ; Set to zero velocity integration
self->Find_Newlimits
self.newlimits[4] = zmin < zmax
self.newlimits[5] = zmin > zmax
self.limits = self.newlimits
self.native_limits = self. limits
IF self.limits[0] GT self.limits[1] THEN self.reverse_x = 1B
IF self.limits[2] GT self.limits[3] THEN self.reverse_y = 1B

; Store more values for ease later on
self.xsize = Fix(self.pix_limits[1] - self.pix_limits[0]+1)
self.ysize = Fix(self.pix_limits[3] - self.pix_limits[2]+1)

; ---------------------------Store Image and header------------------------------
IF pointer THEN self.image =  image ELSE BEGIN
    IF Keyword_Set(temporary) THEN self.image =  Ptr_New(temporary(image)) ELSE $
      self.image =  Ptr_New(image)
ENDELSE
IF N_Elements(header) NE 0 THEN self.header = Ptr_New(header) ELSE self.header = Ptr_New('')

;---------------------------Contours---------------------------------------------
;self.contour = Obj_New('Kang_Contour')
self->Scale_To_Image, lowscale = lowscale, highscale = highscale, /noscale
self.min_value = lowscale
self.max_value = highscale

; Store velocity information
IF self.image_type EQ 'Cube' OR self.image_type EQ 'Cube Array' THEN BEGIN
; Find velocity
    self.velocity = self.limits[4]

;Constrain by cdelt and half the total
    IF N_Elements(deltavel) NE 0 THEN BEGIN
        deltavel = deltavel > (*self.vel_astr).cdelt
        self.deltavel = deltavel < (self.limits[5]-self.limits[4])/2.
    ENDIF

; Update the limits and the widgets
    self.newlimits[5] = self.velocity+self.deltavel/2. < self.limits[5]
    self.newlimits[4] = self.velocity-self.deltavel/2. > self.limits[4]

; Update the pixel limits
    IF self.image_type EQ 'Cube' OR self.image_type EQ 'Cube Array' THEN BEGIN
        pix_vel = Round((self.velocity - (*self.vel_astr).crval)/(*self.vel_astr).cdelt + (*self.vel_astr).crpix - 1)
        pix_vellow = Round((self.newlimits[4] - (*self.vel_astr).crval)/(*self.vel_astr).cdelt + (*self.vel_astr).crpix - 1)
        pix_velhigh = Round((self.newlimits[5] - (*self.vel_astr).crval)/(*self.vel_astr).cdelt + (*self.vel_astr).crpix - 1)

        self.pix_newlimits[4] = pix_vellow
        self.pix_newlimits[5] = pix_velhigh
    ENDIF
ENDIF

; Create dummy pointer data so there aren't errors later
self.byt_image = Ptr_New(0B)
self->BytScl, lowscale, highscale

; Store default zooming factor
self.zoom_factor = 1.

; Compute sky level
;self->Sky
;self.ps_threshold = self.skysig * 10.

END; Kang_Image::Load-------------------------------------------------------


PRO Kang_Image::ThreeD_Load, image, header, pointer=pointer
; This just transposes the arrays correctly

; Set velocity astr values so they are defined later
vel_astr = {cdelt:1., crpix:0., crval:0., ctype:'Image'}

; No header
IF N_Elements(header) EQ 0 THEN BEGIN
    self.vel_astr = Ptr_New(vel_astr)
    RETURN
ENDIF

; Determine which axis is the velocity axis
vel_arr = ['V', 'VEL', 'VELOCITY', 'VELO', 'VELO_LSR', 'VELO-LSR']
ctype1 = StrUpCase(SXPar(header, 'CTYPE1'))
ctype3 = StrUpCase(SXPar(header, 'CTYPE3'))

; These are lbv cubes
IF (where(StrTrim(ctype3,2) EQ vel_arr))[0] NE -1 THEN BEGIN
    vel_astr.ctype = SXPar(header, 'CTYPE3')
    vel_astr.crval = SXPar(header, 'CRVAL3')
    vel_astr.cdelt = SXPar(header, 'CDELT3')
    vel_astr.crpix = SXPar(header, 'CRPIX3')
ENDIF

; These are vbl cubes
IF (where(StrTrim(ctype1,2) EQ vel_arr))[0] NE -1 THEN BEGIN
; Read in velocity information
    vel_astr.ctype = SXPar(header, 'CTYPE1')
    vel_astr.crval = SXPar(header, 'CRVAL1')
    vel_astr.cdelt = SXPar(header, 'CDELT1')
    vel_astr.crpix = SXPar(header, 'CRPIX1')
            
; Transpose the array so it is lbv
    IF Keyword_Set(pointer) THEN BEGIN
        *image = Transpose(Temporary(*image), [2, 1, 0])
    ENDIF ELSE BEGIN
        image = Transpose(Temporary(image), [2, 1, 0])
    ENDELSE

; Rearrange the header
    ctype1 = SXPar(header, 'CTYPE1')
    crval1 = SXPar(header, 'CRVAL1')
    cdelt1 = SXPar(header, 'CDELT1')
    crpix1 = SXPar(header, 'CRPIX1')
    SXAddPar, header, 'CTYPE1', SXPar(header, 'CTYPE3')
    SXAddPar, header, 'CRVAL1', SXPar(header, 'CRVAL3')
    SXAddPar, header, 'CDELT1', SXPar(header, 'CDELT3')
    SXAddPar, header, 'CRPIX1', SXPar(header, 'CRPIX3')
    SXAddPar, header, 'CTYPE3', ctype1
    SXAddPar, header, 'CRVAL3', crval1
    SXAddPar, header, 'CDELT3', cdelt1
    SXAddPar, header, 'CRPIX3', crpix1
ENDIF

; Convert to m/s - pretty crummy logic, assumes km/s if pixel spacing
;                  is less than 5 (km/s)
IF vel_astr.cdelt LT 5 THEN BEGIN
    vel_astr.cdelt = vel_astr.cdelt * 1000.
    vel_astr.crval = vel_astr.crval * 1000.
ENDIF

; Create the velocity astrometry structure
self.vel_astr = Ptr_New(vel_astr)

END; Kang_ThreeD_Load-------------------------------------------------------


PRO Kang_Image::Smooth
; This isn't ready yet - could be neat though

self.smooth = ~self.smooth
self.smoothing_radius = 5

END; Kang_Image::Smooth-----------------------------------------------------


PRO Kang_Image::BytScl, lowScale, highScale
; Bytscales the image for display.
; Need to average if it is a cube and we are making an integrated intensity image.

; Bytscale - not integrated
*self.byt_image = [0]
IF self.smooth THEN BEGIN
    IF self.pix_newlimits[4] NE self.pix_newlimits[5] THEN BEGIN
        *self.byt_image = bytScl(Smooth(self->Integrate(), self.smoothing_radius), $
                                 Min=lowScale, $
                                 Max=highScale, $
                                 Top=self.NColors-1, /NAN)
    ENDIF ELSE BEGIN
        *self.byt_image = bytScl(Smooth(*self.image, self.smoothing_radius), $
                                 Min=lowScale, $
                                 Max=highScale, $
                                 Top=self.NColors-1, /NAN)
    ENDELSE
ENDIF ELSE BEGIN
    IF self.pix_newlimits[4] NE self.pix_newlimits[5] THEN BEGIN
        *self.byt_image = bytScl(self->Integrate(), $
                                 Min=lowScale, $
                                 Max=highScale, $
                                 Top=self.NColors-1, /NAN)
    ENDIF ELSE BEGIN
        *self.byt_image = bytScl((*self.image)[*, *, self.pix_newlimits[4]], $
                                 Min=lowScale, $
                                 Max=highScale, $
                                 Top=self.NColors-1, /NAN)
    ENDELSE
ENDELSE

; Store Values for colorbar
self.lowscale = lowscale
self.highscale = highscale

END; Kang_Image::BytScl-----------------------------------------------------


PRO Kang_Image::Scale_To_Image, percent = percent, lowscale = lowscale, highscale = highscale, noscale = noscale
; Scales the image to the min and max in the displayed range.
; lowscale and highscale are output parameters.  Instead of the min
; and max, the percent keyword will implement histogram clipping.

; Determine min and max in displayed image
IF self.pix_newlimits[4] EQ self.pix_newlimits[5] THEN BEGIN
    lowScale = Min((*self.image)[self.pix_newlimits[0]:self.pix_newlimits[1], $
                                 self.pix_newlimits[2]:self.pix_newlimits[3]], Max = highScale, /NAN)
ENDIF ELSE BEGIN
    lowScale = Min((self->Integrate())[self.pix_newlimits[0]:self.pix_newlimits[1], $
                                       self.pix_newlimits[2]:self.pix_newlimits[3]], Max = highScale, /NAN)
ENDELSE

; Histogram clipping
IF N_Elements(percent) NE 0 THEN BEGIN
    histvals = histogram((self->Integrate())[self.pix_newlimits[0]:self.pix_newlimits[1], $
                                             self.pix_newlimits[2]:self.pix_newlimits[3]], $
                         locations = bins, nbins=2000, /NAN)

    percentages = total(histvals, /Cumulative, /Double) / Total(histvals, /Double)
    good = where(percentages GT (1d - percent/100.) AND percentages LT percent/100.)
;    IF good[0] EQ -1 THEN RETURN

    lowscale = (bins)[Min(good)]
    highscale = (bins)[Max(good)]
ENDIF

; Do the scaling
IF ~Keyword_Set(noscale) THEN self->BytScl, lowscale, highscale

END; Kang_Image::Scale_To_Image---------------------------------------------


PRO Kang_Image::Zoom, xpix, ypix, factor = factor, position_ratio = position_ratio, $
  window_ratio=window_ratio, limits_out = limits_out
; Zooms in about the x, y pixel by the factor.  factor=1 for just
; recentering, <1 for zoom in, > 1 for zoom out

; The factor isn't set if we are just recentering
IF N_Elements(factor) EQ 0 THEN factor=1

; Find aspect ratio of the position and window
IF N_Elements(window_ratio) EQ 0 THEN window_ratio = Float(!d.x_size / !d.y_size)
IF N_Elements(position_ratio) EQ 0 THEN position_ratio = (self.position[2]-self.position[0]) / (self.position[3] - self.position[1])

; Find center to zoom in to
IF N_Elements(xpix) EQ 0 THEN xpix = round(self.pix_newlimits[0] + (self.pix_newlimits[1] - self.pix_newlimits[0]) /2.)
IF N_Elements(ypix) EQ 0 THEN ypix = round(self.pix_newlimits[2] + (self.pix_newlimits[3] - self.pix_newlimits[2]) /2.)

; -------------Find the dimension of the new image---------------
pix_newlimits = fltarr(4)
IF window_ratio GT position_ratio THEN BEGIN
; Y is limiting, set y values
    pix_newlimits[2] = Round(ypix-(self.ysize-1)/(2*factor))
    pix_newlimits[3] = Round(ypix+(self.ysize-1)/(2*factor))
;    pix_newlimits[2] = ypix-(self.ysize-1)/(2*factor)
;    pix_newlimits[3] = ypix+(self.ysize-1)/(2*factor)

; Determine how many x pixels we should show
    new_ysize = pix_newlimits[3] - pix_newlimits[2]
    new_xsize = new_ysize * window_ratio
    pix_newlimits[0] = Round(xpix-new_xsize/2.)
    pix_newlimits[1] = Round(xpix+new_xsize/2.)
;    pix_newlimits[0] = xpix-new_xsize/2.
;    pix_newlimits[1] = xpix+new_xsize/2.

ENDIF ELSE BEGIN
; X is limiting, set x values
    pix_newlimits[0] = Round(xpix-(self.xsize-1)/(2*factor))
    pix_newlimits[1] = Round(xpix+(self.xsize-1)/(2*factor))
;    pix_newlimits[0] = xpix-(self.xsize-1)/(2*factor)
;    pix_newlimits[1] = xpix+(self.xsize-1)/(2*factor)

; Determine how many x pixels we should show
    new_xsize = pix_newlimits[1] - pix_newlimits[0]
    new_ysize = new_xsize / window_ratio
    pix_newlimits[2] = Round(ypix-new_ysize/2.)
    pix_newlimits[3] = Round(ypix+new_ysize/2.)
;    pix_newlimits[2] = ypix-new_ysize/2.
;    pix_newlimits[3] = ypix+new_ysize/2.
ENDELSE

; -----------Adjust ranges if they go off the image----------------------------
; The else statement prevents both options from being run
IF pix_newlimits[0] LT 0 THEN BEGIN
    offset = 0 - pix_newlimits[0]
    pix_newlimits[0] = pix_newlimits[0] + offset
    pix_newlimits[1] = pix_newlimits[1] + offset
ENDIF ELSE BEGIN
    IF pix_newlimits[1] GT self.pix_limits[1] THEN BEGIN
        offset = pix_newlimits[1] - self.pix_limits[1]
        pix_newlimits[1] = pix_newlimits[1] - offset
        pix_newlimits[0] = pix_newlimits[0] - offset
    ENDIF
ENDELSE

; Now y values
IF pix_newlimits[2] LT 0 THEN BEGIN
    offset = 0 - pix_newlimits[2]
    pix_newlimits[2] = pix_newlimits[2] + offset
    pix_newlimits[3] = pix_newlimits[3] + offset
ENDIF ELSE BEGIN
    IF pix_newlimits[3] GT self.pix_limits[3] THEN BEGIN
        offset = pix_newlimits[3] - self.pix_limits[3]
        pix_newlimits[3] = pix_newlimits[3] - offset
        pix_newlimits[2] = pix_newlimits[2] - offset
    ENDIF
ENDELSE

; Store the new pixel limits from the new pixels
IF Arg_Present(limits_out) THEN limits_out = pix_newlimits ELSE BEGIN
    self->Limits, pix_newlimits, /Pixel
    self.zoom_factor = (self.zoom_factor * factor) > 1
ENDELSE

END; Kang_Image::Zoom-------------------------------------------------------


PRO Kang_Image::Axis, noaxis = noaxis, position = position
; Draw the axes

;noaxis = Keyword_Set(noaxis)
noaxis = self.noaxis

; Set axis ranges
xrange = [self.newlimits[0], self.newlimits[1]]
yrange = [self.newlimits[2], self.newlimits[3]]

IF self.sexadecimal THEN BEGIN
    IF self.current_coords EQ 'RA--' THEN xformat = 'RATICKS' $
    ELSE xformat = 'DECTICKS'
    yformat = 'DECTICKS'
ENDIF ELSE BEGIN
    xformat = ''
    yformat = ''
ENDELSE

;xsize = self.newlimits[1]-self.newlimits[0]+1
;ysize = self.newlimits[3]-self.newlimits[2]+1

;xtics = self.ticks              ;!X.TICKS GT 0 ? abs(!X.TICKS) : 8
;ytics = self.ticks              ;!Y.TICKS GT 0 ? abs(!Y.TICKS) : 8
;pixx = float(xsize)/xtics       ;Number of X pixels between tic marks
;pixy = float(ysize)/ytics       ;Number of Y pixels between tic marks

;CASE Abs(self.newlimits[1] - self.newlimits[0]) OF

; Find an even increment on each axis
;tics, self.newlimits[0], self.newlimits[1], xsize, pixx, raincr, RA=self.sexadecimal ;Find an even increment for RA
;tics, self.newlimits[2], self.newlimits[3], ysize, pixy, decincr ;Find an even increment for Dec
;print, raincr, decincr
;print, xsize, ysize

; Find position of first tic on each axis
;tic_one, self.newlimits[0], 10, 15, botmin, xtic1, RA=self.sexadecimal ;Position of first RA tic
;tic_one, self.newlimits[2], 10, 15, leftmin, ytic1 ;Position of first Dec tic

;  nx = fix( (xsize - 1 - xtic1)/pixx ) ;Number of X tic marks
;  ny = fix( (ysize - 1 - ytic1)/pixy ) ;Number of Y tic marks

;  IF self.sexadecimal THEN ra_grid = (botmin + findgen(nx+1)*raincr/4.) ELSE $ 
;    ra_grid = (botmin + findgen(nx+1)*raincr/60.)
;  dec_grid = (leftmin + findgen(ny+1)*decincr/60.)

;  ticlabels, botmin, nx+1, raincr, xlab, RA=self.sexadecimal, DELTA=xdelta
;  ticlabels, leftmin, ny+1, decincr, ylab,DELTA=ydelta
;ticlabels, self.newlimits[0], 10, 15, xlab, RA=self.sexadecimal, DELTA=xdelta
;ticlabels, self.newlimits[1], 10, 15, ylab, DELTA=ydelta
;ticlabels, botmin, 10, 15, xlab, RA=self.sexadecimal, DELTA=xdelta
;ticlabels, leftmin, 10, 15, ylab, DELTA=ydelta

;  xpos = cons_ra(ra_grid, 0, *self.astr ) ;Line of constant RA
;  ypos = cons_dec(dec_grid, 0, *self.astr) ;Line of constant Dec

IF noaxis THEN title = '' ELSE title = self.title
IF noaxis THEN subtitle = '' ELSE subtitle = self.subtitle
IF N_Elements(position) EQ 4 THEN position = position ELSE position = self.newposition

plot, [0], $
;      XTicks = nx, $
;      YTicks = ny, $
;      XTicks = N_Elements(xlab)-1, $
;      YTicks = N_Elements(ylab)-1, $
;      XTickV = xpos, $
;      YTickV = ypos, $
;      XTickName = xlab, $
;      YTickName = ylab, $
      Charsize=self.charsize, $
      Charthick=self.charthick, $
      Color = self.axiscolor, $
      Font = self.font, $
      Position = position, $
      Subtitle=subtitle, $
      Ticklen=self.ticklen, $
      Title=title, $
      XMinor=self.minor, $  ; Minor tick marks
      XRange=xrange, $
      XTicks=self.ticks, $
      XTickFormat=xformat, $
      Xtitle=self.xtitle, $
      YTickFormat=yformat, $
      YTicks=self.ticks, $
      Ytitle=self.ytitle, $
      YMinor=self.minor, $
      yrange = yrange, $
      xstyle = 1+4*noaxis, $
      ystyle = 1+4*noaxis, $
      /noerase

; This plots the tickmarks in a different color
plot, $
  [self.newlimits[0],self.newlimits[1]], $
  [self.newlimits[2],self.newlimits[3]], $
  Color = self.tickColor, $
  Position = position, $
  Subtitle = '', $
  Ticklen=self.ticklen, $
  Title = '', $
  XMinor=self.minor, $          ; Minor tick marks
  XRange=xrange, $
  XTitle = '', $
  XTicks=self.ticks, $
  YTicks=self.ticks, $
  YMinor=self.minor, $
  YTitle = '', $
  yrange = yrange, $
  xtickname = StrArr(25) + ' ', $
  ytickname = StrArr(25) + ' ', $
  xstyle = 1+4*noaxis, $
  ystyle = 1+4*noaxis, $
  /noerase, $
  /nodata

END; Kang_Image::Axis----------------------------------------------------------


PRO Kang_Image::Colorbar

; Determine position for colorbar. I think 15 pixels looks nice, 5
; pixels from the edge of the image
IF !D.Name EQ 'X' THEN BEGIN
    xsize = 1./!D.X_Size
    self.colorbar_pos = [self.newposition[2]+xsize * 5, self.newposition[1], $
                         self.newposition[2]+xsize * 20, self.newposition[3]]
ENDIF ELSE BEGIN
    self.colorbar_pos = [self.newposition[2]+0.01, self.newposition[1], $
                         self.newposition[2]+0.04, self.newposition[3]]
ENDELSE


; Format of numerics
IF self.highScale LT 0.0001 OR self.highscale GT 10000 THEN format = '(e8.2)' ELSE format = '(F8.2)'

colorbar, $
  charsize=self.charsize, $
  charthick=self.charthick, $
  color=self.axiscolor, $
  divisions=0, $                ; Allows inexact ranges
  font=self.font, $
  format=format, $
  minrange = self.lowScale, $
  maxrange = self.highScale, $
  ncolors = self.NColors, $
  position = self.colorbar_pos, $
  title = self.bartitle, $
  xtitle = '', $
  /vertical, $
  /right

END; Kang_Image::Colorbar----------------------------------------------------


PRO Kang_Image::TV, position = position

; Display the image with the TVImage program - different if there is a velocity
; First deal with RGB images – not ready yet
;IF self.rgb_image THEN BEGIN
;    rgb = *self.byt_image
;    self.colors->GetProperty, red=r, green=g, blue=b, ramp=ramp
;    r=r[ramp[*,0]]
;    g=g[ramp[*,1]]
;    b=b[ramp[*,2]]

;    TVImage, $
;      [[[r[(*rgb[0])[self.pix_newlimits[0]:$
;                     self.pix_newlimits[1], $
;                     self.pix_newlimits[2]:$
;                     self.pix_newlimits[3], *]]]], $  
;       [[g[(*rgb[1])[self.pix_newlimits[0]:$
;                     self.pix_newlimits[1], $
;                     self.pix_newlimits[2]:$
;                     self.pix_newlimits[3], *]]]], $
;       [[b[(*rgb[2])[self.pix_newlimits[0]:$
;                     self.pix_newlimits[1], $
;                     self.pix_newlimits[2]:$
;                     self.pix_newlimits[3], *]]]]], $
;      /Keep_Aspect_Ratio, $
;      xsize = xsize, $
;      ysize = ysize, $
;      position = position, $
;      /norm, $
;      /nointerpolation

;ENDIF ELSE BEGIN
IF N_Elements(position) EQ 0 THEN position = self.position

TVImage, $
  (*self.byt_image)[self.pix_newlimits[0]:self.pix_newlimits[1], self.pix_newlimits[2]:self.pix_newlimits[3]], $
;  xsize = xsize, $
;  ysize = ysize, $
  /Keep_Aspect_Ratio, $
  position = position, $
;  /norm, $
  /nointerpolation
;ENDELSE

; position is an output parameter from tvimage
self.newposition = position

END; Kang_Image::TV------------------------------------------------------------


PRO Kang_Image::Draw, pix_newlimits = pix_newlimits, noaxis = noaxis, nobar = nobar, noimage = noimage, position = position, noerase = noerase
; Plot the display - including the image, axis, and colorbar

; If no bytsclae image, do that first
;IF *self.byt_image

IF N_Elements(pix_newlimits) EQ 0 THEN pix_newlimits = self.pix_newlimits
IF ~Keyword_Set(noaxis) THEN noaxis = self.noaxis
IF ~Keyword_Set(nobar) THEN nobar = self.nobar
;IF noaxis AND nobar THEN position = [0, 0, 1, 1] ELSE 

; Erase the screen with the plot command
IF !D.Name NE 'PS' THEN IF ~Keyword_Set(noerase) THEN plot, [0], [0], background=self.backColor, xsty=5, ysty=5, /nodata

; Draw image
IF ~Keyword_Set(noimage) THEN self->TV, position = position

; Colorbar
IF ~Keyword_Set(nobar) THEN self->Colorbar

; Axes
;IF ~Keyword_Set(noaxis) THEN 
self->Axis, noaxis = noaxis, position = position

END; Kang_Image::Draw-------------------------------------------------------


PRO Kang_Image::Zoom_Draw, x, y, pix_newlimits = pix_newlimits
; Draws a zoomed in version of the image in the small window

; Use the zoom method to find new limits
self->Zoom, x, y, factor = (self.zoom_factor * 2) > 16, limits_out = pix_newlimits, window_ratio = 1, position_ratio = 1

pix_newlimits[0] = (pix_newlimits[0] < (pix_newlimits[1]-1)) > 0
pix_newlimits[1] = (pix_newlimits[1] > (pix_newlimits[0]+1)) < self.pix_limits[1]
pix_newlimits[2] = (pix_newlimits[2] < (pix_newlimits[3]-1)) > 0
pix_newlimits[3] = (pix_newlimits[3] > (pix_newlimits[2]+1)) < self.pix_limits[3]

;pix_newlimits[0] = Floor(pix_newlimits[0])
;pix_newlimits[1] = Ceil(pix_newlimits[1])
;pix_newlimits[2] = Floor(pix_newlimits[2])
;pix_newlimits[3] = Ceil(pix_newlimits[3])
;pix_newlimits = Floor(pix_newlimits)
;print, pix_newlimits

; Erase the screen with the plot command
plot, [0], [0], background=self.backColor, xsty=5, ysty=5, /nodata

TVImage, $
  (*self.byt_image)[pix_newlimits[0]:pix_newlimits[1] > 1, pix_newlimits[2]:pix_newlimits[3] > 1], $
  /Keep_Aspect_Ratio, $
  /norm, $
  /nointerpolation

;TVImage, $
;  (*self.byt_image)[(x-size) > 0:(x+size) < self.pix_limits[1], (y-size) > 0: (y+size) < self.pix_limits[3]], $
;  /Keep_Aspect_Ratio, $
;  /norm, $
;  /nointerpolation

END; Kang_Image::Zoom_Draw---------------------------------------------


PRO Kang_Image::Calculate_Levels
; Calculate levels from nlevels

;minValue = Min(c_image, Max = maxValue, /NAN)

;minValue = self.highscale
;maxvalue = self.lowscale

; Scale based on user input
;    minValue = minValue > self.lowscale
;    maxValue = maxValue < self.highscale

minValue = self.min_value
maxValue = self.max_value

; Create levels as min+step....max-step
step = (maxValue  - minValue) / (self.nlevels+1)
self.levels = ptr_New(findgen(self.nlevels) * step + minValue + step)
self.s_nlevels = StrCompress(StrJoin(*self.levels))

END; Kang_Image::Calculate_Levels--------------------------------------


PRO Kang_Image::Contour, image_obj
; Plots contours on top of image

image_obj->GetProperty, astr = ref_astr, newposition = newposition, byt_image = ref_byt_image, $
  header=ref_header, pix_newlimits=ref_pix_newlimits, type = ref_image_type

; Check if they are arrays as opposed to fits files with headers
contour_array = (self.image_type EQ 'Array' OR self.image_type EQ 'Cube Array')
image_array = (ref_image_type EQ 'Array' OR ref_image_type EQ 'Cube Array')
are_they_arrays = contour_array + image_array

IF contour_array + image_array EQ 1B THEN BEGIN
    print, 'Contours will only work with astronomical images with headers.'
    RETURN
ENDIF

; Fix headers
IF ref_image_type EQ 'Cube' THEN BEGIN
    SXAddPar, ref_header, 'NAXIS', '2'
    SXDelPar, ref_header, 'NAXIS3'
ENDIF
newheader = *self.header
IF self.image_type EQ 'Cube' OR self.image_type EQ 'Cube Array' THEN BEGIN
    SXAddPar, newheader, 'NAXIS', '2'
    SXDelPar, newheader, 'NAXIS3'
ENDIF

; Regrid
IF are_they_arrays EQ 0 THEN BEGIN
    hextract, ref_byt_image, ref_header, $
              ref_pix_newlimits[0], $
              ref_pix_newlimits[1], $
              ref_pix_newlimits[2], $
              ref_pix_newlimits[3], $
              /Silent

; Congrid to new dimensions - this makes everything faster
;hcongrid, c_image, c_hdr, xsize < self.xsize, ysize < self.ysize
    IF !D.Name EQ 'X' THEN BEGIN
        xsize = !D.X_Size * (newposition[2]-newposition[0])
        ysize = !D.Y_Size * (newposition[3]-newposition[1])
    ENDIF ELSE BEGIN
        xsize = 550
        ysize = 500
    ENDELSE
    hcongrid, ref_byt_image, ref_header, outsize = [xsize, ysize]

; Line them up!
    hastrom, self->Integrate(), newheader, c_image, c_hdr, ref_header, /silent

; If there is no overlap....
    IF N_Elements(c_image) EQ 0 THEN RETURN
ENDIF ELSE c_image = (*self.image)[self.pix_newlimits[0]:self.pix_newlimits[1], $
              self.pix_newlimits[2]:self.pix_newlimits[3]]

; Draw contours
print, *self.levels
help, *self.levels
;stop
contour, $
  c_image, $
  position = newposition, $
;  C_Annotation=*self.c_annotation, $
;  C_Charsize=*self.c_charsize, $
;  C_Charthick=*self.c_charthick, $
  C_Colors=*self.c_colors, $
  C_Labels=*self.c_labels, $
  C_Linestyle=*self.c_linestyle, $
  C_Thick=*self.c_thick, $
;  /Closed, $
  Downhill=self.downhill, $
  Levels=*self.levels, $
  xstyle = 1+4, $
  ystyle = 1+4, $
  /norm, $
  /noerase

END ;Kang_Image::Contour----------------------------------------------------


FUNCTION Kang_Image::Convert_Velocity, velocity_in, frompixel = frompixel
; Converts velocity to pixel values and vice versa, bounded by image limits
; Set keyword pixel to interpret input in pixels and return velocity
; in m/s.

astr = *self.vel_astr
IF Keyword_Set(frompixel) THEN BEGIN
; Converting from pixels to values
    velocity_out = self.limits[4] > ((velocity_in +1 - astr.crpix) * astr.cdelt + astr.crval) < self.limits[5]
ENDIF ELSE BEGIN
; Converting from values to pixels
    velocity_out = self.pix_limits[4] > Round((velocity_in - astr.crval) / astr.cdelt + astr.crpix - 1)  < self.pix_limits[5]
ENDELSE

RETURN, velocity_out
END; Kang_Image::Convert_Velocity------------------------------------------


PRO Kang_Image::SetVelocity, velocity, velocity2, deltavel = deltavel, pixel = pixel
; Finds the right pixel(s) for the corresponding velocity

IF N_Elements(velocity) EQ 0 THEN BEGIN
; Put velocity into pixel space if needed
    IF Keyword_Set(pixel) THEN BEGIN
        velocity = self->Convert_Velocity(self.velocity)
    ENDIF ELSE BEGIN
        velocity = self.velocity
    ENDELSE
ENDIF

; Set velocity, deltavel if they are input as a range
IF N_Elements(velocity2) NE 0 THEN BEGIN
    deltavel = Abs(velocity - velocity2)
    velocity = Min([velocity, velocity2]) + deltavel/2.
ENDIF

; Mess arond with the vel_astr structure
IF Ptr_Valid(self.vel_astr) THEN vel_astr = *self.vel_astr
IF size(vel_astr, /tname) NE 'STRUCT' THEN RETURN

; First the velocity
IF Keyword_Set(pixel) THEN BEGIN
    pix_velocity = velocity
ENDIF ELSE BEGIN
    pix_velocity = self->Convert_Velocity(velocity)
ENDELSE

; Now we need to convert back in case specified velocity is not the
; right value
self.velocity = self->Convert_Velocity(pix_velocity, /frompixel)

; Deltavel
IF N_Elements(deltavel) NE 0 THEN BEGIN
    IF Keyword_Set(pixel) THEN pix_deltavel = deltavel ELSE pix_deltavel = 2*Round(deltavel/vel_astr.cdelt/2.)
    self.deltavel = pix_deltavel*vel_astr.cdelt
ENDIF ELSE BEGIN
; No deltavel
    pix_deltavel = self.deltavel/vel_astr.cdelt
ENDELSE

; Update newlimits
self.pix_newlimits[4] = (pix_velocity-pix_deltavel/2.) > 0
self.pix_newlimits[5] = (pix_velocity+pix_deltavel/2.) < self.pix_limits[5]
self.newlimits[4] = self->Convert_Velocity(pix_velocity - pix_deltavel/2, /frompixel)
self.newlimits[5] = self->Convert_Velocity(pix_velocity + pix_deltavel/2, /frompixel)

END; Kang_Image::SetVelocity-----------------------------------------------


FUNCTION Kang_Image::Make_Spectrum, indices, xvals = xvals, stddev = stddev, nnstddev = nnstddev
; Creates an average spectrum from the given image indices.  The other
; parameters are outputs.

IF indices[0] EQ -1 THEN RETURN, -1

; Calculate the velocity for the x-axis in the plot
n_vel = self.pix_limits[5]-self.pix_limits[4]+1
xvals = scale_vector(findgen(n_vel), self.limits[4], self.limits[5]) / 1000.
spectrum = fltArr(n_vel)
stddev = fltArr(n_vel)

; Single pixel spectrum
IF N_Elements(indices) EQ 1 THEN BEGIN
    indices = array_indices([self.pix_newlimits[1]+1, self.pix_newlimits[3]+1], indices, /Dim)
    spectrum = (*self.image)[indices[0], indices[1], *]
ENDIF ELSE BEGIN

; Spectrum from a region with multiple pixels
    FOR i = 0, n_vel-1 DO BEGIN
; Create average spectrum
        subimage = ((*self.image)[*,*, i])[indices]
        spectrum[i] = avg(subimage, /NAN)
        stddev[i] = (avg((subimage - spectrum[i])^2, /NAN))^0.5
    ENDFOR
ENDELSE

IF Arg_Present(nnstddev) THEN BEGIN
; Find nearest neighbor
    n = N_Elements(indices)
    nnstddev = (1/(n-1) * total((spectrum_sorted[findgen(n-1)] - spectrum_sorted[findgen(n-1)+1])^2.))^0.5
ENDIF

RETURN, spectrum
END; Kang_Image::Make_Spectrum----------------------------------------------


PRO Kang_Image::Draw_MiniSpectra, indices, XRange = XRange, YRange = YRange
; Makes the mini-spectra plot

n_x = XRange[1] - XRange[0] + 1
n_y = YRange[1] - YRange[0] + 1

; Increase by one pixel
WHILE n_x LT 2 DO BEGIN
    xrange[0] = (xrange[0] - 1) > 0
    xrange[1] = (xrange[0] + 1) < self.pix_limits[1]
    n_x = XRange[1] - XRange[0] + 1
ENDWHILE
WHILE n_y LT 2 DO BEGIN
    yrange[0] = (yrange[0] - 1) > 0
    yrange[1] = (yrange[0] + 1) < self.pix_limits[1]
    n_y = YRange[1] - YRange[0] + 1
ENDWHILE

; Find x and y values
erase
xy = array_indices([self.pix_limits[1]+1, self.pix_limits[3]+1], indices, /Dim)

; Display background image
position = [0.1,0.1,0.9,0.9]
tvimage, (*self.byt_image)[xrange[0]:xrange[1], yrange[0]:yrange[1]], /noint, /half, position = position

; Constrain pixels
wh_xy = where(xy[0, *] GE xrange[0] AND xy[0, *] LE xrange[1] AND xy[1, *] GE yrange[0] AND xy[1, *] LE yrange[1])
IF wh_xy[0] NE -1 THEN BEGIN
    xy = [xy[0, wh_xy], xy[1, wh_xy]]

; Calculate where to put the plots
    pixelsize = [(position[2] - position[0]) / n_x, (position[3] - position[1]) / n_y]
    positions = [(xy[0, *] - xrange[0]) * pixelsize[0] + position[0], $
                 (xy[1, *] - yrange[0]) * pixelsize[1] + position[1], $
                 (xy[0, *]  - xrange[0]) * pixelsize[0] + pixelsize[0] + position[0], $
                 (xy[1, *] - yrange[0]) * pixelsize[1] + pixelsize[1] + position[1]]

; Plot Spectra on top
    FOR i = 0, N_Elements(xy[0, *])-1 DO BEGIN
        plot, (*self.image)[xy[0, i], xy[1, i], *], position = positions[*, i], /noerase, $
              XStyle = 5, YStyle = 5 , YRange = [self.lowscale, self.highscale]
    ENDFOR
ENDIF

; Plot axis
xy2ad, xrange + [-0.5, 0.5], yrange + [-0.5, 0.5], *self.astr, a, d
plot, [0], XRange = [a[0], a[1]], YRange = [d[0], d[1]], position = position, /noerase, /nodata, /XStyle, /YStyle

END; Kang_Image::Draw_MiniSpectra-------------------------------------------


FUNCTION Kang_Image::Fit2DPeak, fitparams, error, pix_newlimits = pix_newlimits, $
  fittype = fittype, weights = weights, circular = circular, tilt = tilt, dof = dof, $
  chisq = chisq, Gaussian = gaussian, Lorentzian = lorentzian, Moffat = moffat

CASE StrUpCase(fitType) OF
    'GAUSSIAN': gaussian = 1
    'LORENTZIAN': lorentzian = 1
    'MOFFAT': moffat = 1
    ELSE: BEGIN
        print, 'ERROR: Fit type not supported.'
        RETURN, -1
    END
ENDCASE

; Find pixel ranges
;info.image->GetProperty, astr = astr, image = image, pix_limits = pix_limits, pix_newlimits = pix_newlimits
;info.profile_region->GetProperty, xrange = xrange, yrange = yrange
;xrange = Round(minmax([x0, x1, x2, x3]))
;yrange = Round(minmax([y0, y1, y2, y3]))

; Create mask
;dim = size(image, /dim)
;IF N_Elements(dim) EQ 3 THEN image = image[*,*,pix_newlimits[4]]
;mask = info.profile_region->ComputeMask(dimensions = dim[0:1], astr = astr)
;image[where(mask EQ 0)] = 0

; Get image
;image = image[xrange[0]>0:xrange[1]<pix_limits[1], yrange[0]>0:yrange[1] < pix_limits[3]]
        
; Get properties for image display
;info.histogram->GetProperty, lowscale = lowscale, highscale = highscale
;info.colors->GetProperty, ncolors = ncolors

; Do the fitting
zfit = MPFit2DPeak((*self.image)[pix_newlimits[0] > 0:pix_newlimits[1] < self.pix_limits[1], $
                                 pix_newlimits[2] > 0:pix_newlimits[3] < self.pix_limits[3]], $
                   fitparams, Gaussian = gaussian, Lorentzian = lorentzian, Moffat = moffat, $
                   weights=weights, circular = circular, tilt = tilt, dof = dof, chisq=chisq, perror=error)

; Adjust values for astronomical purposes
pixelsize = (*self.astr).cdelt[0] * 60 * 60 ; do it in arcseconds for now
fitparams[2] = fitparams[2] * Abs(pixelsize)
fitparams[3] = fitparams[3] * Abs(pixelsize)
data = self->Convert_Coord(fitparams[4] + pix_newlimits[0] > 0, $
                           fitparams[5] + pix_newlimits[2] > 0, old_coord = 'Image')
fitparams[4] = data[0]
fitparams[5] = data[1]
fitparams[6] = fitparams[6] * !radeg
self.fitparams[0:N_Elements(fitparams)-1] = fitparams

; Now errors
error[2] = error[2] * Abs(pixelsize)
error[3] = error[3] * Abs(pixelsize)
error[4] = error[4] * Abs(float((*self.astr).cdelt[0]))
error[5] = error[5] * Abs(float((*self.astr).cdelt[0]))
error[6] = error[6] * !radeg
self.fiterror = error

RETURN, zfit
END; Kang_Image::Fit2DPeak------------------------------------------------------------


PRO Kang_Image::Find_Newlimits
; Finds new limits after, say, zooming in

; Astr isn't valid if an array was loaded
IF self.native_coords EQ 'Image' THEN BEGIN
    self.newlimits = self.pix_newlimits
    RETURN
ENDIF

; Find values in native coords
xy2ad, self.pix_newlimits[0]-0.5, self.pix_newlimits[3]+0.5, *self.astr, xmin1, ymax     ; Top left corner
xy2ad, self.pix_newlimits[0]-0.5, self.pix_newlimits[2]-0.5, *self.astr,  xmin2, ymin1   ; Bottom left corner
xy2ad, self.pix_newlimits[1]+0.5, self.pix_newlimits[2]-0.5, *self.astr,  xmax, ymin2    ; Bottom right corner

;Convert values to desired coords
xconvert_arr = [xmin1, xmin2, xmax]
yconvert_arr = [ymax, ymin1, ymin2]
limits = self->Convert_Coord(xconvert_arr, yconvert_arr)
xlimits = [limits[0, 1], limits[0, 2]]
ylimits = [limits[1, 1], limits[1, 0]]

; Do not let coordinates go over 360 degrees in x
;IF xlimits[0] GT xlimits[1] AND (*self.astr).cdelt[0] LT 0 THEN xlimits = [xlimits[0]-360., xlimits[1]]
;IF xlimits[1] GT xlimits[0] AND (*self.astr).cdelt[0] GT 0 THEN xlimits = [xlimits[0], xlimits[1]-360.]

; Store new limits
self.newlimits[0:3] = [xlimits, ylimits]

END; Kang_Find_Newlimits----------------------------------------------------


PRO Kang_Image::Extract, image, hdr
; Extracts part of an image, updates header

; Remove thrid axis in header
header = *self.header
SXAddPar, header, 'NAXIS', 2
SXDelPar, header, 'NAXIS3'

; Get smaller image
hextract, self->Integrate(), header, image, hdr, $
          self.pix_newlimits[0], $
          self.pix_newlimits[1], $
          self.pix_newlimits[2], $
          self.pix_newlimits[3], $
          /Silent

END; Kang_Image::Extract----------------------------------------------------


FUNCTION Kang_Image::Extract2, pix_newlimits = pix_newlimits
; Extracts part of an image

RETURN, (*self.image)[pix_newlimits[0]:pix_newlimits[1], pix_newlimits[2]:pix_newlimits[3]]
END; Kang_Image::Extract----------------------------------------------------


FUNCTION Kang_Image::Convert_Coord, x0, y0, old_coords = old_coords, new_coords = new_coords
; General purpose routine to go from one coordinate system to another.
; This routine uses the euler astrolib routine for most conversions.

IF N_Elements(y0) EQ 0 THEN BEGIN
; Assume 2 x n array
    y = x0[1, *]
    x = x0[0, *]
    x = reform(x)
    y = reform(y)
ENDIF ELSE BEGIN
    x = reform(x0)
    y = reform(y0)
ENDELSE

; Default values
IF N_Elements(old_coords) EQ 0 THEN old_coords = self.native_coords
IF N_Elements(new_coords) EQ 0 THEN new_coords = self.current_coords

old_coords = StrUpCase(old_coords)
new_coords = StrUpCase(new_coords)

; Branch on the type of conversion we'd like to do
CASE old_coords OF 
    'GALACTIC': BEGIN
        CASE new_coords OF
            'GALACTIC': BEGIN   ; No conversion needed
                newx = x 
                newy = y
            END
            'ECLIPTIC': euler, x, y, newx, newy, 6
            'J2000': euler, x, y, newx, newy, 2
            'B1950': euler, x, y, newx, newy, 2, /FK4
            'IMAGE': BEGIN
                ; Convert to native coordinates, then back to image
                data = self->convert_coord(x, y, old_coords = old_coords, new_coords = self.native_coords)
                ad2xy, data[0, *], data[1, *], *self.astr, newx, newy
            END
            'HORIZON':;number = 2
;BEGIN
;                euler, [limits[0], limits[1], limits[1], limits[0]], [limits[2], limits[2], limits[3], limits[3]], xlimits, ylimits, 2
;                eq2hor, xlimits, ylimits, self.juldate, xlimits, ylimits, ha, Lat = self.obs_struct.latitude, $
;                        Long = self.obs_struct.longitude, Altitude = self.obs_struct.altitude
;            END
            ELSE:
        ENDCASE
    END

    'ECLIPTIC': BEGIN
        CASE new_coords OF
            'GALACTIC': euler, x, y, newx, newy, 5
            'ECLIPTIC': BEGIN   ; No conversion needed
                newx = x 
                newy = y
            END
            'J2000': euler, x, y, newx, newy, 4
            'B1950': euler, x, y, newx, newy, 4, /FK4
            'IMAGE': BEGIN
                ; Convert to native coordinates, then back to image
                data = self->convert_coord(x, y, old_coords = old_coords, new_coords = self.native_coords)
                ad2xy, data[0, *], data[1, *], *self.astr, newx, newy
            END
            'HORIZON': 
;BEGIN
;                eq2hor, xlimits, ylimits, self.juldate, xlimits, ylimits, ha
;                euler, [limits[0], limits[1], limits[1], limits[0]], [limits[2], limits[2], limits[3], limits[3]], xlimits, ylimits, 4
;            END
            ELSE:
        ENDCASE
    END

    'J2000': BEGIN
        CASE new_coords OF
            'GALACTIC': euler, x, y, newx, newy, 1
            'ECLIPTIC': euler, x, y, newx, newy, 3
            'J2000': BEGIN      ; No conversion needed
                newx = x 
                newy = y
            END
            'B1950': bprecess, x, y, newx, newy ; Converting from J2000 to B1950
            'IMAGE': BEGIN
                ; Convert to native coordinates, then back to image
                data = self->convert_coord(x, y, old_coords = old_coords, new_coords = self.native_coords)
                ad2xy, data[0, *], data[1, *], *self.astr, newx, newy
            END
            'HORIZON': ;eq2hor, xlimits, ylimits, self.juldate, xlimits, ylimits, ha
            ELSE:
        ENDCASE
    END

    'B1950': BEGIN
        CASE new_coords OF
            'GALACTIC': euler, x, y, newx, newy, 1
            'ECLIPTIC': euler, x, y, newx, newy, 3
            'J2000': jprecess, x, y, newx, newy ; Converting from B1950 to J2000
            'B1950': BEGIN      ; No conversion needed
                newx = x 
                newy = y
            END
            'IMAGE': BEGIN
                ; Convert to native coordinates, then back to image
                data = self->convert_coord(x, y, old_coords = old_coords, new_coords = self.native_coords)
                ad2xy, data[0, *], data[1, *], *self.astr, newx, newy
            END
            'HORIZON':          ;eq2hor, xlimits, ylimits, self.juldate, xlimits, ylimits, ha
            ELSE:
        ENDCASE
    END

    'IMAGE': BEGIN
; Convert to native coordinates, then convert from there
        IF new_coords NE 'IMAGE' THEN BEGIN
            xy2ad, x, y, *self.astr, newx, newy
            data = self->Convert_Coord(newx, newy, old_coords = self.native_coords, new_coords = new_coords)
            newx = data[0, *]
            newy = data[1, *]
        ENDIF ELSE BEGIN
; Image to image non-conversion
            newx = x
            newy = y
        ENDELSE
    END
ENDCASE

; Return the values
newx = reform(newx)
newy = reform(newy)

RETURN, Transpose([[newx], [newy]])
END; Kang_Image::Convert_Coord----------------------------------------------


PRO Kang_Image::Find_Pixlimits
; Determines which pixels correspond to the input astronomical limits

; Solve the equation that determines lat, long for pixel start, end values
ad2xy, newlimits[0] < newlimits[1], newlimits[2] < newlimits[3], *self.astr, x_start, y_start
ad2xy, newlimits[0] > newlimits[1], newlimits[2] > newlimits[3], *self.astr, x_end, y_end
self.pix_newlimits[0] = Round(x_start < x_end)
self.pix_newlimits[1] = Round(x_start > x_end)
self.pix_newlimits[2] = Round(y_start < y_end)
self.pix_newlimits[3] = Round(y_start > y_end)

END ;Kang_Image::Find_PixLimits---------------------------------------------


FUNCTION Kang_Image::Check_Limits, limits_new_init
; Checks the input astronomical limits to make sure they are within the 
; image boundary

; Switch values if needed.
limits_new = fltarr(6)
limits_new[0:3] = limits_new_init

; Check for input errors, but use values anyway. There are two possibilities: first one 
; value is out of range (low or high) and second: both values are out of range. 
; In both cases, the min or max of the array are used instead.

; Check xmin
IF limits_new[0] LT self.limits[0] THEN limits_new[0] = self.limits[0]
IF limits_new[0] GT self.limits[1] THEN limits_new[0] = self.limits[0]

; Check xmax
IF limits_new[1] GT self.limits[1] THEN limits_new[1] = self.limits[1]
IF limits_new[1] LT self.limits[0] THEN limits_new[1] = self.limits[1]

; Check ymin
IF limits_new[2] LT self.limits[2] THEN imits_new[2] = self.limits[2]
IF limits_new[2] GT self.limits[3] THEN limits_new[2] = self.limits[2]

; Check ymax
IF limits_new[3] GT self.limits[3] THEN limits_new[3] = self.limits[3]
IF limits_new[3] LT self.limits[2] THEN limits_new[3] = self.limits[3]

RETURN, limits_new
END ;Kang_Image::Check_Limits-----------------------------------------------


FUNCTION Kang_Image::Find_Values, x, y, z, Data = data
; Finds value given x and y pixel values

IF Keyword_Set(data) AND self.native_coords NE 'Image' THEN BEGIN
    ad2xy, x, y, *self.astr, a, d
    x = a
    y = d
ENDIF

; Finds the value, or average value at the x and y position
n_z = N_Elements(z)
x = Round(0 > x < self.pix_limits[1])
y = Round(0 > y < self.pix_limits[3])

; These are spectra
IF n_z GT 0 THEN BEGIN
    z = Round(z)
    values = (*self.image)[x, y, z]
ENDIF ELSE BEGIN
; These are x plots, y plots or single values
    values = self->Integrate(x, y)
ENDELSE

RETURN, values
END;Kang_Image::Find_Values-------------------------------------------------


PRO Kang_Image::Find_Geometry, indices, min = min, max = max, mean = mean, stddev = stddev, weights = weights
; Finds the additional parameters of a region

IF indices[0] NE -1 THEN good_indices = where(((*self.image)[*, *, self.pix_newlimits[4]])[indices] EQ ((*self.image)[*, *, self.pix_newlimits[4]])[indices]) $
  ELSE good_indices = -1
IF good_indices[0] NE -1 THEN indices = indices[good_indices] ELSE indices = -1

IF N_Elements(indices) EQ 1 THEN BEGIN ; One index
    IF indices EQ -1 THEN BEGIN ; No indices
        min = 0
        max = 0
        mean = 0
        stddev = 0
    ENDIF ELSE BEGIN
        IF self.image_type EQ 'Cube' OR self.image_type EQ 'Cube Array' THEN min = (*self.image)[indices] $
        ELSE min = (*self.image)[indices]
        max = min
        mean = min
        stddev = 0
    ENDELSE
ENDIF ELSE BEGIN

; Multiple indices
    image = (self->Integrate())[indices]
    min = Min(image, Max = max, /NAN)
    binsize = (max-min)/(N_elements(image))^0.5

; max and min are both equal or zero
    IF binsize EQ 0 THEN BEGIN
        mean = 0
        stddev = 0
    ENDIF ELSE BEGIN
;        yhist = histogram(image, binsize = binsize, locations = xhist)
;        median = (xhist[where(yhist EQ max(yhist))])[0]

; Weight the values. Ths could be flux or area weighted
;    IF N_Elements(weights) NE 0 THEN result = moment((*self.image * weights)[indices], sDev = StdDev, /NAN, /Double) $
;    ELSE 
        result = moment(image, sDev = StdDev, /NAN, /Double)
        mean = result[0]
        stddev = stddev
    ENDELSE
ENDELSE

END;Kang_Image::Find_Geometry-----------------------------------------------


PRO Kang_Image::Histogram, histvals=histvals, bins=bins
; Calculates a histogram for an image

; Find image min, max
;min = min(*self.image, max = max, /NAN)

; Set nbins based on image type
CASE size(*self.image, /Type) OF
    1: nbins = 256
    2: nbins = 200 < (max-min+1)
    3: nbins = 200 < (max-min+1)
    ELSE: nbins = 2000
ENDCASE

; Compute histogram.
IF self.pix_newlimits[4] NE self.pix_newlimits[5] THEN $
  histvals = histogram(self->Integrate(), locations = bins, nbins=nbins, /NAN) $
ELSE $
  histvals = histogram((*self.image)[*, *, self.pix_newlimits[4]], locations = bins, nbins=nbins, /NAN)

END; Kang_Image::Histogram-------------------------------------------------


FUNCTION Kang_Image::Integrate, x, y, indices = indices
; Integrates over the third axis.  For now only does averages.

; Create x and y arrays
IF N_Elements(indices) NE 0 THEN BEGIN
    xy = Array_Indices([pix_limits[1], pix_limits[3]] + 1, indices, /Dimensions)
    x = xy[0, *]
    y = xy[1, *]
ENDIF
IF N_Elements(x) EQ 0 THEN x = lindgen(self.pix_limits[1]+1)
IF N_Elements(y) EQ 0 THEN y = lindgen(self.pix_limits[3]+1)

; Z axis the same, return normal image or point value
IF self.pix_newlimits[4] EQ self.pix_newlimits[5] THEN RETURN, (*self.image)[round(x), round(y), self.pix_newlimits[4]]

; Z axis not the same, return average
RETURN, Total((*self.image)[round(x), round(y), self.pix_newlimits[4]:self.pix_newlimits[5]], 3, /NAN)/$
        (self.pix_newlimits[5]-self.pix_newlimits[4]+1)

END ;Kang_Image::Integrate----------------------------hreh------------------------


FUNCTION Kang_Image::Threshold_Region,  $
  xclick, $
  yclick, $
  threshold_low, $
  threshold_high, $
  invert = invert, $
  interior = interior, $
  _Extra = extra
; Extracts pixels based on where user clicked where each pixel has a value above
; the threshold level

; Check if click is off the image
off = 0
IF xclick GT self.pix_limits[1] THEN off = 1
IF xclick LT self.pix_limits[0] THEN off = 1
IF yclick GT self.pix_limits[3] THEN off = 1
IF yclick LT self.pix_limits[2] THEN off = 1
IF off EQ 1 THEN BEGIN
    Print, 'Threshold click is off the image'
    RETURN, -1
ENDIF

; Find pixel value at user click
;IF Keyword_Set(invert) THEN pixval = self->Integrate(xclick, yclick) ELSE 
;pixval = self->Integrate(xclick, yclick)

; -------------------Find the indices. ----------------------------------------------------------
;IF Keyword_Set(invert) THEN indices = search2D(self->Integrate(), xclick, yclick, threshold_low, threshold_high) ELSE $
;print, threshold_low, threshold_high, pixval
;print, threshold_low > pixval, threshold_high > pixval 
indices = search2D(self->Integrate(), xclick, yclick, threshold_low, threshold_high)

; ----------------------------Create the region object--------------------------------------------
; Create the mask
mask = bytArr(self.pix_limits[1]+1, self.pix_limits[3]+1)
mask[indices] = 255B

;;pts = Find_Boundary(indices, XSize = s[1], YSize = s[2])
; Find the boundary and convert to data coordinates
contour, mask, levels = 255, path_xy = path_xy, path_info=path_info, /path_data_coords
;path_xy = Float(round(path_xy))              ;Need integers, but can't convert them correctly
;xy2ad, path_xy[0, *], path_xy[1, *], *self.astr, long, lat

IF N_Elements(path_xy) EQ 0 THEN RETURN, -1

; Creates the first object if there are holes and the only one if there are no holes
n_holes = N_Elements(path_info.value)-1
endval = total((path_info[0:0]).n)-1
IF self.native_coords EQ 'Image' THEN BEGIN
    xclick_data = xclick
    yclick_data = yclick
ENDIF ELSE xy2ad, xclick, yclick, *self.astr, xclick_data, yclick_data
oregion = Obj_New('Kang_Region', path_xy[*, 0:endval], params = [xclick_data, yclick_data, threshold_low, threshold_high], _Extra = extra)

;dimensions = [self.pix_limits[1], self.pix_limits[3] + 1]
;indices = oregion->Find_Indices(dimensions = dimensions)
;xy = array_indices(dimensions, indices, /dimensions)
;Obj_Destroy, oregion
;oregion = Obj_New('Kang_Region', xy[0, *], xy[1, *], params = [xclick_data, yclick_data, threshold_low, threshold_high], $
;                  _Extra = extra)

; Store the regions
IF n_holes GE 1 THEN BEGIN

; Create a group if there are holes
    objs = ObjArr(n_holes+1)
    objs[0] = oregion

; Loop through regions
    hole_startval = endval+1
    FOR i = 1, n_holes DO BEGIN
        hole_endval = total((path_info[0:i]).n)-1
        objs[i] = Obj_New('Kang_Region', path_xy[*, hole_startval:hole_endval], $;path_xy[1, hole_startval:hole_endval], $
                          Interior = 1, params = [xclick_data, yclick_data, threshold_low, threshold_high], _Extra = extra)
        hole_startval = hole_endval+1
    ENDFOR

; Make group
    ogroup = Obj_New('Kang_RegionGroup', objs, params = [xclick_data, yclick_data, threshold_low, threshold_high], _Extra = extra)
ENDIF

; Return a structure with the important information
IF n_holes GE 1 THEN RETURN, ogroup ELSE RETURN, oregion

END; Kang_Image::Threshold_Region-------------------------------------------


FUNCTION Kang_Image::Threshold_Image, $
  threshold_low, $
  threshold_high, $ 
  invert = invert, $
  interior = interior, $
  _Extra = extra
;  linestyle = linestyle, $
;  thick = thick, $
;  color = color,$
;  cname = cname, $
;  image_obj = image_obj

; Instead of just at one x, y click, this works over an entire image
; to create a bunch of regions
; Really should go through twice to do the threshold high stuff

indices = where(*self.image GT threshold_low AND *self.image LT threshold_high)
IF indices[0] EQ -1 THEN RETURN, -1

; ----------------------------Create the region object---------------------------
; Create the mask
mask = bytArr(self.pix_limits[1]+1, self.pix_limits[3]+1)
mask[indices] = 255B

; Find the boundary and convert to data coordinates
contour, mask, levels = 254, path_xy = path_xy, path_info=path_info, /path_data_coords
;path_xy = Float(round(path_xy))              ;Need integers, but can't convert them correctly
;xy2ad, path_xy[0, *], path_xy[1, *], *self.astr, long, lat

; Creates the first object if there are holes and the only one if there are no holes
n_holes = N_Elements(path_info.value)-1
endval = total((path_info[0:0]).n)-1
params = self->convert_coord(path_xy[0, *], path_xy[1, *], old_coord = 'Image')
params = params[*]
oregion = Obj_New('Kang_Region', path_xy[0, 0:endval], path_xy[1, 0:endval], $
                  params = params[0:endval*2+1], Interior = interior, image_obj = self, regiontype = 'Polygon', _Extra = extra)

; Store the regions
IF n_holes GE 1 THEN BEGIN

; Create a group if there are holes
    objs = ObjArr(n_holes+1)
    objs[0] = oregion

; Loop through regions
    FOR i = 1L, n_holes DO BEGIN
        hole_startval = path_info[i].offset
        hole_endval = hole_startval+path_info[i].n-1
        objs[i] = Obj_New('Kang_Region', path_xy[0, hole_startval:hole_endval], path_xy[1, hole_startval:hole_endval], $
                          Interior = ~path_info[i].high_low NE interior, params = params[hole_startval*2:hole_endval*2+1], $
                          image_obj = self, regiontype = 'Polygon', _Extra = extra)
    ENDFOR
    
; Make group
    ogroup = Obj_New('Kang_RegionGroup', objs, regionType = 'Threhold_Image', $
                     params = [threshold_low, threshold_high], image_obj = self, _Extra = extra)
ENDIF

; Return a structure with the important information
IF n_holes GE 1 THEN BEGIN
    RETURN, ogroup   
ENDIF ELSE BEGIN
    RETURN, oregion
ENDELSE

END; Kang_Image::Threshold_Image--------------------------------------------


PRO Kang_Image::Default_Titles
; Takes the axes titles from the header

CASE self.current_coords OF
    'Galactic': BEGIN
        self.xtitle = 'Galactic Longitude'
        self.ytitle = 'Galactic Latitude'
    END
    'J2000': BEGIN
        self.xtitle = 'Right Ascension'
        self.ytitle = 'Declination'
    END
    'B1950': BEGIN
        self.xtitle = 'Right Ascension'
        self.ytitle = 'Declination'
    END
    'Ecliptic': BEGIN
        self.xtitle = 'Ecliptic Longitude'
        self.ytitle = 'Ecliptic Latitude'
    END
    'Horizon': BEGIN
        self.xtitle = 'Azimuth'
        self.ytitle = 'Altitude'
    END
    'Image': BEGIN
        self.xtitle = ''
        self.ytitle = ''
    END
ENDCASE

; Bartitle
IF self.image_type NE 'Array' AND self.image_type NE 'Cube Array' THEN BEGIN
    bartitle= SXPar(*self.header, 'BUNIT')
    type = size(bartitle, /tname)
    IF type EQ 'STRING' THEN self.bartitle = barTitle
ENDIF

; Title
self.title = ''
self.subtitle = ''

END;Kang_Image::Default_Titles----------------------------------------------


PRO Kang_Image::PlotHist, indices, _Extra = extra
; Plots a histogram of the image values using the astrolib routine plothist

IF self.pix_limits[5] EQ 0 THEN BEGIN
  plothist, (*self.image)[indices], _Extra = extra

ENDIF ELSE BEGIN
    IF self.pix_newlimits[4] EQ self.pix_newlimits[5] THEN $
      plothist, (((*self.image)[*, *, self.pix_newlimits[4]])[indices]), _Extra = extra ELSE $
      plothist, self->integrate(indices = indices), _Extra = extra
ENDELSE

END; Kang_Image::PlotHist---------------------------------------------------


PRO Kang_Image::Make_3D
; Creates the idlgrvolume object. NOT READY YET!

data = bytscl(*self.image, min = self.lowScale, max = self.highScale)

myvolume = OBJ_NEW('IDlgrVolume', data)
cc = [-0.5, 1.0/32]
myvolume -> SetProperty, XCOORD_CONV=cc, YCOORD_CONV=cc, ZCOORD_CONV=cc
myvolume -> SetProperty, ZBUFFER=1
opac = bytArr(256)
opac[100:255] = bindgen(156)
myvolume -> SetProperty, OPACITY_TABLE0=opac

; Set colors
TVLCT, r, g, b, /Get
myvolume -> SetProperty, RGB_TABLE0=[[congrid(r[0:220], 256)], [congrid(g[0:220], 256)], [congrid(b[0:220], 256)]]
;myvolume -> SetProperty, COMPOSITE_FUNCTION=1
xobjview, myvolume, /Modal
Obj_Destroy, myVolume

;thisView = OBJ_NEW('IDLgrView', Color=[80,80,80], Viewplane_Rect=[-1.2,-1.1,2.3,2.3])
;thisModel = OBJ_NEW('IDLgrModel')
;thisView->Add, thisModel

;s = size((*self.image)[self.pix_newlimits[0]:self.pix_newlimits[1], self.pix_newlimits[2]:self.pix_newlimits[3],  $
;                                        (self.pix_newlimits[4]-45)>0:(self.pix_newlimits[5]+45)<self.pix_limits[5]], /Dimensions)
;maxdim = Max(s)
;xs = [0, 1./maxdim]
;ys = [0, 1./maxdim]
;zs = [0, 1./maxdim]

;myvolume = OBJ_NEW('IDlgrVolume' , ((*self.image)));[self.pix_newlimits[0]:self.pix_newlimits[1], $
;                                                                       self.pix_newlimits[2]:self.pix_newlimits[3], (self.pix_newlimits[4]-45)>0:$
;                                                  (self.pix_newlimits[5]+45)<self.pix_limits[5]]))
;myvolume->GetProperty, XRange=xrange, YRange=yrange, ZRange=zrange
;myvolume->SetProperty, RGB_TABLE0=[[r], [g], [b]]

; Create axis objects
;XTitle = 'L'
;YTitle = 'B'
;ZTitle = 'Velocity'

; Create axis text objects
;xTitle = Obj_New('IDLgrText', xtitle, Color=[0,255,0], /Enable_Formatting)
;yTitle = Obj_New('IDLgrText', ytitle, Color=[0,255,0], /Enable_Formatting)
;zTitle = Obj_New('IDLgrText', ztitle, Color=[0,255,0], /Enable_Formatting)

; Create plot objects
;helvetica10pt = Obj_New('IDLgrFont', 'Helvetica', Size=10)
;helvetica14pt = Obj_New('IDLgrFont', 'Helvetica', Size=14)

; Create axis objects
;xconv = [-self.newlimits[1]/(self.newlimits[0]-self.newlimits[1]), 1./(self.newlimits[0]-self.newlimits[1])]*(xrange[1]/maxdim)
;xAxis = Obj_New("IDLgrAxis", 0, Color=[0,255,0], Ticklen=0.1, $
;                Minor=4, Title=xtitle, Range=[self.newlimits[0], self.newlimits[1]], XCoord_Conv = xconv, Exact=1)
;xAxis->GetProperty, Ticktext=xAxisText
;xAxisText->SetProperty, Font=helvetica10pt

;yconv = [-self.newlimits[2]/(self.newlimits[3]-self.newlimits[2]), 1./(self.newlimits[3]-self.newlimits[2])]*(yrange[1]/maxdim)
;yAxis = Obj_New("IDLgrAxis", 1, Color=[0,255,0], Ticklen=0.1, $
;   Minor=4, Title=ytitle, Range=[self.newlimits[3], self.newlimits[2]], YCoord_Conv = yconv, Exact=1)
;yAxis->GetProperty, Ticktext=yAxisText
;yAxisText->SetProperty, Font=helvetica10pt

;limits = [self.velocity-10000, self.velocity+10000]/1000.
;zconv = [-limits[0]/(limits[1]-limits[0]), 1./(limits[1]-limits[0])]
;zAxis = Obj_New("IDLgrAxis", 2, Color=[0,255,0], Ticklen=0.1, $
;   Minor=4, Title=ztitle, Range=[limits[0], limits[1]], ZCoord_Conv = zconv, Exact=1)
;zAxis->GetProperty, Ticktext=zAxisText
;zAxisText->SetProperty, Font=helvetica10pt

; Reverse the X Axis
;xaxis->setproperty, xcoord_conv=xs
;myvolume->SetProperty, XCoord_Conv=xs
;xAxis->SetProperty, XCoord_Conv=xs, TextBaseline=[-1, 0, 0]

;yaxis->setproperty, ycoord_conv=ys
;zaxis->setproperty, zcoord_conv=zs
;xs = [-0.5, 0.01]
;ys = [-0.5, 0.01]
;zs = [-0.5, 0.01]
;myvolume->setProperty, XCoord_conv=xs, YCoord_Conv=ys, ZCoord_Conv=zs

; Set Colors
;TVLCT, r, g, b, /Get
;myvolume -> SetProperty, RGB_TABLE0=[[r], [g], [b]]

; Set opacities
;opac = bytarr(256)
;opac[*] = 128
;opac[0:127] = bindgen(128)/8
;opac[0:80] = 0
;opac[81:255] = bindgen(175)+30
;opac[128] = 255
;myvolume -> SetProperty, OPACITY_TABLE0=opac

; Add atosm to model
;thismodel->add, xaxis
;thismodel->add, yaxis
;thismodel->add, zaxis
;thisModel->Add, myvolume

; View it
;thismodel -> Rotate, [0, 1, 0], 45
;xobjview, thismodel
;Obj_Destroy, thisview

END;Kang_Image::Make_3D-----------------------------------------------------


PRO Kang_Image::Aper

END; Kang_Image::Aper-------------------------------------------------------


PRO Kang_Image::Convol, fwhm
; Convolves the image with a Gaussian of FWHM fwhm
; Stolen completely from find.pro in the AstroLib and rearranged

IF N_Elements(fwhm) EQ 0 THEN fwhm = self.fwhm
IF fwhm EQ self.fwhm AND self.fwhm NE 0 THEN BEGIN
;    Print, 'FWHM not specified or equals that of previously run convolution - resulting image unchanged.'
    RETURN
ENDIF

; Compute additional convolution parameters
radius = 0.637*fwhm > 2.001     ;Radius is 1.5 sigma
maxbox = 13                     ;Maximum size of convolution box in pixels 
nhalf = fix(radius) < (maxbox-1)/2 ; # of pixels halfway across convolution box
nbox = 2*nhalf + 1              ;# of pixels in side of convolution box 
mask = bytarr(nbox, nbox)       ;Mask identifies valid pixels in convolution box 

; Compute convolution kernel g
gauss_kernel = fltarr(nbox, nbox)
row2 = (findgen(nbox)-nhalf)^2
FOR i = 0, nhalf DO BEGIN
    temp = row2 + i^2
    gauss_kernel[0, nhalf-i] = temp         
    gauss_kernel[0, nhalf+i] = temp                           
ENDFOR

; Mask out certain pixels from convolution filter
; MASK is complementary to SKIP in Stetson's Fortran
IF Ptr_Valid(self.mask) THEN *self.mask = fix(gauss_kernel LE radius^2.) ELSE $
  self.mask = Ptr_New(fix(gauss_kernel LE radius^2.))
good = where(*self.mask, pixels) ;Value of "kernel" are now equal to distance to center

; Compute real convolution kernel "self.kernel"
sigsq = (fwhm/2.35482)^2
gauss_kernel = exp(-0.5*gauss_kernel/sigsq)

IF Ptr_Valid(self.kernel) THEN *self.kernel = gauss_kernel*(*self.mask) ELSE $
  self.kernel = Ptr_New(gauss_kernel*(*self.mask))

; Normalize kernel
sum_kernel = total(*self.kernel)
sum_kernelsq = total(*self.kernel^2) - sum_kernel^2/pixels
sum_kernel = sum_kernel/pixels
(*self.kernel)[good] = ((*self.kernel)[good] - sum_kernel)/sum_kernelsq
self.err_fwhm = (total((*self.kernel)[good]^2))^ 0.5

; Convolve image with kernel
IF Ptr_Valid(self.convolved_image) THEN *self.convolved_image = convol(*self.image, *self.kernel) ELSE $
  self.convolved_image = Ptr_New(convol(*self.image, *self.kernel))

; Blank out edges
(*self.convolved_image)[0:nhalf-1,*] = 0 & (*self.convolved_image)[self.pix_limits[1]+1-nhalf:self.pix_limits[1], *] = 0
(*self.convolved_image)[*,0:nhalf-1] = 0 & (*self.convolved_image)[*, self.pix_limits[3]+1-nhalf:self.pix_limits[3]] = 0

; Store fwhm and g
self.fwhm = fwhm
IF Ptr_Valid(self.gauss_kernel) THEN *self.gauss_kernel = gauss_kernel ELSE $
  self.gauss_kernel = Ptr_New(gauss_kernel)

END; Kang_Image::Convol-----------------------------------------------------------


PRO Kang_Image::Draw_Stars, color = color, bad_color = bad_color

IF ~Ptr_Valid(self.stars) THEN RETURN

good = where((*self.stars).good EQ 1B, complement = bad)

; Only plot if stars are there
IF Ptr_Valid(self.stars) THEN BEGIN
    plotsym, 0

; Define symsize in relation to number of pixels displayed
    symsize = (20 * (alog10(self.xsize))^(-1.) - 5.) > 1
    symsize = (0.35 * (float(self.pix_limits[1] - self.pix_limits[0]) / self.xsize)) > 1
    oplot, ((*self.stars).x)[good], ((*self.stars).y)[good], psym = 8, symsize = symsize, color = color
    oplot, ((*self.stars).x)[bad], ((*self.stars).y)[bad], psym = 8, symsize = symsize, color = bad_colors
ENDIF

END; Kang_Image::Draw_Stars-------------------------------------------------------


PRO Kang_Image::Find, x, y, flux, sharpness, roundness, threshold = ps_threshold, $
  Silent=silent, Monitor= monitor
; Finds stars in the image using modified DAOPHOT procedure
; Stolen completely from find.pro

IF ~Ptr_Valid(self.convolved_image) THEN BEGIN
    Print, 'ERROR: Must run convolution first.'
    RETURN
ENDIF

IF N_Elements(ps_threshold) EQ 0 THEN ps_threshold = self.ps_threshold ELSE ps_threshold = self.skysig * ps_threshold

; Parameters of convolution kernel
nbox = N_Elements((*self.kernel)[*, 0]) ; Length of kernel
nhalf = (nbox - 1)/2            ; Middle of kernel

; Find pixels greater than ps_threshold
index = where(*self.convolved_image GE ps_threshold, nfound) ;Valid image pixels are greater than threshold
IF nfound EQ 0 THEN BEGIN       ;Any maxima found?
    print, 'ERROR - No maxima exceed input threshold of ' + string(ps_threshold,'(F9.1)')
    RETURN
ENDIF

; Locate local maxima
(*self.mask)[nhalf, nhalf] = 0  ;From now on we exclude the central pixel
good = where(*self.mask, pixels)      ;"good" identifies position of valid pixels
xx= (good mod nbox) - nhalf	;x and y coordinate of valid pixels 
yy = fix(good/nbox) - nhalf     ;relative to the center
offset = yy * (self.pix_limits[1]+1) + xx

FOR i= 0L, pixels-1 DO BEGIN
    stars = where ((*self.convolved_image)[index] GE (*self.convolved_image)[index+offset[i]], nfound)
    IF nfound EQ 0 THEN BEGIN   ;Do valid local maxima exist?
        print, 'ERROR - No maxima exceed input threshold of ' + string(hmin,'(F9.1)')
        RETURN
    ENDIF
    index = index[stars]
ENDFOR

; Find x and y indices of local maxima
ix = index MOD (self.pix_limits[1]+1)
iy = index/(self.pix_limits[1]+1)
n_stars = N_elements(index)

;--------------------------------------------------------------------------------
;------------------------------Compute statistics------------------------------
ind = lindgen(n_stars)
flux = (*self.convolved_image)[ix[ind], iy[ind]]       ; actual pixel intensity        

; Needed for roundness statistic
row2 = (findgen(nbox)-nhalf)^2
sigsq = (self.fwhm/2.35482)^2
c1 = exp(-.5*row2/sigsq)
sumc1 = total(c1)/nbox
sumc1sq = total(c1^2) - sumc1
c1 = (c1-sumc1)/sumc1sq

; Needed for centroid statistic
;
;  In fitting Gaussians to the marginal sums, pixels will arbitrarily be 
; assigned weights ranging from unity at the corners of the box to 
; NHALF^2 at the center (e.g. if NBOX = 5 or 7, the weights will be
;
;                                 1   2   3   4   3   2   1
;      1   2   3   2   1          2   4   6   8   6   4   2
;      2   4   6   4   2          3   6   9  12   9   6   3
;      3   6   9   6   3          4   8  12  16  12   8   4
;      2   4   6   4   2          3   6   9  12   9   6   3
;      1   2   3   2   1          2   4   6   8   6   4   2
;                                 1   2   3   4   3   2   1
;
; respectively).  This is done to desensitize the derived parameters to 
; possible neighboring, brighter stars.
;
; LDA - I can't follow this part, but it must have something to do
;       with explanation above
xwt = fltarr(nbox,nbox)
wt = nhalf - abs(findgen(nbox)-nhalf ) + 1
FOR i = 0, nbox-1 DO xwt[0, i] = wt
ywt = transpose(xwt)
sgx = total(*self.gauss_kernel*xwt,1)
p = total(wt)
sgy = total(*self.gauss_kernel*ywt,2)
sumgx = total(wt*sgy)
sumgy = total(wt*sgx)
sumgsqy = total(wt*sgy*sgy)
sumgsqx = total(wt*sgx*sgx)
vec = nhalf - findgen(nbox) 
dgdx = sgy*vec
dgdy = sgx*vec
sdgdxs = total(wt*dgdx^2)
sdgdx = total(wt*dgdx) 
sdgdys = total(wt*dgdy^2)
sdgdy = total(wt*dgdy) 
sgdgdx = total(wt*sgy*dgdx)
sgdgdy = total(wt*sgx*dgdy)

; ------------------------------Compute statistics for all stars in a loop------------------------------
; The tradeoff here is whether to store the image of each star, or to
; loop.  For large numbers of stars, looping is probably better to
; conserve memory.
x = FltArr(n_stars)
dx = FltArr(n_stars)
dx2 = FltArr(n_stars)
hx = FltArr(n_stars)
y = FltArr(n_stars)
dy = FltArr(n_stars)
dy2 = FltArr(n_stars)
hy = FltArr(n_stars)
roundness = FltArr(n_stars)
sharpness = FltArr(n_stars)

FOR i = 0L, n_stars-1 DO BEGIN
    temp = float((*self.image)[(ix[i]-nhalf) > 0:(ix[i]+nhalf) < self.pix_limits[1], (iy[i]-nhalf) > 0:(iy[i]+nhalf) < self.pix_limits[3]])
;    temp = float((*self.image)[ix[i]-nhalf:ix[i]+nhalf, iy[i]-nhalf:iy[i]+nhalf])

; Compute Sharpness statistic
    sharpness[i] = (temp[nhalf, nhalf] - (total(*self.mask*temp))/pixels)/flux[i]

; Compute Roundness statistic
    dx[i] = total(total(temp,2)*c1)   
    dy[i] = total(total(temp,1)*c1)
    roundness[i] = 2 * (dx[i] - dy[i]) / (dx[i] + dy[i]) ;Roundness statistic

; Centroid computation:   The centroid computation was modified in Mar 2008 and
; now differs from DAOPHOT which multiplies the correction dx by 1/(1+abs(dx)). 
; The DAOPHOT method is more robust (e.g. two different sources will not merge)
; especially in a package where the centroid will be subsequently be 
; redetermined using PSF fitting.   However, it is less accurate, and introduces
; biases in the centroid histogram.   The change here is the same made in the 
; IRAF DAOFIND routine (see 
; http://iraf.net/article.php?story=7211&query=daofind )
;    
; HX is the height of the best-fitting marginal Gaussian.   If this is not
; positive then the centroid does not make sense 
    sd = total(temp*ywt,2)
    sumgd = total(wt*sgy*sd)
    sumd = total(wt*sd)
    sddgdx = total(wt*sd*dgdx)
    hx[i] = (sumgd - sumgx*sumd/p) / (sumgsqy - sumgx^2/p)

    skylvl = (sumd - hx[i]*sumgx)/p
    dx2[i] = (sgdgdx - (sddgdx-sdgdx*(hx[i]*sumgx + skylvl*p)))/(hx[i]*sdgdxs/sigsq)
    x[i] = ix[i] + dx2[i]       ;X centroid in original array

; Find Y centroid                 
    sd = total(temp*xwt,1)
    sumgd = total(wt*sgx*sd)
    sumd = total(wt*sd)
    sddgdy = total(wt*sd*dgdy)
    hy[i] = (sumgd - sumgy*sumd/p) / (sumgsqx - sumgy^2/p)

    skylvl = (sumd - hy[i]*sumgy)/p
    dy2[i] = (sgdgdy - (sddgdy-sdgdy*(hy[i]*sumgy + skylvl*p)))/(hy[i]*sdgdys/sigsq)
    y[i] = iy[i] +dy2[i]        ;Y centroid in original array
ENDFOR

;----------------------------------------------------------------------
; Store values
Ptr_Free, self.stars
IF N_Elements(x) EQ 0 THEN RETURN

; Convert
;xyvals = self->Convert_Coord(x, y, old_coord = 'Image')
;x = reform(xyvals[0, *])
;y = reform(xyvals[1, *])

; Create new structure
self.stars = Ptr_New({$
             fwhm:self.fwhm, $
             n_stars:n_stars, $
             x:x, $
             y:y, $
             dx:dx, $
             dx2:dx2, $
             hx:hx, $
             dy:dy, $
             dy2:dy2, $
             hy:hy, $
             flux:flux, $
             sharplim:fltarr(2), $
             roundlim:fltarr(2), $
             roundness:roundness, $
             sharpness:sharpness, $
             badsharp:bytarr(n_stars), $
             n_badsharp:0L, $
             badround:bytarr(n_stars), $
             n_badround:0L, $
             badcntrd:bytarr(n_stars), $
             n_badcntrd: 0L, $
             good:bytarr(n_stars), $
             n_good:0L})

END; Kang_Image::Find-------------------------------------------------------


PRO Kang_Image::Filter, sharplim, roundlim, centroidlim
; Find bad stars

;IF ~Ptr_Valid(*self.stars) THEN BEGIN
;    IF N_Elements(*self.stars) EQ 0 THEN RETURN
;ENDIF ELSE RETURN

nbox = N_Elements((*self.kernel)[*, 0]) ; Length of kernel
nhalf = (nbox - 1)/2            ; Middle of kernel

IF N_Elements(sharplim) NE 2 THEN sharplim = self.sharplim
IF N_Elements(roundlim) NE 2 THEN roundlim = self.roundlim
IF N_Elements(centroidlim) NE 2 THEN centroidlim = nhalf

; Filter results
badsharp_in = where(((*self.stars).sharpness LT sharplim[0]) OR ((*self.stars).sharpness GT sharplim[1]), n_badsharp)
badround_in = where(((*self.stars).dx LE 0) OR ((*self.stars).dy LE 0) OR $
                    ((*self.stars).roundness LT roundlim[0]) OR ((*self.stars).roundness GT roundlim[1]), n_badround)
badcntrd_in = where(((*self.stars).hx LE 0) OR ((*self.stars).hy LE 0) OR $
                    (abs((*self.stars).dx2) GE centroidlim) OR (abs((*self.stars).dy2) GE centroidlim), n_badcntrd)

; Store bad locations
badsharp = BytArr((*self.stars).n_stars)
IF badsharp_in[0] NE -1 THEN badsharp[badsharp_in] = 1B
(*self.stars).badsharp = badsharp
(*self.stars).n_badsharp = n_badsharp

badround = BytArr((*self.stars).n_stars)
IF badround_in[0] NE -1 THEN badround[badround_in] = 1B
(*self.stars).badround = badround
(*self.stars).n_badround = n_badround

badcntrd = BytArr((*self.stars).n_stars)
IF badcntrd_in[0] NE -1 THEN badcntrd[badcntrd_in] = 1B
(*self.stars).badcntrd = badcntrd
(*self.stars).n_badcntrd = n_badcntrd

; Store limits
;self.sharplim = sharplim
;self.sharplim = roundlim

; Stars have met all selection criteria.  Save results.
print, ' No. of sources rejected by SHARPNESS criteria', n_badsharp
print, ' No. of sources rejected by ROUNDNESS criteria', n_badround
print, ' No. of sources rejected by CENTROID  criteria', n_badcntrd

good_in = where(((*self.stars).sharpness GT sharplim[0]) AND ((*self.stars).sharpness LT sharplim[1]) AND $
                ((*self.stars).dx GT 0) AND ((*self.stars).dy GT 0) AND $
                ((*self.stars).roundness GT roundlim[0]) AND ((*self.stars).roundness LT roundlim[1]) AND $
                ((*self.stars).hx GT 0 AND abs((*self.stars).dx2) LT nhalf AND $
                 (*self.stars).hy GT 0 AND abs((*self.stars).dy2) LT nhalf), n_good)

; Store good ones
good = BytArr((*self.stars).n_stars)
good[good_in] = 1B
(*self.stars).good = good
(*self.stars).n_good = n_good

END; Kang_Image::Filter--------------------------------------------------------


PRO Kang_Image::GetPSF
; Instead of using the DAOPhot GetPSF function, I will use Craig
; Warkwardt's MPFit2DPeak, which is in ::Fit2DPeak.  Thus we don't
; need to run aper first.

; Determine limits for fitting
fwhm = 5
star_limits = [star_x - fwhm, star_x + fwhm, star_y - fwhm, star_y + fwhm]

; Do the fitting
zfit = self->Fit2DPeak(fitparams, error, pix_newlimits = star_limits, /Gaussian)
(*self.stars).psf = zfit
(*self.stars).psf_residuals = *self.image[star_limits[0]:star_limits[1], star_limits[2]:star_limits[3]] - zfit

END; Kang_Image::GetPSF--------------------------------------------------------


PRO Kang_Image::Sky, skyval, skysig, CIRCLERAD = circlerad, _EXTRA = _EXTRA, MEANBACK = meanback

sky, self->Integrate(), skyval, skysig, CIRCLERAD = circlerad, $
     _EXTRA = _EXTRA, /NAN, MEANBACK = meanback, /Silent

self.skyval = skyval
self.skysig = skysig

END; Kang_Image::Sky-----------------------------------------------------------


PRO Kang_Image::SubStar, ids = ids

;IF N_Elements(ids) EQ 0 THEN ids = lindgen(N_Elements(*self.stars.x))

;substar, self.image, *self.stars.x, *self.stars.y, *self.stars.mags, ids, psfname

END; Kang_Image::SubStar;----------------------------------------------------





PRO Kang_Image::Cleanup
; The purpose of this procedure is to clean up pointers,
; objects, pixmaps, and other things in our program that
; use memory.

; Free the pointers.
Ptr_Free, self.image
Ptr_Free, self.byt_image
Ptr_Free, self.header
Ptr_Free, self.newheader
Ptr_Free, self.astr
Ptr_Free, self.vel_astr
Ptr_Free, self.stars
Ptr_Free, self.kernel
Ptr_Free, self.gauss_kernel
Ptr_Free, self.convolved_image

; Contours
Ptr_Free, self.C_Annotation
Ptr_Free, self.C_Charsize
Ptr_Free, self.C_Charthick
Ptr_Free, self.C_Colors
Ptr_Free, self.C_Labels
Ptr_Free, self.C_Linestyle
Ptr_Free, self.C_Thick
Ptr_Free, self.Levels

END ;Kang_Image::Cleanup----------------------------------------------------


PRO Kang_Image__Define

; Define self structure
struct = {KANG_IMAGE, $
          image:Ptr_New(), $    ; A pointer to the image data.
          byt_image:Ptr_New(), $ ; A pointer to a bytscaled copy of image. This is what is displayed.
          header:Ptr_New(), $   ; A pointer to the image header
          newheader:Ptr_New(), $ ; A copy of the header used to make subimages
          image_type:'', $
          colors:Obj_New(), $   ; The object that manages the colors
          axisCName:'', $   ; The name of the axis color.
          backCName:'', $   ; The name of the background color.
          axisColor:0B, $
          backColor:0B, $
          bartitle:'', $        ; Title for the color bar
          charsize:0., $        ; Character size for all text
          charthick:0L, $       ; Character thickness for all text
          filename:'', $
          font:0L, $                     
          minor:0., $
          noaxis:0B, $
          nobar:0B, $
          reverse_x:0B, $
          reverse_y:0B, $
          subtitle:'', $
          tickCName:'', $
          tickColor:0B, $
          ticklen:0., $
          ticks:0., $
          title:'', $
          xtitle:'', $
          ytitle:'', $
          deltavel:0., $
          velocity:0., $
          highscale:0., $
          lowscale:0., $
          nColors:0B, $
          zoom_factor:0., $     ; Factor that the image is zoomed in by

; Plot parameters
          limits:[0., 0., 0., 0., 0., 0.], $ ; Xmin, Xmax, Ymin, Ymax of the original image in data coords
          native_limits:[0., 0., 0., 0., 0., 0.], $ ; limits in native coords
          newlimits:[0., 0., 0., 0., 0., 0.], $ ; Xmin, Xmax, Ymin, Ymax in data of region of interest
          pix_limits:[0, 0, 0, 0, 0, 0], $ ; Xmin, Xmax, Ymin, Ymax of the origional image in pixels
          pix_newlimits:[0, 0, 0, 0, 0, 0], $ ; Xmin, Xmax, Ymin, Ymax of in pixels of region of interest
          xsize:0L, $     ; The size of the image after pix_newlimits has been applied
          ysize:0L, $
          position:[0., 0., 0., 0.], $ ; The position in the draw window of the image
          newposition:[0., 0., 0., 0.], $
          oldposition:[0., 0., 0., 0.], $
          colorbar_pos:[0., 0., 0., 0.], $

; Contours parameters
          C_Annotation: Ptr_New(), $
          C_Charsize: Ptr_New(), $
          C_Charthick: Ptr_New(), $
          C_Colors: Ptr_New(), $
          C_Labels: Ptr_New(), $
          C_Linestyle: Ptr_New(), $
          C_Thick: Ptr_New(), $
          Downhill: 0B, $
          Levels: Ptr_New(), $
          NLevels: 0, $
          Lev_Out: '', $
          Max_Value: 0., $
          Min_Value: 0., $
          s_levels:'', $ ; Strings used to update the widget
          s_nlevels:'', $                                  
          s_colors:'', $
          s_annotation:'', $
          s_charthick:'', $
          s_charsize:'', $
          s_labels:'', $
          s_linestyle:'', $
          s_thick:'', $
          percent:0B, $
          
; Coordinates
          astr:Ptr_New(), $
          vel_astr:Ptr_New(), $
          sexadecimal:0B, $
          current_coords:'', $
          native_coords:'', $   ; Coordinates in the original header

; Peak fitting
          fittype:'', $         ; 'Gaussian', 'Lorentzian', 'Moffat'
          circular:0B, $        ; Whether fit must be circular, 0 for not circular
          tilt:0B, $            ; Whether fit may be tilted, or whether it must be N-S
          fitParams:fltArr(8), $
          fitError:fltArr(8), $

; Smoothing
          smooth:0B, $
          smoothing_type:'Boxcar', $
          smoothing_radius:5, $

; DAOPhot parameters
          skyval: 0., $
          skysig: 0., $
          convolved_image:Ptr_New(), $
          kernel:Ptr_New(), $
          gauss_kernel:Ptr_New(), $
          mask:Ptr_New(), $
          fwhm:0., $            ; FWHM of convolution kernel in pixels
          err_fwhm:0, $         ; Relative error from fwhm
          psf:Ptr_New(), $      ; Model PSF
          psf_residuals:Ptr_New(), $ ; Residuals from model PSF
          ps_threshold:0., $    ; Point source detection threshold in data units
          stars:Ptr_New(), $    ; Structure containing all info needed for stars
          sharplim:FltArr(2), $
          roundlim:FltArr(2) $
         }

END; Kang_Image__Define-----------------------------------------------------
