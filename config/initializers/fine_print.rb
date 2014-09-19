# Change the settings below to suit your needs
# All options are initially set to their default values
FinePrint.configure do |config|

  # Engine Configuration

  # Proc called with a controller as argument.
  # Returns the current user.
  # Default: lambda { |controller| controller.current_user }
  config.current_user_proc = lambda { |controller| controller.current_user }

  # Proc called with a user as argument.
  # If it returns true, the user is considered to be a contract manager.
  # Contract managers can create and edit agreements and terminate accepted agreements.
  # Default: lambda { |user| false } (no contract managers)
  config.manager_proc = lambda { |user| false }

  # Proc called with a user as argument
  # Returns true iif the argument the user is allowed to sign a contract.
  # In many systems, a non-logged-in user is represented by nil.
  # However, some systems use something like an AnonymousUser class to represent this state.
  # In general, you don't want anonymous users signing contracts.
  # Default: lambda { |user| !!user }
  config.can_sign_proc = lambda { |user| !!user }

  # Proc that raises an Exception when an unauthorized user accesses FinePrint's controllers.
  # Default: lambda { raise ActionController::RoutingError, 'Not Found' }
  config.security_transgression_proc = lambda { raise ActionController::RoutingError, 'Not Found' }

  # Contract Configuration

  # What to call the url or json parameter that holds contract names
  # This is visible to the user in the url or in json responses
  # Default: 'contracts'
  config.contracts_param = 'contracts'

  # Path to redirect users to when they need to agree to contract(s).
  # A list of contract names that must be agreed to will be available in the `contract_param`.
  # Your code doesn't have to deal with all of them at once, e.g. you can get
  # the user to agree to the first one and then they'll just eventually be
  # redirected back to this page with the remaining contract names.
  # Default: '/'
  config.sign_contracts_path = '/'

end
