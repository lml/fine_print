require 'spec_helper'

describe FinePrint do
  it 'gets unsigned contracts' do
    alpha_1 = FactoryGirl.create(:published_contract, :name => 'alpha')
    beta_1 = FactoryGirl.create(:published_contract, :name => 'beta')

    user = mock_model 'DummyUser', :id => -1
    alpha_1_sig = FactoryGirl.create(:signature, :contract => alpha_1, :user => user) 
    beta_1_sig = FactoryGirl.create(:signature, :contract => beta_1, :user => user)

    alpha_2 = alpha_1.draft_copy
    alpha_2.update_attributes(:content => 'foo')
    alpha_2.publish

    expect(FinePrint.get_unsigned_contract_names(['beta', 'alpha'], user)).to eq ['alpha']
  end
end
