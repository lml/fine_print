require 'spec_helper'

module FinePrint
  describe HomeController, :type => :controller do
    routes { FinePrint::Engine.routes }

    before(:each) do
      setup_controller_spec
    end

    it "won't get index unless authorized" do
      get :index, :use_route => :fine_print
      expect(response.status).to eq 403
      
      sign_in @user
      get :index, :use_route => :fine_print
      expect(response.status).to eq 403
    end
    
    it 'must get index if authorized' do
      sign_in @user
      @user.is_admin = true
      get :index, :use_route => :fine_print
      expect(response).to redirect_to contracts_path
    end
  end
end
