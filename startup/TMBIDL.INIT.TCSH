#
#  TMBIDL V8.0 INITIALIZATION FILE
#
#  V8.0 note the capital "V"
#       tmb 30june2015
#
#  new installations should change lines 11 and 14
#
# this is the default IDL path. 
# ***THIS IS DEPENDENT ON YOUR IDL INSTALLTION AND SHOULD BE CHANGED***
# start normal idl, and get the path from there
# idl
# print,!path
# then copy that path here 
setenv DEFAULT_IDL_PATH /home/apps/itt/idl71/lib/astro/pro:/home/apps/itt/idl71/lib/bridges:/home/apps/itt/idl71/lib/dicomex:/home/apps/itt/idl71/lib/hook:/home/apps/itt/idl71/lib/imsl:/home/apps/itt/idl71/lib/itools/components:/home/apps/itt/idl71/lib/itools/framework:/home/apps/itt/idl71/lib/itools/ui_widgets:/home/apps/itt/idl71/lib/itools:/home/apps/itt/idl71/lib/obsolete:/home/apps/itt/idl71/lib/utilities:/home/apps/itt/idl71/lib/wavelet/data:/home/apps/itt/idl71/lib/wavelet/source:/home/apps/itt/idl71/lib:/home/apps/itt/idl71/examples/HP_TIFF:/home/apps/itt/idl71/examples/data:/home/apps/itt/idl71/examples/demo/demodata:/home/apps/itt/idl71/examples/demo/demoslideshows/slideshowsrc:/home/apps/itt/idl71/examples/demo/demosrc:/home/apps/itt/idl71/examples/demo:/home/apps/itt/idl71/examples/doc/bridges:/home/apps/itt/idl71/examples/doc/dicom:/home/apps/itt/idl71/examples/doc/file_io:/home/apps/itt/idl71/examples/doc/image:/home/apps/itt/idl71/examples/doc/itools:/home/apps/itt/idl71/examples/doc/language:/home/apps/itt/idl71/examples/doc/objects:/home/apps/itt/idl71/examples/doc/plot:/home/apps/itt/idl71/examples/doc/sdf:/home/apps/itt/idl71/examples/doc/shaders:/home/apps/itt/idl71/examples/doc/signal:/home/apps/itt/idl71/examples/doc/utilities:/home/apps/itt/idl71/examples/doc/widgets:/home/apps/itt/idl71/examples/imsl:/home/apps/itt/idl71/examples/misc:/home/apps/itt/idl71/examples/mjpeg2000:/home/apps/itt/idl71/examples/ogc/wcs:/home/apps/itt/idl71/examples/ogc/wms:/home/apps/itt/idl71/examples/widgets/wexmast:/home/apps/itt/idl71/examples/widgets:/home/apps/itt/idl71/examples

# this is the location of tmbidl on your system AND SHOULD BE CHANGED
setenv LOCAL_TMBIDL /home/groups/3helium/tmbidlV8_clean/

# This is where we are going to set the new path
setenv IDL_PATH ~

setenv VERSION V8.0

setenv IDL_STARTUP ${LOCAL_TMBIDL}startup/STARTUP.TMBIDL

#setenv IDL_PATH ${IDL_PATH}:${LOCAL_IDL}data/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}data/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/pro/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/pro/flags

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/colors

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/lines

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib/pro

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib/DOC

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib/DOC/html

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/textoidl

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/coyote     

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/markwardt

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/saves

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/archive

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/utilities

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/RRL

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/RRL/pro

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/KANG

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/KANG/pro

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/HI_Models

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/HI_Models/pro

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/vegas

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/vegas/pro

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/tmb/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/lda/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/dsb/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/rtr/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/tvw/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/dan/

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/unipops

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/GRS

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/GRS/pro

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/buao

setenv IDL_PATH ${IDL_PATH}:${LOCAL_TMBIDL}source/arecibo

# Now, stick on the default IDL path
setenv IDL_PATH ${IDL_PATH}:${DEFAULT_IDL_PATH}

#
setenv PSPRINTER 'lp0'         # printer in main office at BU
#setenv PSPRINTER 'lp2'        # printer in TMB's office
#setenv PSPRINTER 'lp'         # printer	in Reber 105
#setenv PSPRINTER 'ops4050'    # printer in GBT control room
