require 'spec_helper'

describe FinePrint::Signature do
  it 'can''t be associated with unpublished contracts' do
    contract = FactoryGirl.create(:contract)
    expect(contract.is_published?).to be_false
    expect(contract.can_be_updated?).to be_true

    sig = FactoryGirl.build(:signature)
    sig.contract = contract
    expect(sig.save).to be_false

    contract.reload
    expect(contract.can_be_updated?).to be_true
  end

  it 'prevents contract from being updated' do
    sig = FactoryGirl.build(:signature)
    contract = sig.contract
    expect(contract.can_be_updated?).to be_true

    sig.save!
    contract.reload
    expect(contract.can_be_updated?).to be_false
  end
end
