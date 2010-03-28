PROG = "hello" 
LIBNAME = PROG
LIBFILE = "lib#{LIBNAME}.a" 
SRC = FileList['**/*.cpp']
OBJDIR = 'obj'

require '../rake/rakecpp'

