module FinePrint
  module ControllerAdditions
    #
    # Internally these methods think of contract names as strings, not symbols.
    # Any names passed in as symbols are converted to strings.
    #
    def self.included(base)
      base.extend(ClassMethods)
    end

    def fine_print_skipped_contract_names
      @fine_print_skipped_contract_names ||= []
    end

    # See the README
    def fine_print_return
      redirect_to session.delete(:fine_print_return_to) || root_path
    end

    module ClassMethods
      # See the README
      def fine_print_get_signatures(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        filter_options = options.except(*FinePrint::SIGNATURE_OPTIONS)
        fine_print_options = options.slice(*FinePrint::SIGNATURE_OPTIONS)

        # Convert all names to string
        names = args.collect{|n| n.to_s}

        class_eval do
          before_filter(filter_options) do |controller|
            names_to_check = names - fine_print_skipped_contract_names

            # Bail if nothing to do
            return true if names_to_check.blank?

            user = send FinePrint.current_user_method
            FinePrint.raise_unless_signed_in(user)

            unsigned_contract_names = 
              FinePrint.get_unsigned_contract_names(names_to_check, user)
            return true if unsigned_contract_names.empty?

            # http://stackoverflow.com/a/2165727/1664216
            session[:fine_print_return_to] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
            # http://stackoverflow.com/a/6561953
            path = fine_print_options[:pose_contracts_path] || FinePrint.pose_contracts_path
            redirect_to path + (path.include?('?') ? '&' : '?') + {:terms => unsigned_contract_names}.to_query
          end
        end
      end

      # See the README
      def fine_print_skip_signatures(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        names = args.collect{|arg| arg.to_s}

        class_eval do
          prepend_before_filter(options) do |controller|
            fine_print_skipped_contract_names.push(*names)
          end
        end
      end
    end
  end
end

ActionController::Base.send :include, FinePrint::ControllerAdditions
