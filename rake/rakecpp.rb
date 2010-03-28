require 'rake/clean'
require 'rake/classic_namespace'
require 'rake/loaders/makefile'

verbose(true) 

CC = "g++"
OBJ = SRC.collect { |fn| File.join(OBJDIR, File.basename(fn).ext('o')) }

CLEAN.include(OBJ, OBJDIR, LIBFILE,".depends.mf")
CLOBBER.include(PROG)

file ".depends.mf" => SRC do |t|
  sh "#{CC} -MM " + t.prerequisites.join(' ') + " > #{t.name}"
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
# Rake::Task[".depends.mf"].invoke
# loadDependencies ".depends.mf"
task :loadDependencies => ".depends.mf" do
  loadDependencies ".depends.mf"
end

task :default => [:build, :run]

task :build => [:loadDependencies,PROG]

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
  sh "#{CC} -c -o #{t.name} #{t.source}" 
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
