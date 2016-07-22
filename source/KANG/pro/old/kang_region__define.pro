FUNCTION Kang_Region::Init, $
  x, $
  y, $
  angle = angle, $
  background = background, $
  cname = cname, $
  charsize = charsize, $
  charthick = charthick, $
  coords = coords, $
  font = font, $
  image_obj = image_obj, $
  nostats = nostats, $
  params = params, $
  polygon = polygon, $
  regiontype = regiontype, $
  source = source, $
  text = text, $
  weighting = weighting, $
  _Extra = extra
; The initialization method for the object.  The data for the region
; are in the x and y vectors.  params is what is displayed in the
; region text widget.

; Set other passed parameters
IF N_Elements(angle) NE 0 THEN self.angle = 0 > angle < 360
IF N_Elements(background) NE 0 THEN self.source = ~background ELSE self.source = 1B
IF N_Elements(cname) NE 0 THEN self.cname = cname ELSE self.cname = 'Green'
IF N_Elements(charsize) NE 0 THEN self.charsize = charsize ELSE self.charsize = 1
IF N_Elements(charthick) NE 0 THEN self.charthick = charthick ELSE self.charthick = 1
IF N_Elements(coords) NE 0 THEN self.coords = coords ELSE self.coords = 'Image'
IF N_Elements(font) NE 0 THEN self.font = font
IF N_Elements(linestyle) NE 0 THEN self.linestyle = linestyle
IF Keyword_Set(nostats) THEN self.nostats = 1
IF N_Elements(regionType) NE 0 THEN self.regionType = regionType
IF N_Elements(params) NE 0 THEN self.params = Ptr_New(reform(reform(params, 1, N_Elements(params))))
IF N_Elements(polygon) NE 0 THEN self.polygon = 0B > polygon  < 1B ELSE self.polygon = 1B ; Defaults to closed polygons
IF N_Elements(source) NE 0 THEN self.source = source ELSE self.source = 1B
IF N_Elements(text) NE 0 THEN self.text = text
IF N_Elements(weighting) NE 0 THEN self.weighting = 0B > weighting < 1B ELSE self.weighting = 0B ; Defaults to using weights

; Change x values > 360
;IF self.coords NE 'Image' THEN BEGIN
;    minx = min(x, max = maxx)
;    IF minx GT 0
;ENDIF

; Create region object from passed data
IF N_Elements(y) NE 0 THEN ok = self->IDLGRROI::Init(x, y, Strict_Extra=extra) ELSE $
  ok = self->IDLGRROI::Init(x, _Strict_Extra=extra)

; Create text
self->CreateText

; Find stats
self->ComputeGeometry, image_obj

RETURN, 1 < ok
END; Kang_Region::Init--------------------------------------------------


PRO Kang_Region::Cleanup
; Free the pointers

Ptr_Free, self.params
self->IDLGRROI::Cleanup
END; Kang_Region::Cleanup--------------------------------------------------


PRO Kang_Region::SetProperty, $
  background = background, $
  cname = cname, $
  charsize = charsize, $
  charthick = charthick, $
  coords = coords, $
  data = data, $
  font = font, $
  image_obj = image_obj, $
  name = name, $
  polygon = polygon, $
  params = params, $
  source = source, $
  text = text, $
  _Extra = extra
; Sets the various parameters for the  region.

self->IDLGRROI::SetProperty, _Strict_Extra = extra
IF N_Elements(background) NE 0 THEN self.source = 0B > (~background) < 1B
IF N_Elements(cname) NE 0 THEN self.cname = cname
IF N_Elements(charsize) NE 0 THEN self.charsize = charsize
IF N_Elements(charthick) NE 0 THEN self.charthick = charthick
IF N_Elements(coords) NE 0 THEN self.coords = coords
IF N_Elements(data) NE 0 THEN BEGIN
    self->IDLGRROI::SetProperty, data = data
    self->ComputeGeometry, image_obj
ENDIF
IF N_Elements(font) NE 0 THEN self.font = font
IF N_Elements(name) NE 0 THEN self.regionName = name

