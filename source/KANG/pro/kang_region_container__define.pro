FUNCTION Kang_Region_Container::Init, $
  color_obj = color_obj, $
  image_obj = image_obj

; Initializes the object.

self.region = Obj_New('IDL_Container')
self.selected_regions = Ptr_New([-1])
IF N_Elements(image_obj) NE 0 THEN self.image_obj = image_obj

RETURN, 1
END; Kang_Region_Container::Init-----------------------------------------------------


PRO Kang_Region_Container::Combine
; Combines selected regions into a single regiongroup

; Get object references
objs = self->Get(count = count)
IF count LE 1 THEN RETURN

ogroup = Obj_New('Kang_RegionGroup', objs, regiontype = 'Composite', image_obj = self.image_obj)
self->Delete                    ; Delete old regions
self->Add, ogroup               ; Add new one
self->Select, /Last

END; Kang_Region_Container::Combine--------------------------------------------------


PRO Kang_Region_Container::Dissolve, position = position
; Dissolves a regiongroup into its composite regions

ogroup = self->Get(position = position)
IF StrUpCase(size(ogroup, /tname)) NE 'OBJREF' THEN RETURN
IF Obj_Class(ogroup) NE 'KANG_REGIONGROUP' THEN RETURN
    
old_n_reg = self.n_regions
objs = ogroup->Get(/All)        ; Find object references
self->Delete, position = position ; Delete old object
n_reg = N_Elements(objs)
FOR i = 0, n_reg-1 DO self->Add, objs[i] ; Add new objects
self->Select, lindgen(n_reg) + old_n_reg - 1

END; Kang_Region_Container::Dissolve--------------------------------------------------


PRO Kang_Region_Container::GetProperty, $
  angle = angle, $
  background = background, $
  data = data, $
  color = color, $
  coords = coords, $
  composite = composite, $
  cname = cname, $
  interior = interior, $
  linestyle = linestyle, $
  n_regions=n_regions, $
  n_selected=n_selected, $
  name = name, $
  params = params, $
  polygon = polygon, $
  position=position, $
  regiontext = regiontext, $
  regiontype = regiontype, $
  selected_regions = selected_regions, $
  source = source, $
  stats = stats, $
  text=text, $
  thick=thick, $
  type = type, $
  xrange = xrange, $
  yrange = yrange

IF Arg_Present(n_regions) THEN n_regions = self.n_regions
IF Arg_Present(n_selected) THEN foo = N_Elements(where(*self.selected_regions GT -1, n_selected))
IF Arg_Present(selected_regions) THEN selected_regions = *self.selected_regions
IF Arg_Present(regiontext) THEN BEGIN
    IF self.n_regions GT 0 THEN BEGIN
        regiontext = StrArr(self.n_regions)
        FOR i = 0, self.n_regions-1 DO BEGIN
            obj = self->Get(position = i)
            obj->GetProperty, regiontext = regiontext0
            regiontext[i] = regiontext0
        ENDFOR
    ENDIF ELSE regiontext = ''
ENDIF

; Returns the indicated property, but only for the top object
IF N_Elements(position) EQ 0 THEN position = *self.selected_regions
IF position[0] NE -1 THEN BEGIN
    n = N_Elements(position)
    objs = self->Get(position = position)
    IF Arg_Present(angle) THEN BEGIN
        angle = FltArr(n)
        FOR i = 0, n-1 DO angle[i] = objs[i]->GetProperty(/angle)
    ENDIF
    IF Arg_Present(color) THEN BEGIN
; THIS DOES NOT WORK!!!!
        color = LonArr(n)
        FOR i = 0, n-1 DO color[i] = objs[i]->GetProperty(/color)
    ENDIF
    IF Arg_Present(coords) THEN BEGIN
        coords = LonArr(n)
        FOR i = 0, n-1 DO coords[i] = objs[i]->GetProperty(/coords)
    ENDIF
    IF Arg_Present(composite) THEN BEGIN
        composite = LonArr(n)
        FOR i = 0, n-1 DO composite[i] = objs[i]->GetProperty(/composite)
    ENDIF
    IF Arg_Present(cname) THEN BEGIN
        cname = StrArr(n)
        FOR i = 0, n-1 DO cname[i] = objs[i]->GetProperty(/cname)
    ENDIF
    IF Arg_Present(data) THEN objs[0]->GetProperty, data = data
    IF Arg_Present(interior) THEN BEGIN
        interior = BytArr(n)
        FOR i = 0, n-1 DO interior[i] = objs[i]->GetProperty(/interior)
    ENDIF
    IF Arg_Present(linestyle) THEN  BEGIN
        linestyle = LonArr(n)
        FOR i = 0, n-1 DO linestyle[i] = objs[i]->GetProperty(/linestyle)
    ENDIF
    IF Arg_Present(stats) THEN BEGIN
        IF n GE 1 THEN BEGIN
            stats = {area:FltArr(n), $
                     centroid:FltArr(2, n), $
                     perimeter:FltArr(n), $
                     npix:LonArr(n), $
                     max:FltArr(n), $
                     min:FltArr(n), $
                     mean:FltArr(n), $
                     stddev:FltArr(n), $
                     total:FltArr(n)}
        
            FOR i = 0, n-1 DO BEGIN
                objs[i]->GetProperty, stats = stats0
                stats.area[i] = stats0.area
                stats.centroid[*, i] = stats0.centroid
                stats.perimeter[i] = stats0.perimeter
                stats.npix[i] = stats0.npix
                stats.max[i] = stats0.max
                stats.min[i] = stats0.min
                stats.mean[i] = stats0.mean
                stats.stddev[i] = stats0.stddev
                stats.total[i] = stats0.total
            ENDFOR
        ENDIF ELSE  stats = -1;objs[0]->GetProperty, stats = stats
    ENDIF
    IF Arg_Present(params) THEN objs[0]->GetProperty, params = params
    IF Arg_Present(polygon) THEN  BEGIN
        polygon = BytArr(n)
        FOR i = 0, n-1 DO polygon[i] = objs[i]->GetProperty(/polygon)
    ENDIF
    IF Arg_Present(regiontype) THEN BEGIN
        regiontype = StrArr(n)
        FOR i = 0, n-1 DO regiontype[i] = objs[i]->GetProperty(/regiontype)
    ENDIF
    IF Arg_Present(text) THEN BEGIN
        text = StrArr(n)
        FOR i = 0, n-1 DO text[i] = objs[i]->GetProperty(/text)
    ENDIF
    IF Arg_Present(thick) THEN BEGIN
        thick = LonArr(n)
        FOR i = 0, n-1 DO thick[i] = objs[i]->GetProperty(/thick)
    ENDIF
    IF Arg_Present(name) THEN BEGIN
        name = StrArr(n)
        FOR i = 0, n-1 DO name[i] = objs[i]->GetProperty(/name)
    ENDIF
    IF Arg_Present(source) THEN BEGIN
        source = BytArr(n)
        FOR i = 0, n-1 DO source[i] = objs[i]->GetProperty(/source)
    ENDIF
    IF Arg_Present(background) THEN BEGIN
        background = BytArr(n)
        FOR i = 0, n-1 DO background[i] = objs[i]->GetProperty(/background)
    ENDIF
    IF Arg_Present(xrange) THEN BEGIN
        xrange = FltArr(2, n)
        FOR i = 0, n-1 DO xrange[*, i] = objs[i]->GetProperty(/xrange)
    ENDIF
    IF Arg_Present(yrange) THEN BEGIN
        yrange = FltArr(2, n)
        FOR i = 0, n-1 DO yrange[*, i] = objs[i]->GetProperty(/yrange)
    ENDIF
