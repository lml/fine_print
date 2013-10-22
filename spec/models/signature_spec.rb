require 'spec_helper'

describe FinePrint::Signature do
  
  it "is all good" do
    sig = FactoryGirl.create(:signature)
    contract = sig.contract

    expect(contract.update_attributes(content: "foo")).to be_false
  end

end