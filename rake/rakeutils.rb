require 'rake/classic_namespace'
require 'rake/loaders/makefile'

def putSh x
  puts x
  sh x
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

def find_source(objfile)
  base = File.basename(objfile, '.o')
  SRC.find { |s| File.basename(s, '.cpp') == base }
end

def expandPreprocessorSymbols
  PreprocSymbols.collect {|s| '-D' + s}.join(' ')
end
def expandLibraries 
  Libs.collect {|p| '-l' + p }.join(' ')
end
