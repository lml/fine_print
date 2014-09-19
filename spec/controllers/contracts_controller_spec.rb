require 'spec_helper'

module FinePrint
  describe ContractsController, :type => :controller do
    routes { FinePrint::Engine.routes }

    before do
      setup_controller_spec
      @contract = FactoryGirl.create(:contract)
      @contract.reload
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
    
    it "won't get new unless authorized" do
      expect { get :new, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      
      sign_in @user
      expect { get :new, :use_route => :fine_print }
      .to raise_error(FinePrint::SecurityTransgression)
    end
    
    it 'must get new if authorized' do
      sign_in @admin
      get :new, :use_route => :fine_print
      assert_response :success
    end
    
    it "won't create unless authorized" do
      attributes = Hash.new
      attributes[:name] = 'some_name'
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'
      
      expect { post :create, :contract => :attributes, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      expect(assigns(:contract)).to be_nil
      
      sign_in @user
      expect { post :create, :contract => :attributes, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      expect(assigns(:contract)).to be_nil
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
      expect(assigns(:contract).name).to eq 'some_name'
      expect(assigns(:contract).title).to eq 'Some title'
      expect(assigns(:contract).content).to eq 'Some content'
    end
    
    it "won't edit unless authorized" do
      expect { get :edit, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      
      sign_in @user
      expect { get :edit, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
    end
    
    it 'must edit if authorized' do
      sign_in @admin
      get :edit, :id => @contract.id, :use_route => :fine_print
      assert_response :success
    end
    
    it "won't update unless authorized" do
      attributes = Hash.new
      attributes[:name] = 'some_name'
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'
      name = @contract.name
      title = @contract.title
      content = @contract.content
      
      expect { post :update, :id => @contract.id,
                    :contract => attributes, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      @contract.reload
      expect(@contract.name).to eq name
      expect(@contract.title).to eq title
      expect(@contract.content).to eq content
      
      sign_in @user
      expect { post :update, :id => @contract.id,
        :contract => attributes, :use_route => :fine_print }
      .to raise_error(FinePrint::SecurityTransgression)
      @contract.reload
      expect(@contract.name).to eq name
      expect(@contract.title).to eq title
      expect(@contract.content).to eq content
    end
    
    it 'must update if authorized' do
      attributes = Hash.new
      attributes[:name] = 'some_name'
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'

      sign_in @admin
      put :update, :id => @contract.id, :contract => attributes, :use_route => :fine_print
      assert_redirected_to @contract
      @contract.reload
      expect(@contract.errors).to be_empty
      expect(@contract.name).to eq 'some_name'
      expect(@contract.title).to eq 'Some title'
      expect(@contract.content).to eq 'Some content'
    end

    it "won't destroy unless authorized" do
      expect { delete :destroy, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      expect(Contract.find(@contract.id)).to eq @contract
      
      sign_in @user
      expect { delete :destroy, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      expect(Contract.find(@contract.id)).to eq @contract
    end
    
    it 'must destroy if authorized' do
      sign_in @admin
      delete :destroy, :id => @contract.id, :use_route => :fine_print
      assert_redirected_to contracts_path
      expect(Contract.find_by_id(@contract.id)).to be_nil
    end

    it "won't publish unless authorized" do
      expect(@contract.is_published?).to eq false
      expect { put :publish, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      @contract.reload
      expect(@contract.is_published?).to eq false
      
      sign_in @user
      expect { put :publish, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
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

    it "won't unpublish unless authorized" do
      @contract.publish
      expect(@contract.is_published?).to eq true
      expect { put :unpublish, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      @contract.reload
      expect(@contract.is_published?).to eq true
      
      sign_in @user
      expect { put :unpublish, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
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

    it "won't new_version unless authorized" do
      @contract.publish
      expect(@contract.is_published?).to eq true
      
      expect { put :new_version, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
      expect(assigns(:contract)).to be_nil
      
      sign_in @user
      expect { put :new_version, :id => @contract.id, :use_route => :fine_print }
             .to raise_error(FinePrint::SecurityTransgression)
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
