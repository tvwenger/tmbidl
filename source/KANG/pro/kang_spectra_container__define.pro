FUNCTION Kang_Spectra_Container::Init
; Initializes the object.

self.spectra = Obj_New('IDL_Container')
self.plot_spectrum = Ptr_New([-1])
self.current_spectrum = -1

IF N_Elements(draw_flags) NE 0 THEN self.draw_flags = 0 > draw_flags < 1 ELSE self.draw_flags = 1B
IF N_Elements(flag) NE 0 THEN $
  IF Ptr_Valid(self.flags) EQ 0 THEN self.flags = Ptr_New(flag) ELSE *self.flags = [*self.flags, flag]

RETURN, 1
END; Kang_Spectra_Container::Init-----------------------------------------------------


PRO Kang_Spectra_Container::Add, spectrum, position = position
; Adds a spectra to the container

self.spectra->Add, spectrum, position = position
IF self.n_spectra EQ 0 THEN *self.plot_spectrum = 0 ELSE *self.plot_spectrum = [*self.plot_spectrum, 1]
++self.n_spectra
self.current_spectrum = self.n_spectra - 1

END;Kang_Spectra_Container::Add-------------------------------------------------------


PRO Kang_Spectra_Container::Replace, spectrum, position = position
; Replaces current spectrum with new one

self.spectra->Remove, position = self.current_spectrum > 0
self.spectra->Add, spectrum, position = self.current_spectrum > 0
IF self.n_spectra EQ 0 THEN BEGIN
    *self.plot_spectrum = [1]
    self.n_spectra = 1
ENDIF ELSE *self.plot_spectrum = [*self.plot_spectrum, 1]
self.current_spectrum = self.n_spectra - 1

END;Kang_Spectra_Container::Replace-------------------------------------------------------


PRO Kang_Spectra_Container::Draw

; Determine which spectra should be plotted
good_spectra = where(*self.plot_spectrum EQ 1)
n_goodspectra = Total(good_spectra) + 1

; Find the first spectrum
IF (*self.plot_spectrum)[self.current_spectrum] EQ 0 THEN first = min(good_spectra) $
ELSE first = self.current_spectrum

IF n_goodspectra GE 1 THEN BEGIN
; Get spectrum
    spec_obj = self.spectra->get(position = first)

; Plot spectrum
    spec_obj->draw

; These do have the overplot keyword
    IF n_goodspectra GT 1 THEN BEGIN
        
; Cycle though the spectra and plot if they exist
        FOR i = 0, self.n_spectra-1 DO BEGIN
            IF (*self.plot_spectrum)[i] THEN BEGIN
                spec_obj = self.spectra->get(position = i)
                spec_obj->draw, /overplot
            ENDIF
        ENDFOR
    ENDIF
ENDIF ELSE IF !D.Name EQ 'WIN' OR !D.Name EQ 'X' THEN erase

; Plot the flags
IF Ptr_Valid(self.flags) AND self.draw_flags THEN BEGIN
    n_flags = N_Elements(*self.flags)
    FOR i = 0, n_flags-1 DO BEGIN
        oplot, $
          [(*self.flags)[i], (*self.flags)[i]], $
          [!y.crange[0], !y.crange[1]], $
          color = (*self.flagColors)[i]
    ENDFOR
ENDIF

END; Kang_Spectra_Container::Draw-----------------------------------------------------


PRO Kang_Spectra_Container::Flag, velocity, color = color, cname = cname

; Create new pointer or add to array
IF ~Ptr_Valid(self.flags) THEN BEGIN
    self.flags = Ptr_New([velocity]) 
    self.flagColors = Ptr_New(replicate(240, N_Elements(velocity))) ; Defaults
    self.flagCNames = Ptr_New(replicate('Red', N_Elements(velocity)))
ENDIF ELSE BEGIN
    *self.flags = [reform(*self.flags), velocity] ; Reform statement allows array concatenation
ENDELSE

; Only unique elements
uniq_flags = uniq(*self.flags)
*self.flags = (*self.flags)[uniq_flags]

IF N_Elements(color) NE 0 THEN BEGIN
; Replicate colors as necessary
    color = color[lindgen(N_Elements(velocity))]
    *self.flagColors = [reform(*self.flagColors), color]
    *self.flagColors = (*self.flagColors)[uniq_flags]
ENDIF
IF N_Elements(cname) NE 0 THEN BEGIN
    cname = cname[lindgen(N_Elements(velocity))]
    *self.flagCNames = [reform(*self.flagCNames), cname]
    *self.flagCNames = (*self.flagCNames)[uniq_flags]
