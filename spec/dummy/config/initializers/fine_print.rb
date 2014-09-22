# Configuration file for the dummy app
FinePrint.configure do |config|
  config.can_manage_proc = lambda { |user| user.try(:is_admin) || \
                                           raise(ActionController::RoutingError, 'Not Found') }
end
