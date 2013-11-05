require "fine_print/engine"
require "fine_print/security_transgression"
require "fine_print/controller_additions"

module FinePrint
  ASSET_FILES = %w()

  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_method,
    :user_admin_proc,
    :pose_contracts_path,
    :user_signed_in_proc,
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

  # Accepts a hash containing:
  #   - :names -- an array of contract names
  #   - :user -- the user in question
  # and returns an array of names for the contracts whose latest published
  # version the given user has not signed.
  #
  def self.get_unsigned_contract_names(options={})
    return [] if options[:names].blank? || options[:user].nil?
    options[:names] = [options[:names]].flatten.collect{|name| name.to_s}

    signed_contracts = FinePrint::Contract
      .where(name: options[:names].collect{|name| name.to_s})
      .where(is_latest:true)
      .joins('LEFT OUTER JOIN fine_print_signatures ON fine_print_signatures.contract_id = fine_print_contracts.id')
      .where("fine_print_signatures.user_id = #{options[:user].id}")
      .where("fine_print_signatures.user_type = '#{options[:user].class.name}'")

    signed_contract_names = signed_contracts.collect{|c| c.name}

    return options[:names] - signed_contract_names
  end

  # Records that the given user has signed the given contract; the contract
  # can be a Contract object, a contract ID, or a contract name (string)
  #
  def self.sign_contract(user, contract)
    contract = get_contract(contract)

    Signature.create do |signature|
      signature.user = user
      signature.contract = contract
    end
  end

  # Returns true iff the given user has signed the given contract; the contract
  # can be a Contract object, a contract ID, or a contract name (string)
  #
  def self.has_signed_contract?(user, contract)
    contract = get_contract(contract)
    contract.signed_by?(user)
  end

  def self.is_admin?(user)
    !user.nil? && user_admin_proc.call(user)
  end

  # Gets a contract given either the contract's name or ID
  #
  def self.get_contract(reference)
    case reference
    when Integer
      Contract.find(reference)
    when String
      Contract.where(name: reference)
    end
  end
end
