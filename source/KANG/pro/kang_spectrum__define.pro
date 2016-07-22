FUNCTION Kang_Spectrum::Init, $
  x, $
  y, $
  AxisColor = axiscolor, $
  AxisCName = axisCName, $
  BackColor = backColor, $
  BackCName = backCName, $
  Charsize=charsize, $
  Charthick=charthick, $
  Color = color, $
  CName = cname, $
  Draw_Model = draw_model, $
  Draw_Resid = draw_resid, $
  Font = font, $
  Freeze_x = freeze_x, $
  Freeze_y = freeze_y, $
  Linestyle=linestyle, $
  Minor=minor, $
  Overplot=overplot, $
  Subtitle=subtitle, $
  Ticklen=ticklen, $
  Ticks=ticks, $
  Title=title, $
  width=width, $
  XErr = xerr, $
  XRange=xrange, $
  Xtitle=xtitle, $
  yErr = Yerr, $
  Ytitle=ytitle, $
  yrange=yrange, $
  zline=zline

; The initialization routine for the object. Create the
; particular instance of the object class.

; Error handling.
Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message(!Error_State.Msg + ' Returning...', $
      Traceback=1, /Error)
   RETURN, 0
ENDIF

; Fill up first x and y
n_x = N_Elements(x)
IF n_x EQ 0 THEN RETURN, 0
n_y = N_Elements(y)

; No x values, need to create them
IF n_y EQ 0 THEN BEGIN
    y = x
    x = findgen(N_Elements(y))
ENDIF
self.x = Ptr_New(x)
self.y = Ptr_New(y)

; Errors
IF N_Elements(xerr) EQ 1 THEN self.xerr = Ptr_New(*self.x * (xerr/100.)) ; As a percent
IF N_Elements(xerr) EQ N_Elements(x) THEN self.xerr = Ptr_New(xerr)
IF N_Elements(yerr) EQ 1 THEN self.yerr = Ptr_New(*self.y * (yerr/100.)) ; As a percent
IF N_Elements(yerr) EQ N_Elements(y) THEN self.yerr = Ptr_New(yerr)

; Set default axes
self->Reset_Axes

; Other parameters
IF N_Elements(axisColor) NE 0 THEN self.axisColor=axisColor ELSE self.axisColor = 0B
IF N_Elements(axisCName) NE 0 THEN self.axisCName=axisCName ELSE self.axisCName = 'Black'
IF N_Elements(backColor) NE 0 THEN self.backColor=backColor ELSE self.backcolor = 255B
IF N_Elements(backCName) NE 0 THEN self.backCName=backCName ELSE self.backCName = 'White'
IF N_Elements(charsize) NE 0 THEN self.charsize = charsize ELSE charsize = 1.2
IF N_Elements(charthick) NE 0 THEN self.charthick = charthick ELSE charthick = 1
IF N_Elements(Color) NE 0 THEN self.Color=Color ELSE self.color = 0B
IF N_Elements(CName) NE 0 THEN self.CName=CName ELSE self.CName = 'Black'
IF N_Elements(draw_model) NE 0 THEN self.draw_model = 0 > draw_model < 1 ELSE self.draw_model = 1B
IF N_Elements(draw_resid) NE 0 THEN self.draw_resid = 0 > draw_resid < 1 ELSE self.draw_resid = 1B
IF N_Elements(font) NE 0 THEN self.font = font ELSE self.font = -1
IF N_Elements(freeze_x) NE 0 THEN self.freeze_x = 0 > freeze_x < 1
IF N_Elements(freeze_y) NE 0 THEN self.freeze_y = 0 > freeze_y < 1 ELSE self.freeze_y = 1
IF N_Elements(linestyle) NE 0 THEN self.linestyle = linestyle ELSE self.linestyle = 0
IF N_Elements(minor) NE 0 THEN self.minor = minor ELSE self.minor = 2
IF N_Elements(overplot) NE 0 THEN self.overplot = 0B > overplot < 1B
IF N_Elements(subtitle) NE 0 THEN self.subtitle = subtitle 
IF N_Elements(ticklen) NE 0 THEN self.ticklen = ticklen ELSE self.ticklen = 0.02
IF N_Elements(title) NE 0 THEN self.title = title 
IF N_Elements(width) NE 0 THEN self.width = width 
IF N_Elements(xrange) NE 0 THEN self.xrange = xrange 
IF N_Elements(xtitle) NE 0 THEN self.xtitle = xtitle 
IF N_Elements(ticks) NE 0 THEN BEGIN
    self.xticks = ticks 
    self.yticks = ticks
