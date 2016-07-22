pro setxy,xmin,xmax,ymin,ymax,help=help
;+
; NAME:
;       SETXY
;
;            ===============================================
;            Syntax: setxy, xmin, xmax, ymin, ymax,help=help
;            ===============================================
;
;   setxy  Use a box cursor to set the x-axis and y-axis scaling.
;   -----    
;          CURON  --> setxy
;          CUROFF --> setxy,xmin,xmax,ymin,ymax
;
;          Click Left button to set box bottom right corner.
;          Drag Left button to move box.
;          Drag Middle button near a corner to resize box.
;          Right button when done.
;-
; V5.0 July 2007
;
; v6.1 Sept 2009 tmb dealing with window and graphics management
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setxy' & return & endif
;
@CT_IN
!last_x=!x.range         ; remember current scaling
!last_y=!y.range
;
if n_params() eq 4 then goto,def_axes
;
if n_params() ne 4 and !cursor ne 1 then begin
   print,'ERROR: Cursor is off so must input range explicitly!'
   print,'Syntax: setxy,xmin,xmax,ymin,ymax'
   return
   end
;
if n_params() gt 0 and n_params() lt 4 then begin
   print,'Error in argument list:'
   print,'Syntax: setxy,xmin,xmax,ymin,ymax'
   goto,punt
   end                  
;
case 1 of         ; execute boolean (1) true case
;
(!cursor eq 1): begin 
                ; set initial position of box_cursor 
                ccc,xpos,ypos
                ; convert to device units and set initial position of box_cursor
                ; x0,y0 are position of lower left box corner and nx,nw are width+height
                pixels=convert_coord(xpos,ypos,0.,/data,/to_device)
                x0=pixels[0]
                y0=pixels[1]
                nx=2
                ny=2
;
                box_cursor,x0,y0,nx,ny,/init,/message
;
                blc=[x0,    y0,    0.]
                brc=[x0+nx, y0,    0.]
                tlc=[x0,    y0+ny, 0.]
                trc=[x0+nx, y0+ny, 0.]
;
                blc=convert_coord(blc,/device,/to_data)
                brc=convert_coord(brc,/device,/to_data)
                tlc=convert_coord(tlc,/device,/to_data)
                trc=convert_coord(trc,/device,/to_data)
;
                xmin=blc[0] & xmax=brc[0] &
                ymin=blc[1] & ymax=tlc[1] &
                end
else:  goto, def_axes
endcase
                        ;
def_axes:
         !x.range=[xmin,xmax]
         !y.range=[ymin,ymax]
;
punt:
@CT_OUT
;
return
end
