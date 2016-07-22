FUNCTION Kang_Window, $
  parent, $
  xsize = xsize, $
  ysize = ysize, $
  position = position, $
  event_pro = event_pro, $
  context_menu = context_menu   ; Widget ID for context menu to be brought up

; This routine is just a wrapper to return the object reference.

RETURN, Obj_New('KANG_WINDOW', $
                parent, $
                xsize = xsize, $
                ysize = ysize, $
                position = position, $
                event_pro = event_pro, $
                context_menu = context_menu)

END; Kang_Window------------------------------------------------------


FUNCTION Kang_Window::Init, $
  parent, $
  xsize = xsize, $
  ysize = ysize, $
  position = position, $
  event_pro = event_pro, $
  context_menu = context_menu, $
  drawingColor = drawingColor

; Check for input parameters
IF N_Elements(xsize) EQ 0 THEN xsize = 600
IF N_Elements(ysize) EQ 0 THEN ysize = 300
IF N_Elements(position) NE 0 THEN self.position = position
IF N_Elements(event_pro) NE 0 THEN self.event_pro = event_pro
self.size = [xsize, ysize]
IF N_Elements(drawingColor) NE 0 THEN self.drawingColor = drawingColor

; Create widget
Window, /Free, /Pixmap, xsize = self.size[0], ysize = self.size[0]
self.pix_WID = !D.Window
self.tlbID = Widget_Base(parent, Column=1, Event_Pro = 'Kang_Window_Events', /KBRD_Focus_Events, UValue = self)
self.drawID = Widget_Draw(self.tlbID, XSize=self.size[0], YSize=self.size[1], /Motion_Events, $
                          /Button_Events, Event_Pro = 'Kang_Window_Events', UValue = self, retain=2, /Wheel_Events)

RETURN, 1
END;Kang_Window::Init-------------------------------------------------


PRO Kang_Window::Realize
; Needs to be called when the window is realized

Widget_Control, self.drawID, Get_Value = WID
self.WID = WID
Widget_Control, self.tlbID, TLB_Get_Size=tlbsize
self.tlbsize = tlbsize

END; Kang_Window::Realize---------------------------------------------


PRO Kang_Window::GetProperty, $
  wid=wid, $
  XRange = xrange, $
  YRange = yrange, $
  Context_Menu = context_menu

IF Arg_Present(wid) THEN wid = self.wid
IF Arg_Present(xrange) THEN xrange = self.xrange
IF Arg_Present(yrange) THEN yrange = self.yrange
IF Arg_Present(context_menu) THEN context_menu = self.context_menu

END;Kang_Window::GetProperty------------------------------------------


PRO Kang_Window::SetProperty, $
  pix_cursor = pix_cursor, $
  position = position, $
  size = size, $
  context_menu = context_menu

IF N_Elements(context_menu) NE 0 THEN self.context_menu = context_menu
IF N_Elements(pix_cursor) NE 0 THEN self.pix_cursor = pix_cursor
IF N_Elements(position) NE 0 THEN self.position = position
IF N_Elements(size) NE 0 THEN BEGIN
    Widget_Control, self.drawid, XSize=size[0], YSize=size[1]
    self.size = size

; Delete then remake pixmap window
    WDelete, self.pix_WID
    Window, /Free, /Pixmap, xsize = self.size[0], ysize = self.size[0]
    self.pix_WID = !D.Window
    WSet, self.WID
ENDIF

END;Kang_Window::SetProperty------------------------------------------


PRO Kang_Window::Update
; Called when the plot has changed.

self.xrange = !x.crange
self.yrange = !y.crange
self.position[0] = !x.window[0]
self.position[2] = !x.window[1]
self.position[1] = !y.window[0]
self.position[3] = !y.window[1]

END;Kang_Window::Update-----------------------------------------------


PRO Kang_Window::Zoom, event, factor
; Zoom in about the position specified by event.x and event.y by the
; factor

; Find the current center of the plot
wset, self.wid
plot, [0], xrange = self.xrange, yrange = self.yrange, position = self.position, $
      XStyle=5, YStyle=5, /NoErase, /NoData
coords = convert_coord(event.x, event.y, /device, /to_data)
xcenter = coords[0]
ycenter = coords[1]
factor = Float(factor)

