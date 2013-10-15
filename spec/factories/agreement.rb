FactoryGirl.define do
  factory :agreement, class: FinePrint::Agreement do

    name { "Terms_#{SecureRandom.hex(4)}" }
    content { Faker::Lorem.paragraphs(2) }
    confirmation_text "I have read and agree to the terms and conditions above" 
    ready false

    trait :ready do
      ready true
    end

    factory :agreement_agreed_to do
      ignore do
        count 2
      end

      after(:build) do |agreement, evaluator|
        evaluator.count.times do 
          agreement.user_agreements << FactoryGirl.build(:user_agreement)
        end
      end
    end
  end
  
end