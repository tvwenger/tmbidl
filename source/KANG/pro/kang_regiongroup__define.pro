FUNCTION Kang_RegionGroup::Init, $
  objects, $
  angle = angle, $
  background = background, $
  color = color, $
  cname = cname, $
  charsize = charsize, $
  charthick = charthick, $
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

IF N_Elements(angle) NE 0 THEN self.angle = 0 > angle < 360
IF N_Elements(background) NE 0 THEN self.source = ~background ELSE self.source = 1B
self.color = 245
IF N_Elements(cname) NE 0 THEN self.cname = cname ELSE self.cname = 'Green'
IF N_Elements(charsize) NE 0 THEN self.charsize = charsize
IF N_Elements(charthick) NE 0 THEN self.charthick = charthick
IF N_Elements(font) NE 0 THEN self.font = font
IF N_Elements(interior) NE 0 THEN self.interior = interior
IF N_Elements(linestyle) NE 0 THEN self.linestyle = linestyle
IF Keyword_Set(nostats) THEN self.nostats = 1
IF N_Elements(regionType) NE 0 THEN self.regionType = regionType
IF N_Elements(params) NE 0 THEN self.params = Ptr_New(params)
IF N_Elements(source) NE 0 THEN self.source = source ELSE self.source = 1B
IF N_Elements(text) NE 0 THEN self.text = text

n_obj = N_Elements(objects)
IF n_obj GT 0 THEN BEGIN
; Add objects to container
    FOR i = 0, n_obj-1 DO self->Add, objects[i]

; Find stats
    self->ComputeGeometry, image_obj
ENDIF

IF  ~Ptr_Valid(self.params) THEN BEGIN ; Not a threshold region, define params
    self.params = Ptr_New([self.centroid, self.angle]) ; centroid and angle
ENDIF

; Add text
self->CreateText

RETURN, 1
END; Kang_RegionGroup::Init-----------------------------------------------------


PRO Kang_RegionGroup::Cleanup

Ptr_Free, self.params
self->IDLANROIGROUP::Cleanup
END; Kang_RegionGroup::Cleanup--------------------------------------------------


PRO Kang_RegionGroup::GetProperty, $
  alltext = alltext, $
  angle = angle, $
  background = background, $
  cname = cname, $
  color = color, $
  composite = composite, $
  interior = interior, $
  linestyle = linestyle, $
  n_regions=n_regions, $
  params = params, $
  polygon = polygon, $
  regiontext=regiontext, $
  regiontype=regiontype, $
  source = source, $
  stats = stats, $
  thick = thick, $
  text = text, $
  xrange = xrange, $
  yrange = yrange, $
  position = position, $
  _Ref_Extra = extra

self->IDLANROIGROUP::GetProperty, _Strict_Extra = extra

; Returns the indicated property
IF Arg_Present(alltext) THEN BEGIN
    count = self->Count()
    alltext = StrArr(count)
    FOR i = 0, count-1 DO BEGIN
        obj = self->Get(position = i)
        obj->GetProperty, regiontext = regiontext
        alltext[i] = regiontext
    ENDFOR
