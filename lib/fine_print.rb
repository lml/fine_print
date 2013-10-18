require "fine_print/engine"
require "fine_print/fine_print_agreement"
require "fine_print/security_transgression"

module FinePrint
  ASSET_FILES = %w(dialog.js)

  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_method,
    :user_admin_proc,
    :redirect_path,
    :sign_in_path
  ]

  # Can be set in initializer or passed as an option to fine_print_agreement
  AGREEMENT_OPTIONS = [
    :agreement_notice,
    :accept_path,
    :cancel_path,
    :use_referers,
    :use_modal_dialogs
  ]
  
  (ENGINE_OPTIONS + AGREEMENT_OPTIONS).each do |option|
    mattr_accessor option
  end

  ActiveSupport.on_load(:before_initialize) do
    Rails.configuration.assets.precompile += ASSET_FILES
  end
  
  def self.configure
    yield self
  end

  def self.get_option(options, name)
    (!options.nil? && !options[name].nil?) ? options[name] : self.send(name)
  end

  def self.get_unsigned_agreement_names(options={})
    return [] if options[:names].blank? || options[:user].nil?
    options[:names] = [options[:names]].flatten

    signed_agreements = FinePrint::Agreement
      .where(name: ['alpha','beta'])
      .where(is_latest:true)
      .joins('LEFT OUTER JOIN fine_print_user_agreements ON fine_print_user_agreements.agreement_id = fine_print_agreements.id')
      .where("fine_print_user_agreements.user_id = #{options[:user].id}")
      .where("fine_print_user_agreements.user_type = '#{options[:user].class.name}'")

    signed_agreement_names = signed_agreements.collect{|sa| sa.name}

    return options[:names] - signed_agreement_names
  end

  def self.record_user_agreement(user, agreement_or_id)
    agreement = agreement_or_id
    agreement = FinePrint::Agreement.find(agreement) if agreement.is_a? Integer

    UserAgreement.create do |ua|
      ua.user = user
      ua.agreement = agreement
    end
  end

  def self.is_admin?(user)
    !user.nil? && user_admin_proc.call(user)
  end
end
