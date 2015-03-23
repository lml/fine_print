module FinePrint
  class Signature < ActiveRecord::Base
    belongs_to :contract, :inverse_of => :signatures
    belongs_to :user, :polymorphic => true

    validate :contract_published, :on => :create

    validates :contract, :presence => true
    validates :contract_id, :uniqueness => {:scope => [:user_type, :user_id]}
    validates :user, :presence => true

    default_scope { order(:contract_id, :user_type, :user_id) }

    protected

    ##############
    # Validation #
    ##############

    def contract_published
      return if contract.is_published?
      errors.add(:contract, I18n.t(
        'fine_print.signature.errors.contract.not_published'))
      false
    end
  end
end
