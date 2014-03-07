module FinePrint
  class Signature < ActiveRecord::Base
    belongs_to :contract, :inverse_of => :signatures
    belongs_to :user, :polymorphic => true

    before_create :contract_published

    validates_presence_of :contract, :user_type, :user_id
    validates_uniqueness_of :contract_id, :scope => [:user_type, :user_id]

    default_scope { order(:contract_id, :user_type, :user_id) }

    protected

    ##############
    # Validation #
    ##############

    def contract_published
      return if contract.is_published?
      errors.add(:contract, 'needs to be published before it can be signed')
      false
    end
  end
end
