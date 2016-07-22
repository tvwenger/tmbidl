;+
; NAME:
;   MGH_POLYFILLG
;
; DESCRIPTION:
;    Given a 2-D polygon and a rectangular grid, this function returns
;    an array indicating the fraction (optionally the area) of each
;    pixel inside the polygon.
;
; CALLING SEQUENCE:
;    result = mgh_polyfillg(poly)
;
; POSITiONAL PARAMETERS:
;   poly (input, numeric [2,n] array)
;     The polygon
;
; KEYWORD PARAMETERS:
;    XOUT, YOUT (input, 1-D or 2-D numeric arrays)
;      Vertex positions for the grid.
;
; RETURN VALUE:
;    The function returns a 2D array representing the fraction
;    (optionally the area) of overlap between each pixel and the polygon.
;
; MODIFICATION HISTORY:
;    Mark Hadfield, 2002-08:
;      Written
;-
function mgh_polyfillg, poly, $
     AREA=area, DELTA=delta, DIMENSION=dimension, START=start, XOUT=xout, YOUT=yout

   compile_opt DEFINT32
   compile_opt STRICTARR
   compile_opt STRICTARRSUBS
   compile_opt LOGICAL_PREDICATE

   ;; Polygon bounds for future reference

   xmin = min(poly[0,*], MAX=xmax)
   ymin = min(poly[1,*], MAX=ymax)

   ;; Process output-grid keywords and set up result array

   if n_elements(xout)*n_elements(yout) eq 0 then begin

      if n_elements(dimension) eq 0 then dimension = 11
      if n_elements(start) eq 0 then start = [xmin,ymin]
      if n_elements(delta) eq 0 then $
           delta = [xmax-xmin,ymax-ymin]/(dimension-1)

      if n_elements(dimension) eq 1 then dimension = [dimension,dimension]
      if n_elements(start) eq 1 then start = [start,start]
      if n_elements(delta) eq 1 then delta = [delta,delta]

      if n_elements(xout) eq 0 then xout = start[0] + delta[0]*lindgen(dimension[0])
      if n_elements(yout) eq 0 then yout = start[1] + delta[1]*lindgen(dimension[1])

      nout = n0*n1
      dout = dimension

   endif

   ndx = size(xout, /N_DIMENSIONS)
   ndy = size(yout, /N_DIMENSIONS)

   if ndx ne ndy then message, 'X & Y output grids do not agree'

   xy2d = (ndx eq 2)

   case xy2d of

      0: begin

         n0 = n_elements(xout)
         n1 = n_elements(yout)

         result = fltarr(n0-1,n1-1)

         ;; Establish the range in which pixels overlap with the
         ;; polygon's bounding rectangle

         i0 = value_locate(xout,xmin) > 0
         i1 = value_locate(xout,xmax) < (n0-2)

         j0 = value_locate(yout,ymin) > 0
         j1 = value_locate(yout,ymax) < (n1-2)

         ;; Clip polygon to pixel boundaries and calculate area. I
         ;; tried replacing calls to MGH_POLYCLIP below with
         ;; MGH_POLYCLIP2, but this slowed the routine down by ~10%.

         for j=j0,j1 do begin
            pola = mgh_polyclip(yout[j], 1, 0, poly)
            pola = mgh_polyclip(yout[j+1], 1, 1, pola)
            for i=i0,i1 do begin
               polc = mgh_polyclip(xout[i], 0, 0, pola)
               polc = mgh_polyclip(xout[i+1], 0, 1, polc)
               if size(polc, /N_DIMENSIONS) eq 2 then begin
                  px = reform(polc[0,*])
                  py = reform(polc[1,*])
                  ;; Calculate area of clipped polygon
                  result[i,j] = 0.5*abs(total(px*shift(py,-1) - py*shift(px,-1)))
                  ;; if AREA keyword not set, divide by area of cell.
                  if ~ keyword_set(area) then begin
                     aa = (xout[i+1]-xout[i])*(yout[j+1]-yout[j])
                     result[i,j] = result[i,j] / aa
                  endif
               endif
            endfor
         endfor

      end

      1: begin

         dimx = size(xout, /DIMENSIONS)
         dimy = size(yout, /DIMENSIONS)

         if ~ array_equal(dimx, dimy) then $
              message, 'X & Y output grids do not agree'

         n0 = dimx[0]
         n1 = dimx[1]

         result = fltarr(n0-1,n1-1)

         ;; Set loop limits. Could add code here to exclude rows/columns of
         ;; pixels that cannot overlap with the polygon.

         i0 = 0
         i1 = n0-2

         j0 = 0
         j1 = n1-2

         ;; Clip polygon to pixel boundaries and calculate area.

         for j=j0,j1 do begin
            for i=i0,i1 do begin
               coeff = mgh_line_coeff(xout[i,j],yout[i,j], $
                                      xout[i+1,j],yout[i+1,j])
               polc = mgh_polyclip2(poly, coeff, COUNT=n_vert)
               if n_vert eq 0 then continue
               coeff = mgh_line_coeff(xout[i+1,j],yout[i+1,j], $
                                      xout[i+1,j+1],yout[i+1,j+1])
               polc = mgh_polyclip2(polc, coeff, COUNT=n_vert)
               if n_vert eq 0 then continue
               coeff = mgh_line_coeff(xout[i+1,j+1],yout[i+1,j+1], $
                                      xout[i,j+1],yout[i,j+1])
               polc = mgh_polyclip2(polc, coeff, COUNT=n_vert)
               if n_vert eq 0 then continue
               coeff = mgh_line_coeff(xout[i,j+1],yout[i,j+1], $
                                      xout[i,j],yout[i,j])
               polc = mgh_polyclip2(polc, coeff, COUNT=n_vert)
               if n_vert eq 0 then continue
               px = reform(polc[0,*])
               py = reform(polc[1,*])
               result[i,j] = 0.5*abs(total(px*shift(py,-1) - py*shift(px,-1)))
               if ~ keyword_set(area) then begin
                  ax = [xout[i,j],xout[i+1,j],xout[i+1,j+1],xout[i,j+1]]
                  ay = [yout[i,j],yout[i+1,j],yout[i+1,j+1],yout[i,j+1]]
                  aa = 0.5*abs(total(ax*shift(ay,-1) - ay*shift(ax,-1)))
                  result[i,j] = result[i,j] / aa
               endif
            endfor
         endfor

      end

   endcase

   return, result

end
