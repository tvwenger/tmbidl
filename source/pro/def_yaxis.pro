pro def_yaxis,help=help
;+
; NAME:
;       DEF_YAXIS
;
;       ===========================
;       Syntax: def_yaxis,help=help
;       ===========================
;
;  def_yaxis   Define Y-axis units from !b[0].yunits
;  ---------   Define Y-axis type  from !b[0].ytype
;
;              If yunits is     'K'  then  Kelvins
;                              'mK'        milliKelvins
;                              'Jy'        Janskys
;                             'mJy'        milliJanskys
;                           'micJy'        microJanskys
;                             'MJy'        MegaJanskys
;              Default is Kelvins.
;
;              If ytype  is    'TA'  then  Antenna Temperature
;                              'TB'        Brightness Temperature
;                             'TA*'        T_A *
;                             'TMB'        Main Beam Brightness Temperature
;                            'FLUX'        Flux
;              Default is Antenna Temperature
;
; V5.0 July 2007  
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'def_yaxis' & return & endif
;
y_units=['K','mK','Jy','mJy','micJy','MJy']
y_label=['TA','TB','TA*','TMB','FLUX']
;
;y_axislabel=['Antenna Temperature','Brightness Temperature', $
;            "T!DA!N!U*!N","T!DMB!N",'FLUX']
y_axislabel=['Antenna Temperature','Brightness Temperature', $
            textoidl('T_A^*'),textoidl('T_{mb}'),'FLUX']
bl=' ('
br=')'
;
yunits=strtrim(string(!b[0].yunits),2)
ytype =strtrim(string(!b[0].ytype ),2)
;
case yunits of                             ; find the Y-axis units
;
       'K': begin
            unit_label=bl+y_units[0]+br
            end
      'mK': begin 
            unit_label=bl+y_units[1]+br
            end
      'Jy': begin 
            unit_label=bl+y_units[2]+br
            end
     'mJy': begin
            unit_label=bl+y_units[3]+br
            end
   'micJy': begin 
            unit_label=bl+y_units[4]+br
            end
     'MJy': begin 
            unit_label=bl+y_units[5]+br
            end
;
      else: begin  ;  Default is Kelvin
            unit_label=bl+y_units[0]+br
            end         
endcase
;
case ytype  of                             ; find the Y-axis label
      'TA': begin
            Y_axis_label=y_axislabel[0]
            end
      'TB': begin 
            Y_axis_label=y_axislabel[1]
            end
     'TA*': begin
            Y_axis_label=y_axislabel[2]
            end
     'TMB': begin
            Y_axis_label=y_axislabel[3]
            end
    'FLUX': begin
            Y_axis_label=y_axislabel[4]
            end
      else: begin  ; Default is Antenna Temperature
            Y_axis_label=y_axislabel[0]
            end
endcase
;
!y.title = Y_axis_label + unit_label
;
return
end
