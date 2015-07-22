require 'spec_helper'

module FinePrint
  describe ContractsController, type: :controller do
    routes { FinePrint::Engine.routes }

    before(:each) do
      setup_controller_spec
    end

    let!(:contract) { FactoryGirl.create(:fine_print_contract) }

    it "won't get index unless authorized" do
      get :index
      expect(response.status).to eq 403

      sign_in @user
      get :index
      expect(response.status).to eq 403
    end

    it 'must get index if authorized' do
      sign_in @admin
      get :index
      expect(response.status).to eq 200
    end

    it "won't get new unless authorized" do
      get :new
      expect(response.status).to eq 403

      sign_in @user
      get :new
      expect(response.status).to eq 403
    end

    it 'must get new if authorized' do
      sign_in @admin
      get :new
      expect(response.status).to eq 200
    end

    it "won't create unless authorized" do
      attributes = Hash.new
      attributes[:name] = 'some_name'
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'

      post :create, contract: :attributes
      expect(response.status).to eq 403
      expect(assigns(:contract)).to be_nil

      sign_in @user
      post :create, contract: :attributes
      expect(response.status).to eq 403
      expect(assigns(:contract)).to be_nil
    end

    it 'must create if authorized' do
      sign_in @admin
      attributes = Hash.new
      attributes[:name] = 'some_name'
      attributes[:title] = 'Some title'
      attributes[:content] = 'Some content'
      attributes[:is_signed_by_proxy] = true

      post :create, contract: attributes
      expect(response).to redirect_to assigns(:contract)
      expect(assigns(:contract).errors).to be_empty
      expect(assigns(:contract).name).to eq 'some_name'
      expect(assigns(:contract).title).to eq 'Some title'
      expect(assigns(:contract).content).to eq 'Some content'
      expect(assigns(:contract).is_signed_by_proxy).to eq true
    end

    it "won't edit unless authorized" do
      get :edit, id: contract.id
      expect(response.status).to eq 403

      sign_in @user
      get :edit, id: contract.id
      expect(response.status).to eq 403
    end

    it 'must edit if authorized' do
      sign_in @admin
      get :edit, id: contract.id
      expect(response.status).to eq 200
    end

    it "won't update unless authorized" do
      attributes = Hash.new
      attributes[:name] = 'another_name'
      attributes[:title] = 'Another title'
      attributes[:content] = 'Another content'
      name = contract.name
      title = contract.title
      content = contract.content

      put :update, id: contract.id, contract: attributes
      expect(response.status).to eq 403
      contract.reload
      expect(contract.name).to eq name
      expect(contract.title).to eq title
      expect(contract.content).to eq content

      sign_in @user
      put :update, id: contract.id, contract: attributes
      expect(response.status).to eq 403
      contract.reload
      expect(contract.name).to eq name
      expect(contract.title).to eq title
      expect(contract.content).to eq content
    end

    it 'must update if authorized' do
      attributes = Hash.new
      attributes[:name] = 'another_name'
      attributes[:title] = 'Another title'
      attributes[:content] = 'Another content'
      attributes[:is_signed_by_proxy] = false

      sign_in @admin
      put :update, id: contract.id, contract: attributes
      expect(response).to redirect_to contract
      contract.reload
      expect(contract.errors).to be_empty
      expect(contract.name).to eq 'another_name'
      expect(contract.title).to eq 'Another title'
      expect(contract.content).to eq 'Another content'
      expect(contract.is_signed_by_proxy).to eq false
    end

    it "won't destroy unless authorized" do
      delete :destroy, id: contract.id
      expect(response.status).to eq 403
      expect(Contract.find(contract.id)).to eq contract

      sign_in @user
      delete :destroy, id: contract.id
      expect(response.status).to eq 403
      expect(Contract.find(contract.id)).to eq contract
    end

    it 'must destroy if authorized' do
      sign_in @admin
      delete :destroy, id: contract.id
      expect(response).to redirect_to contracts_path
      expect(Contract.find_by_id(contract.id)).to be_nil
    end

    it "won't publish unless authorized" do
      expect(contract.is_published?).to eq false
      put :publish, id: contract.id
      expect(response.status).to eq 403
      contract.reload
      expect(contract.is_published?).to eq false

      sign_in @user
      put :publish, id: contract.id
      expect(response.status).to eq 403
      contract.reload
      expect(contract.is_published?).to eq false
    end

    it 'must publish if authorized' do
      expect(contract.is_published?).to eq false
      sign_in @admin

      put :publish, id: contract.id
      expect(response).to redirect_to contracts_path
      contract.reload
      expect(contract.is_published?).to eq true
    end

    it "won't unpublish unless authorized" do
      contract.publish
      expect(contract.is_published?).to eq true
      put :unpublish, id: contract.id
      expect(response.status).to eq 403
      contract.reload
      expect(contract.is_published?).to eq true

      sign_in @user
      put :unpublish, id: contract.id
      expect(response.status).to eq 403
      contract.reload
      expect(contract.is_published?).to eq true
    end

    it 'must unpublish if authorized' do
      contract.publish
      expect(contract.is_published?).to eq true

      sign_in @admin
      put :unpublish, id: contract.id
      expect(response).to redirect_to contracts_path
      contract.reload
      expect(contract.is_published?).to eq false
    end

    it "won't create new_version unless authorized" do
      contract.publish
      expect(contract.is_published?).to eq true

      post :new_version, id: contract.id
      expect(response.status).to eq 403
      expect(assigns(:contract)).to be_nil

      sign_in @user
      post :new_version, id: contract.id
      expect(response.status).to eq 403
      expect(assigns(:contract)).to be_nil
    end

    it 'must create new_version if authorized' do
      contract.publish
      expect(contract.is_published?).to eq true

      sign_in @admin
      post :new_version, id: contract.id
      expect(response.status).to eq 200
      expect(assigns(:contract)).not_to be_nil
    end
  end
end
