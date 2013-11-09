FactoryGirl.define do
  factory :signature, :class => FinePrint::Signature do
    association :contract, :factory => :published_contract
    association :user, :factory => :dummy_user
  end  
end
