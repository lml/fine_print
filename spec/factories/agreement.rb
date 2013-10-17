FactoryGirl.define do
  factory :agreement, class: FinePrint::Agreement do

    name { "Terms_#{SecureRandom.hex(4)}" }
    title { Faker::Lorem.sentence(3) }
    content { Faker::Lorem.paragraphs(2) }

    factory :published_agreement do
      after(:create) {|instance| instance.publish }
    end

    factory :agreement_agreed_to do
      after(:build) {|instance| instance.save; instance.publish }

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