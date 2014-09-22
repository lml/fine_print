require 'spec_helper'

module FinePrint
  describe SignaturesController, :type => :controller do
    routes { FinePrint::Engine.routes }

    before(:each) do
      setup_controller_spec
    end

    let!(:signature) { FactoryGirl.create(:signature) }

    it "won't get index unless authorized" do
      expect { get :index, :contract_id => signature.contract.id,
                           :use_route => :fine_print }
             .to raise_error(ActionController::RoutingError)
      
      sign_in @user
      expect { get :index, :contract_id => signature.contract.id,
                           :use_route => :fine_print }
             .to raise_error(ActionController::RoutingError)
    end
    
    it 'must get index if authorized' do
      sign_in @admin
      get :index, :contract_id => signature.contract.id,
                  :use_route => :fine_print
      expect(response.status).to eq 200
    end

    it "won't get new unless signed in" do
      get :new, :contract_id => signature.contract.id,
                :use_route => :fine_print
      expect(response.status).to eq 401
    end
    
    it 'must get new if signed in' do
      sign_in @user
      get :new, :contract_id => signature.contract.id,
                :use_route => :fine_print
      expect(response.status).to eq 200
    end

    it "won't create unless signed in" do
      post :create, :contract_id => signature.contract.id,
                    :use_route => :fine_print
      expect(response.status).to eq 401
    end
    
    it 'must create if signed in' do
      sign_in @user
      get :new, :contract_id => signature.contract.id,
                :use_route => :fine_print
      expect(response.status).to eq 200
    end

    it "won't destroy unless authorized" do
      expect { delete :destroy, :id => signature.id, :use_route => :fine_print }
             .to raise_error(ActionController::RoutingError)
      expect(Signature.find(signature.id)).to eq signature
      
      sign_in @user
      expect { delete :destroy, :id => signature.id, :use_route => :fine_print }
             .to raise_error(ActionController::RoutingError)
      expect(Signature.find(signature.id)).to eq signature
    end
    
    it 'must destroy if authorized' do
      sign_in @admin
      delete :destroy, :id => signature.id, :use_route => :fine_print
      expect(response).to redirect_to contract_signatures_path(signature.contract)
      expect(Signature.find_by_id(signature.id)).to be_nil
    end
  end
end
