# Change the settings below to suit your needs
# All settings are initially set to their default values
FinePrint.configure do |config|

  # Engine Configuration

  # Name of the ApplicationController helper method that returns the current user
  # Default: 'current_user'
  config.current_user_method = 'current_user'

  # Proc called with user as argument that should return true if and only if the user is an admin
  # Admins can create and edit agreements and terminate accepted agreements
  # Note: user can be nil
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }



  # Agreement Configuration

  # Whether or not to display a checkbox that has to be clicked before the user can accept the agreement
  # Default: true
  config.read_checkbox = true

  # Grace period for accepting new agreements (set to 0 to disable)
  # Default: 0
  config.grace_period = 0

  # If set to true, the grace period will only apply if the user already accepted a previous version of the same agreement
  # Default: true
  config.grace_period_on_new_version_only = true
  
end
