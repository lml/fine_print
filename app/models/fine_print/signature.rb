module FinePrint
  class Signature < ActiveRecord::Base
    belongs_to :contract, inverse_of: :signatures
    belongs_to :user, polymorphic: true

    before_update { false } # no changes allowed

    validate :contract_published, on: :create

    validates :contract, presence: true
    validates :contract_id, uniqueness: { scope: [:user_type, :user_id] }
    validates :user, presence: true

    default_scope { order(:contract_id, :user_type, :user_id) }

    def is_explicit?
      !is_implicit?
    end

    protected

    ##############
    # Validation #
    ##############

    def contract_published
      return if contract.is_published?
      errors.add(
        :contract, I18n.t('fine_print.signature.errors.contract.not_published')
      )
      throw :abort
    end
  end
end
