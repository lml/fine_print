require 'spec_helper'

module FinePrint
  describe SignaturesController do
    routes { FinePrint::Engine.routes }

    before do
      setup_controller_spec
      @signature = FactoryGirl.create(:signature)
      @signature.reload
    end

    it "won't get index unless authorized" do
      expect { get :index, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      
      sign_in @user
      expect { get :index, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
    end
    
    it 'must get index if authorized' do
      sign_in @admin
      get :index, :use_route => :fine_print
      assert_response :success
    end

    it "won't destroy unless authorized" do
      expect { delete :destroy, :id => @signature.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      expect(Signature.find(@signature.id)).to eq @signature
      
      sign_in @user
      expect { delete :destroy, :id => @signature.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      expect(Signature.find(@signature.id)).to eq @signature
    end
    
    it 'must destroy if authorized' do
      sign_in @admin
      delete :destroy, :id => @signature.id, :use_route => :fine_print
      assert_redirected_to signatures_path
      expect(Signature.find_by_id(@signature.id)).to be_nil
    end
  end
end
