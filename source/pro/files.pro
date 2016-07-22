pro files,help=help
;+
; NAME:
;      FILES
;
;  files   Procedure to show what files are currently being used.
;  -----
;          EXAMPLE OUTPUT:
;
;          Files currently being used are:
;
;          SDFITS  Data  file= ../data/fits/feb04.avg.acs.fits LUN=   0
;          ONLINE  Data  file= /idl/idl/data/Lfeb04.gbt LUN= 102
;          OFFLINE Data  file= ../data/offline.gbt LUN= 103
;          
;          Nsave file= /idl/idl/data/he3/nsave_rtr_pne.dat LUN= 100
;          NSlog file= /idl/idl/data/he3/nsave_rtr_pne.log LUN= 101
;          
;          PLOT    file= ../figs/idl.ps
;          MESSAGE file= ../data/messages
;          ARCHIVE file= ../archive/archive
;          
;          Journal   = ../saves/jrnl_CUSTOM
;          SAVE_state= ../saves/state.dat
;          SAVE_procs= ../saves/procs.dat
;
;       =======================
;       Syntax: files,help=help
;       =======================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'files' & return & endif
;print
print,'Files currently being used are:'
print
print,'Spectral Line SDFITS  Data  file= ' 
print,'             '+ !datafile  , ' LUN= ' + fstring(!dataunit,'(I3)')
print,'Continuum     SDFITS  Data  file= ' 
print,'             '+ !c_SDFITS
print,'ONLINE  Data  file= ' + !online_data,' LUN= ' + fstring(!onunit,'(I3)')
print,'OFFLINE Data  file= ' + !offline_data,' LUN= ' + fstring(!offunit,'(I3)')
print
print,'Nsave file= ' + !nsavefile , ' LUN= ' + fstring(!nsunit,'(I3)')
print,'NSlog file= ' + !nslogfile , ' LUN= ' + fstring(!nslogunit,'(I3)')
print
print,'PLOT    file= ' + !plot_file
print,'MESSAGE file= ' + !messfile
print,'ARCHIVE file= ' + !archivefile
print
print,'Journal   = ' + !jrnl_file
print,'SAVE_state= ' + !save_idl_state
print,'SAVE_procs= ' + !save_idl_procs
;
return
end
