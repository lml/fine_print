# Configuration file for the dummy app
FinePrint.configure do |config|
  config.authenticate_manager_proc = ->(user) { user.try(:is_admin) || head(:forbidden) }
end
