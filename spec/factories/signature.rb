require 'rspec-rails'

FactoryGirl.define do
  factory :signature, :class => FinePrint::Signature do
    association :contract, :factory => :published_contract

    ignore do
      user nil
    end 

    user_id { user.nil? ? -1 : user.id }
    user_type { user.nil? ? 'DummyUser' : user.class.name }
  end  
end
