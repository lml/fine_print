module FinePrint
  module ControllerIncludes
    def self.included(base)
      base.extend(ClassMethods)
    end

    # For the following methods, names passed as Symbols are converted to Strings.

    # Accepts an array of contract names
    # Returns nil if the array is blank or the current user cannot sign contracts
    # Otherwise, returns the contract names that the user hasn't signed yet
    def fine_print_get_unsigned_contract_names(*contract_names)
      # Convert names to an array of Strings
      names = contract_names.flatten.collect{|n| n.to_s}

      user = FinePrint.current_user_proc.call(self)
      
      # If the user isn't signed in, they can't sign a contract
      # Since there may be some pages that both logged in and non-logged in users
      # can visit, we just return quietly instead of raising an exception
      return nil if names.blank? || !FinePrint.can_sign?(user)

      # Ignore contracts that don't yet exist or aren't yet published (happens 
      # when adding code that requires a new contract but before that contract 
      # has been added and published)
      FinePrint.get_unsigned_contract_names(user, names)
               .reject{|name| FinePrint.get_contract(name).blank?}
    end

    # Accepts an array of unsigned contract names and an options hash
    # Unless the array of unsigned contract names is blank or the request url is
    # already the contract_redirect_path, it saves the current request path and
    # redirects the user to the `contract_redirect_path`, with
    # `contract_param_name` containing the unsigned contract names
    def fine_print_redirect(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      unsigned_contract_names = args.flatten
      return if unsigned_contract_names.nil? ||\
                unsigned_contract_names.all? { |n| n.blank? }

      path = options[:contract_redirect_path] || FinePrint.contract_redirect_path
      param_name = options[:contract_param_name] || FinePrint.contract_param_name

      # http://stackoverflow.com/a/6561953
      redirect_path = path + (path.include?('?') ? '&' : '?') +\
                      {param_name.to_sym => unsigned_contract_names}.to_query

      # Prevent redirect loop
      return if view_context.current_page?(redirect_path)

      # http://stackoverflow.com/a/2165727/1664216
      session[:fine_print_return_to] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      redirect_to redirect_path
    end

    # Accepts no arguments
    # Redirects the user to the path saved by either
    # `fine_print_get_signatures` or `fine_print_redirect`
    def fine_print_return
      redirect_to session.delete(:fine_print_return_to) || root_path
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
            controller.fine_print_redirect(
              controller.fine_print_get_unsigned_contract_names(contract_names - controller.fine_print_skipped_contract_names),
              fine_print_options)
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
