module FinePrint
  module ControllerIncludes
    def self.included(base)
      base.extend(ClassMethods)
    end

    # For the following methods, names passed as Symbols are converted to Strings.

    # Accepts an array of contract names
    # Returns nil if the array is blank or the current user cannot sign contracts
    # Otherwise, returns the contract names that the user hasn't signed yet
    def fine_print_get_unsigned_contract_names(*names)
      # Convert names to an array of Strings
      contract_names = names.flatten.collect{|n| n.to_s}

      user = FinePrint.current_user_proc.call(self)
      
      # If the user isn't signed in, they can't sign a contract
      # Since there may be some pages that both logged in and non-logged in users
      # can visit, we just return quietly instead of raising an exception
      return nil if contract_names.blank? || !FinePrint.can_sign?(user)

      FinePrint.get_unsigned_contract_names(user, contract_names)
    end

    # Accepts an array of contract names to be signed and an options hash
    # Saves the current request path and redirects the user to the
    # `sign_contract_path`, with an appended parameter contract_param
    # containing the unsigned contract names
    def fine_print_redirect(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      contract_names = args.flatten.collect{|n| n.to_s}

      path = options[:sign_contract_path] || FinePrint.sign_contract_path
      param_name = options[:contract_param] || FinePrint.contract_param

      # http://stackoverflow.com/a/6561953
      redirect_path = path + (path.include?('?') ? '&' : '?') + \
                        {param_name.to_sym => contract_names}.to_query

      # Prevent redirect loop
      return if view_context.current_page?(redirect_path)

      # Use action_interceptor to save the current url
      with_interceptor { redirect_to redirect_path }
    end

    # Accepts no arguments
    # Redirects the user to the path saved by action_interceptor
    def fine_print_return
      redirect_back
    end

    protected

    def fine_print_skipped_contract_names
      @fine_print_skipped_contract_names ||= []
    end

    module ClassMethods
      # Accepts an array of contract names and an options hash
      # Adds a before_filter to the current controller that will check if the
      # current user has signed the given contracts and redirect them to
      # `contract_redirect_path` if appropriate
      # Options relevant to FinePrint are passed to fine_print_redirect, while
      # other options are passed to the before_filter
      def fine_print_get_signatures(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        filter_options = options.except(*FinePrint::CONTRACT_OPTIONS)
        fine_print_options = options.slice(*FinePrint::CONTRACT_OPTIONS)

        # Convert names to an array of Strings
        contract_names = args.flatten.collect{|n| n.to_s}

        class_eval do
          before_filter(filter_options) do |controller|
            skipped_contract_names = controller.fine_print_skipped_contract_names
            names = contract_names - skipped_contract_names

            # Return quietly if all contracts skipped
            next if names.blank?

            user = FinePrint.current_user_proc.call(self)

            unsigned_contract_names = fine_print_get_unsigned_contract_names(
                                        names, fine_print_options)

            # Return quietly if no contracts left to sign
            next if unsigned_contract_names.blank?

            unless FinePrint.can_sign?(user)
              next if fine_print_options[:ignore_if_cannot_sign] || \
                        (fine_print_options[:ignore_if_cannot_sign].nil? && \
                          FinePrint.ignore_if_cannot_sign)

              raise IllegalState, 'Current user cannot sign contracts'
            end

            controller.fine_print_redirect(unsigned_contract_names, fine_print_options)
          end
        end
      end

      # Accepts an array of contract names and an options hash
      # Excludes the given contracts from the `fine_print_get_signatures` check for
      # this controller and subclasses
      # Options are passed to prepend_before_filter
      def fine_print_skip_signatures(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        # Convert all names to string
        names = args.flatten.collect{|n| n.to_s}

        class_eval do
          prepend_before_filter(options) do |controller|
            controller.fine_print_skipped_contract_names.push(*names)
          end
        end
      end
    end
  end
end

ActionController::Base.send :include, FinePrint::ControllerIncludes
