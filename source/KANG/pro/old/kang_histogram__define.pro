FUNCTION Kang_Histogram, $
  parent, $
  histogram=histogram, $
  bins=bins, $
  xsize = xsize, $
  ysize = ysize, $
  event_pro = event_pro, $
  pix_wid = pix_wid, $
  wid = wid, $
  drawID = drawID

; Create object
obj = Obj_New('KANG_HISTOGRAM', histogram=histogram, bins=bins)
IF N_Elements(xsize) EQ 0 THEN xsize = 500
IF N_Elements(ysize) EQ 0 THEN ysize = 350
self.size = [xsize, ysize]
IF N_Elements(event_pro) NE 0 THEN self.event_pro = event_pro

; These widget IDs are for when the draw window and pixmap window are
; already defined
IF N_Elements(drawID) NE 0 THEN self.drawID = drawID
IF N_Elements(wid) NE 0 THEN self.wid = wid
IF N_Elements(pix_wid) NE 0 THEN self.pix_wid = pix_wid

; Realize widget
obj->Realize, parent, xsize = xsize, ysize = ysize

RETURN, obj
END; Kang_Histogram-----------------------------------------------------------------


FUNCTION Kang_Histogram::Init, histogram=histogram, bins=bins, event_pro = event_pro, $
  drawID = drawID, pix_wid = pix_wid, wid = wid
; Initialize the object.  This entails setting the defaults and
; intializing the pointers.

;self.histogram_store = Ptr_New(histogram)
self.bins = Ptr_New(bins)
;self.histogram = Ptr_New(histogram[*, 0]) ; Store first slice as x, y values
self.histogram = Ptr_New(histogram)
self.nbins = N_Elements(bins)
self.lowscale = bins[0]
self.highscale = bins[self.nbins-1]
self.xrange = [self.lowscale, self.highscale]

; Set some parameters
IF N_Elements(event_pro) NE 0 THEN self.event_pro = event_pro
IF N_Elements(drawID) NE 0 THEN self.drawID = drawID
IF N_Elements(wid) NE 0 THEN self.wid = wid
IF N_Elements(pix_wid) NE 0 THEN self.pix_wid = pix_wid

self.log=1
self.lineby = 'NONE'

RETURN, 1
END; Kang_Histogram::Init-----------------------------------------------------------


PRO Kang_Histogram::Create, parent, xsize = xsize, ysize = ysize
; Called when the widget is realized

tlbID = Widget_Base(parent, Column=1, Event_Pro = 'Kang_Histogram_Object_Events')
self.drawID = Widget_Draw(tlbID, XSize=xsize, YSize=ysize, /Button_Events, UValue = self)

; Create pixmap window
Window, /Free, /Pixmap, xsize = xsize, ysize = ysize
self.pix_wid = !D.Window

END; Kang_Histogram::Create---------------------------------------------------------


PRO Kang_Histogram::Realize
; Called when widget is realized to get parameters out

Widget_Control, self.drawID, Get_Value = WID
self.WID = WID
;Widget_Control, self.tlbID, TLB_Get_Size=tlbsize
;self.tlbsize = tlbsize

END; Kang_Histogrma::Create---------------------------------------------------------


PRO Kang_Histogram::GetProperty, $
  autoupdate = autoupdate, $
  histogram=histogram, $
  histramp=histramp, $
  clip = clip, $
  maxscale=maxscale, $
  minscale=minscale, $
  median=median, $
  bins=bins, $
  xrange=xrange, $
  lowscale=lowscale, $
  highscale=highscale, $
  log = log, $
  wid = wid, $
  pix_wid = pix_wid

IF Arg_Present(autoupdate) THEN autoupdate = self.autoupdate
IF Arg_Present(histogram) THEN histogram = *self.histogram
IF Arg_Present(histramp) THEN BEGIN
    foo = min(Abs(*self.bins - self.lowScale), lowIndex)
    foo = min(Abs(*self.bins - self.highScale), highIndex)
    histramp = Total((*self.histogram)[lowIndex:highIndex], /Cumulative)
