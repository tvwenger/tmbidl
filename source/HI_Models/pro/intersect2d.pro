pro intersect2d,array1,array2,help=help,inter=inter,thresh=thresh
;+
; NAME:
;       intersect2d
;
;            ==============================================
;            Syntax: intersect2d,array1,array2,help=help
;            ==============================================
;
;   intersect2d  procedure to 
;   -----------  determine where two curves defined in array1
;                and array2 intersect
;   
;   INPUTS       array1 and array2 are input curves. They should
;                be two-dimensional, but not necessarily the same
;                size
;
;   OUTPUTS      a 2D array of intersection points
;
;   KEYWORDS:
;              HELP - get syntax help
;              INTER - points of intersection
;              THRESH - threshold to determine if minimum is an
;                       intersection. default = 0.1
;
; MODIFICATION HISTORY:
;
; V1.0 TVW 20jan2013
;      tvw 23jan2013 - added thresh
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers
;
if keyword_set(help) then begin
   get_help,'intersect2d'
   return
endif
;
if ~keyword_set(thresh) then thresh=0.1
;
inter=0
;
;count=0
for i=0,n_elements(array1[*,0])-1 do begin  
   cldistind=closest2d(array2,array1[i,*],cl=cldist)
   ; these are the distances from each point in array1 to the
   ; closest point in array1
   if i eq 0 then begin
      dist=cldist 
      ;distind=cldistind
   endif else begin
      dist=[dist,cldist]
      ;distind=[distind,cldistind]
   endelse
endfor
;
; now, go down the array of dist and find the local minima
; these indicies represent the points in array1
foundmin=0
mins=-1
for i=0,n_elements(dist)-2 do begin
   if dist[i+1] lt dist[i] then begin
      foundmin=0
      continue 
   endif else if foundmin eq 0 then begin
      foundmin=1
      ;print,dist[i]
      if dist[i] gt thresh then continue
      if mins[0] eq -1 then mins=i else mins=[mins,i]
   endif
endfor
;
; now, assign values from array1
;print,mins
;help,array1
if mins[0] ne -1 then begin
   ;print,array1[mins,*]
   inter=transpose(array1[mins,*])
endif
;
return
end
