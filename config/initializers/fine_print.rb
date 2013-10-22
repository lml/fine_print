# Change the settings below to suit your needs
# All settings are initially set to their default values
FinePrint.configure do |config|

  # Engine Options (initializer only)

  # Name of the ApplicationController helper method that returns the current user
  # Default: "current_user"
  config.current_user_method = "current_user"

  # Proc called with user as argument that should return true if and only if the user is an admin
  # Admins can create and edit agreements and terminate accepted agreements
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }

  # config.pose_contracts_proc = lambda { |contract_names| ... }

  # Path to redirect users to when an error occurs (e.g. permission denied on admin pages)
  # Default: "/"
  config.redirect_path = "/"
  
end