;IF N_Elements(polygon) NE 0 THEN BEGIN
;    self.polygon = 0B > polygon < 1B
;    self->ComputeGeometry, image_obj
;ENDIF
IF N_Elements(params) NE 0 THEN self.params = Ptr_New(reform(reform(params, 1, N_Elements(params))))
IF N_Elements(source) NE 0 THEN self.source = 0B > source < 1B
IF N_Elements(text) NE 0 THEN self.text = text

;Update the text
self->CreateText
END; Kang_Region::SetProperty--------------------------------------------------


PRO Kang_Region::GetProperty, $
  angle = angle, $
  background = background, $
  charsize = charsize, $
  charthick = charthick, $
  cname = cname, $
  coords = coords, $
  composite = composite, $
  font = font, $
  name = name, $
  params = params, $
  polygon = polygon, $
  regiontext=regiontext, $
  regiontype=regiontype, $
  source = source, $
  stats = stats, $
  text = text, $
  xrange = xrange, $
  yrange = yrange, $
  _Ref_Extra = extra
; Gets the various region properties out of the object.

self->IDLGRROI::GetProperty, _Strict_Extra = extra
IF Arg_Present(angle) THEN angle = self.angle
IF Arg_Present(background) THEN background = ~self.source
IF Arg_Present(charsize) THEN charsize = self.charsize
IF Arg_Present(charthick) THEN charthick = self.charthick
IF Arg_Present(cname) THEN cname = self.cname
IF Arg_Present(coords) THEN coords = self.coords
IF Arg_Present(composite) THEN composite = 0
IF Arg_Present(font) THEN font = self.font
IF Arg_Present(name) THEN name = self.regionName
IF Arg_Present(stats) THEN BEGIN
    stats = {area:self.area, $
             centroid:self.centroid, $
             perimeter:self.perimeter, $
             npix:self.npix, $
             max:self.max, $
             min:self.min, $
             mean:self.mean, $
;             median:self.median, $
             stddev:self.stddev, $
             total:self.total}
ENDIF
IF Arg_Present(params) THEN params = *self.params
IF Arg_Present(regiontext) THEN regiontext = self.regiontext
IF Arg_Present(source) THEN source = self.source
IF Arg_Present(text) THEN text = self.text
IF Arg_Present(polygon) THEN polygon = self.polygon
IF Arg_Present(regiontype) THEN regiontype = self.regiontype
IF Arg_Present(xrange) THEN xrange = self.xrange
IF Arg_Present(yrange) THEN yrange = self.yrange

END; Kang_Region::GetProperty--------------------------------------------------


FUNCTION Kang_Region::GetProperty, $
  angle = angle, $
  background = background, $
  charsize = charsize, $
  charthick = charthick, $
  cname = cname, $
  composite = composite, $
  coords = coords, $
  font = font, $
  interior = interior, $
  linestyle = linestyle, $
  name = name, $
  params = params, $
  regiontext=regiontext, $
  regiontype=regiontype, $
  polygon= polygon, $
  source=source, $
  stats = stats, $
  text = text, $
  thick = thick, $
  xrange = xrange, $
  yrange = yrange, $
  _Ref_Extra = extra
;; Gets the various region properties out of the object - this time as
;;                                                        a function.

self->IDLGRROI::GetProperty, _Strict_Extra = extra

IF Keyword_Set(angle) THEN RETURN, self.angle
IF Keyword_Set(background) THEN RETURN, ~self.source
IF Keyword_Set(charsize) THEN RETURN,  self.charsize
IF Keyword_Set(charthick) THEN RETURN, self.charthick
IF Keyword_Set(cname) THEN RETURN, self.cname
IF Keyword_Set(composite) THEN RETURN, 0
IF Keyword_Set(coords) THEN RETURN, self.coords
IF Keyword_Set(font) THEN RETURN, self.font
IF Keyword_Set(interior) THEN BEGIN
    self->IDLGRROI::GetProperty, interior = interior
    RETURN, interior
ENDIF
IF Keyword_Set(linestyle) THEN BEGIN
    self->IDLGRROI::GetProperty, linestyle = linestyle
    RETURN, linestyle
