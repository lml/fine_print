require 'fine_print/engine'
require 'fine_print/controller_includes'

module FinePrint
  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_proc,
    :manager_proc,
    :can_sign_proc
  ]

  # Can be set in initializer or passed as an argument
  # to FinePrint controller methods
  CONTROLLER_OPTIONS = [
    :contract_param,
    :sign_contract_path
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
    raise IllegalState, 'User cannot sign contracts' unless can_sign?(user)
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

  # Returns an array of names for the contracts whose
  # latest published version the given user has signed.
  #   - user - the user in question
  #   - names - contract names to check
  def self.get_signed_latest_contract_names(user)
    Contract.latest.joins(:signatures)
            .where(:signatures => {:user_id => user.id,
                                   :user_type => user.class.name})
            .pluck(:name)
  end

  # Returns an array of names for the contracts among those given
  # whose latest published version the given user has not signed.
  #   - user - the user in question
  #   - contract_names - contract names to check
  # If no contract names are provided, all contracts are checked
  def self.get_unsigned_latest_contract_names(user, *contract_names)
    names = contract_names.flatten.collect{|name| name.to_s}
    names = Contract.uniq.pluck(:name) if names.blank?
    names - get_signed_latest_contract_names(user)
  end

  def self.can_sign?(user)
    !user.nil? && can_sign_proc.call(user)
  end

  def self.manager?(user)
    !user.nil? && manager_proc.call(user)
  end
end
