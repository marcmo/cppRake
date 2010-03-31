clean_dirs = ["cpp_rake","example","example2"]

task :clean do
  clean_dirs.each do |d|
    cd d do
      sh "rake clean"
      sh "rake clobber"
    end
  end
end
  
