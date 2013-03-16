module FinePrint
  class UserAgreement < ActiveRecord::Base
    belongs_to :agreement
    belongs_to :user, :polymorphic => true

    validates_presence_of :agreement, :user
    validates_uniqueness_of :user_id, :scope => [:agreement_id, :user_type]

    default_scope order(:agreement_id, :user_type, :user_id)

    def self.can_be_listed_by?(user)
      FinePrint.is_admin?(user)
    end

    def can_be_destroyed_by?(user)
      FinePrint.is_admin?(user)
    end
  end
end
