require 'fine_print/engine'
require 'fine_print/security_transgression'
require 'fine_print/controller_additions'

module FinePrint
  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_proc,
    :user_admin_proc,
    :can_sign_contracts_proc,
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
  #   - contract -- can be a Contract object, its ID, or its name as a String or Symbol
  #
  def self.get_contract(reference)
    ref = Integer(reference) rescue reference
    case ref
    when Contract
      ref
    when Integer
      Contract.find(ref)
    when String, Symbol
      Contract.where(:name => ref.to_s).published.first
    end
  end

  # Records that the given user has signed the given contract
  #   - user -- the user in question
  #   - contract -- can be a Contract object, its ID, or its name as a String or Symbol
  #
  def self.sign_contract(user, contract)
    raise_unless_can_sign(user)
    contract = get_contract(contract)
    raise IllegalState, 'Contract not found' if contract.nil?

    Signature.create do |signature|
      signature.user = user
      signature.contract = contract
    end
  end

  # Returns true iff the given user has signed the given contract
  #   - user -- the user in question
  #   - contract -- can be a Contract object, its ID, or its name as a String or Symbol
  #
  def self.signed_contract?(user, contract)
    raise_unless_can_sign(user)
    contract = get_contract(contract)

    !contract.signatures.where(:user_id => user.id,
                               :user_type => user.class.name).first.nil?
  end

  # Returns true iff the given user has signed any version of the given contract
  #   - user -- the user in question
  #   - contract -- can be a Contract object, its ID, or its name as a String or Symbol
  def self.signed_any_contract_version?(user, contract)
    raise_unless_can_sign(user)
    contract = get_contract(contract)
    !Signature.joins(:contract)
              .where(:fine_print_contracts => {:name => contract.name},
                     :user_type => user.class.name,
                     :user_id => user.id).first.nil?
  end

  # Returns an array of names for the contracts whose latest published
  # version the given user has not signed.
  #   - user -- the user in question
  #   - names -- contract names to check
  #
  def self.get_unsigned_contract_names(user, *names)
    raise_unless_can_sign(user)
    names = names.flatten.collect{|name| name.to_s}
    return [] if names.blank?

    signed_contracts = Contract
      .joins(:signatures)
      .where({:name => names,
              :fine_print_signatures => {:user_id => user.id,
                                         :user_type => user.class.name}}).latest
    signed_contract_names = signed_contracts.collect{|c| c.name}

    return names - signed_contract_names
  end

  def self.can_sign?(user)
    can_sign_contracts_proc.call(user)
  end

  def self.is_admin?(user)
    !user.nil? && user_admin_proc.call(user)
  end

  def self.raise_unless_can_sign(user)
    raise IllegalState, 'User cannot sign contracts' unless can_sign?(user)
  end

  def self.raise_unless_admin(user)
    raise SecurityTransgression unless is_admin?(user)
  end
end
