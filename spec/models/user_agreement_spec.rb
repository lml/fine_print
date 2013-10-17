require 'spec_helper'

describe FinePrint::UserAgreement do
  
  it "is all good" do
    ua = FactoryGirl.create(:user_agreement)
    agreement = ua.agreement

    expect(agreement.update_attributes(content: "foo")).to be_false
  end

end