ENDIF

END;Kang_Region_Container::GetProperty-----------------------------------------------


FUNCTION Kang_Region_Container::Get_Stats

self->GetProperty, stats = stats
RETURN, stats
END; Kang_Region_Container::Get_Stats-----------------------------------------------


PRO Kang_Region_Container::SetProperty, $
  angle = angle, $
  background = background, $
  color = color, $
  coords = coords, $
  cname = cname, $
  data = data, $
  include = include, $
  exclude = exclude, $
  linestyle = linestyle, $
  source = source, $
  width = width, $
  name = name, $
  params = params, $
  position = position, $
  polygon = polygon, $
  text = text, $
  type = type
; Sets the indicated property

; Determine which info to be passed back
IF N_Elements(position) EQ 0 THEN position = *self.selected_regions
IF position[0] EQ -1 THEN BEGIN
    print, 'ERROR: No regions selected or specified.'
    RETURN
ENDIF
n_pos = N_Elements(position)

; Loop over all locations in position
FOR i = 0, n_pos - 1 DO BEGIN
    obj = self->Get(position = position[i])
; angle
    IF N_Elements(background) NE 0 THEN obj->SetProperty, source = ~background
    IF N_Elements(source) NE 0 THEN obj->SetProperty, source = source
    IF N_Elements(color) NE 0 THEN obj->SetProperty, color = color
    IF N_Elements(coords) NE 0 THEN BEGIN
        obj->SetProperty, coords = coords
; Need to convert coords here
    ENDIF
    IF N_Elements(cname) NE 0 THEN obj->SetProperty, cname = cname
    IF N_Elements(include) NE 0 THEN obj->SetProperty, interior = ~include, image_obj = self.image_obj
    IF N_Elements(exclude) NE 0 THEN obj->SetProperty, interior = exclude, image_obj = self.image_obj
    IF N_Elements(linestyle) NE 0 THEN obj->SetProperty, linestyle = linestyle
    IF N_Elements(width) NE 0 THEN obj->SetProperty, thick = width
    IF N_Elements(name) NE 0 THEN obj->SetProperty, name = name
    IF N_Elements(text) NE 0 THEN obj->SetProperty, text = text
    IF N_Elements(polygon) NE 0 THEN obj->SetProperty, polygon = polygon, image_obj = self.image_obj
ENDFOR

; Params can only apply to a single region
IF N_Elements(params) NE 0 AND N_Elements(data) NE 0 THEN BEGIN
    obj = self->Get(position = position[0])
    obj->SetProperty, params = params, data = data, image_obj = self.image_obj
ENDIF

END; Kang_Region_Container::SetProperty----------------------------------------------


PRO Kang_Region_Container::Select, positions_in, Add = add, All = All, First = first, Include = include, $
  Exclude = exclude, Invert = invert, Last = last, None = None, $
  source = source, background = background, Next = next, Previous = previous
; Sets which regions are selected
; This is turning into a pretty effective filtering routine.  You can
; select excluded regions, source regions, etc.

IF self.n_regions EQ 0 THEN BEGIN
    *self.selected_regions = [-1]
    RETURN
ENDIF 

IF N_Elements(positions_in) NE 0 THEN BEGIN
; Take unique positions within range
    positions = 0 > positions_in < (self.n_regions-1)
    selected = positions[uniq(positions, sort(positions))]

; I took this out for now - it increased the width for clarity.
;                           Something like this is probably needed.
; Brackets here force array math, which is needed later
;    IF (*self.selected_regions)[0] NE -1 THEN BEGIN
;        FOR i = 0, N_Elements(*self.selected_regions)-1 DO BEGIN
; Change width so display is clearer
;            obj = self.region->Get(position = (*self.selected_regions)[i])
;            obj->GetProperty, thick = width
;            obj->SetProperty, thick = width-1
;        ENDFOR
;    ENDIF
;    IF (*self.selected_regions)[0] NE -1 THEN BEGIN
;        FOR i = 0, N_Elements(*self.selected_regions)-1 DO BEGIN
;            obj = self.region->Get(position = (*self.selected_regions)[i])
; Change width so display is clearer
;            obj->GetProperty, thick = width
;            obj->SetProperty, thick = width+1
;            obj->GetProperty, thick = width
;        ENDFOR
;    ENDIF
ENDIF

; All, none, invert
IF Keyword_Set(all) THEN *self.selected_regions = indgen(self.n_regions)
IF Keyword_Set(none) THEN *self.selected_regions = [-1]
IF Keyword_Set(invert) THEN BEGIN
    IF self.n_regions GT 1 THEN BEGIN
; Use histograms for this
        selected = where(histogram(indgen(self.n_regions)) GT 0 AND $
                         histogram(*self.selected_Regions, Min = 0, Max = self.N_Regions-1) EQ 0)
    ENDIF ELSE *self.selected_regions = [-1]
ENDIF

; first, last, next, previous
IF Keyword_Set(first) THEN selected = 0 < (self.n_regions-1)
IF Keyword_Set(last) THEN selected = self.n_regions-1
IF Keyword_Set(previous) THEN selected = 0 > (max(*self.selected_regions)) - 1
IF Keyword_Set(next) THEN selected = (self.n_regions-1) < (max(*self.selected_regions)) - 1

