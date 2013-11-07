module FinePrint
  module Utilities
    # Returns true iff the given user has signed any version of the given contract.
    #   contract -- can be a Contract object, its ID, or its name as a String or Symbol
    def self.any_signed_contract_version?(contract, user)
      contract = FinePrint::get_contract(contract)
      !user.nil? && 
      !Signature.joins(:contract)
                .where(:contract => {:name => contract.name},
                       :user_type => user.class.name,
                       :user_id => user.id).first.nil?
    end

    # Returns the latest version of the named contract (since contracts don't have
    # versions until they are published this only returns published contracts).
    # If no such contract exists, returns nil.  
    #   name -- can be a String or a Symbol
    def self.latest_contract_named(name)
      Contract.where(:name => name.to_s).latest.first
    end
  end
end
