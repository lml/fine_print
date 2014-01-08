# Change the settings below to suit your needs
# All settings are initially set to their default values
FinePrint.configure do |config|
  # Engine Configuration

  # Proc called with controller as argument that returns the current user.
  # Default: lambda { |controller| controller.current_user }
  config.current_user_proc = lambda { |controller| controller.current_user }

  # Proc called with user as argument that returns true iif the user is an admin.
  # Admins can create and edit agreements and terminate accepted agreements.
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }

  # Proc called with user as argument that returns true iif the argument is a user
  # who can sign a contract.  In many systems, a non-logged-in user is represented by nil.
  # However, some systems use something like an AnonymousUser class to represent this state.
  # This proc is mostly used to help the developer realize that they should only be asking
  # signed in users to sign contracts; without this, developers would get a cryptic SQL error.
  # Default: lambda { |user| user }
  config.can_sign_contracts_proc = lambda { |user| user }

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
