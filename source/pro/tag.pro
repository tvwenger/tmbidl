pro tag,label,xpos,ypos,xvec,yvec,align=align,vector=vector, $
        size=size,thick=thick,color=color,cmd=cmd,help=help, _extra=extra
;+
; NAME:
;       TAG
;
;       =============================================================
;       Syntax: tag, LABEL_STRING, xpos, ypos, xvec, yvec, $
;                    align=align, vector=vector, color=color, $
;                    size=size, thick=thick, cmd=cmd, help=help
;       =============================================================
;
;   tag   Writes a label to the plot at co-ordinates defined 
;   ---   by either cursor click or explicitly passed (xpos,ypos)
;         N.B. Uses NORMALIZED co-ordinates: x,y = 0.0 -> 1.1 
;
;         Keyword 'help' gives TAG syntax and returns: tag,/help
;
;         Keyword 'align' positions the label at this co-ordinate:  
;         'C'= centered        => Label CENTERED at cursor position  
;         'L'= Left  justified => Label ENDS at cursor position
;         'E'= Label and Vector END at cursor position 
;         'R'= Right justified => Label STARTS at cursor position
;         'B'= Label and Vector BEGIN at cursor position
;         Default is 'B' which is identical to 'R'
;
;         If 'vector' keyword is set then draws vector from          
;         label cursor click position to co-ordinate defined 
;         by this second cursor click and sets (xvec,yvec)
;         Default is NO vector.
;
;         Keyword 'color' accepts system variable color definitions.
;         Default is !white.
;
;         Keyword 'size' sets size of the tag CHARSIZE
;         Default is 1.5
;
;         Keyword 'thick' sets thickness of the characters CHARTHICK in IDL
;         Default is 1.5
;          
;         Keyword 'cmd' returns string variable that gives
;         a commmand line which reproduces the tag just
;         executed.  This is useful for PostScript plots.
;         If !flag  is on then this string is sent to standard output.
;
;         Prompts for any missing information.
;
;         EXAMPLE OF FANCY FORMATTING e.g. H91 alpha text
;
;         TMBIDL-->label='H91\alpha'
;         TMBIDL-->label=textoidl(label)
;         TMBIDL-->print,label
;         H91!7a!X
;         TMBIDL-->tag,label
;         Left Click on Label Position
;
;         tag,"H91!7a!X",0.18,0.55,align="C",color=250,cmd=cmd
;
;-
; V6.1 tmb 07aug2010
;      rtr 03Sept2010 rtr adds keywords for size (size) and thickness (wt)
;                         and changes some defaults 
;      tmb 08sept2010 tmb fixes rtr dodo and adds 'help' keyword
;          09sept2010 changed 'wt' to 'thick' to resonate better
;                     with IDL graphics useage.  
;                     added _extra keyword
;                     changed align to 'B' and 'E' instead
;                     of 'L' and 'R' which seem to do things
;                     intuitively counter of expectations 
;      tmb 10feb2011  fixed some bugs with cmd keyword
; V7.0 03may2013 tvw - added /help, !debug
;                     
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
@CT_IN
;
if keyword_set(help) then begin & get_help,'tag' & return & endif
if ~Keyword_Set(align)  then align  = 'B'
if ~Keyword_Set(vector) then vector = 0
if ~Keyword_Set(color)  then color  = !white
if ~Keyword_Set(thick)  then thick  = 1.5
if ~Keyword_Set(size)  then size  = 1.5
case !clr of  ; take care of PostScript 
             1: clr=color 
          else: clr=!d.name eq 'PS' ? !black : !white
endcase
;
if n_params() eq 0 then begin
   label='Wilson=Ugly!'   
   read,label,prompt='Input Label Text: (no quotes!)'
endif
;                          ;
if n_params() lt 3 then begin
   if !flag then print,'Left Click on Label Position'
   rdplot,xpos,ypos,/down,/normal,/fullcursor,color=!red
endif
;
; align the string
;
incr=0.01 
case align of 
       'C': begin & orient=0.5 & x0=xpos & y0=ypos-incr & end
       'L': begin & orient=1.0 & x0=xpos & y0=ypos-incr & end
       'R': begin & orient=0.0 & x0=xpos & y0=ypos-incr & end
       'E': begin & orient=1.0 & x0=xpos & y0=ypos-incr & end
       'B': begin & orient=0.0 & x0=xpos & y0=ypos-incr & end
       else: print,'this should never happen to align'
endcase
;
xyouts,xpos,ypos,label,/normal,charsize=size,charthick=thick, $
       alignment=orient,color=clr, _extra=extra
;
case 1 of 
    vector eq 1 and  n_params() lt 5: begin
           if !flag then print,'Click on Vector Endpoint'
           rdplot,xvec1,yvec1,/down,/normal,/fullcursor,color=!red
           x1=xvec1 & y1=yvec1
           plots,x0,y0,/normal & plots,x1,y1,/normal,/continue,color=clr,_extra=extra
           end
    vector eq 1 and  n_params() eq 5: begin
           x1=xvec & y1=yvec 
           plots,x0,y0,/normal & plots,x1,y1,/normal,/continue,color=clr,_extra=extra
       end
 else: 
endcase
;
; Generate 'tag' command string that we just executed above
;
cmd="tag,'"+label+"',"+fstring(x0,'(f4.2)')+','+fstring(y0,'(f4.2)')
if vector eq 1 then begin
   cmd=cmd+','+fstring(x1,'(f4.2)')+','+fstring(y1,'(f4.2)')
   cmd=cmd+',/vector'
endif
cmd=cmd+',align="'+align+'"'
cmd=cmd+',color='+fstring(color,'(i3)')
cmd=cmd+',size='+fstring(size,'(f3.1)')
cmd=cmd+',thick='+fstring(thick,'(f3.1)')
cmd=cmd+',cmd=cmd'
;
if !flag then begin & print & print,cmd & end
;
@CT_OUT
return
end

