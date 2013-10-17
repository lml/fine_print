require 'spec_helper'

describe FinePrint::Agreement do
  
  it "can be published" do
    agreement = FactoryGirl.create(:agreement)
    expect(agreement.published?).to be_false
    expect(agreement.version).to be_nil
    expect(agreement.is_latest).to be_false
    agreement.publish
    expect(agreement.published?).to be_true
    expect(agreement.version).to be 1
    expect(agreement.is_latest).to be_true
  end

  it "can be modified after published with no user agreements yet" do
    agreement = FactoryGirl.create(:agreement)
    agreement.publish
    agreement.reload
    expect(agreement.update_attributes(content: 'booya')).to be_true
  end

  it "can't be modified after a user agrees" do
    agreement = FactoryGirl.create(:agreement)
    expect(agreement.update_attributes(content: 'booya')).to be_true
    agreement.publish
    agreement.reload
    ua = FactoryGirl.create(:user_agreement, agreement: agreement)
    agreement.reload
    expect(agreement.update_attributes(content: 'booya')).to be_false
  end

  it "results in a first version if a name is changed after publishing" do
    agreement = FactoryGirl.create(:published_agreement)
    new_version = agreement.draft_copy
    new_version.name = "Joe"
    expect(new_version.save).to be_true
    new_version.publish
    expect(new_version.version).to eq 1
  end

end