ENDIF
IF N_Elements(yrange) NE 0 THEN self.yrange = yrange 
IF N_Elements(ytitle) NE 0 THEN self.ytitle = ytitle 
IF N_Elements(zline) NE 0 THEN self.zline = 0 > zline < 1 ELSE zline = 1B

RETURN, 1
END ;Kang_Spectrum::Init---------------------------------------------------


PRO Kang_Spectrum::Reset_Axes
; Sets axes to default spans

cdelt_x = (*self.x)[1]-(*self.x)[0]
self.xrange = [min(*self.x)-cdelt_x/2., max(*self.x)+cdelt_x/2.]
maxy = max(*self.y, min = miny)
margin = (maxy-miny)*0.1
self.yrange = [miny-margin, maxy+margin]

END; Kang_Spectrum::Reset_Axes---------------------------------------------


PRO Kang_Spectrum::Draw, overplot=overplot
; Plots the spectra in the current window

IF Keyword_Set(overplot) THEN BEGIN
    oplot, $
      *self.x, $
      *self.y, $
      Color = self.color, $
      Linestyle = self.linestyle, $
      thick=self.width, $
      psym = 10
ENDIF ELSE BEGIN
; The axis
    plot, $
      [0], $
      Background = self.backColor, $
      Charsize=self.charsize, $
      Charthick=self.charthick, $
      Color = self.axiscolor, $
      Font = self.font, $
      Subtitle=self.subtitle, $
      Ticklen=self.ticklen, $
      Title=self.title, $
      XMinor=self.minor, $
      XRange=self.xrange, $
      XTicks=self.ticks, $
      Xtitle=self.xtitle, $
      YTicks=self.ticks, $
      Ytitle=self.ytitle, $
      YMinor=self.minor, $
      yrange = self.yrange, $
      Xstyle = 1, $
      Ystyle = 3, $
      /nodata

; The plot
; Find indices that will fit in the plot range
    foo = min(abs(*self.x - self.xrange[0]), lowindex)
    foo = min(abs(*self.x - self.xrange[1]), highindex)

    plot, $
      (*self.x)[lowindex:highindex], $
      (*self.y)[lowindex:highindex], $
      xstyle=5, $
      ystyle=7, $
      xrange = self.xrange, $
      yrange = self.yrange, $
      Color = self.color, $
      linestyle = self.linestyle, $
      thick = self.width, $
      psym = 10, $
      position = [!x.window[0], !y.window[0], !x.window[1], !y.window[1]], $
      /noerase
ENDELSE

; Overplot Gaussians (model)
IF Ptr_Valid(self.models) THEN n_model = N_Elements((*self.models)[*, 0]) ELSE n_model = 0
IF n_model GT 0 THEN BEGIN
    IF self.draw_model THEN BEGIN

; Draw individual gaussians
        FOR i = 0, n_model-1 DO BEGIN
            oplot, *self.x, (*self.models)[i, *], color=25
        ENDFOR

; Draw larger gaussian
        oplot, *self.x, total(*self.models, 1), color=25
    ENDIF

; Draw residuals
    IF self.draw_resid THEN oplot, *self.x, *self.y - total(*self.models, 1), color=245, psym=10
ENDIF

END ;Kang_Spectrum::Draw---------------------------------------------------


