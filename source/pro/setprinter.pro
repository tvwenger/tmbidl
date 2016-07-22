pro setprinter,device,help=help
;+
; NAME:
;       SETPRINTER
;
;            ==============================================
;            Syntax: setprinter, device,help=help
;            setprinter,unit_no OR setprinter,"device_name"
;            ==============================================
;
;   setprinter   Select printer for hardcopy output 
;   ----------   via 'setenv PSPRINTER dev'
;
;            ==> setprinter,dev   if no device input a menu is printed
;                         
;                setprinter,0          can specify device by integer or string
;                setprinter,'lpr'      both these commands do the same thing
;
;        Syntax: setprinter,unit_no OR setprinter,"device_name"
;                setprinter,0          can specify device by integer or string
;                setprinter,'lpr'      both these commands do the same thing
;
;          menu: 
;               (0) lp0     : Boston University department office: BW'
;               (1) ops4050 : GBT Control Room: BW'
;               (2) telops  : GBT Control Room: color'
;               (3) net     : Jansky 234: BW'
;               (4) lp      : Reber 105: BW'
;               (5) pslaser : Reber 105: color'
;               (6) coltran : Reber 105: color transparency'
;               (7) astro-hp    : University of Virginia printer'
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
on_ioerror, fault
if keyword_set(help) then begin & get_help,'setprinter' & return & endif
;
npar = n_params(0)
;
menu: if npar eq 0 then begin
  device = 0                       ;Integer
  print,' '
  print,'Select printer to attach: '
  print,'(0) lp0     : Boston University department office: BW'
  print,'(1) ops4050 : GBT Control Room: BW'
  print,'(2) telops  : GBT Control Room: color'
  print,'(3) net     : Jansky 234: BW'
  print,'(4) lp      : Reber 105: BW'
  print,'(5) pslaser : Reber 105: color'
  print,'(6) coltran : Reber 105: color transparency'
  print,'(7) astro-hp: University of Virginia printer'
  print,'Syntax: setprinter,unit_no OR setprinter,"device_name"'
;
  return
endif else begin
  siz = size(device)          ; returns 2 if integer; 7 if string
  if (siz[1] eq 7) then begin
	case strupcase(device) of
	'LP0':     device_no = 0
	'OPS4050': device_no = 1
	'TELOPS':  device_no = 2
	'NET':     device_no = 3
	'LP':      device_no = 4
	'PSLASER': device_no = 5
        'COLTRAN': device_no = 6
        'ASTRO-HP':device_no = 7
  else: begin
        message,'A printer type of ' + device + $
                ' is not an available option',/INFORM
        npar = 0
	goto,menu
        end
        endcase
  endif else begin 
   if (siz[1] eq 2) then device_no = device
  endelse
endelse
if (device_no lt 0) or (device_no gt 7) then begin 
	message,'A printer type of ' + strtrim(device_no,2) + $
                 ' is not an available option',/INFORM
	npar = 0
	goto, menu
endif                             
;
device=''
;
case device_no of 
0:  begin  ; BU   
        print,'Setting printer to Boston University: lp0 (BW)'
	setenv,'PSPRINTER=lp0'
        print
    end
1:  begin  ; GBT control room 
        print,'Setting printer to GBT Control Room: ops4050 (BW)'
        setenv,'PSPRINTER=ops4050'
        print
    end
2:  begin  ; GBT control room    
        print,'Setting printer to GBT Control Room: telops (color)'
        setenv,'PSPRINTER=telops'
        print
    end
3:  begin   ; Jansky lab room 234 
        print,'Setting printer to Jansky lab room 234: net (BW)'
        setenv,'PSPRINTER=net'
        print
    end
4:  begin    ; Reber lab room 105
        print,'Setting printer to Reber lab room 105: lp (BW)'
        setenv,'PSPRINTER=lp'
        print
    end
5:  begin    ; Reber lab room 105
        print,'Setting printer to Reber lab room 105: pslaser (color)'
        setenv,'PSPRINTER=pslaser'
        print
    end
6:  begin    ; Reber lab room 105
        print,'Setting printer to Reber lab room 105: coltran (color transparency)'
        setenv,'PSPRINTER=coltran'
        print
    end
7:  begin    ; University of Virginia printer
        print,'Setting printer to University of Virginia astro-hp'
        setenv,'PSPRINTER=astro-hp'
        print
    end
endcase
;
goto, done
;
fault:  begin
        print,!err_string
        return
        end
;
done:
;
return                                                
end 