; The new values are defined in relation to this center
xrange = Abs(self.xrange[1] - self.xrange[0])
self.xrange[0] = xcenter - xrange/(2*factor)
self.xrange[1] = xcenter + xrange/(2*factor)

yrange = Abs(self.yrange[1] - self.yrange[0])
self.yrange[0] = ycenter - yrange/(2*factor)
self.yrange[1] = ycenter + yrange/(2*factor)

; Send event onwards
event = {KANG_WINDOW_EVENTS, ID:event.id, TOP:event.top, $
         HANDLER:event.handler, XRange:self.xrange, YRange:self.YRange}
Call_Procedure, self.event_pro, event

; Recenter the cursor
TVCRS, xcenter, ycenter, /Data

END;Kang_Window_Zoom--------------------------------------------------


PRO Kang_Window_Events, event
; Just brings up the method since you can't do it from XManager

Widget_Control, event.id, Get_UValue = self
Call_Method, 'Events', self, event

END; Kang_Window_Events-----------------------------------------------


PRO Kang_Window::Events, event
; This handles all the events in the widget.  Mouse roll upwards and
; downwards will zoom in or out. user may also recenter the plot, or
; zoom in by drawing a box.
; This procedure is the real reason for this object to exist.

; Branch on the event type
thisEvent = Tag_Names(event, /Structure_Name)
CASE thisEvent OF
    'WIDGET_DRAW': BEGIN
        self.pix_cursor = [event.x, event.y]

; Further branching on the event type
        eventTypes = ['DOWN', 'UP', 'MOTION', 'SCROLL', 'EXPOSE', 'KEY', 'KEY2', 'WHEEL']

        thisEvent = eventTypes[event.type] 
        CASE thisEvent OF
            'DOWN': BEGIN
                CASE event.press OF
                    1:
                    2: BEGIN
; User started drawing a box to zoom in with
                        self.initial = [event.x, event.y]
                        self.drawing = 1B
                        WSet, self.pix_WID
                        Device, Copy=[0,0,!D.X_Size, !D.Y_Size, 0, 0, self.WID]
; Make sure window coordinates are corrent
                        wset, self.wid
                        plot, [0], xrange = self.xrange, yrange = self.yrange, position = self.position, $
                              XStyle=5, YStyle=5, /NoErase, /Nodata
                    END
                    4:
                    8: self->Zoom, event, 2 ; Mouse wheel upwards
                    16:
                    ELSE:
                ENDCASE
            END
            
            'UP': BEGIN
                CASE event.release OF
                    1:
                    2: BEGIN
; User finished drawing a box
                        self.final = [event.x, event.y]
                        self.drawing = 0B
                        distance = ((self.initial[0] - self.final[0])^2. + (self.initial[1] - self.final[1])^2.)^0.5

; Just a click up and down - no drawing
                        IF distance LT 1.5 THEN self->Zoom, event, 1 ELSE BEGIN
; User has drawn a box we need to zoom in to. Convert and store coordinates.
                            plot, [0], xrange = self.xrange, yrange = self.yrange, position = self.position, $
                                  XStyle=5, YStyle=5, /NoErase, /NoData
                            coords = convert_coord([self.initial[0], self.pix_cursor[0]], [self.initial[1], self.pix_cursor[1]], $
                                                   /device, /to_data)
                            self.xrange = (coords[0, *])[sort(coords[0, *])]
                            self.yrange = (coords[1, *])[sort(coords[1, *])]

; Send event onwards so the display may be updated
                            event = {KANG_WINDOW_EVENTS, ID:event.id, TOP:event.top, $
                                     HANDLER:event.handler, XRange:self.xrange, YRange:self.YRange}
                            Call_Procedure, self.event_pro, event
                        ENDELSE
                    END
                    4: IF self.context_menu NE 0 THEN Widget_DisplayContextMenu, event.ID, event.X, event.Y, self.context_menu
                    16: self->Zoom, event, 0.5 ; Mouse wheel downwards
                    ELSE:
                ENDCASE
            END
            
            'MOTION': BEGIN
; Drawing a box
                IF self.drawing THEN BEGIN
                    Device, Copy=[0,0,!D.X_Size, !D.Y_Size, 0, 0, self.pix_WID]