; These are properties of the region
IF Keyword_Set(exclude) OR Keyword_Set(include) OR Keyword_Set(source) OR Keyword_Set(Background) THEN BEGIN

; Get arrays
    self->GetProperty, position = lindgen(self.n_regions), interior = exclude_arr, background = background_arr

; These will create large arrays that need to be uniqueified
    IF Keyword_Set(exclude) THEN selected = where(exclude_arr EQ 1B)
    IF Keyword_Set(include) THEN selected = where(exclude_arr EQ 0B)
    IF Keyword_Set(background) THEN BEGIN
        IF N_Elements(selected) NE 0 THEN BEGIN
            selected2 = where(background_arr EQ 1B)
            selected = where((histogram(selected, MIN=minab, MAX=maxab) NE 0) and  $
                             (histogram(selected2, MIN=minab, MAX=maxab) ne 0), count) ; This is setintersection
        ENDIF ELSE selected = where(background_arr EQ 1B)
    ENDIF
    IF Keyword_Set(source) THEN BEGIN
        IF N_Elements(selected) NE 0 THEN BEGIN
            selected2 = where(background_arr EQ 0B)
            selected = where((histogram(selected, MIN=minab, MAX=maxab) NE 0) and  $
                             (histogram(selected2, MIN=minab, MAX=maxab) ne 0), count) ; This is setintersection
        ENDIF ELSE selected = where(background_arr EQ 0B)
    ENDIF
ENDIF

; Do the selection
IF N_Elements(selected) NE 0 THEN BEGIN

; Add to current selection
    IF Keyword_Set(add) THEN BEGIN
        IF selected[0] NE -1 THEN array = [*self.selected_regions, selected] ELSE $
          array = *self.selected_regions
        *self.selected_regions = [array[uniq(array, sort(array))]]
    ENDIF ELSE *self.selected_regions = [selected]
ENDIF

END; Kang_Region_Container::Select---------------------------------------------------


FUNCTION Kang_Region_Container::Get, position = position, All=all, count = count
; Returns the object references of interest

; Use selected regions if nothing unput
IF N_Elements(position) EQ 0 AND ~Keyword_Set(all) THEN position = *self.selected_regions
IF Keyword_Set(all) THEN position = lindgen(self.region->count())

IF position[0] NE -1 THEN RETURN, self.region->Get(position = position, count = count) $
  ELSE RETURN, -1

END; Kang_Region_Container::Get------------------------------------------------------


PRO Kang_Region_Container::Load, filename, colors_obj, nostats = nostats

; Open file
IF ~file_test(filename, /Read) THEN BEGIN
    print, 'ERROR: Region file ' + filename + ' cannot be found.'
    RETURN
ENDIF
openr, lun, filename, /Get_Lun
nlines = NumLines(filename)
IF nlines EQ 0 THEN BEGIN
    print, 'ERROR: Region file ' + filename + ' has no lines.'
    RETURN
ENDIF
regions = StrArr(nlines)

; Read the file into the regions variable
temp = ''
FOR i = 0, nlines-1 DO BEGIN 
    readf, lun, temp
    regions[i] = StrCompress(StrTrim(temp,2))
ENDFOR

; Close the file
free_lun, lun

; Parse out the regions
regions = StrTrim(regions, 2)
regions = StrCompress(regions)
regions = RepStr(regions, ' = ', '=')
regions = RepStr(regions, '# ', '#')

; Locate composite regions, remove # character
wh_composite = where(StrMatch(regions, '#Composite*', /Fold_Case) EQ 1, n_composite)
IF n_composite NE 0 THEN regions[wh_composite] = RepStr(regions[wh_composite], '#Composite', 'Composite')

; Remove comments
wh_not_comments = where(StrMatch(regions, '#*') EQ 0 AND StrMatch(regions, '#Composite*', /Fold_Case) EQ 0)
IF wh_not_comments[0] NE -1 THEN regions = regions[wh_not_comments] ELSE RETURN

; Remove nulls
regions = regions[where(StrCompress(regions, /Remove_All) NE '')]

; Locate composite components
composite_array = StrMatch(regions, '*||*')
n_composite2 = total(composite_array)

; Region properties
n_regions = N_Elements(regions)
text = StrArr(n_regions)
color = StrArr(n_regions)
font = StrArr(n_regions)
width = FltArr(n_regions)
select = BytArr(n_regions)
edit = BytArr(n_regions)
move = BytArr(n_regions)
delete = BytArr(n_regions)
highlight = BytArr(n_regions)
exclude = BytArr(n_regions)
rotate = BytArr(n_regions)
source = BytArr(n_regions)

; Default Values
text[*] = ''
color[*] = 'Green'
font[*] = 'normal'
width[*] = 1B
select[*] = 1B
edit[*] = 1B
move[*] = 1B
delete[*] = 1B
highlight[*] = 1B
exclude[*] = 0B
rotate[*] = 1B
source[*] = 1B

;----------------------------------
; Parse out global params
wh_global = where(StrMatch(regions, 'Global*', /Fold_Case) EQ 1, Complement = wh_not_global)
IF wh_not_global[0] EQ -1 THEN RETURN
wh_global = [wh_global, n_regions]

IF wh_global[0] NE -1 THEN BEGIN
; Loop through global parameters
    FOR i = 0, N_Elements(wh_global)-2 DO BEGIN
        global_params = StrSplit(regions[wh_global[i]], ' ', /Extract)
        startval = (wh_global[i]) < n_regions
        endval = (wh_global[i+1]-1) < (n_regions-1)

; Text
        wh_text = (where(StrMatch(global_params, 'Text=*', /Fold_Case) EQ 1))[0]
        IF wh_text NE -1 THEN text[startval:endval] = StrTrim(StrMid(global_params[wh_text], 5, 200), 2)
; Colors
        wh_color = (where(StrMatch(global_params, 'Color=*', /Fold_Case) EQ 1))[0]
        IF wh_color NE -1 THEN color[startval:endval] = StrTrim(StrMid(global_params[wh_color], 6, 200), 2)
; Font
        wh_font = (where(StrMatch(global_params, 'FONT=*', /Fold_Case) EQ 1))[0]
        IF wh_font NE -1 THEN font[startval:endval] = StrTrim(StrMid(global_params[wh_font], 7, 200), 2)
