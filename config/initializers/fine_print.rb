# Change the settings below to suit your needs
# All settings are initially set to their default values
FinePrint.configure do |config|

  # Engine Options (initializer only)

  # Name of the ApplicationController helper method that returns the current user
  # Default: 'current_user'
  config.current_user_method = 'current_user'

  # Proc called with user as argument that should return true if and only if the user is an admin
  # Admins can create and edit agreements and terminate accepted agreements
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }



  # Agreement Options (initializer or inline)

  # Message to be displayed to the user explaining that they need to accept an agreement
  # Set to nil to disable
  # Default: "You must accept the following agreement to proceed."
  config.agreement_notice = "You must accept the following agreement to proceed."

  # Grace period for accepting new agreements (set to 0 to disable)
  # Default: 0
  config.grace_period = 0

  # If set to true, the grace period will only apply if the user already accepted a previous version of the same agreement
  # Default: true
  config.grace_period_on_new_version_only = true

  # Whether or not referer information should be used to redirect users after accepting an agreement
  # Default: true
  config.use_referers = true



  # Session Options (initializer or inline; stored in user session)

  # Whether or not to display the version of the agreement
  # Default: true
  config.display_version = true

  # Whether or not to display the last updated date for the agreement
  # Default: true
  config.display_last_updated = true

  # Path to redirect users to when referer information is unavailable
  # Default: "/"
  config.redirect_path = "/"

  # Whether or not to display a checkbox that has to be clicked before the user can accept the agreement
  # Default: true
  config.require_checkbox = true
  
end
