# Change the settings below to suit your needs
# All options are initially set to their default values
FinePrint.configure do |config|

  # Engine Configuration
  # Must be set in an initializer

  # Layout to be used for FinePrint's controllers
  # Default: 'application'
  config.layout = 'application'

  # Array of custom helpers for FinePrint's controllers
  # Default: [] (no custom helpers)
  config.helpers = []

  # Proc called with a user as argument and a controller as self.
  # This proc is called when a user tries to access FinePrint's controllers.
  # Should raise and exception, render or redirect unless the user can manage contracts.
  # Contract managers can create and edit agreements and terminate accepted agreements.
  # The default renders 403 Forbidden for all users.
  # Note: Proc must account for nil users, if current_user_proc returns nil.
  # Default: lambda { |user| false || head(:forbidden) }
  config.authenticate_manager_proc = lambda { |user| false || head(:forbidden) }

  # Proc called with a user as argument and a controller as self.
  # This proc is called to check that the given user is allowed to sign contracts.
  # Should raise and exception, render or redirect unless the user can sign contracts.
  # You might want to redirect users to a login page if they are not signed in.
  # The default renders 401 Unauthorized for nil users.
  # Default: lambda { |user| !user.nil? || head(:unauthorized) }
  config.authenticate_user_proc = lambda { |user|
    !user.nil? || head(:unauthorized)
  }

  # Proc called with a controller as self.
  # Returns the current user.
  # Default: lambda { current_user }
  config.current_user_proc = lambda { current_user }

  # Controller Configuration
  # Can be set either in an initializer or passed as options to `fine_print_require`

  # This Proc is called with a user and an array of contracts as arguments
  # and a controller as self whenever a user tries to access a resource
  # protected by FinePrint, but has not signed all the required contracts.
  # Should raise and exception, render or redirect the user.
  # The `contracts` variable contains the contracts that need to be signed.
  # The default redirects users to FinePrint's contract signing views.
  # The `fine_print_return` method can be used
  # to return from a redirect made here.
  # Default: lambda { |user, contracts|
  #            redirect_to(
  #              fine_print.new_contract_signature_path(
  #                contract_id: contracts.first.id
  #              )
  #            )
  #          }
  config.redirect_to_contracts_proc = lambda { |user, contracts|
    redirect_to(
      fine_print.new_contract_signature_path(contract_id: contracts.first.id)
    )
  }

end
