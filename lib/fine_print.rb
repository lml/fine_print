require 'fine_print/configuration'
require 'fine_print/engine'

module FinePrint

  SIGNATURE_IS_IMPLICIT = true
  SIGNATURE_IS_EXPLICIT = false

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
    raise ActiveRecord::RecordNotFound, "Couldn't find Contract with 'name'=#{reference.to_s}"
  end

  # Records that the given user has signed the given contract
  #   - user - the user in question
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  #   - is_implicit - if true, the signature is implicit/assumed/indirectly-acquired
  #                   if false, the signature was obtained directly from the user
  def self.sign_contract(user, contract, is_implicit = SIGNATURE_IS_EXPLICIT, max_attempts = 3)
    attempts = 0

    begin
      Signature.transaction(requires_new: true) do
        contract = get_contract(contract)

        Signature.create do |signature|
          signature.user = user
          signature.contract = contract
          signature.is_implicit = is_implicit
        end
      end
    rescue ActiveRecord::RecordNotUnique => exception
      attempts += 1
      raise exception if attempts >= max_attempts

      # Simply retry as in https://apidock.com/rails/v4.0.2/ActiveRecord/Relation/find_or_create_by
      # If it already exists, the validations should catch it this time
      retry
    end
  end

  # Returns true iff the given user has signed the given contract
  #   - user - the user in question
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  def self.signed_contract?(user, contract)
    return false if user.nil?

    contract = get_contract(contract)

    contract.signatures.where(user_id: user.id, user_type: user.class.base_class.name).exists?
  end

  # Returns true iff the given user has signed any version of the given contract
  #   - user - the user in question
  #   - contract - can be a Contract object, its ID, or its name (String/Symbol)
  def self.signed_any_version_of_contract?(user, contract)
    return false if user.nil?

    contract = get_contract(contract)

    contract.same_name.joins(:signatures).where(
      signatures: { user_id: user.id, user_type: user.class.base_class.name }
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
      signatures: { user_id: user.id, user_type: user.class.base_class.name }
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
    contracts - signed_contracts
  end

end
