require 'spec_helper'

describe FinePrint::Contract do
  it 'can be published' do
    contract = FactoryGirl.create(:contract)
    expect(contract.is_published?).to be_false
    expect(contract.version).to be_nil
    expect(contract.is_latest?).to be_false

    contract.publish
    expect(contract.is_published?).to be_true
    expect(contract.version).to be 1
    expect(contract.is_latest?).to be_true
  end

  it 'can be modified after published with no user contracts yet' do
    contract = FactoryGirl.create(:contract)
    contract.publish
    contract.reload
    expect(contract.can_be_updated?).to be_true
  end

  it 'can''t be modified after a user agrees' do
    contract = FactoryGirl.create(:contract)
    expect(contract.can_be_updated?).to be_true

    contract.publish
    contract.reload
    ua = FactoryGirl.create(:signature, :contract => contract)
    contract.reload
    expect(contract.can_be_updated?).to be_false
  end

  it 'results in a first version if a name is changed after publishing' do
    contract = FactoryGirl.create(:published_contract)
    new_version = contract.draft_copy
    new_version.name = 'Joe'
    expect(new_version.save).to be_true
    new_version.publish
    expect(new_version.version).to eq 1
  end
end
