FINE_PRINT_COPY_TASKS = ['assets/stylesheets', 
                         # 'assets/javascripts', 
                         'views/layouts', 
                         'views', 
                         'controllers']

namespace :fine_print do
  namespace :install do
    desc "Copy initializers from fine_print to application"
    task :initializers do
      Dir.glob(File.expand_path('../../../config/initializers/*.rb', __FILE__)) do |file|
        if File.exists?(File.expand_path(File.basename(file), 'config/initializers'))
          print "NOTE: Initializer #{File.basename(file)} from fine_print has been skipped. Initializer with the same name already exists.\n"
        else
          cp file, 'config/initializers', :verbose => false
          print "Copied initializer #{File.basename(file)} from fine_print\n"
        end
      end
    end
  end

  namespace :copy do
    FINE_PRINT_COPY_TASKS.each do |path|
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
    Rake::Task["fine_print:install:initializers"].invoke
    Rake::Task["fine_print:install:migrations"].invoke
  end
  
  desc "Copy assets, layouts, views and controllers from fine_print to application"
  task :copy do
    FINE_PRINT_COPY_TASKS.each do |path|
      Rake::Task["fine_print:copy:#{File.basename(path)}"].invoke
    end
  end
end

