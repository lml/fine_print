# Configuration file for the dummy app
FinePrint.configure do |config|
  config.manager_proc = lambda { |user| user.is_admin }
end
