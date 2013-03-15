module FinePrint
  class UserAgreement < ActiveRecord::Base
    attr_accessible :agreement_id

    belongs_to :agreement
    belongs_to :user, :polymorphic => true

    validates_presence_of :agreement, :user

    def self.can_be_listed_by?(user)
      FinePrint.is_admin?(user)
    end

    def can_be_destroyed_by?(user)
      FinePrint.is_admin?(user)
    end
  end
end
