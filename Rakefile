require "rake/testtask"

task :test => [] do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList["test/*_test.rb"]
  end
end
