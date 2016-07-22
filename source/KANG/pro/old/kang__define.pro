; docformat = 'rst'
;
; TO DO:
; 1) Update velocity widget IDs when another image is deleted
; 2) Account for half-pixels
; 3) Enable regions to be dragged around with the mouse
; 4) Enable regions to be resized with the mouse
; 5) Clean up threshold event programs, line 7155
; 6) Other params cannot be created or saved for regiongroups, or
; maybe just threshold regions
; 7) Get minispectra plot working again
; 8) Better spectrum display control
;
;+
; Display and analysis of images and data cubes.
;
;-

;--------------------------------------------------------------------------------
; Various functions and small routines
;--------------------------------------------------------------------------------
@setarray_utils.pro
@mgauss

compile_opt idl2

;+
; Sets the realized flag so we know if the GUI display is displayed
;
; :Private:
;
;-
PRO Kang::SetRealized, realized

self.realized = realized
END; Kang::SetRealized--------------------------------------------------


;+
; Determine if mouse position falls within a region box.
;
; :Private:
;
;-
PRO Kang::RegionBoxes

self.regions->GetProperty, xrange = xrange, yrange = yrange, selected_regions = selected

IF selected[0] NE -1 THEN BEGIN
;    data = Convert_coord([xrange[0, *], xrange[0, *], xrange[1, *], xrange[1, *]], $
;                         [yrange[0, *], yrange[1, *], yrange[1, *], yrange[0, *]], /Data, /To_Device)
;    self.data[*, 2] = selected
ENDIF

END; Kang::RegionBoxes------------------------------------------------------------


;+
; Determine if the plot params dialog is up on the display (realized).
;
; :Returns:
;   1 if it is realized and 0 if not
;
; :Private:
;
;-
FUNCTION Kang::Plot_Params_Realized

RETURN, XRegistered('kang_plot_params_widget ' +StrTrim(self.tlbID, 2))
END; Kang::Plot_Params_Realized------------------------------------------------------------


;+
; Creates a basic header for images withough astrometry information.
;
; :Private:
;
;-
PRO Kang_MkHdr, hdr, image, xrange=xrange, yrange=yrange, zrange = zrange, $
                     Dimensions = Dimensions, Coord=coord

IF Keyword_Set(Dimensions) THEN s = image ELSE s = Float(size(image, /dim))
IF N_Elements(coord) EQ 0 THEN coord = 'GALACTIC'
CASE StrUpCase(coord) OF
    'GALACTIC': BEGIN
        ctype1 = 'GLON    '
        ctype2 = 'GLAT    '
    END
    'EQUATORIAL': BEGIN
        ctype1 = 'RA--    '
        ctype2 = 'DEC-    '
    END
    ELSE: BEGIN
        ctype1 = 'GLON    '
        ctype2 = 'GLAT    '
    END
ENDCASE

; Create basic header
mkhdr, hdr, image

; Add values so one pixel is the cdelt and the starting value is crval
cdelt1 = (xrange[1]-xrange[0]) / s[0]
sxaddpar, hdr, 'CTYPE1', ctype1
sxaddpar, hdr, 'CDELT1', cdelt1
sxaddpar, hdr, 'CRVAL1', xrange[0] + cdelt1/2.
sxaddpar, hdr, 'CRPIX1', 1

cdelt2 = (yrange[1]-yrange[0]) / s[1]
sxaddpar, hdr, 'CTYPE2', ctype2
sxaddpar, hdr, 'CDELT2', cdelt2
sxaddpar, hdr, 'CRVAL2', yrange[0] + cdelt2/2.
sxaddpar, hdr, 'CRPIX2', 1

IF N_Elements(s) EQ 3 THEN BEGIN
    cdelt3 = (zrange[1]-zrange[0]) / s[2]
    sxaddpar, hdr, 'CTYPE3', 'VELO-LSR'
    sxaddpar, hdr, 'CDELT3', cdelt3
    sxaddpar, hdr, 'CRVAL3', zrange[0]
    sxaddpar, hdr, 'CRPIX3', 1
ENDIF
END; Kang_MkHdr--------------------------------------------------------------------------------


;+
; :Private:
;
; NAME:
;    raticks
; PURPOSE:
;    Tick format to plot RA values in plots.  Interfaces with PLOT command.
;
; CALLING SEQUENCE:
;    set PLOT keyword [XY]TICKFORMAT='RATICKS'
;
; INPUTS:
;    Handled by PLOT
;
; MODIFICATION HISTORY:
;
;       Initial Documentation -- Thu Oct 5 23:02:16 2000, Erik
;                                Rosolowsky <eros@cosmic>
;-
function raticks, axis, index, value

value = value*3600
hour = long(value)/(54000)
minute = long(value-54000*hour)/900
sec =  long(value-54000*hour-900*minute)/15

;if index eq 0 then  return, string(hour, minute, sec, $
;       format = "(i2.2,'!Eh!N', i2.2, '!Em!N',i2.2,'!Es!N')") 

;return, string(hour, minute, sec, $
;               format = "(i2.2,'!Eh!N', i2.2, '!Em!N',i2.2,'!Es!N')")
return, string(hour, minute, sec, format = '(i2.2,":", i2.2, ":",i2.2)')

end



;+
; :Private:
;
; NAME:
;    decticks
; PURPOSE:
;    Tick format to plot DEC values in plots.  Interfaces with PLOT command.
;
; CALLING SEQUENCE:
;    set PLOT keyword [XY]TICKFORMAT='DECTICKS'
;
; INPUTS:
;    Handled by PLOT
;
; MODIFICATION HISTORY:
;
;       Initial Documentation -- Thu Oct 5 23:03:00 2000, Erik
;                                Rosolowsky <eros@cosmic>
;
;		
;
;-
function decticks, axis, index, value

absval = Abs(value)
hour = floor(absval)
minute = floor((absval - hour)*60)
sec = floor(((absval-hour)*60-minute)*60)
IF absval NE 0 THEN hour = hour  / (value / absval)

string = String(hour,  minute, sec, format = '(i3.2,":", i2.2, ":", i2.2)')
IF value LT 0 AND value GT -1 THEN string = '-' + string
return, StrCompress(string, /Remove_All)
end


;+
; This procedure is called automatically when the program exits.  
; It removes pointers and object references so when the program exits
; the memory is cleared and there are no extra "heap" variables left.
;
; :Private:
;
;-
PRO Kang_Cleanup, tlbID

Widget_Control, tlbID, Get_UValue = self
self->SetRealized, 0
;Obj_Destroy, self
;self->Cleanup

END ;Kang_Cleanup---------------------------------------------------------------------------


;+
; This procedure is called automatically when the program exits.  
; It removes pointers and object references so when the program exits
; the memory is cleared and there are no extra "heap" variables left.
;
; :Private:
;-
PRO Kang::Cleanup

;IF ~self.obj_output THEN RETURN

; Delete copied pointers using the copy method
;self->Select, /None
;self->Copy

; Destroying these containers destroys all the objects inside
Obj_Destroy, self.image_container
Obj_Destroy, self.regions_container
Obj_Destroy, self.histogram_container
Obj_Destroy, self.colors_container
Obj_Destroy, self.spectra

; Aditional objects
Obj_Destroy, self.old_colors
Obj_Destroy, self.fsc_psconfig
Obj_Destroy, self.fsc_psconfig_spectra

; Pointers
;Ptr_Free, self.plot_paramsID
Ptr_Free, self.velocityID
Ptr_Free, self.polygon_pts
;Ptr_Free, self.show

; Delete pixmap window
;IF !D.Name NE 'PS' THEN IF self.pix_wid NE -1 THEN WDelete, self.pix_wid
;IF !D.Name NE 'PS' THEN IF self.zoom_pix_wid NE -1 THEN WDelete, self.zoom_pix_wid

END; Kang::Cleanup------------------------------------------------------------


;--------------------------------------------------
;               Image Methods
;--------------------------------------------------
;+
; Aligns the currently displayed image to the specified image.  
; This routine does not deal with fractions of pixels,
; nor does it do well with images in different coordinate
; systems.  Really, DS9 is much better at aligning images.
;
; :Params:
;  whichimage: in, required, type=integer
;     The image index to align the currently displayed image to.
;
; :Examples:
;     To align the currently displayed image to the image stored in
;     position 1::
;         IDL> kang_obj->Align, 1
;
;-
PRO Kang::Align, whichimage
; Aligns the displayed image to the specified image

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(/Traceback)
   RETURN
ENDIF

; IMAGES MUST BE OF SAME COORDINATE SYSTEM FOR NOW
; Get coordinates from reference image
thisImage = self.image_container->Get(position = whichimage)
thisimage->GetProperty, newlimits = newlimits
self.image->Limits, newlimits

; Redraw the graphics
self->Draw

END; Kang::Align-----------------------------------------------------------------------------


;+
; Sets the properties of the axis and colorbar.
;
; :Params:
;  whichImage : in, optional, type = 'integer'
;     The image to apply changes to.
;
; :Keywords:
;  apply : in, optional, type = 'boolean', private
;    Apply changes to GUI.  Not meant for use with commandline.
;  default_titles : in, optional, type = 'boolean' 
;    Set this keyword to plot the default axis titles
;  clear_titles : in, optional, type = 'boolean'
;    Set this keyword to clear the axis titles
;  noaxis : in, optional, type = 'boolean'
;    Set this keyword to remove the axis titles
;  nobar : in, optional, type = 'boolean'
;    Set this keyword to remove the colorbar
;  title : in, optional, type = 'string'
;    Set this to a string for the title
;  xtitle : in, optional, type = 'string' 
;    Set this to a string for the x-axis
;  ytitle : in, optional, type = 'string'
;    Set this to a string for the y-axis
;  bartitle : in, optional, type = 'string'
;    Set this to a string for the colorbar title
;  subtitle : in, optional, type = 'string'
;    Set this to a string for the subtitle
;  charsize : in, optional, type = 'float'
;    The size of the axis characters
;  charthick : in, optional, type = 'float'
;    The thickness of the axis characters
;  minor : in, optional, type = 'float' 
;    The spacing of the minor tickmarks
;  ticklen : in, optional, type = 'float'
;    The length of the tickmarks
;  ticks : in, optional, type = 'float'
;    The spacing of the tick marks
;  font : in, optional, type = 'boolean'
;    The font type to use for the axes.  See IDL documentation.
;  axiscolor : in, optional, type = 'string'
;    The colr of the axis and titles
;  backcolor : in, optional, type = 'string'
;    The color of the background
;  tickcolor : in, optional, type = 'string'
;    The color of the tickmarks
;  position : in, optional, type = 'fltarr(4)'
;    Position of the plot in normalized coordinates.
;  noplot : in, optional, type = 'boolean'
;    Set this keyword to not update the plot when changes are made.
;
;-
PRO Kang::Axis, $
  whichImage, $
  apply = apply, $
  default_titles = default, $
  clear_titles = clear, $
  noaxis = noaxis, $
  nobar = nobar, $
  title = title, $
  xtitle = xtitle, $
  ytitle = ytitle, $
  bartitle = bartitle, $
  subtitle = subtitle, $
  charsize = charsize, $
  charthick = charthick, $
  minor = minor, $
  ticklen = ticklen, $
  ticks = ticks, $
  font = font, $
  axiscolor = axiscolor, $
  backcolor = backcolor, $
  tickcolor = tickcolor,$
  position = position, $
  noplot = noplot

; Default to current image
IF N_Elements(whichImage) EQ 0 THEN whichImage = self.whichImage

; Get correct image
image = self.image_container->Get(position = whichImage)

IF Keyword_Set(apply) THEN BEGIN
    IF ~self->plot_params_realized() THEN RETURN    

; Title
    self.titleID->GetProperty, Value = title
    self.bartitleID->GetProperty, Value = bartitle
    self.subtitleID->GetProperty, Value = subtitle
    self.xtitleID->GetProperty, Value = xtitle
    self.ytitleID->GetProperty, Value = ytitle
    self->Axis, title = title, xtitle = xtitle, ytitle = ytitle, bartitle = bartitle, $
                subtitle = subtitle, /Noplot

; Charsize
    IF size(self.charsizeID->Get_Value(), /tname) NE 'UNDEFINED' THEN $
      charsize = self.charsizeID->Get_Value() ELSE charsize = ''
    IF String(charsize) NE '' THEN self->Axis, charsize = charsize, /Noplot
; Charthick
    IF size(self.charthickID->Get_Value(), /tname) NE 'UNDEFINED' THEN $       
      charthick = self.charthickID->Get_Value() ELSE charthick = ''
    IF String(charthick) NE '' THEN self->Axis, charthick = charthick, /Noplot
; Minor
    IF size(self.minorID->Get_Value(), /tname) NE 'UNDEFINED' THEN $
      minor = self.minorID->Get_Value() ELSE minor = ''
    IF String(minor) NE '' THEN self->Axis, minor = minor, /Noplot
; Ticklen
    IF size(self.ticklenID->Get_Value(), /tname) NE 'UNDEFINED' THEN $
      ticklen = self.ticklenID->Get_Value() ELSE ticklen = ''
    IF String(ticklen) NE '' THEN self->Axis, ticklen = ticklen, /Noplot
; Ticks
    IF size(self.ticksID->Get_Value(), /tname) NE 'UNDEFINED' THEN $
      ticks = self.ticksID->Get_Value() ELSE ticks = ''
    IF String(ticks) NE '' THEN self->Axis, ticks = ticks, /Noplot
;Font
    font = self.fontID->GetIndex()
    self->Axis, font = font-1, /Noplot
ENDIF

IF Keyword_Set(default) THEN BEGIN
; Find the default titles
    image->Default_Titles
    image->GetProperty, title = title, xtitle = xtitle, ytitle = ytitle, bartitle = bartitle, $
                        subtitle = subtitle

; Update widget
    IF self->plot_params_realized() THEN BEGIN
        self.titleID->Set_Value, title
        self.bartitleID->Set_Value, bartitle
        self.subtitleID->Set_Value, subtitle
        self.xtitleID->Set_Value, xtitle
        self.ytitleID->Set_Value, ytitle
    ENDIF
ENDIF

IF Keyword_Set(clear) THEN BEGIN
; Clear all values
    image->SetProperty, title = '', bartitle = '', subtitle = '', xtitle = '', ytitle = ''
    image->GetProperty, title = title, xtitle = xtitle, ytitle = ytitle, bartitle = bartitle, $
                        subtitle = subtitle

; Update widget
    IF self->plot_params_realized() THEN BEGIN
        self.titleID->Set_Value, title
        self.bartitleID->Set_Value, bartitle
        self.subtitleID->Set_Value, subtitle
        self.xtitleID->Set_Value, xtitle
        self.ytitleID->Set_Value, ytitle
    ENDIF
ENDIF

IF N_Elements(noaxis) NE 0 THEN image->SetProperty, noaxis = noaxis
IF N_Elements(nobar) NE 0 THEN image->SetProperty, nobar = nobar
IF N_Elements(title) NE 0 THEN image->SetProperty, title = title
IF N_Elements(xtitle) NE 0 THEN image->SetProperty, xtitle = xtitle
IF N_Elements(ytitle) NE 0 THEN image->SetProperty, ytitle = ytitle
IF N_Elements(bartitle) NE 0 THEN image->SetProperty, bartitle = bartitle
IF N_Elements(subtitle) NE 0 THEN image->SetProperty, subtitle = subtitle
IF N_Elements(charsize) NE 0 THEN image->SetProperty, charsize = charsize
IF N_Elements(charthick) NE 0 THEN image->SetProperty, charthick = charthick
IF N_Elements(minor) NE 0 THEN image->SetProperty, minor = minor
IF N_Elements(ticklen) NE 0 THEN image->SetProperty, ticklen = ticklen
IF N_Elements(ticks) NE 0 THEN image->SetProperty, ticks = ticks
IF N_Elements(font) NE 0 THEN image->SetProperty, font = font-1
IF N_Elements(axiscolor) NE 0 THEN image->SetProperty, axiscname = axiscolor, $
  axiscolor = self.colors->ColorIndex(axiscolor)
IF N_Elements(backcolor) NE 0 THEN image->SetProperty, backcname = backcolor, $
  backcolor = self.colors->ColorIndex(backcolor)
IF N_Elements(tickcolor) NE 0 THEN image->SetProperty, tickcname = tickcolor, $
  tickcolor = self.colors->ColorIndex(tickcolor)
IF N_Elements(position) NE 0 THEN image->SetProperty, position = position

; Replot
IF ~Keyword_Set(noplot) THEN self->Draw

END; Kang::Axis------------------------------------------------------


;+
; Changes which image is displayed
;
; :Params:
;  newimage : in, required, type = 'integer'
;    The image index to change to.
;
; :Keywords:
;  next : in, optional, type = 'boolean'
;    Change to next image.
;  noplot : in, optional, type = 'boolean'
;    If set, graphics will not be redrawn after changing the image.
;  previous : in, optional, type = 'boolean'
;    Change to previous image.
;
;-
PRO Kang::Change_Image, newimage, next = next, previous = previous, noplot = noplot
; Sets all the variables and updates the display when images are
; changed

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Return if there are no images to change to
IF self.image_container->Count() EQ 0 THEN RETURN
IF N_Elements(newimage) EQ 0 THEN newimage = self.whichImage

; Do nothing if changed-to image is the same as current image
n_images = self.image_container->count()
IF newimage GE n_images THEN RETURN

; Determine image to change to
IF Keyword_Set(next) THEN newimage = self.whichImage + 1
IF Keyword_Set(previous) THEN newimage = self.whichImage - 1

; If next or previous goes over the range of images, cycle back around
IF newimage LT 0 THEN newimage = n_images-1
IF newimage GT n_images-1 THEN newimage = 0

; Change the objects over
self.image = self.image_container->Get(position = newimage)
self.regions = self.regions_container->Get(position = newimage)
self.colors = self.colors_container->Get(position = newimage)
self.histogram = self.histogram_container->Get(position = newimage)

; Load new colors
self.colors->TVLCT

; Turn off interactive plots
self->Interactive_Plots, /None

; Change image flag
self.whichImage = newimage

; Reset contrast sliders
; The range of contrast is 0 to 4.666666
; The range of brightness is 0 to 2.5
IF self.realized THEN BEGIN
    self.colors->GetProperty, contrast=contrast, brightness=brightness
    Widget_Control, self.contrastID, Set_Value= contrast* 100.
    Widget_Control, self.brightnessID, Set_Value= brightness * 100.

; Set file dialog button
    IF XRegistered('File Dialog '+StrTrim(self.tlbID, 2)) THEN BEGIN
        Widget_Control, self.plotID, Set_Value = newimage
    ENDIF

; Set Scaling checkmark back
    Widget_Control, self.linearID, Set_Button=0
    Widget_Control, self.logID, Set_Button=0
;    Widget_Control, self.histeqID, Set_Button=0
    Widget_Control, self.asinhID, Set_Button=0
;    Widget_Control, self.gaussianID, Set_Button=0
;    Widget_Control, self.powerID, Set_Button=0
    Widget_Control, self.squarerootID, Set_Button=0
    Widget_Control, self.squaredID, Set_Button=0

; Turn checkmark on for the right button
    self.colors->GetProperty, scaling = scaling
    CASE StrUpCase(scaling[0]) OF
        'GAUSSIAN':Widget_Control, self.gaussianID, Set_Button=1
        'POWER':Widget_Control, self.powerID, Set_Button=1
        'LINEAR':Widget_Control, self.linearID, Set_Button=1
        'LOG':Widget_Control, self.logID, Set_Button=1
        'ASINH':Widget_Control, self.asinhID, Set_Button=1
        'HISTEQ':Widget_Control, self.histeqID, Set_Button=1
        'SQUARED':Widget_Control, self.squaredID, Set_Button=1
        'SQUARE ROOT':Widget_Control, self.squarerootID, Set_Button=1
        ELSE: print, scaling[0]
    ENDCASE

; Set coordinate checkmarks
    Widget_Control, self.J2000ID, Set_Button=0
    Widget_Control, self.B1950ID, Set_Button=0
    Widget_Control, self.galacticID, Set_Button=0
    Widget_Control, self.eclipticID, Set_Button=0
    Widget_Control, self.sexadecimalID, Set_Button=0
    Widget_Control, self.degreeID, Set_Button=0

; Turn checkmark on for the right button
    self.image->GetProperty, current_coords = current_coords, sexadecimal = sexadecimal
    IF current_coords EQ 'Image' THEN Widget_Control, self.coordinatesID, Sensitive=0 ELSE BEGIN
        Widget_Control, self.coordinatesID, Sensitive=1
        CASE current_coords OF
            'J2000': Widget_Control, self.J2000ID, Set_Button=1
            'B1950': Widget_Control, self.B1950ID, Set_Button=1
            'Galactic': Widget_Control, self.galacticID, Set_Button=1
            'Ecliptic': Widget_Control, self.eclipticID, Set_Button=1
        ENDCASE
        IF sexadecimal THEN Widget_Control, self.sexadecimalID, Set_Button=1 ELSE Widget_Control, self.degreeID, Set_Button=1
    ENDELSE

; Set checkmarks
    Widget_Control, self.xplotID, Set_Button = 0
    Widget_Control, self.yplotID, Set_Button = 0
    Widget_Control, self.zplotID, Set_Button = 0
    Widget_Control, self.noneID, Set_Button = 1

; Set sensitivity
    self.image->GetProperty, type = type
    IF type EQ 'Cube' OR type EQ 'Cube Array' THEN BEGIN
        Widget_Control, self.zplotID, Sensitive = 1
;        Widget_Control, self.threeDID, Sensitive = 1
        Widget_Control, self.velocity_widgetID, Sensitive = 1
    ENDIF ELSE BEGIN
        Widget_Control, self.zplotID, Sensitive = 0
;        Widget_Control, self.threeDID, Sensitive = 0
    ENDELSE

; Replot the graphics
    IF ~Keyword_Set(noplot) THEN self->Draw

; Update plot_params dialog
    IF ~self->plot_params_realized() THEN RETURN

    self.histogram->GetProperty, lowScale=lowScale, highScale=highScale, log = log, autoupdate = autoupdate
    self.lowScaleID->Set_Value, lowscale
    self.highScaleID->Set_Value, highscale

; Update UValue of histogram object
    Widget_Control, self.histogram_drawID, Set_UValue = self.histogram

;    self.percentSliderID = CW_FSlider(bigpercentbase, xsize = 200, minimum = 100, maximum = 90, $
;                                  /Drag, /Edit, format = '(F7.3)')
    IF log THEN value = ' Linear Axis ' ELSE value = '  Log Axis  '
;    self.histlogID->Set
;    self.autoUpdateID, Set
    self.histogram->Draw
    self.image->GetProperty, newlimits = newlimits, pix_newlimits = pix_newlimits
    self.xminID->Set_Value, String(newlimits[0])
    self.xmaxID->Set_Value, String(newlimits[1])
    self.yminID->Set_Value, String(newlimits[2])
    self.ymaxID->Set_Value, String(newlimits[3])
    self.pix_xminID->Set_Value, String(pix_newlimits[0])
    self.pix_xmaxID->Set_Value, String(pix_newlimits[1])
    self.pix_yminID->Set_Value, String(pix_newlimits[2])
    self.pix_ymaxID->Set_Value, String(pix_newlimits[3])

; Titles
    self.titleID->Set_Value, self.image->GetProperty(/title)
    self.xtitleID->Set_Value, self.image->GetProperty(/xtitle)
    self.ytitleID->Set_Value, self.image->GetProperty(/ytitle)
    self.bartitleID->Set_Value, self.image->GetProperty(/bartitle)
    self.subtitleID->Set_Value, self.image->GetProperty(/subtitle)

; Colors
;    self.axisColorID = image->GetProperty(/axiscname)
;    self.backColorID = image->GetProperty(/backcname)
;    self.tickColorID = image->GetProperty(/tickcname)

; Characters
    self.charsizeID->Set_Value, self.image->GetProperty(/charsize)
    self.charthickID->Set_Value, self.image->GetProperty(/charthick)
;    self.fontID=FSC_DropList(charBase, Title='   Font: ', Index = self.image->GetProperty(/font)+1, $
;                         Value=['Hershey', 'Hardware', 'True-Type'], UValue=[-1,0,1])

; Ticks
    self.minorID->Set_Value, self.image->GetProperty(/minor)
    self.ticksID->Set_Value, self.image->GetProperty(/ticks)
    self.ticklenID->Set_Value, self.image->GetProperty(/ticklen)

; Toggles buttons
    Widget_Control, self.noaxisID, Set_Button = self.image->GetProperty(/noaxis)
    Widget_Control, self.nobarID, Set_Button = self.image->GetProperty(/nobar)

; Get all the properties needed for the widget
    self.image->GetProperty, All = c_par
    Widget_Control, self.percentbuttonsID, Set_Value = ~c_par.percent

; NLevels
;    self.nlevelsID=FSC_DropList(nlevels_topbase, Title='Levels: ', Index = c_par.nlevels-1, Value=indgen(14)+1, UValue = 'NLevels')
    self.max_value->Set_Value, c_par.max_value
    self.min_value->Set_Value, c_par.min_value
    self.nlevels_levels->Set_Value, c_par.s_nlevels

; Levels
    self.levels->Set_Value,  c_par.s_levels

; Other properties
    self.c_colors->Set_Value, c_par.s_colors
    self.c_linestyle->Set_Value, c_par.s_linestyle
    self.c_thick->Set_Value, c_par.s_thick
;    self.downhillID=CW_BGroup(lineBase, Set_Value=c_par.downhill, 'Downhill', UValue = 'Downhill', /NonExclusive)

    self.c_annotation->Set_Value, c_par.s_annotation
    self.c_labels->Set_Value, c_par.s_labels
    self.c_charsize->Set_Value, c_par.s_charsize
    self.c_charthick->Set_Value, c_par.s_charthick

; Regions
    self->Update_Regions_info, /List_Update
ENDIF

END; Kang::Change_Image------------------------------------------


;+
; Handles various functions of the display colors for the program.
;
; :Keywords:
;  colortable : in, optional, type = 'integer'
;    The colortable index to switch to.  These go from 0-40 and can
;    be found in the IDL documentation.
;  invert : in, optional, type = 'boolean'
;    Set to invert the current color table.
;  reverse : in, optional, type = 'boolean'
;    Set to reverse the current color table.
;
;-
PRO Kang::Color, $
  colorTable = colorTable, $
  invert = invert, $
  reverse = reverse
  
; Changes the image colors of the graphic display.
Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
   RETURN
ENDIF

IF N_Elements(colorTable) NE 0 THEN self.colors->LoadCT, colortable
IF Keyword_Set(invert) THEN self.colors->Invert
IF Keyword_Set(reverse) THEN self.colors->Reverse

; Redraw
self.colors->TVLCT
self->Draw

END ;Kang::Color----------------------------------------------------------------


;+
; Adds or removes contours, changes the properties of contours.
;
; :Params:
;  whichImage : in, optional, type = 'integer'
;    The image to apply the keywords to.  Defaults to current image.
;
; :Keywords:
;  on : in, optional, type = 'boolean'
;    Turn contours on for the image
;  off : in, optional, type = 'boolean'
;    Turn contours off for the image
;  toggle : in, optional, type = 'boolean'
;    Toggle the contours on and off for the image
;  c_Annotation : in, optional, type = 'string array'
;    Annotation for each contour level
;  c_Charsize : in, optional, type = 'float array'
;    Character size for the contour annotations
;  c_Charthick : in, optional, type = 'float array'
;    Character thickness for the contour annotations
;  c_Colors : in, optional, type = 'string array'
;    Colors for each contour level 
;  c_Labels : in, optional, type = 'integer array'
;    Binary for each level for which ones are to be labeled
;  c_Linestyle : in, optional, type = 'integer array'
;    Linestyle for each contour level
;  c_Thick : in, optional, type = 'float array'
;    Thickness for each contour level
;  downhill : in, optional, type = 'boolean'
;    Binary for whether to draw downhill tickmarks
;  levels : in, optional, type = 'float array array'
;    Contour levels
;  nLevels : in, optional, type = 'integer'
;    Number of levels. Scaled from min_value to max_value
;  max_Value : in, optional, type = 'float'
;    Maximum scaled value for nlevels.  Defaults to scaled max.
;  min_Value : in, optional, type = 'float'
;    Minimum scaled value for nlevels.  Defaults to scaled min.
;  percent : in, optional, type = 'boolean'
;    Set to 1 if leves are to be drawn evenly from min_value to max_value, 
;    0 if they are to be drawn from the values in levels.
;  noplot : in, optional, type = 'boolean'
;    Set this keyword to not update the plot when changes are made.
;
;-
PRO Kang::Contour, $
  whichimage, $
  Apply = apply, $
  On = on, $                    ; Contours on
  Off = off, $                  ; Contours off
  Toggle = toggle, $            ; Changes whether the contour is on or off
  NoPlot = noplot, $            ; Don't redisplay the graphic
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

; Default to current image
IF N_Elements(whichImage) EQ 0 THEN whichImage = self.whichImage

; Sets the contours flags
IF Keyword_Set(on) THEN self.whichContours[whichImage] = 1B
IF Keyword_Set(off) THEN self.whichContours[whichImage] = 0B
IF Keyword_Set(toggle) THEN self.whichContours[whichImage] = ~self.whichContours[whichImage]

; Get correct image
image = self.image_container->Get(position = whichImage)

IF Keyword_Set(apply) THEN BEGIN
; Levels
    image->GetProperty, percent=percent
    IF ~percent THEN BEGIN
        s_levels=self.levels->Get_Value()
        levels = Float(kang_spaceorcomma(s_levels)) ; Make the levels into an array and store
        sortLev = uniq(levels, sort(levels))
        n_lev = N_Elements(sortlev)
        image->SetProperty, levels = levels[sortLev], s_levels = s_levels
    ENDIF ELSE BEGIN
            
; Max value
        IF size(self.max_value->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
            max_value=self.max_value->Get_Value() 
            image->SetProperty, max_value = max_value
        ENDIF ELSE BEGIN
            image->GetProperty, max_value = max_value
            self.max_value->Set_Value, max_value
        ENDELSE

; Min value
        IF size(self.min_value->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
            min_value=self.min_value->Get_Value() 
            image->SetProperty, min_value = min_value
        ENDIF ELSE BEGIN
            image->GetProperty, min_value = min_value
            self.min_value->Set_Value, min_value
        ENDELSE

; Set sortlev variable
        image->GetProperty, nlevels = nlevels
        sortlev = indgen(nlevels)
        n_lev = nlevels
    ENDELSE

; Colors
    IF size(self.c_colors->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
        s_colors=self.c_colors->Get_Value()
        self->Contour, c_colors = kang_spaceorcomma(s_colors), s_colors = s_colors, /NoPlot
    ENDIF

; Linestyle
    IF size(self.c_linestyle->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
        s_linestyle=self.c_linestyle->Get_Value()
        self->Contour, c_linestyle = kang_spaceorcomma(s_linestyle), s_linestyle = s_linestyle, /NoPlot
    ENDIF

; Thick
    IF size(self.c_thick->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
        s_thick=self.c_thick->Get_Value()
        self->Contour, c_thick = kang_spaceorcomma(s_thick), s_thick = s_thick, /NoPlot
    ENDIF
  
; Charsize
    IF size(self.c_charsize->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
        s_charsize=self.c_charsize->Get_Value()
        self->Contour, c_charsize = kang_spaceorcomma(s_charsize), s_charsize = s_charsize, /NoPlot
    ENDIF

; Charthick
    IF size(self.c_charthick->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
        s_charthick=self.c_charthick->Get_Value()
        self->Contour, c_charthick = kang_spaceorcomma(s_charthick), s_charthick = s_charthick, /NoPlot
    ENDIF

; Annotation
    IF size(self.c_annotation->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
        s_annotation=self.c_annotation->Get_Value()
        self->Contour, c_annotation = kang_spaceorcomma(s_annotation), s_annotation = s_annotation, /NoPlot
    ENDIF

; Label
    IF size(self.c_labels->Get_Value(), /tname) NE 'UNDEFINED' THEN BEGIN
        s_label=self.c_labels->Get_Value()
        self->Contour, c_label = kang_spaceorcomma(s_label), s_label = s_label, /NoPlot
    ENDIF
;        image->SetProperty, c_labels = c_labels[sortlev[0:(n_labels-1)  < (n_lev-1)]], s_labels = s_labels
ENDIF

; ------------Contours properties------------------
IF N_Elements(levels) NE 0 THEN BEGIN
; Sort the levels.  All other parameters will follow this sorting
    IF size(levels, /tname) EQ 'STRING' THEN BEGIN
        s_levels = levels
        levels = Float(kang_spaceorcomma(s_levels)) ; Make the levels into an array and store
    ENDIF ELSE s_levels = StrCompress(StrJoin(levels, ', '))
    sortLev = uniq(levels, sort(levels))
    n_lev = N_Elements(sortlev)
    image->SetProperty, levels = levels[sortLev], s_levels = s_levels, percent = 0

; Update widget
    IF self->plot_params_realized() THEN self.levels->Set_Value, s_levels
ENDIF ELSE BEGIN
; Get the sortlev array
    image->GetProperty, levels = levels
    sortlev = uniq(levels, sort(levels))
ENDELSE

IF N_Elements(c_annotation) NE 0 THEN BEGIN
    IF N_Elements(sortlev) NE 0 THEN image->SetProperty, c_annotation = c_annotation[sortlev] ELSE $
      image->SetProperty, c_annotation = c_annotation ; Set value
    IF N_Elements(s_annotation) EQ 0 THEN s_annotation = StrJoin(c_annotation, ', ') ; Find string
    image->SetProperty, s_annotation = StrJoin(c_annotation, ', ') ; Set string property
    IF self->plot_params_realized() THEN self.c_annotation->Set_Value, s_annotation ; Update widget
ENDIF

IF N_Elements(c_charsize) NE 0 THEN BEGIN
    IF N_Elements(sortlev) NE 0 THEN image->SetProperty, c_charsize = c_charsize[sortlev] ELSE $
      image->SetProperty, c_charsize = c_charsize
    IF N_Elements(s_charsize) EQ 0 THEN s_charsize = StrJoin(c_charsize, ', ')
    image->SetProperty, s_charsize = StrJoin(c_charsize, ', ')
    IF self->plot_params_realized() THEN self.c_charsize->Set_Value, s_charsize
ENDIF

IF N_Elements(c_colors) NE 0 THEN BEGIN
; Get colors object
    colorsObj = self.colors_container->Get(position = whichImage)

; Find indices of color words
    n_colors = N_Elements(c_colors)
    c_colors_indices = bytArr(n_colors)
    FOR i = 0, N_Colors-1 DO c_colors_indices[i] = colorsObj->ColorIndex(c_colors[i])

; Set Properties
    IF N_Elements(sortlev) NE 0 THEN image->SetProperty, c_colors = c_colors_indices[sortlev] ELSE $
      image->SetProperty, c_colors = c_colors_indices
    IF N_Elements(s_colors) EQ 0 THEN s_colors = StrJoin(c_colors, ', ')
    image->SetProperty, s_colors = StrJoin(c_colors, ', ')
    IF self->plot_params_realized() THEN self.c_colors->Set_Value, s_colors
ENDIF

IF N_Elements(c_labels) NE 0 THEN BEGIN
    IF N_Elements(sortlev) NE 0 THEN image->SetProperty, c_labels = c_labels[sortlev] ELSE $
      image->SetProperty, c_labels = c_labels
    IF N_Elements(s_labels) EQ 0 THEN s_labels = StrJoin(c_labels, ', ')
    image->SetProperty, s_labels = StrJoin(c_labels, ', ')
    IF self->plot_params_realized() THEN self.c_labels->Set_Value, s_labels
ENDIF

IF N_Elements(c_linestyle) NE 0 THEN BEGIN
    IF N_Elements(sortlev) NE 0 THEN image->SetProperty, c_linestyle = c_linestyle[sortlev] ELSE $
      image->SetProperty, c_linestyle = c_linestyle
    IF N_Elements(s_linestyle) EQ 0 THEN s_linestyle = StrJoin(c_linestyle, ', ')
    image->SetProperty, s_linestyle = StrJoin(c_linestyle, ', ')
    IF self->plot_params_realized() THEN self.c_linestyle->Set_Value, s_linestyle
ENDIF

IF N_Elements(c_thick) NE 0 THEN BEGIN
    IF N_Elements(sortlev) NE 0 THEN image->SetProperty, c_thick = c_thick[sortlev] ELSE $
      image->SetProperty, c_thick = c_thick
    IF N_Elements(s_thick) EQ 0 THEN s_thick = StrJoin(c_thick, ', ')
    image->SetProperty, s_thick = StrJoin(c_thick, ', ')
    IF self->plot_params_realized() THEN self.c_thick->Set_Value, s_thick
ENDIF

IF N_Elements(nlevels) NE 0 THEN BEGIN
    image->SetProperty, nlevels = nlevels
    image->GetProperty, s_nlevels = s_nlevels
    self.nlevels_levels->SetProperty, Value = s_nlevels
ENDIF
IF N_Elements(max_value) NE 0 THEN image->SetProperty, max_value = max_value
IF N_Elements(min_value) NE 0 THEN image->SetProperty, min_value = min_value

IF N_Elements(downhill) NE 0 THEN image->SetProperty, downhill = downhill
IF N_Elements(percent) NE 0 THEN image->SetProperty, percent = percent

; Replot
IF ~Keyword_Set(noplot) THEN self->Draw

END; Kang::Contour--------------------------------------------------


;+
; Change the display coordinates.
; This still isn't working as well as it should.  In future releases,
; I think this routine will also rotate the image so the desired
; coordinates run straight up and down and side to side.
;
; :Params:
;  coordType : in, optional, type = 'string'
;    The new coordinate type to change to.  Possible values
;    are 'Galactic', 'J2000', 'B1950', 'Ecliptic', 'Image'
;
; :Keywords:
;  degrees : in, optional, type = 'boolean'
;    Set this keyword to plot the axis values in degrees
;  sexadecimal : in, optional, type = 'boolean'
;    Set this keyword to plot the axis values in sexadecimal format
;
;-
PRO Kang::Coordinates, coordType, Degrees = degrees, Sexadecimal = sexadecimal

;These are changes from degrees to sexadecimal
IF Keyword_Set(degrees) THEN BEGIN
    self.image->SetProperty, Sexadecimal = 0
    Widget_Control, self.degreeID, Set_Button = 1
    Widget_Control, self.sexadecimalID, Set_Button = 0
ENDIF

; Change from sexadecimal to degrees
IF Keyword_Set(sexadecimal) THEN BEGIN
    self.image->SetProperty, Sexadecimal = 1
    Widget_Control, self.degreeID, Set_Button = 0
    Widget_Control, self.sexadecimalID, Set_Button = 1
ENDIF

; Set the buttons
IF self.realized THEN BEGIN
    Widget_Control, self.galacticID, Set_Button = 0
    Widget_Control, self.eclipticID, Set_Button = 0
    Widget_Control, self.B1950ID, Set_Button = 0
    Widget_Control, self.J2000ID, Set_Button = 0
;Widget_Control, self.horizonID, Set_Button = 0
ENDIF

IF N_Elements(coordType) NE 0 THEN BEGIN
    CASE StrUpCase(coordType) OF
        'EQUATORIAL J2000': BEGIN
            self.image->SetProperty, current_coords = 'J2000'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = ' RA'
                Widget_Control, self.latlabelID, Set_Value = 'Dec'
                Widget_Control, self.J2000ID, Set_Button = 1
            ENDIF
        END
        'EQ': BEGIN
            self.image->SetProperty, current_coords = 'J2000'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = ' RA'
                Widget_Control, self.latlabelID, Set_Value = 'Dec'
                Widget_Control, self.J2000ID, Set_Button = 1
            ENDIF
        END
        'J2000': BEGIN
            self.image->SetProperty, current_coords = 'J2000'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = ' RA'
                Widget_Control, self.latlabelID, Set_Value = 'Dec'
                Widget_Control, self.J2000ID, Set_Button = 1
            ENDIF
        END
        'FK5': BEGIN
            self.image->SetProperty, current_coords = 'J2000'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = ' RA'
                Widget_Control, self.latlabelID, Set_Value = 'Dec'
                Widget_Control, self.J2000ID, Set_Button = 1
            ENDIF
        END
        'EQUATORIAL B1950': BEGIN
            self.image->SetProperty, current_coords = 'B1950'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = ' RA'
                Widget_Control, self.latlabelID, Set_Value = 'Dec'
                Widget_Control, self.B1950ID, Set_Button = 1
            ENDIF
        END
        'B1950': BEGIN
            self.image->SetProperty, current_coords = 'B1950'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = ' RA'
                Widget_Control, self.latlabelID, Set_Value = 'Dec'
                Widget_Control, self.B1950ID, Set_Button = 1
            ENDIF
        END
        'FK4': BEGIN
            self.image->SetProperty, current_coords = 'B1950'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = ' RA'
                Widget_Control, self.latlabelID, Set_Value = 'Dec'
                Widget_Control, self.B1950ID, Set_Button = 1
            ENDIF
        END
        'GALACTIC': BEGIN
            self.image->SetProperty, current_coords = 'Galactic'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = '  l'
                Widget_Control, self.latlabelID, Set_Value = '  b'
                Widget_Control, self.galacticID, Set_Button = 1
            ENDIF
        END
        'GA': BEGIN
            self.image->SetProperty, current_coords = 'Galactic'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = '  l'
                Widget_Control, self.latlabelID, Set_Value = '  b'
                Widget_Control, self.galacticID, Set_Button = 1
            ENDIF
        END
        'ECLIPTIC': BEGIN
            self.image->SetProperty, current_coords = 'Ecliptic'
            IF self.realized THEN BEGIN
                Widget_Control, self.longlabelID, Set_Value = 'lam'
                Widget_Control, self.latlabelID, Set_Value = 'bet'
                Widget_Control, self.eclipticID, Set_Button = 1
            ENDIF
        END
;    'HORIZON': BEGIN
;        self.image->SetProperty, current_coords = 'HORI'
;        IF self.realized THEN BEGIN
;        Widget_Control, self.longlabelID, Set_Value = 'alt'
;        Widget_Control, self.latlabelID, Set_Value = 'az'
;        Widget_Control, self.horizonID, Set_Button = 1
;       ENDIF
;    END
        '':
        ELSE: print, 'ERROR: Coordinate Type not recognized.'
    ENDCASE
ENDIF

; Find limits
self.image->Find_Newlimits

; Replot
self->Draw

END; Kang::Coordinates-----------------------------------------------------


;+
; Removes an image from program memory.
;
; :Params:
;  whichDelete : in, optional, type = 'integer'
;    The index of the image to delete.
;
; :Keywords:
;  all : in, optional, type = 'integer'
;    Set this keyword to delete all the images
;
;-
PRO Kang::Delete, whichDelete, All = all
; Deletes an image
Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Delete all the images
IF Keyword_Set(all) THEN BEGIN
    n_delete = self.image_container->Count()
    IF n_delete EQ 0 THEN RETURN
    whichDelete = lindgen(n_delete)

; Deal with show/hide array
;    Ptr_Free, self.show
;    self.show = Ptr_New()
ENDIF

n_delete = N_Elements(whichDelete)
IF n_delete EQ 0 THEN BEGIN
    print, 'ERROR: Must pass argument for which image to delete.'
    RETURN
ENDIF

; Determine if we can delete it
FOR i = n_delete-1, 0, -1 DO BEGIN
    n_images = self.image_container->Count()
    IF n_images LE whichDelete[i] THEN RETURN

; Set the button back to normal position
    IF XRegistered('File Dialog '+StrTrim(self.tlbID, 2)) THEN $
      Widget_Control, self.deleteID, Set_Value= IntArr(self.n_images)

; Delete and remove objects
    image = self.image_container->Get(position = whichDelete[i])
    colors = self.colors_container->Get(position = whichDelete[i])
    regions = self.regions_container->Get(position = whichDelete[i])
    histogram = self.histogram_container->Get(position = whichDelete[i])
    
    Obj_Destroy, image
    Obj_Destroy, colors
    Obj_Destroy, regions
    Obj_Destroy, histogram
    
    self.image_container->Remove, position = whichDelete[i]
    self.colors_container->Remove, position = whichDelete[i]
    self.regions_container->Remove, position = whichDelete[i]
    self.histogram_container->Remove, position = whichDelete[i]

; Adjust show/hide array
;    IF n_images EQ 1 THEN Ptr_Free, self.show ELSE BEGIN
;        arr = lindgen(n_images)
;        keep = where(arr NE whichDelete[i])
;        *self.show = (*self.show)[keep]
;    ENDELSE

; Determine the good indices
    wh = where(findgen(self.n_images) NE whichDelete[i])

; Change contour flags around
    self.whichContours = [self.whichContours[wh], 0] ; The zero keeps the array the same dimensions

; Delete velocity widgets
    IF XRegistered('Kang_Velocity_Widget '+StrTrim(whichDelete[i], 2)+' '+StrTrim(self.tlbID,2)) NE 0 THEN $
      Widget_Control, (*self.velocityID)[whichDelete[i]], /Destroy
    *self.velocityID = [(*self.velocityID)[wh], 0]

; Adjust widget names

; Change object references if selected image was deleted
    position = 0 > (whichDelete[i]-1)
    IF self.whichImage EQ whichDelete[i] THEN BEGIN
        IF n_images-1 GT 0 THEN BEGIN
            self.image = self.image_container->Get(position = position)
            self.colors = self.colors_container->Get(position = position)
            self.regions = self.regions_container->Get(position = position)
            self.histogram = self.histogram_container->Get(position = position)
        ENDIF ELSE BEGIN
; Change sensitivity on main widget if there aren't any images
            Obj_Destroy, self.image
            IF self.realized THEN BEGIN
                Widget_Control, self.drawID, Draw_Button_Events=0, Draw_Motion_Events=0, $
                                Draw_Keyboard_Events = 0
                Widget_Control, self.editID, Sensitive=0
                Widget_Control, self.colorsID, Sensitive=0
                Widget_Control, self.scalingID, Sensitive=0
                Widget_Control, self.zoomID, Sensitive=0
                Widget_Control, self.regionsID, Sensitive=0
                Widget_Control, self.coordinatesID, Sensitive=0
                Widget_Control, self.analysisID, Sensitive=0
            ENDIF
        ENDELSE
    ENDIF

; Update widgets
    self->Change_Image, position
    self->Update_File_Dialog
ENDFOR

END; Kang::Delete--------------------------------------------------


;+
; Returns the requested property of the kang object.
;
; :Keywords:
;  autoupdate
;  header
;  brightness
;  contrast
;  filenames
;  selected
;  n_regions
;  limits
;  pix_limits
;  region_xrange
;  region_yrange
;  regiontext
;  position
;  scaling
;  lowscale
;  highscale
;
;-
PRO Kang::GetProperty, $
  autoupdate = autoupdate, $
  header = header, $
  brightness = brightness, $
  contrast = contrast, $
  filenames = filenames, $
  fitParams = fitParams, $
  selected = selected, $
  n_regions = n_regions, $
  limits = limits, $
  pix_limits = pix_limits, $
  region_xrange = region_xrange, $
  region_yrange = region_yrange, $
  regiontext = regiontext, $
  position = position, $
  scaling = scaling, $
  lowscale = lowscale, $
  highscale = highscale

IF Arg_Present(autoupdate) THEN self.histogram->GetProperty, autoupdate = autoupdate
IF Arg_Present(brightness) THEN self.colors->GetProperty, brightness = brightness
IF Arg_Present(contrast) THEN self.colors->GetProperty, contrast = contrast
IF Arg_Present(header) THEN self.image->GetProperty, header = header
IF Arg_Present(selected) THEN self.regions->GetProperty, selected_regions = selected
IF Arg_Present(n_regions) THEN self.regions->GetProperty, n_regions = n_regions
IF Arg_Present(fitParams) THEN self.image->GetProperty, fitParams = fitParams
IF Arg_Present(filenames) THEN BEGIN
    count = self.image_container->Count()
    IF count GT 0 THEN BEGIN
        filenames = strArr(count)
        FOR i = 0, count-1 DO BEGIN
            image = self.image_container->Get(position = i)
            filenames[i] = image->GetProperty(/filename)
        ENDFOR
    ENDIF ELSE filenames = ''
ENDIF
IF Arg_Present(limits) THEN self.image->GetProperty, newlimits = limits
IF Arg_Present(pix_limits) THEN self.image->GetProperty, pix_newlimits = pix_limits
IF Arg_Present(region_xrange) THEN self.regions->GetProperty, xrange = region_xrange
IF Arg_Present(region_yrange) THEN self.regions->GetProperty, yrange = region_yrange
IF Arg_Present(region_xrange) AND Arg_Present(region_yrange) THEN BEGIN
; Convert to data coordinates
; Only take the min and max
    region_xrange = [min(region_xrange), max(region_xrange)]
    region_yrange = [min(region_yrange), max(region_yrange)]

; Convert ranges
    ranges = self.image->Convert_Coord(region_xrange, region_yrange, old_coords = 'Image')
    region_xrange = [min(ranges[0, *]), max(ranges[0, *])]
    region_yrange = [min(ranges[1, *]), max(ranges[1, *])]
ENDIF
IF Arg_Present(regiontext) THEN self.regions->GetProperty, regiontext = regiontext
IF Arg_Present(lowscale) THEN self.histogram->GetProperty, lowscale = lowscale
IF Arg_Present(highscale) THEN self.histogram->GetProperty, highscale = highscale
IF Arg_Present(position) THEN self.image->GetProperty, position = position
IF Arg_Present(scaling) THEN self.colors->GetProperty, scaling = scaling

END; Kang::GetProperty-----------------------------------------------


;+
; Hides an image so it is not visible.
;
; :Private:
;
; :Params:
;  whichImage : in, required, type='integer array' 
;    The image to hide
;
; :Keywords:
;  all : in, optional, type='boolean'
;    Set to hide all images
;
;
;-
PRO Kang::Hide, whichImage, all = all

; Error checking
n_images = self.image_container->count()
IF n_images EQ 0 THEN RETURN
whichImage = 0 > whichImage < n_images

; Change array to 1s
(*self.show)[whichImage] = 0B

END; Kang::Hide------------------------------------------------------------


;+
; Change the limits of the displayed image
;
; :Params:
;  xmin : in, required, type = 'float'
;    Minimum x-axis value in currently displayed units.
;  xmax : in, required, type = 'float'
;    Maximum x-axis value
;  ymin :  in, required, type = 'float'
;    Minimum y-axis value
;  ymax :  in, required, type = 'float'
;    Maximum y-axis value
;
; :Keywords:
;  pixel :  in, optional, type = 'boolean'
;    Set this keyword to interpret the limits as pixel values
;
; :Examples:
;   To zoom in to image[50:90, 150:250]::
;       IDL> kang_obj->Limits, 50, 90, 150, 250, /pixel
;
;   To zoom to l = 45.5, 47.7, b = -1, 1.4::
;       IDL> kang_obj->Limits, 45.5 57.7, -1, 1.4
;
;-
PRO Kang::Limits, xmin, xmax, ymin, ymax, pixel = pixel

IF N_Elements(xmin) EQ 4 THEN limits = xmin ELSE limits = [xmin, xmax, ymin, ymax]

; Change limits
IF ~Obj_Valid(self.image) THEN RETURN
self.image->Limits, limits, pixel = pixel

; Update widget if on display
IF self->plot_params_realized() THEN BEGIN
    self.image->GetProperty, newlimits = newlimits, pix_newlimits = pix_newlimits
    self.xminID->Set_Value, String(newlimits[0])
    self.xmaxID->Set_Value, String(newlimits[1])
    self.yminID->Set_Value, String(newlimits[2])
    self.ymaxID->Set_Value, String(newlimits[3])
    self.pix_xminID->Set_Value, String(pix_newlimits[0])
    self.pix_xmaxID->Set_Value, String(pix_newlimits[1])
    self.pix_yminID->Set_Value, String(pix_newlimits[2])
    self.pix_ymaxID->Set_Value, String(pix_newlimits[3])
ENDIF

; Redraw
self->Draw

; Update limits dialog
IF self->Plot_Params_Realized() THEN BEGIN
    self.image->GetProperty, newlimits = newlimits, pix_newlimits = pix_newlimits

    self.xminID->Set_Value, newlimits[0]
    self.xmaxID->Set_Value, newlimits[1]
    self.yminID->Set_Value, newlimits[2]
    self.ymaxID->Set_Value, newlimits[3]

    self.pix_xminID->Set_Value, pix_newlimits[0]
    self.pix_xmaxID->Set_Value, pix_newlimits[1]
    self.pix_yminID->Set_Value, pix_newlimits[2]
    self.pix_ymaxID->Set_Value, pix_newlimits[3]
ENDIF

END; Kang::Limits--------------------------------------------------


;-
; Load an array or an image from file
;
; :Params:
;  image : in, required, type = 'string OR float'
;    The filename or array to load
;  header : in, optional, type = 'string'
;    If loading an array, you can load a header too
;
; :Keywords:
;  arrayname : in, optional, type = 'string', private
;    The name of the main level array to load.
;  good_image : out, optional, type = 'boolean'
;    Boolean for whether the specified image was able to be loaded. 1
;    for loaded, 0 for error loading.
;  noplot : in, optional, type = 'boolean'
;    Set this keyword to not update the plot when changes are made.
;
; :Examples:
;    To load an image from disk::
;        IDL> kang_obj->Load, 'fitsfile.fits'
;
;    To load an array
;        IDL> kang_obj->Load, array
;
;-
PRO Kang::Load, image, header, arrayname = arrayname, good_image = good_image, noplot = noplot
; Just determines if the arguments are from a filename or from 
; an array, then sends them on to the relevant routine.

; If nothing passed, assume user wants to use file seelction dialog
IF N_Elements(image) EQ 0 THEN BEGIN
    self->Load_Filename, good_image = good_image
ENDIF ELSE BEGIN

; These are filename inputs
    IF size(image, /tname) EQ 'STRING' THEN BEGIN
        self->Load_Filename, image, good_image = good_image, /noplot
    ENDIF ELSE BEGIN
; These are arrays
        IF N_Elements(header) EQ 0 THEN header = ''
        IF N_Elements(arrayname) EQ 0 THEN arrayname = 'Commandline Array'
        self->Load_Image, image, header, arrayname, good_image = good_image, /noplot
    ENDELSE
ENDELSE

self->Update_File_Dialog
END; Kang::Load--------------------------------------------------


;+
; Save the current display to disk as an image file.
;
; :Params:
;  filename : in, optional, type = 'string'
;    The output filename.  If this has an extension, keywords
;    specifying output type will be ignored.  For example, you cannot
;    save a file named idl.gif as a postscript file.
;
; :Keywords:
;   Fits : in, optional, type = 'boolean'
;     Set this keyword to output a fits subset image
;   Gif : in, optional, type = 'boolean'
;     Set this keyword to output a gif image
;   IDL_Variable : in, optional, type = 'boolean'
;     Set this keyword to output an IDL variable of the currently
;     displayed image.  If the filename starts with an exclamation
;     point, a system variable will be output.
;   Jpg : in, optional, type = 'boolean'
;     Set this keyword to output a jpg image
;   Jpeg : in, optional, type = 'boolean'
;     Set this keyword to output a jpg image
;   Png : in, optional, type = 'boolean'
;     Set this keyword to output a png image
;   Pict : in, optional, type = 'boolean'
;     Set this keyword to output a pict image
;   PS : in, optional, type = 'boolean'
;     Set this keyword to output a postscript file.  Any keywords used
;     with the ps device may be input as well to affect the output.
;   Tiff : in, optional, type = 'boolean'
;     Set this keyword to output a tiff image
;
; :Examples:
;    The postscipt option takes all the IDL keywords for this device.
;    For example, To save the currently display image as an encapsulated
;    postscipt::
;       IDL> kang_obj->Save, /ps, /encap
;
;    To do the same, specifying sizes in inches:
;       IDL> kang_obj->Save, /ps, /encap, xsize = 5, ysize = 10, /in
;
;-
PRO Kang::Save, $
  filename, $
  Fits=fits, $
  Gif=gif, $
  IDL_Variable=idl_variable, $
  Jpg=jpg, $
  Jpeg=jpeg, $
  Png=png, $
  Pict=pict, $
  PS=ps, $
  Tiff = tiff, $
  _Extra = extra

;Errors!
Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok= Error_Message()
    RETURN
    
; Close the PostScript file and clean up.
    IF !D.Name EQ 'PS' THEN BEGIN
        Device, /Close_File
        Set_Plot, thisDevice
        !P.Font = thisFont
    ENDIF
ENDIF

IF N_Elements(filename) EQ 0 AND ~self.realized THEN BEGIN
    print, 'If working from the command line, you must pass a filename string.'
    RETURN
ENDIF

; Determine the correct extension
extension = ''
IF Keyword_Set(gif) THEN extension = 'gif'
IF Keyword_Set(png) THEN extension = 'png'
IF Keyword_Set(jpg) THEN extension = 'jpg'
IF Keyword_Set(jpeg) THEN extension = 'jpeg'
IF Keyword_Set(tiff) THEN extension = 'tiff'
IF Keyword_Set(pict) THEN extension = 'pict'
IF Keyword_Set(fits) THEN extension = 'fits'
IF Keyword_Set(ps) THEN extension = 'ps'

; Get filename
IF Keyword_Set(idl_variable) THEN BEGIN
; IDL variables
    filename = Kang_Textbox(Title='Variable Names...', Group_Leader=self.tlbID, $
                                 Label=['Image Variable Name: ', 'Header Variable Name: '], Cancel=cancelled, XSize=100, Value='')

    IF cancelled THEN RETURN

; Easier just to do it here
    self.image->Extract, image, hdr
    IF strmid(filename[0], 0, 1) EQ '!' THEN DefSysV, filename[0], image ELSE $
      (SCOPE_VARFETCH(filename[0], /ENTER, LEVEL=1)) = image
    IF strmid(filename[1], 0, 1) EQ '!' THEN DefSysV, filename[1], hdr ELSE $
      (SCOPE_VARFETCH(filename[1], /ENTER, LEVEL=1)) = hdr
    RETURN

ENDIF ELSE BEGIN
    IF N_Elements(filename) EQ 0 THEN BEGIN
; Output files
        filename = Dialog_pickfile(filter = '*.' + extension, /Write, Get_Path=thispath, Path=self.lastpath, $
                                   dialog_parent = self.tlbID)
        IF filename EQ '' THEN RETURN
        self.lastpath = thispath
    ENDIF

; Determine extension
    filename_small = FSC_Base_Filename(filename, Extension=newextension, Directory = directory)
    IF newextension NE '' THEN extension = newextension
    filename = directory + filename_small ; + '.' + extension ;TVREAD takes care of this
    filename_small = filename_small + '.' + extension
ENDELSE

; Get visual depth and decomposition state.
;IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN BEGIN
;    Device, Get_Visual_Depth=theDepth, Get_Decomposed=theState
;    WSet, self.wid
;ENDIF

; Read in from the screen
IF StrUpCase(extension) EQ 'EPS' THEN extension = 'ps'
CASE StrUpCase(extension) OF
    'GIF': image = TVREAD(Filename = filename, /GIF, /NoDialog)
    'PNG': image = TVREAD(Filename = filename, /PNG, /NoDialog)
    'JPG': image = TVREAD(Filename = filename, /JPEG, /NoDialog, Quality=85)
    'JPEG': image = TVREAD(Filename = filename, /JPEG, /NoDialog, Quality=85)
    'TIFF': image = TVREAD(Filename = filename, /TIFF, /NoDialog)
    'BMP': image = TVREAD(Filename = filename, /BMP, /NoDialog)
    'PICT': image = TVREAD(Filename = filename, /PICT, /NoDialog)
    'FITS': BEGIN
        self.image->Extract, image, hdr
        WriteFits, filename + '.' + newextension, image, hdr
    END
    'PS': BEGIN
; Turn focus events off
;        IF self.realized THEN Widget_Control, self.tlbID, KBRD_Focus_Events=0

; Calculate the new ysize - keep xsize the same
        IF N_Elements(extra) NE 0 THEN self.fsc_psconfig->SetProperty, _extra = extra
        self.fsc_psconfig->SetProperty, directory = directory, filename = filename_small
        IF self.realized THEN ratio = !d.x_size / !d.y_size ELSE ratio =1. ; Defaults to square
        keywords = self.fsc_psconfig->GetKeywords()
        ysize = keywords.xsize / ratio
        self.fsc_psconfig->SetProperty, ysize = ysize

; Bring up the dialog
        IF self.realized THEN self.fsc_psconfig->gui, Cancel=cancel ELSE cancel = 0
        IF cancel THEN RETURN

; Store the device name and the current font.
        thisDevice = !D.Name
;        thisFont = !P.Font

; Configure the PostScript device.
        Set_Plot, 'ps'
        Device, _Extra=keywords
;        !P.Charsize = 1.75
;        !P.Thick = 2
;        !X.Thick = 2
;        !Y.Thick = 2
;        !Z.Thick = 2
;        !P.Symsize = 1.25
;        !P.Font = 2
;        Device, Set_Font='Helvetica', /TT_FONT
;        sizes = PSWindow(_Extra=extra)

; Replot into ps device
        self->Draw

; Clean up.
;        Set_Plot, ps_struct.currentDevice

; Close the PostScript file and clean up.
        Device, /Close
        Set_Plot, thisDevice
;        !P.Font = thisFont
;        !P = ps_struct.p
;        !X = ps_struct.x
;        !Y = ps_struct.y
;        !Z = ps_struct.z
;        ps_struct.setup = 0
;        ps_struct.currentDevice = ""
;        ps_struct.filename = ""
;        ps_struct.convert = ""
    END
ENDCASE

END; Kang::Save----------------------------------------------------------


;+
; Adjust the contrast and brightness of the displayed image
;
; :Keywords:
;  brightness : in, optional, type = 'float'
;    Value from 0 to 1 for brightness.
;  contrast : in, optional, type = 'float'
;    Value from 0 to 1 for contrast.
;  reset : in, optional, type = 'boolean'
;    Reset the values to their defaults (0.5 and 0.5)
;  nosliderupdate : in, optional, private, type = 'boolean'
;    Don't change the slider positions
;  nocontours : in, optional, type = 'boolean'
;    Don't replot the contours.  Useful if changing rapidly over many values.
;  nostars : in, optional, type = 'boolean'
;    Don't replot the star positions.  Useful if changing rapidly over many values.
;  noplot : in, optional, type = 'boolean'
;    If set, will not update plot
;
;-
PRO Kang::Stretch, brightness = brightness, contrast = contrast, reset = reset, noSliderUpdate = nosliderupdate, $
                   nocontours = nocontours, nostars = nostars, noplot = noplot
; Brightness and contrast

IF N_Elements(brightness) NE 0 THEN self.colors->SetProperty, brightness = brightness
IF N_Elements(contrast) NE 0 THEN self.colors->SetProperty, contrast = contrast
IF Keyword_Set(reset) THEN self.colors->SetProperty, brightness = 0.5, contrast = 0.5

; Change the slider values
IF ~Keyword_Set(noSliderUpdate) THEN BEGIN
    IF self.realized THEN BEGIN
        self.colors->GetProperty, brightness = brightness, contrast = contrast
        Widget_Control, self.brightnessID, Set_Value = brightness * 100.
        Widget_Control, self.contrastID, Set_Value = contrast * 100.
    ENDIF
ENDIF

; Redraw
self.colors->TVLCT
IF ~Keyword_Set(noplot) THEN self->Draw, nocontours = nocontours, nostars = nostars

END; Kang::Stretch--------------------------------------------------


;+
; Adjust the scaling of the displayed image.  The scaling is simply
; how the pixel values get mapped to the color table.
;
; :Params:
;  lowscale : in, optional, type = 'float'
;     The low scaling value.  This is the lowest value in the image
;     that will be assigned a color.  All lower image values will be
;     assigned the lowest color in the color table.
;  highscale : in, optional, type = 'float'
;     The high scaling value.  This is the highest value in the image
;     that will be assigned a color.
;
; :Keywords:
;  asinh : in, optional, type = 'boolean'
;     Use a asinh scale
;  gaussian : in, optional, type = 'boolean', private
;     Use a gaussian  scale
;  histeq : in, optional, type = 'boolean'
;     Use a histogram equalization  scale
;  linear : in, optional, type = 'boolean'
;     Use a linear scale
;  log : in, optional, type = 'boolean'
;     Use a logarithmic scale
;  noupdate : in, optional, type = 'boolean'
;     Set to not scale the image, but to just store the values.
;  noplot : in, optional, type = 'boolean'
;    If set, will not update plot.  If noupdate is set, this keyword
;    is automatically set as well.
;  power : in, optional, type = 'boolean'
;     Use a power law  scale
;  percent : in, optional, type = 'float'
;     Implement histogram clipping.  If the scale_to_image keyword is
;     set, this is implemented over the min and max of the displayed image.
;  Scale_to_Image : in, optional, type = 'boolean'
;     Scale to the min and max of the displayed image.
;  squared : in, optional, type = 'boolean'
;    Use a squared scale
;  squareroot : in, optional, type = 'boolean'
;     Use a square root scale
;
;-
PRO Kang::Scale, lowscale, highscale, percent = percent, Scale_to_Image = scale_to_image, $
                 noupdate = noupdate, noplot = noplot, $
                 linear = linear, log = log, histeq = histeq, asinh = asinh, squared = squared,  $
                 squareroot = squareroot, power = power, gaussian = gaussian
; Changes what type of scaling is used to display the image

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
   RETURN
ENDIF
IF self.image_container->Count() EQ 0 THEN RETURN

IF Keyword_Set(noupdate) THEN noplot = 1

; Turn checkmark off on all buttons
IF self.realized THEN BEGIN
;    Widget_Control, self.gaussianID, Set_Button=0
;    Widget_Control, self.powerID, Set_Button=0
    Widget_Control, self.linearID, Set_Button=0
    Widget_Control, self.logID, Set_Button=0
;    Widget_Control, self.histeqID, Set_Button=0
    Widget_Control, self.asinhID, Set_Button=0
    Widget_Control, self.squaredID, Set_Button = 0
    Widget_Control, self.squarerootID, Set_Button = 0
    
; Turn checkmark on for the right button
    IF Keyword_Set(power) THEN Widget_Control, self.powerID, Set_Button=1
    IF Keyword_Set(gaussian) THEN Widget_Control, self.gaussianID, Set_Button=1
    IF Keyword_Set(linear) THEN Widget_Control, self.linearID, Set_Button=1
    IF Keyword_Set(log) THEN Widget_Control, self.logID, Set_Button=1
    IF Keyword_Set(histeq) THEN Widget_Control, self.histeqID, Set_Button=1
    IF Keyword_Set(asinh) THEN Widget_Control, self.asinhID, Set_Button=1
    IF Keyword_Set(squared) THEN Widget_Control, self.squaredID, Set_Button=1
    IF Keyword_Set(squareroot) THEN Widget_Control, self.squarerootID, Set_Button=1
ENDIF    

IF Keyword_Set(power) THEN self.colors->SetProperty, scaling = 'Power'
IF Keyword_Set(gaussian) THEN self.colors->SetProperty, scaling = 'Gaussian'
IF Keyword_Set(linear) THEN self.colors->SetProperty, scaling = 'Linear'
IF Keyword_Set(log) THEN self.colors->SetProperty, scaling = 'Log'
IF Keyword_Set(histeq) THEN self.colors->SetProperty, scaling = 'HistEq'
IF Keyword_Set(asinh) THEN self.colors->SetProperty, scaling = 'asinh'
IF Keyword_Set(squared) THEN self.colors->SetProperty, scaling = 'squared'
IF Keyword_Set(squareroot) THEN self.colors->SetProperty, scaling = 'Square Root'
    
self.colors->Make_Ramp
self.colors->TVLCT

; Low and high scale
IF N_Elements(lowScale) NE 0 THEN self.histogram->SetProperty, lowScale=lowScale $
ELSE self.histogram->GetProperty, highscale = highscale

IF N_Elements(highScale) NE 0 THEN self.histogram->SetProperty, highScale=highScale $
ELSE self.histogram->GetProperty, lowscale = lowscale

; Scale to displayed image
IF Keyword_Set(scale_to_image) THEN BEGIN
    self.image->Scale_To_Image, percent = percent, lowscale = lowscale, highscale = highscale
ENDIF ELSE BEGIN
; Impliment the histogram clipping
    IF N_Elements(percent) NE 0 THEN BEGIN
        self.histogram->Clip, percent/100.
        self.histogram->GetProperty, lowScale = lowScale,  highScale = highScale
    ENDIF
ENDELSE

; Replot
IF N_Elements(lowscale) NE 0 AND N_Elements(highscale) NE 0 THEN BEGIN
    self.histogram->SetProperty, lowScale=lowscale, highScale=highscale
    
; ReDraw the histogram
    IF self->plot_params_realized() THEN BEGIN
;        self.histogram->FullRange
        self.histogram->Draw

; Update text boxes
        self.lowscaleID->Set_Value, lowscale
        self.highscaleID->Set_Value, highscale
    ENDIF

;Rescale Image
    IF ~Keyword_Set(noupdate) THEN self.image->BytScl, lowScale, highScale
ENDIF
IF ~Keyword_Set(noplot) THEN self->Draw

END; Kang::Scale----------------------------------------------------------


;+
; Allows a previously hidden image to be shown.
;
; :Private:
;
; :Params:
;  whichImage : in, required, type='integer array' 
;    The index of the image to show
;
; :Keywords:
;  all : in, optional, type='boolean'
;    Set this to show all images
;
;-
PRO Kang::Show, whichImage, all = all

; Error checking
n_images = self.image_container->count()
whichImage = 0 > whichImage < n_images

; Change array to 1s
(*self.show)[whichImage] = 1B

END; Kang::Show------------------------------------------------------------


;+
; Change the velocity of the displayed data cube.  With the deltavel
; keyword one can display integrated intensity images.  These
; integrated intensity images are just averages over the deltavel
; range.  Future versions should implement Gaussian convolution to the
; third axis.
;
; :Params:
;  velocity : in, optional, type = 'float'
;     The velocity to change to.  Currently this is in units of m/s only.
;  velocity2 : in, optional, type = 'float'
;    If non-zero, the image will be created from the range of velocity
;    to velocity2.
;
; :Keywords:
;  deltavel : in, optional, type = 'float'
;    The width of velocities to smooth over.  Currently this is in units of m/s only.
;  nosliderupdate : in, optional, private, type = 'boolean'
;    If set, velocity sliders will not be updated.
;  pixel : in, optional, type = 'boolean'
;    Set this keyword to intepret the input in pixels instead of coordinates
;  whichImage : in, optional, type = 'integer'
;    Which image this applies to
;
; :Examples:
;    To change the velocity channel to that which is closest to 50
;    km/s::
;       IDL> kang_obj->Velocity, 50
;
;    To do the same, but for channel 150::
;       IDL> kang_obj->Velocity, 150, /pixel
;
;    To do the same, not for the currently displayed image, but for an
;    image that is contoured over the currently dispalyed image and
;    stored in index 2::
;       IDL> kang_obj->Velocity, 150, /pixel, whichImage = 2
;
;    To create an integrated intensity image from 50-75 km/s::
;       IDL> kang_obj->Velocity, 50, 80
;
;    Or, with the deltavel keyword::
;       IDL> kang_obj->Velocity, 65, deltavel = 30
;
;-
PRO Kang::Velocity, velocity, velocity2, whichImage = whichImage, $
  deltavel = deltavel, pixel = pixel, noSliderUpdate = nosliderupdate
; Changes the velocity of an image

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
   RETURN
ENDIF
IF N_Elements(whichImage) EQ 0 THEN whichImage = self.whichImage ; Default to current image

; Get correct image and histogram objects
image = self.image_container->Get(position = whichImage)
histogram = self.histogram_container->Get(position = whichImage)

; Set velocity - get them back
image->SetVelocity, velocity, velocity2, deltavel=deltavel, pixel=pixel
image->GetProperty, velocity=velocity, deltavel=deltavel, vel_astr = astr, limits = limits, $
                    pix_newlimits = pix_newlimits, pix_limits = pix_limits, newlimits = newlimits

; If there is a widget on the display
IF XRegistered('Kang_Velocity_Widget '+StrTrim(whichImage, 2)+' '+StrTrim(self.tlbID,2)) NE 0 THEN BEGIN
    Widget_Control, (*self.velocityID)[whichImage], Get_UValue = velocityinfo ; Get widget IDs

; Update sliders
    IF ~Keyword_Set(nosliderUpdate) THEN BEGIN
        pix_deltavel = pix_newlimits[5] - pix_newlimits[4]
        Widget_Control, velocityinfo.vel_sliderID, Set_Value = pix_newlimits[4] +pix_deltavel/2. 
        Widget_Control, velocityinfo.deltavel_sliderID, Set_Value = pix_deltavel
    ENDIF

; Set input boxes
    velocityinfo.lowvel->Set_Value, StrTrim(String(newlimits[4], format = '(f10.2)'))
    velocityinfo.highvel->Set_Value, StrTrim(String(newlimits[5], format = '(f10.2)'))
    velocityinfo.vel_text->Set_Value, StrTrim(String(velocity, format = '(f10.2)'))
    velocityinfo.deltavel_text->Set_Value, StrTrim(String(deltavel, format = '(f10.2)'))

; Draw verticle line on the spectra
;    n_spectra = self.spectra->count()
;    IF n_spectra[0] NE -1 AND XRegistered('plot_windows '+StrTrim(tlbID, 2)) THEN BEGIN
;        Widget_Control, tlbID, Set_UValue=info, /No_Copy
;        Kang_Draw_Spectra, tlbID
;        Widget_Control, tlbID, Get_UValue=info, /No_Copy
;        Plots, [velocity/1000., velocity/1000.], !y.crange, color = info.drawingcolor
;    ENDIF
ENDIF

; Update histogram
self.image->Histogram, histvals=histvals, bins=bins
self.histogram->SetProperty, histogram = histvals, bins = bins
IF self->Plot_Params_Realized() THEN self.histogram->draw

; Make the new image to display. Replot
histogram->GetProperty, lowscale = lowscale, highscale = highscale
image->BytScl, lowscale, highscale
self->Draw

END; Kang::Velocity--------------------------------------------------


;+
; Zoom display in or out.  If only xcenter and ycenter are input, this
; routine will just recenter about (xcenter, ycenter).  Inputs are in
; the currently displayed units, unless pixel keyword is set.
;
; :Params:
;  xcenter : in, optional, type = 'float'
;    X center to zoom into
;  ycenter : in, optional, type = 'float'
;    Y center to zoom into
;
; :Keywords:
;  cursor : in, optional, type = 'boolean'
;    If set, the cursor position will not be updated.
;  factor : in, optional, type = 'float'
;    Zooming factor.  Less than 1 for zooming in.  Greater than 1 for
;    zooming out.  For example, factor = 2 will zoom in twice as far
;    in x and y as the currently displayed image.
;  pixel : in, optional, type = 'boolean'
;    If set, inputs are interpreted as being in pixel coordinates.
;
; :Examples:
;    To zoom in to l = 45.3, b = -0.2::
;       IDL> kang_obj->Zoom, 45.3, -0.2
;
;    To zoom to pixel location (45, 190) with 1/4 the number of pixels
;    shown in the x and y directions:
;       IDL> kang_obj->Zoom, 45, 190, /pixel, factor = 4
;
;-
PRO Kang::Zoom, xcenter, ycenter, factor = factor, cursor = cursor, pixel = pixel
; This event handler does all the zooming.  It will recenter around
; the middle, but always keep the image within the axes.

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Convert to pixel values
IF ~Keyword_Set(pixel) AND N_Elements(xcenter) NE 0 AND N_Elements(ycenter) NE 0 THEN BEGIN
    newcoords = self.image->Convert_Coord(xcenter, ycenter, new_coords = 'Image')
    xcenter = newcoords[0]
    ycenter = newcoords[1]
ENDIF

; Define the x and y centers
self.image->GetProperty, pix_newlimits = pix_newlimits
IF N_Elements(xcenter) EQ 0 THEN xcenter = (pix_newlimits[1] - pix_newlimits[0] + 1) / 2. + pix_newlimits[0]
IF N_Elements(ycenter) EQ 0 THEN ycenter = (pix_newlimits[3] - pix_newlimits[2] + 1) / 2. + pix_newlimits[2]

; Zooming ratio
IF N_Elements(factor) EQ 0 THEN factor = 1

; Store the new pixel limits from the new pixels
; Find the aspect ratio of the window
window_ratio = Float(self.xsize)/self.ysize
self.image->Zoom, xcenter, ycenter, factor = factor, window_ratio = Float(self.xsize / self.ysize)
self.image->GetProperty, newlimits = newlimits
self->Limits, newlimits[0], newlimits[1], newlimits[2], newlimits[3]

; Replot the image
self->Draw

; Move the cursor
IF Keyword_Set(cursor) THEN BEGIN
    IF self.realized THEN BEGIN
        self.image->GetProperty, pix_newlimits = pix_newlimits, newposition = newposition
        plot, [0], XRange = [pix_newlimits[0]-0.5, pix_newlimits[1]+0.5], YRange = [pix_newlimits[2]-0.5, pix_newlimits[3]+0.5], $
              XStyle=5, YStyle=5, /NoData, /NoErase, position = newposition
        TVCRS, self.current_pix[0], self.current_pix[1], /Data
    ENDIF
ENDIF

; Store the device coordinates of the small region boxes
self->RegionBoxes

; Update limits dialog
IF self->Plot_Params_Realized() THEN BEGIN
    self.image->GetProperty, newlimits = newlimits, pix_newlimits = pix_newlimits

    self.xminID->Set_Value, newlimits[0]
    self.xmaxID->Set_Value, newlimits[1]
    self.yminID->Set_Value, newlimits[2]
    self.ymaxID->Set_Value, newlimits[3]

    self.pix_xminID->Set_Value, pix_newlimits[0]
    self.pix_xmaxID->Set_Value, pix_newlimits[1]
    self.pix_yminID->Set_Value, pix_newlimits[2]
    self.pix_ymaxID->Set_Value, pix_newlimits[3]
ENDIF

END;Kang::Zoom-----------------------------------------------------


;--------------------------------------------------
;               DAOPHOT Methods
;--------------------------------------------------
;+
; Finds stars in an image
;
; :Private:
;
;-
PRO Kang::Find, x, y, flux, sharp, roundness, threshold = threshold, fwhm = fwhm, $
                roundlim = roundlim, sharplim = sharplim, centroidlim = centroidlim, filename = filename

Widget_Control, Hourglass = 1
self.image->GetProperty, fwhm = old_fwhm

; Find stars.
;IF (N_Elements(fwhm) NE 0 AND fwhm NE old_fwhm) OR old_fwhm EQ 0 THEN 
;self.image->Convol, fwhm
self.image->Find, x, y, flux, sharpness, roundness, threshold = threshold
self.image->Filter, sharplim, roundlim, centroidlim

; Draw them
self->Draw

self->DAOPhot_Widget

Widget_Control, Hourglass = 0
END; Kang::Find----------------------------------------------------


;+
; Filters star results
;
; :Private:
;-
PRO Kang::Filter, sharplim, roundlim, centroidlim

self.image->Filter, sharplim, roundlim, centroidlim

; Draw them
self->Draw
self->DAOPhot_Widget

END; Kang::Filter----------------------------------------------------

;+
; Brings up DAOPhot dialog.
;
; :Private:
;-
PRO Kang::DAOPhot_Widget

IF XRegistered('Kang DAOPhot '+StrTrim(self.tlbID, 2)) THEN BEGIN
    self->Update_DAOPhot_Widget
    RETURN
ENDIF
self.DAOPhot_WidgetID = Widget_Base(MBar = menubarID, Title = 'DAOPhot', $
                                    UValue = self, Column = 2)

; Define the Save As pull-down menu.
FileID = Widget_Button(menubarID, Value='File', /Menu)

CommandsBase = Widget_Base(self.DAOPhot_WidgetID, Column = 1)

skyBase = Widget_Base(CommandsBase, /Frame, /Column)
meanmodeID = CW_BGroup(skyBase, ['Mean', 'Mode'], /Row, /Exclusive)
labelBase = Widget_Base(skyBase, Row = 2)
label = Widget_Label(labelBase, Value = 'Sky Value: ')
skyvalID = Widget_Label(labelBase, Value = ' ', /Dynamic)
label = Widget_Label(labelBase, Value = 'Sky Sigma: ')
skysigID = Widget_Label(labelBase, Value = ' ', /Dynamic)
Widget_Control, meanmodeID, Set_Value = 0
skyID = Widget_Button(skyBase, Value = 'Find New Sky Level')

convolBase = Widget_Base(CommandsBase, /Frame, /Column)
sliderBase = Widget_Base(convolBase, Row = 1)
label = Widget_Label(sliderBase, Value = 'FWHM: ')
fwhm_sliderID = Widget_Slider(sliderBase, min = 1, max = 13, xsize = 70)
labelBase = Widget_Base(convolBase, Row = 1)
label = Widget_Label(labelBase, Value = 'FWHM Error: ')
errorID = Widget_Label(labelBase, Value = ' ', /Dynamic)
colvolID = Widget_Button(convolBase, Value = 'Convolve Image')

findBase = Widget_Base(CommandsBase, /Frame, /Column)
sliderBase = Widget_Base(findBase, Row = 1)
label = Widget_Label(sliderBase, Value = 'Threshold: ')
threshold_sliderID = Widget_Slider(sliderBase, min = 1, max = 20, xsize = 60)
labelBase = Widget_Base(findBase, Row = 1)
label = Widget_Label(labelBase, Value = '# Stars: ')
n_starsID = Widget_Label(labelBase, Value = ' ', /Dynamic)
findID = Widget_Button(findBase, Value = 'Find Point Sources')

filterBase = Widget_Base(CommandsBase, /Frame, /Column)
limitsBase = Widget_Base(filterBase, Row = 2)
label = Widget_Label(limitsBase, Value = 'Sharp:')
sharp_minID = Widget_Text(limitsBase, xsize = 4, /Edit)
sharp_maxID = Widget_Text(limitsBase, xsize = 4, /Edit)
label = Widget_Label(limitsBase, Value = 'Round:')
round_minID = Widget_Text(limitsBase, xsize = 4, /Edit)
round_maxID = Widget_Text(limitsBase, xsize = 4, /Edit)

filterID = Widget_Button(filterBase, Value = 'Filter Results')

TableBase = Widget_Base(self.DAOPhot_WidgetID)
self.DAOPhot_tableID = Widget_Table(self.DAOPhot_WidgetID, column_labels = ['X Pos', 'Y Pos', 'Flux', 'Sharpness', 'Roundness'], $ 
                       Y_Scroll_Size = 21, /Scroll, xsize = 5, column_Widths = 80)

; Create structure with IDs
UVal = {self:self, $
        meanmodeID:meanmodeID, $
        skyvalID:skyvalID, $
        skysigID:skysigID, $
        errorID:errorID, $
        fwhm_sliderID:fwhm_sliderID, $
        n_starsID:n_starsID, $
        threshold_sliderID:threshold_sliderID, $
        sharp_minID: sharp_minID, $
        sharp_maxID: sharp_maxID, $
        round_minID: round_minID, $
        round_maxID: round_maxID $
       }

; Bring up display
Widget_Control, self.DAOPhot_WidgetID, Set_UValue = uval, /Realize
XManager, 'Kang DAOPhot '+StrTrim(self.tlbID, 2), self.DAOPhot_WidgetID, /No_Block, $
          Event_Handler = 'Kang_DAOPhot_Events', Group_Leader=self.tlbID

; Update display
self->Update_DAOPhot_Widget

END; Kang::DAOPhot_Widget----------------------------------------


;+
; DAOPhot Dialog Events.
;
; :Private:
;-
PRO Kang_DAOPhot_Events, event

Widget_Control, event.top, Get_UValue = uval

; Branch on type of event
thisEvent = Tag_Names(event, /Structure_Name)
CASE thisEvent OF

; Menubar and events
    'WIDGET_BUTTON': BEGIN
        Widget_Control, event.ID, Get_Value = buttonName
        CASE buttonName OF
            'Find New Sky Level': uval.self->Sky
            'Convolve Image': BEGIN
                Widget_Control, uval.fwhm_sliderID, Get_Value = fwhm
                uval.self->Convol, fwhm
            END
            'Find Point Sources': BEGIN
                Widget_Control, uval.threshold_sliderID, Get_Value = threshold
                uval.self->Find, threshold = threshold
            END
            'Filter Results': uval.self->Filter
        ENDCASE

; Update the display
        uval.self->Update_DAOPhot_Widget
    END

    'WIDGET_SLIDER': BEGIN
;        Widget_Control, event.ID, Get_UValue = sliderName

;; Branch off the two options
;        CASE sliderName OF
;            'FWHM': ;uval.self->stretch, brightness = event.value / 100.
;        ENDCASE
    END
    ELSE:
ENDCASE

END; Kang_DAOPhot_Events-----------------------------------------

;+
; Compute Sky brightness
;
;-
PRO Kang::Sky, skyval, skysig

self.image->Sky, skyval, skysig
self->Update_DAOPhot_Widget

END; Kang::Sky------------------------------------------------------------


;+
; Compute Sky brightness
;
; :Private:
;-
PRO Kang::Convol, fwhm

Widget_Control, Hourglass = 1

self.image->Convol, fwhm
self->Update_DAOPhot_Widget

Widget_Control, Hourglass = 0
END; Kang::Convol------------------------------------------------------------


;+
; Updates up DAOPhot dialog.
;
; :Private:
;-
PRO Kang::Update_DAOPhot_Widget

; Nothing to update
IF ~XRegistered('Kang DAOPhot '+StrTrim(self.tlbID, 2)) THEN RETURN

; Get info out
Widget_Control, self.DAOPhot_WidgetID, Get_UValue = uval
self.image->GetProperty, stars = stars, skyval = skyval, skysig = skysig, fwhm = fwhm, $
  ps_threshold = ps_threshold, sharplim = sharplim, roundlim = roundlim, err_fwhm = err_fwhm

; Sky Level
Widget_Control, uval.skyvalID, Set_Value = StrTrim(skyval, 2)
Widget_Control, uval.skysigID, Set_Value = StrTrim(skysig, 2)

; Image Convolution
;IF fwhm NE 0 THEN BEGIN
;    Widget_Control, uval.fwhm_sliderID, Set_Value = fwhm
;    Widget_Control, uval.errorID, Set_Value = fwhm_error
;ENDIF ELSE Widget_Control, uval.fwhm_sliderID, Set_Value = 3

; Find point sources
IF ps_threshold NE 0 THEN BEGIN
    Widget_Control, uval.threshold_sliderID, Set_Value = ps_threshold
    IF size(stars, /tname) EQ 'STRUCT' THEN Widget_Control, uval.n_starsID, Set_Value = StrTrim(stars.n_stars)
ENDIF

; Filter
Widget_Control, uval.sharp_minID, Set_Value = StrTrim(sharplim[0], 2)
Widget_Control, uval.sharp_maxID, Set_Value = StrTrim(sharplim[1], 2)
Widget_Control, uval.round_minID, Set_Value = StrTrim(roundlim[0], 2)
Widget_Control, uval.round_maxID, Set_Value = StrTrim(roundlim[1], 2)

; Table
IF size(stars, /tname) EQ 'STRUCT' THEN BEGIN
; It takes a while to update this, so let's only do it if it's different
    newtable = transpose([[stars.x],[stars.y], [stars.flux], [stars.sharpness], [stars.roundness]])
    Widget_Control, self.DAOPhot_TableID, Get_Value = oldTable
    IF total(newtable EQ oldtable) NE N_Elements(oldtable) THEN BEGIN
        Widget_Control, self.DAOPhot_TableID, Set_Value = newTable, $
                        table_ysize = stars.n_stars, table_xsize = 5, column_Widths = 80, alignment = 2
    ENDIF
ENDIF

END; Kang::DAOPhot_Widget----------------------------------------


;+

;+
; Subtracts stars found by Find from the image.
;
; :Private:
;
;-
PRO Kang::SubStar

; Need tp get the IDs out here

self.image->Substar, ids = ids

END; Kang::SubStar------------------------------------------------


;--------------------------------------------------
;               Spectra Methods
;--------------------------------------------------
;+
; Deletes the spectra specified.
;
; :Params:
;  whichspectrum : in, optional, type = 'integer array'
;    The spectra to delete specified as an integer array
;
; :Keywords:
;  all : in, optional, type = 'boolean'
;    Set this keyword to delete all the regions
;  NoPlot : in, optional, type = 'boolean'
;    If set, will not update plot
;
;-
PRO Kang::Delete_Spectrum, whichSpectrum, All = all, noplot = noplot

IF ~Obj_Valid(self.spectra) THEN RETURN
self.spectra->Remove, position = whichSpectrum, All = all

; Update, replot
IF ~Keyword_Set(noplot) THEN self->Draw_Spectra

END; Kang::Delete_Spectra--------------------------------------------------


;+
; Creates spectrum and displays it in the spectrum window.  If the
; position argument is present, a spectrum will be extracted from the
; region of index position.  If the x and y values are present (and
; the position keyword is not), the spectrum will be extracted from
; the x,y location.  If neither keywords is present, the spectrum will
; be extracted from the currently selected region.  Extracted spectrum
; is the unweighted average of all spectra within the region.
;
; :Params:
;  x : in, optional, type = 'integer'
;    The x location to extract the spectrum from
;  y : in, optional, type = 'integer'
;    The y location to extract the spectrum from
;
; :Keywords:
;  Pixel : in, optional, type = 'boolean'
;    If set, the x and y parameters will be interpreted as pixels
;  NoPlot : in, optional, type = 'boolean'
;    If set, will not update plot
;  StdDev : out, optional, type = 'float'
;    The standard deviation at each velocity
;  TMBIDL : in, optional, type = 'boolean'
;    Set to export spectrum to the TMBIDL spectral analysis package
;  XVals : out, optional, type = 'fltarr'
;    The x values of the output spectrum
;  YVals : out, optional, type = 'fltarr'
;    The y values of the output spectrum
;
; :Examples:
;    To create an average spectrum from the currently selected
;    region::
;       IDL> kang_obj->Extract_Spectrum
;
;    To extract a spectrum from region of zero-based index 5::
;       IDL> kang_obj->Extract_Spectrum, position = 5
;
;    To extract a single spectrum from (l, b) = (22.5, 0) and return
;    the x and y values::
;       IDL> kang_obj->Extract_Spectrum, 22.5, 0, xvals = xvals, yvals = yvals       
;
;-
PRO Kang::Extract_Spectrum, x, y, noplot = noplot, pixel = pixel, position = position, $
  stddev = stddev, tmbidl = tmbidl, xvals = xvals, yvals = yvals

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; If both positional parameters are input as well as the region
; position keyword, we want the region to be the one used
; If no region position, then use position parameters.
; If no position parameters and no region, use currently selected
; region
; If none of these, return

; Can't just have one
IF N_Params() EQ 1 THEN BEGIN
    print, 'ERROR: Must specify two parameters.'
    RETURN
ENDIF

; If no position specified, and no regions selected, return
self.regions->GetProperty, selected_regions = selected_regions
position = selected_regions
IF (N_Elements(position) EQ 0 OR position[0] EQ -1) AND N_Params() EQ 0 THEN BEGIN
    position = selected_regions
    IF position[0] EQ -1 THEN BEGIN
        print, 'ERROR: No regions are selected to extract spectrum from.'
        RETURN
    ENDIF
ENDIF

; Convert to data coordinates
IF N_Params() EQ 2 AND ~Keyword_Set(pixel) THEN BEGIN
    pix_xy = self.image->Convert_Coord(x, y, new_coords = 'Image')
 ENDIF; ELSE pix_xy = [x, y]

; If inside a region, make average spectrum
IF N_Elements(position) EQ 0 OR position[0] EQ -1 THEN BEGIN
    self.image->GetProperty, pix_limits = pix_limits, limits = limits
    yvals = self.image->Find_Values(pix_xy[0], pix_xy[1], lindgen(pix_limits[5]+1))
    xvals = scale_vector(findgen(pix_limits[5]), limits[4], limits[5])
    title = 'Spectrum of ('+StrTrim(self.current_data[0],2)+','+StrTrim(self.current_data[1])+')'
ENDIF ELSE BEGIN
; Find indices
    indices = self.regions->Find_Indices(position = position)

; Create spectrum
    Widget_Control, Hourglass=1
    yvals = self.image->Make_Spectrum(indices, xvals = xvals, stddev = stddev)
    Widget_Control, Hourglass=0

    title = 'Spectrum of ('+StrTrim(self.initial_data[0], 2)+': '+StrTrim(self.final_data[0], 2)+$
            ',  '+StrTrim(self.initial_data[1], 2)+': '+StrTrim(self.final_data[1], 2)+')    N = ' + $
            StrTrim(N_Elements(indices),2)
ENDELSE

; Create an object for the spectrum, then add to container
self.image->GetProperty, bartitle = bartitle
IF bartitle EQ '' THEN bartitle = 'Pixel Value'

IF ~Keyword_Set(tmbidl) THEN BEGIN
    spec_obj = Obj_New('Kang_Spectrum', xvals, yvals, Title = Title, $
                       XTitle = 'Velocity (km s!U-1!N)', YTitle = bartitle, /Overplot, $
                       color = self.colors->Colorindex('black'), CName = 'black', $
                       axisColor = self.colors->Colorindex('black'), axisCName = 'black', $
                       backColor = self.colors->Colorindex('white'), backCName = 'white')
;self.spectra->Add, spec_obj, position = 0
    self.spectra->Replace, spec_obj, position = 0

; Remove the spectrum if it is already there
;count = self.spectra->Count()
;IF self.whichSpectrum LT count THEN self.spectra->remove, position = self.whichSpectrum

; Replot
    IF ~Keyword_Set(noplot) THEN BEGIN
; Create the draw windows for the spectrum and the plots if they  haven't been created already

        IF self.realized THEN BEGIN
            self->Plot_Windows_Widget

; Plot the minispectra
;            IF N_Elements(indices) GT 1 THEN self->Draw_MiniSpectra

; Plot the spectrum in the spectrum window, or export it to the TMBIDL package
            WSet, self.spectrum_WID
            Widget_Control, self.windows_tabBase, Set_Tab_Current = 0
            self->Draw_Spectra
        ENDIF
    ENDIF

; Turn on button
;    info.plotwindowID, Get
ENDIF ELSE BEGIN

; Export to tmbidl package
; Transfer data into TMBIDL data format 
    self.image->GetProperty, header = hdr
    mapfile=sxpar(hdr,'OBJECT')
    nlong=sxpar(hdr,'NAXIS1')
    nlat =sxpar(hdr,'NAXIS2')
;    nchan=sxpar(hdr,'NAXIS3')
    nchan = 659

    delta_l=sxpar(hdr,'CDELT1') ; in degrees 
    delta_b=sxpar(hdr,'CDELT2') ; in degrees
    delta_v=sxpar(hdr,'CDELT3')/1000.D ; in km/sec
;;    !grs.delta_l=delta_l
;;    !grs.delta_b=delta_b
;;    !grs.delta_v=delta_v
    
    lmap0=sxpar(hdr,'CRPIX1')
    bmap0=sxpar(hdr,'CRPIX2')
    
    v_center=sxpar(hdr,'CRVAL3')/1000.D ; LSR velocity of 'center' channel  
    v_refchan=sxpar(hdr,'CRPIX3') ; pixel/channel of this velocity
;;    !grs.v_center=v_center
;;    !grs.v_refchan=v_refchan
    
    x=fltarr(nchan)
    FOR i=0,nchan-1 DO x[i]=(i-v_refchan)*delta_v+v_center

    lpix = 0;convert_array[1]
    bpix = 0;convert_array[3]
;    l_gal=(lpix - lmap0)*delta_l   
;    b_gal=(bpix - bmap0)*delta_b 
    l_gal = 0.
    b_gal = 0.
    
    IF (b_gal LT 0.d) THEN source='G'+fstring(l_gal,'(f6.3)')+fstring(b_gal,'(f6.3)') $
    ELSE source='G'+fstring(l_gal,'(f6.3)')+'+'+fstring(b_gal,'(f5.3)')   
    
; Convert to tmb_idl data format
    !b[0]=!rec            ; initialize the structure

    !b[0].source=byte(strtrim(source,2))
    !b[0].observer=byte('BU-FCRAO')
    !b[0].obsid=byte('Galactic Ring Survey')
    !b[0].scan_num=2000000L
    !b[0].line_id=byte('13CO(1-0)')

    !b[0].ra=0.d
    !b[0].dec=0.d
    !b[0].epoch=1950.
    !b[0].l_gal=l_gal
    !b[0].b_gal=b_gal
    !b[0].hor_offset=lpix
    !b[0].ver_offset=bpix

    !b[0].vel=v_center*1000.d
    !b[0].ref_ch=v_refchan
    !b[0].rest_freq=110.201353D+9
    !b[0].sky_freq =110.201353D+9
    !b[0].delta_x=-(delta_v/!light_c)*!b[0].rest_freq

    !b[0].bw=nchan*abs(!b[0].delta_x)
    !b[0].tsys=1.d
    !b[0].tintg=60.d
    !b[0].tcal=1.d

    !data_points=nchan
    !b[0].data_points=!data_points

; Need to make the spectrum have length 659 since it is a fixed length
; record. Convert to T_MB
    spectrum = spectrum/0.48
    stddev = stddev/0.48
    IF n_vel GT 659 THEN BEGIN 
        spectrum = spectrum[0:658]
        stddev = stddev[0:658]
    ENDIF
    IF n_vel LT 659 THEN BEGIN
        !b[0].data[0:N_Elements(spectrum)-1]=spectrum
        !b[10].data[0:N_Elements(stddev)-1]=stddev
    ENDIF ELSE BEGIN
        !b[0].data = spectrum[0:658]
        !b[10].data = stddev[0:658]
    ENDELSE
    
; Change x-axis to km/s
    !chan=0
    !vgrs=1
    !x.title='Velocity (km/s)'
    !y.title=textoidl('T_{MB}')

; Display the spectrum
    IF info.deltavel[info.whichImage]/2000. GE 2 THEN BEGIN
        flag, info.velocity[info.whichImage]/1000.+info.deltavel[info.whichImage]/2000.
        flag, info.velocity[info.whichImage]/1000.-info.deltavel[info.whichImage]/2000.
    ENDIF ELSE flag, info.velocity[info.whichImage]/1000.

;    freex
;    xxx
ENDELSE

END; Kang::Extract_Spectrum-----------------------------------------------------------------


;+
; Draws the spectra in the spectrum window.
;
;-
PRO Kang::Draw_Spectra

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Get info structure out
IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN WSet, self.spectrum_wid

; Draw them
self.spectra->Draw
self.spectrum_window->Update
self.plot_window->Update

END; Kang_Draw_Spectra-----------------------------------------------


;+
; Flags velocities in the displayed spectra with a vertical line.
;
; :Params:
;    Flags : in, required, type = 'Float Array'
;        The velocities to flag 
;
; :Keywords:
;    Color : in,optional, type = 'String Array'
;        The color to draw the flags in.  Defaults to red.
;
; :Examples:
;   To flag 45 km/s with a green line::
;     IDL> kang_obj-> Flag, 45, color = 'green' 
;
;-
PRO Kang::Flag, flags, color = color

IF N_Elements(flags) EQ 0 THEN RETURN
IF N_Elements(color) NE 0 THEN cname = color ELSE cname = 'red'
colors = self.colors->ColorIndex(cname)
self.spectra->flag, flags, color = color, cname = cname
self->Draw_Spectra

END; Kang::Flag------------------------------------------------------


;+
; Fits Gaussians to displayed spectra.  Future versions will have more
; features.
;
; :Params:
;  n_gauss : in, optional, type = 'integer'
;    The number of Gaussians to fit.  Defaults to 1.
;
; :Keywords:
;  xrange : in, optional, private, type = 'float array(2)'
;    The range to fit over.
;
; :Examples:
;    To fit a Gassian to the displayed spectrum::
;      IDL> kang_obj->Gauss
;
;-
PRO Kang::Gauss, n_gauss, xrange = xrange

WSet, self.spectrum_wid

spectrum = self.spectra->Get()
self->Draw_Spectra
spectrum->Gauss, n_gauss, xrange = xrange

END; Kang::Gauss--------------------------------------------------


;+
; Creates a display with the spectrum for each pixel overlaid on top
; of the pixel values.  The color table and scaling are from the main
; displayed image.
;
; :Private:
;
; :Keywords:
;  XRange : in, optional, type = 'float'
;    The xrange to display
;  YRange : in, optional, type = 'float'
;    The yrange to display
;
;-
PRO Kang::Draw_MiniSpectra, XRange = xrange, YRange = yrange
; Plot the minispectra. Events from zooming will use the xrange and
; yrange keywords

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Find indices
indices = self.regions->Find_Indices(position = self.whichInside)
self.regions->GetProperty, xrange = xrange, yrange = yrange, position = self.whichInside

; Draw the minispectra
WSet, self.minispectrum_wid

; Events zooming in or out
IF N_Elements(xrange) EQ 2 AND N_Elements(yrange) EQ 2 THEN BEGIN
    pix_limits  = [0, 1000, 0, 1000]
    xrange = Round([(xrange[1] + 0.5) > pix_limits[0], (xrange[0] - 0.5) < pix_limits[1]])
    yrange = Round([(yrange[0] + 0.5) > pix_limits[2], (yrange[1] - 0.5) < pix_limits[3]])
print, xrange, yrange
ENDIF ELSE self.regions->GetProperty, xrange = xrange, yrange = yrange

; Draw spectra
self.image->Draw_Minispectra, indices, XRange = xrange, yrange = yrange
self.minispectrum_window->Update

END; Kang::Draw_MiniSpectra------------------------------------------------------------------


;+
; Save the current spectrum to disk.
;
; :Params:
;  filename : in, optional, type = 'string'
;    The output filename.  If this has an extension, keywords
;    specifying output type will be ignored.  For example, you cannot
;    save a file named idl.gif as a postscript file.
;
; :Keywords:
;   Gif : in, optional, type = 'boolean'
;     Set this keyword to output a gif image
;   IDL_Variable : in, optional, type = 'boolean'
;     Set this keyword to output an IDL variable of the currently
;     displayed image.  If the filename starts with an exclamation
;     point, a system variable will be output.
;   Jpg : in, optional, type = 'boolean'
;     Set this keyword to output a jpg image
;   Jpeg : in, optional, type = 'boolean'
;     Set this keyword to output a jpg image
;   FITS : in, optional, type = 'boolean'
;     Set this keyword to output a FITS spectrum
;   Png : in, optional, type = 'boolean'
;     Set this keyword to output a png image
;   Pict : in, optional, type = 'boolean'
;     Set this keyword to output a pict image
;   PS : in, optional, type = 'boolean'
;     Set this keyword to output a postscript file.  Any keywords used
;     with the ps device may be input as well to affect the output.
;   Tiff : in, optional, type = 'boolean'
;     Set this keyword to output a tiff image
;
;  :Examples:
;    To save the current spectrum as a FITS spectrum for use in
;    another application::
;      IDL> kang_obj->Save_Spectrum, 'spectrum.fits', /fits
;
;    To save it as an encapsulated ps file::
;      IDL> kang_obj->Save_Spectrum, 'spectrum.ps', /ps, /encap
;
;-
PRO Kang::Save_Spectrum, $
  filename, $
  Gif=gif, $
  IDL_Variable=idl_variable, $
  FITS=fits, $
  Jpg=jpg, $
  Jpeg=jpeg, $
  Png=png, $
  Pict=pict, $
  PS=ps, $
  Tiff = tiff, $
  _Extra = extra

;Errors!
Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok= Error_Message()
    RETURN
    
; Close the PostScript file and clean up.
    IF !D.Name EQ 'PS' THEN BEGIN
        Device, /Close_File
        Set_Plot, thisDevice
        !P.Font = thisFont
    ENDIF
ENDIF

IF N_Elements(filename) EQ 0 AND ~self.realized THEN BEGIN
    print, 'If working from the command line, you must pass a filename string.'
    RETURN
ENDIF

; Determine the correct extension
extension = ''
IF Keyword_Set(gif) THEN extension = 'gif'
IF Keyword_Set(png) THEN extension = 'png'
IF Keyword_Set(jpg) THEN extension = 'jpg'
IF Keyword_Set(jpeg) THEN extension = 'jpeg'
IF Keyword_Set(fits) THEN extension = 'fits'
IF Keyword_Set(tiff) THEN extension = 'tiff'
IF Keyword_Set(pict) THEN extension = 'pict'
IF Keyword_Set(ps) THEN extension = 'ps'

; Get filename
IF Keyword_Set(idl_variable) THEN BEGIN
; IDL variables
    filename = Kang_Textbox(Title='Variable Name...', Group_Leader=self.tlbID, $
                                 Label=['Spectrum Name: ',  'Velocity Name: '], Cancel=cancelled, XSize=100)
    IF cancelled THEN RETURN

; Easier just to do it here
    spectrum = self.spectra->Get()
    spectrum->GetProperty, xvals = xvals, yvals = yvals
    IF strmid(filename[0], 0, 1) EQ '!' THEN DefSysV, filename[0], image ELSE $
      (SCOPE_VARFETCH(filename[0], /ENTER, LEVEL=1)) = xvals
    IF strmid(filename[1], 0, 1) EQ '!' THEN DefSysV, filename[1], hdr ELSE $
      (SCOPE_VARFETCH(filename[1], /ENTER, LEVEL=1)) = yvals
    RETURN

ENDIF ELSE BEGIN
    IF N_Elements(filename) EQ 0 THEN BEGIN
; Output files
        filename = Dialog_pickfile(filter = '*.' + extension, /Write, Get_Path=thispath, Path=self.lastpath, $
                                   dialog_parent = self.tlbID)
        IF filename EQ '' THEN RETURN
        self.lastpath = thispath

; Determine extension
        filename_small = FSC_Base_Filename(filename, Extension=newextension, Directory = directory)
        IF newextension NE '' THEN extension = newextension
        filename = directory + filename_small; + '.' + extension ; Looks like TVRead takes care of this.
        filename_small = filename_small + '.' + extension
    ENDIF
ENDELSE

; Read in from the screen
IF StrUpCase(extension) EQ 'EPS' THEN extension = 'ps'
WSet, self.spectrum_wid

CASE StrUpCase(extension) OF
    'GIF': image = TVREAD(Filename = filename, /GIF, /NoDialog)
    'PNG': image = TVREAD(Filename = filename, /PNG, /NoDialog)
    'JPG': image = TVREAD(Filename = filename, /JPEG, /NoDialog, Quality=85)
    'JPEG': image = TVREAD(Filename = filename, /JPEG, /NoDialog, Quality=85)
    'TIFF': image = TVREAD(Filename = filename, /TIFF, /NoDialog)
    'BMP': image = TVREAD(Filename = filename, /BMP, /NoDialog)
    'PICT': image = TVREAD(Filename = filename, /PICT, /NoDialog)
    'FITS': BEGIN
            spectrum = self.spectra->Get()
            spectrum->GetProperty, xvals = xvals, yvals = yvals
            self.image->GetProperty, header = hdr

; Change header around
; Get velocity info
            cdelt3 = sxpar(hdr, 'CDELT3', Comment = cdelt3_comment)
            crpix3 = sxpar(hdr, 'CRPIX3', Comment = crpix3_comment)
            crval3 = sxpar(hdr, 'CRVAL3', Comment = crval3_comment)
            ctype3 = sxpar(hdr, 'CTYPE3', Comment = ctype3_comment)
            IF N_Elements(cdelt3_comment) EQ 0 THEN cdelt3_comment = ''
            IF N_Elements(crpix3_comment) EQ 0 THEN crpix3_comment = ''
            IF N_Elements(crval3_comment) EQ 0 THEN crval3_comment = ''
            IF N_Elements(ctype3_comment) EQ 0 THEN ctype3_comment = ''

; Add records from third axis to first
            sxaddpar, hdr, 'CDELT1', cdelt3, cdelt3_comment
            sxaddpar, hdr, 'CRPIX1', crpix3, crpix3_comment
            sxaddpar, hdr, 'CRVAL1', crval3, crval3_comment
            sxaddpar, hdr, 'CTYPE1', ctype3, ctype3_comment

; Delete 2nd, third axes
            sxdelpar, hdr, 'CROTA1' ; Delete rotation
            sxdelpar, hdr, 'CDELT2'
            sxdelpar, hdr, 'CRPIX2'
            sxdelpar, hdr, 'CRVAL2'
            sxdelpar, hdr, 'CROTA2'
            sxdelpar, hdr, 'CTYPE2'
            sxdelpar, hdr, 'CDELT3'
            sxdelpar, hdr, 'CRPIX3'
            sxdelpar, hdr, 'CRVAL3'
            sxdelpar, hdr, 'CROTA3'
            sxdelpar, hdr, 'CTYPE3'

; Change number of records
            sxaddpar, hdr, 'NAXIS1', N_Elements(spectrum)
            sxdelpar, hdr, 'NAXIS2'
            sxdelpar, hdr, 'NAXIS3'

; Write file
            writefits, filename + '.' + extension, yvals, hdr
    END
    'PS': BEGIN
; Turn focus events off
;        IF self.realized THEN Widget_Control, self.tlbID, KBRD_Focus_Events=0

; Calculate the new ysize - keep xsize the same
        IF N_Elements(extra) NE 0 THEN self.fsc_psconfig_spectra->SetProperty, _extra = extra
        self.fsc_psconfig_spectra->SetProperty, directory = directory, filename = filename_small
        IF self.realized THEN ratio = !d.x_size / !d.y_size ELSE ratio =1. ; Defaults to square
        keywords = self.fsc_psconfig_spectra->GetKeywords()
        ysize = keywords.xsize / ratio
        self.fsc_psconfig_spectra->SetProperty, ysize = ysize

; Bring up the dialog
        IF self.realized THEN self.fsc_psconfig_spectra->gui, Cancel=cancel ELSE cancel = 0
        IF cancel THEN RETURN

; Store the device name and the current font.
        thisDevice = !D.Name
        thisFont = !P.Font

; Configure the PostScript device.
        Set_Plot, 'PS'
        Device, _Extra=keywords
;        !P.Charsize = 1.75
;        !P.Thick = 2
;        !X.Thick = 2
;        !Y.Thick = 2
;        !Z.Thick = 2
;        !P.Symsize = 1.25
;        !P.Font = 1
;        Device, Set_Font='Helvetica', /TT_FONT
;        sizes = PSWindow(_Extra=extra)

; Replot into ps device
        self->Draw_Spectra

; Clean up.
;        Set_Plot, ps_struct.currentDevice

; Close the PostScript file and clean up.
        Device, /Close_File
        Set_Plot, thisDevice
;        !P.Font = thisFont
;        !P = ps_struct.p
;        !X = ps_struct.x
;        !Y = ps_struct.y
;        !Z = ps_struct.z
;        ps_struct.setup = 0
;        ps_struct.currentDevice = ""
;        ps_struct.filename = ""
;        ps_struct.convert = ""
    END
ENDCASE

END; Kang_Save_Spectrum--------------------------------------------------------------


;+
; Change the properties of the current spectrum.
;
; :Keywords:
;  axiscolor : in, optional, type = 'string'
;    The axis color name
;  backcolor : in, optional, type = 'string'
;    The background color name
;  charsize : in, optional, type = 'integer'
;    The size of the axis characters
;  charthick : in, optional, type = 'integer'
;   The thickness of the axis characters
;  color : in, optional, type = 'string'
;    The spectrum line color name
;  linestyle : in, optional, type = 'integer'
;    The line style to use when plotting the spectrum
;  width : in, optional, type = 'integer'
;    The width of the spectrum line
;  xrange : in, optional, type = 'float array(2)'
;    The xrange of the spectrum plot
;  yrange : in, optional, type = 'float array(2)'
;    The yrange of the spectrum plot
;
;-
PRO Kang::Spectrum_Property, $
  axiscolor = axiscolor, $
  backcolor = backcolor, $
  charsize = charsize, $
  charthick = charthick, $
  color = color, $
  freeze_x = freeze_x, $
  freeze_y = freeze_y, $
  linestyle = linestyle, $
  width = width, $
  xrange = xrange, $
  yrange = yrange

IF N_Elements(color) NE 0 THEN BEGIN
    cname = color
    color = self.colors->ColorIndex(cname)
ENDIF
IF N_Elements(axiscolor) NE 0 THEN BEGIN
    axiscname = axiscolor
    axiscolor = self.colors->ColorIndex(axiscname)
ENDIF
IF N_Elements(backcolor) NE 0 THEN BEGIN
    backcname = backcolor
    backcolor = self.colors->ColorIndex(backcname)
ENDIF
spectrum = self.spectra->Get()
spectrum->SetProperty, axiscolor = axiscolor, axiscname = axiscname, backcolor = backcolor, backcname = backcname, $
  charsize = charsize, charthick = charthick, color = color, cname = cname,  freeze_x = freeze_x, freeze_y = freeze_y, $
  linestyle = linestyle, width = width, xrange = xrange, yrange = yrange

self->Draw_Spectra
END; Kang::Spectrum_Property-----------------------------------------------------------------------


;+
; Un-Flags velocities in the displayed spectra.
;
; :Params:
;    Flags : in, required, type = 'Float Array'
;        The velocities to unflag.  Must be exactly what was input. 
;
; :Keywords:
;    All : in, optional, type = 'boolean'
;        Set to remove all flags.
;
; :Examples:
;   To unflag 45 km/s::
;     IDL> kang_obj-> UnFlag, 45
;
;-
PRO Kang::UnFlag, flags, All = all

IF N_Elements(flags) EQ 0 THEN RETURN
self.spectra->unflag, flags, all = all
self->Draw_Spectra

END; Kang::UnFlag------------------------------------------------------


;--------------------------------------------------
;               Analysis Methods
;--------------------------------------------------
;+
; Finds the indices for the selected region.  These are the same
; indices as would be returned from the "where" function
;
; :Returns:
;   An array of indices for the image that lie inside the region.
;
; :Keywords:
;  position : in, optional, type = 'integer'
;    Region index to find indices for.  Defaults to current selection.
;
;-
FUNCTION Kang::Find_Indices, position = position

RETURN, self.regions->Find_Indices(position = position)
END; Kang::Find_Indices--------------------------------------------------


;+
; Set which type of interactive plot should be displayed.
;
; :Private:
;
; :Keywords:
;
;-
PRO Kang::Interactive_Plots, none = none, xplot = xplot, yplot = yplot, zplot = zplot
; These are from when the user has selected a plot in the main
; menubar.  It sets the plot_type variable in the info structure so
; the motion events handler will catch it

; Set checkboxes
IF XRegistered('Kang ' + StrTrim(self.tlbID, 2)) THEN widget_update = 1B ELSE widget_update = 0B
IF self.realized THEN BEGIN
    Widget_Control, self.xplotID, Set_Button = 0
    Widget_Control, self.yplotID, Set_Button = 0
    Widget_Control, self.zplotID, Set_Button = 0
    Widget_Control, self.noneID, Set_Button = 0
ENDIF

IF Keyword_Set(xplot) THEN BEGIN
    self.plot_Type = 'XPlot'
    IF self.realized THEN Widget_Control, self.xplotID, Set_Button = 1
ENDIF
IF Keyword_Set(yplot) THEN BEGIN
    self.plot_Type = 'YPlot'
    IF self.realized THEN Widget_Control, self.yplotID, Set_Button = 1
ENDIF
IF Keyword_Set(zplot) THEN BEGIN
    self.plot_Type = 'ZPlot'
    IF self.realized THEN Widget_Control, self.zplotID, Set_Button = 1
ENDIF
IF Keyword_Set(none) THEN BEGIN
    self.plot_Type = 'None'
    IF self.realized THEN Widget_Control, self.noneID, Set_Button = 1
END

END; Kang::Interactive_Plots------------------------------------------


;+
; Smooth the currently displayed image
;
; :Private:
;
;
;-
PRO Kang::Smooth

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF

;IF XRegistered('Kang_Profile' + StrTrim(tlbID, 2)) THEN RETURN
self.image->Smooth

END; Kang::Smooth---------------------------------------------


;+
; Makes a 3D visualization using XObjView
;
; :Private:
;
;-
PRO Kang::ThreeD

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

self.image->Make_3D

END; Kang::ThreeD -------------------------------------------------------


;+
; Creates a large group of regions that are defined by the low and
; high threshold.  This is semilar to running SEARCH_2D over the
; entire image, but the result is a set of region files.
;
; :Params:
;  threshold_low : in, optional, type = 'float'
;    The low threshold value
;  threshold_high : in, optional, type = 'float'
;    The high threshold value
;
; :Examples::
;    To locate all points in the image with values greater than 50::
;      IDL> kang_obj->threshold, 50
;
;-
PRO Kang::Threshold_Image, threshold_low, threshold_high

IF N_Elements(threshold_low) EQ 0 AND N_Elements(threshold_high) EQ 0 THEN BEGIN
    IF self.realized THEN BEGIN
        thresholds = Kang_Textbox(Title='Image Threshold', Group_Leader=self.tlbID, $
                                       Label=['Low Threshold: ', 'High Threshold'], Cancel=cancelled, XSize=100, Value='')
        IF StrCompress(thresholds[0], /Remove_All) EQ '' THEN RETURN
        threshold_low = thresholds[0]
        threshold_high = thresholds[1]
    ENDIF ELSE BEGIN
        print, 'You must specify the thresholds.'
        RETURN
    ENDELSE
ENDIF

; Create regions
Widget_Control, self.tlbID, Hourglass=1 ; This may take a while
region = self.image->Threshold_Image(threshold_low, threshold_high, Invert = self.threshold_invert[self.whichImage], $
                                     cname = self.regions_cname, color = self.regions_color, interior = ~self.regions_include, linestyle = self.regions_linestyle, $
                                     thick = self.regions_width)
Widget_Control, self.tlbID, Hourglass=0
        
; This is if it didn't work out.
IF size(region, /TName) NE 'OBJREF' THEN BEGIN
    print, "ERROR: Thresholding the image didn't work out. Sorry."
    RETURN
ENDIF
self.regions->Add, region

; Update the regions widget, replot
self->Update_Regions_Info, /List_Update
self->Draw

END; Kang::Threshold_Image-------------------------------------------------


;--------------------------------------------------
;               Region Methods
;--------------------------------------------------
;+
; Copy selected regions to clipboard.
;
;-
PRO Kang::Copy

self.regions->GetProperty, selected_regions = selected_regions

; Delete old array of pointers
IF Ptr_Valid(self.copied_regions) THEN BEGIN
    n_copied = N_Elements(*self.copied_regions)
    FOR i = 0, n_copied-1 DO Ptr_Free, (*self.copied_regions)[i]
    Ptr_Free, self.copied_regions
ENDIF
IF selected_regions[0] EQ -1 THEN RETURN

; Create a new array of pointers. 
n_selected = N_Elements(selected_regions)
self.copied_regions = Ptr_New(PtrArr(n_selected))

; Fill up pointer array of structures
regions = self.regions->Get()
FOR i = 0, n_selected-1 DO BEGIN
    regions[i]->GetProperty, regiontype = regiontype, params = params, cname = color, thick = width, linestyle = linestyle, $
      source = source, interior = exclude, polygon = polygon, coords = coords

    IF StrUpCase(regiontype) EQ 'THRESHOLD' THEN BEGIN
        foo = self->Threshold_to_Polygon(regions[i], data = data)
        params = reform(data, N_Elements(data))
        regiontype = 'Polygon'
    ENDIF
    (*self.copied_regions)[i] = Ptr_New({regiontype:regiontype, params:params, coords:coords, color:color, width:width, $
                                         linestyle:linestyle, source:source, include:~exclude, polygon:polygon})
ENDFOR

END; Kang::Copy--------------------------------------------------


;+
; Copies selected regions to clipboard and deletes them from current display.
;
;-
PRO Kang::Cut

self->Copy
self->Delete_Region

END; Kang::Cut--------------------------------------------------


;+
; Pastes regions on clipboard into current display.
;
;-
PRO Kang::Paste

IF Ptr_Valid(self.copied_regions) THEN BEGIN

; Loop over all copied regions
    n_copied = N_Elements(*self.copied_regions)
    FOR i = 0, n_copied-1 DO BEGIN

; Create the new regions
        self->Make_Region, (*(*self.copied_regions)[i]).regiontype, (*(*self.copied_regions)[i]).params, color = (*(*self.copied_regions)[i]).color, $
                           width = (*(*self.copied_regions)[i]).width, source = (*(*self.copied_regions)[i]).source, $
                           include = (*(*self.copied_regions)[i]).include, polygon = (*(*self.copied_regions)[i]).polygon, $
                           coords = (*(*self.copied_regions)[i]).coords, /noplot
    ENDFOR
ENDIF

;Update regions widget
self.regions->GetProperty, n_regions = n_regions
self->Select, lindgen(n_copied) + (n_regions-n_copied)
self->Update_Regions_Info, /List_Update
self->Draw
END; Kang::Paste--------------------------------------------------


;+
; Combines all selected regions into a single composite region.
;
;-
PRO Kang::Combine

self.regions->Combine
self->Draw
self->Update_Regions_Info, /List_Update
END; Kang::Combine_Regions--------------------------------------------------


;+
; Dissolves a composite region into its constituent regions.
;
;-
PRO Kang::Dissolve

self.regions->Dissolve
self->Draw
self->Update_Regions_Info, /List_Update
END; Kang::Dissolve_Regions--------------------------------------------------


;+
; Determines which regions contain the specified points.
;
; :Returns:
;   A boolean array that has one element for each loaded region.  This
;   is 0 is the point is not inside the region and 1 if it is.
;
; :Params:
;  x : in, required, type = 'float'
;    The x position to test in data units
;  y : in, required, type = 'float'
;    The y position to test in data units
;
; :Keywords:
;  coords : in, optional, type = 'string'
;    A string representing the coordinate system the x and y position is in.
;    If unspecified, x and y are assumed to be in the current coordinate system.
;  count : out, optional, type = 'integer'
;    The number of regions that contain the specified point.
;
; :Examples:
;    To locate which regions intersect with the point (l, b) = (32.4,
;    -0.5)::
;      IDL> hits = kang_obj->Contains_Points(32.5, -0.5)
;
;    To do the same, but for an image that is displayed in J2000
;    coordinates::
;      IDL> hits = kang_obj->Contains_Points(32.5, -0.5, coords = 'Galactic')
;
;-
FUNCTION Kang::Contains_Points, x, y, coords = coords, Count = count
  
; Convert coords - will use native coordinates by default
IF N_Elements(coords) EQ 0 THEN self.image->GetProperty, current_coords = coords
data = self.image->Convert_Coord(x, y, old_coords = coords, new_coords = 'Image')

; Find which regions it hits
hits =  self.regions->Contains_Points(data[0, *], data[1, *], count = count)

RETURN, hits
END; Kang::Contains_Points--------------------------------------------------


;+
; Deletes regions.
;
; :Params:
;  whichregion : in, optional, type = 'integer array'
;    The regions to delete specified as an integer array
;
; :Keywords:
;  all : in, optional, type = 'boolean'
;    Set this keyword to delete all the regions
;  noplot: in, optional, type = 'boolean'
;    If set, display will not be updated
;
;-
PRO Kang::Delete_Region, whichRegion, All = all, noplot = noplot

IF ~Obj_Valid(self.regions) THEN RETURN
self.regions->Delete, position = whichRegion, All = all, /Destroy

; Update, replot
IF ~Keyword_Set(noplot) THEN self->Draw
self->Update_Regions_Info, /List_Update

END; Kang::Delete_Region--------------------------------------------------


;+
; Returns the region stats in a structure for all currently selected
; regions.  This is very useful for photometry measurements.
;
; :Returns:
;  A structure with the following tags:
;   AREA            FLOAT
;   CENTROID        FLOAT[2]
;   PERIMETER       FLOAT
;   NPIX            LONG
;   MAX             FLOAT
;   MIN             FLOAT
;   MEAN            FLOAT
;   STDDEV          FLOAT
;   TOTAL           FLOAT
;
;  The dimensions of these tages are given by the number of selected
;  regions.
;
; :Examples:
;   To find the statistics for all selected regions::
;      IDL> stats = kang_obj->Get_Stats()
;
;-
FUNCTION Kang::Get_Stats

RETURN, self.regions->Get_Stats()
END; Kang::Get_Stats--------------------------------------------------


;+
; Changes the properties of subsequent regions drawn.
;
; :Keywords:
;  background : in, optional, type = 'boolean'
;    Set this keyword for background regions
;  color : in, optional, type = 'string'
;    Set to a color string specified in colors.txt
;  include : in, optional, type = 'boolean'
;    Set this keyword for included regions
;  exclude : in, optional, type = 'boolean'
;    Set this keyword for excluded regions
;  linepar : in, optional, type = 'boolean'
;    Set this keyword for line regions where interior pixels are not
;    counted in region statistics
;  linestyle : in, optional, type = 'integer (0-5)'
;    Set to desired linestyle
;  polygon : in, optional, type = 'boolean'
;    Set this keyword for polygon regions where interior pixels are
;    counted in region statistics
;  regionType : in, optional, type = 'string'
;    Set to have future regions drawn as this region type
;  source : in, optional, type = 'boolean'
;    Set this keyword for source regions
;  width : in, optional, type = 'integer (1-10)'
;    Set to desired display width
;
;-
PRO Kang::Global_Region_Property, $
  background = background, $
  color = colorName, $
  include = include, $
  exclude = exclude, $
  linepar = line, $
  linestyle = linestyle, $
  polygon = polygon, $
  regionType = regionType, $
  source = source, $
  width = width

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
ENDIF

IF N_Elements(regionType) NE 0 THEN BEGIN
    IF self.realized THEN BEGIN
; Turn checkmark off on all buttons
        Widget_Control, self.BoxID, Set_Button=0
        Widget_Control, self.CircleID, Set_Button=0
        Widget_Control, self.EllipseID, Set_Button=0
        Widget_Control, self.CrossID, Set_Button=0
        Widget_Control, self.ThresholdID, Set_Button=0
        Widget_Control, self.TextID, Set_Button=0
        Widget_Control, self.LineID, Set_Button=0
        Widget_Control, self.FreehandID, Set_Button=0
;        Widget_Control, self.PolygonID, Set_Button=0

        CASE STrUpCase(regionType) OF 
; Set region type checkmark accordingly
            'BOX': Widget_Control, self.BoxID, Set_Button=1
            'CIRCLE': Widget_Control, self.CircleID, Set_Button=1
            'ELLIPSE': Widget_Control, self.EllipseID, Set_Button=1
            'CROSS': Widget_Control, self.CrossID, Set_Button=1
            'THRESHOLD': Widget_Control, self.ThresholdID, Set_Button=1
            'TEXT': Widget_Control, self.TextID, Set_Button=1
            'LINE': Widget_Control, self.LineID, Set_Button=1
            'FREEHAND': Widget_Control, self.FreehandID, Set_Button=1
            ELSE: RETURN
        ENDCASE
    ENDIF

; Set region type value
    self.regionType = CapFirstLetter(regionType)
ENDIF

; Change color of selected regions
IF N_Elements(colorName) NE 0 THEN BEGIN
; Bring up dialog
    IF colorName EQ 1B THEN colorName = pickColorName(self.regions_cName, group_leader = self.tlbID, filename = 'colors.txt')
    self.regions_color = self.colors->ColorIndex(colorName)
    self.regions_cName = colorName
ENDIF

; Include and exclude
IF Keyword_Set(include) THEN BEGIN
    self.regions_include = 1B
    IF self.realized THEN BEGIN
        Widget_Control, self.includeID, Set_Button = 1B
        Widget_Control, self.excludeID, Set_Button = 0B
    ENDIF
ENDIF
IF Keyword_Set(exclude) THEN BEGIN
    self.regions_include = 0B
    IF self.realized THEN BEGIN
        Widget_Control, self.includeID, Set_Button = 0B
        Widget_Control, self.excludeID, Set_Button = 1B
    ENDIF
ENDIF

; Source and background
IF Keyword_Set(source) THEN BEGIN
    self.regions_source = 1B
   IF self.realized THEN BEGIN
       Widget_Control, self.sourceID, Set_Button = 1B
       Widget_Control, self.backgroundID, Set_Button = 0B
   ENDIF
ENDIF
IF Keyword_Set(background) THEN BEGIN
    self.regions_source = 0B
    IF self.realized THEN BEGIN
        Widget_Control, self.backgroundID, Set_Button = 1B
        Widget_Control, self.sourceID, Set_Button = 0B
    ENDIF
ENDIF

; Polygon and line
IF Keyword_Set(polygon) THEN BEGIN
    self.regions_polygon = 1B
    Widget_Control, self.polygonparID, Set_Button = 1B
    Widget_Control, self.lineparID, Set_Button = 0B
ENDIF
IF Keyword_Set(line) THEN BEGIN
    self.regions_polygon = 0B
    IF self.realized THEN BEGIN
        Widget_Control, self.polygonparID, Set_Button = 0B
        Widget_Control, self.lineparID, Set_Button = 1B
    ENDIF
ENDIF

; Width
IF N_Elements(width) NE 0 THEN BEGIN
    self.regions_width = 1 > Round(width) < 10
        
; Turn on correct checkmark
    IF self.realized THEN BEGIN
        FOR i = 0, 9 DO  Widget_Control, self.widthIDs[i], Set_Button=0
        Widget_Control, self.widthIDs[Round(width)-1], Set_Button=1
    ENDIF
ENDIF

; Linestyle
IF N_Elements(linestyle) NE 0 THEN BEGIN
    self.regions_linestyle = 0 > Round(linestyle) < 5
        
; Turn on correct checkmark
    IF self.realized THEN BEGIN
        FOR i = 0, 5 DO  Widget_Control, self.linestyleIDs[i], Set_Button=0
        Widget_Control, self.linestyleIDs[Round(linestyle)], Set_Button=1
    ENDIF
ENDIF

END; Kang::Global_Region_Property--------------------------------------------------


;+
; Loads the regions from the specified file.
;
; :Params:
;  filename : in, optional, type = 'string'
;    Region file to load.  If not present, a dialog will be brought up.
;
; :Keywords:
;  n_regions : out, optional, type = 'integer'
;    The number of regions in the loaded file.
;  noplot : in, optional, type = 'boolean'
;    Set to not plot after creating - faster
;  nostats : in, optional, type = 'boolean'
;    Set this keyword to prevent the program from computing statistics
;    for each region, which can be very slow for large regions.
;
;-
PRO Kang::Load_Regions, filename, n_regions = n_regions, nostats = nostats, noplot = noplot
; This routine parses the region text into region objects when a
; region file is loaded

; Bring up dialog if needed
IF N_Elements(filename) EQ 0 THEN BEGIN
    filename = Dialog_pickfile(Filter='*.reg', /Must_Exist, $
                               Title='Please Select a Region File to Load', $
                               Get_Path=thispath, Path=self.last_regionpath, $
                               dialog_parent = self.tlbID) 
    self.last_regionpath = thispath
ENDIF
IF filename EQ '' THEN RETURN

; Load regions
self.regions->Load, filename, self.colors, nostats = nostats

; Update the regions widget
IF ~Keyword_Set(noplot) THEN self->Draw
self->Update_Regions_Info, /List_Update

END; Kang::Load_Regions-----------------------------------------


;+
; Creates a region for current image.
;
; :Params:
;  regiontype : in, required, type = 'string'
;    The type of region to create.
;  params : in, required, type = 'float array'
;    The parameters for the region.  The parameters are exactly the same as
;    they appear in the region file.  For example, the parameters for
;    a circular region would be [xcenter, ycenter, radius].
;
; :Keywords:
;  angle : in, optional, type = 'float'
;    The rotation angle of the created region.  Can also be specified
;    as the last value of the params keyword.
;  background : in, optional, type = 'boolean'
;    Set this keyword for background regions
;  color : in, optional, type = 'string'
;    Set to a color string specified in colors.txt
;  coords : in, optional, type = 'string'
;    The coordinate system to use.
;  data : out, optional, type = 'float array'
;    Set to a variable to contain the 2D array of positions to use
;    when creating the region.
;  include : in, optional, type = 'boolean'
;    Set this keyword for included regions
;  exclude : in, optional, type = 'boolean'
;    Set this keyword for excluded regions
;  line : in, optional, type = 'boolean'
;    Set this keyword for line regions where interior pixels are not
;    counted in region statistics
;  linestyle : in, optional, type = 'integer'
;    Set to desired linestyle
;  noobject : in, optional, type = 'boolean'
;    Set to not create the object reference.  Only useful when the
;    data keyword is also used.
;  noplot : in, optional, type = 'boolean'
;    Set to not plot after creating - faster
;  nostats : in, optional, type = 'boolean'
;    Set to disable statistics for the region - much faster for large images
;  polygon : in, optional, type = 'boolean'
;    Set this keyword for polygon regions where interior pixels are
;    counted in region statistics
;  replace : in, optional, type = 'boolean'
;    Set this keyword to replace last selected region with the region
;    being created.
;  source : in, optional, type = 'boolean'
;    Set this keyword for source regions
;  text : in, optional, type = 'string'
;    The text associated with the region.  Required for tex regions.
;  width : in, optional, type = 'integer'
;    Set to desired display width
;
; :Examples:
;    To create a circular region centered at (l, b) = (45.5, 0.1) of
;    radius 0.4 degrees::
;      IDL> kang_obj->Make_Region, 'Circle', [45.5, 0.1, 0.4]
;
;    To do the same, but made with width greater and make it a
;    background region::
;      IDL> kang_obj->Make_Region, 'Circle', [45.5, 0.1, 0.4], width =  2, /background
;
;-
PRO Kang::Make_Region, $
  regiontype, $
  params, $
  angle = angle, $
  background = background, $
  coords = coords, $
  color = color, $
  data = data, $
  exclude = exclude, $
  include = include, $
  linestyle = linestyle, $
  line = line, $
  noobject = noobject, $
  noplot = noplot, $
  nostats = nostats, $
  polygon = polygon, $
  replace = replace, $
  source = source, $
  text = text, $
  width = width

IF N_Params() NE 2 THEN BEGIN
    Print, 'Error: Must specify region type and params: objref->Make_Region, "Circle, [x_center, y_center, radius]".'
    RETURN
ENDIF

Widget_Control, Hourglass=1     ; This may take some time

n_par = N_Elements(params)
IF N_Elements(coords) EQ 0 THEN self.image->GetProperty, current_coords = coords
IF ~Keyword_Set(source) AND ~Keyword_Set(background) THEN source = 1B
IF N_Elements(background) NE 0 THEN source = ~background    
IF N_Elements(color) EQ 0 THEN color = self.regions_color ELSE BEGIN
    cname = color
    color = self.colors->ColorIndex(cname)
ENDELSE
IF ~Keyword_Set(include) AND ~Keyword_Set(exclude) THEN include = self.regions_include
IF N_Elements(exclude) NE 0 THEN include = ~exclude
IF ~Keyword_Set(polygon) AND ~Keyword_Set(line) THEN polygon = self.regions_polygon
IF N_Elements(line) NE 0 THEN polygon = ~line
IF N_Elements(linestyle) EQ 0 THEN linestyle = self.regions_linestyle
IF N_Elements(width) EQ 0 THEN width = self.regions_width
IF N_Elements(text) EQ 0 THEN text = ''

CASE StrUpCase(regiontype) OF
    'BOX': BEGIN
        IF n_par EQ 4 THEN IF N_Elements(angle) NE 0 THEN params = [params, angle] ELSE params = [params, 0]
        angle = params[4]
        data = kang_box(params[0], params[1], params[2], params[3], params[4])
    END

    'CIRCLE': BEGIN
        data = Kang_Circle(params[0], params[1], params[2]) 
        angle = 0
    END

    'CROSS':  data = [[params[0]+params[2], params[1]], $
                      [params[0]-params[2], params[1]], $
                      [params[0], params[1]], $
                      [params[0], params[1]+params[2]], $
                      [params[0], params[1]-params[2]], $
                      [params[0], params[1]]]
    'ELLIPSE': BEGIN
        IF n_par EQ 4 THEN IF N_Elements(angle) NE 0 THEN params = [params, angle] ELSE params = [params, 0]
        angle = params[4]
        data = Kang_Ellipse(params[0], params[1], params[2], params[3], params[4])
    END
    'LINE': BEGIN
        data = [[params[0:1]], [params[2:3]]]
        polygon = 0
        angle = 0
    END
    'FREEHAND': data = Reform(params, 2, N_Elements(params)/2.)
    'POLYGON': data = params
    'TEXT': BEGIN
        data = params
        IF n_par EQ 2 THEN IF N_Elements(angle) NE 0 THEN params = [params, angle] ELSE params = [params, 0]
        angle = params[2]
    END
    'THRESHOLD': BEGIN
        data = self.image->Convert_Coord(params[0], params[1], new_coord = 'Image')
        IF ~Keyword_Set(noobject) THEN BEGIN
            obj = self.image->Threshold_Region(data[0], data[1], params[2], params[3], $
                                               color = color, cname = cname, interior = ~include, $
                                               image_obj = self.image, regiontype = 'Threshold', text = text, $
                                               source = source, thick = width, linestyle = linestyle[0], $
                                               polygon = polygon, nostats = nostats)
            IF ~obj_valid(obj) THEN RETURN
        ENDIF
    END
ENDCASE

; Set the region properties
IF StrUpCase(regiontype) NE 'THRESHOLD' THEN BEGIN
; Convert from data to image coordinates if necessary
    IF data[0] EQ -1 THEN RETURN
    data = self.image->Convert_Coord(data[0, *], data[1, *], old_coords = coords, new_coords = 'Image')

; Create object
    IF ~Keyword_Set(noobject) THEN BEGIN
        obj = Obj_New('Kang_Region', data, params = params, $
                      angle = angle, color = color, coords = coords, cname = cname, interior = ~include, $
                      image_obj = self.image, regiontype = regiontype, text = text, source = source, $
                      thick = width, linestyle = linestyle, polygon = polygon, nostats = nostats)
    ENDIF
ENDIF

; Add and select object
IF ~Keyword_Set(noobject) THEN BEGIN
    IF Keyword_Set(replace) THEN self.regions->Replace, obj ELSE BEGIN
        self.regions->Add, obj
        self.regions->Select, /Last
    ENDELSE

; Replot
    IF ~Keyword_Set(noplot) THEN self->Draw
    self->Update_Regions_Info, /List_Update
ENDIF

Widget_Control, Hourglass=0
END; Kang::Make_Region--------------------------------------------------


;+
; Move region and update statistics.
;
; :Params:
;  direction : in, required, type = 'string'
;    The direction [up, down, left or right] to move the region.  I'll
;    probably change this keyword in the future to something more sensible
;
;-
PRO Kang::Move_Region, direction

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

self.regions->GetProperty, selected_regions = selected
IF selected[0] EQ -1 THEN RETURN

; Calculate the size of one pixel on the monitor in data units
self.image->GetProperty, newposition = newposition, pix_newlimits = pix_newlimits
device_range = (newposition[2]-newposition[0]) * self.xsize
pixel_range = Abs(pix_newlimits[1] - pix_newlimits[0])
pixelsize = pixel_range / device_range
CASE direction OF
    'Left': translation = [-pixelsize, 0]
    'Right': translation = [pixelsize, 0]
    'Up': translation = [0, pixelsize]
    'Down': translation = [0, -pixelsize]
ENDCASE

; Move regions
self.regions->Translate, translation

; Update Widget and Replot
self->Draw
self->Update_Regions_Info, /List_Update

END;Kang::Move_Region--------------------------------------------

;+
; Finds overlap between two or more regions
;
; :Keywords:
;  position : in, optional, type = 'integer'
;    Region index to find indices for.  Defaults to current selection.
;
;-
FUNCTION Kang::Overlap, position = position

RETURN, self.regions->Overlap(position = position)
END; Kang::Overlap---------------------------------------------------


;+
; Plots a histogram of the pixel values in the selected regions.
;
; :Keywords:
;  _Extra : in, optional
;    Use this keyword to pass any additional plot keywords to the
;    plothist histogram routine.
;
;-
PRO Kang::Histogram_Region, _Extra = extra
; Plots a histogram of the selected region(s)

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Get info structure out
;eventName = Tag_Names(event, /Structure_Name)
;IF eventName EQ 'KANG_WINDOW_EVENTS' OR $
;  eventName EQ 'WIDGET_BASE' THEN BEGIN
;    Widget_Control, event.top, Get_UValue = tlbID
;ENDIF ELSE tlbID = event.top
self->Plot_Windows_Widget

; Plot a histogram of the image
Wset, self.plot_WID
Widget_Control, self.windows_tabBase, Set_Tab_Current = 2

indices = self.regions->Find_Indices()
self.image->PlotHist, indices, XTitle = 'Pixel Value', YTitle = 'Number', charsize = 1, _Extra = extra
self.plot_window->Update

END; Kang::Histogram_Region--------------------------------------------------------


;+
; Change the property of the selected regions.
;
; :Keywords:
;  background : in, optional, type = 'boolean'
;    Set this keyword for background regions
;  color : in, optional, type = 'string'
;    Set to a color string specified in colors.txt.  If set as /colors
;    then a dialog is brought up.
;  include : in, optional, type = 'boolean'
;    Set this keyword for included regions
;  exclude : in, optional, type = 'boolean'
;    Set this keyword for excluded regions
;  linepar : in, optional, type = 'boolean'
;    Set this keyword for line regions where interior pixels are not
;    counted in region statistics.
;  linestyle : in, optional, type = 'integer'
;    Set to desired linestyle
;  position : in, optional, type = 'integer'
;    An array of region indices to apply these changes to.  Defaults
;    to all selected regions.
;  polygon : in, optional, type = 'boolean'
;    Set this keyword for polygon regions where interior pixels are
;    counted in region statistics
;  source : in, optional, type = 'boolean'
;    Set this keyword for source regions
;  width : in, optional, type = 'integer'
;    Set to desired display width
;
;-
PRO Kang::Region_Property, $
  background = background, $
  color = cname, $
  exclude = exclude, $
  include = include, $
  width = width, $
  linepar = linepar, $
  linestyle = linestyle, $
  name = name, $
  polygon = polygon, $
  position = position, $
  source = source

IF N_Elements(cName) NE 0 THEN BEGIN
; Bring up dialog if needed
    IF size(cName, /tname) NE 'STRING' THEN BEGIN
        IF cName EQ 1 THEN BEGIN
            self.regions->GetProperty, cname = region_cname, position = position
            cName = pickColorName(CapFirstLetter(region_cName), group_leader = self.tlbID, filename = 'colors.txt')
        ENDIF
    ENDIF
    color = self.colors->ColorIndex(cname)
    self.regions->SetProperty, color = color, cname = cname
ENDIF
IF N_Elements(width) NE 0 THEN self.regions->SetProperty, width = width, position = position
IF N_Elements(linestyle) THEN self.regions->SetProperty, linestyle = linestyle, position = position
IF N_Elements(include) NE 0 THEN self.regions->SetProperty, include = include, position = position
IF N_Elements(exclude) NE 0 THEN self.regions->SetProperty, exclude = exclude, position = position
IF N_Elements(source) NE 0 THEN self.regions->SetProperty, source = source, position = position
IF N_Elements(background) NE 0 THEN self.regions->SetProperty, background = background, position = position
IF N_Elements(name) NE 0 THEN self.regions->SetProperty, name = name, position = position
IF N_Elements(linepar) NE 0 THEN self.regions->SetProperty, polygon = ~linepar, position = position
IF N_Elements(polygon) NE 0 THEN self.regions->SetProperty, polygon = polygon, position = position

;'Threshold High': BEGIN
;    Widget_Control, tlbID, Set_UValue=info, /No_Copy
;    Kang_Threshold_events,  event
;END

;'Threshold Low': BEGIN
;    Widget_Control, tlbID, Set_UValue=info, /No_Copy
;    Kang_Threshold_events,  event
;END


;    'Invert': BEGIN
;        info.threshold_invert[whichplot_params] = event.select
;        Widget_Control, tlbID, Set_UValue=info, /No_Copy
;    END

self->Update_Regions_Info, /List_Update
self->Draw

END; Kang::Region_Property--------------------------------------------------


;+
; Rotates currently selected regions to specified angle in degrees.
;
; :Params:
;  angle : in, required, type = 'float'
;    The new angle to rotate to in degrees.
;
;-
PRO Kang::Rotate_Region, angle

self.regions->Rotate, angle
self->Update_Regions_Info, /List_Update
self->Draw

END; Kang::Rotate_Region--------------------------------------------------

;+
; Changes the size of the region.  This routine seems to break
; spectacularly for some reason.
;
; :Private:
;
;-
PRO Kang::Scale_Region, scale

self.regions->Scale, scale
END; Kang::Scale_Region---------------------------------------------------


;+
; Saves a mask of the regions to file such that values inside the
; regions are 1 and values outside the regions are 0.  The mask may
; thus be multiplied by the original image to include only pixels of
; interest.  All regions marked as excluded appear as "holes" with
; value 0.  This only applies to excluded regions in front of included
; regions in the region list.  Included regions in front of excluded
; regions will have a value of 1 in the mask.
;
; :Params:
;  filename : in, optional, type = 'string'
;    The name of the output FITS file.  If not present, a dialog will
;    be brought up so the user can type a filename.
;
; :Keywords:
;  weighted : in, optional, private, type = 'integer'
;    If set, the mask values will be weighted by the fraction of each pixel that
;    the region lies inside.
;
;-
PRO Kang::Save_Mask, filename, weighted = weighted

; Bring up dialog if no filename was passed
IF N_Elements(filename) EQ 0 THEN BEGIN
    filter = ['*.fits; *.fit; *.FIT; *.FITS']
    filename = Dialog_pickfile(Filter=filter, Title='Please Type a Mask File Name', $
                               Get_Path=thispath, Path=self.last_regionpath, Dialog_Parent = self.tlbID, $
                               /Overwrite_Prompt, /Write) 
ENDIF
IF filename EQ '' THEN RETURN

; Write fits
;IF ~File_Test(filename, /Write) THEN BEGIN
;    print, 'ERROR: File ' + filename + ' cannot be written.'
;    RETURN
;ENDIF

; Make a mask the size of the original image
self.image->GetProperty, pix_limits = pix_limits, header = header
self.regions->GetProperty, n_regions = n_regions
IF n_regions GT 0 THEN mask = self.regions->ComputeMask(position = lindgen(n_regions), weighted = weighted) ELSE $
  mask = bytarr(pix_limits[1]+1, pix_limits[3]+1)
mask = mask / 255B              ; Scale to 0 to 1
writeFits, filename, mask, header
print, 'Wrote file ' + filename + '.'

END; Kang::Save_Mask--------------------------------------------------


;+
; Writes the regions to file.
; 
; :Params:
;  filename : in, optional, type = 'string'
;    The name of the output file. If not present, a dialog will be
;    brought up so the user can type a filename.
;
;-
PRO Kang::Save_Regions, filename

IF N_Elements(filename) EQ 0 THEN BEGIN
    filename = Dialog_pickfile(Filter='*.reg', Title='Please Type a Region File Name', $
                               Get_Path=thispath, Path=self.last_regionpath, Dialog_Parent = self.tlbID, $
                               /Overwrite_Prompt, /Write) 
ENDIF
IF filename EQ '' THEN RETURN

self.regions->Save, filename

END; Kang::Save_Regions--------------------------------------------------


;+
; Selects regions based on supplied criteria.
;
; :Params:
;  positions : in, optional, type = 'integer'
;    An array of region indices to select.
;
; :Keywords:
;  Add : in, optional, type = 'boolean'
;    Set this to add new selection to old selection.
;  All : in, optional, type = 'boolean'
;    Set this keyword to select all regions
;  Background : in, optional, type = 'boolean'
;    Set this keyword to select background regions
;  Exclude : in, optional, type = 'boolean'
;    Set this keyword to select excluded regions
;  Include : in, optional, type = 'boolean'
;    Set this keyword to select included regions
;  Invert : in, optional, type = 'boolean'
;    Set this keyword to invert the current selection
;  Last : in, optional, type = 'boolean'
;    Set this keyword to select the last region in the region list
;  N_Selected : out, optional, type = 'boolean'
;    The number of regions selected
;  None : in, optional, type = 'boolean'
;    Set this keyword to de-select all regions
;  Selected : out, optional, type = 'boolean'
;    An array of the region indices that are selected
;  Source : in, optional, type = 'boolean'
;    Set this keyword to select source regions
;
; :Examples:
;    To select all source regions::
;      IDL> kang_obj->Select, /Source
;
;    To invert this selection::
;      IDL> kang_obj->Select, /Invert
;
;    To select regions 0:20::
;      IDL> kang_obj->Select, lindgen(21)
;
;    To select all regions::
;      IDL> kang_obj->Select, /All
;
;-
PRO Kang::Select, $
  positions, $
  All = all, $
  Add = add, $
  Background = background, $
  Exclude = exclude, $
  Include = include, $
  Invert = invert, $
  Last = last, $
  None = none, $
  Source = source, $
  Selected = selected, $
  n_selected = n_selected           

self.regions->Select, positions, Add = add, All = all, Include = include, Exclude = exclude, invert = invert, none = none, $
  source = source, background = background, Last = last

; Return selected region indices if requested
self.regions->GetProperty, selected_regions = selected
n_selected = N_Elements(selected)
IF selected[0] EQ -1 THEN n_selected = 0

; Update, replot
self->Draw
self->Update_Regions_Info, /List_Update

; Store the device coordinates of the small region boxes
self->RegionBoxes

END; Kang::Select--------------------------------------------------


;+
;
; :Private:
;
;-
PRO Kang::Select_Profile_Region;, whichRegion

self->Profile_Widget

; Store region
self.regions->GetProperty, selected_regions = selected_regions
oregion = self.regions->Get(position = selected_regions)
self.profile_region = oregion[0]

; Set sensitivity of fit button back
IF XRegistered('Kang_Profile' + StrTrim(self.tlbID, 2)) THEN BEGIN
    Widget_Control, self.profile_WidgetID, Get_UValue = uval
    Widget_Control, uval.fitID, Sensitive=1 

; Draw image
    WSet, uval.data_wid
;self.image->Draw, [xrange[0]>0:xrange[1]<pix_limits[1], yrange[0]>0:yrange[1] < pix_limits[3], /noaxis, /nobar

; Erase other windows
    WSet, uval.model_wid
    Erase
    WSet, uval.residual_wid
    Erase
ENDIF

END; Kang::Select_Profile_Region------------------------------------------------------------


;+
;
; :Private:
;
;-
FUNCTION Kang::Threshold_to_Polygon, obj, data = data

IF Obj_Class(obj) EQ 'KANG_REGIONGROUP' THEN BEGIN

; Cycle through regions
    count = obj->count()
    FOR j = 0, count-1 DO BEGIN
        newobj = obj->Get(position=j)
        newobj->Getproperty, data=data, interior = interior
        data = self.image->Convert_Coord(data[0, *], data[1, *], old_coord = 'Image') 
        IF interior THEN text = '-Polygon(' + StrCompress(StrJoin(data, ',', /Single)) + ')' ELSE $
          text = 'Polygon(' + StrCompress(StrJoin(data, ',', /Single)) + ')'
    ENDFOR
ENDIF ELSE BEGIN
                            
; Threshold region, no holes
    obj->GetProperty, data = data, interior = interior
    data = self.image->Convert_Coord(data[0, *], data[1, *], old_coord = 'Image') 
    IF interior THEN text = '-Polygon(' + StrCompress(StrJoin(data, ',', /Single)) + ')' ELSE $
      text = 'Polygon(' + StrCompress(StrJoin(data, ',', /Single)) + ')'
ENDELSE

RETURN, text
END; Kang::Threshold_to_Polygon------------------------------------------------------------


;+
;
; :Private:
;
;-
PRO Kang::Write_Region, filename

; Bring up dialog if needed
IF N_Elements(filename) EQ 0 THEN BEGIN
    filename = Dialog_pickfile(Title='Please Select an Output Filename', $
                               Get_Path=thispath, Path=self.last_regionpath, $
                               Dialog_Parent = self.tlbID, /Write, $
                               /Overwrite_Prompt)
    self.last_regionpath = thispath
ENDIF
IF filename EQ '' THEN RETURN

self.region_container->GetProperty, n_regions = n_regions

; Get stats for each region individually
openw, lun, 'fits2.cat', /Get_Lun
printf, lun, 'Filename        XCenter', '        YCenter', '        NPix', '           Area', '      Perimeter', '            Min', $
        '            Max', '           Mean', '         StdDev', '          Total', format = '(A, A, A, A, A, A, A, A, A, A)'
FOR i = 0 ,n_regions-1 DO BEGIN
    self.region_container->GetProperty, stats=stats, position = i
    printf, lun, stats.centroid[0], stats.centroid[1], stats.npix, stats.area, stats.perimeter, $
            stats.min, stats.max, stats.mean, stats.stddev, stats.total, format = '(F, F, I, F, F, F, F, F, F, F)'
ENDFOR
free_lun, lun

END; Kang::Write_Region--------------------------------------------------


;+
; Zoom display into the selected region(s)
;
;-
PRO Kang::Zoom_Region

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF

; Get the data out
self.regions->GetProperty, xrange = xrange, yrange = yrange

; Store the values for pixel limits
pix_newlimits = fltarr(4)
pix_newlimits[0] = (min(xrange)-1)
pix_newlimits[1] = (max(xrange)+1)
pix_newlimits[2] = (min(yrange)-1)
pix_newlimits[3] = (max(yrange)+1)
self.image->Limits, pix_newlimits, /Pixel

; Replot
self->Draw
END; Kang::Zoom_Region----------------------------------


;--------------------------------------------------------------------------------
;                   Widget definition methods
;--------------------------------------------------------------------------------
;+
; Brings up the file dialog widget
;
; :Private:
;
;-
PRO Kang::File_Dialog_Widget

On_Error, 2  ; Return to the Caller

; Get the info structure out of the top tlb
whichImage = self.whichImage > 0

; Find the filenames
self->GetProperty, filenames = filenames

;  Bring up new dialog if not already on screen
IF XRegistered('File Dialog '+StrTrim(self.tlbID, 2)) THEN RETURN

tlb = Widget_Base(Column=1, /TLB_Size_Events, Title='File Dialog', UValue = self, $
                  MBar=menubarID, /Base_Align_Center, tlb_frame_attr=1)
subbase = Widget_Base(tlb, Column=8, Frame=1)

; Delete buttons
delete_uvalues = 'del_'+StrCompress(IndGen(self.n_images), /Remove_All)
self.deleteID=CW_BGroup(subbase, StrArr(self.n_images), /column, /NonEXCLUSIVE, LABEL_TOP='D', $
                   /FRAME, ypad=6, space=14, Button_UValue=delete_uvalues, /No_Release)

; Filenames
textbase = Widget_Base(subbase, Column=2, Frame=1)
self.filenameID = strArr(self.n_images)
label = Widget_Label(textbase, Value = '  ', scr_ysize = 18)
FOR i = 0, self.n_images-1 DO label = Widget_Label(textbase, Value = StrTrim(i, 2), scr_ysize = 31)
label=Widget_Label(textbase, Value='Loaded Files')
FOR i = 0, self.n_images-1 DO self.filenameID[i] = Widget_Text(textbase, XSize = 40) 
FOR i = 0, N_Elements(filenames)-1 DO Widget_Control, self.filenameID[i], Set_Value=filenames[i]

; Define the plot toggles and the plot parameters buttons. The Plot
; toggles have uvalues specified so they can be identified.
plot_uvalues = 'plot'+StrCompress(IndGen(self.n_images), /Remove_All)
self.plotID=CW_BGroup(subbase, StrArr(self.n_images), /column, /EXCLUSIVE, LABEL_TOP='P', $
                    /FRAME, ypad=6, space=14, Button_UValue=plot_uvalues, /No_Release, Set_Value=whichImage)
; Define the contour toggles and the contour parameter buttons
contour_uvalues = 'contour'+StrCompress(IndGen(self.n_images), /Remove_All)
self.contourID=CW_BGroup(subbase, StrArr(self.n_images), /column, /NONEXCLUSIVE, LABEL_TOP='C', $
                       FRAME=1,ypad=6, space=14, Button_UValue=contour_uvalues, Set_Value=self.whichcontours)

; Center the program on the display
centertlb, tlb
        
; Realize top-level base and all of its children.
IF !D.Name NE 'PS' THEN Widget_Control, tlb, /Realize
    
XManager, 'File Dialog '+StrTrim(self.tlbID, 2), tlb, /No_Block, Event_Handler = 'Kang_File_Dialog_Events', Group_Leader=self.tlbID

END; Kang::File_Dialog_Widget------------------------------------


;+
; Brings up the plot parameters widget
;
; :Private:
;
;-
PRO Kang::Plot_Params_Widget

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Get the info structure out of the top tlb
IF ~self.realized THEN RETURN
IF self->plot_params_realized() THEN RETURN

; Define Top Level Base
tlb = Widget_Base(Row=2, MBar=menubarID, /Base_Align_Top, Event_Pro = 'Kang_Plot_Params_Events', $
                  Title='Plot Parameters', tlb_frame_attr=1, /Base_Align_Center, UValue = self)
tabBase = Widget_Tab(tlb, Location=0, UValue = 'Tab', Event_Pro = 'Kang_Plot_Params_Events')

; Get the required objects
histogram = self.histogram
image = self.image
regions = self.regions

;----------------------------------------------------------------------
;                               Scale
;----------------------------------------------------------------------
scalebase=Widget_Base(tabBase, Title='   Scale   ', Column=1, Frame=1)
topscalebase = Widget_Base(scaleBase, Row = 3)

HLScaleBase = Widget_Base(topscaleBase, Row = 1)
histogram->GetProperty, lowScale=lowScale, highScale=highScale
self.lowScaleID = FSC_InputField(HLScaleBase, Value=lowScale, Title='Low Scale', /CR_Only, $
                                 /Float, /Return_Events, UValue = 'Low Scale', Event_Pro = 'Kang_Plot_Params_Events')
self.highScaleID = FSC_InputField(HLScaleBase, Value=highScale, Title='High Scale', /CR_Only, $
                                  /Float, /Return_Events, UValue = 'High Scale', Event_Pro = 'Kang_Plot_Params_Events')

hist_values = ['99.99%', '99.9%', '99%', '98%', '95%']
bigpercentBase = Widget_Base(topscaleBase, Row = 1)
percentBase = Widget_Base(bigPercentBase, /Row, /Exclusive)
button = Widget_Button(percentBase, Value = hist_Values[0], UValue = hist_values[0])
button = Widget_Button(percentBase, Value = hist_Values[1], UValue = hist_values[1])
button = Widget_Button(percentBase, Value = hist_Values[2], UValue = hist_values[2])
button = Widget_Button(percentBase, Value = hist_Values[3], UValue = hist_values[3])
self.percentSliderID = CW_FSlider(bigpercentbase, xsize = 200, minimum = 100, maximum = 90, $
                                  /Drag, /Edit, format = '(F7.3)', UValue = 'Percent Slider')

butbase = Widget_Base(topscaleBase, Row = 1)
self.histzoomID = Widget_Button(butBase, Value = '    Zoom    ', UValue = 'Zoom')
self.histunzoomID = Widget_Button(butBase, Value = '   Unzoom   ', UValue = 'Unzoom')
histogram->GetProperty, log = log, autoupdate = autoupdate

IF log THEN value = ' Linear Axis ' ELSE value = '  Log Axis  '
self.histlogID = Widget_Button(butBase, Value=value, UValue = 'Log Axis')
self.scaletoimageID = Widget_Button(butBase, Value = 'Scale to Image', UValue = 'Scale to Image')

autoUpdateBase = Widget_Base(butBase, /NonExclusive)
self.autoUpdateID = Widget_Button(autoUpdateBase, Value = 'Auto Update', UValue = 'Auto Update')
Widget_Control, self.autoUpdateID, Set_Button = autoUpdate

xsize = 500
ysize = 350
self.histogram_drawID = Widget_Draw(scalebase, xsize=xsize, ysize=ysize, Button_Events=1, $
                                    Event_Pro='Kang_Histogram_Object_Events', UValue = self.histogram)
Window, /Free, /Pixmap, xsize = xsize, ysize = ysize
self.histogram_pix_WID = !D.Window

;----------------------------------------------------------------------
;                              Limits
;----------------------------------------------------------------------
imagebase=Widget_Base(tabBase, Title='   Limits   ', Frame=1, Column=2)
limitsbase = Widget_Base(imagebase, Column=1, Frame=1)
pix_limitsbase = Widget_Base(imagebase, Column=1, Frame=1)
image->GetProperty, newlimits = newlimits, pix_newlimits = pix_newlimits

label=Widget_Label(limitsbase, /Align_Center, Value='Coordinate Limits')
self.xminID = FSC_InputField(limitsbase, Value=newlimits[0] < newlimits[1], Event_Pro = 'Kang_Plot_Params_Events', $
                             Title='X Min:', LabelSize=60, /FloatValue, /CR_Only, UValue = 'Limits')
self.xmaxID = FSC_InputField(limitsbase, Value=newlimits[1] > newlimits[0], Event_Pro = 'Kang_Plot_Params_Events', $
                             Title='X Max:', LabelSize=60,/FloatValue, /CR_Only, UValue = 'Limits')
self.yminID = FSC_InputField(limitsbase, Value=newlimits[2] < newlimits[3], Event_Pro = 'Kang_Plot_Params_Events', $
                             Title='Y Min:', LabelSize=60,/FloatValue, /CR_Only, UValue = 'Limits')
self.ymaxID = FSC_InputField(limitsbase, Value=newlimits[3] > newlimits[2], Event_Pro = 'Kang_Plot_Params_Events', $
                             Title='Y Max:', LabelSize=60,/FloatValue, /CR_Only, UValue = 'Limits')
limits_arr = [self.xminID, self.xmaxID, self.yminID, self.ymaxID]
self.xminID->SetProperty, UValue = limits_arr
self.xmaxID->SetProperty, UValue = limits_arr
self.yminID->SetProperty, UValue = limits_arr
self.ymaxID->SetProperty, UValue = limits_arr

label=Widget_Label(pix_limitsbase, /Align_Center, Value='Pixel Limits')
self.pix_xminID = FSC_InputField(pix_limitsbase, Value=pix_newlimits[0] < pix_newlimits[1], $
                                 Title='X Min:', LabelSize=60, /FloatValue, /CR_Only, UValue = 'Pix Limits', $
                                 Event_Pro = 'Kang_Plot_Params_Events')
self.pix_xmaxID = FSC_InputField(pix_limitsbase, Value=pix_newlimits[1] > pix_newlimits[0], $
                                 Title='X Max:', LabelSize=60,/FloatValue, /CR_Only, UValue = 'Pix Limits', $
                                 Event_Pro = 'Kang_Plot_Params_Events')
self.pix_yminID = FSC_InputField(pix_limitsbase, Value=pix_newlimits[2] < pix_newlimits[3], $
                                 Title='Y Min:', LabelSize=60,/FloatValue, /CR_Only, UValue = 'Pix Limits', $
                                 Event_Pro = 'Kang_Plot_Params_Events')
self.pix_ymaxID = FSC_InputField(pix_limitsbase, Value=pix_newlimits[3] > pix_newlimits[2], $
                                 Title='Y Max:', LabelSize=60,/FloatValue, /CR_Only, UValue = 'Pix Limits', $
                                 Event_Pro = 'Kang_Plot_Params_Events')
pix_limits_arr = [self.pix_xminID, self.pix_xmaxID, self.pix_yminID, self.pix_ymaxID]
self.pix_xminID->SetProperty, UValue = pix_limits_arr
self.pix_xmaxID->SetProperty, UValue = pix_limits_arr
self.pix_yminID->SetProperty, UValue = pix_limits_arr
self.pix_ymaxID->SetProperty, UValue = pix_limits_arr

; Align buttons
self.align0ID = Widget_Button(limitsbase, Value = 'Align to Image 0', UValue = 'Align to Image 0')
self.align1ID = Widget_Button(limitsbase, Value = 'Align to Image 1', UValue = 'Align to Image 1')
self.align2ID = Widget_Button(limitsbase, Value = 'Align to Image 2', UValue = 'Align to Image 2')
self.align3ID = Widget_Button(limitsbase, Value = 'Align to Image 3', UValue = 'Align to Image 3')

;----------------------------------------------------------------------
;                             Axis properties
;----------------------------------------------------------------------
bigaxisBase = Widget_Base(tabBase, Title='    Axis    ', Column=1)

; Titles
titleBase = Widget_Base(bigAxisBase, Column = 2, Frame=1)
self.titleID = FSC_InputField(titlebase, Value=image->GetProperty(/title), LabelSize=65, Title='Title:', $
                              UValue = 'Title', Event_Pro = 'Kang_Plot_Params_Events', /CR_Only, XSize = 25)
self.xtitleID = FSC_InputField(titlebase, Value=image->GetProperty(/xtitle), LabelSize=65, Title='X Title:', $
                               UValue = 'XTitle', Event_Pro = 'Kang_Plot_Params_Events', /CR_Only, XSize = 25)
self.bartitleID = FSC_InputField(titlebase, Value=image->GetProperty(/bartitle), LabelSize=65, Title='Bar Title:', $
                                 UValue = 'BarTitle', Event_Pro = 'Kang_Plot_Params_Events', /CR_Only, XSize = 25)
self.subtitleID = FSC_InputField(titlebase, Value=image->GetProperty(/subtitle), LabelSize=65, Title='Subtitle:', $
                                 UValue = 'SubTitle', Event_Pro = 'Kang_Plot_Params_Events', /CR_Only, XSize = 25)
self.ytitleID = FSC_InputField(titlebase, Value=image->GetProperty(/ytitle), LabelSize=65, Title='Y Title:', $
                               UValue = 'YTitle', Event_Pro = 'Kang_Plot_Params_Events', /CR_Only, XSize = 25)
buttonBase = Widget_Base(titleBase, Column = 2, /Align_Center)
defaultButton = Widget_Button(buttonBase, Value = '  Default  ', UValue = 'Default')
clearButton = Widget_Button(buttonBase, Value = '   Clear   ', UValue = 'Clear')

; Rest of parameters
axisbase=Widget_Base(bigaxisBase, Column=1, Frame=1, /Base_Align_Center)

; Colors
colorsBase = Widget_Base(axisBase, Row = 1);, Event_Pro = 'Kang_Axis_Events')
self.axisColorID = CW_Drawcolor(colorsBase, Color=image->GetProperty(/axiscname), LabelText='Axis Color: ', $
                                Title='Axis Color:', UValue ='Axis Color', Filename = 'colors.txt')
self.backColorID = CW_Drawcolor(colorsBase, Color=image->GetProperty(/backcname), LabelText='     Background Color: ', $
                                Title='Axis Color:', UValue = 'Background Color', Filename = 'colors.txt')
self.tickColorID = CW_Drawcolor(colorsBase, Color=image->GetProperty(/tickcname), LabelText='       Tick Color: ', $
                                Title='Axis Color:', UValue = 'Tick Color', Filename = 'colors.txt')

; Characters
charBase = Widget_Base(axisBase, Row = 1)
self.charsizeID = FSC_InputField(charbase, Value=image->GetProperty(/charsize), $
                                 LabelSize=80, /FloatValue, Title='Char. Size:', XSize=5, Decimal = 2)
self.charthickID = FSC_InputField(charbase, Value=image->GetProperty(/charthick), $
                                  LabelSize=80, /IntegerValue, Title='Char. Thick:', XSize=5)
self.fontID=FSC_DropList(charBase, Title='   Font: ', Index = image->GetProperty(/font)+1, $
                         Value=['Hershey', 'Hardware', 'True-Type'], UValue='Font')

; Ticks
tickBase = Widget_Base(axisBase, Row = 1)
self.minorID = FSC_InputField(tickbase, Value=image->GetProperty(/minor), $
                              Title='Minor Ticks:', LabelSize=75, /FloatValue, XSize=5, Decimal = 2)
self.ticksID = FSC_InputField(tickbase, Value=image->GetProperty(/ticks), $
                              Title='Ticks:', LabelSize=75, /FloatValue, XSize=5, Decimal = 2)
self.ticklenID = FSC_InputField(tickbase, Value=image->GetProperty(/ticklen), $
                                Title='Tick Length:', LabelSize=75, /FloatValue, XSize=5, Decimal = 2)

; Toggles buttons
noBase = Widget_Base(axisBase, Row = 1, /NonExclusive)
self.noaxisID = Widget_Button(noBase, Value='No Axis       ', UValue = 'No Axis')
self.nobarID = Widget_Button(noBase, Value='No Colorbar', UValue = 'No Colorbar')
Widget_Control, self.noaxisID, Set_Button = image->GetProperty(/noaxis)
Widget_Control, self.nobarID, Set_Button = image->GetProperty(/nobar)

; Apply button
butbase = Widget_Base(bigaxisBase, Row=1, /Align_Center)
acceptID = Widget_Button(butbase, Value='  Apply  ', UValue = 'Axis Apply')        

;----------------------------------------------------------------------
;                      Contours
;----------------------------------------------------------------------
; Define Top Level Base
contourBase = Widget_Base(tabbase, Title = '   Contour  ', Column=1)
topBase = Widget_Base(contourBase, Column=2)

; Get all the properties needed for the widget
image->GetProperty, All = c_par

; Percent buttons
self.percentButtonsID = CW_BGroup(topBase, ['', ''], Label_Top=' ', Column=1, space = 45, ypad = 30, /Exclusive, $
                             UValue='Percent', /No_Release)
Widget_Control, self.percentbuttonsID, Set_Value = ~c_par.percent

; NLevels
levBase = Widget_Base(topBase, Column = 1)
nlevels_base = Widget_Base(levBase, Column = 1, /Frame)
nlevels_topBase = Widget_Base(nlevels_Base, Row = 1)
self.nlevelsID=FSC_DropList(nlevels_topbase, Title='Levels: ', Index = c_par.nlevels-1, $
                            Value=indgen(14)+1, UValue = 'NLevels')
self.min_value=FSC_InputField(nlevels_topBase, Title='Min Value: ', Value=c_par.min_value, xSize=10, $
                              /FloatValue, Decimal = 3)
self.max_value=FSC_InputField(nlevels_topBase, Title='Max Value: ', Value=c_par.max_value, xSize=10, $
                              /FloatValue, Decimal = 3)
nlevels_levelsBase = Widget_Base(nlevels_Base, Row = 1)
self.nlevels_levels = FSC_InputField(nlevels_levelsBase, Title = ' ', LabelSize = 90, $
                                     Value=c_par.s_nlevels, UValue = 'NLevels_Levels', XSize=50, Edit = 0)

; Levels
levelsBase = Widget_Base(levBase, Column = 1, /Frame)
self.levels = FSC_InputField(levelsBase, Title='Level Values: ', LabelSize = 90, Value=c_par.s_levels, $
                             UValue = 'Levels', XSize=50, /CR_Only, Event_Pro = 'Kang_Plot_Params_Events')

; Other properties
othersBase = Widget_Base(ContourBase, Column = 1, /Frame)
colorsBase = Widget_Base(othersBase, Row = 1)
self.c_colors=FSC_InputField(colorsBase, Title='Color(s):    ', Value=c_par.s_colors, XSize=60)
lineBase = Widget_Base(othersBase, Row = 1)
self.c_linestyle=FSC_InputField(lineBase, Title='Linestyle(s):   ', Value=c_par.s_linestyle, XSize=15, /IntValue)
self.c_thick=FSC_InputField(lineBase, Title='Thickness: ', Value=c_par.s_thick, XSize=15)
self.downhillID=CW_BGroup(lineBase, Set_Value=c_par.downhill, 'Downhill', UValue = 'Downhill', /NonExclusive)

annotateBase = Widget_Base(ContourBase, Row=2, /Frame)
self.c_annotation=FSC_InputField(annotateBase, Title='Annotation: ', Value=c_par.s_annotation, XSize=20)
self.c_labels=FSC_InputField(annotateBase, Title='Label:     ', Value=c_par.s_labels)
self.c_charsize=FSC_InputField(annotateBase, Title='Charsize:   ', Value=c_par.s_charsize, XSize=20, /FloatValue)
self.c_charthick=FSC_InputField(annotateBase, Title='Charthick: ', Value=c_par.s_charthick, XSize=20, /FloatValue)

;tab = Widget_table(subbase, Column_Labels = ['Levels', 'Color', 'Width', 'LineStyle'], $
;                   Value = findgen(4,4), /Editable, format = '(F6.2)', background_color = [200, 0,0])

; Apply button
butbase = Widget_Base(contourBase, Row=1, /Align_Center)
acceptID = Widget_Button(butbase, Value='  Apply  ', UValue = 'Contour Apply')

;----------------------------------------------------------------------
;                      Regions
;----------------------------------------------------------------------
; Define bases
self.regionBase = Widget_Base(tabBase, Title='   Regions  ',  Column=1)
subBase = Widget_Base(self.regionBase, Column=1)
topBase = Widget_Base(subBase, Column=3, /Frame)

; Menubar
;fileID = Widget_Button(menubarID, Value = 'File')

; List
listBase = Widget_Base(topBase)
;regions->GetProperty, text=text
self.regions_listID = Widget_List(listBase, XSize=53, YSize=12, UValue='List', /Multiple)

; Information labels
labelBase = Widget_Base(topBase, Column = 1)
label = Widget_Label(labelBase, Value='Area:', /Align_Left)
label = Widget_Label(labelBase, Value='Perimeter:', /Align_Left)
label = Widget_Label(labelBase, Value='X Center:', /Align_Left)
label = Widget_Label(labelBase, Value='Y Center:', /Align_Left)
label = Widget_Label(labelBase, Value='# Pixels:', /Align_Left)
label = Widget_Label(labelBase, Value='Minimum:', /Align_Left)
label = Widget_Label(labelBase, Value='Maximum:', /Align_Left)
label = Widget_Label(labelBase, Value='Mean:', /Align_Left)
label = Widget_Label(labelBase, Value='Std. Dev.:', /Align_Left)
label = Widget_Label(labelBase, Value='Total:', /Align_Left)

; Information
statBase = Widget_Base(topBase, Column = 1)
self.areaLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.perimeterLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.x_centerLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.y_centerLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.NPixelLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.minLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.maxLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.meanLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.StdDevLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)
self.TotalLabelID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic_Resize)

; Names and buttons
otherBase = Widget_Base(subBase, Row =1)
;self.region_WriteID = Widget_Button(otherBase, Value = 'Write Params', UValue = 'Write')
self.region_DeleteID = Widget_Button(otherBase, Value=' Delete ', UValue='Delete')
self.region_HistogramID = Widget_Button(otherBase,  Value='Histogram',  UValue='Histogram')
self.region_ZoomID = Widget_Button(otherBase,  Value='  Zoom   ',  UValue='Zoom to Region')

; Basic Properties
propBase = Widget_Base(subBase, /Frame, Row=2)
toppropBase = Widget_Base(propBase, /Row)
Label = Widget_Label(toppropBase, Value='Name:', sensitive=0)
self.region_NameID = Widget_Text(toppropBase, Value='', XSize=15, /Editable, UValue='Name', sensitive=0)
self.region_ColorID = CW_Drawcolor(toppropBase, Color='black', LabelText='Color: ', $
                                   Title='Axis Color:', UValue = 'Region Color', Filename = 'colors.txt')
self.region_widthID = Widget_DropList(toppropbase, Title='Width: ', Value=StrTrim(indgen(10)+1, 2), UValue = 'Region Width')
self.region_linestyleID = Widget_DropList(toppropbase, Title='Linestyle: ', Value=StrTrim(indgen(6), 2), UValue = 'Region Linestyle')

botpropBase = Widget_Base(propBase, Row=1)
self.angle_sliderID = Widget_Slider(botpropBase, xsize=110, title='Angle', /Drag, $
                            Minimum=0, Maximum=360, UValue='Angle', Value=0, /Suppress)
self.angle_textboxID = FSC_InputField(botpropBase, Title='', Value=0, XSize=5, UValue = 'Angle Textbox', $
                                      /FloatValue, /Editable, /CR_Only, Event_Pro = 'Kang_Plot_Params_Events')
self.region_includeID=CW_BGroup(botpropBase, Set_Value=0, ['Include', 'Exclude'], UValue = 'Region Exclude', /Exclusive, /No_Release)
self.region_sourceID=CW_BGroup(botpropBase, Set_Value=0, ['Source', 'Background'], UValue = 'Region Source', /Exclusive, /No_Release)
self.region_typeID=CW_BGroup(botpropBase, Set_Value=0, ['Polygon', 'Line'], UValue = 'Region Type', /Exclusive, /No_Release)

;butBase = Widget_Base(threshold_base, /NonExclusive)
;invertButton = Widget_Button(butBase, Value = 'Invert', UValue = 'Invert')
;Widget_Control, invertButton, Set_Button = info.threshold_invert[whichplot_Params]

;---------------------------------------------------------
; later....
;; Spectra properties
;;spectrum = self.spectra->Get(position = self.whichSpectrum)
;;spectrum->GetProperty, axisCName = axisCName, backCName = backCName, CName = lineCName, $
;;  width = width, linestyle = linestyle, charsize = charsize, charthick = charthick, XRange = xrange, $
;;  yrange = yrange, title = title, xtitle = xtitle, ytitle = ytitle

;bigplotBase = Widget_Base(tabBase, Title='    Plots    ', Column=1)

;;plot->GetProperty, title = title, xtitle = xtitle, ytitle = ytitle, subtitle = subtitle, $
;;                   axisCName = axiscname


;; Titles
;titleBase = Widget_Base(bigplotBase, Column=1, Frame=1)
;titleBase2 = Widget_Base(titleBase, Column=2)
;self.spectrum_titleID = FSC_InputField(titlebase2, Value=image->GetProperty(/title), LabelSize=70, Title='Title:')
;self.spectrum_xtitleID = FSC_InputField(titlebase2, Value=image->GetProperty(/xtitle), LabelSize=70, Title='X Title:')
;self.spectrum_subtitleID = FSC_InputField(titlebase2, Value=image->GetProperty(/subtitle), LabelSize=70, Title='Subtitle:')
;self.spectrum_ytitleID = FSC_InputField(titlebase2, Value=image->GetProperty(/ytitle), LabelSize=70, Title='Y Title:')
;buttonBase = Widget_Base(titleBase, Column = 2, /Align_Center)
;defaultButton = Widget_Button(buttonBase, Value = '  Default  ', UValue = 'Default')
;clearButton = Widget_Button(buttonBase, Value = '   Clear   ', UValue = 'Clear')

;; Rest of parameters
;axisbase=Widget_Base(bigplotBase, Column=1, Frame=1, /Base_Align_Center)

;; Colors
;colorsBase = Widget_Base(axisBase, Row = 1) ;, Event_Pro = 'Kang_Axis_Events')
;self.spectrum_axisColorID = CW_Drawcolor(colorsBase, Color=image->GetProperty(/axiscname), LabelText='Axis Color: ', $
;                                         Title='Axis Color:', UValue ='Axis Color', Filename = 'colors.txt')
;self.spectrum_backColorID = CW_Drawcolor(colorsBase, Color=image->GetProperty(/backcname), LabelText='     Background Color: ', $
;                                         Title='Axis Color:', UValue = 'Background Color', Filename = 'colors.txt')
;self.spectrum_tickColorID = CW_Drawcolor(colorsBase, Color=image->GetProperty(/tickcname), LabelText='       Tick Color: ', $
;                                         Title='Axis Color:', UValue = 'Tick Color', Filename = 'colors.txt')

;; Characters
;charBase = Widget_Base(axisBase, Row = 1)
;self.spectrum_charsizeID = FSC_InputField(charbase, Value=image->GetProperty(/charsize), $
;                                          LabelSize=75, /FloatValue, Title='Charsize:', XSize=5, Decimal = 2)
;self.spectrum_charthickID = FSC_InputField(charbase, Value=image->GetProperty(/charthick), $
;                                           LabelSize=75, /FloatValue, Title='Charthick:', XSize=5, Decimal = 2)
;self.spectrum_fontID=FSC_DropList(charBase, Title='   Font: ', Index = image->GetProperty(/font)+1, $
;                                  Value=['Hershey', 'Hardware', 'True-Type'], UValue='Font')

;; Ticks
;tickBase = Widget_Base(axisBase, Row = 1)
;self.spectrum_minorID = FSC_InputField(tickbase, Value=image->GetProperty(/minor), $
;                                       Title='Minor Ticks:', LabelSize=75, /FloatValue, XSize=5, Decimal = 2)
;self.spectrum_ticksID = FSC_InputField(tickbase, Value=image->GetProperty(/ticks), $
;                                       Title='Ticks:', LabelSize=75, /FloatValue, XSize=5, Decimal = 2)
;self.spectrum_ticklenID = FSC_InputField(tickbase, Value=image->GetProperty(/ticklen), $
;                                         Title='Ticklength:', LabelSize=75, /FloatValue, XSize=5, Decimal = 2)

;; Line
;lineBase = Widget_Base(bigplotBase, Row = 1, frame = 1)
;axisColorID = CW_Drawcolor(lineBase, Color=image->GetProperty(/axiscname), LabelText='Line Color: ', $
;                           Title='Axis Color:', UValue ='Line Color', Filename = 'colors.txt')
;widthID = FSC_DropList(lineBase, Title='Width: ', Value=indgen(10)+1, UValue = 'Spectrum Width', $
;                       Event_Pro='Kang_Plot_Windows_Events')
;linestyleID = FSC_DropList(lineBase, Title='Linestyle: ', Value=indgen(6), UValue = 'Spectrum Linestyle', $
;                           Event_Pro='Kang_Plot_Windows_Events')

;; Ranges
;rangesBase = Widget_Base(bigplotBase, Row=3, /align_left, frame=1)
;self.spectrum_xminID = FSC_InputField(rangesBase, /Float, Title='X Range: ', XSize = 20, LabelSize = 55, $
;                                      /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events')
;self.spectrum_xmaxID = FSC_InputField(rangesBase, /Float, Title = '', XSize = 20, LabelSize = 0, $
;                                      /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events')
;freezexID = CW_BGroup(rangesBase, Set_Value=0, 'Freeze X', UValue = 'Freeze X', /NonExclusive)

;self.spectrum_yminID = FSC_InputField(rangesBase, /Float, Title='Y Range: ', XSize = 20, LabelSize = 55, $
;                                      /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events')
;self.spectrum_ymaxID = FSC_InputField(rangesBase, /Float, Title='', XSize = 20, LabelSize = 0, $
;                                      /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events')
;freezeyID = CW_BGroup(rangesBase, Set_Value=0, 'Freeze Y', UValue = 'Freeze Y', /NonExclusive)
;resetID = Widget_Button(rangesBase, Value = '  Reset X Axis  ', UValue = 'Reset X Axis')
;resetID = Widget_Button(rangesBase, Value = '  Reset Y Axis  ', UValue = 'Reset Y Axis')
;resetID = Widget_Button(rangesBase, Value = '  Reset X and Y Axes  ', UValue = 'Reset X and Y Axes')

;; Apply button
;butbase = Widget_Base(bigplotBase, Row=1, /Align_Center)
;acceptID = Widget_Button(butbase, Value='  Apply  ', UValue = 'Axis Apply')      

;---------------------------------------------------------
; Put in right top corner
screenSize = Get_Screen_Size()
geom = Widget_Info(tlb, /Geometry)
Widget_Control, tlb, XOffset = (screenSize[0]) - (geom.scr_xsize)
Widget_Control, tlb, /Realize

; Change to last displayed tab
Widget_Control, tabBase, Set_Tab_Current = self.currentTab

; Realize top-level base and all of its children.
Widget_Control, tlb, /Realize

; Store histogram IDs and draw histogram
n_hist = self.histogram_container->Count()
Widget_Control, self.histogram_drawID, Get_Value = histogram_WID
self.histogram_wid = histogram_wid
FOR i = 0, n_hist-1 DO BEGIN
    hist = self.histogram_container->Get(position = i)
    hist->Setproperty, drawID = self.histogram_drawID, wid = self.histogram_wid, pix_wid = self.histogram_pix_wid
ENDFOR
histogram->Draw

XManager, 'kang_plot_params_widget ' +StrTrim(self.tlbID, 2), tlb, /No_Block, Group_Leader=self.tlbID
self.current_regionBase = -1
self.plot_params_regiontype = ''
self->Update_Regions_Info, /List_Update

END; Kang::Plot_Params_Widget--------------------------------------------------------


;+
; Brings up the velocity widget
;
; :Private:
;
; :Params:
;  whichVelocity : in, optional, type = 'integer'
;    The image index number whose velocity to display.  Defaults to
;    current image.
;
;-
PRO Kang::Velocity_Widget, whichVelocity

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF

IF N_Elements(whichVelocity) EQ 0 THEN whichVelocity = self.whichImage
IF XRegistered('Kang_Velocity_Widget '+StrTrim(whichVelocity, 2)+' '+StrTrim(self.tlbID,2)) NE 0 THEN RETURN

; If an image hasn't been loaded, don't display
IF N_Elements(whichVelocity) EQ 0 THEN whichvelocity = self.whichImage
IF whichVelocity GE self.image_container->count() THEN RETURN

; Get the image object
image = self.image_container->Get(position = whichVelocity)
IF ~Obj_Valid(image) THEN RETURN
image->GetProperty, type = image_type, pix_limits = pix_limits, pix_newlimits = pix_newlimits, $
  velocity = velocity, deltavel = deltavel, newlimits = newlimits

; Won't display widget if no velocity axis
IF image_type NE 'Cube' AND image_type NE 'Cube Array' THEN RETURN $
ELSE image->GetProperty, vel_astr = astr

; Define top level base and subbase
tlb = Widget_Base(Title='Velocity - Image '+StrTrim(whichVelocity,2), $
                  /Base_Align_Center, Row = 2, tlb_frame_attr=1)
sliderBase = Widget_Base(tlb, Row = 2, /Base_Align_Center)
subbase = Widget_Base(tlb, Row=2, /Base_Align_Center)

; Create the slider and text widgets, store IDs in info structure
vel_sliderID = Widget_Slider(sliderbase, /suppress_value, xsize=(pix_limits[5] +1 + 37) > 250, $
                             title='Velocity', /Drag, Minimum=pix_limits[4], Maximum=pix_limits[5], $
                             UValue='Vel_Slider', Value=(pix_newlimits[5] - pix_newlimits[4])/2 + pix_newlimits[4], Scroll=1)
vel_text = FSC_InputField(sliderbase, /Float, Title='', Value=velocity, /CR_Only, XSize = 10, $
                          UValue = 'Vel_Text', Event_Pro = 'Kang_Velocity_Events')

; Do the same for deltavel
deltavel_sliderID = Widget_Slider(sliderbase, /suppress_value, xsize=(pix_limits[5]+1 + 37) > 250, $
                                  title='Delta V', /Drag, Minimum=0, Maximum=Round(pix_limits[5]/2.), $
                                  UValue='Deltavel_Slider', Value=(pix_newlimits[5] - pix_newlimits[4]), Scroll=1)
deltavel_text = FSC_InputField(sliderbase, /Float, Title='', Value=deltavel, /CR_Only, XSize = 10, $
                               UValue = 'Deltavel_Text', Event_Pro = 'Kang_Velocity_Events')

; Show the values
lowvel = FSC_InputField(subbase, /Float, Title='Low Velocity: ', XSize = 10, LabelSize = 100, $
                        Value=newlimits[4], /CR_Only, UValue = 'LowVel', Event_Pro = 'Kang_Velocity_Events')
highvel = FSC_InputField(subbase, /Float, Title='High Velocity: ', XSize = 10, LabelSize = 100, $
                           Value=newlimits[5], /CR_Only, UValue = 'HighVel', Event_Pro = 'Kang_Velocity_Events')

; Buttons for predefined values
butbase = Widget_Base(subbase, column=8)
label = Widget_Label(butBase, Value = 'Deltavel Presets: ')
buttonID = Widget_Button(butbase, Value='  1.0 ', UValue = 'Button')
buttonID = Widget_Button(butbase, Value='  2.0 ', UValue = 'Button')
buttonID = Widget_Button(butbase, Value='  5.0 ', UValue = 'Button')
buttonID = Widget_Button(butbase, Value='  7.5 ', UValue = 'Button')
buttonID = Widget_Button(butbase, Value=' 10.0 ', UValue = 'Button')
;buttonID = Widget_Button(butbase, Value='Animate', Event_Pro = 'Kang_Velocity_Animate')
;waitID = CW_Field(subbase, /Floating, Title='Time', Value=0, xsize = 13)

UVal = {self:self, $
        whichVelocity:whichVelocity, $
        vel_sliderID: vel_sliderID, $
        vel_text:vel_text, $
        deltavel_sliderID:deltavel_sliderID, $
        deltavel_text:deltavel_text, $
        lowvel:lowvel, $
        highvel:highvel}

; Put in bottom right corner
screenSize = Get_Screen_Size()
geom = Widget_Info(tlb, /Geometry)
Widget_Control, tlb, XOffset = (screenSize[0]) - (geom.scr_xsize)
Widget_Control, tlb, YOffset = (screenSize[1]) - (geom.scr_ysize)
Widget_Control, tlb, /Realize


; Add tlb to info structure
(*self.velocityID)[whichVelocity] = tlb

; Realize top-level base and all of its children.
Widget_Control, tlb, Set_UValue = UVal, /Realize
XManager, 'Kang_Velocity_Widget '+StrTrim(whichVelocity,2)+' '+StrTrim(self.tlbID,2), tlb, Event_Handler='Kang_Velocity_Events', $
          /No_Block, Group_Leader=self.tlbID

END;Kang::Velocity_Widget---------------------------------------------------


;+
; Brings up with plot windows widget
;
; :Private:
;
;-
PRO Kang::Plot_Windows_Widget

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Only open if not there already - if not, send some ids
IF XRegistered('plot_windows '+StrTrim(self.tlbID, 2)) THEN RETURN

; Create the draw windows for the spectrum and the plots
Windows_tlb = Widget_Base(Column=1, /TLB_Size_Events, MBar = menubarID, Title='Plots', UValue = self, /Kbrd_Focus, $
                          Event_Pro = 'Kang_Plot_Windows_TLB_Events')

; Define the Save As pull-down menu.
saveAsID = Widget_Button(menubarID, Value='Save As', Event_Pro='Kang_File_Output_Windows', /Menu)
button = Widget_Button(saveAsID, Value='JPG File')
button = Widget_Button(saveAsID, Value='GIF File')
button = Widget_Button(saveAsID, Value='PNG File')
button = Widget_Button(saveAsID, Value='TIFF File')
button = Widget_Button(saveAsID, Value='PostScript File')
button = Widget_Button(saveAsID, Value='FITS File')
button = Widget_Button(saveAsID, Value='IDL Variable')

; Use a tab environment
tabBase = Widget_Tab(windows_tlb, Location=1)
self.windows_tabBase = tabBase
SpectrumBase = Widget_Base(tabBase, Column=1, Title = '  Spectra   ')
subBase = Widget_Base(spectrumBase, Row=1)
self.spectrum_window = Obj_New('Kang_Window', subBase, Event_Pro = 'Kang_Draw_Spectra_Events', $
                               position = [0.1, 0.1, 0.9, 0.9], xsize = 700, ysize = 300, $
                               drawingColor = self.drawingColor)

;self.spectra->GetProperty, plot_spectrum = plot_spectrum, current_spectrum = current_spectrum
;SpectrumButtonBase = Widget_Base(subBase, Row=2, Event_Pro = 'Kang_Plot_Windows_Events')
;CurrentID=CW_BGroup(spectrumButtonBase, StrArr(9), /column, /Exclusive, Label_Top='C', $
;                   /FRAME, Set_Value = current_spectrum, UValue = 'C', /No_Release)
;;Widget_Control, currentID, Set_Button = self.whichSpectrum
;SpecID=CW_BGroup(spectrumButtonBase, StrArr(9), /column, /NonEXCLUSIVE, Label_Top='P', $
;                   /FRAME, Set_Value = plot_spectrum, UValue = 'P')
;properties=Widget_Button(spectrumButtonBase, Value = 'Show Par.', UValue = spectrumBase, $
;                         Event_Pro = 'Kang_Spectra_Properties_Widget')
;gauss1=Widget_Button(spectrumButtonBase, Value = 'Fit 1', UValue = 'Fit 1', $
;                         Event_Pro = 'Kang_Plot_Windows_Events')
;gauss2=Widget_Button(spectrumButtonBase, Value = 'Fit 2', UValue = 'Fit 2', $
;                         Event_Pro = 'Kang_Plot_Windows_Events')
;gauss3=Widget_Button(spectrumButtonBase, Value = 'Fit 3', UValue = 'Fit 3', $
;                         Event_Pro = 'Kang_Plot_Windows_Events')
;gauss4=Widget_Button(spectrumButtonBase, Value = 'Fit 4', UValue = 'Fit 4', $
;                         Event_Pro = 'Kang_Plot_Windows_Events')

;clear=Widget_Button(spectrumButtonBase, Value = 'Clear All', UValue = spectrumBase, $
;                    Event_Pro = 'Kang_Spectra_Properties_Widget')

; Mini spectra
;MiniSpectrumBase = Widget_Base(tabBase, Row = 1, Title = 'MiniSpectra')
;self.minispectrum_window = Obj_New('Kang_Window', minispectrumBase, Event_Pro = 'Kang_Draw_MiniSpectra_Events', $
;                                   position = [0.1, 0.1, 0.9, 0.9], xsize = 700, ysize = 300, drawingColor = self.drawingColor)

PlotBase = Widget_Base(tabBase, Title = '    Plots    ')
self.plot_window = Obj_New('Kang_Window', plotbase, Event_Pro = 'Kang_Plot_Region', position = [0.1, 0.1, 0.9, 0.9], $
                          xsize = 700, ysize = 300, drawingColor = self.drawingColor)

; Put in right hand corner
screenSize = Get_Screen_Size()
geom = Widget_Info(windows_tlb, /Geometry)
Widget_Control, windows_tlb, XOffset = (screenSize[0]) - (geom.scr_xsize+20)
Widget_Control, windows_tlb, /Realize

; Get the Ids for these draw widgets
self.spectrum_window->Realize
self.spectrum_window->GetProperty, wid = spectrum_WID
;self.minispectrum_window->Realize
;self.minispectrum_window->GetProperty, wid = minispectrum_WID
self.plot_window->Realize
self.plot_window->GetProperty, wid = plot_WID

self.spectrum_WID = spectrum_WID
;self.minispectrum_WID = minispectrum_WID
self.plot_WID = plot_WID

; Do the same for the plot windows
XManager, 'plot_windows ' + StrTrim(self.tlbID, 2), windows_tlb, Event_Handler='Kang_Plot_Windows_TLB_Events', $
          /No_Block, Group_Leader=self.tlbID

END; Kang::Plot_Windows_Widget------------------------------------------------


;+
; Brings up with spectrum propertes widget
;
; :Private:
;
;-
PRO Kang::Spectra_Properties_Widget, event

; Turn off updates
Widget_Control, event.top, Update=0
Widget_Control, event.id, Get_UValue = base, Get_Value = value

; If display is hidden, show it
;IF value EQ 'Clear All' THEN BEGIN
;    Obj_Destroy, info.spectra
;ENDIF

IF value EQ 'Show Par.' THEN BEGIN
; Get spectra parameters    
    spectrum = self.spectra->Get(position = self.whichSpectrum)
    spectrum->GetProperty, axisCName = axisCName, backCName = backCName, CName = lineCName, $
      width = width, linestyle = linestyle, charsize = charsize, charthick = charthick, XRange = xrange, $
      yrange = yrange, title = title, xtitle = xtitle, ytitle = ytitle

    propBase = Widget_Base(base, column=1, Event_Pro = 'Kang_Plot_Windows_Events', UName = 'propBase')
    toprowBase = Widget_Base(propBase, row=1)
    lineColorID = CW_Drawcolor(toprowBase, Color=lineCName, LabelText='Line Color: ', $
                               Title='Line Color:', UValue = 'Line Color', Filename = 'colors.txt')
    axisColorID = CW_Drawcolor(toprowBase, Color=axisCName, LabelText='Axis Color: ', $
                               Title='Axis Color:', UValue = 'Axis Color', Filename = 'colors.txt')
    backColorID = CW_Drawcolor(toprowBase, Color=backCName, LabelText='BG Color: ', $
                               Title='BG Color:', UValue = 'BG Color', Filename = 'colors.txt')
    widthID = FSC_DropList(toprowBase, Title='Width: ', Index = width-1, Value=indgen(10)+1, UValue = 'Spectrum Width', $
                           Event_Pro='Kang_Plot_Windows_Events')
    linestyleID = FSC_DropList(toprowBase, Title='Linestyle: ', Index = linestyle, Value=indgen(6), UValue = 'Spectrum Linestyle', $
                               Event_Pro='Kang_Plot_Windows_Events')
    charsize=FSC_InputField(toprowBase, Title='Charsize:   ', Value = String(charsize, format = '(F4.1)'), $
                                UValue = 'Spectrum Charsize', XSize=4, /FloatValue, labelSize = 75, /CR_Only, $
                                Event_Pro = 'Kang_Plot_Windows_Events')
    charthick=FSC_InputField(toprowBase, Title='Charthick: ', Value = String(charthick, format = '(F4.1)'), $
                                                                                 UValue = 'Spectrum Charthick', XSize=4, /FloatValue, labelSize = 75, $
                                                                                 /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events')

; Text boxes
    midrowBase = Widget_Base(propBase, row=1)
    xmin = FSC_InputField(midrowbase, /Float, Title='X Range: ', XSize = 10, LabelSize = 55, $
                          /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events', Value = xrange[0])
    xmax = FSC_InputField(midrowbase, /Float, Title = '', XSize = 10, LabelSize = 0, $
                          /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events', Value = xrange[1])
    ymin = FSC_InputField(midrowbase, /Float, Title='Y Range: ', XSize = 10, LabelSize = 80, $
                          /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events', Value = yrange[0])
    ymax = FSC_InputField(midrowbase, /Float, Title='', XSize = 10, LabelSize = 0, $
                          /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events', Value = yrange[1])
    freezexID = CW_BGroup(midrowBase, Set_Value=0, 'Freeze X', UValue = 'Freeze X', /NonExclusive)
    freezeyID = CW_BGroup(midrowBase, Set_Value=0, 'Freeze Y', UValue = 'Freeze Y', /NonExclusive)
    resetID = Widget_Button(midrowBase, Value = '  Reset Axes  ', UValue = 'Reset Axes')

;    ymin = FSC_InputField(midrowbase, /Float, Title='Y Range(R): ', XSize = 5, LabelSize = 70, $
;                          Value=0, /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events')
;    ymax = FSC_InputField(midrowbase, /Float, Title='', XSize = 5, LabelSize = 0, $
;                          Value=0, /CR_Only, Event_Pro = 'Kang_Plot_Windows_Events')
;    overplotID=CW_BGroup(midrowBase, Set_Value=0, 'Overplot', UValue = 'Spectrum Overplot', /NonExclusive)
;    overplotID=CW_BGroup(midrowBase, Set_Value=0, 'Overplot', UValue = 'Spectrum Overplot', /NonExclusive)

; Set UValues of text boxes
    obs = ObjArr(4)
    obs = [xmin, xmax, ymin, ymax]
    xmin->SetProperty, UValue = obs
    xmax->SetProperty, UValue = obs
    ymin->SetProperty, UValue = obs
    ymax->SetProperty, UValue = obs

; Titles
    botrowBase = Widget_Base(propBase, row=1)
    title_box = FSC_InputField(botrowbase, Value=title, LabelSize=50, Title='Title:', XSize = 22, /CR_Only, $
                           Event_Pro = 'Kang_Plot_Windows_Events', UVal = 'Title')
    xtitle_box = FSC_InputField(botrowbase, Value=xtitle, LabelSize=50, Title='X Title:', XSize = 22, /CR_Only, $
                            Event_Pro = 'Kang_Plot_Windows_Events', UVal = 'XTitle')
    ytitle_box = FSC_InputField(botrowbase, Value=ytitle, LabelSize=74, Title='Y Title:', XSize = 22, /CR_Only, $
                            Event_Pro = 'Kang_Plot_Windows_Events', UVal = 'YTitle')
    defaultID = Widget_Button(botrowBase, Value = '  Default Titles  ', UValue = 'Default Titles')

;    Label = Widget_Label(botrowBase, Value='Name:')
;    region_NameID = Widget_Text(botrowBase, Value='', XSize=35, YSize=1, /Editable, UValue='Name')

    uval = {linecolorID:linecolorID, $
            axiscolorID:axiscolorID, $
            backcolorID:backcolorID, $
            widthID:widthID, $
            linestyleID:linestyleID, $
            charsize:charsize, $
            charthick:charthick, $
            xmin:xmin, $
            xmax:xmax, $
            ymin:ymin, $
            ymax:ymax, $
            freezexID:freezexID, $
            freezeyID:freezeyID, $
;            overplotID:overplotID, $
            title:title_box, $
            xtitle:xtitle_box, $
            ytitle:ytitle_box};, $
;            ytitle2:ytitle2}
    Widget_Control, propBase, Set_UValue = uval

; Change button display
    Widget_Control, event.ID, Set_Value = 'Hide Par.'
ENDIF ELSE BEGIN
; If display is shown, hide it
; Find the base ID
    base = Widget_Info(event.top, Find_By_UName = 'propBase')

; Get rid of base
    Widget_Control, base, /Destroy

; Set button value back
    Widget_Control, event.ID, Set_Value = 'Show Par.'
ENDELSE

; Turn updates back on to realize the display
Widget_Control, event.top, Update=1
END; Kang::Spectra_Properties_Widget------------------------------------------------------


;+
; Brings up the dialog to fit 2D profiles
;
; :Private:
;
;-
PRO Kang::Profile_Widget

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF

IF XRegistered('Kang_Profile ' + StrTrim(self.tlbID, 2)) THEN RETURN

self.profile_WidgetID = Widget_Base(Column=1, /Base_Align_Center, Group_Leader = self.tlbID)
topBase = Widget_Base(self.profile_WidgetID, Row=1, /Base_Align_Left, Event_Pro = 'Kang_Profile_Events')

; Get info from image object
self.image->GetProperty, fitType = fitType, circular = circular, tilt = tilt

; Define top row
leftBase = Widget_Base(topBase, Column=1, /Base_Align_Left)
fitArr = ['Gaussian', 'Lorentzian', 'Moffat', 'Ellipse']
profile=FSC_DropList(leftBase, Title='Type: ', Value = fitArr, index = where(fitType EQ fitarr))
circularBase = Widget_Base(leftBase, /NonExclusive)
circularID=Widget_Button(circularBase, Value = 'Circular')
tiltBase = Widget_Base(leftBase, /NonExclusive)
tiltID=Widget_Button(tiltBase, Value = 'Tilt')
Widget_Control, tiltID, Set_Button=tilt

; Second Row
;paramsBase = Widget_Base(leftBase, row=1)
;xcenter = FSC_InputField(paramsbase, Title='X Center: ', xsize=10, /Float)
;ycenter = FSC_InputField(paramsbase, Title='Y Center: ', xsize=10, /Float)

; Labels
rightBase = Widget_Base(topBase, Column=2)
labelBase = Widget_Base(rightBase, Column=1)
label = Widget_Label(labelBase, Value='Baseline:', /Align_Left)
label = Widget_Label(labelBase, Value='Peak:', /Align_Left)
label = Widget_Label(labelBase, Value='Peak Half Width (x):', /Align_Left)
label = Widget_Label(labelBase, Value='Peak Half Width (y):', /Align_Left)
label = Widget_Label(labelBase, Value='X Center:', /Align_Left)
label = Widget_Label(labelBase, Value='Y Center:', /Align_Left)
label = Widget_Label(labelBase, Value='Angle:', /Align_Left)
label = Widget_Label(labelBase, Value='Power Law Index:', /Align_Left)

statBase = Widget_Base(rightBase, Column = 1)
baselineID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)
peakID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)
peak_xwidthID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)
peak_ywidthID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)
xcenterID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)
ycenterID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)
angleID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)
indexID = Widget_Label(statBase, Value='        ', /Align_Left, /Dynamic)

;      A(0)   Constant baseline level
;      A(1)   Peak value
;      A(2)   Peak half-width (x) -- gaussian sigma or half-width at half-max
;      A(3)   Peak half-width (y) -- gaussian sigma or half-width at half-max
;      A(4)   Peak centroid (x)
;      A(5)   Peak centroid (y)
;      A(6)   Rotation angle (radians) if TILT keyword set
;      A(7)   Moffat power law index if MOFFAT keyword set

;textID = Widget_Text
; Windows
windowBase = Widget_Base(self.profile_WidgetID, Column=4)
label = Widget_Label(windowBase, Value='Data', /Align_Center)
data_windowID = Widget_Draw(windowBase, xsize = 150, ysize = 150)
label = Widget_Label(windowBase, Value='Model', /Align_Center)
model_windowID = Widget_Draw(windowBase, xsize = 150, ysize = 150)
label = Widget_Label(windowBase, Value='Residuals', /Align_Center)
residual_windowID = Widget_Draw(windowBase, xsize = 150, ysize = 150)
label = Widget_Label(windowBase, Value='1D Cuts', /Align_Center)
cuts_windowID = Widget_Draw(windowBase, xsize = 150, ysize = 150)

; Fit button
butbase = Widget_Base(self.profile_WidgetID, Row=1)
fitID = Widget_Button(butbase, Value='  Fit  ')
createID = Widget_Button(butbase, Value='Create Region')
printID = Widget_Button(butbase, Value='Print Fit')

; Realize widget
Widget_Control, self.profile_WidgetID, /Realize

; Get window ids
Widget_Control, data_windowID, Get_Value=data_wid
Widget_Control, model_windowID, Get_Value=model_wid
Widget_Control, residual_windowID, Get_Value=residual_wid
Widget_Control, cuts_windowID, Get_Value=cuts_wid

; Store values in the uval structure
uval = {self:self, $
        tlbID:self.tlbID, $
        profile:profile, $
        circularID:circularID, $
        tiltID:tiltID, $
        data_wid:data_wid, $
        model_wid:model_wid, $
        residual_wid:residual_wid, $
        cuts_wid:cuts_wid, $
        fitID:fitID, $
        baselineID:baselineID, $
        peakID:peakID, $
        peak_xwidthID:peak_xwidthID, $
        peak_ywidthID:peak_ywidthID, $
        xcenterID:xcenterID, $
        ycenterID:ycenterID, $
        angleID:angleID, $
        indexID:indexID}
Widget_Control, self.profile_WidgetID, Set_UValue = uval

; Fit button is insensitive until a valid region has been defined
;self.regions->GetProperty, selected_regions = selected_regions
;oregion = self.regions->Get(position = selected_regions)
;self.profile_region = oregion[0]
;IF ~Obj_Valid(self.profile_region) THEN 
;Widget_Control, fitID, sensitive=0

XManager, 'Kang_Profile ' + StrTrim(self.tlbID, 2), self.profile_WidgetID, Event_Handler = 'Kang_Profile_Events', /No_Block

END; Kang::Profile_Widget-----------------------------------------


;+
; Brings up the widget to fit gaussians to each pixel in a region
;
; :Private:
;
;-
PRO Kang::Velocity_Field_Widget

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF
IF XRegistered('Kang_Velocity_Field' + StrTrim(tlbID, 2)) THEN RETURN

tlb = Widget_Base(Column=1, /Base_Align_Center, Group_Leader = self.tlbID)
topBase = Widget_Base(tlb, Column=2, /Base_Align_Left)

; Define top row
leftBase = Widget_Base(topBase, Column=2, /Base_Align_Left, UValue = tlb, $
                       Event_Pro = 'Kang_Velocity_Field_Events')
ngauss=Widget_Droplist(leftBase, Title='# Gaussians: ', Value=StrTrim(indgen(6)+1, 2), UValue = tlb)
lowrange = FSC_InputField(leftbase, Title='Low Range: ', xsize=10, /Float)
invertBase = Widget_Base(leftBase, /NonExclusive)
invertID = Widget_Button(invertBase, Value = 'Invert')
highrange = FSC_InputField(leftbase, Title='High Range: ', xsize=10, /Float)

; Spectrum area
rightBase = Widget_Base(topBase, Column=1)
spectrum_windowID = Widget_Draw(rightBase, xsize = 350, ysize = 150)

; Gauss Base
gaussBase = Widget_Base(tlb, Row=1)
break1ID = CW_Field(gaussBase, Title='Break 1: ', xsize=10, /Float)
break2ID = CW_Field(gaussBase, Title='Break 2: ', xsize=10, /Float)
break3ID = CW_Field(gaussBase, Title='Break 3: ', xsize=10, /Float)
break4ID = CW_Field(gaussBase, Title='Break 4: ', xsize=10, /Float)
break5ID = CW_Field(gaussBase, Title='Break 5: ', xsize=10, /Float)

; Windows
windowBase = Widget_Base(tlb, Column=3)
label = Widget_Label(windowBase, Value='Height', /Align_Center)
height_windowID = Widget_Draw(windowBase, xsize = 250, ysize = 250)
label = Widget_Label(windowBase, Value='Width', /Align_Center)
width_windowID = Widget_Draw(windowBase, xsize = 250, ysize = 250)
label = Widget_Label(windowBase, Value='Center', /Align_Center)
center_windowID = Widget_Draw(windowBase, xsize = 250, ysize = 250)

; Fit button
butbase = Widget_Base(tlb, Row=1)
fitID = Widget_Button(butbase, Value='  Fit  ', Event_Pro = 'Kang_Velocity_Field_Events')

; Realize widget
Widget_Control, tlb, /Realize

; Set sensitivity
Widget_Control, break1ID, Sensitive=0
Widget_Control, break2ID, Sensitive=0
Widget_Control, break3ID, Sensitive=0
Widget_Control, break4ID, Sensitive=0
Widget_Control, break5ID, Sensitive=0

; Get window ids
Widget_Control, spectrum_windowID, Get_Value=spectrum_wid
Widget_Control, height_windowID, Get_Value=height_wid
Widget_Control, width_windowID, Get_Value=width_wid
Widget_Control, center_windowID, Get_Value=center_wid

; Store values in the uval structure
uval = {tlbID:tlbID, $
        nGauss:nGauss, $
        invertID:invertID, $
        lowrange:lowrange, $
        highrange:highrange, $
        break1ID:break1ID, $
        break2ID:break2ID, $
        break3ID:break3ID, $
        break4ID:break4ID, $
        break5ID:break5ID, $
        spectrum_wid:spectrum_wid, $
        height_wid:height_wid, $
        width_wid:width_wid, $
        center_wid:center_wid, $
        fitID:fitID}
Widget_Control, tlb, Set_UValue = uval

; Add ID to info structure
self.velfieldID = tlb

; Fit button is insensitive until a valid region has been defined
IF ~Obj_Valid(info.profile_region) THEN Widget_Control, fitID, sensitive=0

XManager, 'Kang_Velocity_Field' + StrTrim(tlbID,2), tlb, Event_Handler = 'Kang_Profile_Events', /No_Block
END; Kang::Velocity_Field_Widget------------------------------------------


;--------------------------------------------------------------------------------
; Event Handlers
;--------------------------------------------------------------------------------
;+
; This is the main event handler for the program.  It handles all
; events from the main window, including the menubar.
;
; :Private:
;
;-
PRO Kang_Events, event
Widget_Control, event.top, Get_UValue = self

; Branch on type of event
thisEvent = Tag_Names(event, /Structure_Name)
CASE thisEvent OF

; Menubar and events
    'WIDGET_BUTTON': BEGIN
        Widget_Control, event.ID, Get_Value = buttonName
        CASE buttonName OF
            'Open FITS': self->Load
            'Open Array': self->Load_Array_Events
            'Show FITS Header': self->Show_Header, event
            'GIF File': self->Save, /GIF
            'PNG File': self->Save, /PNG
            'JPG File':self->Save, /JPEG
            'TIFF File': self->Save, /TIFF
            'PostScript File': self->Save, /PS
            'FITS File': self->Save, /FITS
            'IDL Variable': self->Save, /IDL
            'Quit': self->Quit
            'Files': self->File_Dialog_Widget
            'Plot Parameters': self->Plot_Params_Widget
            'Velocity': self->Velocity_Widget
            
            'Cut': self->Cut
            'Copy': self->Copy
            'Paste': self->Paste
            
            'Image Colors': self->XColors_Events, event
            'Invert': self->Color, /Invert
            'Reverse': self->Color, /Reverse
            'Reset Stretch': self->Stretch, /Reset
            
            'Linear': self->Scale, /Linear
            'Log': self->Scale, /Log
            'Histogram Eq.': self->Scale, /HistEq
            'Power': self->Scale, /Power
            'Gaussian': self->Scale, /Gaussian
            'asinh': self->Scale, /asinh
            'Squared': self->Scale, /Squared
            'Square Root': self->Scale, /SquareRoot
            
            'Zoom In': self->Zoom, factor = 2
            'Zoom Out': self->Zoom, factor = 0.5
            
            'Load Regions': self->Load_Regions
            'Save Regions': self->Save_Regions
            'Delete All Regions': self->Delete_Region, /All
            'Save Mask': self->Save_Mask
            'Save Weighted Mask': self->Save_Mask, /Weighted
            'Threshold Image': self->Threshold_Image
            'Select All': self->Select, /All
            'Select None': self->Select, /None
            'Invert Selection': self->Select, /Invert
            'Create Composite': self->Combine
            'Dissolve Composite': self->Dissolve
            'Box': self->Global_Region_Property, RegionType = 'Box'
            'Circle': self->Global_Region_Property, RegionType = 'Circle'
            'Ellipse': self->Global_Region_Property, RegionType = 'Ellipse'
            'Cross': self->Global_Region_Property, RegionType = 'Cross'
            'Threshold': self->Global_Region_Property, RegionType = 'Threshold'
            'Text': self->Global_Region_Property, RegionType = 'Text'
            'Line': self->Global_Region_Property, RegionType = 'Line'
            'Freehand': self->Global_Region_Property, RegionType = 'Freehand'

            'Include': self->Global_Region_Property, /Include
            'Exclude': self->Global_Region_Property, /Exclude
            'Source': self->Global_Region_Property, /Source
            'Background': self->Global_Region_Property, /Background
            'Polygon ': self->Global_Region_Property, /Polygon ; These have an extra space
            'Line ': self->Global_Region_Property, /Linepar

            'Solid': self->Global_Region_Property, linestyle = 0
            'Dotted': self->Global_Region_Property, linestyle = 1
            'Dashed': self->Global_Region_Property, linestyle = 2
            'Dash-Dot': self->Global_Region_Property, linestyle = 3
            'Dash-Dot-Dot-Dot': self->Global_Region_Property, linestyle = 4
            'Long Dash': self->Global_Region_Property, linestyle = 5

            'Color': self->Global_Region_Property, /Color
            
            'Equatorial J2000': self->Coordinates, 'J2000'
            'Equatorial B1950': self->Coordinates, 'B1950'
            'Galactic': self->Coordinates, 'Galactic'
            'Ecliptic': self->Coordinates, 'Ecliptic'
            'Horizon': self->Coordinates, 'Horizon'
            'Degrees': self->Coordinates, /Degree
            'Sexadecimal': self->Coordinates, /Sexadecimal
            
            'XPlot': self->Interactive_Plots, /XPlot
            'YPlot': self->Interactive_Plots, /YPlot
            'ZPlot': self->Interactive_Plots, /ZPlot
            'None': self->Interactive_Plots, /None

            'DAOPhot': self->DAOPhot_Widget

            '3D': self->threeD
            'Smooth': self->Smooth
            'Fit Profile': self->Profile_Widget
            'Velocity Field':
            ELSE: BEGIN
; Handle the width events
                Widget_Control, event.ID, Get_UValue = property
                self->Global_Region_Property, Width = fix(buttonName)
            END            
        ENDCASE
    END

; Mouse buttons and mouse motion
    'WIDGET_DRAW': self->Draw_Window_Events, event

; Changed size of window
    'WIDGET_BASE': self->TLB_Events, event

; Moved mouse into window    
    'WIDGET_KBRD_FOCUS': self->KBRD_Focus_Events, event.enter

; Changed stretch on the bottom of the display
    'WIDGET_SLIDER': BEGIN
        Widget_Control, event.ID, Get_UValue = sliderName

; Branch off the two options.  Don't draw contours if dragging
        CASE sliderName OF
            'brightness_slider': self->stretch, brightness = event.value / 100., nocontours = event.drag
            'contrast_slider': self->stretch, contrast=event.value / 100., nocontours = event.drag
        ENDCASE
        self->Set_Focus
    END

; Inputs in top area - this is the stupid way cw_field returns events
    '': BEGIN
        Widget_Control, event.ID, Get_UValue = longlat
        CASE longlat.name OF
            'Long': BEGIN
                Widget_Control, event.id, Get_Value = long
                Widget_Control, longlat.otherID, Get_Value = lat
                self->Zoom, long, lat, /cursor
            END
            'Lat': BEGIN
                Widget_Control, event.id, Get_Value = lat
                Widget_Control, longlat.otherID, Get_Value = long
                self->Zoom, long, lat, /cursor
            END
        ENDCASE
    END

; Loaded new color table
    'XCOLORS_LOAD': self->XColors_Events, event
    else:stop
ENDCASE

END; Kang_Events--------------------------------------------------------------------


;----------------------------------------------------------------------
;-----------------------Main window events-----------------------------
;----------------------------------------------------------------------
;+
; NOT DOING ALL THAT IT SHOULD
; This routine basically just sets the colors back so as to not
; interfere with the user's color table, but preserves the one we
; want.  It is attached to all widgets.
; It's not quite operational yet, but just does the basics.
; The top_level keyword means the events originate in the top level
; base
;
; :Private:
;
;-
PRO Kang::Kbrd_Focus_Events, enter

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF

n_images = self.image_container->count()
IF n_images EQ 0 THEN RETURN

;Widget_Control, id, Timer=1
;stop
;systime = systime(1)
;print, enter

; These are events
;IF systime - info.systime LT 0.01 AND enter EQ 1 THEN BEGIN
;    print, 'window 2 window'

; If losing keyboard focus, change to spectrum window, set colors back
    IF enter EQ 0 THEN BEGIN
        IF XRegistered('plot_windows ' + StrTrim(self.tlbID, 2)) THEN WSet, self.spectrum_wid
;        TVLCT, info.r_old, info.g_old, info.b_old
 ;       IF info.plot_Type NE 'None' THEN info.plot_window->update
;        Widget_Control, tlbID, Set_UValue=info, /No_Copy
    ENDIF ELSE BEGIN

;; Get old display colors
;        TVLCT, r_old, g_old, b_old, /Get
;        info.r_old = r_old
;        info.g_old = g_old
;        info.b_old = b_old

;; Load the program's colors
        self.colors->TVLCT

;; Recopy graphics in case something was plotted onto the draw window
        self->Copy_Display
    ENDELSE
;ENDIF ELSE IF enter EQ 0 THEN print, 'leaving window'

;info.systime = systime
END; Kang_Kbrd_Focus-----------------------------------------------------------------


;+
; Responds to events from the keyboard
;
; :Private:
;
;-
PRO Kang::Keyboard_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; These are ASCII keys
IF event.type EQ 5 THEN BEGIN

; Only handle down events
    IF event.release THEN BEGIN
        CASE event.ch OF
; I'd like this eventually to be used to determine which image to contour
;            99B: self.c = 0B
            ELSE:
        ENDCASE
    ENDIF

    IF event.press THEN BEGIN
; The numbers change which image is displayed
        CASE event.ch OF
            1B: IF self.shift THEN self->Select, /None ELSE self->Select, /All ; ctrl-a key - for select all
            3B: self->Copy      ; ctrl-c
            8B: self->Delete_Region ;Backspace key
            9B: BEGIN
                IF self.control THEN self->Change_Image, /Previous ELSE self->Change_Image, /Next
                self->Set_Focus
            END
            22B: self->Paste    ; ctrl-v
            24B: self->Cut      ; ctrl-x
            43B: self->Zoom, factor = 2 ; plus sign
            45B: self->Zoom, factor = 0.5 ; minus sign
            41B: self->Contour, 0, /Toggle ; shift + number keys = contours
            33B: self->Contour, 1, /Toggle
            64B: self->Contour, 2, /Toggle
            35B: self->Contour, 3, /Toggle
            36B: self->Contour, 4, /Toggle
            37B: self->Contour, 5, /Toggle
            94B: self->Contour, 6, /Toggle
            38B: self->Contour, 7, /Toggle
            42B: self->Contour, 8, /Toggle
            40B: self->Contour, 9, /Toggle
            48B: self->Change_Image, 0 ; numbers keys = change image
            49B: self->Change_Image, 1
            50B: self->Change_Image, 2
            51B: self->Change_Image, 3
            52B: self->Change_Image, 4
            53B: self->Change_Image, 5
            54B: self->Change_Image, 6
            55B: self->Change_Image, 7
            56B: self->Change_Image, 8
            57B: self->Change_Image, 9
            99B: self->Contour, /Toggle ; c button - toggles contour display
            109B: BEGIN         ; m button - toggles mask display
                IF self.mask THEN BEGIN
; Draw normal display
                    self->Draw 
                    self.mask = 0B
                ENDIF ELSE BEGIN
; Draw mask
                    mask = self.regions->ComputeMask()
                    self.image->GetProperty, newposition = position, pix_newlimits = pix_newlimits
                    tvimage, mask[pix_newlimits[0]:pix_newlimits[1], pix_newlimits[2]:pix_newlimits[3]], position = position, /noint
                    self.mask = 1B
                ENDELSE
            END
            127B: self->Delete_Region ;Delete key
            ELSE:
        ENDCASE
    ENDIF
ENDIF ELSE BEGIN

; These are not ASCII keys - e.g. shift and control
    eventTypes = ['Shift', 'Control', 'Caps Lock', 'Alt', 'Left', 'Right', 'Up', 'Down', 'Page Up', 'Page Down', 'Home', 'End']
    thisEvent = eventTypes[event.key-1]

    CASE thisEvent OF
; These just set the flags
        'Shift': self.shift = event.press
        'Control': self.control = event.press

; Arrow  keys move the regions around
        'Left': IF event.press THEN self->Move_Region, 'Left' 
        'Right': IF event.press THEN self->Move_Region, 'Right'
        'Up': IF event.press THEN self->Move_Region, 'Up' 
        'Down': IF event.press THEN self->Move_Region, 'Down' 
        ELSE:
    ENDCASE
ENDELSE

END; Kang::Keyboard_Events----------------------------------------------------


;+
; Sets the focus to the draw window so keyboard events can be registered.
;
; :Private:
;
;-
PRO Kang::Set_Focus

Widget_Control, self.drawID, /Input_Focus
END; Kang::Set_Focus----------------------------------------------------------------


;+
; Responds to events from the main window
;
; :Private:
;
;-
PRO Kang::TLB_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Resize the draw widget
IF StrUpCase(!Version.OS_Family) NE 'UNIX' THEN BEGIN
    Widget_Control, self.drawID, XSize=event.x, YSize=event.y
    self.xsize = event.x
    self.ysize = event.y
ENDIF ELSE BEGIN
           
; This code added to work-around UNIX resize bug when
; TLB has a menu bar in IDL 5.2.
    Widget_Control, self.tlbID, TLB_GET_Size=newsize
    xdiff = newsize[0] - self.tlbsize[0]
    ydiff = newsize[1] - self.tlbsize[1]
    self.xsize = self.xsize + xdiff
    self.ysize = self.ysize + ydiff
    Widget_Control, self.drawid, XSize=self.xsize, YSize=self.ysize
ENDELSE
Widget_Control, self.tlbID, TLB_GET_Size=tlbsize
self.tlbsize = newsize
Widget_Control, self.drawID, Draw_XSize=self.xsize, Draw_YSize=self.ysize
       
; Adjust the sliders
Widget_Control, self.brightnessID, XSize = self.xsize
Widget_Control, self.contrastID, XSize = self.xsize

; Make a new pixmap window of the correct new size
WDelete, self.pix_wid
Window, /Pixmap, /Free, XSize=self.xsize, YSize=self.ysize
self.pix_wid = !D.Window
;WDelete, self.pix_wid2
;Window, /Pixmap, /Free, XSize=self.xsize, YSize=self.ysize
;self.pix_wid2 = !D.Window
;WDelete, self.pix_wid3
;Window, /Pixmap, /Free, XSize=self.xsize, YSize=self.ysize
;self.pix_wid3 = !D.Window

; Update with new aspect ratio
IF Obj_Valid(self.image) THEN BEGIN
    self.image->GetProperty, pix_newlimits = pix_newlimits
    self.current_pix[0] = (pix_newlimits[1] - pix_newlimits[0])/2. + pix_newlimits[0]
    self.current_pix[1] = (pix_newlimits[3] - pix_newlimits[2])/2. + pix_newlimits[2]

; Redraw
    self->Draw
ENDIF

END; Kang::TLB_Events--------------------------------------------------


;+
; Responds to mouse button down clicks - drawing or selecting a region
;
; :Private:
;
;-
PRO Kang::Down_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

CASE event.press OF
; Left mouse button down
    1: BEGIN
; Turn on the flags
        IF self.shift THEN BEGIN 
            self.drawingRegion = 0B
            self.selectingRegion = 1B 
        ENDIF ELSE BEGIN
            IF self.control THEN self.drawingRegion = 0B ELSE self.drawingRegion = 1B
        ENDELSE

; Detect double-clicks
;        IF event.clicks EQ 2 THEN self.doubleclick = 1B ELSE self.doubleclick = 0B 

; This bit of code accounts for when the user puts a box down, then
; changes the window size
        wset, self.pix_wid
        pix_xsize = !d.x_size
        pix_ysize = !d.y_size
        IF (pix_xsize NE self.xsize) OR (pix_ysize NE self.ysize) THEN BEGIN
            WDelete, self.pix_wid
            Window, /Free, /Pixmap, xsize = self.xsize, ysize = self.ysize
        ENDIF

; This is if user clicked outisde all regions
        self.initial_pix = self.current_pix
        self.initial_data = self.current_data

; Copy display over to main window
        self->Copy_Display

; Plot the axis to set axis ranges and make convert_coord work
        self.image->GetProperty, newlimits = newlimits, newposition = newposition
        xrange = [newlimits[0], newlimits[1]]
        yrange = [newlimits[2], newlimits[3]]
        plot, $
          [0], $
          /nodata, $
          Position = newposition, $
          XRange=xrange, $
          yrange = yrange, $
          xstyle = 5, $
          ystyle = 5, $
          /noerase

; Store the first point
        IF StrUpCase(self.regionType) EQ 'FREEHAND' THEN BEGIN
            Ptr_Free, self.polygon_pts
            self.polygon_pts = Ptr_New(self.current_pix)
        ENDIF
    END
    
; Right button down
    4: BEGIN
        self.right_click = 1B
        self.initial_device = [event.x, event.y]
    ENDCASE

    ELSE: RETURN
ENDCASE

END; Kang::Down_Events----------------------------------------------------


;+
; Responds to mouse button release events - done drawing or selecting a region
;
; :Private:
;
;-
PRO Kang::Up_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

CASE event.release OF
; Left mouse button up           
    1: BEGIN

; This block of code is for when the user is selecting regions by
; holding and dragging the left mouse button
        IF self.selectingRegion THEN BEGIN
            self.selectingRegion = 0B
            self->Copy_Display

; Determine if the selection box selects any regions
            hits =  self.regions->ContainsRegions(self.initial_pix[0], self.initial_pix[1], $
                                                  self.current_pix[0], self.current_pix[1])  

; Clear selected regions if click is outside all regions
            IF hits[0] EQ -1 THEN BEGIN
                self.regions->Select, /None
            ENDIF ELSE BEGIN
                self.regions->GetProperty, selected_regions = selected_regions
; Remove the -1 if it exists
                IF selected_regions[0] EQ -1 THEN selected_regions = hits ELSE selected_regions = [selected_regions, hits]

; Find uniq elements of the array
                self.regions->Select, selected_regions
            ENDELSE

; Update the widget
            self->Update_Regions_Info, /List_Update
            self->Draw
        ENDIF

; Select the regions if shift is help down
        IF self.control THEN BEGIN

; Find which regions are selected by click
            hits =  self.regions->Contains_Points(self.current_pix[0], self.current_pix[1])

; Clear selected regions if click is outside all regions
            IF hits[0] EQ -1 THEN BEGIN
                self.regions->Select, /None
            ENDIF ELSE BEGIN
                self.regions->GetProperty, selected_regions = selected_regions

; If nothing was previously selected, use the hits
                IF selected_regions[0] EQ -1 THEN selected_regions = hits ELSE BEGIN
                    overlap = where(hits[0] EQ selected_regions, complement = nonoverlap)

; Remove region from selection if it was already selected, add it if
; it wasn't already selected
                    IF overlap[0] EQ -1 THEN selected_regions = [selected_regions, hits] ELSE BEGIN
                        IF nonoverlap[0] NE -1 THEN selected_regions = selected_regions(nonoverlap) ELSE selected_regions = -1
                    ENDELSE
                ENDELSE
; Sort array
                self.regions->Select, selected_regions
            ENDELSE

; Update the widget
            self->Draw
            self->Update_Regions_Info
        ENDIF ELSE BEGIN

; Clear any events queued for widget.
            IF ~self.drawingRegion THEN RETURN
            self.drawingregion = 0
            Widget_Control, self.drawID, Clear_Events=1

; Just erase the box if the user just clicked up and down
            IF ((self.initial_pix[0] EQ self.current_pix[0]) AND (self.initial_pix[1] EQ self.current_pix[1]) $
                AND (StrUpCase(self.regionType) NE 'CROSS') AND (StrUpCase(self.regionType) NE 'THRESHOLD') $
                AND (StrUpCase(self.regionType) NE 'TEXT')) THEN BEGIN
                self->Copy_Display

; Also need to clear input structure
                self.initial_data = [0., 0.]
                self.final_data = [0., 0.]
                self.initial_pix = [0., 0.]
                self.final_pix = [0., 0.]
                RETURN
            ENDIF

; Store the values
            self.final_data = self.current_data
            self.final_pix = self.current_pix

; Make some strings for the regions
            str_xinitial = StrTrim(self.initial_data[0], 2)
            str_yinitial = StrTrim(self.initial_data[1], 2)
            str_xfinal = StrTrim(self.final_data[0], 2)
            str_yfinal = StrTrim(self.final_data[1], 2)
            
            distance_pix = ((self.final_pix[0]-self.initial_pix[0])^2.+(self.final_pix[1]-self.initial_pix[1])^2.)^.5
            distance_data = ((self.final_data[0]-self.initial_data[0])^2.+(self.final_data[1]-self.initial_data[1])^2.)^.5
            str_distance_data = StrTrim(distance_data,2)

;--------------------------------------------------
; Write to the string array
            CASE StrUpCase(self.regionType) OF
                'BOX': BEGIN
                    width = abs(self.initial_data[0] - self.final_data[0])
                    height = abs(self.initial_data[1] - self.final_data[1])
                    xcenter = (self.initial_data[0] < self.final_data[0]) + width/2.
                    ycenter = (self.initial_data[1] < self.final_data[1]) + height/2.
                    self->Make_Region, 'Box', [xcenter, ycenter, width, height, 0]
                END
                
                'CIRCLE': self->Make_Region, 'Circle', [self.initial_data[0], self.initial_data[1], distance_data]
                
                'CROSS': self->Make_Region, 'Cross', [self.initial_data[0], self.initial_data[1], distance_data, 0.]

                'ELLIPSE': BEGIN
; Compute major and minor axis
                    xydistance_data = Abs(self.initial_data-self.final_data)
                    self->Make_Region, 'Ellipse', [self.initial_data[0], self.initial_data[1], xydistance_data[0],  xydistance_data[1], 0.]
                END
                
                'LINE': self->Make_Region, 'Line', [self.initial_data[0], self.initial_data[1], self.final_data[0], self.final_data[1]]

                'FREEHAND': BEGIN
                    data  = self.image->Convert_Coord((*self.polygon_pts)[0, *], (*self.polygon_pts)[1, *], old_coord = 'Image')
                    self->Make_Region, 'Freehand', data
                END
;                'POLYGON': BEGIN
;                    self.regions->GetProperty, n_regions=n_regions
;                    self.regions->GetProperty, text=thisregion, position=n_regions-1
;                    thisregion = StrTrim(thisregion, 2)
;                    IF thisRegion EQ '' THEN BEGIN
;                        thisRegion = 'polygon,'+str_xfinal+','+str_yinitial 
;                        self.regions_objects[self.whichRegion[self.whichImage], self.whichImage]->$
;                          ReplaceData, [self.current_pix[0], self.current_pix[1]]
;                    ENDIF ELSE BEGIN
;                        thisRegion = thisregion + ',' +str_xfinal+','+str_yinitial
;                        self.regions_objects[self.whichRegion[self.whichImage], self.whichImage]->$
;                          AppendData, [self.current_pix[0], self.current_pix[1]]
;                    ENDELSE
;                END

                'TEXT': BEGIN
; Bring up dialog
                    text = Kang_Textbox(Title='Provide Region Text', Group_Leader=self.tlbID, $
                                             Label='Text: ', Cancel=cancelled, XSize=200, Value='');, $
;                                             XOffset = event.x, YOffset = event.y)
                    IF StrCompress(text, /Remove_All) EQ '' THEN RETURN
                    self->Make_Region, 'Text', self.final_data, text = text
                END
                
                'THRESHOLD': BEGIN
; Find the thresholds
                    pixvalue = self.image->Integrate(self.current_pix[0], self.current_pix[1])
                    self.histogram->GetProperty, lowscale = lowscale, highscale = highscale, maxscale = maxscale
                    threshold_high = maxscale*1.1
                    range = highscale - lowscale
                    threshold_low = (range*(5/6.) + lowscale) < (pixvalue * 0.8)

; Create region
                    self->Make_Region, 'Threshold', [self.current_data[0], self.current_data[1], threshold_low, threshold_high]
                END
            ENDCASE
        ENDELSE
    END

    2: self->Zoom, self.current_pix[0], self.current_pix[1], factor = 1, /cursor, /Pixel

; Buton Release of 4 means the right mouse button to display context menu      
    4: BEGIN
; This updates values so we can test for point containment later
        self->Motion_Events, event

; Don't bring up context menu is adjusting stretch
        self.right_click = 0B
        IF self.adjustingStretch THEN BEGIN 
            self.adjustingStretch = 0B
            self->Draw
            RETURN
        ENDIF

; Right click up and down
        IF self.plot_Type NE 'None' THEN BEGIN
            self.plot_type = 'None'

; Set checkmarks
            Widget_Control, self.xplotID, Set_Button = 0
            Widget_Control, self.yplotID, Set_Button = 0
            Widget_Control, self.zplotID, Set_Button = 0
            Widget_Control, self.noneID, Set_Button = 1
            RETURN
        ENDIF

; Cycle through regions to see if the click hits a selected region.
; If so, use all selected regions.  If not, use only the region that
; was clicked inside
        hits =  self.regions->Contains_Points(self.current_pix[0], self.current_pix[1])
        self.regions->GetProperty, selected_regions = selected_regions

; Find the intersection of the selected_regions and the hits
;        inside = -1
;        IF hits[0] NE -1 AND selected_regions[0] NE -1 THEN BEGIN
;            overlap = -1
;            overlap = max(where(hits EQ 1))
;            IF overlap NE -1 THEN inside = 0
;        ENDIF

; IF user clicked outside all regions, use the hits as the selected regions
;        IF inside EQ -1 THEN BEGIN
;            self.regions->Select, max(hits)
; Update the widget
;            self->Update_Regions_Info
;        ENDIF

; Set some variables for later
        IF total(hits) GT 0 THEN BEGIN
            self.inside = 1
            self.whichInside = max(where(hits EQ 1))
        ENDIF ELSE BEGIN
            self.inside = 0
            self.whichInside = -1
        ENDELSE

; Create the buttons for the context menu.
        self.image->GetProperty, pix_limits = pix_limits
        contextBase = Widget_Base(self.drawID, /Context_Menu, Event_Pro = 'Kang_Context_Events')
        IF pix_limits[5] GT 0 THEN BEGIN
            spectrumButton = Widget_Button(contextBase, Value = 'Extract Spectrum')
            DefSysV, '!B', Exists = b_exists
            IF b_exists THEN exportButton = Widget_Button(contextBase, Value = 'Export to TMBIDL')
        ENDIF

; Buttons if inside a region
        IF self.inside THEN BEGIN
; I'm going to piggyback on the plot_params event handler here
            regionButton = Widget_Button(contextBase, Value = 'Region Properties', /Menu)
            colorID = Widget_Button(regionButton, Value = 'Color', /Checked_Menu)
            widthIDs = LonArr(10)
            widthID = Widget_Button(regionButton, Value = 'Width', /Menu)
            widthIDs[0] = Widget_Button(widthID, Value = '1', UValue = 'Width', /Checked_Menu)
            widthIDs[1] = Widget_Button(widthID, Value = '2', UValue = 'Width', /Checked_Menu)
            widthIDs[2] = Widget_Button(widthID, Value = '3', UValue = 'Width', /Checked_Menu)
            widthIDs[3] = Widget_Button(widthID, Value = '4', UValue = 'Width', /Checked_Menu)
            widthIDs[4] = Widget_Button(widthID, Value = '5', UValue = 'Width', /Checked_Menu)
            widthIDs[5] = Widget_Button(widthID, Value = '6', UValue = 'Width', /Checked_Menu)
            widthIDs[6] = Widget_Button(widthID, Value = '7', UValue = 'Width', /Checked_Menu)
            widthIDs[7] = Widget_Button(widthID, Value = '8', UValue = 'Width', /Checked_Menu)
            widthIDs[8] = Widget_Button(widthID, Value = '9', UValue = 'Width', /Checked_Menu)
            widthIDs[9] = Widget_Button(widthID, Value = '10', UValue = 'Width', /Checked_Menu)
            linestyleID = Widget_Button(regionButton, value = 'Linestyle', /Menu)
            linestyleIDs = intArr(6)
            linestyleIDs[0] = Widget_Button(linestyleID, Value = '0', UValue = 'Linestyle', /Checked_Menu)
            linestyleIDs[1] = Widget_Button(linestyleID, Value = '1', UValue = 'Linestyle', /Checked_Menu)
            linestyleIDs[2] = Widget_Button(linestyleID, Value = '2', UValue = 'Linestyle', /Checked_Menu)
            linestyleIDs[3] = Widget_Button(linestyleID, Value = '3', UValue = 'Linestyle', /Checked_Menu)
            linestyleIDs[4] = Widget_Button(linestyleID, Value = '4', UValue = 'Linestyle', /Checked_Menu)
            linestyleIDs[5] = Widget_Button(linestyleID, Value = '5', UValue = 'Linestyle', /Checked_Menu)
            includeID = Widget_Button(regionButton, Value = 'Include', /Checked_Menu, /Separator)
            excludeID = Widget_Button(regionButton, Value = 'Exclude', /Checked_Menu)
            sourceID = Widget_Button(regionButton, Value = 'Source', /Checked_Menu, /Separator)
            backgroundID = Widget_Button(regionButton, Value = 'Background', /Checked_Menu)
            polygonID = Widget_Button(regionButton, Value = 'Polygon', /Checked_Menu, /Separator)
            lineID = Widget_Button(regionButton, Value = 'Line', /Checked_Menu)

; Set buttons
            self.regions->GetProperty, interior = exclude, source = source, polygon = polygon, thick = width, $
              linestyle = linestyle, position = max(where(hits EQ 1))
            Widget_Control, widthIDs[width-1], Set_Button=1
            Widget_Control, linestyleIDs[linestyle], Set_Button=1
            IF exclude THEN Widget_Control, excludeID, Set_Button = 1 ELSE Widget_Control, includeID, Set_Button = 1
            IF source THEN Widget_Control, sourceID, Set_Button = 1 ELSE Widget_Control, backgroundID, Set_Button = 1
            IF polygon THEN Widget_Control, polygonID, Set_Button = 1 ELSE Widget_Control, lineID, Set_Button = 1

            analysisButton = Widget_Button(contextBase, Value = 'Analysis', /Menu)
            plotButton = Widget_Button(analysisButton, Value = 'Plot Region')
;            profileButton = Widget_Button(analysisButton, Value = 'Fit Profile')

;            IF pix_limits[5] GT 0 THEN BEGIN
;                velocityfieldButton = Widget_Button(contextBase, Value = 'Velocity Field', $
;                                                    Event_Pro = 'Kang_Velocity_Field_Events')
;            ENDIF
            zoomButton = Widget_Button(contextBase, Value = 'Zoom to Region')
        ENDIF

; Recentering button
        recenterButton = Widget_Button(contextBase, Value = 'Recenter Here')

; Display the GUI.
        Widget_DisplayContextMenu, event.ID, event.X, event.Y, contextBase
    END

; This is for IDL<7.0
    8: self->Zoom, self.current_pix[0], self.current_pix[1], factor = 2, /cursor, /Pixel
    16: self->Zoom, self.current_pix[0], self.current_pix[1], factor = 0.5, /cursor, /Pixel

    ELSE: stop;RETURN
ENDCASE

END; Kang::Up_Events--------------------------------------------------------


;+
; Responds to mouse motion events
;
; :Private:
;
;-
PRO Kang::Motion_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF

; Get variables out
WSet, self.wid
self.image->GetProperty, pix_newlimits = pix_newlimits, pix_limits = pix_limits, $
  newposition = newposition, native_coords = native_coords, current_coords = current_coords, $
  newlimits = newlimits, XTitle = XTitle, YTitle = ytitle, BarTitle = Bartitle, $
  xsize = image_xsize, ysize = image_ysize, velocity = velocity, astr = astr, $
  limits = limits, sexadecimal = sexadecimal

; Set plotting system
plot, [0], XRange = [pix_newlimits[0]-0.5, pix_newlimits[1]+0.5], $
      YRange = [pix_newlimits[2]-0.5, pix_newlimits[3]+0.5], $
      XStyle=5, YStyle=5, /NoData, /NoErase, position = newposition
pixvals = convert_coord(event.x, event.y, /Device, /To_Data)
self.current_pix = [pixvals[0], pixvals[1]]

; Constrain current pix
self.current_pix[0] = (self.current_pix[0] < pix_limits[1]) > 0.
self.current_pix[1] = (self.current_pix[1] < pix_limits[3]) > 0.

; Now convert to data locations
IF StrUpCase(native_coords) NE 'IMAGE' THEN BEGIN
    xy2ad, self.current_pix[0], self.current_pix[1], astr, a, d
    self.current_data = self.image->Convert_Coord(a, d)
ENDIF ELSE self.current_data = self.current_pix

; Don't display anything if off the image
IF self.current_pix[0] GT pix_limits[1] OR $
  self.current_pix[1] GT pix_limits[3] OR $
  self.current_pix[0] LT pix_limits[0] OR $
  self.current_pix[1] LT pix_limits[2] THEN BEGIN
;    str_convert_array = ['           ', '            ']
;    str_value = '          '
    value = 0.
ENDIF ELSE value = self.image->Integrate(self.current_pix[0], self.current_pix[1])

; Update the values
Widget_Control, self.xvalueID, Set_Value = self.current_pix[0]
Widget_Control, self.yvalueID, Set_Value = self.current_pix[1]
IF sexadecimal THEN BEGIN
    long = sixty(self.current_data[0])
    lat = sixty(self.current_data[1])

; Determine if its negative - otherwise sign will be on minutes or seconds 
    IF sign(long[0]) EQ -1 OR sign(long[1]) EQ -1 OR sign(long[2]) EQ -1 $
      THEN longsign = '-' ELSE longsign = '+'
    IF sign(lat[0]) EQ -1 OR sign(lat[1]) EQ -1 OR sign(lat[2]) EQ -1 $
      THEN latsign = '-' ELSE latsign = '+'
    long = abs(long)
    lat = abs(lat)

; Create strings
    str_long = longsign + string(long[0], format = '(I3)') + ':' + string(long[1], format = '(I2)') + ':' + $
               string(long[2], format = '(F6.3)')
    str_lat = latsign + string(lat[0], format = '(I3)') + ':' + string(lat[1], format = '(I2)') + ':' + $
              string(lat[2], format = '(F6.3)')

; Replace ' ' with '0'
    data = [str_long, str_lat]
    data = RepStr(data, ' ', '0')
ENDIF ELSE data = String(self.current_data, format = '(F7.3)')
Widget_Control, self.longvalueID, Set_Value = data[0]
Widget_Control, self.latvalueID, Set_Value = data[1]
Widget_Control, self.valueID, Set_Value = Value

; Region Drawing
IF self.drawingRegion THEN BEGIN
    self->Copy_Display
    plot, [0], XRange = [pix_newlimits[0]-0.5, pix_newlimits[1]+0.5], $
          YRange = [pix_newlimits[2]-0.5, pix_newlimits[3]+0.5], $
          XStyle=5, YStyle=5, /NoData, /NoErase, position = newposition

    CASE self.regionType OF
        'Box': Plots, [self.initial_pix[0], self.initial_pix[0], self.current_pix[0], $
                       self.current_pix[0], self.initial_pix[0]], $
                   [self.initial_pix[1], self.current_pix[1], self.current_pix[1], $
                    self.initial_pix[1], self.initial_pix[1]], $
                   Color=self.drawingcolor, thick = self.regions_width, linestyle = self.regions_linestyle

        'Circle': BEGIN
            data = Kang_Circle(self.initial_pix[0], self.initial_pix[1], $
                               ((self.initial_pix[0]-self.current_pix[0])^2. + $
                                (self.initial_pix[1]-self.current_pix[1])^2.)^.5)

            plots, data[0,*], data[1,*], color=self.drawingcolor, thick = self.regions_width, $
                   linestyle = self.regions_linestyle
        END
        
        'Ellipse': BEGIN
            data = Kang_Ellipse(self.initial_pix[0],  self.initial_pix[1], $
                                Abs(self.initial_pix[0]-self.current_pix[0]), $
                                Abs(self.initial_pix[1]-self.current_pix[1]), 0)
            plots, data[0,*], data[1,*], color=self.drawingcolor, thick = self.regions_width, $
                   linestyle = self.regions_linestyle
        END
        'Cross': BEGIN
            size = (((self.initial_pix[0]-self.current_pix[0])^2.+(self.initial_pix[1]-self.current_pix[1])^2.)^.5)
            plots, [self.initial_pix[0]-size, self.initial_pix[0]+size], [self.initial_pix[1], self.initial_pix[1]], $
                   color = self.drawingcolor, thick = self.regions_width, linestyle = self.regions_linestyle
            plots, [self.initial_pix[0], self.initial_pix[0]], [self.initial_pix[1]-size, self.initial_pix[1]+size], $
                   color = self.drawingcolor, thick = self.regions_width, linestyle = self.regions_linestyle
        END
        
        'Line': plots, [self.initial_pix[0], self.current_pix[0]], [self.initial_pix[1], self.current_pix[1]], $
                       color = self.drawingcolor, thick = self.regions_width, linestyle = self.regions_linestyle

        'Text':

        'Threshold': 
        
        'Freehand': BEGIN
            *self.polygon_pts = [[*self.polygon_pts],  [[self.current_pix[0], self.current_pix[1]]]]
            plots, *self.polygon_pts, color = self.drawingColor, thick = self.regions_width, $
                   linestyle = self.regions_linestyle
        END
        
        'Polygon': plots, [self.initial_pix[0], self.current_pix[0]], $
                          [self.initial_pix[1], self.current_pix[1]], self.drawingcolor, $
                          thick = self.regions_width, linestyle = self.regions_linestyle

        'Annulus': 
    ENDCASE
ENDIF

; Region Selection-----------------------------------------
IF self.selectingRegion THEN BEGIN
    self->Copy_Display
    plot, [0], XRange = [newlimits[0], newlimits[1]], YRange = [newlimits[2], newlimits[3]], $
          XStyle=5, YStyle=5, /NoData, /NoErase, position = newposition
    
; Draw box
    Plots, [self.initial_data[0], self.initial_data[0], self.current_data[0], self.current_data[0], self.initial_data[0]], $
           [self.initial_data[1], self.current_data[1], self.current_data[1], self.initial_data[1], self.initial_data[1]], $
           Color=self.selectingcolor, linestyle = 2
ENDIF

; Interactive plots
IF self.plot_Type NE 'None' THEN BEGIN
    self->Plot_Windows_Widget
    self->Copy_Display
    plot, [0], XRange = [newlimits[0], newlimits[1]], YRange = [newlimits[2], newlimits[3]], $
          XStyle=5, YStyle=5, /NoData, /NoErase, position = newposition
    self.histogram->GetProperty, lowscale = lowscale, highscale = highscale
    WSet, self.wid

; Set titles
    IF bartitle EQ '' THEN bartitle = 'Pixel Value'
    IF xtitle EQ '' THEN xtitle = 'X Value'

; Set correct tab
    Widget_Control, self.windows_tabBase, Set_Tab_Current = 2
ENDIF

bgcolor = self.colors->Colorindex('black')
CASE self.plot_Type OF
    'XPlot': BEGIN
; Plot line
        plots, [newlimits[0], newlimits[1]], [self.current_data[1], self.current_data[1]], color = self.drawingcolor

; Calculate x and y values
        xvals = scale_vector(findgen(image_xsize), newlimits[0], newlimits[1])
        yvals = self.image->Find_Values(lindgen(pix_limits[1]), self.current_pix[1])

; Plot
        WSet, self.plot_wid
        Plot, xvals, yvals, XTitle = XTitle, YTitle = barTitle, /XStyle, Title = 'Y = ' + StrTrim(self.current_data[1], 2), $
              XRange =  [newlimits[0], newlimits[1]], YRange = [lowScale, highScale], background = bgcolor
        plots, [self.current_data[0], self.current_data[0]], !y.crange, color = self.drawingcolor
    END

    'YPlot': BEGIN
; Plot line
        plots, [self.current_data[0], self.current_data[0]], [newlimits[2], newlimits[3]], color = self.drawingcolor

; Calculate x and y values
        xvals = scale_vector(findgen(image_ysize), newlimits[2], newlimits[3])
        yvals = self.image->Find_Values(self.current_pix[0], lindgen(pix_limits[3]))

; Plot
        WSet, self.plot_wid
        Plot, xvals, yvals, XTitle = XTitle, YTitle = barTitle, Title = 'X = ' + StrTrim(self.current_data[0], 2), /XStyle, $
              XRange =  [newlimits[2], newlimits[3]], YRange = [lowScale, highScale], background = bgcolor
        plots, [self.current_data[1], self.current_data[1]], !y.crange, color = self.drawingcolor
    END

    'ZPlot': BEGIN
        IF pix_limits[5] GT 0 THEN BEGIN
; Find x and y values
            xvals = scale_vector(findgen(pix_limits[5]), limits[4], limits[5])
            yvals = self.image->Find_Values(self.current_pix[0], self.current_pix[1], lindgen(pix_limits[5]+1))
            WSet, self.plot_wid
            Plot, xvals, yvals, XTitle = 'Velocity', YTitle = barTitle, /XStyle, YRange = [lowScale, highScale], $
                  XRange =  [newlimits[4], newlimits[5]], $
                  Title = 'X = ' + StrTrim(self.current_data[0], 2) + '   Y = ' + StrTrim(self.current_data[1], 2), $
                  background = bgcolor
            Plots, velocity, !y.crange, color = self.drawingcolor
        ENDIF
    END
    'None':
ENDCASE

; Draw in the zoom window
IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN BEGIN
    WSet, self.zoom_pix_wid
    self.image->Zoom_Draw, self.current_pix[0], self.current_pix[1], pix_newlimits = pix_newlimits
    plot, [0], XRange = pix_newlimits[0:1] + [0.5, -0.5], YRange = pix_newlimits[2:3] + [0.5, -0.5], $
          XStyle=5, YStyle=5, /NoData, /NoErase, position = [0, 0, 1, 1]
    self.regions->Draw

; Copy display to prevent flickering
    WSet, self.zoom_wid
    Device, Copy=[0,0,100, 100, 0, 0, self.zoom_pix_wid]

; Change back the main window
    WSet, self.wid
ENDIF

; Adjusting Stretch
IF self.right_click THEN BEGIN
    brightness_distance = event.x - self.initial_device[0]
    contrast_distance = event.y - self.initial_device[1]

; If user has moved more than 2 pixels, adjusting stretch is assumed
    IF ~self.adjustingStretch THEN BEGIN
        IF (brightness_distance^2. + contrast_distance^2.)^0.5 GT 2 THEN self.adjustingstretch = 1B
    ENDIF

; Adjust stretch
    IF self.adjustingStretch THEN self->Stretch, brightness = event.x / float(self.xsize), contrast = event.y / float(self.ysize), $
      /nocontours,/nostars
ENDIF

; Is cursor over a box on edge of region?
IF Ptr_Valid(self.regionBoxes) THEN BEGIN
    regionbox = where(event.x EQ (*self.regionboxes)[0, *] AND event.y EQ (*self.regionboxes)[1, *])
    IF regionbox[0] NE -1 THEN BEGIN
        IF StrUpCase(!Version.OS_Family) EQ 'UNIX' THEN Device, Cursor_Standard = 120
        print, 'Region', regionbox
    ENDIF
ENDIF

; Is cursor over a region?
;hits = self->Contains_Points(self.current_pix[0], self.current_pix[1], coords = 'Image', count = n_hits)
;IF n_hits GT 0 THEN BEGIN
;    self.regions->GetProperty, position = hits[n_hits-1], name = name
;    IF StrTrim(name, 2) NE '' THEN Widget_Control, self.drawID, Tooltip = name
;ENDIF ELSE Widget_Control, self.drawID, Tooltip = 0B

END; Kang::Motion_Events---------------------------------------------


;--------------------------------------------------------------------------------
; Menubar Events
;--------------------------------------------------------------------------------
;+
; Loads a fits file specified by the filename
;
; :Private:
;
;-
PRO Kang::Load_FileName, filename, good_image = good_image, noplot = noplot
; Reads in the filenames, sends onwards
; good_image is 1 if valid, 0 if not

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

IF N_Elements(filename) EQ 0 THEN BEGIN
; Bring up dialog
    filter = [['*.fits;*.fit;*.fits.gz;*.fit.gz;*.FIT;*.FITS;*.FIT.gz;*.FITS.gz', $
               '*.fits;*.fit;*.FIT;*.FITS', $
               '*.fits.gz;*.fit.gz;*.FIT.gz, *.FITS.gz', $
               '*'], $
              ['All FITS files', 'Uncompressed', 'Compressed', 'All Files']]
    filename = Dialog_pickfile(/read, filter = filter, /must_exist, $
                               file = self.lastFilename, $
                               title='Please Select a Fits File', $
                               Get_Path=thispath, Path=self.lastpath, $
                               dialog_parent = self.tlbID, /Multiple_Files) 

; If canceled, filename will be ''
    IF filename[0] NE '' THEN BEGIN
; Store filenames
        self.lastpath = thispath
        self.lastfilename = filename[0]
    ENDIF ELSE RETURN
ENDIF

; Load files in
nfiles = N_Elements(filename)
good_image = BytArr(nfiles)
FOR i = 0, nfiles-1 DO BEGIN
    IF file_test(filename[i], /Read) THEN BEGIN ; Check if file exists
; Read in image, send array to kang_load_image
        Widget_Control, /HourGlass      
        self->Load_Image, filename[i], noplot = noplot
        Widget_Control, HourGlass=0
        good_image = 1B
    ENDIF ELSE BEGIN
; File doesn't exist
        print, 'ERROR: The file ' + filename + ' cannot be found. Check spelling.'
        good_image = 0B
    ENDELSE
ENDFOR

END; Kang::Load_FileName-----------------------------------------------------


;+
; Loads an array specified by the filename
;
; :Private:
;
;-
PRO Kang::Load_Array_Events

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Bring up dialog to get the names of the arrays
arrayNames = Kang_Textbox(Title='Load Array From Main Level', Group_Leader=self.tlbID, $
                     Label=['Array Name: ',  'Header Name: '], Cancel=cancelled, XSize=100)
IF cancelled THEN RETURN
IF arrayNames[0] EQ '' THEN RETURN

; Read in the arrays from the main level
; Routine_Names has the ability to return a variable from the main
; level. See Craig Markwardt's documentation
IF N_Elements(Routine_Names(arrayNames[0], Fetch=1)) GT 0 THEN BEGIN
    image = Routine_Names(arrayNames[0], Fetch=1)          
    filename = arraynames[0]

; Check image
    s = size(image)
    IF s[0] LT 2 OR s[1] LT 3 OR s[2] LT 3 THEN BEGIN
        Print, 'ERROR: Variable is not an image.'
        RETURN
    ENDIF
ENDIF ELSE BEGIN
    Print, 'ERROR: Array does not exist at main level. Check spelling.'
    RETURN
ENDELSE

; Headers
IF arraynames[1] NE '' THEN BEGIN
    IF N_Elements(Routine_Names(arraynames[1], Fetch=1)) GT 0 THEN BEGIN
        header = Routine_Names(arraynames[1], Fetch=1) 

; Check header
        IF size(header, /tname) NE 'STRING' THEN BEGIN
            Print, 'ERROR: Header is not valid.'
            RETURN
        ENDIF
    ENDIF ELSE BEGIN
        Print, 'ERROR: Header does not exist at main level. Check spelling.'
        RETURN
    ENDELSE
ENDIF ELSE BEGIN
;    ranges = Kang_Textbox(Title='Image Ranges', Group_Leader=tlbID, $
;                     Label=['XMin: ',  'XMax: ', 'YMin:', 'YMax:'], Cancel=cancelled, XSize=10, /Float, /Modal)
ENDELSE

; Load the array and header
self->Load_Image, image, header, filename = filename

END; Kang_Load_Array_Events---------------------------------------------------------------


;+
; Loads an array and header.
;
; :Private:
;
;-
PRO Kang::Load_Image, image, header, filename = filename, good_image = good_image, noplot = noplot

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Check if image is good
;image_type = size(image, /TName)
;IF image_type EQ 'POINTER' THEN image_size = size(*image, /Dim) $
;   ELSE newimage_size = size(newimage, /Dim)
;IF (newimage_size[0] GT 3) AND (newimage_size[1] GT 3) THEN checkfile = 1

; --------------------------------Load the Image---------------------------
oimage = Obj_New('Kang_Image', image, header, filename = filename)

; Load titles, create histogram
oimage->Default_Titles
oimage->SetProperty, title = ''
oimage->Histogram, histvals=histvals, bins=bins
self.image_container->Add, oimage

; ----------------------------------Histogram---------------------------------
; Draw histogram in the draw window. This also finds the max and min
; of the image and sets the threshold
histogram= Obj_New('kang_histogram', histogram=histvals, bins=bins, $
                   Event_Pro = 'Kang_Histogram_Events', drawID = self.histogram_drawID, $
                   wid = self.histogram_wid, pix_wid = self.histogram_pix_wid)
self.histogram_container->Add, histogram

; Set some parameters from the histogram
histogram->GetProperty, lowScale=lowscale, highScale=highscale, histramp = histramp

; ----------------------------------Colors---------------------------------------
; Create the colors object
; These are the names of available colors for drawing
colornames = ['white', ' pink', 'red', 'maroon', 'magenta', 'tomato', 'orange', 'yellow', $
              'green yellow', 'spring green', 'green', 'olive drab', $
              'powder blue', 'steel blue', 'blue', 'cyan', 'navy', 'violet', 'purple', $
              'saddle brown', 'burlywood', 'beige', 'light gray', $
              'medium gray', 'gray', 'dark gray', 'charcoal', 'black']

; Create colors object, load the "heat" color table and the colornames
colors = Obj_New('Kang_Colors', colornames=colornames, colorindex = 3)
self.colors_container->Add, colors
colors->GetProperty, NColors=NColors
histogram->SetProperty, plot_color = colors->ColorIndex('White'), $
  low_color = colors->ColorIndex('Green'), $
  high_color = colors->ColorIndex('Blue'), $
  back_color = colors->ColorIndex('Black')
axisColor = colors->ColorIndex('Black')
backColor = colors->ColorIndex('White')
tickColor = colors->ColorIndex('Black')
self.drawingcolor = colors->ColorIndex('Yellow')
self.selectingColor = colors->ColorIndex('White')
self.regions_color = colors->ColorIndex(self.regions_cName)

; Store colors
oimage->SetProperty, axisColor = axisColor, AxisCname = 'Black', backColor = backColor, backCname = 'White', $
  tickColor = tickColor, tickCname = 'Black', NColors = NColors

;---------------------------Regions------------------------------
oimage->GetProperty, astr = astr
regions= Obj_New('Kang_Region_Container', color_obj = self.colors, image_obj = oimage)
self.regions_container->Add, regions

;---------------------------------------------------------------------
; Add to show pointer
n_images = self.image_container->count()
;IF n_images EQ 1 THEN self.show = Ptr_New([1B]) ELSE *self.show =[*self.show, 1B]

; Bytscale the image
oimage->BytScl, lowscale, highscale

; Bring up file dialog, change the variables
changeimage = n_images-1
self->Change_Image, changeImage, noplot = noplot

; Turn on events
IF self.realized THEN BEGIN
    Widget_Control, self.drawID, /Draw_Button_Events, /Draw_Motion_Events, Draw_Keyboard_Events = 2, /Input_Focus
    Widget_Control, self.tlbID, /KBRD_Focus_Events

; Change sensitivity of main window in case this is the first image
    Widget_Control, self.editID, Sensitive=1
    Widget_Control, self.colorsID, Sensitive=1
    Widget_Control, self.scalingID, Sensitive=1
    Widget_Control, self.zoomID, Sensitive=1
    self.image->GetProperty, current_coords = coords
    IF StrUpCase(coords) NE 'IMAGE' THEN Widget_Control, self.regionsID, Sensitive=1
    Widget_Control, self.coordinatesID, Sensitive=1
    Widget_Control, self.analysisID, Sensitive=1

; Add widget button
;    button = Widget_Button(self.showHideID, Value = 'Frame ' + StrTrim(n_images-1, 2), /Checked)

; Bring up dialog
;    self->File_Dialog_Widget

; Bring up velocity sliders
    self.image->GetProperty, type = type
    IF type EQ 'Cube' OR type EQ 'Cube Array' THEN self->Velocity_Widget, self.whichImage
ENDIF

;RETURN, 1B
; increment whichimage?
good_image = 1B

self->Plot_Params_Widget

END ;Kang::Load_Image----------------------------------------------------------------


;+
; Brings up a dialog that has the FITS header
;
; :Private:
;
;-
PRO Kang::Show_Header, event
; Brings up a text box with the header inside

; Check if it's already defined
IF XRegistered('Kang_Header ' + StrTrim(self.tlbID, 2) + ' ' + StrTrim(self.whichImage,2)) THEN RETURN

; Create widget
self.image->GetProperty, filename = filename, header = header
tlb = Widget_Base(Title = filename + ' header', group_leader = self.tlbID, /TLB_Size_Events)
textID = Widget_Text(tlb, XSize = 80, YSize = 30, /scroll, Value = header)

; Realize the widget. UValue is the text ID
Widget_Control, tlb, Set_UValue = textID, /Realize
XManager, 'Kang_Header ' + StrTrim(self.tlbID, 2) + ' ' + StrTrim(self.whichImage,2), tlb, $
          Event_Handler = 'Kang_Show_Header_Events', /No_Block

END; Kang::Show_Header-----------------------------------------------------------------


;+
; :Private:
;
;-
PRO Kang_Menubar_Zoom, event
; Zoom from the menubar if user doesn't have 3-button mouse

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
ENDIF
Widget_Control, event.id, Get_Value=buttonValue

self.image->GetProperty, pix_newlimits = pix_newlimits
self.current_pix[0] = (pix_newlimits[1]-pix_newlimits[0]+1) / 2. + pix_newlimits[0]-0.5
self.current_pix[1] = (pix_newlimits[3]-pix_newlimits[2]+1) / 2. + pix_newlimits[2]-0.5

CASE buttonValue OF
    'Zoom In': Kang_Zoom, factor = 2, /No_Cursor
    'Zoom Out': Kang_Zoom, factor = 0.5, /No_Cursor
ENDCASE

END;Kang_Menubar_Zoom--------------------------------------------------------------------------------


;+
; Responds to events from the XColors dialog
;
; :Private:
;
;-
PRO Kang::XColors_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
ENDIF

; What kind of event is this: button or color table loading?
thisEvent = Tag_Names(event, /Structure_Name)
CASE thisEvent OF
    'WIDGET_BUTTON': BEGIN
; Load the current color vectors.
        self.colors->TVLCT

; Create an unique title for the XColors program. Assign
; it to the top-level base widget.
        colorTitle = self.windowtitle + " (" + StrTrim(self.wid,2) + ")"
        Widget_Control, self.tlbID, TLB_Set_Title = colorTitle

; Store old colors in case the load is cancelled
        self.old_colors = Obj_New('Kang_Colors')

; Call XColors with NOTIFYID to alert widgets when colors change.
        self.colors->GetProperty, NColors=NColors
        XColors, NColors = NColors, Group_Leader=self.tlbID, $
                 NotifyID=[event.id, self.tlbID], Title=colortitle + ' Colors', /NoSliders
    END

    'XCOLORS_LOAD': BEGIN
; The XCOLORS load was cancelled
        IF event.index EQ -1 THEN BEGIN
            self.old_colors->GetProperty, red=r, green=g, blue=b
            self.colors->SetProperty, red=r, green=g, blue=b
        ENDIF ELSE BEGIN
;Update colors
            self.colors->GetProperty, NColors=NColors
            self.colors->SetProperty, red=event.r[0:NColors-1], $
              green=event.g[0:NColors-1], blue=event.b[0:NColors-1], colorindex = event.index
        ENDELSE

; Redisplay the graphic
        self.colors->TVLCT
        self->Draw
    END
ENDCASE

END; Kang::XColors_Events--------------------------------------------------


;----------------------------------------------------------------------
; Events from the other widgets
;----------------------------------------------------------------------
;+
; Responds to events from the file dialog
;
; :Private:
;
;-
PRO Kang_File_Dialog_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
ENDIF

; These are button events, get the button values
Widget_Control, event.id, Get_UValue=buttonValue
buttonName = event.value
selectName = event.select
Widget_Control, event.top, Get_UValue=self

; Get the unique four letter name of the button out        
CASE StrUpCase(StrMid(buttonName, 0, 4)) OF
    'DEL_': BEGIN
; Find which delete button was pressed
        whichDelete = StrMid(buttonName, 4, 1)

; Delete image
        self->Delete, whichDelete
    END
            
    'PLOT': BEGIN
; Change all the variables around
        newimage = StrMid(buttonName, 4, 1)
        self->Change_Image, newimage
    END
            
    'CONT':  IF selectName THEN self->Contour,StrMid(buttonName, 7, 1), /On $
             ELSE self->Contour,StrMid(buttonName, 7, 1), /Off

;    'PLPA': BEGIN
;        whichPlot_Params = StrMid(buttonName, 5, 1)
;        whichPlot_Params = Fix(whichPlot_Params)
; The file dialog holds the tlbID
;        self->Plot_Params_Widget
;    END

;    'VELP': BEGIN
;        whichVelocity = StrMid(buttonName, 6, 1)
;        self->Velocity_Widget, whichVelocity
;    END

;    'LOAD': Print, 'load'

;    'RGBP': BEGIN
;        whichbutton = StrMid(buttonName, 4, 1)
;        Kang_Make_RGB_Define, tlbID, whichbutton, Group_Leader=tlbID
;        info.colors[whichbutton] = Obj_New('kang_colors')
;    END
ENDCASE

END; Kang_File_Dialog_Events--------------------------------------------------


;+
; Sets the properties of the distogram display
;
; :Private:
;
;-
PRO Kang::Histogram_Properties, autoupdate = autoupdate, linear = linear, log = log, unzoom = unzoom, zoom = zoom
; Handles basic functions of the histogram display

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok= Error_Message()
ENDIF

IF N_Elements(autoupdate) NE 0 THEN self.histogram->SetProperty, autoupdate = autoupdate
IF N_Elements(linear) NE 0 THEN self.histogram->SetProperty, log = ~linear
IF N_Elements(log) NE 0 THEN self.histogram->SetProperty, log = log
IF Keyword_Set(unzoom) THEN self.histogram->FullRange
IF Keyword_Set(zoom) THEN self.histogram->Zoom

; Redraw the histogram plot
self.histogram->Draw

END; Kang::Histogram------------------------------------------------------------


;+
; :Private:
;
;-
PRO Kang_Context_Events, event

Widget_Control, event.top, Get_UValue = self
self->Context_Events, event

END; Kang_Context_Events

;+
; Handles events from the context menu
;
; :Private:
;
;-
PRO Kang::Context_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(/Traceback)
   RETURN
ENDIF

; Get self object reference
Widget_Control, event.ID, Get_Value = buttonValue

CASE buttonValue OF
    'Plot Region': self->Histogram_Region
    'Zoom to Region': self->Zoom_Region
    'Extract Spectrum': self->Extract_Spectrum, self.current_pix[0], self.current_pix[1], position = self.whichInside, /pixel
    'Export to TMBIDL': self->Extract_Spectrum, self.current_pix[0], self.current_pix[1], position = self.whichInside, /tmbidl
    'Fit Profile': self->Select_Profile_Region

    'Recenter Here': self->Zoom, self.current_pix[0], self.current_pix[1], factor = 1, /cursor, /Pixel

    'Include': self->Region_Property, /Include, position = self.whichInside
    'Exclude': self->Region_Property, /Exclude, position = self.whichInside
    'Source': self->Region_Property, /Source, position = self.whichInside
    'Background': self->Region_Property, /Background, position = self.whichInside
    'Polygon': self->Region_Property, /Polygon, position = self.whichInside
    'Line': self->Region_Property, /Linepar, position = self.whichInside
    'Color': self->Region_Property, /Color, position = self.whichInside
    
    ELSE: BEGIN
; Width and linestyle
        Widget_Control, event.ID, Get_UValue = uval
        CASE uval OF
            'Width': self->Region_Property, width = Fix(buttonValue), position = self.whichInside
            'Linestyle': self->Region_Property, linestyle = Fix(buttonValue), position = self.whichInside
            ELSE:
        ENDCASE
    END
ENDCASE

END; Kang_Context_Events------------------------------------------------------------


;+
; Responds to events from the plot parameters dialog
;
; :Private:
;
;-
PRO Kang_Plot_Params_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(/Traceback)
   RETURN
ENDIF

; Get self object reference
Widget_Control, event.top, Get_UValue=self
Widget_Control, event.ID, Get_UValue = uval
eventName = Tag_Names(event, /Structure_Name)
IF eventName EQ 'WIDGET_BUTTON' THEN Widget_Control, event.ID, Get_Value = buttonValue

; Branch on button value
CASE uval OF
    'Tab': self->Tab_Events, event.tab ; Plot parameters tabs

;--------------Scale----------------
    'Low Scale': BEGIN
        self->GetProperty, highscale = highscale
        self->Scale, Float(*event.value), highscale
    END
    'High Scale': BEGIN
        self->GetProperty, lowscale = lowscale
        self->Scale, lowscale, Float(*event.value)
    END
    '99.99%': self->Scale, percent = 99.99
    '99.9%': self->Scale, percent = 99.9
    '99%': self->Scale, percent = 99.
    '98%': self->Scale, percent = 98
    'Percent Slider': BEGIN
        self->GetProperty, autoupdate = autoupdate
        IF event.drag EQ 0 OR autoUpdate THEN noupdate = 0 ELSE noupdate = 1
        self->Scale, percent = event.value, noupdate = noupdate
    END
    'Scale to Image': self->Scale, /Scale_To_Image
    'Zoom':  self->Histogram_Properties, /Zoom 
    'Unzoom': self->Histogram_Properties, /UnZoom
    'Linear Axis': BEGIN
        self->Histogram_Properties, /Linear
        Widget_Control, event.ID, Set_Value = '  Log Axis  ', Set_UValue = 'Log Axis'
    END
    'Log Axis': BEGIN
        self->Histogram_Properties, /Log
        Widget_Control, event.ID, Set_Value = ' Linear Axis ', Set_UValue = 'Linear Axis'
    END
    'Auto Update': self->Histogram_Properties, autoupdate = event.select

;--------------Limits----------------
    'Limits': BEGIN
        event.objref->GetProperty, UValue = limits_arr
        limits_arr[0]->GetProperty, Value = xmin
        limits_arr[1]->GetProperty, Value = xmax
        limits_arr[2]->GetProperty, Value = ymin
        limits_arr[3]->GetProperty, Value = ymax

; Store values
        self->Limits, xmin, xmax, ymin, ymax 
    END
    'Pix Limits': BEGIN
        event.objref->GetProperty, UValue = limits_arr
        limits_arr[0]->GetProperty, Value = xmin
        limits_arr[1]->GetProperty, Value = xmax
        limits_arr[2]->GetProperty, Value = ymin
        limits_arr[3]->GetProperty, Value = ymax

; Store values
        self->Limits, xmin, xmax, ymin, ymax, /pixel
    END
    'Align to Image 0': self->Align, 0
    'Align to Image 1': self->Align, 1
    'Align to Image 2': self->Align, 2
    'Align to Image 3': self->Align, 3

; --------------Axis-----------------
    'Default': self->Axis, /Default_Titles
    'Title': self->Axis, title = *event.value
    'XTitle': self->Axis, ytitle = *event.value
    'YTitle': self->Axis, xtitle = *event.value
    'BarTitle': self->Axis, bartitle = *event.value
    'SubTitle': self->Axis, subtitle = *event.value
    'Clear': self->Axis, /Clear_Titles
    'No Axis': self->Axis, noaxis = event.select
    'No Colorbar': self->Axis, nobar = event.select
    'Axis Color': self->Axis, axiscolor = event.color
    'Background Color': self->Axis, backcolor = event.color
    'Tick Color': self->Axis, tickcolor = event.color
    'Font': self->Axis, font = event.index+1
    'Axis Apply': self->Axis, /Apply

;-----------Contours----------------
    'Levels': self->Contour, levels = *event.value, percent = 0 ; self->contour, /Apply
    'NLevels': self->Contour, nlevels = event.index+1, /percent
    'Percent': self->Contour, percent = ~event.value
    'Downhill': self->Contour, downhill = event.select
    'Contour Apply' : self->Contour, /Apply

;-------------Regions--------------------
    'List': BEGIN
; User clicked inside the list widget. Update selected regions tag
        selected_regions = Widget_Info(event.ID, /LIST_SELECT)
        self->Select, selected_regions
        IF event.clicks EQ 2 THEN print, 'Double click!!!'
    END
    
    'Write': self->Write_Region
    'Histogram': self->Histogram_Region
    'Zoom to Region': self->Zoom_Region
    'Threshold Image': self->Threshold_Image

    'Delete': self->Delete_Region
    'Name': BEGIN
        Widget_Control, event.id, Get_Value = name
        self->Region_Property, name = name
    END
    'Angle': self->Rotate_Region, event.value
    'Angle Textbox': self->Rotate_Region, *event.value
    'Region Color': self->Region_Property, color = event.color
    'Region Width': self->Region_Property, width = event.index+1
    'Region Linestyle': self->Region_Property, linestyle = event.index
    'Threshold High': self->Threshold_events,  event
    'Threshold Low': self->Threshold_events,  event

    'Region Exclude': self->Region_Property, exclude = event.value
    'Region Source': self->Region_Property, source = ~event.value
    'Region Type': self->Region_Property, polygon = ~event.value

    'Invert':; BEGIN
;        info.threshold_invert[whichplot_params] = event.select
;        Widget_Control, tlbID, Set_UValue=info, /No_Copy
;    END
    ELSE:
ENDCASE

END; Kang_Plot_Params_Events------------------------------------------------------------


;+
;
; :Private:
;
;-
PRO Kang_Histogram_Events, event
; Responds to events in the histogram draw window.  The histogram
; object will return a lowscale and a highscale.
; Sends onwards

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(/Traceback)
   RETURN
ENDIF

Widget_Control, event.top, Get_UValue=self
self->Histogram_Events, event
END; Kang_Histogram_Events--------------------------------------------------


;+
; Responds to events from the plot parameters dialog when the tabs are
; changed
;
; :Private:
;
; :Params:
;  newTab : in, required, type = 'integer'
;    The new tab index
;
;-
PRO Kang::Tab_Events, newTab

self.currentTab = newTab
END; Kang::Tab_Events--------------------------------------------------------------------------------


;+
; Events from the small widgets for each region.  Just forwards them onward.
;
; :Private:
;
;-
PRO Kang_Individual_Region_Widget_Events, event

Widget_Control, event.top, Get_UValue=self
self->Individual_Region_Widget_Events, event

END; Kang_Individual_Region_Widget_Events----------------------------------------


;+
; :Private:
;-
PRO Kang::Individual_Region_Widget_Events, event

; Branch on the user value of the event
Widget_Control, event.id, Get_UValue = UValue
Widget_Control, event.handler, Get_UValue = IDs

CASE UValue OF
    'Box': BEGIN
        Widget_Control, IDs.Box_xID, Get_Value = xcenter
        Widget_Control, IDs.Box_yID, Get_Value = ycenter
        Widget_Control, IDs.Box_widthID, Get_Value = width
        Widget_Control, IDs.Box_heightID, Get_Value = height

        self.regions->GetProperty, angle = angle
        params = [xcenter, ycenter, width, height, angle[0]]
        self->Make_Region, 'Box', params, data = data, /noobject
    END

    'Circle': BEGIN
        Widget_Control, IDs.Circle_xID, Get_Value = xcenter
        Widget_Control, IDs.Circle_yID, Get_Value = ycenter
        Widget_Control, IDs.Circle_radiusID, Get_Value = radius

        params = [xcenter, ycenter, radius]
        self->Make_Region, 'Circle', params, data = data, /noobject
    END

    'Ellipse': BEGIN
        Widget_Control, IDs.Ellipse_xID, Get_Value = xcenter
        Widget_Control, IDs.Ellipse_yID, Get_Value = ycenter
        Widget_Control, IDs.Ellipse_semimajorID, Get_Value = semimajor
        Widget_Control, IDs.Ellipse_semiminorID, Get_Value = semiminor

        self.regions->GetProperty, angle = angle
        params = [xcenter, ycenter, semimajor, semiminor, angle]
        self->Make_Region, 'Ellipse', params, data = data, /noobject
    END

    'Line': BEGIN
        Widget_Control, IDs.line_p1_xID, Get_Value = p1_x 
        Widget_Control, IDs.line_p1_yID, Get_Value = p1_y
        Widget_Control, IDs.line_p2_xID, Get_Value = p2_x
        Widget_Control, IDs.line_p2_yID, Get_Value = p2_y

        params = [p1_x, p1_y, p2_x, p2_y]
        self->Make_Region, 'Line', params, data = data, /noobject
    END

    'Text': BEGIN
        Widget_Control, IDs.text_xID, Get_Value = xcenter
        Widget_Control, IDs.text_yID, Get_Value = ycenter
        Widget_Control, IDs.text_textID, Get_Value = text

        params = [xcenter, ycenter]
        self->Make_Region, 'Text', params, data = data, /noobject

        self.regions->SetProperty, text = text
    END

    'Threshold High': self->Threshold_Events, event, IDs
    'Threshold Low': self->Threshold_Events, event, IDs


    ELSE:
ENDCASE

; Update the region
self.regions->SetProperty, params = params, data = data

; Update display
self->Draw
self->Update_Regions_info, /List_Update, /No_Slider_Update

END; Kang::Individual_Region_Widget_Events----------------------------------------

;+
; Responds to events from the velocity widget
;
; :Private:
;
;-
PRO Kang_Velocity_Events, event
; Events from the velocity dialog - just passes them onward
; The self object is stored in the uvalue of the widget
Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(/Traceback)
   RETURN
ENDIF

; Get info out
Widget_Control, event.top, Get_UValue=velocityinfo
whichVelocity = velocityinfo.whichVelocity
self = velocityinfo.self

; Branch on the user value of the event
Widget_Control, event.id, Get_UValue = UValue

CASE UValue OF
; Velocity slider
    'Vel_Slider': self->Velocity, event.value, whichImage = whichVelocity, /pixel, /nosliderupdate

; Velocity text box
    'Vel_Text': self->Velocity, *event.value, whichImage = whichVelocity

; Deltavel slider
    'Deltavel_Slider': self->Velocity, deltavel = event.value, whichImage = whichVelocity, /pixel, /nosliderupdate

; Deltavel text box
    'Deltavel_Text': self->Velocity, deltavel = *event.value, whichImage = whichVelocity

; These are low velocity text box events
    'LowVel': BEGIN
; Get values
        velocityinfo.highvel->GetProperty, Value=highvel
        self->Velocity, Float(*event.value), highvel, whichImage = whichVelocity
    END

; These are high velocity events
    'HighVel': BEGIN
; Get values
        velocityinfo.lowvel->GetProperty, Value=lowvel
        self->Velocity, Float(*event.value), highvel, whichImage = whichVelocity
    END

; These are the velocity buttons along the bottom of the widget
    'Button': BEGIN
        Widget_Control, event.id, Get_Value=buttonValue
        self->Velocity, deltavel = buttonValue * 1000., whichImage = whichVelocity
    END
ENDCASE

END; Kang_Velocity_Events-------------------------------------------------------------------


;+
; Packages up events from the draw window. These events are from
; zooming and have event.xrange and event.yrange parameters
;
; :Private:
;
;-
PRO Kang_Draw_Spectra_Events, event

Widget_Control, event.top, Get_UValue = self

; Set new limits
self->Spectrum_Property, xrange = event.xrange, yrange = event.yrange

END; Kang_Draw_Spectra_Events-----------------------------------------------------------


;+
; Packages up events from the draw window. These events are from
; zooming and have event.xrange and event.yrange parameters
;
; :Private:
;
;-
PRO Kang_Draw_Minispectra_Events, event

Widget_Control, event.top, Get_UValue = self

; Set new limits
self->Draw_Minispectra, xrange = event.xrange, yrange = event.yrange

END; Kang_Draw_Spectra_Events-----------------------------------------------------------


;+
; Fits a 2D model to the data enclosed in a region.  Basically just a
; wrapper for Craig Markwardt's mpfit2dpeak.  Keywords are
; basically the same as in his program.
;
; :Params:
;  fitparams : out, optional, type = fltarr(7)
;    Parameters output from the fit
;      [0]   Constant baseline level
;      [1]   Peak value
;      [2]   Peak half-width (x) -- gaussian sigma or half-width at
;                                   half-max in arcseconds
;      [3]   Peak half-width (y) -- gaussian sigma or half-width at
;                                   half-max in arcseconds
;      [4]   Peak centroid (x)
;      [5]   Peak centroid (y)
;      [6]   Rotation angle in degrees if TILT keyword set
;      [7]   Moffat power law index if MOFFAT keyword set;
;
;  error : out, optional, type = fltarr(7)
;    Errors in fitparams
;
; :Keywords:
;  weights : in, optional, type = 'fltarr'
;    Array of weights to be used in calculating the
;    chi-squared value.  If WEIGHTS is specified then the ERR
;    parameter is ignored.  The chi-squared value is computed
;    as follows:
;
;        CHISQ = TOTAL( (Z-MYFUNCT(X,Y,P))^2 * ABS(WEIGHTS) )
;
;    Here are common values of WEIGHTS:
;
;        1D/ERR^2 - Normal weighting (ERR is the measurement error)
;        1D/Y     - Poisson weighting (counting statistics)
;        1D       - Unweighted
;
;    The ERROR keyword takes precedence over any WEIGHTS
;    keyword values.  If no ERROR or WEIGHTS are given, then
;    the fit is unweighted.
;
;  circular : in, optional, type = 'boolean'
;    If set, then the peak profile is assumed to be
;    azimuthally symmetric.  When set, the parameters A[2)
;    and A[3) will be identical and the TILT keyword will
;    have no effect.
;
;  tilt : in, optional, type = 'boolean'
;    If set, then the major and minor axes of the peak profile
;    are allowed to rotate with respect to the image axes.
;    Parameter A[6] will be set to the clockwise rotation angle
;    of the A[2] axis in radians.
;
;  dof : out, optional, type = 'integer'
;    Number of degrees of freedom, computed as
;      DOF = N_ELEMENTS(DEVIATES) - NFREE
;
;  chisq : out, optional, type = 'float'
;    The value of the summed squared residuals for the
;    returned parameter values.
;
;  fitType : in, optional, type = 'string'
;    String specifying type of fit to use.  Options are:
;      Gaussian, Lorentzian, Moffat, or Ellipse.  Defaults to Gaussian.
;
;-
PRO Kang::Fit_Profile, fitType, fitparams, error, weights=weights, $
  circular = circular, tilt = tilt, dof = dof, chisq=chisq, baseline = baseline, peak = peak, $
  semiaxes = semiaxes, center = center, orientation = orientation
; Fits a 2D profile to selected region

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(/Traceback)
   RETURN
ENDIF

IF N_Elements(fitType) EQ 0 THEN fitType = 'Gaussian'

; Get object reference
self.regions->GetProperty, selected_regions = selected_regions
oregion = self.regions->Get(position = selected_regions)
self.profile_region = oregion[0]

; Find pixel ranges
self.profile_region->GetProperty, xrange = xrange, yrange = yrange
self.image->GetProperty, pix_limits = pix_limits
xrange = [floor(xrange[0]) > 0, ceil(xrange[1]) < pix_limits[1]]
yrange = [floor(yrange[0]) > 0, ceil(yrange[1]) < pix_limits[3]]
pix_newlimits = [xrange, yrange]

; Create mask
dim = [pix_newlimits[1]-pix_newlimits[0], pix_newlimits[3]-pix_newlimits[2]] + 1
dim = [pix_limits[1], pix_limits[3]] + 1
mask = self.profile_region->ComputeMask(dimensions = dim)

; Do the fitting
IF StrUpCase(fitType) EQ 'ELLIPSE' THEN BEGIN
    self.regions->Fit_Ellipse, center = center, orientation = orientation, semiaxes = semiaxes
    baseline = 0
    peak = 0

ENDIF ELSE BEGIN
    zfit = self.image->Fit2DPeak(fitparams, error, pix_newlimits = pix_newlimits, fittype=fittype, weights=1D, $
                                 circular = circular, tilt = tilt, dof = dof, chisq=chisq, $
                                 Gaussian = StrUpCase(fitType) EQ 'GAUSSIAN', Lorentzian = StrUpCase(fitType) EQ 'LORENTZIAN', $
                                 Moffat = StrUpCase(fitType) EQ 'MOFFAT')
    
    baseline = fitparams[0]
    peak = fitparams[1]
    semiaxes = fitparams[2:3]
    center = fitparams[4:5]
    orientation = fitparams[6]
ENDELSE


;--------------------------------------------------------------------------------
; Update profile widget
; Get info out
IF ~XRegistered('Kang_Profile ' + StrTrim(self.tlbID, 2)) THEN RETURN
Widget_Control, self.profile_WidgetID, Get_UValue = uval

; Update labels
self.image->GetProperty, bartitle = bartitle, fitParams = fitParams, fiterror = error
newlimits = self.image->Convert_Coord(pix_newlimits[0:1], pix_newlimits[2:3], old_coord = 'image')

Widget_Control, uval.baselineID, Set_Value = String(baseline) + ' +/- ' + StrCompress(error[0]) + ' ' + bartitle
Widget_Control, uval.peakID, Set_Value = String(peak) + ' +/- ' + StrCompress(error[1]) + ' ' + bartitle
Widget_Control, uval.peak_xwidthID, Set_Value = String(semiaxes[0]) + ' +/- ' + StrCompress(error[2]) + '"'
Widget_Control, uval.peak_ywidthID, Set_Value = String(semiaxes[1]) + ' +/- ' + StrCompress(error[3]) + '"'
Widget_Control, uval.xcenterID, Set_Value = String(center[0]) + ' +/- ' + StrCompress(error[4]) + ' deg.'
Widget_Control, uval.ycenterID, Set_Value = String(center[1]) + ' +/- ' + StrCompress(error[5]) + ' deg.'
Widget_Control, uval.angleID, Set_Value = String(orientation) + ' +/- ' + StrCompress(error[6]*!radeg)
;IF Keyword_Set(moffat) THEN Widget_Control, uval.indexID, Set_Value = String(a[7]) + ' +/- ' + StrCompress(error[7]) ELSE $
;  Widget_Control, uval.indexID, Set_Value = ''

; Draw image
self.colors->GetProperty, ncolors = ncolors
image = self.image->Extract2(pix_newlimits = pix_newlimits)
wset, uval.data_wid
erase
position = [0., 0., 1., 1.]
tvimage, bytscl(image, min = lowscale, max = highscale, top = ncolors-1), /keep, /noint, position = position

; Draw cross and ellipse
plot, [0], xrange = [newlimits[0], newlimits[2]], yrange = [newlimits[1], newlimits[3]], $
      xstyle = 5, ystyle = 5, /nodata, /noerase, position = position
plots, center[0], center[1], psym=1, symsize = 4, color = self.regions_color
data = Kang_Ellipse(center[0], center[1], semiaxes[0], semiaxes[1], orientation)
plots, data[0 ,*], $            ; / (xrange[1]-xrange[0]+1) * (position[2]-position[0]), $
       data[1, *], $            ; / (yrange[1]-yrange[0]+1) * (position[3]-position[1]), /norm, 
       color = self.regions_color

; Draw model and residuals
wset, uval.model_wid
erase
tvimage, bytscl(zfit, min = lowscale, max = highscale, top = ncolors-1), /keep, /noint
wset, uval.residual_wid
erase
residual = image - zfit
;        tvimage, bytscl(residual, min = min(residual), max = max(residual), top = ncolors-1), /keep, /noint
tvimage, bytscl(residual, min = lowscale, max = highscale, top = ncolors-1), /keep, /noint

wset, uval.cuts_wid
erase
nPoints = 200
plot, data[0, *]-center[0], data[1, *]-center[1]
x1 = center[0]*cos(orientation / !radeg)
y1 = center[0]*sin(orientation / !radeg)
x2 = -x1
y2 = -y1
xloc = x1 + (x2 - x1) * Findgen(nPoints) / (nPoints - 1) + semiaxes[0]
yloc = y1 + (y2 - y1) * Findgen(nPoints) / (nPoints - 1) + semiaxes[1]
    
data_profile = Interpolate(image, xloc, yloc)
model_profile = Interpolate(zfit, xloc, yloc)
residual_profile = data_profile-model_profile
yrange = [min([data_profile, model_profile, residual_profile]), max([data_profile, model_profile])]

plot, data_profile, yrange = yrange, ystyle=2, xstyle=2, position=[0.15, 0.15, 0.95, 0.95], /nodata
oplot, data_profile, color = 250
oplot, model_profile, linestyle=2, color = 250
oplot, data_profile-model_profile, linestyle=3, color = 250

x1 = center[0]*cos(orienatation / !radeg)
y1 = -center[0]*sin(orientation / !radeg)
x2 = -x1
y2 = -y1
xloc = x1 + (x2 - x1) * Findgen(nPoints) / (nPoints - 1) + semiaxes[0]
yloc = y1 + (y2 - y1) * Findgen(nPoints) / (nPoints - 1) + semiaxes[1]
    
data_profile = Interpolate(image, xloc, yloc)
model_profile = Interpolate(zfit, xloc, yloc)
residual_profile = data_profile-model_profile
yrange = [min([data_profile, model_profile, residual_profile]), max([data_profile, model_profile])]

;        oplot, data_profile, color = 250
;        oplot, model_profile, linestyle=2, color = 250
;        oplot, data_profile-model_profile, linestyle=3, color = 250
;    END

END; Kang::Fit_Profile------------------------------------------------------------------


;+
; Responds to events from the profile dialog
;
; :Private:
;
;-
PRO Kang_Profile_Events, event
; Events from the profile fitting dialog

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Get self structure
Widget_Control, event.top, Get_UValue = uval
self = uval.self

eventName = Tag_Names(event, /Structure_Name)
IF eventName EQ 'WIDGET_BUTTON' THEN BEGIN
    Widget_Control, event.ID, Get_Value = buttonName

    CASE buttonName OF
        '  Fit  ': BEGIN
; Get values out of dialog
            fittype = uval.profile->GetSelection()
            circular = Widget_Info(uval.circularID, /Button_Set)
            tilt = Widget_Info(uval.tiltID, /Button_Set)
            self->Fit_Profile, fitType = fitType, circular = circular, tilt = tilt
        END
        
        'Create Region': BEGIN
            Widget_Control, event.top, Get_UValue = uval
            Widget_Control, uval.tlbID, Get_UValue = self

; Get values out of widget
            Widget_Control, uval.peak_xwidthID, Get_Value = xwidth
            Widget_Control, uval.peak_ywidthID, Get_Value = ywidth
            Widget_Control, uval.xcenterID, Get_Value = xcenter
            Widget_Control, uval.ycenterID, Get_Value = ycenter
            Widget_Control, uval.angleID, Get_Value = angle

; Create ellipse region
            self->Make_Region, 'Ellipse', [xcenter, ycenter, xwidth/3600., ywidth/3600., angle]
        END
        
        'Print Fit': BEGIN
            self->GetProperty, fitParams = fitParams
            print, fitParams
        END
        ELSE: 
    ENDCASE
ENDIF ELSE BEGIN
; Droplist events

ENDELSE

END; Kang_Profile_Events--------------------------------------------------------------------------------


;+
; Events from the profile fitting dialog
;
; :Private:
;
;-
PRO Kang_Velocity_Field_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Only take Button events
eventName = Tag_Names(event, /Structure_Name)
CASE eventName OF
    'WIDGET_DROPLIST': BEGIN
        Widget_Control, event.top, Get_UValue = uval
        ngauss = event.index+1

; Make boxes sensitive
        IF ngauss GT 1 THEN Widget_Control, uval.break1ID, sensitive=1 ELSE $
          Widget_Control, uval.break1ID, sensitive=0
        IF ngauss GT 2 THEN Widget_Control, uval.break2ID, sensitive=1 ELSE $
          Widget_Control, uval.break2ID, sensitive=0
        IF ngauss GT 3 THEN Widget_Control, uval.break3ID, sensitive=1 ELSE $
          Widget_Control, uval.break3ID, sensitive=0
        IF ngauss GT 4 THEN Widget_Control, uval.break4ID, sensitive=1 ELSE $
          Widget_Control, uval.break4ID, sensitive=0
        IF ngauss GT 5 THEN Widget_Control, uval.break5ID, sensitive=1 ELSE $
          Widget_Control, uval.break5ID, sensitive=0
    END
    
    'WIDGET_BUTTON': BEGIN
        Widget_Control, event.ID, Get_Value = buttonName

        CASE buttonName OF
            'Velocity Field': BEGIN
                tlbID = event.top

; Bring up dialog if it isn't already up
                IF ~XRegistered('Kang_Velocity_Field' + StrTrim(tlbID, 2)) THEN BEGIN
                    Kang_Velocity_Field, {TOP:tlbID}
                    Widget_Control, tlbID, Get_UValue = info
                ENDIF
                Widget_Control, tlbID, Get_UValue = info

; Store region
                info.regions->GetProperty, selected_regions = selected_regions
                oregion = info.regions->Get(position = selected_regions)
                info.profile_region = oregion[0]

; Set sensitivity of fit button back
                Widget_Control, info.velfieldID, Get_UValue = uval
                Widget_Control, uval.fitID, Sensitive=1 

; Calculate the velocity for the x-axis in the plot
                info.image->GetProperty, limits = limits, pix_limits = pix_limits, pix_newlimits = pix_newlimits, bartitle = bartitle, astr = astr
                n_vel = pix_limits[5]-pix_limits[4]+1
                vel_array = scale_vector(findgen(n_vel), limits[4], limits[5]) / 1000.

; Create spectrum
                dim = [pix_limits[1]-pix_limits[0]+1, pix_limits[3]-pix_limits[2]+1]
                indices = info.profile_region->Find_Indices(dimensions = dim[0:1], astr = astr)
                IF N_Elements(indices) EQ 1 THEN BEGIN
                    indices = array_indices([pix_newlimits[1]+1, pix_newlimits[3]+1], indices, /Dim)
                    spectrum = info.image->Make_Spectrum(indices[0], indices[1], xvals = vel_array)
                ENDIF ELSE BEGIN
                    Widget_Control, Hourglass=1
                    spectrum = info.image->Make_Spectrum(indices, xvals = vel_array, stddev = stddev)
                    Widget_Control, Hourglass=0
                ENDELSE

; Draw spectrum
                WSet, uval.spectrum_wid
                plot, vel_array, spectrum, /xstyle, ystyle=3, Title = 'Average Spectrum', XTitle = 'Velocity (km/s)'
            END

            '  Fit  ': BEGIN
                Widget_Control, event.top, Get_UValue = uval
                Widget_Control, /Hourglass

; Get values out of dialog
                nGauss = Widget_Info(uval.nGauss, /DropList_Select)
                invert = Widget_Info(uval.invertID, /Button_Set)
                uval.lowrange->GetProperty, value = lowrange
                uval.highrange->GetProperty, value = highrange
                Widget_Control, uval.tlbID, Get_UValue = info

; Find pixel ranges
                info.image->GetProperty, astr = astr, image = image, pix_limits = pix_limits, pix_newlimits = pix_newlimits, $
                  limits = limits, vel_astr = vel_astr

; Find velocity limits
                IF StrTrim(lowrange, 2) EQ 'NULLVALUE' THEN lowrange = limits[4]/1000.
                IF StrTrim(highrange, 2) EQ 'NULLVALUE' THEN highrange = limits[5]/1000.
                pix_lowrange = Round((lowrange*1000. - vel_astr.crval)/vel_astr.cdelt + vel_astr.crpix - 1) > 0
                pix_highrange = Round((highrange*1000. - vel_astr.crval)/vel_astr.cdelt + vel_astr.crpix - 1) < pix_limits[5]

; Draw on spectrum
                WSet, uval.spectrum_wid
                oplot, [pix_lowrange, pix_lowrange], [0, 2]
                oplot, [pix_highrange, pix_highrange], [0, 2]

; Find image limits
                info.profile_region->GetProperty, xrange = xrange, yrange = yrange
                ad2xy, xrange[1], yrange[0], astr, x0, y0
                ad2xy, xrange[1], yrange[1], astr, x1, y1
                ad2xy, xrange[0], yrange[0], astr, x2, y2
                ad2xy, xrange[0], yrange[1], astr, x3, y3
                xrange = Round(minmax([x0, x1, x2, x3]))
                yrange = Round(minmax([y0, y1, y2, y3]))

; Create mask
                dim = size(image, /dim)
                mask = info.profile_region->ComputeMask(dimensions = dim[0:1], astr = astr)
                image[where(mask EQ 0)] = 0

; Get image
                image = image[xrange[0]>0:xrange[1]<pix_limits[1], yrange[0]>0:yrange[1] < pix_limits[3], *]
                dim = size(image, /dim)

; Define arrays
                height = fltarr(dim[0:1])
                center = fltarr(dim[0:1])
                width = fltarr(dim[0:1])

; Fit Gaussians
                nchan = pix_highrange-pix_lowrange+1
                gauss_x = scale_vector(findgen(nchan), lowrange*1000., highrange*1000.)/1000.
                weightf=fltarr(nchan)+1.0   
                FOR i = 0, dim[0]-1 DO BEGIN
                    FOR j = 0, dim[1]-1 DO BEGIN
                        gauss_y = image[i, j, pix_lowrange:pix_highrange]
                        a = [2, 45, 10]
                        yfit = mpcurvefit(gauss_x,gauss_y,$
                                          weightf, a, sigmaa, $
                                          function_name="mgauss",$
                                          chisq=chisq,itmax=500,quiet=1)
;                wset, 0
;                plot, gauss_x, gauss_y
;                oplot, gauss_x, yfit, linestyle=2
;                wait, 0.1

; Store values
                        height[i,j] = a[0]
                        center[i,j] = a[1]
                        width[i, j] = a[2]
                    ENDFOR
                ENDFOR

; Get some plotting parameters
                info.histogram->GetProperty, lowscale = lowscale, highscale = highscale
                info.colors->GetProperty, ncolors = ncolors

; Plot
                wset, uval.height_wid
                erase
                TVImage, bytscl(height, min = lowscale, max = highscale, top = ncolors-1), /keep, /noint
                wset, uval.width_wid
                erase
                TVImage, bytscl(width, min = min(width), max = max(width), top = ncolors-1), /keep, /noint
                wset, uval.center_wid
                erase
                TVImage, bytscl(center, min = min(center), max = max(center), top = ncolors-1), /keep, /noint

                Widget_Control, Hourglass=0
            END
            ELSE:
        ENDCASE
    END
ENDCASE

END ; Kang_Velocity_Field_Events--------------------------------------------------------------------------------


;+
; Responds to events draw windows
;
; :Private:
;
;-
PRO Kang::Draw_Window_Events, event
; This is the event handler for the draw widget graphics window.
; Handles mouse events

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; What kind of event is this?
eventTypes = ['DOWN', 'UP', 'MOTION', 'VIEWPORT', 'FOCUS', 'KEYS', 'KEYS', 'SCROLL']
thisEvent = eventTypes[event.type]

; We want to create motion events all the time so info.current is
; actually current
self->Motion_Events, event

CASE thisEvent OF
    'DOWN': self->Down_Events, event
    'UP': self->Up_Events, event
    'KEYS': self->Keyboard_Events, event
    'SCROLL': BEGIN
; In IDL 7.0, they changed this so 7 is middle button
; clicks = 1 for middle upwards, -1 for downwards
        IF event.clicks EQ 1 THEN BEGIN
            self->Zoom, self.current_pix[0], self.current_pix[1], factor = 2, /cursor, /Pixel
        ENDIF ELSE BEGIN
            self->Zoom, self.current_pix[0], self.current_pix[1], factor = 0.5, /cursor, /Pixel
        ENDELSE
    END
    ELSE:
ENDCASE

END; Kang_Draw_Window_Events-------------------------------------------------------------


;+
; These events arise from events in the plot, spectrum or minispectrum
; windows.  They could be zoom in events, or changing the size events.
;
; :Private:
;
;-
PRO Kang_Plot_Windows_TLB_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Branch on the event type
thisEvent = Tag_Names(event, /Structure_Name)
CASE thisEvent OF
; User changed the size of the base
    'WIDGET_BASE': BEGIN   
;stop
RETURN
        Widget_Control, event.top, Get_UValue=tlbID
        Widget_Control, tlbID, Get_UValue=info, /No_Copy

; Resize the draw widget
       IF StrUpCase(!Version.OS_Family) NE 'UNIX' THEN BEGIN
           info.spectrum_window->SetProperty, size = [event.x, event.y]
           info.minispectrum_window->SetProperty, size = [event.x, event.y]
           info.plot_window->SetProperty, size = [event.x, event.y]
       ENDIF ELSE BEGIN
           
; This code added to work-around UNIX resize bug when
; TLB has a menu bar in IDL 5.2.
;           Widget_Control, event.top, TLB_GET_Size=newsize
;           xdiff = newsize[0] - info.tlbsize[0]
;           ydiff = newsize[1] - info.tlbsize[1]
;           info.xsize = info.xsize + xdiff
;           info.ysize = info.ysize + ydiff
           self.spectrum_window->SetProperty, size = [event.x, event.y]
           self.minispectrum_window->SetProperty, size = [event.x, event.y]
           self.plot_window->SetProperty, size = [event.x, event.y]
       ENDELSE

; Replot
;       self->Draw_MiniSpectra;, event

        self->Draw_Spectra
;        WSet, info.plot_WID
;        DefSysV, '!B', Exists = b_exists
;        IF b_exists THEN BEGIN
;            IF N_Elements(!b[0]) NE 0 THEN xxx
;        ENDIF
    END

; Events changing the tabs
    'WIDGET_TAB': BEGIN
        RETURN
        Widget_Control, event.top, Get_UValue=self

; I'm not sure of whether to replot these
        CASE event.tab OF
            0: BEGIN
;                self->Draw_Spectra
;                info.spectrum_window->Update
            END
            1: BEGIN
;                Kang_Draw_MiniSpectra, event
;                info.minispectrum_window->Update
            END
            2: BEGIN
;
;                info.plot_window->Update
            END
        ENDCASE
    END

    'WIDGET_KBRD_FOCUS': BEGIN
        Widget_Control, event.top, Get_UValue=self
;        Kang_Kbrd_Focus_Events, tlbID, event.top, event.enter
    END

    ELSE:
ENDCASE

END ;Kang_Plot_Windows_TLB_Events-------------------------------------------------------------


;+
; Events from the plot windows.  Basically just changing the plot properties
;
; :Private:
;
;-
PRO Kang_Plot_Windows_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   IF N_Elements(info) NE 0 THEN $
     Widget_Control, tlbID, Set_UValue=info, /No_Copy
   RETURN
ENDIF

; Get info structure
Widget_Control, event.top, Get_UValue=self

; These are button events from the spectrum buttons
Widget_Control, event.id, Get_UValue=uval

; These are events from the text boxes
eventName = Tag_Names(event, /Structure_Name)
IF eventName EQ 'FSC_INPUTFIELD_EVENT' THEN BEGIN
    CASE uval OF
        'Title': self->spectrum, title = *event.value
        'XTitle': self->spectrum, Xtitle = *event.value
        'YTitle': self->spectrum, Ytitle = *event.value
        ELSE: BEGIN
; These are the ranges.  Get values out
            event.objRef->GetProperty, UValue = uval
            xmin = uval[0]->Get_Value()
            xmax = uval[1]->Get_Value()
            ymin = uval[2]->Get_Value()
            ymax = uval[3]->Get_Value()

; Set values and draw
            spectrum->SetProperty, XRange = [xmin, xmax], YRange = [ymin, ymax] 
        END
    ENDCASE
ENDIF ELSE BEGIN

; Events from the other buttons
    CASE uval OF
; Changing current spectrum
        'C': BEGIN
            info.whichSpectrum = event.Value

; Update the widget
; Get info
            base = Widget_Info(event.top, Find_By_UName = 'propBase')

            IF base NE 0 THEN BEGIN
                Widget_Control, base, Get_UValue = propinfo

; Get properties
                spectrum = info.spectra->Get(position = info.whichSpectrum, count = count)
                IF count NE 0 THEN spectrum->GetProperty, title = title, xtitle = xtitle, ytitle = ytitle, xrange = xrange, yrange = yrange, $
                  freeze_x = freeze_x, freeze_y = freeze_y, charsize = charsize, charthick = charthick, linestyle = linestyle, width=width, $
                  cname = cname, axisCName = axiscname, backCName = backcname

; Set properties
                propinfo.title->Set_Value, title
                propinfo.xtitle->Set_Value, xtitle
                propinfo.ytitle->Set_Value, ytitle
                propinfo.xmin->Set_Value, xrange[0]
                propinfo.xmax->Set_Value, xrange[1]
                propinfo.ymin->Set_Value, yrange[0]
                propinfo.ymax->Set_Value, yrange[1]
                Widget_Control, propinfo.freezexID, Set_Value = freeze_x
                Widget_Control, propinfo.freezeyID, Set_Value = freeze_y
                propinfo.charsize->Set_Value, String(charsize, format = '(f4.1)')
                propinfo.charthick->Set_Value, String(charthick, format = '(f4.1)')
                propinfo.linestyleID->SetIndex, linestyle
                propinfo.widthID->SetIndex, width
                Widget_Control, propinfo.linecolorID, Set_Value = cname
                Widget_Control, propinfo.backcolorID, Set_Value = backcname
                Widget_Control, propinfo.axiscolorID, Set_Value = axiscname
            ENDIF

; Replot
            self->Draw_Spectra
        END

; Changing which spectrum is plotted
        'P': BEGIN
            info.plot_Spectrum[event.value] = event.select
            self->Draw_Spectra
        END

        'Properties': Kang_Spectra_Properties_Widget, event

        'Line Color': self->Spectrum_Property, color = event.color
        'Axis Color': self->Spectrum_Property, axiscolor = event.color
        'BG Color': self->Spectrum_Property, backcolor = event.color
        'Spectrum Width': self->Spectrum_Property, width = event.index+1
        'Spectrum Linestyle': self->Spectrum_Property, linestyle = event.index
        'Spectrum Charthick': self->Spectrum_Property, charthick = *event.value
        'Spectrum Charsize': self->Spectrum_Property, charsize = *event.value
        'Freeze X':  self->Spectrum_Property, freeze_x = event.select
        'Freeze Y': self->Spectrum_Property, freeze_x = event.select
        'Reset Axes': self->Spectrum_Property, /Reset_Axes
        'Default Titles': self->Spectrum_Property, XTitle = 'Velocity (km s!U-1!N)', YTitle = 'K'

        'Fit 1':self->gauss, 1
        'Fit 2':self->gauss, 2
        'Fit 3':self->gauss, 3
        'Fit 4':self->gauss, 4
    ENDCASE
ENDELSE

END; Kang_Plot_Windows_Events-----------------------------------------------------------------------------


;--------------------------------------------------------------------------------
; File menu events
;--------------------------------------------------------------------------------
;+
; Passes stuff along.
;
; :Private:
;
;-
PRO Kang_File_Output_Windows, event
Widget_Control, event.top, Get_UValue = self

Widget_Control, event.ID, Get_Value = buttonName
CASE buttonName OF
    'GIF File': self->Save_Spectrum, /GIF
    'PNG File': self->Save_Spectrum, /PNG
    'JPG File':self->Save_Spectrum, /JPEG
    'TIFF File': self->Save_Spectrum, /TIFF
    'PostScript File': self->Save_Spectrum, /PS
    'FITS File': self->Save_Spectrum, /FITS
    'IDL Variable': self->Save_Spectrum, /IDL_Variable
ENDCASE

END; Kang_File_Output_Windows-------------------------------------------------------


;+
; Responds to events from the histogram dialog
;
; :Private:
;
;-
PRO Kang::Histogram_Events, event

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(/Traceback)
   RETURN
ENDIF

eventName = Tag_Names(event, /Structure_Name)
CASE eventName OF
    'KANG_HISTOGRAM_EVENTS': BEGIN
; Dragging the line
        noupdate = 0
        IF event.drag THEN BEGIN
            self.histogram->GetProperty, autoupdate = autoUpdate
            IF autoUpdate THEN noupdate = 0 ELSE noupdate = 1
        ENDIF
        self->Scale, event.lowscale, event.highscale, noupdate = noupdate
    END
ENDCASE

END; Kang_Histogram_Events--------------------------------------------------


;+
; Events from the window showing the header
;
; :Private:
;
;-
PRO Kang_Show_Header_Events, event

eventName = Tag_Names(event, /str)
CASE eventName OF
    'WIDGET_BASE': BEGIN
        Widget_Control, event.top, Get_UValue = textID
        Widget_Control, textID, Scr_XSize = event.x, Scr_YSize = event.y
    END
ELSE:
ENDCASE

END; Kang_Show_Header_Events--------------------------------------------------------


;+
; Responds to events from the threshold sliders.
;
; :Private:
;
;-
PRO Kang::Threshold_Events, event, IDs
; This event handler is for when the user changes the threshold sliders

; This event handler takes slider and carriage return events
Widget_Control, event.id, Get_UValue=buttonValue
eventName = Tag_Names(event, /Structure_Name)
self.histogram->GetProperty, minscale = minscale, maxscale = maxscale

; Get threshold parameters. 0,1 are x, y click positions, 3,4 are low
; and high threshold values
self.regions->GetProperty, params = params
threshold_low = params[2]
threshold_high = params[3]

; What steps are the sliders in?
value = self.image->Find_Values(params[0], params[1], /Data)
low_cdelt = [value - minscale]/300.
high_cdelt = [maxscale - value]/300.

; What type of event is this?
CASE buttonValue OF
    'Threshold High': BEGIN
        CASE eventName OF
; Text events
            '': BEGIN
                highpix = (event.value - value) / high_cdelt - 1
                Widget_Control, IDs.threshold_high_sliderID, Set_Value = highpix
                threshold_high = event.value
            END

; Slider events
            'WIDGET_SLIDER': BEGIN
                threshold_high = (event.value + 1) * high_cdelt + value
                Widget_Control, IDs.threshold_high_ValueID, Set_Value = threshold_high
            END
        ENDCASE
    END
    'Threshold Low': BEGIN
        CASE eventName OF
; Text events
            '': BEGIN
                lowpix = (event.value - minscale) / low_cdelt - 1
                Widget_Control, IDs.threshold_low_sliderID, Set_Value = lowpix
                threshold_low = event.value
            END

; Slider events
            'WIDGET_SLIDER': BEGIN
                threshold_low = (event.value + 1) * low_cdelt + minscale
                Widget_Control, IDs.threshold_low_ValueID, Set_Value = threshold_low
            END
        ENDCASE
    END
ENDCASE

; Create region
self->Make_Region, 'Threshold', [params[0], params[1], threshold_low, threshold_high], /Replace

END ;Kang::Threshold_Events----------------------------------------------------------------


;--------------------------------------------------
;           Display Methods
;--------------------------------------------------
;+
; Copies the display from the pixmap window to the main display
;
; :Private:
;
;-
PRO Kang::Copy_Display, wid1, wid2, wid3, wid4
; Copies the contents of the pixmap window into the current window.
; Images are drawn into the pixmap window, then copied over for speed
; and to reduce flickering.

IF N_Elements(wid1) EQ 0 THEN wid1 = self.wid
IF N_Elements(wid2) EQ 0 THEN wid2 = self.pix_wid
;IF N_Elements(wid3) EQ 0 THEN wid3 = self.pix_wid2
;IF N_Elements(wid4) EQ 0 THEN wid4 = self.pix_wid3

IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN BEGIN
;    WSet, wid3
;    annotations = TVRead()

;    WSet, wid2
;    image = TVRead()

; Combine them
;    alpha = 0.5
;    rgb = image
;    wh = where(annotations NE 255)
;    rgb[wh] = BYTE( alpha * FLOAT(image[wh]) + (1.0 - alpha) * FLOAT(annotations[wh]) )
    
; Draw
;    WSet, wid4
;    TVImage, rgb
    WSet, wid1
    Device, Copy=[0,0,!d.X_size, !D.y_size, 0, 0, wid2]
ENDIF

END; Kang::Copy_Display-------------------------------------------------


;+
; Draws the entire display
;
; :Private:
;
; :Keywords:
;  NoContours : in, optional, type = 'boolean'
;    If set, contours will not be drawn.  Increases speed
;    dramitically.
;  NoStars : in, optional, type = 'boolean'
;    If set, stars will not be drawn.  Increases speed dramitically.
;-
PRO Kang::Draw, WID, noimage = noimage, noaxis = noaxis, nobar = nobar, nocontours = nocontours, nostars = nostars, $
                     position = position
; Draws the image, axis, regions, contours, and colorbar on the display.`w

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN
ENDIF

; Don't draw if no GUI
;IF ~XRegistered('Kang ' + StrTrim(self.tlbID, 2)) AND !D.Name NE 'PS' THEN RETURN
IF ~self.realized AND !D.Name NE 'PS' THEN RETURN

; Draw into the pixmap window
IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN BEGIN
    IF N_Elements(wid) NE 0 THEN WSet, wid ELSE WSet, self.pix_wid
ENDIF

; Don't draw if nothing is loaded
IF ~Obj_Valid(self.image) THEN BEGIN
    IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN BEGIN
        Erase
        self->Copy_Display
    ENDIF
    RETURN
ENDIF

; Load colors
self.colors->TVLCT

; Draw the display
self.image->Draw, noimage = noimage, noaxis = noaxis, nobar = nobar, position = position

; Draw the contours
IF ~Keyword_Set(nocontours) THEN BEGIN
    good_contours = where(self.whichContours NE 0)
    IF good_contours[0] NE -1 THEN BEGIN

; Get objects
        contours = self.image_container->Get(position = good_contours)

; Loop through all objects, drawing contours
        FOR i = 0, N_Elements(good_contours)-1 DO BEGIN
            good = good_contours[i]
            contours[i]->contour, self.image
            contours[i]->GetProperty, percent=percent, s_nlevels = s_nlevels
            IF percent AND self.realized THEN BEGIN
;XRegistered('kang_plot_params_widget '+StrTrim(self.tlbID,2)) THEN BEGIN
;            Widget_Control, (*self.plot_paramsID)[good], Get_UValue = plotinfo, Update=0
;            plotinfo.nlevels_levels->Set_Value, s_nlevels
            ENDIF
        ENDFOR
    ENDIF
ENDIF

; Draw the regions
;wset, self.pix_wid2
self.image->GetProperty, pix_newlimits = pix_newlimits, newposition = newposition
IF N_Elements(position) NE 4 THEN position = newposition
plot, [0], XRange = [pix_newlimits[0]-0.5, pix_newlimits[1]+0.5], YRange = [pix_newlimits[2]-0.5, pix_newlimits[3]+0.5], $
      XStyle=5, YStyle=5, /NoData, /NoErase, position = position
self.regions->Draw

; Draw the stars
IF ~Keyword_Set(nostars) THEN $
  self.image->Draw_Stars, color = self.colors->ColorIndex('Green'), bad_color = self.colors->ColorIndex('Red')

; Copy the drawn image over to the current display
IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN self->Copy_Display

END; Kang::Draw--------------------------------------------------


;+
; Updates the file dialog.
;
; :Private:
;
;-
PRO Kang::Update_File_Dialog

; Find the filenames
IF XRegistered('File Dialog '+StrTrim(self.tlbID, 2)) THEN BEGIN
    self->GetProperty, filenames = filenames
    n_filenames = N_Elements(filenames)
    FOR j = 0, n_filenames-1 DO Widget_Control, self.filenameID[j], Set_Value=filenames[j]
    FOR j = n_filenames, 7 DO Widget_Control, self.filenameID[j], Set_Value=''

; Set plot buttons to normal values
    Widget_Control, self.plotID, Set_Value = self.whichImage
    Widget_Control, self.contourID, Set_Value = self.whichcontours
ENDIF

END; Kang::Update_File_Dialog----------------------------------------------


;+
; Updates the regions dialog
;
; :Private:
;
; :Keywords:
;  List_Update : in, optional, type = 'integer'
;    If set, the text in the region list will be updated
;  No_Slider_Update : in, optional, type = 'integer'
;    If set, the threshold sliders will not be changed around.  Useful since the
;    conversion from slider to values would otherwise make the sliders
;    jumpy.
;
;-
PRO Kang::Update_Regions_Info, List_Update = list_update, No_Slider_Update = no_slider_update
; This routine updates the regions dialog with new statistics and
; region info
; The second keyword is necessary because of how IDL handles sliders

Catch, theError
IF theError NE 0 THEN BEGIN
    Catch, /Cancel
    ok = Error_Message(Traceback=1)
    RETURN
ENDIF
IF ~self->plot_params_realized() THEN RETURN

; Turn updating off so it goes smoothly when we turn it back on
Widget_Control, self.regionBase, Update = 0

; Get information from regions object
self.regions->GetProperty, position = position, regiontext=regiontext, N_Regions = n_regions, stats = stats, $
  angle = angle, cname = cname, thick = width, linestyle = linestyle, interior = exclude, regiontype = regiontype, params = params, $
  source = source, polygon = polygon, selected_regions = selected_regions, n_selected = n_selected

; Only update list if specified. Reduces flickering.
IF Keyword_Set(List_Update) THEN BEGIN
    IF N_Elements(regiontext) EQ 0 THEN regiontext = ''
    Widget_Control, self.regions_listID, Set_Value = regiontext
ENDIF

; Set selected regions
Widget_Control, self.regions_ListID, Set_List_Select = selected_regions

; If nothing is there, update with 'NA', otherwise use real values
IF n_selected NE 0 THEN BEGIN
    position = selected_regions(n_selected-1)

; Set stats
    Widget_Control, self.areaLabelID, Set_Value = StrTrim(stats.area[0], 2) + "'"
    Widget_Control, self.x_centerLabelID, Set_Value = StrTrim(stats.centroid[0], 2)
    Widget_Control, self.y_centerLabelID, Set_Value = StrTrim(stats.centroid[1], 2)
    Widget_Control, self.perimeterLabelID, Set_Value = StrTrim(stats.perimeter[0], 2) + "'"
    Widget_Control, self.NPixelLabelID, Set_Value = StrTrim(stats.npix[0], 2)
    Widget_Control, self.minLabelID, Set_Value = StrTrim(stats.min[0], 2)
    Widget_Control, self.maxLabelID, Set_Value = StrTrim(stats.max[0], 2)
    Widget_Control, self.meanLabelID, Set_Value = StrTrim(stats.mean[0], 2)
    Widget_Control, self.stdDevLabelID, Set_Value = StrTrim(stats.stdDev[0], 2)
    Widget_Control, self.totalLabelID, Set_Value = StrTrim(stats.total[0], 2)

; Update region properties
    Widget_Control, self.angle_sliderID, Set_Value = angle[n_selected-1]
    self.angle_textboxID->Set_Value, String(angle[n_selected-1], format = '(F5.1)')
    Widget_Control, self.region_colorID, Set_Value = cname[n_selected-1]
    Widget_Control, self.region_widthID, Set_Droplist_Select = Fix(width[n_selected-1]-1)
    Widget_Control, self.region_linestyleID, Set_Droplist_Select = linestyle[n_selected-1]
    Widget_Control, self.region_includeID, Set_Value = exclude[n_selected-1]
    Widget_Control, self.region_sourceID, Set_Value = ~source[n_selected-1]
    Widget_Control, self.region_typeID, Set_Value = ~polygon[n_selected-1]

; Set sensitivity of angle, etc
    IF total(regionType[n_selected-1] EQ ['Circle', 'Line', 'Threshold']) THEN angle_sensitive = 0 ELSE angle_sensitive = 1
    IF total(regionType[n_selected-1] EQ ['Text']) THEN exclude_sensitive = 0 ELSE exclude_sensitive = 1
    IF total(regionType[n_selected-1] EQ ['Text']) THEN linestyle_sensitive = 0 ELSE linestyle_sensitive = 1
;    IF total(regionType EQ ['Circle', 'Line', 'Threshold']) THEN width_sensitive = 0 ELSE width_sensitive = 1
    Widget_Control, self.angle_sliderID, Sensitive=angle_sensitive
    Widget_Control, self.excludeID, Sensitive=exclude_sensitive
    Widget_Control, self.region_linestyleID, Sensitive=linestyle_sensitive
;    Widget_Control, self.region_widthID, Sensitive=width_sensitive

; UnMap current base
    IF self.current_regionBase NE -1 AND regionType[n_selected-1] NE self.plot_params_regionType THEN $
      Widget_Control, self.current_regionBase, /Destroy

; Bases for individual regions
    IF regionType[n_selected-1] NE self.plot_params_regionType THEN BEGIN
        self.current_regionBase = self->Update_Regions_Info_Region(regionType[n_selected-1], self.regionBase, $
                                                                   No_Slider_Update = no_slider_update)
        self.plot_params_regionType  = regionType[n_selected-1]
    ENDIF
    self->Update_Regions_Base, self.current_regionBase, regiontype[n_selected-1], params, $
      angle = angle, color = color, linestyle = linestyle, polygon = polygon, $
      source = source,  width = width

ENDIF ELSE BEGIN
    Widget_Control, self.areaLabelID, Set_Value = ' '
    Widget_Control, self.x_centerLabelID, Set_Value = ' '
    Widget_Control, self.y_centerLabelID, Set_Value = ' '
    Widget_Control, self.perimeterLabelID, Set_Value = ' '
    Widget_Control, self.NPixelLabelID, Set_Value = ' '
    Widget_Control, self.maxLabelID, Set_Value = ' '
    Widget_Control, self.minLabelID, Set_Value = ' '
    Widget_Control, self.meanLabelID, Set_Value = ' '
    Widget_Control, self.stdDevLabelID, Set_Value = ' '
    Widget_Control, self.totalLabelID, Set_Value = ' '

; Update region properties
    Widget_Control, self.angle_sliderID, Set_Value = 0
    Widget_Control, self.region_colorID, Set_Value = self.regions_cname
    Widget_Control, self.region_widthID, Set_Droplist_Select = self.regions_width-1
    Widget_Control, self.region_linestyleID, Set_Droplist_Select = self.regions_linestyle

; Unmap base
    IF self.current_regionBase NE -1 THEN Widget_Control, self.current_regionBase, /Destroy
    self.current_regionBase = -1
    self.plot_params_regionType = ''
ENDELSE

Widget_Control, self.regionBase, Update = 1

END; Kang::Update_Regions_Info-----------------------------------


;+
; Updates smaller widget base in regions widget
;
; :Private:
;
;-
PRO Kang::Update_Regions_Base, base, regiontype, params, angle = angle, color = color, linestyle = linestyle, polygon = polygon, $
  source = source,  width = width

IF base EQ -1 THEN RETURN

; Get uvalue
Widget_Control, base, Get_UValue = uval

CASE regiontype OF
    'Box': BEGIN
        Widget_Control, uval.box_xID, Set_Value = params[0]
        Widget_Control, uval.box_yID, Set_Value = params[1]
        Widget_Control, uval.box_widthID, Set_Value = params[2]
        Widget_Control, uval.box_heightID, Set_Value = params[3]
    END

    'Circle': BEGIN
        Widget_Control, uval.circle_xID, Set_Value = params[0]
        Widget_Control, uval.circle_yID, Set_Value = params[1]
        Widget_Control, uval.circle_radiusID, Set_Value = params[2]
    END

    'Composite': BEGIN
; Set list Value
        regiongroup_obj = self.regions->Get(position = position)
        regiongroup_obj->GetProperty, alltext = alltext
        Widget_Control, uval.composite_listID, Set_Value = alltext
    END

    'Ellipse': BEGIN
        Widget_Control, uval.ellipse_xID, Set_Value = params[0]
        Widget_Control, uval.ellipse_yID, Set_Value = params[1]
        Widget_Control, uval.ellipse_semimajorID, Set_Value = params[2]
        Widget_Control, uval.ellipse_semiminorID, Set_Value = params[3]
    END

    'Line': BEGIN
        Widget_Control, uval.line_p1_xID, Set_Value = params[0]
        Widget_Control, uval.line_p1_yID, Set_Value = params[1]
        Widget_Control, uval.line_p2_xID, Set_Value = params[2]
        Widget_Control, uval.line_p2_yID, Set_Value = params[3]
    ENDCASE

    'Text': BEGIN
        Widget_Control, uval.text_xID, Set_Value = params[0]
        Widget_Control, uval.text_yID, Set_Value = params[1]

        self.regions->GetProperty, text = text
        Widget_Control, uval.text_textID, Set_Value = text
    END

    'Threshold': BEGIN
; Set threshold sliders to corect values
        value = self.image->Find_Values(params[0], params[1], /Data)
        self.histogram->GetProperty, minscale = minscale, maxscale = maxscale
        low_cdelt = [value - minscale]/300.
        lowval = (params[2] - minscale) / low_cdelt - 1
        high_cdelt = [maxscale - value]/300.
        highval = (params[3] - value) / high_cdelt - 1

        Widget_Control, uval.threshold_low_sliderID, Set_Value = lowval
        Widget_Control, uval.threshold_high_sliderID, Set_Value = highval
        Widget_Control, uval.threshold_low_valueID, Set_Value = params[2]
        Widget_Control, uval.threshold_high_valueID, Set_Value = params[3]
    END

;    'Threshold Image': BEGIN
;;        Widget_Control, regionBase, Get_UValue = currentBaseInfo
;;        Widget_Control, currentBaseInfo.threshold_imageID, Set_Value = params[0]
;    END
ENDCASE

END; Kang::Update_Regions_Base----------------------------------------


;+
; Creates smaller widget base in regions widget
;
; :Private:
;-
FUNCTION Kang::Update_Regions_Info_Region, regiontype, base, no_slider_update = no_slider_update

CASE regiontype OF
    'Box': BEGIN
; Create widget
; Uvalues should have regionbase ID so when events are returned, the
; uval of the base may be gotten
        regionBase = Widget_Base(base, Column = 2, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        Box_xID = CW_Field(regionbase, /Floating, UValue = 'Box', Title='Center:', /Return_Events, XSize = 15)
        Box_widthID = CW_Field(regionbase, /Floating, UValue = 'Box', Title='Size:  ', /Return_Events, XSize = 15)
        Box_yID = CW_Field(regionbase, /Floating, UValue = 'Box', Title='', /Return_Events, XSize = 15)
        Box_heightID = CW_Field(regionbase, /Floating, UValue = 'Box', Title='', /Return_Events, XSize = 15)

; Set UVal
; uval should contain object reference for image and region
        uval = {Box_xID:Box_xID, $
                Box_yID:Box_yID, $
                Box_widthID:Box_widthID, $
                Box_heightID:Box_heightID}
    END

    'Circle': BEGIN
; Create widget
        regionBase = Widget_Base(base, Column=2, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        circle_xID = CW_Field(regionBase, /Floating, UValue = 'Circle', Title='Center:', /Return_Events, XSize = 15)
        circle_radiusID = CW_Field(regionBase, /Floating, UValue = 'Circle', Title='Radius:', /Return_Events, XSize = 15)
        circle_yID = CW_Field(regionBase, /Floating, UValue = 'Circle', Title='', /Return_Events, XSize = 15)
        
; Set UVal
        uval = {circle_xID:circle_xID, $
                circle_yID:circle_yID, $
                circle_radiusID:circle_radiusID}
    END
    
    'Composite': BEGIN
; Create widget
        regionBase = Widget_Base(base, Column=2, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        composite_listID = Widget_List(regionBase, XSize=53, YSize=5, UValue='Composite', /Multiple)
            
; Set UVal
        uval = {composite_listID:composite_listID}
    END
    
    'Ellipse': BEGIN
; Create widget
        regionBase = Widget_Base(base, Column=2, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        ellipse_xID = CW_Field(regionBase, /Floating, UValue = 'Ellipse', Title='Center:', /Return_Events, XSize = 15)
        ellipse_semimajorID = CW_Field(regionBase, /Floating, UValue = 'Ellipse', Title='Radius:', /Return_Events, XSize = 15)
        ellipse_yID = CW_Field(regionBase, /Floating, UValue = 'Ellipse', Title='', /Return_Events, XSize = 15)
        ellipse_semiminorID = CW_Field(regionBase, /Floating, UValue = 'Ellipse', Title='', /Return_Events, XSize = 15)
            
; Set UVal
        uval = {ellipse_xID:ellipse_xID, $
                ellipse_yID:ellipse_yID, $
                ellipse_semimajorID:ellipse_semimajorID, $
                ellipse_semiminorID:ellipse_semiminorID}
    END
    
    'Line': BEGIN
; Create widget
        regionBase = Widget_Base(base, Column=2, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        line_p1_xID = CW_Field(regionBase, /Floating, UValue = 'Line', Title='Point 1:', /Return_Events, XSize = 15)
        line_p2_xID = CW_Field(regionBase, /Floating, UValue = 'Line', Title='Point 2:', /Return_Events, XSize = 15)
        line_p1_yID = CW_Field(regionBase, /Floating, UValue = 'Line', Title='', /Return_Events, XSize = 15)
        line_p2_yID = CW_Field(regionBase, /Floating, UValue = 'Line', Title='', /Return_Events, XSize = 15)
            
; Set UVal
        uval = {line_p1_xID:line_p1_xID, $
                line_p1_yID:line_p1_yID, $
                line_p2_xID:line_p2_xID, $
                line_p2_yID:line_p2_yID}
    END
    
    'Polygon': BEGIN
        regionBase = -1
    END
    
    'Text': BEGIN
        regionBase = Widget_Base(base, Column=2, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        text_xID = CW_Field(regionBase, /Floating, UValue = 'Text', Title='Center:', /Return_Events, XSize = 15)
        text_textID = CW_Field(regionBase, /String, UValue = 'Text', Title='Text:  ', /Return_Events, XSize = 15)
        text_yID = CW_Field(regionBase, /Floating, UValue = 'Text', Title='', /Return_Events, XSize = 15)
        
; Set UVal
        uval = {text_xID:text_xID, $
                text_yID:text_yID, $
                text_textID:text_textID}
    END
    
    'Threshold': BEGIN
        regionBase = Widget_Base(base, Column=1, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        slider_Base = Widget_Base(regionBase, Column=2)
        threshold_high_sliderID = Widget_Slider(slider_base, /suppress_value, xsize=360, title='High Threshold', /Drag, $
                                                UValue='Threshold High', maximum = 299, minimum=0)
        threshold_low_sliderID = Widget_Slider(slider_base, /suppress_value, xsize=360, title='Low Threshold', /Drag, $
                                               UValue='Threshold Low', maximum = 299, minimum=0)
        threshold_high_valueID = CW_Field(slider_base, /Floating, UValue = 'Threshold High', $
                                          Title='', /Return_Events, XSize = 10)
        threshold_low_ValueID = CW_Field(slider_base, /Floating, UValue = 'Threshold Low', $
                                         Title='', /Return_Events, XSize = 10)
            
; Set UVal
        uval = {threshold_high_sliderID:threshold_high_sliderID, $
                threshold_low_sliderID:threshold_low_sliderID, $
                threshold_high_valueID:threshold_high_valueID, $
                threshold_low_ValueID:threshold_low_ValueID}
    END
    
    'Threshold_Image': BEGIN
; Create widget
        regionBase = Widget_Base(base, Column=1, /Frame, Event_Pro = 'Kang_Individual_Region_Widget_Events')
        threshold_imageID = CW_Field(regionBase, /Floating, UValue = 'Threshold Image', Title = 'Threshold', /Return_Events, $
                                     XSize = 10)
        Widget_Control, regionBase, Set_UValue = {threshold_imageID:threshold_imageID}
    END

    ELSE: regionBase = -1
ENDCASE

; Store UValue
IF regionBase NE -1 THEN Widget_Control, regionBase, Set_UValue = uval

RETURN, regionBase
END; Kang::Update_Regions_Info_Region----------------------------------------


;+
; Brings up the GUI so the user can interact with it.
;
; :Keywords:
;  Block : in, optional, type = 'integer'
;    If set, the commandline will be blocked.  Very useful for
;    multiple calls to the program since it can act like a "pause."
;  WindowTitle : in, optional, type = 'string'
;    The title of the main window
;  XSize : in, optional, type = 'integer' 
;    The x-size of the main window
;  YSize : in, optional, type = 'integer' 
;    The y-size of the main window
;
; :Examples:
;   Some thing that is very useful in batch processing when user-input
;   is required is to use the block command.  This will pause any loop
;   until the program is closed.  To do so with a window size of
;   400x400::
;      IDL> kang_obj->GUI, /block, xsize = 400, ysize = 400
;
;-
PRO Kang::GUI, block = block, windowTitle = windowTitle, xsize=xsize, ysize = ysize
; Brings the GUI up onto the display

IF !D.Name EQ 'PS' THEN BEGIN
    print, 'ERROR: Cannot display with device set to "ps."'
    RETURN
ENDIF

; Don't bring up multiple copies
IF self.realized THEN RETURN

;--------------------------------------------------------------------------------
; Top Level Base definition
;--------------------------------------------------------------------------------
self.tlbID = Widget_Base(Column=1, MBar=menubarID, /tlb_size_events, UValue = self, Event_Pro = 'Kang_Events')
;Widget_Control, menubarID, Event_Pro = 'Kang_Menubar_Events'

; Sensitivity is 1 for image loaded, 0 otherwise.
sensitive = self.image_container->count() < 1

; Define the File pull-down menu.
fileID = Widget_Button(menubarID, Value='File')

; Define an Open button.
openID = Widget_Button(fileID, Value='Open...', /Menu)
button = Widget_Button(openID, Value='Open FITS')
button = Widget_Button(openID, Value='Open Array')
;button = Widget_Button(openID, Value='Open DSS Image')

; Define the Print pull-down menu.
;printID = Widget_Button(fileID, Value='Print', Event_Pro='Kang_Print', /Menu)
;button = Widget_Button(printID, Value='Portrait Mode')
;button = Widget_Button(printID, Value='Landscape Mode')

; Define the Save As pull-down menu.
saveAsID = Widget_Button(fileID, Value='Save As', /Menu)
button = Widget_Button(saveAsID, Value='PostScript File')
button = Widget_Button(saveAsID, Value='GIF File')
button = Widget_Button(saveAsID, Value='PNG File')
button = Widget_Button(saveAsID, Value='JPG File')
button = Widget_Button(saveAsID, Value='TIFF File')
button = Widget_Button(saveAsID, Value='FITS File')
button = Widget_Button(saveAsID, Value='IDL Variable')
;button = Widget_Button(saveAsID, Value='System Variable')

; Widgets
widgetsID = Widget_Button(fileID, Value = 'Widgets', /Menu)
fileDialogID = Widget_Button(widgetsID, Value='Files')
plot_parametersID = Widget_Button(widgetsID, Value='Plot Parameters')
self.velocity_widgetID = Widget_Button(widgetsID, Value='Velocity')

; Define the print fits header menu
headerID = Widget_Button(fileID, Value='Show FITS Header')

; Define the Quit button.
quitID = Widget_Button(fileID, Value='Quit', /Separator)

; Define Edit pull down menu
self.editID = Widget_Button(menubarID, Value = 'Edit', sensitive=sensitive)
self.cutID = Widget_Button(self.editID, Value = 'Cut   (Ctrl+X)')
self.copyID = Widget_Button(self.editID, Value = 'Copy  (Ctrl+C)')
self.pasteID = Widget_Button(self.editID, Value = 'Paste (Ctrl+V)')
;self.showHideID = Widget_Button(self.editID, Value = 'Show/Hide', /Menu)
;button = Widget_Button(self.showHideID, Value = 'Show All')
;button = Widget_Button(self.showHideID, Value = 'Hide All')
;n_images = self.image_container->count()
;FOR i = 0, n_images-1 DO BEGIN
;    IF i EQ 0 THEN separator = 1 ELSE separator = 0
;    button = Widget_Button(self.showHideID, Value = 'Frame ' + StrTrim(n_images-1, 2), /Checked, separator = separator)
;    Widget_Control, button, /Set_Button
;ENDFOR

; Define the Colors pull-down menu
self.colorsID = Widget_Button(menubarID, Value='Colors', sensitive=sensitive)
imageColorsID = Widget_Button(self.colorsID, Value='Image Colors')
self.invertID = Widget_Button(self.colorsID, Value='Invert', /Separator)
self.reverseID = Widget_Button(self.colorsID, Value='Reverse')
resetstretchID = Widget_Button(self.colorsID, Value='Reset Stretch')
;drawColorsID = Widget_Button(colorsID, Value='Drawing Colors', $
;                             Event_Pro='Kang_Drawing_Colors', /Menu)
;button = Widget_Button(drawColorsID, Value='Background Color', UValue='BACKGROUND')
;button = Widget_Button(drawColorsID, Value='Annotation Color', UValue='ANNOTATION')

; Scaling pull down menu
self.scalingID = Widget_Button(menubarID, Value = 'Scaling', sensitive=sensitive)
self.linearID = Widget_Button(self.scalingID, Value = 'Linear', /Checked_Menu)
self.logID = Widget_Button(self.scalingID, Value = 'Log', /Checked_Menu)
;self.histEqID = Widget_Button(self.scalingID, Value = 'Histogram Eq.', /Checked_Menu)
self.asinhID = Widget_Button(self.scalingID, Value = 'asinh', /Checked_Menu)
;self.gaussianID = Widget_Button(self.scalingID, Value = 'Gaussian', /Checked_Menu)
;self.powerID = Widget_Button(self.scalingID, Value = 'Power', /Checked_Menu)
self.SquaredID = Widget_Button(self.scalingID, Value = 'Squared', /Checked_Menu)
self.SquareRootID = Widget_Button(self.scalingID, Value = 'Square Root', /Checked_Menu)

IF Obj_Valid(self.colors) THEN BEGIN
    self.colors->GetProperty, scaling = scaling
    CASE StrUpCase(scaling[0]) OF
        'GAUSSIAN':Widget_Control, self.gaussianID, Set_Button=1
        'POWER':Widget_Control, self.powerID, Set_Button=1
        'LINEAR':Widget_Control, self.linearID, Set_Button=1
        'LOG':Widget_Control, self.logID, Set_Button=1
        'ASINH':Widget_Control, self.asinhID, Set_Button=1
        'HISTEQ':Widget_Control, self.histeqID, Set_Button=1
        'SQUARED':Widget_Control, self.squaredID, Set_Button=1
        'SQUARE ROOT':Widget_Control, self.squarerootID, Set_Button=1
        ELSE: print, scaling[0]
    ENDCASE
ENDIF ELSE BEGIN
    Widget_Control, self.linearID, Set_Button=1
ENDELSE

; Zoom pull down menu in case user doesn't have 3rd button
self.zoomID = Widget_Button(menubarID, Value = 'Zoom', sensitive=sensitive)
zoomInID = Widget_Button(self.zoomID, Value = 'Zoom In  (+)')
zoomOutID = Widget_Button(self.zoomID, Value = 'Zoom Out (-)')
 
; Regions pull down menu
self.regionsID = Widget_Button(menubarID, Value = 'Regions', sensitive=sensitive)
loadregionsID = Widget_Button(self.regionsID, Value = 'Load Regions')
saveregionsID = Widget_Button(self.regionsID, Value = 'Save Regions')
delregionsID = Widget_Button(self.regionsID, Value = 'Delete All Regions')
createMaskID = Widget_Button(self.regionsID, Value = 'Save Mask')
;saveWeightsID = Widget_Button(self.regionsID, Value = 'Save Weighted Mask')

selectallID = Widget_Button(self.regionsID, Value = 'Select All        (Ctrl+A)', /Separator)
selectnoneID = Widget_Button(self.regionsID, Value = 'Select None (Ctrl+Shift+A)')
invertselectionID = Widget_Button(self.regionsID, Value = 'Invert Selection')

shapeID = Widget_Button(self.regionsID, Value = 'Shape', UValue = 'Shape', /Menu, /Separator)
self.boxID = Widget_Button(shapeID, Value = 'Box', /Checked_Menu)
self.circleID = Widget_Button(shapeID, Value = 'Circle', /Checked_Menu)
self.ellipseID = Widget_Button(shapeID, Value = 'Ellipse',  /Checked_Menu)
self.crossID = Widget_Button(shapeID, Value = 'Cross', /Checked_Menu)
self.thresholdID = Widget_Button(shapeID, Value = 'Threshold', /Checked_Menu)
self.textID = Widget_Button(shapeID, Value = 'Text', /Checked_Menu)
self.lineID = Widget_Button(shapeID, Value = 'Line', /Checked_Menu)
self.freehandID = Widget_Button(shapeID, Value = 'Freehand', /Checked_Menu)

CASE STrUpCase(self.regionType) OF 
; Set region type checkmark accordingly
    'BOX': Widget_Control, self.BoxID, Set_Button=1
    'CIRCLE': Widget_Control, self.CircleID, Set_Button=1
    'ELLIPSE': Widget_Control, self.EllipseID, Set_Button=1
    'CROSS': Widget_Control, self.CrossID, Set_Button=1
    'THRESHOLD': Widget_Control, self.ThresholdID, Set_Button=1
    'TEXT': Widget_Control, self.TextID, Set_Button=1
    'LINE': Widget_Control, self.LineID, Set_Button=1
    'FREEHAND': Widget_Control, self.FreehandID, Set_Button=1
    ELSE: RETURN
ENDCASE

propertiesID = Widget_Button(self.regionsID, Value = 'Properties', UValue = 'Properties', /Menu)
self.includeID = Widget_Button(propertiesID, Value = 'Include', UValue = 'Include', /Checked_Menu)
self.excludeID = Widget_Button(propertiesID, Value = 'Exclude', UValue = 'Exclude', /Checked_Menu)
IF self.regions_include THEN Widget_Control, self.includeID, Set_Button = 1 ELSE Widget_Control, self.excludeID, Set_Button = 1

self.sourceID = Widget_Button(propertiesID, Value = 'Source', UValue = 'Source', /Checked_Menu, /Separator)
self.backgroundID = Widget_Button(propertiesID, Value = 'Background', UValue = 'Background', /Checked_Menu)
IF self.regions_source THEN Widget_Control, self.sourceID, Set_Button = 1 ELSE Widget_Control, self.backgroundID, Set_Button = 1

self.polygonparID = Widget_Button(propertiesID, Value = 'Polygon ', UValue = 'Polygon', /Checked_Menu, /Separator)
self.lineparID = Widget_Button(propertiesID, Value = 'Line ', UValue = 'Line', /Checked_Menu)
IF self.regions_polygon THEN Widget_Control, self.polygonparID, Set_Button = 1 ELSE Widget_Control, self.lineparID, Set_Button = 1

widthID = Widget_Button(self.regionsID, Value = 'Width', UValue = 'Width', /Menu)
self.widthIDs[0] = Widget_Button(widthID, Value = '1', UValue = 'Width', /Checked_Menu)
self.widthIDs[1] = Widget_Button(widthID, Value = '2', UValue = 'Width', /Checked_Menu)
self.widthIDs[2] = Widget_Button(widthID, Value = '3', UValue = 'Width', /Checked_Menu)
self.widthIDs[3] = Widget_Button(widthID, Value = '4', UValue = 'Width', /Checked_Menu)
self.widthIDs[4] = Widget_Button(widthID, Value = '5', UValue = 'Width', /Checked_Menu)
self.widthIDs[5] = Widget_Button(widthID, Value = '6', UValue = 'Width', /Checked_Menu)
self.widthIDs[6] = Widget_Button(widthID, Value = '7', UValue = 'Width', /Checked_Menu)
self.widthIDs[7] = Widget_Button(widthID, Value = '8', UValue = 'Width', /Checked_Menu)
self.widthIDs[8] = Widget_Button(widthID, Value = '9', UValue = 'Width', /Checked_Menu)
self.widthIDs[9] = Widget_Button(widthID, Value = '10', UValue = 'Width', /Checked_Menu)
Widget_Control, self.widthIDs[self.regions_width-1], Set_Button=1

linestyleID = Widget_Button(self.regionsID, value = 'Linestyle', UValue = 'Linestyle', /Menu)
self.linestyleIDs = intArr(6)
self.linestyleIDs[0] = Widget_Button(linestyleID, Value = 'Solid', UValue = 'Linestyle', /Checked_Menu)
self.linestyleIDs[1] = Widget_Button(linestyleID, Value = 'Dotted', UValue = 'Linestyle', /Checked_Menu)
self.linestyleIDs[2] = Widget_Button(linestyleID, Value = 'Dashed', UValue = 'Linestyle', /Checked_Menu)
self.linestyleIDs[3] = Widget_Button(linestyleID, Value = 'Dash-Dot', UValue = 'Linestyle', /Checked_Menu)
self.linestyleIDs[4] = Widget_Button(linestyleID, Value = 'Dash-Dot-Dot-Dot', UValue = 'Linestyle', /Checked_Menu)
self.linestyleIDs[5] = Widget_Button(linestyleID, Value = 'Long Dash', UValue = 'Linestyle', /Checked_Menu)
Widget_Control, self.linestyleIDs[self.regions_linestyle], Set_Button=1

colorID = Widget_Button(self.regionsID, Value = 'Color',UValue = 'Color')
compositeID = Widget_Button(self.regionsID, value = 'Composites', UValue = 'Composites', /Menu)
createcompositeID = Widget_Button(compositeID, Value = 'Create Composite')
dissolvecompositeID = Widget_Button(compositeID, Value = 'Dissolve Composite')

; Coordinates pull down menu
self.coordinatesID = Widget_Button(menubarID, Value = 'Coordinates', sensitive=sensitive)
self.J2000ID = Widget_Button(self.coordinatesID, Value = 'Equatorial J2000', /Checked_Menu)
self.B1950ID = Widget_Button(self.coordinatesID, Value = 'Equatorial B1950', /Checked_Menu)
self.galacticID = Widget_Button(self.coordinatesID, Value = 'Galactic', /Checked_Menu)
self.eclipticID = Widget_Button(self.coordinatesID, Value = 'Ecliptic', /Checked_Menu)
;self.horizonID = Widget_Button(self.coordinatesID, Value = 'Horizon', /Checked_Menu)
self.degreeID = Widget_Button(self.coordinatesID, Value = 'Degrees', /Checked_Menu, /Separator)
self.sexadecimalID = Widget_Button(self.coordinatesID, Value = 'Sexadecimal', /Checked_Menu)

IF Obj_Valid(self.image) THEN BEGIN
    self.image->GetProperty, current_coords = current_coords, sexadecimal = sexadecimal
    CASE current_coords OF
        'J2000': Widget_Control, self.J2000ID, Set_Button=1
        'B1950': Widget_Control, self.B1950ID, Set_Button=1
        'Galactic': Widget_Control, self.galacticID, Set_Button=1
        'Ecliptic': Widget_Control, self.eclipticID, Set_Button=1
    ENDCASE
    IF sexadecimal THEN Widget_Control, self.sexadecimalID, Set_Button=1 ELSE Widget_Control, self.degreeID, Set_Button=1
ENDIF ELSE BEGIN
    Widget_Control, self.galacticID, Set_Button=1
    Widget_Control, self.degreeID, Set_Button=1
ENDELSE

; Analysis
self.analysisID = Widget_Button(menubarID, Value = 'Analysis', sensitive=sensitive)
interactive_plotID = Widget_Button(self.analysisID, Value = 'Interactive Plots', /Menu)
self.xplotID = Widget_Button(interactive_plotID, Value = 'XPlot', /Checked_Menu)
self.yplotID = Widget_Button(interactive_plotID, Value = 'YPlot', /Checked_Menu)
self.zplotID = Widget_Button(interactive_plotID, Value = 'ZPlot', /Checked_Menu)
self.noneID = Widget_Button(interactive_plotID, Value = 'None', /Checked_Menu, /Separator)
Widget_Control, self.noneID, Set_Button=1
;DAOPhotID = Widget_Button(self.analysisID, Value = 'DAOPhot')
;thresholdImagelID = Widget_Button(self.analysisID, Value = 'Threshold Image')
;self.threeDID = Widget_Button(self.analysisID, Value = '3D')
;smoothID = Widget_Button(self.analysisID, Value = 'Smooth')
;fitID = Widget_Button(self.analysisID, Value = 'Fit Profile', Event_Pro = 'Kang_Events')
;velfieldID = Widget_Button(self.analysisID, Value = 'Velocity Field', Event_Pro = 'Kang_Velocity_Field')

; Context Base
self.contextBaseID = Widget_Base(self.tlbID, /Context_Menu, Event_Pro = 'Kang_Context_Events')

; Define some labels
topareaBase = Widget_Base(self.tlbID, Column = 2)
labelsID = Widget_Base(topareaBase, Column=1, /Frame)
toplabelsID = Widget_Base(labelsID, Row = 1)
label = Widget_Label(toplabelsid, Value = 'Image')
self.xlabelID = Widget_Label(toplabelsid, Value = '  X')
self.xvalueID = CW_Field(toplabelsid, Title = '', Value = 0., /Float, /NoEdit, XSize = 14)
;xvalueID = Widget_Label(toplabelsid, Value = '  ', scr_xsize = 40)
self.ylabelID = Widget_Label(toplabelsid, Value = '  Y')
self.yvalueID = CW_Field(toplabelsid, Title = '', Value = 0., /Float, /NoEdit, XSize = 14)
;yvalueID = Widget_Label(toplabelsid, Value = '  ', scr_xsize = 40)
valuelabel = Widget_Label(toplabelsid, Value = 'Value')
self.valueID = CW_Field(toplabelsid, Title = '', Value = 0., /Float, /NoEdit, XSize = 14)
;valueID = Widget_Label(toplabelsid, Value = '  ', scr_xsize = 40)

bottomlabelsID = Widget_Base(labelsID, Row = 1)
label = Widget_Label(bottomlabelsID,  Value = 'WCS  ')
self.longlabelID = Widget_Label(bottomlabelsID, Value = '  l')
self.longvalueID = CW_Field(bottomlabelsID, Title = '', Value = 0., /String, /Return_Events, XSize = 14)
self.latlabelID = Widget_Label(bottomlabelsID, Value = '  b')
self.latvalueID = CW_Field(bottomlabelsID, Title = '', Value = 0., /String, /Return_Events, XSize = 14)
Widget_Control, self.longvalueID, Set_UValue = {name: 'Long', otherID: self.latvalueID}
Widget_Control, self.latvalueID, Set_UValue = {name: 'Lat', otherID: self.longvalueID}

; Zoom draw windows
minidrawwindowID = Widget_Base(topareaBase, Column = 1, /Align_Right)
self.zoom_DrawID = Widget_Draw(minidrawwindowID, XSize=100, YSize=100)

; Define the draw widget.
IF N_Elements(xsize) NE 0 THEN self.xsize = 100 > xsize
IF N_Elements(ysize) NE 0 THEN self.ysize = 100 > ysize
self.drawID = Widget_Draw(self.tlbID, XSize=self.xsize, YSize=self.ysize, Event_Pro = 'Kang_Events', /Wheel_Events)

; Define sliders for brightness, contrast
self.brightnessID = Widget_Slider(self.tlbID, /suppress_value, xsize=xsize, /Drag, Minimum=0, Maximum=100, $
                                  UValue='brightness_slider', Value=50)
self.contrastID = Widget_Slider(self.tlbID, /suppress_value, xsize=xsize, /Drag, Minimum=0, Maximum=100, $
                                UValue='contrast_slider', Value=50)

 ; Realize the widget hierarchy.
IF !D.Name NE 'PS' THEN BEGIN
    Widget_Control, self.tlbID, /Realize
    Widget_Control, self.tlbID, TLB_Get_Size=tlbsize
    self.tlbsize = tlbsize

; Get the window index number of the draw widget window. Set title
; with WID.
    Widget_Control, self.drawID, Get_Value=wid
    self.wid = wid
    WSet, self.wid
    Widget_Control, self.zoom_drawID, Get_Value=zoom_wid
    self.zoom_wid = zoom_wid

; Make pixmap window
    Window, /Free, /Pixmap, XSize=self.xsize, YSize=self.ysize
    self.pix_wid = !D.Window
;    Window, /Free, /Pixmap, XSize=self.xsize, YSize=self.ysize
;    self.pix_wid2 = !D.Window
;    Window, /Free, /Pixmap, XSize=self.xsize, YSize=self.ysize
;    self.pix_wid3 = !D.Window

; Make zoom pixmap window
    Window, /Free, /Pixmap, XSize=100, YSize=100
    self.zoom_pix_wid = !D.Window

ENDIF ELSE BEGIN
    self.tlbsize = [0, 0]
    self.wid = -1
    self.pix_wid = -1
;    self.pix_wid2 = -1
;    self.pix_wid3 = -1

; Set quit flag
    quit=1
ENDELSE

; Set title
IF N_Elements(windowTitle) NE 0 THEN self.user_windowTitle = windowTitle
IF self.user_windowTitle NE '' THEN self.windowTitle = 'Kang ('+StrTrim(self.wid, 2)+')' ELSE $
  self.windowTitle = self.user_windowTitle
Widget_Control, self.tlbID, Base_Set_Title = 'Kang';self.windowTitle

; Turn on events
IF sensitive THEN BEGIN
    Widget_Control, self.drawID, /Draw_Button_Events, /Draw_Motion_Events, Draw_Keyboard_Events = 2, /Input_Focus
    Widget_Control, self.tlbID, /KBRD_Focus_Events
ENDIF

; Draw image, set menu buttons correctly
self.realized = 1B
self->Change_Image, self.whichImage

; Set up the event loop. Register the program with the window manager.
XManager, 'Kang ' + StrTrim(self.tlbID, 2), self.tlbID, No_Block = ~Keyword_Set(block), $
          Cleanup='Kang_Cleanup', Event_Handler = 'Kang_Events'
self->Draw

; Bring up widgets
IF Obj_valid(self.image) THEN self->plot_params_widget
self->Velocity_Widget

END; Kang::Gui--------------------------------------------------


;+
; Removes the GUI from the display
;
; :Private:
;
;-
PRO Kang::NoGUI

Widget_Control, self.tlbID, /Destroy
self->SetRealized, 0

END; Kang::NoGUI--------------------------------------------------


;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
; Object initialization routines and GUI
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;+
; Initializes the object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Params:
;  image_in : in, optional, type = 'float OR string'
;    The image data. Can be an array or a filename.
;  header_in : in, optional, type = 'string'
;     The header data.
;
; :Keywords:
;  AxisColor : 
;    The axis color.
;  BackColor : 
;    The background color.
;  BarTitle : 
;    Colorbar title
;  Block : 
;    Blocks the command line
;  Brightness :
;    Brightness (stretch)
;  C_Annotation : 
;    Contour annotations
;  C_Charsize : 
;    Contour annotation character size
;  C_Colors : 
;    Contour colors
;  C_Labels : 
;    Contour labels (binary array)
;  C_Linestyle : 
;    Contour line styles (solid, dashed, etc)
;  C_Thick : 
;    Contour thickness
;  Charsize : 
;    Character size for axes
;  Charthick : 
;    Character thickness for axes
;  Clip : 
;    The percentage at which to clip the input image
;  ColorTable : 
;    The colortable index to load
;  Contrast : 
;    Contrast (level)
;  Contours :
;    Binary array for which image should be displayed with contours
;  Deltavel :
;    Range to intergated the velocity over
;  Downhill :
;    Downhill contours
;  Filename :
;    Output file name
;  Font :
;    The axes font
;  HighScale :
;    The highest value to plot
;  Invert :
;    Invert the color table
;  Levels :
;    Contour levels
;  Limits :
;    Data limits: [xmin, xmax, ymin, ymax]
;  LowScale :
;    The lowest value to plot
;  Max_value :
;    Max value for contours - used with nlevels keyword
;  Mask :
;    Output mask
;  Min_value :
;    Max value for contours - used with nlevels keyword
;  Minor :
;    Minor tick marks
;  NLevels :
;    Number of contour levels
;  NoAxis :
;    Don't plot the axis
;  NoBar :
;    Don't plot the color bar
;  OutFile :
;    Image output file. Can be jpg, ps, gif, etc. This is a scaler
;  Position :
;    The position of the plot in the window
;  Quit :
;    Quit after loaded - good for immediate output of ps files
;  RegionFile :
;    Region file to load
;  Reverse :
;    Reverse the color table
;  Scale_To_Image :
;    Will scale the image based on the min and max of the current image displayed
;  Scaling :
;    Which type of scaling to use
;  Sexadecimal :
;    Sexadecimal numbers on axes
;  Subtitle :
;    Subtitle
;  TickColor :
;    Tickmark color
;  Ticklen :
;    The length of the tickmarks. 0.02 is the default and 1 draws a grid
;  Ticks :
;    Major tick marks
;  Title :
;    Title printed above plot
;  tlbid :
;    Outputs the widget ID of the program. Useful for getting information out if necessary.
;  Velocity :
;    The velocity of the 3-D image to display
;  Wid :
;    This is an output variable for the main draw window ID
;  XSize :
;    The size of draw window in the y direction
;  XTitle :
;    The X-Axis title
;  YSize :
;    The size of draw window in the y direction
;  YTitle :
;    The Y-Axis title
;
;-
FUNCTION Kang::Init, $
  image_in, $                   ; The image data. Can be an array or a filename.
  header_in, $                  ; The header data.
  AxisColor=axisColor, $        ; The axis color.
  BackColor=backColor, $        ; The background color.
  BarTitle=bartitle, $          ; Colorbar title
  Block=block, $                ;Blocks the command line
  Brightness=brightness, $      ; Brightness (stretch)
  C_Annotation=c_annotation, $  ; Contour annotations
  C_Charsize=c_charsize, $      ; Contour annotation character size
  C_Colors=c_colors, $          ; Contour colors
  C_Labels=c_labels, $          ; Contour labels (binary array)
  C_Linestyle=c_linestyle, $    ; Contour line styles (solid, dashed, etc)
  C_Thick=c_thick, $            ; Contour thickness
  Charsize=charsize, $          ; Character size for axes
  Charthick=charthick, $        ; Character thickness for axes
  Clip=clip, $                  ; The percentage at which to clip the input image
  ColorTable=colortable, $      ; The colortable index to load
  Contrast=contrast, $          ; Contrast (level)
  Contours = contours, $        ; Binary array for which image should be displayed with contours
  Deltavel=deltavel, $          ; Range to intergated the velocity over
  Downhill=downhill, $          ; Downhill contours
;  _Extra=extra, $          ; For passing extra keywords
  Filename=filename, $          ; Output file name
  Font=font, $                  ; The axes font
;  GUI=gui, $                    ;Boolean for whether to bring up GUI
  HighScale=highScale, $        ; The highest value to plot
  Invert=invert, $              ; Invert the color table
  Levels=levels, $              ; Contour levels
  Limits=limits, $              ; Data limits: [xmin, xmax, ymin, ymax]
  LowScale=lowScale, $          ; The lowest value to plot
  Max_value=max_value, $        ; Max value for contours - used with nlevels keyword
  Mask = mask, $                ; Output mask
  Min_value=min_value, $        ; Max value for contours - used with nlevels keyword
  Minor=minor, $                ; Minor tick marks
  NLevels=nlevels, $            ; Number of contour levels
  NoAxis=noaxis, $              ; Don't plot the axis
  NoBar=nobar, $                ; Don't plot the color bar
  OutFile=outfile, $            ; Image output file. Can be jpg, ps, gif, etc. This is a scaler
  Position=position, $          ; The position of the plot in the window
  Quit=Quit, $                  ; Quit after loaded - good for immediate output of ps files
  RegionFile=regionfile, $      ; Region file to load
  Reverse=reverse, $            ; Reverse the color table
  Scale_To_Image=scale_to_image, $ ; Will scale the image based on the min and max of the current image displayed
  Scaling=scaling, $            ; Which type of scaling to use
  Sexadecimal=sexadecimal, $    ; Sexadecimal numbers on axes
  Subtitle=subtitle, $          ; Subtitle
  TickColor=tickColor, $        ; Tickmark color
  Ticklen=ticklen, $            ; The length of the tickmarks. 0.02 is the default and 1 draws a grid
  Ticks=ticks, $                ; Major tick marks
  Title=title, $                ; Title printed above plot
  tlbid=tlbid, $                ; Outputs the widget ID of the program. Useful for getting information out if necessary.
  Velocity=velocity, $          ; The velocity of the 3-D image to display
  Wid=wid, $                    ; This is an output variable for the main draw window ID
  WindowTitle = windowTitle, $  ; The title of the main window
  XSize=xsize, $                ; Size of draw window in x direction
  XTitle=xtitle, $              ; The X-Axis title
  YSize=ysize, $                ; Size of draw window in y direction
  YTitle=ytitle                 ; The Y-Axis title

; Catch any error in the Kang program.
Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(Traceback=1)
   RETURN, 0B
ENDIF

;--------------------------------------------------------------------------------
; Check for input paramters
;--------------------------------------------------------------------------------
CASE size(image_in, /TName) OF
    'STRING': n_image=N_Elements(image_in)
    'UNDEFINED': n_image=0
    ELSE: n_image = 1
ENDCASE
n_header=N_Elements(header_in)
n_AxisColor=N_Elements(AxisColor)
n_BackColor=N_Elements(BackColor)
n_BarTitle=N_Elements(BarTitle)
n_Brightness=N_Elements(Brightness)
n_C_Annotation=N_Elements(C_Annotation)
n_C_Charsize=N_Elements(C_Charsize)
n_C_Colors=N_Elements(C_Colors)
n_C_Labels=N_Elements(C_Labels)
n_C_Linestyle=N_Elements(C_Linestyle)
n_C_Thick=N_Elements(C_Thick)
n_Charsize=N_Elements(Charsize)
n_Charthick=N_Elements(Charthick)
n_Clip=N_Elements(Clip)
n_ColorTable=N_Elements(ColorTable)
n_Contrast=N_Elements(Contrast)
n_Contours=N_Elements(Contours)
n_Deltavel=N_Elements(Deltavel)
n_Downhill=N_Elements(Downhill)
;n__Extra=N_Elements(_Extra)
n_Filename=N_Elements(Filename)
n_Font=N_Elements(Font)
n_HighScale=N_Elements(HighScale)
n_invert=N_Elements(Invert)
n_Levels=N_Elements(Levels)
n_Limits=N_Elements(Limits)
n_LowScale=N_Elements(LowScale)
n_Max_value=N_Elements(Max_value)
n_Mask=N_Elements(Mask)
n_Min_value=N_Elements(Min_value)
n_Minor=N_Elements(Minor)
n_NLevels=N_Elements(NLevels)
n_NoAxis=N_Elements(NoAxis)
n_NoBar=N_Elements(NoBar)
n_Position=N_Elements(Position)
n_Quit=N_Elements(Quit)
n_RegionFile=N_Elements(RegionFile)
n_Reverse=N_Elements(Reverse)
n_Scale_To_Image=N_Elements(Scale_To_Image)
n_Scaling=N_Elements(Scaling)
n_Sexadecimal=N_Elements(Sexadecimal)
n_Subtitle=N_Elements(Subtitle)
n_TickColor=N_Elements(TickColor)
n_Ticklen=N_Elements(Ticklen)
n_Ticks=N_Elements(Ticks)
n_Title=N_Elements(Title)
n_tlbid=N_Elements(tlbid)
n_Velocity=N_Elements(Velocity)
n_Wid=N_Elements(Wid)
n_XTitle=N_Elements(XTitle)
n_YTitle=N_Elements(YTitle)

;--------------------------------------------------------------------------------------------
; Define some parameters
self.whichImage=-1
cd, current=lastpath
self.lastpath = lastpath
self.last_regionpath = lastpath
self.n_images = 8                    ;Default number of images
;device, retain = 2

; Store old window id, Obtain the current RGB color vectors.
self.oldwid = !D.Window
TVLCT, r_old, g_old, b_old, /Get
IF !D.Name EQ 'X' OR !D.Name EQ 'WIN' THEN Device, Decomposed=0	

; Draw window size and title
IF N_Elements(xsize) EQ 0 THEN self.xsize = 600 ELSE self.xsize = xsize > 100
IF N_Elements(ysize) EQ 0 THEN self.ysize = 550 ELSE self.ysize = ysize > 100
IF N_Elements(windowTitle) EQ 0 THEN self.user_windowTitle = '' ELSE self.user_windowTitle = windowTitle

;-----------------Other variables-----------------------------
;rgb_view = lonarr(!n_images, 3)
;rgb_view[*] = -1

; Define some objects
self.fsc_psconfig = Obj_New('FSC_PSConfig')
self.fsc_psconfig_spectra = Obj_New('FSC_PSConfig')
self.image_container = Obj_New('IDL_Container')
self.histogram_container = Obj_New('IDL_Container')
self.regions_container = Obj_New('IDL_Container')
self.colors_container = Obj_New('IDL_Container')
self.spectra = Obj_New('Kang_Spectra_Container')
self.copied_regions = Ptr_New()

self.velocityID = Ptr_New(lonArr(self.n_images))

; Global region properties
self.regions_width = 1L
self.regionType = 'Box'
self.regions_cName = 'Green'
self.regions_include = 1B
self.regions_source = 1B
self.regions_polygon = 1B
;r_old

; Determine what inputs user wants
image_loaded=0
;------------------------------------------------------------
; Loop through the images, loading and setting parameters.
; Only allow parameters to be set if a valid image was loaded
FOR i = 0, N_Image - 1 DO BEGIN

; These are filename inputs
    IF size(image_in, /tname) EQ 'STRING' THEN BEGIN
        self->Load_Filename, image_in[i], good_image = good_image, /noplot
    ENDIF ELSE BEGIN
; These are arrays
        IF N_Header EQ 0 THEN header = '' ELSE header = header
        self->Load_Image, image_in, header_in, filename = 'Commandline Array', good_image = good_image, /noplot
    ENDELSE

; If an image was successfully loaded, set user defined parameters
    IF good_image THEN BEGIN
        IF n_AxisColor GT i THEN self->Axis, AxisColor = AxisColor[i]
        IF n_BackColor GT i THEN self->Axis, BackColor = BackColor[i]
        IF n_BarTitle GT i THEN self->Axis, BarTitle = BarTitle[i]
        IF n_Charsize GT i THEN self->Axis, Charsize = Charsize[i]
        IF n_Charthick GT i THEN self->Axis, Charthick = Charthick[i]
        IF n_Filename GT i THEN self.image->SetProperty, Filename = Filename[i]
        IF n_Font GT i THEN self->Axis, Font = Font[i]
        IF n_Levels GT i THEN self.image->SetProperty, Levels = Levels, percent=0
        IF n_Limits GT i THEN self->Limits, limits
        IF n_Minor GT i THEN self->Axis, Minor = Minor[i]
        IF n_NoAxis GT i THEN self->Axis, NoAxis = NoAxis[i]
        IF n_NoBar GT i THEN self->Axis, NoBar = NoBar[i]
        IF n_Position EQ 4 THEN self.image->SetProperty, Position = Position
        IF n_Sexadecimal GT i THEN self->Axis, Sexadecimal = Sexadecimal[i]
        IF n_Subtitle GT i THEN self->Axis, Subtitle = Subtitle[i]
        IF n_TickColor GT i THEN self->Axis, TickColor = TickColor[i]
        IF n_Ticklen GT i THEN self->Axis, Ticklen = Ticklen[i]
        IF n_Ticks GT i THEN self->Axis, Ticks = Ticks[i]
        IF n_Title GT i THEN self->Axis, Title = Title[i]

        IF n_Velocity GT i THEN BEGIN
            IF n_Deltavel GT i THEN deltavel = deltavel[i]*1000.
            self.image->SetVelocity, velocity[i]*1000., deltavel = deltavel
            self.histogram->GetProperty, lowscale = lowscale1, highscale = highscale1
            self.image->BytScl, lowscale1, highscale1
        ENDIF

        IF n_XTitle GT i THEN self->Axis, XTitle = XTitle[i]
        IF n_YTitle GT i THEN self->Axis, YTitle = YTitle[i]
        
        IF n_C_Charsize GT i THEN self->Contour, C_Charsize = C_Charsize[i]
        IF n_C_Colors GT i THEN self->Contour, C_Colors = C_Colors[i]
        IF n_C_Labels GT i THEN self->Contour, C_Labels = C_Labels[i]
        IF n_C_Linestyle GT i THEN self->Contour, C_Linestyle = C_Linestyle[i]
        IF n_C_Thick GT i THEN self->Contour, C_Thick = C_Thick[i]
        IF n_C_Annotation GT i THEN self->Contour, C_Annotation = C_Annotation[i]
        IF n_Max_value GT i THEN self->Contour, Max_value = Max_value[i]
        IF n_Min_value GT i THEN self->Contour, Min_value = Min_value[i]
        IF n_NLevels GT i THEN self->Contour, NLevels = NLevels[i]
        IF n_Downhill GT i THEN self->Contour, Downhill = Downhill[i]

; -----------------------Histogram Properties---------------------------------
        IF n_lowscale GT i THEN BEGIN
            self.histogram->SetProperty, lowscale = lowscale[i]
            lowscale_0 = lowscale[i]

; Find highscale if it wasn't set
            IF n_highscale LE i THEN self.histogram->GetProperty, highscale = highscale_0
        ENDIF

        IF n_highscale GT i THEN BEGIN
            self.histogram->SetProperty, highscale = highscale[i]
            highscale_0 = highscale[i]

            IF n_lowscale LE i THEN self.histogram->GetProperty, lowscale = lowscale_0
        ENDIF
        IF n_lowscale GT i OR n_highscale GT i THEN self.image->BytScl, lowscale_0, highscale_0

; Histogram clipping
        IF n_clip GT i THEN BEGIN
            self.histogram->Clip, 1 < clip[i] > 0
            self.histogram->GetProperty, lowscale = lowscale_clip, highscale = highscale_clip
            self.image->BytScl, lowscale_clip, highscale_clip
        ENDIF

; Scale to image - this will override any other scaling
        IF n_scale_to_image GT i THEN BEGIN
            IF scale_to_image[i] GT 0 THEN self->Scale, lowscale2, highscale2, /Scale_to_image
            self.histogram->SetProperty, lowscale=lowscale2, highscale=highscale2
        ENDIF

;---------------------------Colors Properties----------------------------------
        IF n_ColorTable GT i THEN self->Color, colortable = 0 > ColorTable[i] < 40 ELSE self->Color, colortable = 3
        IF n_Brightness GT i THEN self->Stretch, Brightness = Brightness[i]
        IF n_Contrast GT i THEN self->Stretch, Contrast = Contrast[i]
        IF n_Invert GT i THEN self->Color, Invert = invert[i]
        IF n_reverse GT i THEN self->Color, reverse = reverse[i]

; Scaling type - default is linear
        IF n_Scaling GT i THEN BEGIN
            scal_arr = ['Linear', 'Log', 'HistEq', 'asinh', 'Power', 'Gaussian']

; Determine where the scaling array matches
            wh_scaling = where(StrTrim(StrUpCase(scaling[i])) EQ StrUpCase(scal_arr))
            IF wh_scaling NE -1 THEN BEGIN
                self.colors->SetProperty, Scaling = scal_arr[wh_scaling]
                self.colors->Make_Ramp
                self.colors->TVLCT
                Widget_Control, self.linearID, Set_Button=1
            ENDIF
        ENDIF

; -------------------------------Regions----------------------------------------------
        IF n_RegionFile GT i THEN self->Load_Regions, regionfile[i]
;        IF n_Mask GT i THEN info.regions->GetProperty, Mask  = Mask
    ENDIF
ENDFOR

; Update the contour array
IF n_contours GT 0 THEN self.whichContours[0:n_contours-1] = contours

; Plot the image
self->Draw

; Make output file
IF N_Elements(outfile) NE 0 THEN self->Save, outfile

;    filename = FSC_Base_Filename(outfile, Directory=directory, Extension=extension)
;    filename = StrJoin([directory, filename])

;    CASE StrUpCase(extension) OF
;        'JPG': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /jpg, filename = filename
;        'JPG': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /jpg, filename = filename
;        'PNG': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /png, filename = filename
;        'GIF': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /gif, filename = filename
;        'BMP': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /bmp, filename = filename
;        'TIF': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /tiff, filename = filename
;        'TIFF': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /tiff, filename = filename
;        'PICT': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /pict, filename = filename
;        'FITS': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /fits, filename = filename
;        'FIT': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /fits, filename = filename
;        'PS': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /ps, filename = filename, /color, bits_per_pixel=8
;        'EPS': Kang_Save, {ID:0L, TOP:tlbID, HANDLER:0L}, /CommandLine, /ps, filename = filename, /color, /eps, bits_per_pixel=8
;    ENDCASE
;ENDIF

; Quit
;IF Keyword_Set(Quit) THEN Kang_Quit, {TOP:tlbID}

RETURN, 1B
END; Kang::Init---------------------------------------------------------------------------


;+
; Defines the variables for the self structure.
; :Private:
;
;-
PRO Kang__Define

n_images = 8
struct = {KANG, $
          tlbID:0L, $
          realized:0B, $        ; Is the GUI realized?
          image_container:Obj_New(), $ ; The image information
          image:Obj_New(), $    ; Image object reference
          whichContours:lonArr(n_images), $ ; This boolean array shows which image to contour
          whichImage:0L, $      ; This is the current display image
          n_images:0L, $        ; How long to make the file dialog
          show:Ptr_New(), $     ; Byte array - one for each image - that is 1 if we show, 0 if hidden. 
          
; Parameters of the session when the program was called
          old_colors:Obj_New(), $ ; An object to store the old color values
          r_old:BytArr(256), $  ; The color vectors used before kang began
          g_old:BytArr(256), $
          b_old:BytArr(256), $
          oldwid:0L, $          ; The window index number used before kang
          systime:0D, $         ; This aids in changing the colors

; ------------Identifiers for the widgets and widget variables----------------
; Main widget display
          brightnessID:0L, $    ; The identifier of the brightness slider
          contrastID:0L, $      ; The identifier of the contrast slider
          contextBaseID:0L, $   ; Right click menu
          zoom_DrawID:0L, $
          drawID:0L, $          ; The identifier of the draw widget.         
          xlabelID:0L, $        ; Coordinate Labels at top of main widget
          ylabelID:0L, $
          xvalueID:0L, $
          yvalueID:0L, $
          valueID:0L, $
          longlabelID:0L, $
          latlabelID:0L, $
          longvalueID:0L, $
          latvalueID:0L, $
          xsize:0L, $           ; The X size of the graphics window (used when resizing)
          ysize:0L, $           ; The Y size of the graphics window.
          tlbsize:[0L, 0L], $   ; The size of the program in device units
          wid:0L, $             ; The window index number of the graphics window.
          zoom_wid:0L, $        ; The window index number of the small zoom window.
          zoom_pix_wid:0L, $    ; The window index number of the pixmap zoom window.
          user_windowtitle:'', $ ; The user-defined window title.
          windowtitle:'', $     ; The window title.
          
; ------------------Menubar IDs-----------------------
; File
          velocity_widgetID:0L, $

; Edit
          cutID:0L, $           ; Edit identifiers
          copyID:0L, $
          pasteID:0L, $

; Frames
          showHideID: 0L, $     ; Frames identifiers

; Zoom          
          zoomID:0L, $
          
; Colors
          invertID:0L, $        ; Colors identifiers
          reverseID:0L, $
          
; Scaling
          scalingID:0L, $       ; Scaling identifiers
          linearID:0L, $
          logID:0L, $
          gaussianID:0L, $
          histEqID:0L, $
          asinhID:0L, $
          powerID:0L, $
          squaredID:0L, $
          squarerootID:0L, $

; Regions
          regionsID:0L, $       ; Region identifiers
          boxID:0L, $
          circleID:0L, $
          ellipseID:0L, $
          crossID:0L, $
          thresholdID:0L, $
          textID:0L, $
          lineID:0L, $
          freehandID:0L, $
;        polygonID:0L, $
;        annulusID:0L, $
          widthIDs:intArr(10), $
          linestyleIDs:intArr(6), $
          includeID:0L, $
          excludeID:0L, $
          sourceID:0L, $
          backgroundID:0L, $
          polygonparID:0L, $
          lineparID:0L, $

; Coordinates
          coordinatesID:0L, $   ; Coordinate identifiers
          J2000ID:0L, $
          B1950ID:0L, $
          eclipticID:0L, $
          galacticID:0L, $
;        horizonID:0L, $
          degreeID:0L, $
          sexadecimalID:0L, $
          
; Interactive Plots
          xplotID:0L, $
          yplotID:0L, $
          zplotID:0L, $
          noneID:0L, $
          editID:0L, $
          colorsID:0L, $
          threeDID:0L, $
          analysisID:0L, $
          
; ----------------File dialog identifiers and filenames------------------------
          lastFilename:'', $    ; The filename to start with
          lastpath:'', $        ; The path to start with
          last_regionpath:'', $ ; Separate paths for region files is nice
          
; ------------Second draw window identifiers-----------------
          windows_tabBase:0L, $ ; ID for the tabs so we can change them
          spectrum_WID:0L, $    ; Window ID for the spectrum window
          minispectrum_WID:0L, $ ; Window ID for the mini-spectrum window
          plot_WID:0L, $        ; Window ID for the plot window
          spectrum_window:Obj_New(), $ ; Object for spectrum window - controls basic functions
          minispectrum_window:Obj_New(), $ ; Object for mini-spectrum window - controls basic functions
          plot_window:Obj_New(), $ ; Object for plot window - controls basic functions
          
;------------------------Velocity widget------------------------------
          velocityID:Ptr_New(), $
          
; -------- Variables for interacting with the main draw window-------------
; Mouse stuff: rubberband box, right mouse menu, etc.
          doubleclick:0B, $     ; Boolean for whether user doubleclicked
          inside:0B, $          ; Boolean for whether click is within region
          whichInside:0L, $     ; The region indices that the click falls within
          pix_wid:0L, $         ; The pixmap identifier where all plots are sent
;          pix_wid2:0L, $         ; The pixmap identifier where all annotations are sent
;          pix_wid3:0L, $         ; The pixmap identifier where annotations and images are combined
          current_pix:[0., 0.], $ ; Current mouse position in pixels ([x, y])
          current_data:[0., 0L], $ ; Current mouse position in data coords ([x, y])
          initial_pix:[0., 0.], $ ; When drawing a region, this is the first click in pixels ([x, y])
          final_pix:[0., 0.], $ ; When drawing a region, this is the last click in pixels ([x, y])
          initial_data:[0., 0.], $ ; When drawing a region, this is the first click in data coords ([x, y])
          final_data:[0., 0.], $ ; When drawing a region, this is the last click in data coords ([x, y])
          initial_device:[0L, 0L], $ ; When adjusting stretch, this is first click
          drawingRegion:0, $    ; Boolean for whether user is currently drawing a region
          selectingRegion:0B, $ ; Boolean for whether user is currently drawing a selection box
          adjustingStretch:0B, $ ; Boolean for whether user is currently adjusting strech with right mouse button
          right_click:0B, $     ; Boolean for whether user has the right mouse button down
          mask:0B, $            ; Boolean for whether the mask is being flashed on the display

; Region variables
          drawingColor:0B, $    ; Color to use when drawing a region (string)
          selectingColor:0B, $  ; Color to use when selecting multiple regions
          regions_container:Obj_New(), $ ; Region objects which hold all information about the regions 
          regions:Obj_New(), $  ;Current region object reference
          regions_color:0B, $   ; The default color at startup for drawing regions
          regions_cName:'', $   ; The default colorname at startup for drawing regions
          regions_include:0B, $ ; Boolean for whether regions being drawn are excluded regions
          regions_source:0B, $  ; Boolean for whther regions being drawn are source or background
          regions_polygon:0B, $ ; Boolean for whther regions being drawn are polygons (filled) or lines (unfilled)
          regions_width:0L, $   ; Width of region being drawn
          regions_linestyle:0L, $ ; Linestyle of region being drawn
          noregion:0, $         ; Boolean for whether user clicked outside all regions
          polygon_pts:Ptr_New(), $ ; Holds the polygon and freehand veritces while it's being drawn
          threshold_invert:BytArr(n_images), $ ; Boolean for inverting the threshold (using troughs instead of peaks)
          regionType:'', $      ; Type of region being drawn
          copied_regions:Ptr_New(), $ ; Container to hold any copied regions - like a clipboard
          regionBoxes:Ptr_New(), $ ; Data in device coordinates used to resize regions
          
; Analysis
          profile_WidgetID:0L, $       ;ID for the profile dialog
          profile_region:Obj_New(), $ ; If doing a profile, this stores the region of interest
          velfieldID:0L, $      ;ID for the velocity field dialog
          DAOPhot_WidgetID:0L, $ ;ID for the DAOPhot dialog
          DAOPhot_TableID:0L, $ ;ID for the DAOPhot table
          
; RGB stuff - not quite ready
;        red:-1, $
;        blue:-1, $
;        green: -1, $
;        rgb_image:bytarr(!n_images), $
;        rgb_view:rgb_view, $

; coordinates
;        obs_struct:{Observatory:'', Name:'', Longitude:1., Latitude:1., Altitude:1., TZ:1.}, $
;        juldate:0L, $                                                                                ; Current julian date. Used for converting to horizon
;        date:'', $                                                                                      ; Current date. Used for converting to horizon

; Spectra
          spectra:Obj_New(), $

; Keyboard
          shift:0B, $           ; Flags for if keys are being pressed
          control:0B, $
          
; Plot type
          plot_type:'None', $   ; Interactive plot type

; Post script object
          fsc_psconfig:Obj_New(), $
          fsc_psconfig_spectra:Obj_New(), $

; Colors
          colors_container:Obj_New(), $
          colors:Obj_New(), $    ; The object that manages the colors

; File dialog buttons
          deleteID:0B, $
          filenameID:strArr(n_images), $
          plotID:0B, $
          contourID:0B, $

; -------------Plot Parameters identifiers and variables--------------------
          plot_paramsID:Ptr_New(lonArr(n_images)), $
; Scale
          histogram_container:Obj_New(), $
          histogram:Obj_New(), $
          lowScaleID: Obj_New(), $
          highScaleID: Obj_New(), $
          percentSliderID: 0L, $
          histzoomID: 0L, $
          histunzoomID: 0L, $
          histlogID: 0L, $
          scaletoimageID: 0L, $
          autoUpdateID: 0L, $
          histogram_drawID: 0L, $
          histogram_wid:0L, $
          histogram_pix_wid:0L, $
; Limits
          xminID:Obj_New(), $
          xmaxID:Obj_New(), $
          yminID:Obj_New(), $
          ymaxID:Obj_New(), $
          pix_xminID:Obj_New(), $
          pix_xmaxID:Obj_New(), $
          pix_yminID:Obj_New(), $
          pix_ymaxID:Obj_New(), $
          align0ID:0L, $
          align1ID:0L, $
          align2ID:0L, $
          align3ID:0L, $
; Axis
          titleID:Obj_New(), $
          xtitleID:Obj_New(), $
          bartitleID:Obj_New(), $
          subtitleID:Obj_New(), $
          ytitleID:Obj_New(), $
          axisColorID:0L, $
          backColorID:0L, $
          tickColorID:0L, $
          charsizeID:Obj_New(), $
          charthickID:Obj_New(), $
          fontID:Obj_New(), $
          minorID:Obj_New(), $
          ticksID:Obj_New(), $
          ticklenID:Obj_New(), $
          noaxisID:0L, $
          nobarID:0L, $
;Contours
          percentButtonsID:0L, $
          nlevelsID:Obj_New(), $
          max_value:Obj_New(), $
          min_value:Obj_New(), $
          nlevels_levels:Obj_New(), $
          levels:Obj_New(), $
          c_annotation:Obj_New(), $
          c_colors:Obj_New(), $
          c_linestyle:Obj_New(), $
          c_thick:Obj_New(), $
          downhillID:0L, $
          c_labels:Obj_New(), $
          c_charsize:Obj_New(), $
          c_charthick:Obj_New(), $
          regions_listID:0L, $
          areaLabelID:0L, $
          perimeterLabelID:0L, $
          x_centerLabelID:0L, $
          y_centerLabelID:0L, $
          NPixelLabelID:0L, $
          minLabelID:0L, $
          maxLabelID:0L, $
          meanLabelID:0L, $
          StdDevLabelID:0L, $
          TotalLabelID:0L, $
; Regions
          region_NameID:0L, $
          region_WriteID:0L, $
          region_DeleteID:0L, $
          region_HistogramID:0L, $
          region_ZoomID:0L, $
          angle_sliderID:0L, $
          angle_textboxID:Obj_New(), $
          region_ColorID:0L, $
          region_widthID:0L, $
          region_linestyleID:0L, $
          region_includeID:0L, $
          region_sourceID:0L, $
          region_typeID:0L, $
          regionBase:0L, $
          current_regionBase:0L,  $
          currentTab:0L, $
          plot_params_regionType:'', $
; Plot tab
          spectrum_titleID:Obj_New(), $
          spectrum_xtitleID:Obj_New(), $
          spectrum_subtitleID:Obj_New(), $
          spectrum_ytitleID:Obj_New(), $
          spectrum_axisColorID:0L, $
          spectrum_backColorID:0L, $
          spectrum_tickColorID:0L, $
          spectrum_charsizeID:Obj_New(), $
          spectrum_charthickID:Obj_New(), $
          spectrum_fontID:Obj_New(), $
          spectrum_minorID:Obj_New(), $
          spectrum_ticksID:Obj_New(), $
          spectrum_ticklenID:Obj_New(), $
          spectrum_xminID:Obj_New(), $
          spectrum_xmaxID:Obj_New(), $
          spectrum_yminID:Obj_New(), $
          spectrum_ymaxID:Obj_New()}
          
END; Kang__Define--------------------------------------------------
