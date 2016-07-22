pro unmk,help=help
;+
; NAME:
;       UNMK
;
;            ======================
;            Syntax: unmk,help=help
;            ======================
;
;   unmk   Convert y-axis in milliKelvins to Kelvin scale.
;   ----
; 
;-
; V5.0 July 2007
;   27 July 2007 TMB modified to store y-axis info 
;                in !b[0].yunits and !b[0].ytype
; V5.1 Feb  2008 TMB modified to deal with continuum data
; v7.0 May 2013 tmb/tvw added help and new error handle
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'unmk' & return & endif
;
yunits=strtrim(string(!b[0].yunits),2)  ;  find out current y-axis units
;
if yunits eq 'K' then begin
          print,'Already in Kelvins !'
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
!fact=1.0e-3
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
!b[0].yunits=byte('K')
;
flush:
return
end

