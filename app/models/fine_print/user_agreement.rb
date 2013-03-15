module FinePrint
  class UserAgreement < ActiveRecord::Base
    attr_accessible :agreement_id

    belongs_to :agreement
    belongs_to :user, :polymorphic => true

    validates_presence_of :agreement, :user
  end
end