; Width
        wh_width = (where(StrMatch(global_params, 'WIDTH=*', /Fold_Case) EQ 1))[0]
        IF wh_width NE -1 THEN width[startval:endval] = StrTrim(StrMid(global_params[wh_width], 6, 200), 2)
; Select
        wh_select = (where(StrMatch(global_params, 'SELECT=*', /Fold_Case) EQ 1))[0]
        IF wh_select NE -1 THEN select[startval:endval] = Byte(StrTrim(StrMid(global_params[wh_select], 7, 200), 2))
; Edit
        wh_edit = (where(StrMatch(global_params, 'EDIT=*', /Fold_Case) EQ 1))[0]
        IF wh_edit NE -1 THEN edit[startval:endval] = Byte(StrTrim(StrMid(global_params[wh_edit], 5, 200), 2))
; Move
        wh_move = (where(StrMatch(global_params, 'MOVE=*', /Fold_Case) EQ 1))[0]
        IF wh_move NE -1 THEN move[startval:endval] = Byte(StrTrim(StrMid(global_params[wh_move], 5, 200), 2))
; Delete
        wh_delete = (where(StrMatch(global_params, 'DELETE=*', /Fold_Case) EQ 1))[0]
        IF wh_delete NE -1 THEN delete[startval:endval] = Byte(StrTrim(StrMid(global_params[wh_delete], 7, 200), 2))
; Highlight
        wh_highlight = (where(StrMatch(global_params, 'HIGHLIGHT=*', /Fold_Case) EQ 1))[0]
        IF wh_highlight NE -1 THEN highlight[startval:endval] = Byte(StrTrim(StrMid(global_params[wh_highlight], 7, 200), 2))
; Rotate
        wh_rotate = (where(StrMatch(global_params, 'ROTATE=*', /Fold_Case) EQ 1))[0]
        IF wh_rotate NE -1 THEN rotate[startval:endval] = Byte(StrTrim(StrMid(global_params[wh_rotate], 7, 200), 2))
; Background
;        wh_background = (where(StrMatch(global_params, /Fold_Case), 'BACKGROUND=*') EQ 1))[0]
;        IF wh_background NE -1 THEN background[startval:endval] = Byte(StrTrim(StrMid(global_params[wh_background], 7, 200), 2))
    ENDFOR
ENDIF

; Remove lines defining global parameters
regions = regions[wh_not_global]
text = text[wh_not_global]
color = color[wh_not_global]
font = font[wh_not_global]
width = width[wh_not_global]
select = select[wh_not_global]
edit = edit[wh_not_global]
move = move[wh_not_global]
delete = delete[wh_not_global]
highlight = highlight[wh_not_global]
rotate = rotate[wh_not_global]
;background = background[wh_not_global]
composite_array = composite_array[wh_not_global]
n_regions = N_Elements(regions)
;---------------------------------------
; Parse out coordinates
; Not quite ready
coord_Type = StrArr(n_regions)
wh_galactic = where(StrMatch(regions, 'GALACTIC', /Fold_Case))
IF wh_galactic[0] NE -1 THEN coord_Type[wh_galactic] = 'Galactic'
wh_ecliptic = where(StrMatch(regions, 'ECLIPTIC', /Fold_Case))
IF wh_ecliptic[0] NE -1 THEN coord_Type[wh_ecliptic] = 'Ecliptic'
wh_image = where(StrMatch(regions, 'IMAGE', /Fold_Case))
IF wh_image[0] NE -1 THEN coord_Type[wh_image] = 'Image'
wh_physical = where(StrMatch(regions, 'PHYSICAL', /Fold_Case))
IF wh_physical[0] NE -1 THEN coord_Type[wh_physical] = 'Physical'
wh_b1950 = where(StrMatch(regions, 'FK4', /Fold_Case) + StrMatch(regions, 'B1950', /Fold_Case)) 
IF wh_b1950[0] NE -1 THEN coord_Type[wh_b1950] = 'B1950'
wh_j2000 = where(StrMatch(regions, 'FK5', /Fold_Case) + StrMatch(regions, 'J2000', /Fold_Case))
IF wh_j2000[0] NE -1 THEN coord_Type[wh_j2000] = 'J2000'
coord_type_old = coord_type

; Fill up array
current_coord = 'Image' ; By default
FOR i = 0, n_regions-1 DO BEGIN
    IF coord_Type[i] NE '' THEN current_coord = coord_Type[i]
    coord_Type[i] = current_coord
ENDFOR

; Remove these lines
no_coords = where(coord_type_old EQ '', cnt)
IF cnt GT 0 THEN BEGIN
    regions = regions[no_coords]
    text = text[no_coords]
    color = color[no_coords]
    font = font[no_coords]
    width = width[no_coords]
    select = select[no_coords]
    edit = edit[no_coords]
    delete = delete[no_coords]
    highlight = highlight[no_coords]
    move = move[no_coords]
    rotate = rotate[no_coords]
    source = source[no_coords]
    composite_array = composite_array[no_coords]
    n_regions = N_Elements(regions)
ENDIF ELSE RETURN
;---------------------------------------
; Parse out the regions
length = StrLen(regions)
num_pos = StrPos(regions, '#')
wh_pos = where(num_pos EQ -1)
IF wh_pos[0] NE -1 THEN num_pos[wh_pos] = length[wh_pos]
region_Type = StrArr(n_regions)

; Define composite array
; 0: not part of composite
; 1: part of composite
; 2: end of composite
IF N_Elements(regions) GE 3 THEN BEGIN
    IF composite_array[N_Elements(regions)-2] GE 1 THEN composite_array[N_Elements(regions)-1] = 2 ; If last region is a composite
    FOR i = 0, N_Elements(regions)-2 DO BEGIN
        IF composite_array[i] EQ 1 AND composite_array[i+1] EQ 0 THEN composite_array[i+1] = 2 ; Set to 1 if last (no || for these)
    ENDFOR
ENDIF

; Cycle through regions
FOR i = 0, n_regions - 1 DO BEGIN
    other_params = StrSplit(StrMid(regions[i], num_pos[i]+1, length[i]), ' ', /Extract, count = count)

; Extract the other parameters
    IF other_params[0] NE '' THEN BEGIN

