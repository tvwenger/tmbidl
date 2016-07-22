;+
;   hiimap.pro   Invokes read_table.pro to create !table structure   
;   ----------   which contains HII region catalog for GRS zone
;                Invokes lbmap to make maps
;             
;               Syntax:  hiimap,idx,span,dv
;                         
; written 12 June 2006 by T.M.Bania
;-
pro hiimap,idx,span,dv
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt='(i3,1x,i4,1x,a12,1x,f5.2,1x,f5.2,1x,f6.1)'
;
if n_params() eq 0 then begin
                      print,'       SYNTAX: hiimap,index'
                      print,'                      index is HII region source #'
                      end
;
@def_colors
read_table,nrows
;
print,'number of sources in HII sample is= ',nrows
;
;for idx=0,nrows-1 do begin
src=  !table[idx].(0) 
name= !table[idx].(1)
l_gal=!table[idx].(2)
b_gal=!table[idx].(3)
v_lsr= !table[idx].(4)
l_range=span
b_range=span
v_range=15.0
;
lbmap,l_gal,b_gal,v_lsr,l_range,b_range,v_range 
;
;
print,idx,name,src,l_gal,b_gal,v_lsr,format=fmt
;
qqq=strtrim(src,2)
xyouts,0.01,0.84,qqq,/normal,charsize=3.0,charthick=2.5, $
  color=orange
qqq=fstring(v_lsr,'(f6.1)')+' km/s'
xyouts,0.01,0.8,qqq,/normal,charsize=2.5,charthick=2.0, $
  color=orange
qqq=fstring(idx,'(i3)')
xyouts,0.01,0.76,qqq,/normal,charsize=3.0,charthick=2.5, $
  color=orange
;
      pause,ians
      if ians eq 'b' or ians eq 'p' then idx=idx-2
      if ians eq 'q' then goto,punt
;
;endfor
;
punt:
return
end
