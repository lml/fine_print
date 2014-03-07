# Configuration file for the dummy app
FinePrint.configure do |config|
  config.user_admin_proc = lambda { |user| user.is_admin }
end
