FactoryBot.define do
  factory :fine_print_signature, class: FinePrint::Signature do
    association :contract, factory: [:fine_print_contract, :published]

    trait :implicit do
      is_implicit { FinePrint::SIGNATURE_IS_IMPLICIT }
    end

    transient do
      user_factory { :user }
    end

    after(:build) do |signature, evaluator|
      signature.user ||= FactoryBot.build(evaluator.user_factory)
    end
  end
end
