module FinePrint
  class Signature < ActiveRecord::Base
    belongs_to :contract
    belongs_to :user, :polymorphic => true

    validates_presence_of :contract, :user_id
    validates_uniqueness_of :user_id, :scope => [:contract_id, :user_type]

    validate :contract_published

    default_scope order(:contract_id, :user_type, :user_id)

  protected

    def contract_published
      errors.add(:contract, "needs to be published before it can be signed") \
        if !contract.published?
      errors.none?
    end

  end
end
