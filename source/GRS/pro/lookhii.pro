;+
;   lookhii.pro   Invokes read_table.pro to create !table structure   
;   -----------   which contains HII region catalog for GRS zone
;                 Invokes lbmap,l_hii,b_hii,v_lsr,.2,.2,15.
;             
;               Syntax:  lookhii,vrange  vrange is Dv for W_co
;                                               in km/sec
;                         
; written 19 June 2006 by T.M.Bania
;-
pro lookhii
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt='(i3,1x,i4,1x,a12,1x,f5.2,1x,f5.2,1x,f6.1)'
;
span=0.2            ; 12x12 arcmin map extent
v_range=15.0        ; 15 km/sec wide W_co centered at vlsr
;
read_table,nrows
;
;for i=0,5 do begin
;for idx=0,nrows-1 do begin
for idx=0,34 do begin
      src=  !table[idx].(0) 
      name= !table[idx].(1)
      l_gal=!table[idx].(2)
      b_gal=!table[idx].(3)
      vlsr= !table[idx].(4)

;
      lbmap,l_gal,b_gal,vlsr,span,span,v_range
;

;
      print,idx,name,src,l_gal,b_gal,vlsr,format=fmt
;
      pause,ians
      if ians eq 'b' or ians eq 'p' then idx=idx-2
      if ians eq 'q' then goto,punt
;
end
;
punt:
return
end
