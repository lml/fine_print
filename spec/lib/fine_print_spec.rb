require 'spec_helper'

RSpec.describe FinePrint, type: :lib do
  before :each do
    @alpha_1 = FactoryBot.create(:fine_print_contract, :published, name: 'alpha')
    @beta_1 = FactoryBot.create(:fine_print_contract, :published, name: 'beta')

    @user = DummyUser.create
    @alpha_1_sig = FactoryBot.create(:fine_print_signature, contract: @alpha_1, user: @user)
    @beta_1_sig = FactoryBot.create(:fine_print_signature, contract: @beta_1, user: @user)

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
    expect(FinePrint.signed_contracts_for(@user)).to eq [@beta_1]
  end

  it 'gets unsigned contracts' do
    names = [@alpha_2, @beta_1].map(&:name)
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

  it 'can record implicit signatures' do
    signature = FinePrint.sign_contract(@user, @alpha_2, FinePrint::SIGNATURE_IS_IMPLICIT)

    expect(signature.is_implicit?).to eq true
    expect(signature.is_explicit?).to eq false
  end

  it 'records signatures explicitly by default' do
    expect(FinePrint.sign_contract(@user, @alpha_2).is_explicit?).to eq true
  end
end
