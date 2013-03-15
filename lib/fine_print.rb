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
    :read_checkbox,
    :grace_period,
    :grace_period_on_new_version_only
  ]
  
  (ENGINE_OPTIONS + AGREEMENT_OPTIONS).each do |option|
    mattr_accessor option
  end
  
  def self.configure
    yield self
  end

  def self.require_agreements(controller, names, options)
    names.each do |name|
      print(name)
    end
    controller.redirect_to :root
  end

  def self.is_admin?(user)
    user_admin_proc.call(user)
  end
end
