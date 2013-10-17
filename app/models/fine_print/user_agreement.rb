module FinePrint
  class UserAgreement < ActiveRecord::Base
    belongs_to :agreement
    belongs_to :user, :polymorphic => true

    validates_presence_of :agreement, :user_id
    validates_uniqueness_of :user_id, :scope => [:agreement_id, :user_type]

    validate :agreement_published

    default_scope order(:agreement_id, :user_type, :user_id)

  protected

    def agreement_published
      errors.add(:agreement, "needs to be published before it can be accepted") \
        if !agreement.published?
      errors.none?
    end

  end
end
