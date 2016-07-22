;
;   h00.pro   Flag in channels the position of the H87alpha, He87alpha, and C87alpha
;   -------   We interpolate all other RRLs to this velocity scale
;             Use channel 643.0 as the reference for the alpha lines
;
;             Velocity resolution = (50.0/4096)*3.0e5/9816.867 = 0.373 km/s
;
;             H87alpha:  9816.867 MHz;   0.00 km/s; 643.00
;             He87alpha: 9820.864 MHz; 122.15 km/s; 315.52 
;             C87alpha:  9821.761 MHz; 149.56 km/s; 242.03
;
; tvw 21jun2013 - checks if we are in chan or velo, plots flags accordingly
;
;

pro h00
;
on_error,!debug ? 0 : 2
;
; define channel array
;
xchan=[643.00, 315.52, 242.03]
xvelo=[0.0, -122.15, -149.56]
;
; check if we are chan or velo
if !chan then xvals=xchan else if !velo then xvals=xvelo else begin
   print,'Uh oh... need x-axis not defined correctly'
   return
endelse
;
label=['H','He','C']
color=fltarr(3)
color=[!red,!red,!red]

;
; get x data range
;
xmin = !x.crange[0]
xmax = !x.crange[1]
;
for i=0,2 do begin
      ;print,xchan[i],' ',label[i],color[i]
;
      if ((xvals[i] gt xmin) and (xvals[i]lt xmax)) then $
         flg_id,xvals[i],textoidl(label[i]),color[i]
endfor
;
return
end
