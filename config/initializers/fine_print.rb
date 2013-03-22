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

  # Path to redirect users to when an error occurs (e.g. permission denied on admin pages)
  # Default: "/"
  config.redirect_path = "/"

  # Path to link users to if they need to sign in
  # Set to nil to disable the link
  # Default: "/"
  config.sign_in_path = "/"



  # Agreement Options (initializer or inline)

  # Message to be displayed to the user explaining that they need to accept an agreement
  # Set to nil to disable
  # Default: "You must accept the following agreement to proceed."
  config.agreement_notice = "You must accept the following agreement to proceed."

  # Path to redirect users to when an agreement is accepted and referer information is unavailable
  # Default: "/"
  config.accept_path = "/"

  # Path to redirect users to when an agreement is not accepted and referer information is unavailable
  # Default: "/"
  config.cancel_path = "/"

  # Whether to use referer information to redirect users after (not) accepting an agreement
  # Default: true
  config.use_referers = true

  # If set to true, modal jQuery UI dialogs will be used instead of redirecting the user to the agreement page
  # Note: users with javascript disabled will not even see the agreement and will be able to proceed without accepting it
  #       if users are not supposed to ever see or interact with a certain page without accepting the agreement,
  #       disable this option for that particular controller action
  # Default: false
  config.use_modal_dialogs = false
  
end
