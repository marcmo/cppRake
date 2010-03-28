require 'rake/clean'
require 'rake/classic_namespace'
require 'rake/loaders/makefile'

verbose(true) 

CC = "g++"
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
  putSh "#{CC} #{INCLUDES} -MM " + t.prerequisites.join(' ') + " > #{t.name}"
end

SPACE_MARK = "__&NBSP;__"
def loadDependencies(fn)
  open(fn) do |mf|
    lines = mf.read
    lines.gsub!(/\\ /, SPACE_MARK)
    lines.gsub!(/#[^\n]*\n/m, "")
    lines.gsub!(/\\\n/, ' ')
    lines.split("\n").each do |line|
      process_dep_line(line)
    end
  end
end
def process_dep_line(line)
  file_tasks, args = line.split(':')
  return if args.nil?
  dependents = args.split.map { |d| respace(d) }
  file_tasks.strip.split.each do |file_task|
    file_task = objectPath(file_task)
    file file_task => dependents
    puts "added dependency: " + file_task + " => " + dependents.join(' ')
  end
end
def objectPath(str)
  OBJDIR + "/" + respace(str)
end
def respace(str)
  str.gsub(/#{SPACE_MARK}/, ' ')
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
  sh "#{CC} -o #{PROG} -L. -l#{LIBNAME}" 
end

file LIBFILE => OBJ do
  sh "ar cr #{LIBFILE} #{OBJ}" 
  sh "ranlib #{LIBFILE}" 
end

directory OBJDIR

rule '.o' => lambda{ |objfile| find_source(objfile) } do |t|
  Task[OBJDIR].invoke
  sh "#{CC} #{CXXFLAGS} -c -o #{t.name} #{t.source}" 
end

def find_source(objfile)
  base = File.basename(objfile, '.o')
  SRC.find { |s| File.basename(s, '.cpp') == base }
end

# Alternatives
# On possible alternative is to replace the rule with a loop that explicitly creates tasks to compile each .c file. It might look something like this:

# SRC.each do |srcfile|
#   objfile = File.join(OBJDIR, File.basename(srcfile).ext('o'))
#   file objfile => [srcfile, OBJDIR] do
#     sh "#{CC} -c -o #{objfile} #{srcfile}" 
#   end
# end