; Deal with text first
        wh_text = (where(StrMatch(other_params, 'text=*', /Fold_Case) EQ 1))[0]
        IF wh_text NE -1 THEN BEGIN
            startpos = StrPos(regions[i], 'text=')
            startpos = StrPos(regions[i], '{', startpos)
            endpos = StrPos(regions[i], '}', startpos)
            text[i] = StrMid(regions[i], startpos+1, endpos-startpos-1)
        ENDIF

; Colors
        wh_color = (where(StrMatch(other_params, 'color=*', /Fold_Case) EQ 1))[0]
        IF wh_color NE -1 THEN color[i] = StrTrim(StrMid(other_params[wh_color], 6), 2)
; Width
        wh_width = (where(StrMatch(other_params, 'width=*', /Fold_Case) EQ 1))[0]
        IF wh_width NE -1 THEN width[i] = StrTrim(StrMid(other_params[wh_width], 6), 2)
; Font
        wh_font = (where(StrMatch(other_params, 'font=*', /Fold_Case) EQ 1))[0]
        IF wh_font NE -1 THEN font[i] = StrTrim(StrMid(other_params[wh_font], 7), 2)
; Select
        wh_select = (where(StrMatch(other_params, 'select=*', /Fold_Case) EQ 1))[0]
        IF wh_select NE -1 THEN select[i] = Byte(StrTrim(StrMid(other_params[wh_select], 7), 2))
; Edit
        wh_edit = (where(StrMatch(other_params, 'edit=*', /Fold_Case) EQ 1))[0]
        IF wh_edit NE -1 THEN edit[i] = Byte(StrTrim(StrMid(other_params[wh_edit], 5), 2))
; Move
        wh_move = (where(StrMatch(other_params, 'move=*', /Fold_Case) EQ 1))[0]
        IF wh_move NE -1 THEN move[i] = Byte(StrTrim(StrMid(other_params[wh_move], 5), 2))
; Rotate
        wh_rotate = (where(StrMatch(other_params, 'rotate=*', /Fold_Case) EQ 1))[0]
        IF wh_rotate NE -1 THEN rotate[i] = Byte(StrTrim(StrMid(other_params[wh_rotate], 7), 2))
; Delete
        wh_delete = (where(StrMatch(other_params, 'delete=*', /Fold_Case) EQ 1))[0]
        IF wh_delete NE -1 THEN delete[i] = Byte(StrTrim(StrMid(other_params[wh_delete], 7), 2))
; Background
        wh_background = (where(StrMatch(other_params, 'background', /Fold_Case) EQ 1))[0]
        IF wh_background NE -1 THEN source[i] = 0
    ENDIF

; Get the correct color index
    IF Obj_Valid(colors_obj) THEN color_new = colors_obj->ColorIndex(color[i]) ELSE color_new = 128

; Extract the real region parameters
    reg = RepStr(RepStr(regions[i], '(', ','), ')', ' ')
    reg = RepStr(reg, ' ', ',')
    region_type_break = (StrPos(reg, ','))[0]
    reg = StrMid(regions[i], region_type_break+1, num_pos[i]-region_type_break-1)
    reg = StrSplit(reg, ',', /Extract)
    n_params = N_Elements(reg)

; Change arcsec, arcmin
    wh_arcmin = where(StrPos(reg, "'") NE -1)
    IF wh_arcmin[0] NE -1 THEN reg[wh_arcmin] = reg[wh_arcmin] / 60.
    wh_arcsec = where(StrPos(reg, '"') NE -1)
    IF wh_arcsec[0] NE -1 THEN reg[wh_arcsec] = reg[wh_arcsec] / 3600.
    reg = float(reg)

; Region types
    region_Type[i] = StrMid(regions[i], 0, region_type_break)

; Determine which regions are excluded
    wh_exclude = where(StrMid(region_Type, 0, 1) EQ '-')
    IF wh_exclude[0] NE -1 THEN exclude[wh_exclude] = 1

; Remove plus and minus signs
    region_Type = repstr(region_Type, '-', '')
    region_Type = repstr(region_Type, '+', '')

; Find the indices
    type = 2
    angle = 0
    CASE StrUpCase(region_Type[i]) OF
        'TEXT': BEGIN
            data = [reg[0], reg[1]]
            angle = reg[2]
            type = 0
        END
        'BOX': BEGIN
            data = Kang_Box(reg[0], reg[1], reg[2], reg[3], reg[4])
            angle = reg[4]
        END
        'ELLIPSE': BEGIN
            data = Kang_Ellipse(reg[0], reg[1], reg[2], reg[3], reg[4])
            angle = reg[4]
        END
        'CIRCLE': data = Kang_Circle(reg[0], reg[1], reg[2])
        'CROSS': BEGIN
            data = [[reg[0]+reg[2], reg[1]], $
                    [reg[0]-reg[2], reg[1]], $
                    [reg[0], reg[1]], $
                    [reg[0], reg[1]+reg[2]], $
                    [reg[0], reg[1]-reg[2]], $
                    [reg[0], reg[1]]]
            type = 1
        END
        'LINE': BEGIN
            data = [[reg[0], reg[1]], [reg[2], reg[3]]]
            type = 1
        END
        'POLYGON': BEGIN
; Find the x and y points
            n_points = N_Elements(reg) /2
            data = reform(reg[0:n_points*2-1], 2, n_points)
            params = reg
        END
        'COMPOSITE': BEGIN
            regiongroup_obj = Obj_New('Kang_RegionGroup', angle = angle, color = color_new, cname = color[i], $
                                      thick=width[i], interior = exclude[i], image_obj = self.image_obj, $
                                      regiontype = 'Composite', text = text[i], source = source[i], $
                                      linestyle = 0, type = type, nostats = nostats)
            composite_array[i] = 3
        END
    ENDCASE

    IF composite_array[i] NE 3 THEN BEGIN
; Convert from data to image coordinates if necessary
        IF Obj_Valid(self.image_obj) THEN BEGIN
            data = self.image_obj->Convert_Coord(data[0, *], data[1, *], old_coords = coord_type[i], new_coords = 'Image')
        ENDIF

; Create object
        region_obj = Obj_New('Kang_Region', data, params = reg, angle = angle, $
                             color = color_new, cname = color[i], thick=width[i], interior = exclude[i], $
                             image_obj = self.image_obj, regiontype = region_type[i], text = text[i], $
                             source = source[i], linestyle = 0, type = type, nostats = nostats)
    ENDIF

