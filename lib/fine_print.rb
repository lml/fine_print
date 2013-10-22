require "fine_print/engine"
require "fine_print/security_transgression"

module FinePrint
  ASSET_FILES = %w(dialog.js)

  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_method,
    :user_admin_proc,
    :sign_contract_proc,
    :redirect_path
  ]
  
  (ENGINE_OPTIONS).each do |option|
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

  def self.get_unsigned_contract_names(options={})
    return [] if options[:names].blank? || options[:user].nil?
    options[:names] = [options[:names]].flatten

    signed_contracts = FinePrint::Contract
      .where(name: options[:names])
      .where(is_latest:true)
      .joins('LEFT OUTER JOIN fine_print_signatures ON fine_print_signatures.contract_id = fine_print_contracts.id')
      .where("fine_print_signatures.user_id = #{options[:user].id}")
      .where("fine_print_signatures.user_type = '#{options[:user].class.name}'")

    signed_contract_names = signed_contracts.collect{|c| c.name}

    return options[:names] - signed_contract_names
  end

  # def self.get_signatures!(contract_names, user)
  #   raise IllegalArgument, "A user must be provided" if user.nil?

  #   unsigned_contract_names = FinePrint.get_unsigned_agreement_names(names: [names], user: current_user)

  #   return true if unsigned_agreement_names.empty?

  #   session[:terms_return_to] = request.referrer

  #   pose_contracts_proc.call(unsigned_agreement_names, request.referrer)

  #   redirect_to somewhere based on unsigned_agreement_names.first
  # end

  def self.require_agreement_signature(names)

  end

  # Records that the given user has signed the given contract; the contract
  # can be a Contract object, a contract ID, or a contract name (string)
  def self.sign_agreement(user, contract)
    contract = Contract.find(contract) if contract.is_a? Integer
    contract = Contract.where(name: contract) if contract.is_a? String

    Signature.create do |signature|
      signature.user = user
      signature.contract = contract
    end
  end

  def self.is_admin?(user)
    !user.nil? && user_admin_proc.call(user)
  end
end