ENDIF
IF Keyword_Set(name) THEN RETURN, self.regionName
;IF Keyword_Set(stats) THEN RETURN, $
;  stats = {area:self.area, $
;           centroid:self.centroid, $
;           perimeter:self.perimeter, $
;           npix:self.npix, $
;           max:self.max, $
;           min:self.min, $
;           mean:self.mean, $
;           stddev:self.stddev, $
;           total:self.total}
IF Keyword_Set(params) THEN RETURN, *self.params
IF Keyword_Set(regiontext) THEN RETURN, self.regiontext
IF Keyword_Set(source) THEN RETURN, self.source
IF Keyword_Set(text) THEN RETURN, self.text
IF Keyword_Set(thick) THEN BEGIN
    self->IDLGRROI::GetProperty, thick = thick
    RETURN, thick
ENDIF
IF Keyword_Set(regiontype) THEN RETURN, self.regiontype
IF Keyword_Set(polygon) THEN RETURN, self.polygon
IF Keyword_Set(xrange) THEN RETURN, self.xrange
IF Keyword_Set(yrange) THEN RETURN, self.yrange

END; Kang_Region::GetProperty--------------------------------------------------


PRO Kang_Region::Rotate, newangle, image_obj = image_obj
; Rotates about the center of the object

; Use IDL's function to rotate it around
IF self.regiontype NE 'Text' THEN BEGIN
    centroid = image_obj->Convert_Coord(self.centroid[0], self.centroid[1], new_coord = 'Image')
    self->IDLGRROI::Rotate, [0,0, 1], self.angle - newangle, Center = [centroid[0], centroid[1], 0]

; Update the statistics
    self->ComputeGeometry, image_obj
ENDIF
self.angle = newangle

; Update the text
IF Ptr_Valid(self.params) THEN BEGIN
    n = N_Elements(*self.params)
    CASE StrUpCase(self.regiontype) OF
        'BOX': (*self.params)[n-1] = self.angle
        'TEXT': (*self.params)[n-1] = self.angle
        'ELLIPSE': (*self.params)[n-1] = self.angle
        'CIRCLE':
        'CROSS': (*self.params)[n-1] = self.angle
        'LINE': 
        'POLYGON': BEGIN
            self->GetProperty, data = data
            data = image_obj->Convert_Coord(data, old_coord = 'Image')
            *self.params = reform(reform(data, 1, N_Elements(data)))
        END
        'THRESHOLD': (*self.params)[n-1] = self.angle
        'FREEHAND': BEGIN
            self->GetProperty, data = data
            data = image_obj->Convert_Coord(data, old_coord = 'Image')
            *self.params = reform(reform(data, 1, N_Elements(data)))
        END
    ENDCASE
    self->CreateText
ENDIF

END; Kang_Region::Rotate--------------------------------------------------


PRO Kang_Region::Scale, scale, image_obj = image_obj

self->Scale, scale
self->ComputeGeometry, image_obj
END; Kang_Region::Scale--------------------------------------------------


PRO Kang_Region::Translate, translation, image_obj = image_obj
; Move the region up, down left or right

; Use IDL's built in translate function
self->IDLGRROI::Translate, translation

; Update the text
IF Ptr_Valid(self.params) THEN BEGIN
    CASE StrUpCase(self.regiontype) OF 
        'LINE': BEGIN
            (*self.params)[0:1] += translation
            (*self.params)[2:3] += translation
        END
        'POLYGON': BEGIN
            n_points = N_Elements(*self.params)/2.
            (*self.params)[lindgen(n_points)*2] +=translation[0]
            (*self.params)[lindgen(n_points)*2+1] +=translation[1]
        END
        'FREEHAND': BEGIN
            n_points = N_Elements(*self.params)/2.
            (*self.params)[lindgen(n_points)*2] +=translation[0]
            (*self.params)[lindgen(n_points)*2+1] +=translation[1]
        END
        ELSE: (*self.params)[0:1] += translation
    ENDCASE
    self->CreateText
ENDIF

; Update the region stats
self->ComputeGeometry, image_obj

END;Kang_Regions::Translate-----------------------------------------------------------------------------------


PRO Kang_Region::CreateText
; Creates the region text string for display in the widget and for
; saving purposes.

self.regiontext = StrCompress(self.regiontype + '(' + StrJoin(*self.params, ',') + ')')

; Adjust the text based on the region properties
self->GetProperty, interior = interior
IF interior THEN self.regiontext = '-' + self.regiontext

