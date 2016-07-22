;+
;   gethii.pro   Invokes read_table.pro to create !table structure   
;   ----------   which contains HII region catalog for GRS zone
;                Invokes Beamlb and shows all HII region spectra
;             
;               Syntax:  gethii
;                         
; written 12 June 2006 by T.M.Bania
;-
pro gethii
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt='(i3,1x,i4,1x,a12,1x,f5.2,1x,f5.2,1x,f6.1)'
zlon
curoff
@def_colors
read_table,nrows
;
print,'number of sources in HII sample is= ',nrows
;for i=187,5 do begin
for i=0,nrows-1 do begin
      src=  !table[i].(0) 
      name= !table[i].(1)
      l_gal=!table[i].(2)
      b_gal=!table[i].(3)
      vlsr= !table[i].(4)
      vmin=vlsr-2.5 & vmax=vlsr+2.5 &
;
      Beamlb,l_gal,b_gal
      vt,l_gal,vt_dpc,vt_wbb
;
      setx,vlsr-15.,vlsr+15.
      xx
      
      flag,vlsr,cyan
      flag,vmin,yellow & flag,vmax,yellow &
      flag,vt_dpc,magenta
      flag,vt_wbb,green
      hline,0.5
;
      print,i,name,src,l_gal,b_gal,vlsr,format=fmt
;
      pause,ians
      if ians eq 'b' or ians eq 'p' then i=i-2
end
;
zloff
curon
;
return
end