PRO Kang_Spectrum::GetProperty, $
  xvals=xvals, $
  yvals=yvals, $
  AxisColor = axiscolor, $
  AxisCName = axisCName, $
  BackColor = backColor, $
  BackCName = backcname, $
  Charsize=charsize, $
  Charthick=charthick, $
  CName=cname, $
  Color=color, $
  Font = font, $
  Freeze_x = freeze_x, $
  Freeze_y = freeze_y, $
  Linestyle = linestyle, $
  Minor=minor, $
  Subtitle=subtitle, $
  Ticklen=ticklen, $
  Ticks=ticks, $
  Title=title, $
  width=width, $
  XRange=xrange, $
  Xtitle=xtitle, $
  Ytitle=ytitle, $
  yrange=yrange

IF Arg_Present(xvals) THEN xvals = *self.x
IF Arg_Present(yvals) THEN yvals = *self.y

IF Arg_Present(axiscolor) NE 0 THEN axiscolor = self.axiscolor
IF Arg_Present(axisCName) NE 0 THEN axisCName = self.AxisCName
IF Arg_Present(backcolor) NE 0 THEN backcolor = self.backcolor
IF Arg_Present(backCName) NE 0 THEN backCName = self.BackCName
IF Arg_Present(charsize) NE 0 THEN charsize = self.charsize 
IF Arg_Present(charthick) NE 0 THEN charthick = self.charthick
IF Arg_Present(color) NE 0 THEN color = self.color 
IF Arg_Present(cName) NE 0 THEN cName = self.CName
IF Arg_Present(font) NE 0 THEN font = self.font 
IF Arg_Present(freeze_x) NE 0 THEN freeze_x = self.freeze_x
IF Arg_Present(freeze_y) NE 0 THEN freeze_y = self.freeze_y
IF Arg_Present(linestyle) NE 0 THEN linestyle = self.linestyle
IF Arg_Present(minor) NE 0 THEN minor = self.minor
IF Arg_Present(subtitle) NE 0 THEN subtitle = self.subtitle 
IF Arg_Present(ticklen) NE 0 THEN ticklen = self.ticklen
IF Arg_Present(title) NE 0 THEN title = self.title 
IF Arg_Present(width) NE 0 THEN width = self.width
IF Arg_Present(xrange) NE 0 THEN xrange = self.xrange 
IF Arg_Present(xtitle) NE 0 THEN xtitle = self.xtitle 
IF Arg_Present(ticks) NE 0 THEN ticks = self.self.ticks
IF Arg_Present(yrange) NE 0 THEN yrange = self.yrange 
IF Arg_Present(ytitle) NE 0 THEN ytitle = self.ytitle 

END; Kang_Spectrum::GetProperty--------------------------------------------


PRO Kang_Spectrum::SetProperty, $
  xvals = xvals, $
  yvals = yvals, $
  AxisColor = axiscolor, $
  AxisCName = axisCName, $
  BackColor = backColor, $
  BackCName = backcname, $
  Charsize=charsize, $
  Charthick=charthick, $
  CName=cname, $
  Color=color, $
  Font = font, $
  Freeze_x = freeze_x, $
  Freeze_y = freeze_y, $
  Linestyle = linestyle, $
  Minor=minor, $
  Subtitle=subtitle, $
  Ticklen=ticklen, $
  Ticks=ticks, $
  Title=title, $
  Width=width, $
  XRange=xrange, $
  Xtitle=xtitle, $
  Ytitle=ytitle, $
  yrange=yrange

n_x = N_Elements(xvals)
n_y = N_Elements(yvals)
IF (n_x NE 0) AND (n_y NE 0) AND (n_x EQ n_y) THEN BEGIN
; Must update both at once for now
    *self.x = xvals
    *self.y = yvals
    cdelt_x = xvals[1]-xvals[0]
    self.xrange = [min(xvals)-cdelt_x/2., max(xvals)+cdelt_x/2.]
    maxy = max(yvals, min = miny)
    margin = (maxy-miny)*0.1
    self.yrange = [miny-margin, maxy+margin]
ENDIF

