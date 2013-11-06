require 'spec_helper'

describe FinePrint::Signature do
  it 'prevents contract from being updated' do
    sig = FactoryGirl.build(:signature)
    contract = sig.contract
    expect(contract.can_be_updated?).to be_true

    sig.save!
    contract.reload
    expect(contract.can_be_updated?).to be_false
  end
end
