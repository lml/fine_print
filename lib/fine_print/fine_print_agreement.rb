module FinePrint
  module FinePrintAgreement
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def fine_print_agreement(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        class_eval do
          before_filter(options.except(*FinePrint::AGREEMENT_OPTIONS)) do |controller|
            FinePrint.require_agreements(controller, args, options.slice(*FinePrint::AGREEMENT_OPTIONS))
          end
        end
      end

      #alias_method :fine_print, :fine_print_agreement
      alias_method :fine_print_agreements, :fine_print_agreement
    end
  end
end

ActionController::Base.send :include, FinePrint::FinePrintAgreement