; Draw the box
                    plots, [self.initial[0], self.initial[0], self.pix_cursor[0], self.pix_cursor[0], self.initial[0]], $
                           [self.initial[1], self.pix_cursor[1], self.pix_cursor[1], self.initial[1], self.initial[1]], $
                           color = self.drawingColor, /device
                ENDIF
            END

; IDL seems to have changed the behavior here - now 7 is the middle button
; event.clicks = 1 is upwards scroll, event.clicks = -1 is downwards
            'WHEEL': BEGIN
                IF event.clicks EQ 1 THEN self->Zoom, event, 2 ELSE self->Zoom, event, 0.5
            END
        ENDCASE
    END

   'WIDGET_BASE': BEGIN
; Resize the draw widget.
       self.size = [event.x, event.y]
       Widget_Control, self.drawid, XSize=self.size[0], YSize=self.size[1]

; Destroy old pixmap window, create new one
       WDelete, self.pix_WID
       Window, /Free, /Pixmap, xsize = self.size[0], ysize = self.size[0]
       self.pix_WID = !D.Window

; Replot
       WSet, self.wid
       event = {KANG_WINDOW_EVENTS, ID:event.id, TOP:event.top, $
                HANDLER:event.handler, XRange:self.xrange, YRange:self.YRange}
       Call_Procedure, self.event_pro, event
   END

   'WIDGET_KBRD_FOCUS': BEGIN
; Nothing for this yet

   END
   ELSE:
ENDCASE

END ;Kang_Window::Events----------------------------------------------


PRO Kang_Window::Save, filename = filename, keywords
; Save the current display as an image.

filename = FSC_Base_Filename(outfile, Extension=extension)
CASE StrUpCase(file_extension) OF
    'BMP'  : image = TVREAD(Filename = filename, /BMP)
    'GIF'  : image = TVREAD(Filename = filename, /GIF)
    'PICT' : image = TVREAD(Filename = filename, /PICT)
    'JPG'  : image = TVREAD(Filename = filename, /JPEG)
    'JPEG' : image = TVREAD(Filename = filename, /JPEG)
    'TIF'  : image = TVREAD(Filename = filename, /TIFF)
    'TIFF' : image = TVREAD(Filename = filename, /TIFF)
    'PNG'  : image = TVREAD(Filename = filename, /PNG)
    'PS': BEGIN
        thisDevice = !D.Name
        Set_Plot, 'PS'
        Device, _Extra = keywords
        Call_Procedure, self.event_pro, xrange = self.xrange, yrange = self.yrange
        Device, /Close_File
        Set_Plot, thisDevice
    END
ENDCASE

END; Kang_Window::Save------------------------------------------------


PRO Kang_Window_Cleanup, event
; Don't know what to do here

END; Kang_Window_Cleanup----------------------------------------------


PRO Kang_Window::Cleanup
; Removes the pixmap window from memory

WDelete, self.pix_WID
END; Kang_Window::Cleanup---------------------------------------------


PRO Kang_Window__Define

struct = { KANG_WINDOW, $
           tlbID:0L, $          ; Top level base ID
           size:fltarr(2), $    ; Size of the draw window
           tlbsize:fltarr(2), $ ; Size of the top level base
           drawID:0, $          ; Widget ID of the draw window
           drawingColor:0B, $   ; Color for box drawing
           xrange:fltarr(2), $  ; Plot X range
           yrange:fltarr(2), $  ; Plot Y range
           position:[0., 0., 0., 0.], $ ; Position in the window
           pix_cursor:fltarr(2), $ ; Location of the cursor in pixel coordinates
           data_cursor:fltarr(2), $ ; Location of the cursor in data coordinates
           event_pro:'', $      ; Procedure to be called when an event is generated
           event_func:'', $     ; Function to be called when an event in generated
           initial:[0.,0.], $   ; Initial corner when box is being drawn
           final:[0.,0.],  $    ; Final corner when box is being drawn
           drawing:0B, $        ; Flag is 1B when user us currently drawing a box
           WID:-1, $            ; Window ID
           pix_WID:-1, $         ; Pixmap window ID
           context_menu:0L $    ; WidgetID for context menu
         }

END; Kang_Window__Define----------------------------------------------