ENDIF

END; Kang_Spectra_Container::Flag----------------------------------------


FUNCTION Kang_Spectra_Container::Get, position = position, All=all
; Returns the object references of interest

; Use current spectrum if nothing unput
IF N_Elements(position) EQ 0 THEN position = self.current_spectrum

IF position[0] NE -1 THEN RETURN, self.spectra->Get(position = position, All = All) $
  ELSE RETURN, -1

END; Kang_Spectra_Container::Get------------------------------------------------------


PRO Kang_Spectra_Container::GetProperty, $
  current_spectrum = current_spectrum, $
  plot_spectrum = plot_spectrum, $
  position = position, $
  xvals = xvals, $
  yvals = yvals

IF Arg_Present(plot_spectrum) THEN plot_spectrum = *self.plot_spectrum
IF Arg_Present(current_spectrum) THEN current_spectrum = self.current_spectrum

IF Arg_Present(xvals) OR Arg_Present(yvals) THEN BEGIN
    IF N_Elements(position) EQ 0 THEN position = self.current_spectrum
    spec_obj = self.spectra->Get(position = position[0])
    spec_obj->GetProperty, xvals = xvals, yvals = yvals
ENDIF

END; Kang_Spectra_Container--------------------------------------------------------


PRO Kang_Spectra_Container::Remove, position = position, All=All
; Removes the selected objects at the given position - or all if that
; keyword is set
; I think we need to delete the objects to clear up the memory.

IF self.n_spectra EQ 0 THEN RETURN

; Remove all
IF Keyword_Set(All) THEN BEGIN
    objs = self.spectra->Get(/All)
    Obj_Destroy, objs
    self.spectra->Remove, /All
    self.current_spectrum = -1
    self.n_spectra = 0
    RETURN
ENDIF

; Default to deleting the selected spectrum
n_pos = N_Elements(position)
IF n_pos EQ 0 THEN position = self.current_spectrum
n_pos = N_Elements(position)

; Do nothing if there are no spectra selected
IF (position)[0] NE -1 THEN BEGIN

; Position can be a vector
; Need to go backwards since otherwise position is off as the elements
; are removed
    objs = self->Get(position = position)
    Obj_Destroy, objs
    FOR i = n_pos-1, 0, -1 DO self.spectra->Remove, position = position[i]
        
; Update which spectra is selected - find intersection of the two  arrays
    IF n_pos GT 1 THEN bad = where(histogram(position, min = 0, max = self.n_spectra-1), complement = good) $
    ELSE bad = where(lindgen(self.n_spectra) EQ position[0], complement = good)

; Update n_spectra
    self.n_spectra = self.n_spectra - n_pos

; User deleted all spectra
    IF good[0] EQ -1 THEN self.current_spectrum = -1 ELSE self.current_spectrum = 0
ENDIF

END;Kang_Spectra_Container::Remove----------------------------------------------------


PRO Kang_Spectra_Container::UnFlag, velocity, all = all

; Pointer has already been initialized - we can proceed
IF Ptr_Valid(self.flags) THEN BEGIN

; Remove elements from array
    IF Keyword_Set(all) THEN Ptr_Free, self.flags ELSE BEGIN
        IF N_Elements(self.flags) GT 1 THEN BEGIN
            good = where(*self.flags NE velocity)
            *self.flags = (*self.flags)[good]

; Remove pointer
        ENDIF ELSE Ptr_Free, self.flags
    ENDELSE
ENDIF

END; Kang_Spectra_Container::UnFlag--------------------------------------


PRO Kang_Spectra_Container::Cleanup
; Removes object references and pointers

Obj_Destroy, self.spectra
Ptr_Free, self.plot_spectrum


END; Kang_Spectra_Container::Cleanup--------------------------------------------------


PRO Kang_Spectra_Container__Define

; Define self structure
struct = {KANG_SPECTRA_CONTAINER, $
          current_spectrum:-1, $ ; Index of current spectrum
          draw_flags:0B, $      ;Boolean for whether to draw flags
          flags:Ptr_New(), $    ; Velocity flag velocities
          flagColors:Ptr_New(), $ ;Velocity flag color indices
          flagCNames:Ptr_New(), $ ;Velocity flag color names
          spectra:Obj_New(), $  ; Container to hold the individual spectra
          n_spectra:0L, $       ; Number of spectra
          plot_Spectrum:Ptr_New() $ ; Pointer of indices
         }

END ;Kang_Spectra_Container__Define---------------------------------------------------