; Additional properties
IF ~self.source OR StrTrim(self.regionName, 2) NE '' OR ~self.polygon OR self.thick GT 1 OR self.linestyle GT 0 OR $
  self.cname NE 'green' OR self.text NE '' THEN BEGIN
    self.regiontext += ' # '
    IF self.cname NE 'green' THEN self.regiontext += ('color = ' + StrCompress(self.cname, /Remove))
    IF ~self.source THEN self.regiontext += ' background '
    IF StrTrim(self.regionName, 2) NE '' THEN self.regiontext += ' name = {' + self.regionName + '} '
    IF self.polygon NE 1B THEN self.regiontext += ' type = Line '
    IF self.linestyle GT 1 THEN self.regiontext += ' linestyle = ' + StrTrim(String(self.linestyle, format = '(I)'), 2)
    IF self.thick GT 1 THEN self.regiontext += ' width = ' + StrTrim(String(self.thick, format = '(I)'), 2)
    IF self.text NE '' THEN self.regiontext += ' text = {' + self.text + '}'
ENDIF

END; Kang_Region::CreateText------------------------------------------------------------------------------


PRO Kang_Region::ComputeGeometry, image_obj
; Finds and stores the statistics.

IF self.nostats THEN RETURN

; Find some basic statistics
Result = self->IDLGRROI::ComputeGeometry(area = area, centroid = centroid, perimeter = perimeter)

; Something horribly wrong here sometimes with negative area.
area = abs(area)

; Stats without a valid image object
IF ~Obj_Valid(image_obj) THEN BEGIN
    self.area = area
    self.centroid = centroid[0:1]
    self.perimeter = perimeter
    RETURN
ENDIF

; The remainder of the statistics require an image
image_obj->GetProperty, astr = astr

; These are not astronomical images
IF size(astr, /tname) EQ 'STRING' THEN BEGIN
    self.area = area
    self.perimeter = perimeter
ENDIF ELSE BEGIN
    self.area = area * (abs(astr.cdelt[0]) * astr.cdelt[1]) * 3600.
    self.perimeter = perimeter * abs(astr.cdelt[0]) * 60.
ENDELSE
self.centroid = image_obj->Convert_Coord(centroid[0], centroid[1], Old_Coord = 'Image')

; Find dimensions
image_obj->GetProperty, pix_limits = pix_limits
dimensions = [pix_limits[1]-pix_limits[0]+1, pix_limits[3]-pix_limits[2]+1]

; Find indices of the pixels inside the region
indices = self->Find_Indices(dimensions = [pix_limits[1]-pix_limits[0]+1, pix_limits[3]-pix_limits[2]+1])

; Compute weights if flag is set
IF self.weighting THEN weights = self->ComputeWeights(dimensions = dimensions)

; Find and store additional stats
image_obj->Find_Geometry, indices, min = min, max = max, mean = mean, $;median = median, $
  stddev = stddev, weights = weights
self.min = min
self.max = max
self.mean = mean
;self.median = median
self.stddev = stddev
self.npix = N_Elements(indices)
self.total = self.npix*self.mean

END; Kang_Region::ComputeGeometry-------------------------------------------------------------


FUNCTION Kang_Region::Find_Indices, dimensions = dimensions
; Returns the indices that lie inside the region

; From James Jones at ITT:
self->GetProperty, interior = interior
self->SetProperty, interior = 0
subscriptKey = self->ComputeMask(dimensions = dimensions, /Run_Length)
nSubscripts = total(subscriptKey[0:*:2])
IF nSubscripts GT 0 THEN BEGIN
    roiSubscripts = lonarr(nSubscripts)
    roiCursor = 0
    FOR i = 0, n_elements(subscriptKey)-1, 2 DO BEGIN
        runlength = subscriptKey[i]
        roiSubscripts[roiCursor] = lindgen(runlength) + subscriptKey[i+1]
        roiCursor += runlength
    ENDFOR
ENDIF ELSE roiSubscripts = -1
self->SetProperty, interior = interior

RETURN, roiSubscripts
END; Kang_Region::Find_Indices--------------------------------------------------


FUNCTION Kang_Region::ComputeMask, dimensions = dimensions, mask_in = mask_in, weighted = weighted, run_length = run_length
; Returns a mask with values inside the region at a value of 255B, and
; outside with a value of 0B.
; Basically, we just need to transform to pixel coordinates
; If the weighting keyword is set, this returns an array weighted by
; the fraction of the pixel inside the polygon.

