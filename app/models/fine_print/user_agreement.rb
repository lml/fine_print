module FinePrint
  class UserAgreement < ActiveRecord::Base
    attr_accessible :agreement_id, :user_id
  end
end
