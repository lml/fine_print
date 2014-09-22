module FinePrint
  module ControllerIncludes
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Accepts a user, an array of contract ids to be signed and an options hash
    # Calls the sign_proc with the given parameters
    def fine_print_sign(user, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      contract_ids = args.flatten.collect{|n| n.to_s}

      blk = options[:must_sign_proc] || FinePrint.must_sign_proc

      # Use action_interceptor to save the current url
      with_interceptor { instance_exec user, contract_ids, &blk }
    end

    # Accepts no arguments
    # Redirects the user back to the url they were at before
    # one of FinePrint's procs redirected them
    def fine_print_return
      redirect_back
    end

    protected

    def fine_print_skipped_contract_ids
      @fine_print_skipped_contract_ids ||= []
    end

    module ClassMethods
      # For the following methods, names passed as Symbols are converted to Strings.

      # Accepts an array of contract names and an options hash
      # Adds a before_filter to the current controller that will check if the
      # current user has signed the given contracts and call the sign_proc if appropriate
      # Options relevant to FinePrint are passed to fine_print_sign, while
      # other options are passed to the before_filter
      def fine_print_require(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        filter_options = options.except(*FinePrint::CONTROLLER_OPTIONS)
        fine_print_options = options.slice(*FinePrint::CONTROLLER_OPTIONS)

        # Convert names to an array of Strings
        contract_names = args.flatten.collect{|n| n.to_s}
        contract_ids = FinePrint.contract_names_to_ids(contract_names)

        class_eval do
          before_filter(filter_options) do |controller|
            skipped_contract_ids = controller.fine_print_skipped_contract_ids
            unskipped_contract_ids = contract_ids - skipped_contract_ids

            # Return quietly if all contracts skipped
            next if unskipped_contract_ids.blank?

            user = FinePrint.current_user_proc.call(self)

            unsigned_contract_ids = FinePrint.get_unsigned_contract_ids(
                                      user, unskipped_contract_ids)

            # Return quietly if no contracts left to sign
            next if unsigned_contract_ids.blank?

            controller.fine_print_sign(user, unsigned_contract_ids, fine_print_options)
          end
        end
      end

      # Accepts an array of contract names and an options hash
      # Excludes the given contracts from the `fine_print_require`
      # check for this controller and subclasses
      # Options are passed to prepend_before_filter
      def fine_print_skip(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        # Convert all names to string
        contract_names = args.flatten.collect{|n| n.to_s}

        class_eval do
          prepend_before_filter(options) do |controller|
            contract_ids = FinePrint.contract_names_to_ids(contract_names)
            controller.fine_print_skipped_contract_id.push(*contract_ids)
          end
        end
      end
    end
  end
end

ActionController::Base.send :include, FinePrint::ControllerIncludes
