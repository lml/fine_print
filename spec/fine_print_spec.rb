require 'spec_helper'

describe FinePrint do
  
  it "gets unsigned agreements" do
    alpha_1 = FactoryGirl.create(:published_agreement, name: 'alpha')
    beta_1 = FactoryGirl.create(:published_agreement, name: 'beta')

    user = mock_model "DummyUser", id: -1
    alpha_1_ua = FactoryGirl.create(:user_agreement, agreement: alpha_1, user: user) 
    beta_1_ua = FactoryGirl.create(:user_agreement, agreement: beta_1, user: user)

    alpha_2 = alpha_1.draft_copy
    alpha_2.update_attributes(content: "foo")
    alpha_2.publish

    expect(FinePrint.get_unsigned_agreement_names(names: ['beta', 'alpha'], user: user)).to eq ['alpha']
  end

end