mask = -1
; I forget why this is necessary
self->GetProperty, data = data, interior = interior
x = data[0, *] > 0
y = data[1, *] > 0
region = Obj_New('IDLANROI', x, y, type = self.polygon+1)

; Compute the mask using the built in IDL method.
;IF self.polygon THEN mask_rule = 2 ELSE mask_rule = 0 ; Either polygon or line
IF interior THEN mask_rule = 1  ; Since regiongroup insists on this when computing composite masks, we'll leave it here

IF N_Elements(mask_in) NE 0 THEN mask = region->ComputeMask(dimensions = dimensions, mask_in = mask_in, $
                                                            mask_rule = mask_rule, run_length = run_length) ELSE $
  mask = region->ComputeMask(dimensions = dimensions, mask_rule = mask_rule, run_length = run_length)
Obj_Destroy, region

; The weights
IF Keyword_Set(weighted) THEN weights = self->ComputeWeights(dimensions = dimensions) ELSE weights = 1B
RETURN, mask * weights
END; Kang_Region::ComputeMask----------------------------------------


FUNCTION Kang_Region::ComputeWeights, dimensions = dimensions
; Create a weighted mask sing Mark Hadfield's mgh_polyfillv

self->GetProperty, data = data
RETURN, mgh_polyfillg(data[0:1, *], dimension = dimensions + 1, start = [0, 0], delta = [1,1])
END; Kang_Region::ComputeWeights-------------------------------------


PRO Kang_Region::Draw
; Draw the region on the display

self->GetProperty, data = data, interior = interior

CASE StrUpCase(self.regiontype) OF
    'TEXT': XYOuts, data[0], data[1], self.text, /Data, color = *self.color, charsize = self.charsize, charthick=self.charthick, $
                    orientation = self.angle, alignment = 0.5
    'POINT': PlotS, (data)[0], (data)[1], thick=self.thick, linestyle=self.linestyle, color=(*self.color)[0], NoClip=0
    'LINE': PlotS, (data)[0, *], (data)[1, *], thick=self.thick, linestyle=self.linestyle, color=(*self.color)[0], NoClip=0
    'FREEHAND': BEGIN
; Lines, don't close polygon
        IF self.polygon EQ 0B THEN PlotS, data, thick=self.thick, linestyle=self.linestyle, color=(*self.color)[0], NoClip=0 ELSE $
          PlotS, [[data], [data[*, 0]]], thick=self.thick, linestyle=self.linestyle, color=(*self.color)[0], NoClip=0 
; Draw the red line
        IF interior THEN PlotS, [self.xrange[1], self.xrange[0]], [self.yrange[0], self.yrange[1]], thick=thick, color=250, NoClip=0
    END
    ELSE: BEGIN
; Add the last element to close the polygon
        PlotS, [[data], [data[*, 0]]], thick=self.thick, linestyle=self.linestyle, color=(*self.color)[0], NoClip=0

; Draw the red line
        IF interior THEN PlotS, [self.xrange[1], self.xrange[0]], [self.yrange[0], self.yrange[1]], thick=thick, color=250, NoClip=0
    END
ENDCASE

END; Kang_Region::Draw--------------------------------------------------


PRO Kang_Region__Define

struct = {KANG_REGION, $
          INHERITS IDLGRROI, $
          regiontext:'', $      ; Text to display in widget
          regiontype:'', $      ; Type of region
          angle:0., $           ; Position angle
          params:Ptr_New(), $   ; Parameters used to construct region
          area:0., $            ; Region stats
          perimeter:0., $
          npix:0L, $
          centroid:FltArr(2), $
          max:0., $
          min:0., $
          mean:0., $
;          median:0., $
          stddev:0., $
          total:0., $
          text:'', $            ; Region drawing properties
          charsize:0, $
          charthick:0, $
          coords:'', $
          cname:'', $           ; Color name
          font:0, $
          regionname:'', $
          polygon:0B, $         ; Region can be a polygon or a line
          weighting:0B, $       ; Use weights in the statistical analysis?
          source:0B, $          ; Is this a source or a background region?
          nostats: 0B $         ; Set to 1 if stats are not to be computed
         }

END; Kang_Region__Define------------------------------------------------------------
