require 'spec_helper'

module FinePrint
  describe Contract do
    it 'can be published and unpublished' do
      contract = FactoryGirl.create(:contract)
      expect(contract.is_published?).to eq false
      expect(contract.version).to be_nil
      expect(contract.is_latest?).to eq false
      expect(contract.can_be_updated?).to eq true
      expect(contract.can_be_published?).to eq true
      expect(contract.can_be_unpublished?).to eq false

      contract.unpublish
      expect(contract.errors).not_to be_empty
      contract.errors.clear
      expect(contract.errors).to be_empty
      contract.publish
      expect(contract.errors).to be_empty
      expect(contract.is_published?).to eq true
      expect(contract.version).to eq 1
      expect(contract.is_latest?).to eq true
      expect(contract.can_be_updated?).to eq true
      expect(contract.can_be_published?).to eq false
      expect(contract.can_be_unpublished?).to eq true

      contract.publish
      expect(contract.errors).not_to be_empty
      contract.errors.clear
      expect(contract.errors).to be_empty
      contract.unpublish
      expect(contract.errors).to be_empty
      expect(contract.is_published?).to eq false
    end

    it "can't be modified after a user signs" do
      contract = FactoryGirl.create(:contract)

      contract.publish
      expect(contract.is_published?).to eq true
      expect(contract.can_be_updated?).to eq true
      expect(contract.can_be_published?).to eq false
      expect(contract.can_be_unpublished?).to eq true

      ua = FactoryGirl.create(:signature, :contract => contract)
      contract.reload
      expect(contract.can_be_updated?).to eq false
      expect(contract.can_be_published?).to eq false
      expect(contract.can_be_unpublished?).to eq false

      contract.save
      expect(contract.errors).not_to be_empty
      contract.errors.clear
      expect(contract.errors).to be_empty
      contract.unpublish
      expect(contract.errors).not_to be_empty
      expect(contract.is_published?).to eq true
    end

    it 'results in a new version if a copy is published' do
      contract = FactoryGirl.create(:published_contract)
      expect(contract.version).to eq 1
      new_version = contract.new_version
      expect(new_version.save).to eq true
      new_version.publish
      expect(new_version.version).to eq 2
    end

    it 'results in a first version if a name is changed after publishing' do
      contract = FactoryGirl.create(:published_contract)
      expect(contract.version).to eq 1
      new_version = contract.draft_copy
      new_version.name = 'Joe'
      expect(new_version.save).to eq true
      new_version.publish
      expect(new_version.version).to eq 1
    end
  end
end
