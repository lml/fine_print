require 'spec_helper'

module FinePrint
  describe SignaturesController do
    routes { FinePrint::Engine.routes }

    before do
      setup_controller_spec
      @signature = FactoryGirl.create(:signature)
      @signature.reload
    end

    it 'won''t get index unless authorized' do
      get :index, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      
      sign_in @user
      get :index, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
    end
    
    it 'must get index if authorized' do
      sign_in @admin
      get :index, :use_route => :fine_print
      assert_response :success
    end

    it 'won''t destroy unless authorized' do
      delete :destroy, :id => @signature.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      expect(Signature.find(@signature.id)).to eq @signature
      
      sign_in @user
      delete :destroy, :id => @signature.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
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
