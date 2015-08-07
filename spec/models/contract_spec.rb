require 'spec_helper'

module FinePrint
  describe Contract, type: :model do
    it 'can be published and unpublished' do
      contract = FactoryGirl.create(:fine_print_contract)
      expect(contract.is_published?).to eq false
      expect(contract.version).to be_nil
      expect(contract.is_latest?).to eq false
      expect(contract.signatures).to be_empty

      contract.unpublish
      expect(contract.errors).not_to be_empty
      contract.errors.clear
      expect(contract.errors).to be_empty
      contract.publish
      expect(contract.errors).to be_empty
      expect(contract.is_published?).to eq true
      expect(contract.version).to eq 1
      expect(contract.is_latest?).to eq true
      expect(contract.signatures).to be_empty

      contract.publish
      expect(contract.errors).not_to be_empty
      contract.errors.clear
      expect(contract.errors).to be_empty
      contract.unpublish
      expect(contract.errors).to be_empty
      expect(contract.is_published?).to eq false
    end

    it "can't be modified after a user signs it" do
      contract = FactoryGirl.create(:fine_print_contract)

      contract.publish
      expect(contract.is_published?).to eq true
      expect(contract.signatures).to be_empty

      ua = FactoryGirl.create(:fine_print_signature, contract: contract)
      contract.reload
      expect(contract.signatures).not_to be_empty

      contract.save
      expect(contract.errors).not_to be_empty
      contract.errors.clear
      expect(contract.errors).to be_empty
      contract.unpublish
      expect(contract.errors).not_to be_empty
      expect(contract.reload.is_published?).to eq true
    end

    it 'results in a new version if a copy is published' do
      contract = FactoryGirl.create(:fine_print_contract, :published)
      expect(contract.version).to eq 1
      new_version = contract.new_version
      expect(new_version.save).to eq true
      new_version.publish
      expect(new_version.version).to eq 2
    end

    it 'results in a first version if a name is changed after publishing' do
      contract = FactoryGirl.create(:fine_print_contract, :published)
      expect(contract.version).to eq 1
      new_version = contract.new_version
      new_version.name = 'Joe'
      expect(new_version.save).to eq true
      new_version.publish
      expect(new_version.version).to eq 1
    end

    it 'calls the contract_published_proc after publish' do
      original_proc = FinePrint.config.contract_published_proc

      begin
        FinePrint.config.contract_published_proc = lambda do |contract|
          contract.name = 'Deep Thought'
        end
        contract = FactoryGirl.create(:fine_print_contract, name: '42')
        contract.publish
        expect(contract.name).to eq 'Deep Thought'
      rescue
        fail
      ensure
        FinePrint.config.contract_published_proc = original_proc
      end
    end

  end
end
