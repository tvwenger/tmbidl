#
#  TMBIDL V8.0 INITIALIZATION FILE
# new installations should change lines 11 and 14

# this is the default IDL path. 
# ***THIS IS DEPENDENT ON YOUR IDL INSTALLTION AND SHOULD BE CHANGED***
# start normal idl, and get the path from there
# idl
# print,!path
# then copy that path here 
export DEFAULT_IDL_PATH=/home/apps/itt/idl71/lib/astro/pro:/home/apps/itt/idl71/lib/bridges:/home/apps/itt/idl71/lib/dicomex:/home/apps/itt/idl71/lib/hook:/home/apps/itt/idl71/lib/imsl:/home/apps/itt/idl71/lib/itools/components:/home/apps/itt/idl71/lib/itools/framework:/home/apps/itt/idl71/lib/itools/ui_widgets:/home/apps/itt/idl71/lib/itools:/home/apps/itt/idl71/lib/obsolete:/home/apps/itt/idl71/lib/utilities:/home/apps/itt/idl71/lib/wavelet/data:/home/apps/itt/idl71/lib/wavelet/source:/home/apps/itt/idl71/lib:/home/apps/itt/idl71/examples/HP_TIFF:/home/apps/itt/idl71/examples/data:/home/apps/itt/idl71/examples/demo/demodata:/home/apps/itt/idl71/examples/demo/demoslideshows/slideshowsrc:/home/apps/itt/idl71/examples/demo/demosrc:/home/apps/itt/idl71/examples/demo:/home/apps/itt/idl71/examples/doc/bridges:/home/apps/itt/idl71/examples/doc/dicom:/home/apps/itt/idl71/examples/doc/file_io:/home/apps/itt/idl71/examples/doc/image:/home/apps/itt/idl71/examples/doc/itools:/home/apps/itt/idl71/examples/doc/language:/home/apps/itt/idl71/examples/doc/objects:/home/apps/itt/idl71/examples/doc/plot:/home/apps/itt/idl71/examples/doc/sdf:/home/apps/itt/idl71/examples/doc/shaders:/home/apps/itt/idl71/examples/doc/signal:/home/apps/itt/idl71/examples/doc/utilities:/home/apps/itt/idl71/examples/doc/widgets:/home/apps/itt/idl71/examples/imsl:/home/apps/itt/idl71/examples/misc:/home/apps/itt/idl71/examples/mjpeg2000:/home/apps/itt/idl71/examples/ogc/wcs:/home/apps/itt/idl71/examples/ogc/wms:/home/apps/itt/idl71/examples/widgets/wexmast:/home/apps/itt/idl71/examples/widgets:/home/apps/itt/idl71/examples

# this is the location of your tmbidl installation and SHOULD BE CHANGED
export LOCAL_TMBIDL=/home/groups/3helium/tmbidlV8_clean/

# This is where we are going to set the new path
export IDL_PATH=~

export VERSION=v8.0

export IDL_STARTUP=${LOCAL_TMBIDL}startup/STARTUP.TMBIDL

export IDL_PATH=${IDL_PATH}:${LOCAL_IDL}data/

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/pro/

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/pro/flags

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/colors

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/lines

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib/pro

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib/DOC

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/astrolib/DOC/html

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/textoidl

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/coyote     

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/markwardt

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/saves

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/archive

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/utilities

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/RRL

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/RRL/pro

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/KANG

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/KANG/pro

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/HI_Models

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/HI_Models/pro

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/tmb/

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/lda/

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/dsb/

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/rtr/

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}sandboxes/tvw/

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/unipops

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/GRS

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/GRS/pro

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/buao

export IDL_PATH=${IDL_PATH}:${LOCAL_TMBIDL}source/arecibo

# Now, stick on the default IDL path
export IDL_PATH=${IDL_PATH}:${DEFAULT_IDL_PATH}
