require 'spec_helper'

module FinePrint
  describe Signature, type: :model do
    it "can't be associated with unpublished contracts" do
      contract = FactoryBot.create(:fine_print_contract)
      expect(contract.is_published?).to eq false
      expect(contract.signatures).to be_empty

      sig = FactoryBot.build(:fine_print_signature)
      sig.contract = contract
      expect(sig.save).to eq false

      contract.reload
      expect(contract.signatures).to be_empty
    end
  end
end
