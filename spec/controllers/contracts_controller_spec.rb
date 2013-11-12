require 'spec_helper'

module FinePrint
  describe ContractsController do
    routes { FinePrint::Engine.routes }

    before do
      setup_controller_spec
      @contract = FactoryGirl.create(:contract)
      @contract.reload
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
    
    it 'won''t get new unless authorized' do
      get :new, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      
      sign_in @user
      get :new, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
    end
    
    it 'must get new if authorized' do
      sign_in @admin
      get :new, :use_route => :fine_print
      assert_response :success
    end
    
    it 'won''t create unless authorized' do
      attributes = Hash.new
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'
      
      post :create, :contract => attributes, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      
      sign_in @user
      post :create, :contract => attributes, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
    end
    
    it 'must create if authorized' do
      sign_in @admin
      attributes = Hash.new
      attributes[:name] = 'some_name'
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'
      
      post :create, :contract => attributes, :use_route => :fine_print
      assert_redirected_to assigns(:contract)
      expect(assigns(:contract).errors).to be_empty
    end
    
    it 'won''t edit unless authorized' do
      get :edit, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      
      sign_in @user
      get :edit, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
    end
    
    it 'must edit if authorized' do
      sign_in @admin
      get :edit, :id => @contract.id, :use_route => :fine_print
      assert_response :success
    end
    
    it 'won''t update unless authorized' do
      attributes = Hash.new
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'
      title = @contract.title
      content = @contract.content
      
      put :update, :id => @contract.id, :contract => attributes, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      @contract.reload
      expect(@contract.title).to eq title
      expect(@contract.content).to eq content
      
      sign_in @user
      put :update, :id => @contract.id, :contract => attributes, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      @contract.reload
      expect(@contract.title).to eq title
      expect(@contract.content).to eq content
    end
    
    it 'must update if authorized' do
      attributes = Hash.new
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'
      title = @contract.title
      content = @contract.content
      sign_in @admin
      put :update, :id => @contract.id, :contract => attributes, :use_route => :fine_print
      assert_redirected_to @contract
      @contract.reload
      expect(@contract.errors).to be_empty
      expect(@contract.title).to eq 'Some title'
      expect(@contract.content).to eq 'Some content'
    end

    it 'won''t destroy unless authorized' do
      delete :destroy, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      expect(Contract.find(@contract.id)).to eq @contract
      
      sign_in @user
      delete :destroy, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      expect(Contract.find(@contract.id)).to eq @contract
    end
    
    it 'must destroy if authorized' do
      sign_in @admin
      delete :destroy, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to contracts_path
      expect(Contract.find_by_id(@contract.id)).to be_nil
    end

    it 'won''t publish unless authorized' do
      expect(@contract.is_published?).to eq false
      put :publish, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      @contract.reload
      expect(@contract.is_published?).to eq false
      
      sign_in @user
      put :publish, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      @contract.reload
      expect(@contract.is_published?).to eq false
    end
    
    it 'must publish if authorized' do
      expect(@contract.is_published?).to eq false
      sign_in @admin

      put :publish, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to contracts_path
      @contract.reload
      expect(@contract.is_published?).to eq true
    end

    it 'won''t unpublish unless authorized' do
      @contract.publish
      expect(@contract.is_published?).to eq true
      put :unpublish, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      @contract.reload
      expect(@contract.is_published?).to eq true
      
      sign_in @user
      put :unpublish, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      @contract.reload
      expect(@contract.is_published?).to eq true
    end
    
    it 'must unpublish if authorized' do
      @contract.publish
      expect(@contract.is_published?).to eq true

      sign_in @admin
      put :unpublish, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to contracts_path
      @contract.reload
      expect(@contract.is_published?).to eq false
    end

    it 'won''t new_version unless authorized' do
      @contract.publish
      expect(@contract.is_published?).to eq true
      
      put :new_version, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      expect(assigns(:contract)).to be_nil
      
      sign_in @user
      put :new_version, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to FinePrint.redirect_path
      expect(assigns(:contract)).to be_nil
    end
    
    it 'must new_version if authorized' do
      @contract.publish
      expect(@contract.is_published?).to eq true

      sign_in @admin
      put :new_version, :id => @contract.id, :use_route => :fine_print
      assert_response :success
      expect(assigns(:contract)).not_to be_nil
    end
  end
end
