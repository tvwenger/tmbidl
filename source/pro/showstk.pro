pro showstk,over=over,fact=fact,help=help
;+
; NAME:
;       SHOWSTK
;
;            =============================================
;            Syntax: showstk,over=over,fact=fact,help=help
;            =============================================
;
;   showstk  Show current contents of STACK. 
;   -------  Uses !select value to figure out whether 
;            STACK entries are records (!select=0) or NSAVEs  (!select=1)
;            Uses !line value to figure out whether data are LINE (!line=1) 
;            or CONTINUUM
;            FACT expands the plot y_range beyond that of first plot
;            Default is FACT=0.05
;
;            Syntax: showstk,\over   
;            ===================== 
;                            <== \over OVERLAYS the plots, else pages
;
;            showstk,/over,fact=0.5 <== overlay all STACK data with
;                                       y_axis range twice that of
;                                       first record
;-       
; MODIFICATION HISTORY:
; V5.1 tmb 12aug08 
;      tmb 18aug08 added DCSUB to \over after fixing DCSUB to work on
;      continuum
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'showstk' & return & endif
;
batch_state=!batch
batchon
;
if Keyword_Set(fact) then scl=fact else scl=0.05
;
for i=0,!acount-1 do begin
     scn=!astack[i]
     case 1 of 
              !line eq 0 and !select eq 0 : cget,scn   ; get continuum record
              !line eq 0 and !select eq 1 : cgetns,scn ; get continuum NSAVE
              !line eq 1 and !select eq 0 : get,scn    ; get line record
              !line eq 1 and !select eq 1 : getns,scn  ; get line NSAVE
                                     else :    
     endcase
;
     case i of 
              0: begin & dcsub & xx,/pause & sizey,scl & end  
           else: if Keyword_Set(over) then begin
                                    dcsub & reshow 
                 endif else begin & xx,/pause & endelse
     endcase
;
endfor
;
!batch=batch_state
;
return
end
