require 'spec_helper'

module FinePrint
  describe Signature do
    it 'can''t be associated with unpublished contracts' do
      contract = FactoryGirl.create(:contract)
      expect(contract.is_published?).to eq false
      expect(contract.signatures).to be_empty

      sig = FactoryGirl.build(:signature)
      sig.contract = contract
      expect(sig.save).to eq false

      contract.reload
      expect(contract.signatures).to be_empty
    end
  end
end