ENDIF
IF Arg_Present(angle) THEN angle = self.angle
IF Arg_Present(background) THEN background = ~self.source
IF Arg_Present(cname) THEN cname = self.cname
IF Arg_Present(color) THEN color = self.color
IF Arg_Present(composite) THEN composite = 1
IF Arg_Present(interior) THEN interior = self.interior
IF Arg_Present(linestyle) THEN linestyle = self.linestyle
IF Arg_Present(n_regions) THEN n_regions = self.n_regions
IF Arg_Present(stats) THEN BEGIN
    stats = {angle:self.angle, $
             area:self.area, $
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
IF Arg_Present(polygon) THEN polygon = self.polygon
IF Arg_Present(regiontext) THEN regiontext = self.regiontext
IF Arg_Present(regiontype) THEN regiontype = self.regiontype
IF Arg_Present(source) THEN source = self.source
IF Arg_Present(thick) THEN thick = self.thick
IF Arg_Present(text) THEN text = self.text
IF Arg_Present(xrange) THEN self->IDLANROIGROUP::GetProperty, roigroup_xrange = xrange
IF Arg_Present(yrange) THEN self->IDLANROIGROUP::GetProperty, roigroup_yrange = yrange

END; Kang_RegionGroup::GetProperty----------------------------------------------


FUNCTION Kang_RegionGroup::GetProperty, $
  angle = angle, $
  background = background, $
  charsize = charsize, $
  charthick = charthick, $
  cname = cname, $
  coords = coords, $
  color = color, $
  composite = composite, $
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

self->IDLANROIGROUP::GetProperty, _Strict_Extra = extra

IF Keyword_Set(angle) THEN RETURN, self.angle
IF Keyword_Set(background) THEN RETURN, ~self.source
IF Keyword_Set(charsize) THEN RETURN,  self.charsize
IF Keyword_Set(charthick) THEN RETURN, self.charthick
IF Keyword_Set(cname) THEN RETURN, self.cname
IF Keyword_Set(color) THEN RETURN, self.color
IF Keyword_Set(composite) THEN RETURN, 1
IF Keyword_Set(coords) THEN RETURN, self.coords
IF Keyword_Set(font) THEN RETURN, self.font
IF Keyword_Set(interior) THEN interior = self.interior
IF Keyword_Set(linestyle) THEN lienstyle = self.linestyle
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
IF Keyword_Set(thick) THEN thick = self.thick
IF Keyword_Set(regiontype) THEN RETURN, self.regiontype
IF Keyword_Set(polygon) THEN RETURN, self.polygon
IF Arg_Present(xrange) THEN BEGIN
    self->IDLANROIGROUP::GetProperty, roigroup_xrange = xrange
    RETURN, xrange
ENDIF
IF Arg_Present(yrange) THEN BEGIN
    self->IDLANROIGROUP::GetProperty, roigroup_yrange = yrange
    RETURN, yrange
ENDIF

END; Kang_RegionGroup::GetProperty----------------------------------------------


PRO Kang_RegionGroup::SetProperty, $
  background = background, $
  cname = cname, $
  charsize = charsize, $
  charthick = charthick, $
  coords = coords, $
  font = font, $
  name = name, $
  source = source, $
  polygon = polygon, $
  image_obj = image_obj, $  
  _Extra = extra

;self->IDLANROIGROUP::SetProperty, _Strict_Extra = extra
IF N_Elements(background) NE 0 THEN self.source = 0B > (~background) < 1B
IF N_Elements(source) NE 0 THEN self.source = 0B > source < 1B

;stop
;FOR j = 0, n_Tags(extra)-1 DO BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, _Extra = extra
;    ENDFOR
;ENDFOR

;IF N_Elements(color) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, color = color
;    ENDFOR
;    self.color = color
;ENDIF
;IF N_Elements(cname) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, cname = cname
;    ENDFOR
;    self.cname = cname
;ENDIF
;IF N_Elements(charsize) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, charsize = charsize
;    ENDFOR
;    self.charsize = charsize
;ENDIF
;IF N_Elements(charthick) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, charthick = charthick
;    ENDFOR
;    self.charthick = charthick
;ENDIF
;IF N_Elements(font) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, font = font
;    ENDFOR
;    self.font = font
;ENDIF
;IF N_Elements(interior) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, interior = interior
;    ENDFOR
;    self.interior = interior
;ENDIF
;IF N_Elements(linestyle) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, linestyle = linestyle
;    ENDFOR
;    self.linestyle = linestyle
;ENDIF
;IF N_Elements(text) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, text = text
;    ENDFOR
;    self.text = text
;ENDIF
;IF N_Elements(thick) NE 0 THEN BEGIN
;    FOR i = 0, self.n_regions-1 DO BEGIN
;        obj = self->Get(position = i)
;        obj->SetProperty, thick = thick
;    ENDFOR
;    self.thick = thick
;ENDIF

;Update the text
self->CreateText

END; Kang_RegionGroup::SetProperty----------------------------------------------


PRO Kang_RegionGroup::Rotate, newangle, image_obj = image_obj

; Doesn't do rotating yet
self->IDLANROIGROUP::Rotate, [0,0, 1], self.angle - newangle, Center = [self.centroid[0], self.centroid[1], 0]
self.angle = newangle

; Change params
(*self.params)[2] = self.angle

; Adjust stats
self->ComputeGeometry, image_obj

; Change text
self->CreateText

END; Kang_RegionGroup::Rotate---------------------------------------------------


PRO Kang_RegionGroup::Translate, translation, image_obj = image_obj

self->IDLANROIGROUP::Translate, translation

; Adjust text
(*self.params)[1] = (*self.params)[1] + translation[0]
(*self.params)[2] = (*self.params)[2] + translation[1]
self->CreateText

; Adjust stats
self->ComputeGeometry, image_obj

END; Kang_RegionGroup-----------------------------------------------------------


PRO Kang_RegionGroup::ComputeGeometry, image_obj
; Finds stats for group
;Result = self->IDLGRROI::ComputeGeometry(area = area, centroid = centroid, perimeter = perimeter)

IF self.nostats THEN RETURN
image_obj->GetProperty, pix_limits = pix_limits
dimensions = [pix_limits[1]+1, pix_limits[3]+1]

indices = self->Find_Indices(dimensions = dimensions)
image_obj->Find_Geometry, indices, min = min, max = max, mean = mean, stddev = stddev, weights = weights
self.min = min
self.max = max
self.mean = mean
self.stddev = stddev
self.npix = N_Elements(indices)
self.total = self.npix*self.mean

END; Kang_RegionGroup::ComputeGeometry------------------------------------------


PRO Kang_RegionGroup::CreateText
; Just creates the region text string

self.regiontext = StrCompress(self.regiontype + '(' + StrJoin(*self.params, ',') + ')')

; Adjust the text based on the region properties
self->GetProperty, interior = interior
IF interior THEN self.regiontext = '-' + self.regiontext

; Additional properties
IF ~self.source THEN BEGIN;OR ~self.polygon OR self.thick GT 1 OR self.linestyle GT 0 OR self.cname NE 'green' THEN BEGIN
    self.regiontext += ' # '
;    IF self.cname NE 'green' THEN self.regiontext += ('color = ' + StrCompress(self.cname, /Remove))
    IF ~self.source THEN self.regiontext += ' background '
;    IF StrTrim(self.regionName, 2) NE '' THEN self.regiontext += ' name = {' + self.regionName + '} '
;    IF self.polygon NE 1B THEN self.regiontext += ' type = Line '
;    IF self.linestyle GT 1 THEN self.regiontext += ' linestyle = ' + StrTrim(String(self.linestyle, format = '(I)'), 2)
;    IF self.thick GT 1 THEN self.regiontext += ' width = ' + StrTrim(String(self.thick, format = '(I)'), 2)
ENDIF

END; Kang_RegionGroup::CreateText-----------------------------------------------


FUNCTION Kang_RegionGroup::Find_Indices, dimensions = dimensions
; Returns the indices that lie inside the region

; From James Jones at ITT:
;self->GetProperty, interior = interior
;self->SetProperty, interior = 0
;subscriptKey = self->ComputeMask(dimensions = dimensions, /Run_Length)
;nSubscripts = total(subscriptKey[0:*:2])
;IF nSubscripts GT 0 THEN BEGIN
;    roiSubscripts = lonarr(nSubscripts)
;    roiCursor = 0
;    FOR i = 0, n_elements(subscriptKey)-1, 2 DO BEGIN
;        runlength = subscriptKey[i]
;        roiSubscripts[roiCursor] = lindgen(runlength) + subscriptKey[i+1]
;        roiCursor += runlength
;    ENDFOR
;ENDIF ELSE roiSubscripts = -1
;self->SetProperty, interior = interior

;RETURN, roiSubscripts

;;indices = -1

;; Remove holes
;FOR i = 0, self.n_regions-1 DO BEGIN
;; Get data for region
;    obj = self->IDLANROIGROUP::Get(position=i)
;    obj->GetProperty, interior = interior

;; Calculate indices for the individual region
;    indices_new = obj->Find_Indices(dimensions = dimensions)

;; Interior regions - remove from indices
;    IF interior THEN BEGIN

;; Indices is undefined - remove indices
;        IF indices[0] NE -1 THEN indices = SetDifference(indices, indices_new)
;    ENDIF ELSE BEGIN
;; Not interior regions - add to indices
;        IF indices[0] EQ -1 THEN indices = indices_new ELSE BEGIN
;            array = [indices, indices_new]
;            indices = array[Uniq(array, Sort(array))] ; Find unique values
;        ENDELSE
;    ENDELSE
;ENDFOR

foo = self->ComputeMask(dimensions = dimensions, indices = indices)
RETURN, indices
END; Kang_RegionGroup::Find_Indices---------------------------------------------


FUNCTION Kang_RegionGroup::ComputeMask, dimensions = dimensions, mask_in = mask_in, weighted = weighted, $
  run_length = run_length, indices = indices

;self->GetProperty, interior = interior

;IF self.polygon THEN mask_rule = 2 ELSE mask_rule = 0 ; Either polygon or line
;IF interior THEN mask_rule = 1

objref = self->Get(/All)
exterior_indices = [-1]
interior_indices = [-1]
FOR i = 0, self.n_regions-1 DO BEGIN
    objref[i]->GetProperty, interior = interior
    indices = objref[i]->Find_Indices(dimensions = dimensions)
    IF interior THEN BEGIN
        interior_indices = [indices, interior_indices]
    ENDIF ELSE BEGIN
        exterior_indices = [indices, exterior_indices]
    ENDELSE
ENDFOR

; Take only exterior indices not included in interior indices
; Setdifference does all the uniq and sorting for us, removes -1 naturally
indices = setdifference(exterior_indices, interior_indices)

mask = bytarr(dimensions)
IF indices[0] NE -1 THEN mask[indices] = 255
RETURN, mask

END; Kang_RegionGroup::ComputeMask----------------------------------------------


PRO Kang_RegionGroup::Add, region

self->IDLANROIGROUP::Add, region
++self.n_regions
END; Kang_RegionGroup::Add-----------------------------------------------------


FUNCTION Kang_RegionGroup::Get, position = position, All=all, count = count
; Returns the object references of interest

; Default to returning all
IF N_Elements(position) EQ 0 THEN RETURN, self->IDLANROIGROUP::Get(All = all, count = count) ELSE $
  RETURN, self->IDLANROIGROUP::Get(position = position, All = All, count = count)

END; Kang_Region_Container::Get-------------------------------------------------


PRO Kang_RegionGroup::Draw
; Cycles through the group, drawing the regions

FOR i = 0, self.n_regions-1 DO BEGIN
    obj = self->IDLANROIGROUP::Get(position=i)
    obj->Draw
ENDFOR

END; Kang_RegionGroup::Draw-----------------------------------------------------


PRO Kang_RegionGroup__Define

; Define self structure
struct = {KANG_REGIONGROUP, $
          INHERITS IDLANROIGROUP, $ ; IDLANGROUP methods
          regiontext:'', $      ; Text for this region
          regiontype:'', $      ; Type of region - composite or threshold
          n_regions:0L, $       ; Number of individual regions in this object
          angle:0., $           ; Rotated angle
          area:0., $            ; Area in native coordinate units
          cname:'', $           ; Color name
          color:0B, $           ; Color index
          centroid:FltArr(2), $ ; Center of region group
          params:Ptr_New(), $   ; Parameters used to create object
          perimeter:0., $       ; Perimeter
          npix:0L, $            ; Number of pixels
          max:0., $             ; Maximum image value within the object
          min:0., $             ; Minimmum image value within the object
          mean:0., $            ; Mean image value within the object
;          median:0., $          ; Median value in the image within the object
          nostats:0B, $         ; If set, no statistics are computed
          stddev:0., $          ; Standard deviation of the image values in the object
          source:0B, $          ; Is this a source or a background region?
          total:0., $           ; Sum of the image values
          text:'', $            ; Region labelling text
          charsize:0, $         ; Size for the text
          charthick:0, $        ; Text thickness
          font:0, $             ; Text font
          thick:0L, $           ; Region line thickness
          linestyle:0L, $       ; Dash-dot, etc
          interior:0B, $        ; Interior are holes
          weighting:0B, $       ; Use weights in the statistical analysis?
          polygon:0B $
         }

END; Kang_RegionGroup__Define---------------------------------------------------
