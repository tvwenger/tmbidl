pro setplot,device,THICK=thick,help=help
;+
; NAME:
;   SETPLOT
;
;            ============================================
;            Syntax: setplot,device,THICK=thick,help=help
;            ============================================
;
;   setplot   NOT part of this package, but it is useful.
;   -------
;
;   Directs subsequent plot to the specified plotting device.
;   Typing SETPLOT without any parameters will give a menu of
;   available plotting devices.
;
;   setplot              ;Print menu of available graphics devices
;   setplot,device_n_no  ;Direct subsequent to device device_no
;   setplot,device_name  ;Set to device given by device_name
;                 
;   THICK - controls thickness of lines and characters, by setting
;         !P.CHARTHICK, !P.THICK, !X.THICK and !Y.THICK, default=1
;   For example, to make triple thickness lines on a QMS landscape plot:
;   TMBIDL->SETPLOT,'QMS',THICK=3
;
; PURPOSE:
;   To direct subsequent plot to the specified plotting device.
;	Typing SETPLOT without any parameters will give a menu of
;	     available plotting devices.
;	The user is informed of the subsequent plotting device.
;	The user can either specify the device name or the 
;	     device number.    
; CALLING SEQUENCE:
;    setplot	           ;Print menu of available graphics devices
;    setplot,device_no	   ;Direct subsequent to device given by device_no
;    setplot,device_name   ;Set to device given by device_name
; INPUT:
; KEYWORDS:
;      THICK - controls the thickness of the lines and characters, by setting
;              !P.CHARTHICK, !P.THICK, !X.THICK and !Y.THICK,  default=1
;              For example, to make triple thickness lines on a QMS landscape 
;              plot:
;
;                      IDL>SETPLOT,'QMS',THICK=3
; REVISION HISTORY:
;    Written, W. Landsman, STX Corp. 	February, 1987
;    Adapted to SUN IDL.  M. Greason, STX, August 1990
;    Combined VAX and UNIX versions, N. Collins, STX, Nov. 27, 1990
;    Added THICK keyword to control the plot thickness  W. Landsman Mar 1991
;
;    Modified by Ed Murphy for his personal preferences.
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'setplot' & return & endif
;
common tek,plotunit,old_device
os = !VERSION.OS
npar = n_params(0)
nod = getenv('NODE')
start =' Subsequent plots will be directed to '
menu: if npar eq 0 then begin
  device_no = 0                       ;Integer
  print,' '
  print,'Select device number for subsequent plotting output'
  print,'(0) Tektronics Terminal Screen 
  print,'(1) X windows display'
  print,'(3) PostScript Landscape plot file'
  print,'(4) PostScript Thesis format plot file'
  print,'(5) Postscript full page portrait format plot file'
  print,'(6) Postscript default portrait format plot file'
  print,'(7) Postscript portrait square plot file'
  print,'(8) PostScript Narrow Landscape plot file'
  read,'Graphics device number: ',device_no
endif else begin
  siz = size(device)
  if (siz(1) eq 7) then begin
	case strupcase(device) of
	'TEK': device_no = 0
	'X': device_no = 1
	'LAND': device_no = 3
	'THESIS': device_no = 4
	'FULL': device_no = 5
	'PORT': device_no = 6
        'SQR': device_no =7
        'NARROW': device_no = 8
	else: begin
	  message,'A device type of ' + device + $
                   ' is not an available option',/INFORM
	  npar = 0
	  goto,menu
          end
        endcase
  endif else begin 
   if (siz(1) eq 2) then device_no = device 
  endelse
endelse
if (device_no lt 0) or (device_no gt 8) then begin 
	message,'A device type of ' + strtrim(device_no,2) + $
                 ' is not an available option',/INFORM
	npar = 0
	goto, menu
endif                             
;
;
case device_no of 
0:  begin                                ;Tektronics   
	print,'$(/a)',start + 'the Tektronics terminal'
        set_plot,'tek'
	end
1:  begin
	print,'$(/a)',start + 'the X windows display'
        set_plot,'X'
    end
2:  begin
	print,'$(/a)',start + 'the X windows display'
        set_plot,'X'
    end
3: begin
   print,'$(/a)',start + 'a Landscape PostScript file'
   print,'$(a/)',' File may be printed with PSPLOT'
   set_plot,'PS'
   device,/landscape
   end
4: begin                               ;Postscript file
   print,'$(/a)',start + 'a Thesis Format PostScript file'
   print,'$(a/)',' File may be printed with PSPLOT'
   set_plot,'PS'
   device,/portrait
   device,/inches,xsize=6.9,ysize=6.5,xoffset=0.75,yoffset=3.5
   end
5: begin                               ;Postscript file
   print,'$(/a)',start + 'a full page Portrait PostScript file'
   print,'$(a/)',' File may be printed with PSPLOT'
   set_plot,'PS'
   device,/portrait
   device,/inches,xsize=7.5,ysize=10.0,xoffset=0.5,yoffset=0.5
   end
6: begin
   print,'$(/a)',start + 'Default Portrait PostScript file'
   print,'$(a/)',' File may be printed with PSPLOT'
   set_plot,'PS'
   device,/portrait
   device,/inches,xsize=7.0,ysize=6.0,xoffset=0.75,yoffset=4.0
   end
7: begin                               ;Postscript file
   print,'$(/a)',start + 'a square Portrait PostScript file'
   print,'$(a/)',' File may be printed with PSPLOT'
   set_plot,'PS'
   device,/portrait
   device,/inches,xsize=7.4,ysize=7.4,xoffset=0.0,yoffset=2.0
   end
8: begin
   print,'$(/a)',start + 'a narrow Landscape PostScript file'
   print,'$(a/)',' File may be printed with PSPLOT'
   set_plot,'PS'
   device,/landscape
   device,/inches,xsize=10.0,ysize=4.0,xoffset=2.0,yoffset=10.8
   end
endcase
if (n_elements(thick) eq 0) then thick = 1
!P.CHARTHICK = thick  & !X.THICK = thick
!Y.THICK = thick      & !P.THICK = thick
return                                                
end 


