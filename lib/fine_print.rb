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

  # Can be set in initializer or passed as an option to fine_print_get_signatures
  SIGNATURE_OPTIONS = [
    :pose_contracts_path
  ]
  
  (ENGINE_OPTIONS + SIGNATURE_OPTIONS).each do |option|
    mattr_accessor option
  end
  
  def self.configure
    yield self
  end

  # Gets a contract given either the contract's object, ID or name
  # If given a name, it returns the latest published version of that contract
  #
  def self.get_contract(reference)
    ref = Integer(reference) rescue reference
    case ref
    when Contract
      ref
    when Integer
      Contract.find(ref)
    when String
      Contract.where(:name => ref).published.first
    end
  end

  # Returns an array of names for the contracts whose latest published
  # version the given user has not signed.
  #   - names -- an array of contract names
  #   - user -- the user in question
  #
  def self.get_unsigned_contract_names(names, user)
    raise_unless_signed_in(user)
    return [] if names.blank?
    names_array = names.is_a?(Array) ? names.collect{|name| name.to_s} : [names.to_s]

    signed_contracts = Contract
      .joins(:signatures)
      .where({:name => names_array,
              :fine_print_signatures => {:user_id => user.id,
                              :user_type => user.class.name}}).latest
    signed_contract_names = signed_contracts.collect{|c| c.name}

    return names - signed_contract_names
  end

  # Records that the given user has signed the given contract; the contract
  # can be a Contract object, a contract ID, or a contract name (string)
  #
  def self.sign_contract(contract, user)
    raise_unless_signed_in(user)
    contract = get_contract(contract)
    raise IllegalState, 'Contract not found' if contract.nil?

    Signature.create do |signature|
      signature.user = user
      signature.contract = contract
    end
  end

  # Returns true iff the given user has signed the given contract; the contract
  # can be a Contract object, a contract ID, or a contract name (string)
  #
  def self.signed_contract?(contract, user)
    raise_unless_signed_in(user)
    contract = get_contract(contract)

    !contract.signatures.where(:user_id => user.id,
                               :user_type => user.class.name).first.nil?
  end

  # Returns true iff the given user has signed any version of the given contract.
  #   - contract -- can be a Contract object, its ID, or its name as a String or Symbol
  def self.signed_any_contract_version?(contract, user)
    raise_unless_signed_in(user)
    contract = get_contract(contract)
    !Signature.joins(:contract)
              .where(:fine_print_contracts => {:name => contract.name},
                     :user_type => user.class.name,
                     :user_id => user.id).first.nil?
  end

  def self.is_signed_in?(user)
    user_signed_in_proc.call(user)
  end

  def self.is_admin?(user)
    is_signed_in?(user) && user_admin_proc.call(user)
  end

  def self.raise_unless_signed_in(user)
    raise IllegalState, 'User not signed in' unless is_signed_in?(user)
  end

  def self.raise_unless_admin(user)
    raise SecurityTransgression unless is_admin?(user)
  end
end
