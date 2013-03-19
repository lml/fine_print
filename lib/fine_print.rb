require "fine_print/engine"
require "fine_print/fine_print_agreement"

module FinePrint
  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_method,
    :user_admin_proc
  ]

  # Can be set in initializer or passed as an option to fine_print_agreement
  AGREEMENT_OPTIONS = [
    :agreement_notice,
    :display_version,
    :display_last_updated,
    :grace_period,
    :grace_period_on_new_version_only,
    :use_referers,
    :redirect_path,
    :require_checkbox
  ]
  
  (ENGINE_OPTIONS + AGREEMENT_OPTIONS).each do |option|
    mattr_accessor option
  end
  
  def self.configure
    yield self
  end

  def self.require_agreements(controller, names, options)
    user = controller.send FinePrint.current_user_method
    names.each do |name|
      agreement = Agreement.latest_ready(name)
      unless agreement.accepted_by?(user)
        if FinePrint.use_referers
          controller.session[:fine_print_request_url] = controller.request.url
          controller.session[:fine_print_request_referer] = controller.request.referer
        end
        controller.redirect_to controller.fine_print.agreement_path(agreement),
          :notice => FinePrint.agreement_notice
        return false
      end
    end
  end

  def self.is_admin?(user)
    !user.nil? && user_admin_proc.call(user)
  end
end
