require 'spec_helper'

describe FinePrint::Agreement do
  
  it "can't be modified after a user agrees" do
    agreement = FactoryGirl.create(:agreement)
    expect(agreement.update_attributes(content: 'booya')).to be_true
    ua = FactoryGirl.create(:user_agreement, agreement: agreement)
    agreement.reload
    expect(agreement.update_attributes(content: 'booya')).to be_false
  end

end