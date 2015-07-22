module FinePrint
  class Configuration
    # Attributes

    # Can be set in initializer only
    ENGINE_OPTIONS = [
      :helpers,
      :layout,
      :authenticate_user_proc,
      :authenticate_manager_proc,
      :current_user_proc,
      :contract_published_proc
    ]

    # Can be set in initializer or passed as an argument
    # to FinePrint controller methods
    CONTROLLER_OPTIONS = [
      :redirect_to_contracts_proc
    ]

    (ENGINE_OPTIONS + CONTROLLER_OPTIONS).each do |option|
      attr_accessor option
    end
  end
end