; Add region objects to correct container
    CASE composite_array[i] OF
        0: self->Add, region_obj
        1: regiongroup_obj->Add, region_obj
        2: BEGIN
            regiongroup_obj->Add, region_obj
            regiongroup_obj->ComputeGeometry, self.image_obj
            self->Add, regiongroup_obj
        END
        ELSE:
    ENDCASE
ENDFOR

; Change selected region
;self->Select, /Last

END; Kang_Region_Container::Load------------------------------------------------------------


PRO Kang_Region_Container::Save, filename
; Saves regions in DS9 format

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   free_lun, lun
   RETURN
ENDIF

; Open file
openw, lun, filename, /Get_Lun

; Print the coordinate type
IF Obj_Valid(self.image_obj) THEN self.image_obj->GetProperty, native_coords = native_coords $
  ELSE native_coords = 'Image'
printf, lun, native_coords

; Get info
self->GetProperty, regiontype = regiontype, regiontext = text
objrefs = self->Get(/All)
regiontype = RepStr(regiontype, 'Threshold Image', 'Threshold') ; Treat these the same
text = repstr(text, 'Freehand', 'Polygon') ; Change these to polygons

; This loop neccessitated by threshold and composite regions
FOR i = 0, self.n_regions-1 DO BEGIN

; Threshold regions need to be converted to polygons
    CASE regiontype[i] OF
        'Threshold': BEGIN

; Cycle through regions
            IF obj_class(objrefs[i]) NE 'KANG_REGIONGROUP' THEN BEGIN

; Single threshold region
                objrefs[i]->Getproperty, data=data, interior = interior, composite = composite
                IF Obj_Valid(self.image) THEN data = self.image_obj->Convert_Coord(data[0, *], data[1, *], $
                                                                                    old_coord = 'Image')
                text[i] = 'Polygon(' + StrCompress(StrJoin(data, ',', /Single)) + ')'
                IF interior THEN text[i] = '-' + text[i]
                IF composite THEN text[i] = '# ' + text[i] + ' ||'
                PrintF, lun, text[i]
            ENDIF ELSE BEGIN

; Threshold region with "holes".  Create as composite polygon region
; Print initial composite string
                PrintF, lun, 'Composite( 0.00000, 0.00000, 0.0000)' + ' ||'

; Print data for individual polygons
                threshold_refs = objrefs[i]->Get(/All, count = n_threshold_regions)
                FOR j = 0, n_threshold_regions-1 DO BEGIN
                    threshold_refs[j]->Getproperty, data=data, interior = interior
                    IF Obj_Valid(self.image_obj) THEN data = self.image_obj->Convert_Coord(data[0, *], data[1, *], $
                                                                                        old_coord = 'Image')
                    threshold_text = 'Polygon(' + StrCompress(StrJoin(data, ',', /Single)) + ')'
                    IF interior THEN threshold_text = '-' + text[i]
                    IF j NE n_threshold_regions-1 THEN threshold_text = threshold_text + ' ||'
                    PrintF, lun, threshold_text
                ENDFOR
            ENDELSE
        END

        'Composite': BEGIN
; Account for extra parameters at end of region string
            IF StrPos(text[i], '#') EQ -1 THEN PrintF, lun, text[i] + ' ||' ELSE PrintF, lun, repstr(text[i], '#', '|| #')

; Get region text
            objrefs[i]->GetProperty, alltext = alltext, n_regions = n_composite_regions

; Cycle though and add "||"
            FOR j = 0, n_composite_regions-2 DO $ ; Don't do the last one
                    IF StrPos(alltext[j], '#') EQ -1 THEN PrintF, lun, alltext[j] + ' ||' ELSE $
                    PrintF, lun, repstr(alltext[j], '#', '|| #')
            PrintF, lun, alltext[n_composite_regions-1]
        END

; Non-threshold regions
        ELSE: PrintF, lun, text
    ENDCASE
ENDFOR
free_lun, lun

END; Kang_Region_Container::Save-----------------------------------------------------------


PRO Kang_Region_Container::Replace, region, position=position
; Changes the data values for a region.

IF N_Elements(position) EQ 0 THEN position = max(*self.selected_regions)
IF position[0] EQ -1 THEN position = 0

; Get region properties out, delete old region
self->GetProperty, thick = thick, linestyle = linestyle, color = color, cname = cname, position = position, $
                   interior = interior, source = source, polygon = polygon
self.region->Remove, position = position

; Set properties for new region
self.region->Add, region, position = position
self->SetProperty, cname = cname, width = thick, exclude = interior, source = source, polygon = polygon

END;Kang_Region_Container::Replace---------------------------------------------------


FUNCTION Kang_Region_Container::Overlap, position = position
; Finds the indices of overlap between two regions

IF N_Elements(position) EQ 0 THEN position = *self.selected_regions
IF position[0] EQ -1 THEN RETURN, -1

; Image dimensions
self.image_obj->GetProperty, pix_limits = pix_limits
dimensions = [pix_limits[1] + 1, pix_limits[3] + 1]

; Find overlap one by one
obj = self->Get(position = position[0])
indices = obj->Find_Indices(dimensions = dimensions)
IF N_Elements(position) EQ 1 THEN RETURN, indices

FOR i = 1, N_Elements(position)-1 DO BEGIN 
    obj = self->Get(position = position[i])
    indices2 = obj->Find_Indices(dimensions = dimensions)
    indices = setIntersection(indices, indices2)
ENDFOR

; Find outline
IF indices[0] EQ -1 THEN RETURN, -1
pix_data = Find_Boundary(indices, XSize=dimensions[0], YSize=dimensions[1])

; Convert
data = self.image_obj->Convert_Coord(pix_data, old_coords = 'Image')

RETURN, data
END; Kang_Region_Container::Overlap-------------------------------------------------------


PRO Kang_Region_Container::Add, region, position = position
; Adds a region to the container

self.region->Add, region, position = position
++self.n_regions

END; Kang_Region_Container::Add-------------------------------------------------------


PRO Kang_Region_Container::Delete, position = position, All=All, Destroy = Destroy
; Removes the selected objects at the given position - or all if that
; keyword is set
; I think we need to delete the objects to clear up the memory.

IF self.n_regions EQ 0 THEN RETURN

