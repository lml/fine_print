require 'fine_print/engine'
require 'fine_print/controller_includes'

module FinePrint
  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_proc,
    :can_manage_proc,
    :can_sign_proc,
    :layout,
    :helpers
  ]

  # Can be set in initializer or passed as an argument
  # to FinePrint controller methods
  CONTROLLER_OPTIONS = [
    :must_sign_proc
  ]
  
  (ENGINE_OPTIONS + CONTROLLER_OPTIONS).each do |option|
    mattr_accessor option
  end
  
  def self.configure
    yield self
  end

  # Gets a contract, given either the contract object, ID or name
  # If given a name, it returns the latest published version of that contract
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  def self.get_contract(reference)
    return reference if reference.is_a? Contract
    num = Integer(reference) rescue nil
    return Contract.find(num) if num
    contract = Contract.where(:name => reference.to_s).published.first
    return contract if contract
    raise ActiveRecord::RecordNotFound, "Couldn't find Contract with 'name'=#{reference.to_s}"
  end

  # Records that the given user has signed the given contract
  #   - user - the user in question
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  def self.sign_contract(user, contract)
    contract = get_contract(contract)

    Signature.create do |signature|
      signature.user = user
      signature.contract = contract
    end
  end

  # Returns true iff the given user has signed the given contract
  #   - user - the user in question
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  def self.signed_contract?(user, contract)
    contract = get_contract(contract)

    contract.signatures.where(:user_id => user.id,
                              :user_type => user.class.name).exists?
  end

  # Returns true iff the given user has signed any version of the given contract
  #   - user - the user in question
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  def self.signed_any_version_of_contract?(user, contract)
    contract = get_contract(contract)

    contract.same_name.includes(:signatures).any? do |c|
      c.signatures.where(:user_id => user.id,
                         :user_type => user.class.name).exists?
    end
  end

  # Converts an array of contract names into an array containing
  # the latest contract id for each given name.
  def self.contract_names_to_ids(*contract_names)
    names = contract_names.flatten
    Contract.latest.where(:name => names).pluck(:id)
  end

  # Returns an array of ids for the contracts among those given
  # whose latest published version the user has signed.
  #   - user - the user in question
  #   - contract_ids - contract ids to check
  # If no contract ids are provided, all latest contracts are checked
  def self.get_signed_contract_ids(user, *contract_ids)
    ids = contract_ids.flatten
    ids = Contract.published.latest.pluck(:id) if ids.blank?

    Signature.where(:user_id => user.id,
                    :user_type => user.class.name,
                    :contract_id => ids).pluck(:contract_id)
  end

  # Returns an array of ids for the contracts among those given
  # whose latest published version the user has not signed.
  #   - user - the user in question
  #   - contract_ids - contract ids to check
  # If no contract ids are provided, all latest contracts are checked
  def self.get_unsigned_contract_ids(user, *contract_ids)
    ids = contract_ids.flatten
    ids = Contract.published.latest.pluck(:id) if ids.blank?

    ids - get_signed_contract_ids(user, ids)
  end

end
