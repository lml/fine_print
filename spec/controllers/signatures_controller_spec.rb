require 'spec_helper'

module FinePrint
  describe SignaturesController, type: :controller do
    routes { FinePrint::Engine.routes }

    before(:each) do
      setup_controller_spec
    end

    let!(:signature) { FactoryBot.create(:fine_print_signature) }

    it "won't get index unless authorized" do
      get :index, params: { contract_id: signature.contract.id }
      expect(response.status).to eq 403
      
      sign_in @user
      get :index, params: { contract_id: signature.contract.id }
      expect(response.status).to eq 403
    end
    
    it 'must get index if authorized' do
      sign_in @admin
      get :index, params: { contract_id: signature.contract.id }
      expect(response.status).to eq 200
    end

    it "won't get new unless signed in" do
      get :new, params: { contract_id: signature.contract.id }
      expect(response.status).to eq 401
    end
    
    it 'must get new if signed in' do
      sign_in @user
      get :new, params: { contract_id: signature.contract.id }
      expect(response.status).to eq 200
    end

    it "won't create unless signed in" do
      post :create, params: { contract_id: signature.contract.id }
      expect(response.status).to eq 401
    end
    
    it 'must create if signed in' do
      sign_in @user
      get :new, params: { contract_id: signature.contract.id }
      expect(response.status).to eq 200
    end

    it "won't destroy unless authorized" do
      delete :destroy, params: { id: signature.id }
      expect(response.status).to eq 403
      expect(Signature.find(signature.id)).to eq signature
      
      sign_in @user
      delete :destroy, params: { id: signature.id }
      expect(response.status).to eq 403
      expect(Signature.find(signature.id)).to eq signature
    end
    
    it 'must destroy if authorized' do
      sign_in @admin
      delete :destroy, params: { id: signature.id }
      expect(response).to redirect_to contract_signatures_path(signature.contract)
      expect(Signature.find_by_id(signature.id)).to be_nil
    end
  end
end
