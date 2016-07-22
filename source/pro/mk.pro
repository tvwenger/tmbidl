pro  mk,help=help
;+
; NAME:
;       MK
;
;            ====================
;            Syntax: mk,help=help
;            ====================
;
;   mk   Convert y-axis in Kelvins to milliKelvin scale.
;   --
;-
; V5.0 July 2007
;   27 July 2007 TMB modified to store y-axis info 
;                in !b[0].yunits and !b[0].ytype
; V5.1 Feb  2008 TMB modified to deal with continuum data
;
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'mk' & return & endif
;
yunits=strtrim(string(!b[0].yunits),2)  ;  find out current y-axis units
;
if yunits eq 'mK' then begin
          print,'Already in milliKelvins !'
          return
      endif
;
if yunits ne 'K' and yunits ne '' then begin   ; default is Kelvins
          print,'Y-axis units are' + yunits   
          return
      endif
;
if yunits eq '' then begin
          print,'No yunit defined:  do you still want to do this? (y/n)'
          ans=''
          ans=get_kbrd(1)
          if ans eq 'y' then goto,doit $
                        else goto,flush
   endif
;
doit:
!fact=1.0e+3
;
case !line of 
           1: !b[0].data=!fact*!b[0].data
           0: begin
              cpts=!b[0].c_pts
              !b[0].data[0:cpts-1]=!fact*!b[0].data[0:cpts-1]
              end
        else: begin
              print,'Invalid line/continuum flag: take off your clothes!'
              return
              end
endcase
;
!b[0].yunits=''
!b[0].yunits=byte('mK')
;
flush:
return
end