; Remove all
IF Keyword_Set(All) THEN BEGIN
    IF Keyword_Set(destroy) THEN BEGIN
        objs = self->Get(/All)
        Obj_Destroy, objs
    ENDIF
    self.region->Remove, /All
    self->Select, /None
    self.n_regions = 0
    RETURN
ENDIF

; Default to deleting all selected regions
n_pos = N_Elements(position)
IF n_pos EQ 0 THEN position = *self.selected_regions
n_pos = N_Elements(position)

; Do nothing if there are no regions selected
IF (position)[0] NE -1 THEN BEGIN

; Position can be a vector
; Need to go backwards since otherwise position is off as the elements
; are removed
    IF Keyword_Set(destroy) THEN BEGIN
        objs = self->Get(position = position)
        Obj_Destroy, objs
    ENDIF
    FOR i = n_pos-1, 0, -1 DO self.region->Remove, position = position[i]
        
; Update which region is selected - find intersection of the two  arrays
    IF n_pos GT 1 THEN bad = where(histogram(position, min = 0, max = self.n_regions-1), complement = good) $
    ELSE bad = where(lindgen(self.n_regions) EQ position[0], complement = good)

; Update n_regions
    self.n_regions = self.n_regions - n_pos

; User deleted all regions
    IF good[0] EQ -1 THEN self->Select, /None ELSE self->Select, self.n_regions-1
ENDIF

END;Kang_Region_Container::Delete----------------------------------------------------


PRO Kang_Region_Container::Rotate, angle, position = position
; Rotates the region about its centroid using the built in IDL routine

n_pos = N_Elements(position)
IF n_pos EQ 0 THEN position = (*self.selected_regions)[0] ELSE position = position[0]
obj = self->Get(position = position)
obj->Rotate, angle, image_obj = self.image_obj

END; Kang_Region_Container::Rotate---------------------------------------------------


PRO Kang_Region_Container::Scale, scale, position = position

IF N_Elements(position) EQ 0 THEN position = *self.selected_regions
n_pos = N_Elements(position)

; Cycle through selected regions, using IDL's built in scale function
objs = self->Get(position = position)
FOR i = 0, n_pos-1 DO objs[i]->scale, translation, image_obj = self.image_obj

self->Scale, scale
END; Kang_Region::Scale--------------------------------------------------


PRO Kang_Region_Container::Translate, translation, position = position
; Move the region up, down left or right

IF N_Elements(position) EQ 0 THEN position = *self.selected_regions
n_pos = N_Elements(position)

; Cycle through selected regions, using IDL's built in translate function
objs = self->Get(position = position)
FOR i = 0, n_pos-1 DO objs[i]->translate, translation, image_obj = self.image_obj

END;Kang_Region_Container::Translate-------------------------------------------------


FUNCTION Kang_Region_Container::ComputeMask, position=position, weighted = weighted
; Computes a mask for the selected regions

; Find dimensions
self.image_obj->GetProperty, dimensions = dimensions

; Create position array
n_pos = N_Elements(position)
IF n_pos EQ 0 THEN BEGIN
    IF (*self.selected_regions)[0] NE -1 THEN BEGIN
        position = *self.selected_regions
        n_pos = N_Elements(position)
    ENDIF ELSE RETURN, bytarr(dimensions)
ENDIF

mask = bytarr(dimensions)
FOR i = 0, n_pos-1 DO BEGIN
    obj = self->Get(position = position[i])
    mask = obj->ComputeMask(dimensions = dimensions, mask_in = mask, weighted = weighted)
ENDFOR

RETURN, mask
END; Kang_Region_Container::ComputeMask----------------------------------------------


FUNCTION Kang_Region_Container::Find_Indices, position = position
; Finds the indices for the selected group
; I'm sure this has a faster solution

indices = -1
n_pos = N_Elements(position)
IF n_pos EQ 0 THEN BEGIN
    position = *self.selected_regions
    n_pos = N_Elements(position)
ENDIF

; Find image dimensions
self.image_obj->GetProperty, pix_limits = pix_limits
dimensions = [pix_limits[1] + 1, pix_limits[3] + 1]

; Remove holes
FOR i = 0, n_pos-1 DO BEGIN
; Get data for region
    obj = self->Get(position = position[i])
    obj->GetProperty, interior = interior

; Calculate indices
    indices_new = obj->Find_Indices(dimensions = dimensions)

; Interior regions - remove from indices
    IF interior THEN BEGIN

; Indices is undefined - remove indices
        IF indices[0] NE -1 THEN BEGIN
            keep = where(histogram(indices, OMIN=om) GT 0 AND histogram(indices_new, MIN=om) EQ 0)+om
            IF keep[0] NE -1 THEN indices = indices[keep] ELSE indices = -1
        ENDIF
    ENDIF ELSE BEGIN
; Not interior regions - add to indices
        IF indices[0] EQ -1 THEN indices = indices_new ELSE BEGIN
            array = [indices, indices_new]
            indices = array[Uniq(array, Sort(array))] ; Find uniq values
        ENDELSE
    ENDELSE
ENDFOR

RETURN, indices

;mask = self->ComputeMask(position = position)
;RETURN, where(mask EQ 255B)
END; Kang_Region_Container::Find_Indices---------------------------------------------


PRO Kang_Region_Container::Fit_Ellipse, position = position, center = center, orientation = orientation, semiaxes = semiaxes, $
  weighted = weighted
; Fits an ellipse to the specified region

IF N_Elements(position) EQ 0 THEN position = max(*self.selected_regions) ELSE position = max(position)
IF position[0] EQ -1 THEN RETURN

;IF Keyword_Set(weighted) AND Obj_Valid(self.image_obj) THEN BEGIN
; Get indices
;    indices = self->Find_Indices(position = position)

;    weights = self.image->Values(indices)

; Image dimensions
;    self.image_obj->GetProperty, pix_limits = pix_limits
;    dimensions = [pix_limits[1] + 1, pix_limits[3] + 1]
;ENDIF
    
; Do fitting
;ellipse = self.regions->Fit_Ellipse(indices, XSize=dimensions[0], YSize=dimensions[1], center = center, orientation = orientation, $
;                                    semiaxes = semiaxes)

;RETURN, ellipse

; Get region, data
oregion = self->Get(position = position)
oregion->GetProperty, data = data
data = self.image_obj->Convert_Coord(data, old_coord = 'Image')

