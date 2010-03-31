PROG = "unittest" 
LIBNAME = PROG
LIBFILE = "lib#{LIBNAME}.a" 
SRC = FileList['**/*.cpp']
Libs=["dl","cppunit"]
OBJDIR = 'obj'
INCLUDEDIRS = ['include']
PreprocSymbols = ["CPPUNIT_MAIN=main","UNIT_TEST"]
LibIncludePath=[]

require 'rakecpp'

