;+
;
;   molecule.pro   Flag molecular lines 
;   -------        for dn=0 to nMax, plus show stronger H, He lines
;
;                  Written by G. Langston March 2004
;-
pro molecule,nMax
;
on_error,!debug ? 0 : 2
  if keyword_set(nMax) then nMax = nMax else nMax = 4
  if nMax lt 1 then nMax = 1

  xmin = !x.crange[0]         ; check for lines in range
  xmax = !x.crange[1]
  ymin = !y.crange[0]
  ymax = !y.crange[1]
  yrange = ymax-ymin
  yincr=0.025*yrange
  yOffset= -4.*yincr
  nShow = 0
  ;
  moleculeRead                ; read in molecule frequencies
  ;
  for i = 0,!nMol do begin

    if ((!molecules[i].freq gt xmin)&&(!molecules[i].freq lt xmax)) then begin
      textLabel  = textoidl( 'U')
      if (!molecules[i].type ne 'U') then begin
        textLabel = textoidl( strtrim(string( !molecules[i].formula)))
      endif
      flg_id, !molecules[i].freq, textLabel, !orange, yOffset
      nShow = nShow + 1
      yOffset = yOffset + yincr
      if (yOffset ge -yincr) then yOffset = -4.*yincr
    endif
    ; if past both x end points, exit
    if ((!molecules[i].freq gt xmin)&&(!molecules[i].freq gt xmax)) then return
  endfor

;
return
end