ENDIF
IF Arg_Present(bins) THEN bins = *self.bins
IF Arg_Present(clip) THEN clip = self.clip
IF Arg_Present(maxscale) THEN maxscale = max(*self.bins)
IF Arg_Present(minscale) THEN minscale = min(*self.bins)
IF Arg_Present(median) THEN median = (*self.bins)[where(*self.histogram EQ max(*self.histogram))]
IF Arg_Present(xrange) THEN xrange = self.xrange
IF Arg_Present(lowscale) THEN lowscale = self.lowscale
IF Arg_Present(highscale) THEN highscale = self.highscale
IF Arg_Present(log) THEN log = self.log
IF Arg_Present(wid) THEN wid = self.wid
IF Arg_Present(pix_wid) THEN wid = self.pix_wid

END; Kang_Histogram::GetProperty----------------------------------------------------


PRO Kang_Histogram::SetProperty, $
  autoupdate=autoupdate, $
  histogram=histogram, $
  bins = bins,  $
  nbins=nbins, $
  log=log, $
  plot_color=plot_color, $
  back_color=back_color, $
  low_color=low_color, $
  high_color=high_color, $
  lowScale=lowScale, $
  highScale=highScale, $
  XRange=XRange, $
  drawID=drawID, $
  wid=wid, $
  pix_wid=pix_wid

IF N_Elements(autoupdate) NE 0 THEN self.autoupdate = autoupdate
IF N_Elements(histogram) NE 0 THEN *self.histogram = histogram
IF N_Elements(bins) NE 0 THEN *self.bins = bins
IF N_Elements(nbins) NE 0 THEN BEGIN
    self.nbins = nbins
    self->calculate
ENDIF
IF N_Elements(log) NE 0 THEN self.log = log
IF N_Elements(lowScale) NE 0 THEN self.lowScale = lowScale
IF N_Elements(highScale) NE 0 THEN self.highScale = highScale
IF N_Elements(plot_color) NE 0 THEN self.plot_color = plot_color
IF N_Elements(back_color) NE 0 THEN self.back_color = back_color
IF N_Elements(low_color) NE 0 THEN self.low_color = low_color
IF N_Elements(high_color) NE 0 THEN self.high_color = high_color
IF N_Elements(XRange) NE 0 THEN self.XRange = xrange
IF N_Elements(drawID) NE 0 THEN self.drawID = drawID
IF N_Elements(wid) NE 0 THEN self.wid = wid
IF N_Elements(pix_wid) NE 0 THEN self.pix_wid = pix_wid

END; Kang_Histogram::SetProperty----------------------------------------------------


FUNCTION Kang_Histogram::WhichLine, event
; Determines which line the user clock is closest to.
; May be unnecessary

; Converts from device to data coords
self->FakeDraw
IF self.log THEN yrange = 10.^(!y.crange) ELSE yrange = !y.crange
lowscale_device = convert_coord(self.lowscale, yrange, /data, /to_device)
highscale_device = convert_coord(self.highscale, yrange, /data, /to_device)

; Determine if click is off the top or bottom
IF event.x LT lowscale_device[1] THEN whichLine = 'NONE'
IF event.x GT highscale_device[1] THEN whichLine = 'NONE'

; Determine if it's close enough - I'll be pretty lenient.
lowclose = Abs(event.x-lowscale_device[0])
highclose = Abs(event.x-highscale_device[0])

IF highclose LT lowclose THEN BEGIN
    IF highclose LT 3 THEN whichLine = 'MAX' ELSE whichLine = 'NONE'
ENDIF ELSE BEGIN
    IF lowclose LT 3 THEN whichLine = 'MIN' ELSE whichLine = 'NONE'
ENDELSE

RETURN, whichLine
END; Kang_Histogram::WhichLine------------------------------------------------------


PRO Kang_Histogram::Clip, percent
; Implements histogram clipping by the requested percentage

