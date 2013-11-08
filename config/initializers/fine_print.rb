# Change the settings below to suit your needs
# All settings are initially set to their default values
FinePrint.configure do |config|
  # Engine Configuration

  # Name of the ApplicationController helper method that returns the current user.
  # Default: 'current_user'
  config.current_user_method = 'current_user'

  # Proc called with user as argument that should return true if and only if the user is an admin.
  # Admins can create and edit agreements and terminate accepted agreements.
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }

  # Proc that returns true if and only if the provided user is logged in.
  # In many systems, a non-logged-in user is represented by nil.
  # However, some systems use something like an AnonymousUser class to represent this state.
  # This proc is mostly used to help the developer realize that they should only be asking
  # signed in users to sign contracts; without this, developers would get a cryptic SQL error.
  # Default: lambda { |user| !user.nil? }
  config.user_signed_in_proc = lambda { |user| !user.nil? }

  # Path to redirect users to when an error occurs (e.g. permission denied on admin pages).
  # Default: '/'
  config.redirect_path = '/'

  # Signature (fine_print_get_signatures) Configuration

  # Path to redirect users to when they need to agree to contract(s).
  # A list of contract names that must be agreed to will be available in the 'contracts' parameter.
  # Your code doesn't have to deal with all of them at once, e.g. you can get
  # the user to agree to the first one and then they'll just eventually be
  # redirected back to this page with the remaining contract names.
  # Default: '/'
  config.pose_contracts_path = '/'
end
