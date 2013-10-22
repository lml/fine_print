module FinePrint

  GET_SIGNATURES_OPTIONS = [
    :names
  ]

  SKIP_SIGNATURES_OPTIONS = [
    :names
  ]

  module ControllerAdditions

    def self.included(base)
      base.extend(ClassMethods)
    end

    def fine_print_skipped_contract_names
      @fine_print_skipped_contract_names ||= []
    end
    # attr_accessor :fine_print_skipped_contract_names

    module ClassMethods
      # def fine_print_skipped_contract_names
      #   @fine_print_skipped_contract_names ||= []
      # end

      def fine_print_get_signatures(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        filter_options = options.except(*FinePrint::GET_SIGNATURES_OPTIONS)
        fine_print_options = options.slice(*FinePrint::GET_SIGNATURES_OPTIONS)

        # Get the array of names into FP options, and normalize them
        fine_print_options[:names] = args
        fine_print_options[:names] = fine_print_options[:names].collect{|n| n.to_sym}

        class_eval do
          before_filter(filter_options) do |controller|
            fine_print_skipped_contract_names.each do |name|
              fine_print_options[:names].delete(name.to_sym)
            end

            fine_print_options[:user] = self.send FinePrint.current_user_method

            FinePrint.get_signatures(fine_print_options)
          end
        end
      end

      def fine_print_skip_signatures(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        names = args

        filter_options = options.except(*FinePrint::SKIP_SIGNATURES_OPTIONS)
        fine_print_options = options.slice(*FinePrint::SKIP_SIGNATURES_OPTIONS)

        class_eval do
          prepend_before_filter(filter_options) do |controller|
            fine_print_skipped_contract_names.push(*names)
          end
        end
      end

    end

  end
end

ActionController::Base.send :include, FinePrint::ControllerAdditions