IF N_Elements(axiscolor) NE 0 THEN self.axiscolor = axiscolor
IF N_Elements(axisCName) NE 0 THEN self.axisCName = AxisCName
IF N_Elements(backcolor) NE 0 THEN self.backcolor = backcolor
IF N_Elements(backCName) NE 0 THEN self.backCName = BackCName
IF N_Elements(charsize) NE 0 THEN self.charsize = charsize 
IF N_Elements(charthick) NE 0 THEN self.charthick = charthick
IF N_Elements(color) NE 0 THEN self.color = color 
IF N_Elements(cName) NE 0 THEN self.cName = CName
IF N_Elements(font) NE 0 THEN self.font = font 
IF N_Elements(freeze_x) NE 0 THEN self.freeze_x = freeze_x
IF N_Elements(freeze_y) NE 0 THEN self.freeze_y = freeze_y
IF N_Elements(linestyle) NE 0 THEN self.linestyle = 0 > linestyle < 5
IF N_Elements(minor) NE 0 THEN self.minor = minor ELSE self.minor = 2
IF N_Elements(subtitle) NE 0 THEN self.subtitle = subtitle 
IF N_Elements(ticklen) NE 0 THEN self.ticklen = ticklen ELSE self.ticklen = 0.02
IF N_Elements(title) NE 0 THEN self.title = title 
IF N_Elements(width) NE 0 THEN self.width = 0 > width < 10 
IF N_Elements(xrange) NE 0 AND ~self.freeze_x THEN self.xrange = xrange
IF N_Elements(xtitle) NE 0 THEN self.xtitle = xtitle 
IF N_Elements(ticks) NE 0 THEN BEGIN
    self.xticks = ticks 
    self.yticks = ticks
ENDIF
IF N_Elements(yrange) NE 0 AND ~self.freeze_y THEN self.yrange = yrange 
IF N_Elements(ytitle) NE 0 THEN self.ytitle = ytitle 

END ;Kang_Spectrum::SetProperty--------------------------------------------


PRO Kang_Spectrum::Gauss, n_gauss, xrange = xrange
; Fits gaussian to spectrum

!except=0                       ; turn off underflow messages (and, alas, *all* math errors)

a=fltarr(n_gauss*3)
sigmaa=fltarr(n_gauss*3)
Ptr_Free, self.models

self->Draw
print,"Click: bgauss #_gauss(center,hw_right) egauss"
;rdplot, x, y, /data, /down, /full, color = 240
cursor, x, y, 3
print, x, y
foo = min(abs(x - (*self.x)), xchan)
bgauss=(*self.x)[xchan]

FOR i = 0, n_gauss-1 DO BEGIN
;    rdplot, x, y, /data, /down, /full, color = 240
    cursor, x, y, 3
    print, x, y
    foo = min(abs(x - (*self.x)), xchan)

    c=(*self.x)[xchan]          ; flag center position
    h=(*self.y)[xchan]          ; peak y_value is at center = c

;    rdplot, x, y, /data, /down, /full, color = 240
    cursor, x, y, 3
    print, x, y
    foo = min(abs(x - (*self.x)), hw)
    w=abs(2*((*self.x)[hw] - c))

    a[i*3+0]=h
    a[i*3+1]=c
    a[i*3+2]=w
ENDFOR

;rdplot, x, y, /data, /down, /full, color = 240
cursor, x, y, 3
print, x, y
foo = min(abs(x - (*self.x)), xchan)
egauss=(*self.x)[xchan]

;  restrict range to bgauss-egauss
IF (bgauss GT egauss) THEN BEGIN
    hold = bgauss
    bgauss = egauss
    egauss = hold
ENDIF
foo = where(*self.x LT bgauss, bpix)
foo = where(*self.x LT egauss, epix)

weightf=fltarr(epix-bpix+1)+1.0 ; weight 1.0 in mask region

yfit = mpcurvefit((*self.x)[bpix:epix], (*self.y)[bpix:epix],$
                  weightf, a, sigmaa, function_name='mgauss',$
                  chisq=chisq, itmax=500, /quiet)

