FactoryBot.define do
  factory :fine_print_contract, class: FinePrint::Contract do
    name { Faker::Lorem.words.join('_') }
    title { Faker::Lorem.words.join(' ').capitalize }
    content { Faker::Lorem.paragraphs.join("\n") }

    trait :published do
      transient do
        user_factory { :user }
        signatures_count { 0 }
      end

      after(:build) do |contract, evaluator|
        contract.version = (contract.same_name.published
                                    .first.try(:version) || 0) + 1

        evaluator.signatures_count.times do 
          contract.signatures << FactoryBot.build(
                                   :fine_print_signature,
                                   user_factory: evaluator.user_factory
                                 )
        end
      end
    end
  end
end
