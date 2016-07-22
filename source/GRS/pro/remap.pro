;+
;   remap.pro   remap whatever has gone before using plot
;   ---------   parameters in common block 'map_data'
;               normally used after 'setxy' choice of 
;               subset of original map
;             
;               Syntax:  remap
;                         
;-
pro remap
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
common map_data,map,hor,ver,levs,thick,colors,style,label, $
                title,xsize,ysize,DPC,WBB
;
window,!map_win,title=title,xsize=xsize,ysize=ysize
;
contour,map,hor,ver,/xstyle,/ystyle,/follow,title=title,levels=levs, $
        c_thick=thick,c_colors=colors,c_linestyle=style,c_labels=label,   $
        charsize=1.5,charthick=1.5
;
;oplot,DPC,ver,color=!magenta
;oplot,WBB,ver,color=!green
;if !zline then zline
;
return
end