dof = N_Elements((*self.x)[bpix:epix]) - N_Elements(a) ; deg of freedom
csigma = FltArr(n_gauss*3)
csigma=sigmaa * (chisq / dof)^0.5 ; scaled uncertainties
sigmaa=csigma

chanwidth = (*self.x)[1] - (*self.x)[0]
nchan = N_Elements(*self.x)
yfit = FltArr(nchan)
;IF Ptr_Valid(self.models) THEN *self.models = FltArr(n_gauss,;nchan) ELSE $
self.models = Ptr_New(FltArr(n_gauss, nchan))

print
print,"G#      Height +/- sigma     Center +/- sigma       FWHM +/- sigma"+ $
      "   ==>     kHz        km/sec"

FOR i = 0, n_gauss-1 DO BEGIN
    h=a[i*3+0]                  ; in current y-axis units
    c=a[i*3+1]                  ; in current x-axis units
    w=a[i*3+2]                  ; in current x-axis units
    vw=w*chanwidth              ; width in km/s
    sh=sigmaa[i*3+0]
    sc=sigmaa[i*3+1]
    sw=sigmaa[i*3+2]

; Find and store individual gaussian components
    ycomp=h*exp(-4.0*alog(2)*(*self.x - c)^2/w^2)
    (*self.models)[i, *] = ycomp
    yfit=yfit+ycomp
    print, i, h, sh, c, sc, w, sw, 0, vw, format='(i1,1x,4(f11.3,1x,f11.3))'
ENDFOR

self->draw, /overplot
!except=1                       ; return math error flag to default

END ; Kang_Spectrum::Gauss--------------------------------------------------


PRO Kang_Spectrum::Cleanup
; Free the data pointers

Ptr_Free, self.x
Ptr_Free, self.y

END ;Kang_Spectrum::Cleanup------------------------------------------------


PRO Kang_Spectrum__Define

struct = {KANG_SPECTRUM, $
          x:Ptr_New(), $        ; X data values. Must be pointer since we don't know how large it is a priori
          y:Ptr_New(), $        ; Y data values
          xerr:Ptr_New(), $     ; X errors
          yerr:Ptr_New(), $     ; Y errors
          models:Ptr_New(),$    ; An pointer to an array of gaussians of indeterminite length
          axisCName:'', $       ; The name of the axis color.
          axisColor:0B, $       ; Axis color index
          backCName:'', $       ; The name of the background color.
          backColor:0B, $       ; Background color index
          charsize:0., $        ; Character size for all text
          charthick:0., $       ; Character thickness for all text
          cname:'', $           ; Plot color name
          color:0B, $           ; Plot color index
          draw_model:0B, $      ; Boolean for whether to draw gaussians
          draw_resid:0B, $      ; Boolean for whether to draw residuals
          font:0, $             ; Font index
          freeze_x:0B, $        ; Whether we should freeze the x range when zooming
          freeze_y:0B, $        ; Ditto for the y range
          linestyle:0, $        ; Plot linestyle
          minor:0., $           ; Minor ticks
          overplot:0B, $        ; Whether this spectrum should be overplotted
          reverse_x:0B, $       ; Whether we should reverse the x axis
          reverse_y:0B, $       ; Ditto for y axis
          subtitle:'', $        ; Subtitle string
          tickCName:'', $       ; Tick color name
          tickColor:0B, $       ; Tick color index
          ticklen:0., $         ; Tick length - 1 is a grid
          ticks:0., $           ; Tick spacing
          title:'', $           ; Title string
          width:0, $            ; Line width
          xrange:fltarr(2), $   ; X range encompassed by plot
          xtitle:'', $          ; X title string
          yrange:fltarr(2), $   ; Y  range encompassed by plot
          ytitle:'', $          ; Y title string
          zline:0B $            ; Boolean for whether to draw zline
         }

END ;Kang_Spectrum__Define-------------------------------------------------
