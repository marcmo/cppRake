$:.unshift File.dirname(__FILE__) + '/.'
require 'rake/clean'
require 'rakeutils'

verbose(true) 

CC = "g++"
CC_AND_PREP = "#{CC} " + expandPreprocessorSymbols
INCLUDES = INCLUDEDIRS.collect {|p| "-I" + p }.join(' ')
CXXFLAGS = "-g -Wall " + INCLUDES
OBJ = SRC.collect { |fn| File.join(OBJDIR, File.basename(fn).ext('o')) }

CLEAN.include(OBJ, OBJDIR, LIBFILE,".depends.mf")
CLOBBER.include(PROG)

def putSh x
  puts x
  sh x
end

file ".depends.mf" => SRC do |t|
  putSh "#{CC_AND_PREP} #{INCLUDES} -MM " + t.prerequisites.join(' ') + " > #{t.name}"
end

task :loadDependencies => ".depends.mf" do
  puts "invoking loadDependencies"
  loadDependencies ".depends.mf"
end

desc "will build and run the thing"
task :default => [:build, :run]

desc "build executable"
task :build => [:loadDependencies,PROG]

desc "run program"
task :run => [PROG] do
  sh "./#{PROG}" 
end

file PROG => [LIBFILE] do
  sh "#{CC} -o #{PROG} -L. -l#{LIBNAME} " + expandLibraries 
end

file LIBFILE => OBJ do
  sh "ar cr #{LIBFILE} #{OBJ}" 
  sh "ranlib #{LIBFILE}" 
end

directory OBJDIR

rule '.o' => lambda{ |objfile| find_source(objfile) } do |t|
  Task[OBJDIR].invoke
  sh "#{CC} " + expandPreprocessorSymbols + " #{CXXFLAGS} -c -o #{t.name} #{t.source}" 
end

# Alternatives
# On possible alternative is to replace the rule with a loop that explicitly creates tasks to compile each .c file. It might look something like this:

# SRC.each do |srcfile|
#   objfile = File.join(OBJDIR, File.basename(srcfile).ext('o'))
#   file objfile => [srcfile, OBJDIR] do
#     sh "#{CC} -c -o #{objfile} #{srcfile}" 
#   end
# end
