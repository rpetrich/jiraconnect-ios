task :default => :clang

desc "Clean the build directory"
task :clean do
  sh "xcodebuild clean"
end

desc "Run the clang static code analysis tool and view the analysis results in a web browser - scan-build must be in your PATH"
task :clang => :clean do
  sh "scan-build -V xcodebuild"
end
