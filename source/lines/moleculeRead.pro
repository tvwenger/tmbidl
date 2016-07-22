;+
;
;   moleculeRead.pro   Reads the list of molecules from a file.  W
;   -------
; HISTORY
; 04APR02 GIL initial version
;
;-
pro moleculeRead
; moleculeRead() reads in the line frequencies and writes to a
; structure.  The procedure molecule will flag selected molecules 

on_error,!debug ? 0 : 2

  if (!nMol gt 0) then return

  fname='/home/astro-util/idlData/nistLineTable.txt
  ;
  maxl=3000
  ;now define for molecules function
  record = {type:' ', freq:1234.567, formula:'HCCCCCCCCCCCN'}
  defsysv,'!molecules',replicate(record,maxl)

  ;- Open input file
  openr, lun, fname, /get_lun

  ;- Define record structure and create array
  fmt = '(a1,1x,f11.4,4x,a13)'

  ;- Read records until end-of-file reached
  nMol = 0L
  nShow = 0L
  recnum = 0L
  while (eof(lun) ne 1 && nMol lt maxl) do begin
    on_ioerror, bad_rec
    error = 1
    readf, lun, record, format=fmt
    error = 0
;  print,'type=', record.type,', freq=',record.freq,',
;  formula=',record.formula
    !molecules[nMol] = record
    nMol = nMol+1 
;- Check for bad input record
   bad_rec:
     recnum = recnum + 1
  endwhile

  close,lun 

  !nMol = nMol
  print,'moleculeRead: read ',nMol, ' molecule frequencies'
  print,'moleculeRead: ',!molecules[nMol-1].freq,' ',!molecules[nMol-1].formula
;
return
end
