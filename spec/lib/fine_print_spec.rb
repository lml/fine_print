require 'spec_helper'

describe FinePrint, type: :lib do
  before :each do
    @alpha_1 = FactoryGirl.create(:fine_print_contract, :published,
                                                        name: 'alpha')
    @beta_1 = FactoryGirl.create(:fine_print_contract, :published,
                                                       name: 'beta')

    @user = DummyUser.create
    @alpha_1_sig = FactoryGirl.create(:fine_print_signature, contract: @alpha_1,
                                                             user: @user)
    @beta_1_sig = FactoryGirl.create(:fine_print_signature, contract: @beta_1,
                                                            user: @user)

    @alpha_2 = @alpha_1.new_version
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

  it 'gets signed contracts' do
    expect(FinePrint.signed_contracts_for(@user)).to(
      eq [@beta_1]
    )
  end

  it 'gets unsigned contracts' do
    names = [@alpha_2, @beta_1].collect{|c| c.name}
    expect(FinePrint.unsigned_contracts_for(@user, name: names)).to eq [@alpha_2]
  end

  it 'allows users to sign contracts' do
    expect(FinePrint.signed_contract?(@user, @alpha_1)).to eq true
    expect(FinePrint.signed_contract?(@user, @alpha_2)).to eq false
    expect(FinePrint.signed_contract?(@user, @beta_1)).to eq true
    expect(FinePrint.signed_any_version_of_contract?(@user, @alpha_1)).to eq true
    expect(FinePrint.signed_any_version_of_contract?(@user, @alpha_2)).to eq true
    expect(FinePrint.signed_any_version_of_contract?(@user, @beta_1)).to eq true

    expect(FinePrint.sign_contract(@user, @alpha_2)).to be_a FinePrint::Signature

    expect(FinePrint.signed_contract?(@user, @alpha_1)).to eq true
    expect(FinePrint.signed_contract?(@user, @alpha_2)).to eq true
    expect(FinePrint.signed_contract?(@user, @beta_1)).to eq true
    expect(FinePrint.signed_any_version_of_contract?(@user, @alpha_1)).to eq true
    expect(FinePrint.signed_any_version_of_contract?(@user, @alpha_2)).to eq true
    expect(FinePrint.signed_any_version_of_contract?(@user, @beta_1)).to eq true
  end

  it 'automatically signs contracts signed by proxy' do
    contract = FactoryGirl.create(:fine_print_contract, :published,
                                  :signed_by_proxy, name: 'gamma')

    expect(FinePrint.signed_contract?(@user, contract)).to eq false
    expect(FinePrint.unsigned_contracts_for(@user, name: 'gamma')).to eq []
    expect(FinePrint.signed_contract?(@user, contract)).to eq true
  end
end
