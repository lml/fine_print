require 'fine_print/engine'
require 'fine_print/security_transgression'
require 'fine_print/controller_additions'

module FinePrint
  # Attributes
  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_method,
    :user_admin_proc,
    :user_signed_in_proc,
    :pose_contracts_path,
    :redirect_path
  ]
  
  (ENGINE_OPTIONS).each do |option|
    mattr_accessor option
  end
  
  def self.configure
    yield self
  end

  # Accepts the following arguments:
  #   - :names -- an array of contract names
  #   - :user -- the user in question
  # and returns an array of names for the contracts whose latest published
  # version the given user has not signed.
  #
  def self.get_unsigned_contract_names(names, user)
    return [] if names.blank? || user.nil?
    names = [names].flatten.collect{|name| name.to_s}

    signed_contracts = Contract
      .joins(:signatures)
      .where({:name => names,
              :fine_print_signatures => {:user_id => user.id,
                                         :user_type => user.class.name}}).latest
    signed_contract_names = signed_contracts.collect{|c| c.name}

    return names - signed_contract_names
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

  # Gets a contract given either the contract's object, ID or name
  #
  def self.get_contract(reference)
    case reference
    when Contract
      reference
    when Integer
      Contract.find(reference)
    when String
      Contract.where(:name => reference)
    end
  end
end
