FactoryGirl.define do
  factory :fine_print_signature, class: FinePrint::Signature do
    association :contract, factory: [:fine_print_contract, :published]

    transient do
      user_factory :user
    end

    after(:build) do |signature, evaluator|
      signature.user ||= FactoryGirl.build(evaluator.user_factory)
    end
  end  
end
