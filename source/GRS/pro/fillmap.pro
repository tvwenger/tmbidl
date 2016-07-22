;+
;   fillmap.pro   remap whatever has gone before as a FILLED contour map
;   -----------   Uses plot parameters in common block 'map_data'
;             
;                 Syntax:  fillmap
;                         
;-
pro fillmap
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
common map_data,map,hor,ver,levs,thick,colors,style,label, $
                plot_title,DPC,WBB
;
window,1,title='L-V Plot',xsize=1200,ysize=1000
;
;  first must fill the map
contour,map,hor,ver,/xstyle,/ystyle,/follow,title=plot_title,levels=levs, $
        c_thick=thick,c_colors=colors,c_linestyle=style,c_labels=label,   $
        charsize=1.5,charthick=1.5,/fill
;
;  now overlay the contours-- colors must be black!!!
clr=fltarr(n_elements(colors))
clr[0:n_elements(colors)-1]=!black
contour,map,hor,ver,/xstyle,/ystyle,/follow,title=plot_title,levels=levs, $
        c_thick=thick,c_colors=clr,c_linestyle=style,c_labels=label,   $
        charsize=1.5,charthick=1.5,/overplot
;
oplot,DPC,ver,color=!magenta
oplot,WBB,ver,color=!green
if !zline then zline
;
return
end
