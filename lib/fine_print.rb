require 'fine_print/configuration'
require 'fine_print/engine'

module FinePrint

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield config
  end

  # Gets a contract, given either the contract object, ID or name
  # If given a name, returns the latest published version of that contract
  #   - contract - can be a Contract object, its ID, or its name
  def self.get_contract(reference)
    return reference if reference.is_a? Contract
    num = Integer(reference) rescue nil
    return Contract.find(num) if num
    contract = Contract.where(name: reference.to_s).published.first
    return contract if contract
    raise ActiveRecord::RecordNotFound,
          "Couldn't find Contract with 'name'=#{reference.to_s}"
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
    return false if user.nil?

    contract = get_contract(contract)

    contract.signatures.where(user_id: user.id,
                              user_type: user.class.name).exists?
  end

  # Returns true iff the given user has signed any version of the given contract
  #   - user - the user in question
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  def self.signed_any_version_of_contract?(user, contract)
    return false if user.nil?

    contract = get_contract(contract)

    contract.same_name.joins(:signatures).where(
      signatures: { user_id: user.id, user_type: user.class.name }
    ).exists?
  end

  # Returns all the latest published contracts that match the given conditions.
  def self.latest_published_contracts(conditions = {})
    Contract.published.latest.where(conditions)
  end

  # Returns all contracts matching the given conditions
  # whose latest published version the user has signed.
  #   - user - the user in question
  #   - conditions - filters the list of contracts to check
  # If no conditions are provided, all latest contracts are checked.
  def self.signed_contracts_for(user, conditions = {})
    return [] if user.nil?

    contracts = latest_published_contracts(conditions)
    contracts.joins(:signatures).where(
      signatures: { user_id: user.id, user_type: user.class.name }
    )
  end

  # Returns all contracts matching the given conditions
  # whose latest published version the user has not signed.
  #   - user - the user in question
  #   - conditions - filters the list of contracts to check
  # If no conditions are provided, all latest contracts are checked.
  def self.unsigned_contracts_for(user, conditions = {})
    contracts = latest_published_contracts(conditions)
    signed_contracts = signed_contracts_for(user, conditions)
    unsigned_contracts = contracts - signed_contracts

    # Reject proxy-signed contracts and lazily store automatic signatures for
    # proxy-signed contracts so that they no longer show up in this unsigned
    # list.
    unsigned_contracts.reject do |contract|
      contract.is_signed_by_proxy? && sign_contract(user, contract)
    end
  end

end
