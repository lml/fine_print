COPY_TASKS = ['assets/stylesheets', 'views', 'helpers', 'controllers', 'models']

namespace :fine_print do
  namespace :copy do
    COPY_TASKS.each do |path|
      name = File.basename(path)
      desc "Copy #{name} from fine_print to application"
      task name.to_sym do
        cp_r File.expand_path("../../../app/#{path}/fine_print", __FILE__), "app/#{path}", :verbose => false
        print "Copied #{name} from fine_print\n"
      end
    end
  end
  
  desc "Copy migrations from fine_print to application"
  task :install do
    Rake::Task["fine_print:install:migrations"].invoke
  end
  
  desc "Copy assets, views, helpers, controllers and models from fine_print to application"
  task :copy do
    COPY_TASKS.each do |path|
      Rake::Task["fine_print:copy:#{File.basename(path)}"].invoke
    end
  end
end

