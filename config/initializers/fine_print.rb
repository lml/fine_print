# Change the settings below to suit your needs
# All options are initially set to their default values
FinePrint.configure do |config|
  # Engine Configuration

  # Proc called with a controller as argument.
  # Returns the current user.
  # Default: lambda { |controller| controller.current_user }
  config.current_user_proc = lambda { |controller| controller.current_user }

  # Proc called with a user as argument.
  # Returns true iif the user is an admin.
  # Admins can create and edit agreements and terminate accepted agreements.
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }

  # Proc called with a user as argument
  # Returns true iif the argument the user is allowed to sign a contract.
  # In many systems, a non-logged-in user is represented by nil.
  # However, some systems use something like an AnonymousUser class to represent this state.
  # If this proc returns false, FinePrint will not ask for signatures and will not
  # redirect the user, so it's up to the developer to make sure that unsigned users
  # can't access pages that should require a signed contract to use.
  # Default: lambda { |user| !!user }
  config.user_can_sign_proc = lambda { |user| !!user }



  # Contract Configuration

  # What to call the contract names param, passed when the user is redirected
  # This is visible to the user in the Url
  # Default: 'contracts'
  config.contract_param_name = 'contracts'

  # Path to redirect users to when they need to agree to contract(s).
  # A list of contract names that must be agreed to will be available in the `contract_param_name` parameter.
  # Your code doesn't have to deal with all of them at once, e.g. you can get
  # the user to agree to the first one and then they'll just eventually be
  # redirected back to this page with the remaining contract names.
  # Default: '/'
  config.contract_redirect_path = '/'
end
