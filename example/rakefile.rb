PROG = "hello" 
LIBNAME = PROG
LIBFILE = "lib#{LIBNAME}.a" 
SRC = FileList['**/*.cpp']
OBJDIR = 'obj'
INCLUDEDIRS = ['include']
PreprocSymbols=[]
Libs=[]
LibIncludePath=[]

require 'rakecpp'

