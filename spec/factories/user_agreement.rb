require 'rspec-rails'

FactoryGirl.define do
  factory :user_agreement, class: FinePrint::UserAgreement do
    agreement
    user_id -1
    user_type "DummyUser"
  end  
end