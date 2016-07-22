	function closest2d, array, value, cl=cl
;+
; NAME:
;	CLOSEST2D
;
; PURPOSE:
;	Find the element of ARRAY that is the closest in value to VALUE
;
; CATEGORY:
;	utilities
;
; CALLING SEQUENCE:
;	index = CLOSEST(array,value)
;
; INPUTS:
;	ARRAY = the array to search (2D)
;	VALUE = the value we want to find the closest approach to (2D)
;       ARRAY is [[x1,y1],[x2,y2],...]
;       VALUE is [x0,y0]
;
; OUTPUTS:
;	INDEX = the index into ARRAY[*,0] which is the element closest to VALUE
;
;   OPTIONAL PARAMETERS:
;	none
;
; COMMON BLOCKS:
;	none.
; SIDE EFFECTS:
;	none.
; MODIFICATION HISTORY:
;	Written by: Trevor Harris, Physics Dept., University of Adelaide,
;		July, 1990.
;       22jan2012 tvw added 2d
;
;-

	if (n_elements(array) le 1) or (n_elements(value) le 1) then index=-1 $
	else if (n_elements(array) eq 1) then index=0 $
	else begin
		dist = sqrt( (array[*,0]-value[0])^2. + (array[*,1]-value[1])^2.)
		mindiff = min(dist,index)
	endelse
        cl=mindiff
	return,index
	end
