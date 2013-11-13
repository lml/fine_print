require 'spec_helper'

describe FinePrint do
  before :each do
    @alpha_1 = FactoryGirl.create(:published_contract, :name => 'alpha')
    @beta_1 = FactoryGirl.create(:published_contract, :name => 'beta')

    @user = mock_model 'DummyUser', :id => -1
    @alpha_1_sig = FactoryGirl.create(:signature, :contract => @alpha_1, :user => @user) 
    @beta_1_sig = FactoryGirl.create(:signature, :contract => @beta_1, :user => @user)

    @alpha_2 = @alpha_1.draft_copy
    @alpha_2.update_attribute(:content, 'foo')
    @alpha_2.publish
  end

  it 'gets contracts' do
    expect(FinePrint.get_contract(@beta_1)).to eq @beta_1
    expect(FinePrint.get_contract(@beta_1.id)).to eq @beta_1
    expect(FinePrint.get_contract('beta')).to eq @beta_1
    expect(FinePrint.get_contract(@alpha_1)).to eq @alpha_1
    expect(FinePrint.get_contract(@alpha_1.id)).to eq @alpha_1
    expect(FinePrint.get_contract('alpha')).to eq @alpha_2
  end

  it 'gets unsigned contracts' do
    expect(FinePrint.get_unsigned_contract_names(['beta', 'alpha'], @user)).to eq ['alpha']
  end

  it 'allows users to sign contracts' do
    expect(FinePrint.signed_contract?(@alpha_1, @user)).to eq true
    expect(FinePrint.signed_contract?(@alpha_2, @user)).to eq false
    expect(FinePrint.signed_contract?(@beta_1, @user)).to eq true
    expect(FinePrint.signed_any_contract_version?(@alpha_1, @user)).to eq true
    expect(FinePrint.signed_any_contract_version?(@alpha_2, @user)).to eq true
    expect(FinePrint.signed_any_contract_version?(@beta_1, @user)).to eq true

    expect(FinePrint.sign_contract(@alpha_2, @user)).to be_a FinePrint::Signature

    expect(FinePrint.signed_contract?(@alpha_1, @user)).to eq true
    expect(FinePrint.signed_contract?(@alpha_2, @user)).to eq true
    expect(FinePrint.signed_contract?(@beta_1, @user)).to eq true
    expect(FinePrint.signed_any_contract_version?(@alpha_1, @user)).to eq true
    expect(FinePrint.signed_any_contract_version?(@alpha_2, @user)).to eq true
    expect(FinePrint.signed_any_contract_version?(@beta_1, @user)).to eq true
  end
end
