require 'rspec-rails'

FactoryGirl.define do
  factory :user_agreement, class: FinePrint::UserAgreement do
    association :agreement, factory: :published_agreement

    ignore do
      user nil
    end 

    user_id { user.nil? ? -1 : user.id }
    user_type { user.nil? ? "DummyUser" : user.class.name }
  end  
end