percentages = total(*self.histogram, /Cumulative, /Double) / Total(*self.histogram, /Double)
good = where(percentages GT (1d - percent) AND percentages LT percent)
IF good[0] EQ -1 THEN RETURN

; Store values
self.lowscale = (*self.bins)[Min(good)]
self.highscale = (*self.bins)[Max(good)]
self.clip = percent

self->FullRange
END; Kang_Histogram::Clip-----------------------------------------------------------


PRO Kang_Histogram::FullRange
; Resets XRange to entire range

rangeclip = ((*self.bins)[self.nbins-1] - (*self.bins)[0]) * 0.02
self.XRange = [(*self.bins)[0] - rangeclip, (*self.bins)[self.nbins-1] + rangeclip]
END; Kang_Histogram::FullRange------------------------------------------------------


PRO Kang_Histogram::Zoom
; Zooms to selected range

rangeclip = (self.highScale-self.lowScale)*0.01
self.XRange = [self.lowScale - rangeclip, self.highScale+rangeclip]
END; Kang_Histogram::Zoom-----------------------------------------------------------


PRO Kang_Histogram::Draw
; Plots a histogram in the pixmap window. The lines for the min and
; max are overplot in a direct graphics window, not the pixmap so the
; pixmap doesn't have to be redrawn when the lines are moved.

; Erase the display
WSet, self.pix_wid

; Draw histogram
Plot, *self.bins, *self.histogram > 1, $
      background = self.back_color, $
      charsize = 1.2, $
      Position=[0.17, 0.15, 0.97, 0.95], $
      XRange = self.XRange, $
      XStyle=1, $
      YStyle=3, $
      YLog = self.log, $
      XTitle='Image Value', $ 
      YTitle='Pixel Density', $
      YTickformat='(E8.1)'

; Draw the bars
IF self.log THEN yrange = 10.^(!Y.CRange) ELSE yrange = !Y.CRange
OPlot, [self.lowScale, self.lowScale], yrange, Color=self.low_color, Thick=3
OPlot, [self.highScale, self.highScale], yrange, Color=self.high_color, Thick=3

; Copy from the pixmap window
WSet, self.wid
Device, Copy = [0, 0, 500, 350, 0, 0, self.pix_wid]

END; Kang_Histogram::Draw-----------------------------------------------------------


PRO Kang_Histogram::FakeDraw
; Sets axis scale so convert_coord works correctly

; Plot histogram
WSet, self.pix_wid
Plot, *self.bins, *self.histogram > 1, $
      charsize = 1.2, $
      Position=[0.17, 0.15, 0.97, 0.95], $
      XRange = self.XRange, $
      XStyle=5, $
      YStyle=7, $
      YLog = self.log, $
      XTitle='Image Value', $ 
      YTitle='Pixel Density', $
      YTickformat='(E8.1)', $
      /Noerase, $
      /NoData

WSet, self.wid
END; Kang_Histogram::FakeDraw-------------------------------------------------------


PRO Kang_Histogram_Object_Events, event
; Just brings up the method since you can't do it from XManager

Widget_Control, event.id, Get_UValue = self
Call_Method, 'Events', self, event
END; Kang_Histogram_Object_Events---------------------------------------------------


PRO Kang_Histogram::Events, event
; Responds to line movement in the histogram draw window

; What type of event?
possibleEventTypes = [ 'DOWN', 'UP', 'MOTION', 'SCROLL']
thisEvent = possibleEventTypes(event.type)

; We aren't moving a line - user clicked down
IF NOT self.moving THEN BEGIN
    IF thisEvent NE 'DOWN' THEN RETURN

; Convert the device coordinates to data coordinates
    self.lineby = self->whichline(event)
    IF self.lineby EQ 'NONE' THEN RETURN

; Set moving tag, turn motion events off
    self.moving = 1B
    Widget_Control, event.id, Draw_Motion_Events=1

