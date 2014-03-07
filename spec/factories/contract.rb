FactoryGirl.define do
  factory :contract, :class => FinePrint::Contract do
    name { "Contract_#{SecureRandom.hex(4)}" }
    title { Faker::Lorem.sentence(3).to_s }
    content { Faker::Lorem.paragraphs(2).to_s }

    factory :published_contract do
      after(:create) {|instance| instance.publish }
    end

    factory :signed_contract do
      after(:build) {|instance| instance.save; instance.publish }

      ignore do
        count 2
      end

      after(:build) do |contract, evaluator|
        evaluator.count.times do 
          contract.signatures << FactoryGirl.build(:signature)
        end
      end
    end
  end
end