; Fit
help, data
result = MPFitEllipse(reform(data[0, *]), reform(data[1, *]), /Tilt, /quiet)
;      P[0]   Ellipse semi axis 1
;      P[1]   Ellipse semi axis 2   ( = P[0] if CIRCLE keyword set)
;      P[2]   Ellipse center - x value
;      P[3]   Ellipse center - y value
;      P[4]   Ellipse rotation angle (radians) if TILT keyword set

; Parse out variables
semiaxes = result[0:1]
center = result[2:3]
orientation = result[4] * !radeg

END; Kang_Region_Container::Fit_Ellipse-------------------------------------------------


PRO Kang_Region_Container::Draw, position=position
; Draws the regions by invoking the draw method for each region.

IF self.n_regions EQ 0 THEN RETURN

; Determine the positions to draw
n_pos = N_Elements(position)
IF n_pos EQ 0 THEN BEGIN
    position = lindgen(self.n_regions)
    n_pos = self.n_regions
ENDIF

; I don't think this is necessary
; Find regions to plot
;self.image_obj->GetProperty, pix_newlimits = pix_newlimits
;position = self->ContainsRegions(pix_newlimits[0], pix_newlimits[2], pix_newlimits[1], pix_newlimits[3], /AnyPart)
;n_pos = N_Elements(position)
;IF n_pos EQ -1 THEN RETURN

; Loop through all positions, drawing    
objs = self->Get(position = position)
FOR i = 0, n_pos-1L DO objs[i]->Draw

; Draw squares on selected region
IF (*self.selected_regions)[0] NE -1 AND !D.Name NE 'PS' THEN BEGIN
    objs = self->Get(Count = n_regions)
    FOR i = 0, n_regions-1 DO BEGIN
        objs[i]->GetProperty, xrange = xrange, yrange = yrange, color = color, source = source, regiontype = regiontype

; Draw source boxes solid, background boxes open
        IF regiontype NE 'Text' THEN BEGIN
            IF source THEN BEGIN
                plots, [xrange[0], xrange[0], xrange[1], xrange[1]], [yrange[0], yrange[1], yrange[1], yrange[0]], psym = symcat(15), $
                       color = color, noclip = 0
            ENDIF ELSE BEGIN
                plots, [xrange[0], xrange[0], xrange[1], xrange[1]], [yrange[0], yrange[1], yrange[1], yrange[0]], psym = symcat(6), $
                       color = color, noclip = 0
            ENDELSE
        ENDIF
    ENDFOR
ENDIF

END;Kang_Region_Container::Draw------------------------------------------------------


FUNCTION Kang_Region_Container::Contains_Points, x, y, count = count
; Determine which regions contain the x,y pair

IF self.n_regions EQ 0 THEN RETURN, -1

; Get region object references
n_points = N_Elements(x)
hits = intArr(self.n_regions, n_points)
regions = self->Get(/All)

; This is a built in method to idlanroi
FOR i = 0, N_Elements(regions)-1 DO hits[i, *] =  regions[i]->ContainsPoints(x, y)

;good_hits = where(hits GE 1, count)
count = total(hits)

RETURN, hits;good_hits
END;Kang_Region_Container::Contains_Points--------------------------------------------


FUNCTION Kang_Region_Container::ContainsRegions, x1, y1, x2, y2, AnyPart = anypart, Position = position
; Returns the indices of the regions that fall within the boundaries
; The anypart keyword returns the indices of the regions that have any
; part within the specified boundary.

IF self.n_regions EQ 0 THEN RETURN, -1

; Sort input variables
xlow = x1 < x2
xhigh = x1 > x2
ylow = y1 < y2
yhigh = y1 > y2

; Get region object references
hits = intArr(self.n_regions)
IF N_Elements(position) EQ 0 THEN objs = self->Get(/All, Count = n_reg) $
  ELSE objs = self->Get(position = position, Count = n_reg)

; Sort though all regions to find the lowest and highest points
xmin = fltarr(n_reg)
xmax = fltarr(n_reg)
ymin = fltarr(n_reg)
ymax = fltarr(n_reg)
FOR i = 0, n_reg-1 DO BEGIN
    objs[i]->GetProperty, xrange = xrange, yrange = yrange
    xmin[i] = xrange[0]
    xmax[i] = xrange[1]
    ymin[i] = yrange[0]
    ymax[i] = yrange[1]
ENDFOR

; Determine the regions that are inside the box
IF Keyword_Set(anypart) THEN BEGIN
; Any part of the region is within the drawing window
    hits = where((xmin GT xlow AND xmin LT xhigh AND ymin GT ylow AND ymin LT yhigh) OR $ ; Lower left corner
                 (xmin GT xlow AND xmin LT xhigh AND ymax GT ylow AND ymax LT yhigh) OR $ ; Lower right corner
                 (xmax GT xlow AND xmax LT xhigh AND ymin GT ylow AND ymin LT yhigh) OR $ ; Upper left corner
                 (xmax GT xlow AND xmax LT xhigh AND ymax GT ylow AND ymax LT yhigh) OR $ ; Upper right corner
                 (xmin LT xlow AND xmax GT xhigh AND (ymin GT ylow AND ymin LT yhigh) OR (ymax GT ylow AND ymax LT yhigh)) OR $ ; X spans
                 (ymin LT ylow AND ymax GT yhigh AND (xmin GT xlow AND xmin LT xhigh) OR (xmax GT xlow AND xmax LT xhigh))) ; Y spans
ENDIF ELSE BEGIN
; All parts of the region are within the drawing window
    hits = where(xlow LT xmin AND xhigh GT xmax AND ylow LT ymin AND yhigh GT ymax)
ENDELSE

RETURN, hits
END;Kang_Region_Container::ContainsRegions-------------------------------------------


PRO Kang_Region_Container::Cleanup
; Removes object references and pointers

Obj_Destroy, self.region
Ptr_Free, self.selected_regions

END; Kang_Region_Container::Cleanup--------------------------------------------------


PRO Kang_Region_Container__Define

; Define self structure
struct = {KANG_REGION_CONTAINER, $
          image_obj:Obj_New(), $ ; Object reference for calculating the region statistics
          region:Obj_New(), $   ; Container to hold the individual regions
          n_regions:0L, $       ; Number of regions
          selected_regions:Ptr_New() $ ; Pointer of indices
         }

END ;Kang_Region_Container__Define---------------------------------------------------