; Moving events
ENDIF ELSE BEGIN
    self->FakeDraw
    coord = Convert_Coord(event.x, event.y, /Device, /To_Data)
    range = (self.xrange[1] - self.xrange[0])*0.01 ; The 1% here is the minimum distance between the low and high scales.

; These are from dragging the bar
    CASE self.lineby OF
        'MIN': BEGIN
            coord[0] = coord[0] > self.xrange[0]
            coord[0] = coord[0] < (self.highScale - range)
            self.lowScale = coord[0]
        END

        'MAX': BEGIN
            coord[0] = coord[0] > (self.lowScale + range)
            coord[0] = coord[0] < self.xrange[1]
            self.highScale = coord[0]
        END
    ENDCASE

; Redraw the graphics
    self->Draw

; Send the event
    event = {KANG_HISTOGRAM_EVENTS, ID:event.id, TOP:event.top, HANDLER:event.handler,  $
             ObjRef:self, LOWSCALE:self.lowscale, HIGHSCALE:self.highscale, DRAG:1}
    Call_Procedure, self.event_pro, event

    IF thisEvent EQ 'UP' THEN BEGIN
; Turn motion events off
        self.moving = 0B
        Widget_Control, event.id, Draw_Motion_Events=0

; Send event
        event = {KANG_HISTOGRAM_EVENTS, ID:event.id, TOP:event.top, HANDLER:event.handler, $
                 ObjRef:self, LOWSCALE:self.lowscale, HIGHSCALE:self.highscale, DRAG:0}
        Call_Procedure, self.event_pro, event
    ENDIF
ENDELSE

END ; Kang_Histogram::Events ---------------------------------------------------


;PRO Kang_Histogram::Velocity, low_index, high_index
;; Changes the slice shown in the histogram

;IF low_index EQ high_index THEN *self.histogram = (*self.histogram_store)[*, low_index] ELSE $
;  *self.histogram = total((*self.histogram_store)[*, low_index:high_index], 2)

;self->Draw
;END; Kang_Histogram::Velocity---------------------------------------------------


PRO Kang_Histogram::Cleanup
; Cleans up the pointers and pixmap  windows

;WDelete, self.pix_wid
Ptr_Free, self.histogram
Ptr_Free, self.bins

END; Kang_Histogram::Cleanup----------------------------------------------------


PRO Kang_Histogram__Define

struct = {KANG_HISTOGRAM, $
          autoupdate:0B, $      ; Update when values change? 1 for Yes, 0 for no.
          back_color:0B, $      ; Background color index
          bins:Ptr_New(), $     ; X-axis bins.  For 3D arrays, this is just one "slice"
          clip:0., $            ; Percentage the data were clipped at
          drawID:0L, $          ; Widget draw window ID
          event_pro:'', $       ; propgram to send events onwards to
          high_color:0B, $      ; High scale line color
          highScale:0., $       ; High scale value
;          histogram_store:Ptr_New(), $ ; For 3D arrays, it is useful to store the complete y-axis dataset here
;          histogram:Ptr_New(), $ ; Y values.  For 3D arrays, this is just one "slice"
          histogram:Ptr_New(), $ ; Y values
          lineby:'', $          ; Which line the click was closer to
          log:0B, $             ; Whether the Y axis is logarithmic
          low_color:0B, $       ; Low scale line color 
          lowScale:0., $        ; Low scale value
          moving:0B, $          ; 1B is user is moving line, 0B otherwise
          nbins:0L, $           ; Number of histogram bins
          pix_wid:0L, $         ; Pixmap window ID
          plot_color:0B, $      ; Color to draw the histogram
          size:fltarr(2), $     ; Size of the draw window
;          tlbID:0L, $           ; Top level base for the widget
;          tlbsize:[0, 0], $     ; This may be redundant with size - I forget
          wid:0L, $             ; Window ID for the draw window
          XRange:Fltarr(2), $   ; Range of bins
          YRange:Fltarr(2)$     ; Range of pixel densities
         }

END ;Kang_Histogram__Define-----------------------------------------------------
