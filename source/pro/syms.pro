Pro syms,no,scale,ifl,help=help,xvec=xvec,yvec=yvec
;+
; NAME:
;       SYMS
;
;        ======================================================
;       Syntax: syms,no,scale,ifl,help=help,xvec=xvec,yvec=yvec
;        ======================================================
;
;     syms   Creates a set of vectors which define basic symbols
;     ----   for use in scatter plots.  These vectors set 
;            the shape of the symbols, then USERSYM is called. 
;
;     no --  selects the desired symbol
;            1=circle
;            2=triangle
;            3=square
;            4=diamond
;            5=plus
;            6=x symbol
;            7=half circle
;  scale --  selects the scale factor
;  ifl   --  selects the `filling 'factor' 
;            1= filled 
;            0= empty
;
;     KEYWORDS  HELP  gives HELP and returns if set 
;               XVEC  X vector to be sent to USERSYM 
;               YVEC  Y vector to be sent to USERSYM
;-
; MODIFICATION HISTORY 
;
;  Originally written by Mike Fanelli many moons ago.
;  Modified by Ed Murphy to run with IDL version 2
; V5.0 July 2007
; V6.1 24 April 2012 tmb Completely rewritten and 
;      Modified to return the x,y vectors sent to 
;      USERSYM as keywords added HELP keyword 
; V7.0 03may2013 tvw - added /help, !debug
;-
;
if Keyword_Set(help) then begin & get_help,'syms' & return & endif
;
case no of 
       1: begin ; circle
          ang = (360. / 24.) * findgen(25) / !radeg 
          xvec=cos(ang)*scale & yvec=sin(ang)*scale
          end 
       2: begin ; triangle
          ang = (360. / 3.)  * findgen(4) / !radeg
          xvec=sin(ang)*scale & yvec=cos(ang)*scale
          end
       3: begin ; square
          sqx=[1.,1.,-1.,-1.,1.] & sqy=[1.,-1.,-1.,1.,1.]
          xvec=sqx*scale & yvec=sqy*scale
          end
       4: begin ; diamond
          dix= [0.,1.,0.,-1.,0.] & diy=[1.,0.,-1.,0.,1.]
          xvec=dix*scale & yvec=diy*scale
          end
       5: begin ; plus sign
          plx=[0.,0.,0.,-1.,1.] & ply=[1.,-1.,0.,0.,0.]
          xvec=plx*scale & yvec=ply*scale
          end
       6: begin ; X symbol
          xkx = [0.7071,-0.7071,0.,-0.7071,0.7071]  
          xky = [0.7071,-0.7071,0.,0.7071,-0.7071]
          xvec=xkx*scale & yvec=xky*scale
          end  
       7: begin ; half-circle -- to make a half-filled circle
;                 plot an open circle then replot with half circle 
;                 and ifl=1 
;                if lrtp filled half circle is on:
;                    90  --> left
;                   180  --> bottom
;                   270  --> right
;                   360  --> top
          lrtp=90. & ang=fltarr(14) 
          ang[0]=(15.*findgen(13)+lrtp)/!radeg
          ang[13] = lrtp / !radeg 
          xvec=cos(ang)*scale & yvec=sin(ang)*scale
          end
    else: begin & print,'ERROR ! Invalid symbol number' & return & end
endcase
;
; now define the symbol
; fetch the vectors xvec,yvec via keywords
;
usersym,xvec,yvec,FILL=ifl
;
return
end
 
 


